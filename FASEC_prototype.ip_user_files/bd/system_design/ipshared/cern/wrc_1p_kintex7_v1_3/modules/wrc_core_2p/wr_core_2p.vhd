-- Title      : WhiteRabbit PTP Core
-- Project    : WhiteRabbit
-------------------------------------------------------------------------------
-- File       : wr_core.vhd
-- Author     : Grzegorz Daniluk
-- Company    : Elproma
-- Created    : 2011-02-02
-- Last update: 2017-03-14
-- Platform   : FPGA-generics
-- Standard   : VHDL
-------------------------------------------------------------------------------
-- Description:
-- WR PTP Core is a HDL module implementing a complete gigabit Ethernet
-- interface (MAC + PCS + PHY) with integrated PTP slave ordinary clock
-- compatible with White Rabbit protocol. It performs subnanosecond clock
-- synchronization via WR protocol and also acts as an Ethernet "gateway",
-- providing access to TX/RX interfaces of the built-in WR MAC.
--
-- Starting from version 2.0 all modules are interconnected with pipelined
-- wishbone interface (using wb crossbars). Separate pipelined wishbone bus is
-- used for passing packets between Endpoint, Mini-NIC and External
-- MAC interface.
-------------------------------------------------------------------------------
--
-- Copyright (c) 2011, 2012 Elproma Elektronika
-- Copyright (c) 2012, 2013 CERN
--
-- This source file is free software; you can redistribute it
-- and/or modify it under the terms of the GNU Lesser General
-- Public License as published by the Free Software Foundation;
-- either version 2.1 of the License, or (at your option) any
-- later version.
--
-- This source is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE.  See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from http://www.gnu.org/licenses/lgpl-2.1.html
--
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2011-02-02  1.0      greg.d          Created
-- 2011-10-25  2.0      greg.d          Redesigned and wishbonized
-- 2012-03-05  3.0      wterpstra       Added SDB descriptors
-- 2014-10-24  4.0      eml             Two ports compatible for the wrc_2p.
-------------------------------------------------------------------------------


-- Memory map:

-- Master interconnect:
--  0x00000000: I/D Memory 1 (GTP0 packet exchange & LM32 SW)
--  0x00020000: I/D Memory 2 (GTP1 packet exchange)
--  0x00030000: Peripheral interconnect
--      +0x000: Minic 1 (for GTP0)
--      +0x100: Endpoint 1 (for (GTP0)
--      +0x200: Softpll
--      +0x300: PPS gen
--      +0x400: Syscon
--      +0x500: UART
--      +0x600: OneWire
--      +0x700: Auxillary space (Etherbone config, etc)
--      +0x800: Minic 2 (for GTP1)
--      +0x900: Endpoint 2 (for GTP1)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.STD_LOGIC_ARITH.all;

library work;
use work.wrcore_2p_pkg.all;
use work.genram_pkg.all;
use work.wishbone_pkg.all;
use work.endpoint_pkg.all;
use work.etherbone_pkg.all;
use work.wr_fabric_pkg.all;
use work.sysc_wbgen2_pkg.all;
use work.gen7s_cores_pkg.all;
use work.softpll_pkg.all;

entity wr_core_2p is
  generic(
    --if set to 1, then blocks in PCS use smaller calibration counter to speed
    --up simulation
    g_simulation                : integer                        := 0;
    g_with_external_clock_input : boolean                        := false;
    --
    g_phys_uart                 : boolean                        := true;
    g_virtual_uart              : boolean                        := false;
    g_aux_clks                  : integer                        := 1;
    g_rx_buffer_size            : integer                        := 1024;
    g_main_dpram_initf          : string                         := "default";
    g_main_dpram_size           : integer                        := 90112/4;  --in 32-bit words
    g_sec_dpram_size            : integer                        := 90112/4;  --in 32-bit words
    g_interface_mode            : t_wishbone_interface_mode      := PIPELINED;
    g_address_granularity       : t_wishbone_address_granularity := WORD;
    g_softpll_channels_config   : t_softpll_channel_config_array := c_softpll_default_channel_config;
    g_softpll_enable_debugger   : boolean                        := false;
    g_num_phys                  : integer                        := 2;
    g_ep_with_rtu               : boolean                        := false;

    g_pcs_16bit         : boolean := true;
    g_tx_runt_padding   : boolean := true;
    g_with_flow_control : boolean := false;

    g_extbar_bridge_sdb : t_sdb_bridge := c_empty_bridge_sdb);
  port(
    ---------------------------------------------------------------------------
    -- Clocks/resets
    ---------------------------------------------------------------------------

    -- system reference clock (any frequency <= f(clk_ref_i))
    clk_sys_i : in std_logic;

    --Reset for the ethernet chipset.
    phy_rst_n_o : out std_logic;

    -- DDMTD offset clock (125.x MHz)
    clk_dmtd_i : in std_logic;

    -- Timing reference (125 MHz)
    clk_ref_i : in std_logic;

    -- Aux clocks (i.e. the FMC clock), which can be disciplined by the WR Core
    clk_aux_i : in std_logic_vector(g_aux_clks-1 downto 0) := (others => '0');

    -- External 10 MHz reference (cesium, GPSDO, etc.), used in Grandmaster mode
    clk_ext_i            : in std_logic := '0';
    clk_ext_mul_i        : in std_logic := '0';
    clk_ext_mul_locked_i : in std_logic := '0';

    -- External PPS input (cesium, GPSDO, etc.), used in Grandmaster mode
    pps_ext_i : in std_logic := '0';
    rst_n_i   : in std_logic;

    -----------------------------------------
    --Timing system
    -----------------------------------------
    dac_hpll_load_p1_o : out std_logic;
    dac_hpll_data_o    : out std_logic_vector(15 downto 0);

    dac_dpll_load_p1_o : out std_logic;
    dac_dpll_data_o    : out std_logic_vector(15 downto 0);

    -- PHY I/f. These ports are for one port WRC.
    phy_ref_clk_i : in std_logic;

    --AD9516 SYNC
    pll_sync_n_o : out std_logic;

    -- 2 ports WRC.
    phys_o : out t_phyif_output_array(g_num_phys-1 downto 0);
    phys_i : in  t_phyif_input_array(g_num_phys-1 downto 0);

    -----------------------------------------
    --GPIO
    -----------------------------------------
    led_act_o  : out std_logic_vector(1 downto 0);
    led_link_o : out std_logic_vector(1 downto 0);

    scl_o      : out std_logic;
    scl_i      : in  std_logic := '1';
    sda_o      : out std_logic;
    sda_i      : in  std_logic := '1';
    gtp0_scl_o : out std_logic;
    gtp0_scl_i : in  std_logic := '1';
    gtp0_sda_o : out std_logic;
    gtp0_sda_i : in  std_logic := '1';
    gtp0_det_i : in  std_logic := '1';
    gtp1_scl_o : out std_logic;
    gtp1_scl_i : in  std_logic := '1';
    gtp1_sda_o : out std_logic;
    gtp1_sda_i : in  std_logic := '1';
    gtp1_det_i : in  std_logic := '1';
    btn1_i     : in  std_logic := '1';
    btn2_i     : in  std_logic := '1';

    -----------------------------------------
    --UART
    -----------------------------------------
    uart_rxd_i : in  std_logic := '0';
    uart_txd_o : out std_logic;

    -----------------------------------------
    -- Pause Frame Control
    -----------------------------------------
    ep0_fc_tx_pause_req_i   : in  std_logic                     := '0';
    ep0_fc_tx_pause_delay_i : in  std_logic_vector(15 downto 0) := x"0000";
    ep0_fc_tx_pause_ready_o : out std_logic;

    ep1_fc_tx_pause_req_i   : in  std_logic                     := '0';
    ep1_fc_tx_pause_delay_i : in  std_logic_vector(15 downto 0) := x"0000";
    ep1_fc_tx_pause_ready_o : out std_logic;

    -----------------------------------------
    -- 1-wire
    -----------------------------------------
    owr_pwren_o : out std_logic_vector(1 downto 0);
    owr_en_o    : out std_logic_vector(1 downto 0);
    owr_i       : in  std_logic_vector(1 downto 0) := (others => '1');

    -----------------------------------------
    -- External WB interface Master
    -----------------------------------------
    wb_adr_i   : in  std_logic_vector(c_wishbone_address_width-1 downto 0)   := (others => '0');
    wb_dat_i   : in  std_logic_vector(c_wishbone_data_width-1 downto 0)      := (others => '0');
    wb_dat_o   : out std_logic_vector(c_wishbone_data_width-1 downto 0);
    wb_sel_i   : in  std_logic_vector(c_wishbone_address_width/8-1 downto 0) := (others => '0');
    wb_we_i    : in  std_logic                                               := '0';
    wb_cyc_i   : in  std_logic                                               := '0';
    wb_stb_i   : in  std_logic                                               := '0';
    wb_ack_o   : out std_logic;
    wb_err_o   : out std_logic;
    wb_rty_o   : out std_logic;
    wb_stall_o : out std_logic;

    -----------------------------------------
    -- External Fabric I/F
    -----------------------------------------
    -- Etherbone + Connections between both endpoints.
    ext_wrf_src_o : out t_wrf_source_out_array(g_num_phys-1 downto 0);
    ext_wrf_src_i : in  t_wrf_source_in_array(g_num_phys-1 downto 0);
    ext_wrf_snk_o : out t_wrf_sink_out_array(g_num_phys-1 downto 0);
    ext_wrf_snk_i : in  t_wrf_sink_in_array(g_num_phys-1 downto 0);

    -----------------------------------------
    -- External TSU I/F
    -----------------------------------------
    timestamp_array_o     : out t_txtsu_timestamp_array(g_num_phys-1 downto 0);
    timestamp_array_ack_i : in  std_logic_vector(g_num_phys-1 downto 0) := (others => '0');

    -----------------------------------------
    --  External WB interface Slave. To Ext Crossbar
    -----------------------------------------
    ext_xb_master_i : in  t_wishbone_master_in;
    ext_xb_master_o : out t_wishbone_master_out;

    -----------------------------------------
    -- Timecode/Servo Control
    -----------------------------------------
    tm_link_up_o : out std_logic;

    -- DAC Control
    tm_dac_value_o : out std_logic_vector(23 downto 0);
    tm_dac_wr_o    : out std_logic_vector(g_aux_clks-1 downto 0);

    -- Aux clock lock enable
    tm_clk_aux_lock_en_i : in std_logic_vector(g_aux_clks-1 downto 0) := (others => '0');

    -- Aux clock locked flag
    tm_clk_aux_locked_o : out std_logic_vector(g_aux_clks-1 downto 0);

    -- Timecode output
    tm_time_valid_o : out std_logic;
    tm_tai_o        : out std_logic_vector(39 downto 0);
    tm_cycles_o     : out std_logic_vector(27 downto 0);

    -- 1PPS output
    pps_p_o   : out std_logic;
    pps_led_o : out std_logic;

    rst_aux_n_o : out std_logic;

    link_ok_o : out std_logic;

    -- Info about the EP incoming packets.
    ep_rtu_info_array_o : out t_ep_rtu_info_array(g_num_phys-1 downto 0);

    --Set Grand Master mode. It enables the PPS input.
    set_gm_o : out std_logic;

    -- External LM32 interruption
    ext_lm32_irq_i : in std_logic);
end wr_core_2p;

architecture struct of wr_core_2p is

  signal rst_wrc_n   : std_logic;
  signal rst_net_n   : std_logic;
  -----------------------------------------------------------------------------
  --PPS generator
  -----------------------------------------------------------------------------
  signal s_pps_csync : std_logic;
  signal pps_valid   : std_logic;

  signal ppsg_wb_in  : t_wishbone_slave_in;
  signal ppsg_wb_out : t_wishbone_slave_out;

  -----------------------------------------------------------------------------
  --Timing system
  -----------------------------------------------------------------------------
  signal spll_wb_in  : t_wishbone_slave_in;
  signal spll_wb_out : t_wishbone_slave_out;

  -----------------------------------------------------------------------------
  --Endpoint
  -----------------------------------------------------------------------------
  signal ep_led_link : std_logic_vector(g_num_phys-1 downto 0);

  --MAIN RAM SIZE
  constant c_mnic_memsize_log2 : integer := f_log2_size(g_main_dpram_size);

  --SECOND RAM SIZE
  constant c_mnic_memsize_gtp1_log2 : integer := f_log2_size(g_sec_dpram_size);
  -----------------------------------------------------------------------------
  --Mini-NIC
  -----------------------------------------------------------------------------

  --GTP0 Mini-NIC
  signal mnic_mem_gtp0_data_o : std_logic_vector(31 downto 0);
  signal mnic_mem_gtp0_addr_o : std_logic_vector(c_mnic_memsize_log2-1 downto 0);
  signal mnic_mem_gtp0_data_i : std_logic_vector(31 downto 0);
  signal mnic_mem_gtp0_wr_o   : std_logic;
  signal minic_txtsu_gtp0_ack : std_logic;

  --GTP1 Mini-NIC
  signal mnic_mem_gtp1_data_o : std_logic_vector(31 downto 0);
  signal mnic_mem_gtp1_addr_o : std_logic_vector(c_mnic_memsize_gtp1_log2-1 downto 0);
  signal mnic_mem_gtp1_data_i : std_logic_vector(31 downto 0);
  signal mnic_mem_gtp1_wr_o   : std_logic;
  signal minic_txtsu_gtp1_ack : std_logic;

  -----------------------------------------------------------------------------
  --Dual-port RAM
  -----------------------------------------------------------------------------
  --Interface between RAM<->Mini-NIC

  --GTP0
  signal dpram_gtp0_wbb_i : t_wishbone_slave_in;
  signal dpram_gtp0_wbb_o : t_wishbone_slave_out;

  --GTP1
  signal dpram_gtp1_wbb_i : t_wishbone_slave_in;
  signal dpram_gtp1_wbb_o : t_wishbone_slave_out;

  -----------------------------------------------------------------------------
  --WB Peripherials
  -----------------------------------------------------------------------------
  signal periph_slave_i : t_wishbone_slave_in_array(0 to 2);
  signal periph_slave_o : t_wishbone_slave_out_array(0 to 2);
  signal sysc_in_regs   : t_sysc_in_registers;
  signal sysc_out_regs  : t_sysc_out_registers;

  -----------------------------------------------------------------------------
  --WB Secondary Crossbar
  -----------------------------------------------------------------------------
  constant c_secbar_layout : t_sdb_record_array(8 downto 0) :=
    (0 => f_sdb_embed_device(c_xwr_mini_nic_sdb, x"00000000"),
     1 => f_sdb_embed_device(c_xwr_endpoint_sdb, x"00000100"),
     2 => f_sdb_embed_device(c_xwr_softpll_ng_sdb, x"00000200"),
     3 => f_sdb_embed_device(c_xwr_pps_gen_sdb, x"00000300"),
     4 => f_sdb_embed_device(c_wrc_periph0_sdb, x"00000400"),  -- Syscon                                                                --(4)
     5 => f_sdb_embed_device(c_wrc_periph1_sdb, x"00000500"),  -- UART                                                                  --(5)
     6 => f_sdb_embed_device(c_wrc_periph2_sdb, x"00000600"),  -- 1-Wire                                                                --(6)
     7 => f_sdb_embed_device(c_xwr_mini_nic_sdb, x"00000700"),  -- GTP1 MINI-NIC. Added.
     8 => f_sdb_embed_device(c_xwr_endpoint_sdb, x"00000800")  -- GTP1 ENDPOINT Added.
     );

  constant c_secbar_sdb_address : t_wishbone_address := x"00001000";

  constant c_secbar_bridge_sdb : t_sdb_bridge :=
    f_xwb_bridge_layout_sdb(true, c_secbar_layout, c_secbar_sdb_address);

  signal secbar_master_i : t_wishbone_master_in_array(8 downto 0);
  signal secbar_master_o : t_wishbone_master_out_array(8 downto 0);

  -----------------------------------------------------------------------------
  --WB intercon
  -----------------------------------------------------------------------------
  constant c_layout : t_sdb_record_array(3 downto 0) :=
    (0 => f_sdb_embed_device(f_xwb_dpram(g_main_dpram_size), x"00000000"),  --GTP0 RAM. g_dpram_size + 1/2
     1 => f_sdb_embed_device(f_xwb_dpram(g_sec_dpram_size), x"00020000"),  --GTP1 RAM. Added. g_dpram_size/2
     2 => f_sdb_embed_bridge(c_secbar_bridge_sdb, x"00030000"),  --Secundary crossbar
     3 => f_sdb_embed_bridge(g_extbar_bridge_sdb, x"00050000")  --External Crossbar
     );

  constant c_sdb_address : t_wishbone_address := x"00070000";

  -- (0) data. (1) Instructions. (2) GN4124. Masters.
  signal cbar_slave_i : t_wishbone_slave_in_array (2 downto 0);  --OBP Disabled
  signal cbar_slave_o : t_wishbone_slave_out_array(2 downto 0);  --OBP Disabled

  --Slaves
  signal cbar_master_i : t_wishbone_master_in_array(3 downto 0);  --GTP1 RAM Enabled + External Crossbar.
  signal cbar_master_o : t_wishbone_master_out_array(3 downto 0);  --GTP1 RAM Enabled + External Crossbar.

  -----------------------------------------------------------------------------
  --External WB interface Master
  -----------------------------------------------------------------------------
  signal ext_wb_in  : t_wishbone_slave_in;
  signal ext_wb_out : t_wishbone_slave_out;

  signal softpll_irq : std_logic;

  signal lm32_irq_slv : std_logic_vector(31 downto 0);

  --Duplicate me. x2 Endpoints & Mini-NIC
  signal ep_wb_gtp0_in  : t_wishbone_slave_in;
  signal ep_wb_gtp0_out : t_wishbone_slave_out;

  signal minic_gtp0_wb_in  : t_wishbone_slave_in;
  signal minic_gtp0_wb_out : t_wishbone_slave_out;

  signal ep_wb_gtp1_in  : t_wishbone_slave_in;
  signal ep_wb_gtp1_out : t_wishbone_slave_out;

  signal minic_gtp1_wb_in  : t_wishbone_slave_in;
  signal minic_gtp1_wb_out : t_wishbone_slave_out;

-------------------------------------------------------------------------------
-- Fabric/Endpoint interconnect for WR-LEN
-------------------------------------------------------------------------------
  signal endpoint_src_out : t_wrf_source_out_array(g_num_phys-1 downto 0);
  signal endpoint_src_in  : t_wrf_source_in_array(g_num_phys-1 downto 0);
  signal endpoint_snk_out : t_wrf_sink_out_array(g_num_phys-1 downto 0);
  signal endpoint_snk_in  : t_wrf_sink_in_array(g_num_phys-1 downto 0);

-------------------------------------------------------------------------------
-- Fabric between; ENDPOINT<->MINI_NIC:
-------------------------------------------------------------------------------
-- GTP0
  signal mux_src_gtp0_out : t_wrf_source_out_array(g_num_phys-1 downto 0);
  signal mux_src_gtp0_in  : t_wrf_source_in_array(g_num_phys-1 downto 0);
  signal mux_snk_gtp0_out : t_wrf_sink_out_array(g_num_phys-1 downto 0);
  signal mux_snk_gtp0_in  : t_wrf_sink_in_array(g_num_phys-1 downto 0);
  signal mux_gtp0_class   : t_wrf_mux_class(g_num_phys-1 downto 0);

-- GTP1
  signal mux_src_gtp1_out : t_wrf_source_out_array(g_num_phys-1 downto 0);
  signal mux_src_gtp1_in  : t_wrf_source_in_array(g_num_phys-1 downto 0);
  signal mux_snk_gtp1_out : t_wrf_sink_out_array(g_num_phys-1 downto 0);
  signal mux_snk_gtp1_in  : t_wrf_sink_in_array(g_num_phys-1 downto 0);
  signal mux_gtp1_class   : t_wrf_mux_class(g_num_phys-1 downto 0);

-------------------------------------------------------------------------------

  signal dummy : std_logic_vector(31 downto 0);

  signal spll_out_locked : std_logic_vector(g_aux_clks downto 0);

  signal dac_dpll_data    : std_logic_vector(15 downto 0);
  signal dac_dpll_sel     : std_logic_vector(3 downto 0);
  signal dac_dpll_load_p1 : std_logic;

  signal clk_fb     : std_logic_vector(g_aux_clks downto 0);
  signal out_enable : std_logic_vector(g_aux_clks downto 0);

-------------------------------------------------------------
  --Signals for WR-LEN.
  --Timestamp between Endpoint and Mini_NIC

  signal txtsu_timestamps_ack : std_logic_vector(g_num_phys-1 downto 0);
  signal txtsu_timestamps     : t_txtsu_timestamp_array(g_num_phys-1 downto 0);

-------------------------------------------------------------
  --OBP reset

  signal stall_wrpc       : std_logic := '0';
  signal stall_wrpc_reset : std_logic := '0';

-------------------------------------------------------------
  --SYNC stuff
  signal s_pps_inter       : std_logic;
  signal s_pps_inter_pre   : std_logic;
  signal s_pps_valid_inter : std_logic;
  signal s_sync_cnt        : std_logic_vector(3 downto 0) := (others => '0');
  signal s_sync_stop       : std_logic_vector(3 downto 0) := (others => '0');
  signal s_sync            : std_logic;

begin

  rst_aux_n_o <= rst_net_n;

  -----------------------------------------------------------------------------
  -- PPS generator
  -----------------------------------------------------------------------------
  PPS_GEN : xwr_pps_gen
    generic map(
      g_interface_mode       => PIPELINED,
      g_address_granularity  => BYTE,
      g_ref_clock_rate       => 62500000,
      g_ext_clock_rate       => 10000000,
      g_with_ext_clock_input => g_with_external_clock_input)
    port map(
      clk_ref_i => clk_ref_i,
      clk_sys_i => clk_sys_i,
      clk_ext_i => clk_ext_i,

      rst_n_i => rst_net_n,

      slave_i => ppsg_wb_in,
      slave_o => ppsg_wb_out,

      -- Single-pulse PPS output for synchronizing endpoint to
      pps_in_i    => pps_ext_i,
      pps_csync_o => s_pps_csync,
      pps_out_o   => s_pps_inter,
      pps_led_o   => pps_led_o,

      sync_pps_valid_o => s_pps_valid_inter,  -- SYNC stuff

      pps_valid_o     => pps_valid,
      tm_utc_o        => tm_tai_o,
      tm_cycles_o     => tm_cycles_o,
      tm_time_valid_o => tm_time_valid_o,
      set_gm_o        => set_gm_o
      );

  pps_p_o <= s_pps_inter;


  --SYNC process to reset the AD9516 counters

  p_PLL_SYNC : process(clk_ref_i, rst_n_i) is
  begin
    if (rst_n_i = '0') then
      s_sync      <= '1';
      s_sync_cnt  <= (others => '0');
      s_sync_stop <= (others => '0');

    elsif (clk_ref_i'event and clk_ref_i = '1') then
      s_pps_inter_pre <= s_pps_inter;

      if(s_pps_valid_inter = '1') then
        if (s_pps_inter_pre = '0' and s_pps_inter = '1') then
          if (s_sync_cnt < "0111") then
            s_sync_cnt <= s_sync_cnt + '1';
          elsif (s_sync_cnt = "0111") then
            s_sync_cnt  <= "1111";
            s_sync      <= '0';
            s_sync_stop <= "1111";
          end if;
        elsif(s_sync_stop > "0000") then
          s_sync_stop <= s_sync_stop - '1';
        elsif (s_sync_stop = "0000") then
          s_sync <= '1';
        end if;
      else
        s_sync_cnt <= (others => '0');
        s_sync     <= '1';
      end if;
    end if;
  end process p_PLL_SYNC;

  pll_sync_n_o <= s_sync;

  -----------------------------------------------------------------------------
  -- Software PLL
  -----------------------------------------------------------------------------
  -- External 10 MHz input divider parameters.
  --    constant c_softpll_ext_div_ref     : integer := 8;      --Same value for the switch
  --    constant c_softpll_ext_div_fb      : integer := 50;     --25 for the switch and WR-LEN
  --    constant c_softpll_ext_log2_gating : integer := 13; --Same value for the switch


  U_SOFTPLL : xwr_softpll_ng
    generic map(
      g_with_ext_clock_input => g_with_external_clock_input,
      g_reverse_dmtds        => false,
      g_divide_input_by_2    => false,           --default true. eml.
      g_with_debug_fifo      => g_softpll_enable_debugger,
      g_tag_bits             => 22,
      g_interface_mode       => PIPELINED,
      g_address_granularity  => BYTE,
      g_num_ref_inputs       => 2,               -- 0->GTP0, 1->GTP1.
      g_num_outputs          => 1 + g_aux_clks,  -- 1 + 1 in the default wrc.
      g_ref_clock_rate       => 62500000,
      g_ext_clock_rate       => 10000000)
    port map(
      clk_sys_i => clk_sys_i,                    --1
      rst_n_i   => rst_net_n,                    --1

      -- Reference inputs (i.e. the RX clocks recovered by the PHYs)
      --  clk_ref_i  length is g_num_ref_inputs
      clk_ref_i(0) => phys_i(0).rx_clk,  --GTP0
      clk_ref_i(1) => phys_i(1).rx_clk,  --GTP1

      -- Feedback clocks (i.e. the outputs of the main or aux oscillator)
      clk_fb_i   => clk_fb,             --Before:    clk_fb, --g_num_outputs
      -- DMTD Offset clock
      clk_dmtd_i => clk_dmtd_i,

      clk_ext_i            => clk_ext_i,
      clk_ext_mul_i        => clk_ext_mul_i,
      clk_ext_mul_locked_i => clk_ext_mul_locked_i,

      pps_csync_p1_i => s_pps_csync,
      pps_ext_a_i    => pps_ext_i,

      -- DMTD oscillator drive
      dac_dmtd_data_o => dac_hpll_data_o,     --(15 downto 0);
      dac_dmtd_load_o => dac_hpll_load_p1_o,  --1

      -- Output channel DAC value
      dac_out_data_o => dac_dpll_data,     --(15 downto 0);
      -- Output channel select (0 = channel 0, etc. )
      dac_out_sel_o  => dac_dpll_sel,
      dac_out_load_o => dac_dpll_load_p1,  --1

      out_enable_i => out_enable,  --Before:    out_enable,     --g_num_outputs
      out_locked_o => spll_out_locked,  --Before: spll_out_locked,      --g_num_outputs

      slave_i => spll_wb_in,
      slave_o => spll_wb_out,

      debug_o => open  -- The dio outputs were here. There is no need to DIO anymore. We are in two ports.
      );

  clk_fb(0)                   <= clk_ref_i;
  clk_fb(g_aux_clks downto 1) <= clk_aux_i;

  out_enable(0)                   <= '1';
  out_enable(g_aux_clks downto 1) <= tm_clk_aux_lock_en_i;

  dac_dpll_data_o    <= dac_dpll_data;
  dac_dpll_load_p1_o <= '1' when (dac_dpll_load_p1 = '1' and dac_dpll_sel = x"0") else '0';

  tm_dac_value_o <= x"00" & dac_dpll_data;

  p_decode_dac_writes : process(dac_dpll_load_p1, dac_dpll_sel)
  begin
    for i in 0 to g_aux_clks-1 loop
      if dac_dpll_sel = std_logic_vector(to_unsigned(i+1, 4)) then
        tm_dac_wr_o(i) <= dac_dpll_load_p1;
      else
        tm_dac_wr_o(i) <= '0';
      end if;
    end loop;  -- i
  end process;

  locked_spll : if g_aux_clks > 0 generate
    tm_clk_aux_locked_o <= spll_out_locked(g_aux_clks downto 1);
  end generate;

  softpll_irq <= spll_wb_out.int;

-----------------------------------------------------------------------------
-- Endpoint x 2 (GTP0 + GTP1)
-----------------------------------------------------------------------------
-- GTP0
  U_Endpoint_GTP0 : xwr_endpoint
    generic map (
      g_interface_mode        => PIPELINED,
      g_address_granularity   => BYTE,
      g_simulation            => false,
      g_tx_runt_padding       => g_tx_runt_padding,
      g_pcs_16bit             => g_pcs_16bit,
      g_rx_buffer_size        => g_rx_buffer_size,
      g_with_rx_buffer        => true,
      g_with_flow_control     => g_with_flow_control,
      g_with_timestamper      => true,
      g_with_dpi_classifier   => true,
      g_with_vlans            => false,
      g_with_rtu              => g_ep_with_rtu,
      g_with_leds             => true,
      g_with_packet_injection => false,
      g_use_new_rxcrc         => true,
      g_use_new_txcrc         => false)
    port map (
      clk_ref_i      => clk_ref_i,
      clk_sys_i      => clk_sys_i,
      clk_dmtd_i     => clk_dmtd_i,
      rst_n_i        => rst_net_n,
      pps_csync_p1_i => s_pps_csync,
      pps_valid_i    => pps_valid,

      phy_rst_o         => phys_o(0).rst,
      phy_ref_clk_i     => phy_ref_clk_i,
      phy_tx_data_o     => phys_o(0).tx_data,
      phy_tx_k_o        => phys_o(0).tx_k,
      phy_loopen_vec_o  => phys_o(0).loopen,
      phy_tx_prbs_sel_o => phys_o(0).tx_prbs_sel,

      phy_tx_disparity_i => phys_i(0).tx_disparity,
      phy_tx_enc_err_i   => phys_i(0).tx_enc_err,
      phy_rx_data_i      => phys_i(0).rx_data,
      phy_rx_clk_i       => phys_i(0).rx_clk,
      phy_rx_k_i         => phys_i(0).rx_k,
      phy_rx_enc_err_i   => phys_i(0).rx_enc_err,
      phy_rx_bitslide_i  => phys_i(0).rx_bitslide,
      phy_rdy_i          => phys_i(0).rdy,

      phy_sfp_tx_disable_o => phys_o(0).tx_disable,
      phy_sfp_tx_fault_i   => phys_i(0).tx_fault,
      phy_sfp_los_i        => phys_i(0).los,

      src_o => endpoint_src_out(0),     --ep_src_out
      src_i => endpoint_src_in(0),      --ep_src_in
      snk_o => endpoint_snk_out(0),     --ep_snk_out
      snk_i => endpoint_snk_in(0),      --ep_snk_in

      -- Info about the incoming packets.
      rtu_rq_strobe_p1_o => ep_rtu_info_array_o(0).valid,
      rtu_rq_smac_o      => ep_rtu_info_array_o(0).smac,
      rtu_rq_dmac_o      => ep_rtu_info_array_o(0).dmac,
      rtu_rq_vid_o       => ep_rtu_info_array_o(0).vid,
      rtu_rq_has_vid_o   => ep_rtu_info_array_o(0).has_vid,
      rtu_rq_prio_o      => ep_rtu_info_array_o(0).prio,
      rtu_rq_has_prio_o  => ep_rtu_info_array_o(0).has_prio,

      txtsu_port_id_o      => txtsu_timestamps(0).port_id,
      txtsu_frame_id_o     => txtsu_timestamps(0).frame_id,
      txtsu_ts_value_o     => txtsu_timestamps(0).tsval,
      txtsu_ts_incorrect_o => txtsu_timestamps(0).incorrect,
      txtsu_stb_o          => txtsu_timestamps(0).stb,
      txtsu_ack_i          => txtsu_timestamps_ack(0),

      wb_i => ep_wb_gtp0_in,
      wb_o => ep_wb_gtp0_out,

      rmon_events_o       => open,
      fc_tx_pause_req_i   => ep0_fc_tx_pause_req_i,
      fc_tx_pause_delay_i => ep0_fc_tx_pause_delay_i,
      fc_tx_pause_ready_o => ep0_fc_tx_pause_ready_o,

      led_link_o => ep_led_link(0),     --LEDs only for the GTP0 port
      led_act_o  => led_act_o(0));      --LEDs only for the GTP1 port

--------------------------------------------------------------------------------

  --GTP1
  U_Endpoint_GTP1 : xwr_endpoint
    generic map (
      g_interface_mode        => PIPELINED,
      g_address_granularity   => BYTE,
      g_simulation            => false,
      g_tx_runt_padding       => g_tx_runt_padding,
      g_pcs_16bit             => g_pcs_16bit,
      g_rx_buffer_size        => g_rx_buffer_size,
      g_with_rx_buffer        => true,
      g_with_flow_control     => g_with_flow_control,
      g_with_timestamper      => true,
      g_with_dpi_classifier   => true,
      g_with_vlans            => false,
      g_with_rtu              => g_ep_with_rtu,
      g_with_leds             => true,
      g_with_packet_injection => false,
      g_use_new_rxcrc         => true,
      g_use_new_txcrc         => false)
    port map (
      clk_ref_i      => clk_ref_i,
      clk_sys_i      => clk_sys_i,
      clk_dmtd_i     => clk_dmtd_i,
      rst_n_i        => rst_net_n,
      pps_csync_p1_i => s_pps_csync,
      pps_valid_i    => pps_valid,

      phy_rst_o         => phys_o(1).rst,
      phy_ref_clk_i     => phy_ref_clk_i,
      phy_tx_data_o     => phys_o(1).tx_data,
      phy_tx_k_o        => phys_o(1).tx_k,
      phy_loopen_vec_o  => phys_o(1).loopen,
      phy_tx_prbs_sel_o => phys_o(1).tx_prbs_sel,

      phy_tx_disparity_i => phys_i(1).tx_disparity,
      phy_tx_enc_err_i   => phys_i(1).tx_enc_err,
      phy_rx_data_i      => phys_i(1).rx_data,
      phy_rx_clk_i       => phys_i(1).rx_clk,
      phy_rx_k_i         => phys_i(1).rx_k,
      phy_rx_enc_err_i   => phys_i(1).rx_enc_err,
      phy_rx_bitslide_i  => phys_i(1).rx_bitslide,
      phy_rdy_i          => phys_i(1).rdy,

      phy_sfp_tx_disable_o => phys_o(1).tx_disable,
      phy_sfp_tx_fault_i   => phys_i(1).tx_fault,
      phy_sfp_los_i        => phys_i(1).los,

      txtsu_port_id_o      => txtsu_timestamps(1).port_id,
      txtsu_frame_id_o     => txtsu_timestamps(1).frame_id,
      txtsu_ts_value_o     => txtsu_timestamps(1).tsval,
      txtsu_ts_incorrect_o => txtsu_timestamps(1).incorrect,
      txtsu_stb_o          => txtsu_timestamps(1).stb,
      txtsu_ack_i          => txtsu_timestamps_ack(1),

      -- Info about the incoming packets.
      rtu_rq_strobe_p1_o => ep_rtu_info_array_o(1).valid,
      rtu_rq_smac_o      => ep_rtu_info_array_o(1).smac,
      rtu_rq_dmac_o      => ep_rtu_info_array_o(1).dmac,
      rtu_rq_vid_o       => ep_rtu_info_array_o(1).vid,
      rtu_rq_has_vid_o   => ep_rtu_info_array_o(1).has_vid,
      rtu_rq_prio_o      => ep_rtu_info_array_o(1).prio,
      rtu_rq_has_prio_o  => ep_rtu_info_array_o(1).has_prio,

      src_o => endpoint_src_out(1),     --ep_src_out
      src_i => endpoint_src_in(1),      --ep_src_in
      snk_o => endpoint_snk_out(1),     --ep_snk_out
      snk_i => endpoint_snk_in(1),      --ep_snk_in

      wb_i => ep_wb_gtp1_in,
      wb_o => ep_wb_gtp1_out,

      rmon_events_o       => open,
      fc_tx_pause_req_i   => ep1_fc_tx_pause_req_i,
      fc_tx_pause_delay_i => ep1_fc_tx_pause_delay_i,
      fc_tx_pause_ready_o => ep1_fc_tx_pause_ready_o,

      led_link_o => ep_led_link(1),     --LEDs only for the GTP0 port
      led_act_o  => led_act_o(1));

  txtsu_timestamps_ack(1) <= minic_txtsu_gtp1_ack or timestamp_array_ack_i(1);
  txtsu_timestamps_ack(0) <= minic_txtsu_gtp0_ack or timestamp_array_ack_i(0);

  led_link_o <= ep_led_link;            --LEDs

  -----------------------------------------------------------------------------
  -- WBP MUX GTP0
  -----------------------------------------------------------------------------

  U_WBP_Mux_GTP0 : xwrf_mux
    generic map(
      g_muxed_ports => 2)
    port map (
      clk_sys_i   => clk_sys_i,
      rst_n_i     => rst_n_i,
      ep_src_o    => endpoint_snk_in(0),
      ep_src_i    => endpoint_snk_out(0),
      ep_snk_o    => endpoint_src_in(0),
      ep_snk_i    => endpoint_src_out(0),
      mux_src_o   => mux_src_gtp0_out,
      mux_src_i   => mux_src_gtp0_in,
      mux_snk_o   => mux_snk_gtp0_out,
      mux_snk_i   => mux_snk_gtp0_in,
      mux_class_i => mux_gtp0_class);

  mux_gtp0_class(0) <= x"03";  -- To LM32: Class 0 & 1. No broadcast packets.
  mux_gtp0_class(1) <= x"FC";  -- To the rest of architecture: 2, 3, 4, 5 & 6. Broadcast (ARP): 7.

  -- WBP MUX GTP1

  U_WBP_Mux_GTP1 : xwrf_mux
    generic map(
      g_muxed_ports => 2)
    port map (
      clk_sys_i   => clk_sys_i,
      rst_n_i     => rst_n_i,
      ep_src_o    => endpoint_snk_in(1),
      ep_src_i    => endpoint_snk_out(1),
      ep_snk_o    => endpoint_src_in(1),
      ep_snk_i    => endpoint_src_out(1),
      mux_src_o   => mux_src_gtp1_out,
      mux_src_i   => mux_src_gtp1_in,
      mux_snk_o   => mux_snk_gtp1_out,
      mux_snk_i   => mux_snk_gtp1_in,
      mux_class_i => mux_gtp1_class);

  mux_gtp1_class(0) <= x"03";  -- To LM32: Class 0 & 1. No broadcast packets.
  mux_gtp1_class(1) <= x"FC";  -- To the rest of architecture: 2, 3, 4, 5 & 6. Broadcast (ARP): 7.

  ---------------------------------------------------------------------
  -- Interconnections between the XWRF_MUX and the external fabrics --
  ---------------------------------------------------------------------
  ---------------------------------------------------------------
  -- snk_gtp0 <-----> ext_snk(0)
  ext_wrf_snk_o(0)   <= mux_snk_gtp0_out(1);
  mux_snk_gtp0_in(1) <= ext_wrf_snk_i(0);
  -- src_gtp0 <-----> ext_src(0)
  ext_wrf_src_o(0)   <= mux_src_gtp0_out(1);
  mux_src_gtp0_in(1) <= ext_wrf_src_i(0);
  ---------------------------------------------------------------
  -- snk_gtp1 <-----> ext_snk(1)
  ext_wrf_snk_o(1)   <= mux_snk_gtp1_out(1);
  mux_snk_gtp1_in(1) <= ext_wrf_snk_i(1);
  -- src_gtp0 <-----> ext_src(0)
  ext_wrf_src_o(1)   <= mux_src_gtp1_out(1);
  mux_src_gtp1_in(1) <= ext_wrf_src_i(1);
  ---------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- Mini-NIC GTP0
  -----------------------------------------------------------------------------
  MINI_NIC_GTP0 : xwr_mini_nic
    generic map (
      g_interface_mode       => PIPELINED,
      g_address_granularity  => BYTE,
      g_memsize_log2         => f_log2_size(g_main_dpram_size),
      g_buffer_little_endian => false)
    port map (
      clk_sys_i => clk_sys_i,
      rst_n_i   => rst_net_n,

      mem_data_o => mnic_mem_gtp0_data_o,
      mem_addr_o => mnic_mem_gtp0_addr_o,
      mem_data_i => mnic_mem_gtp0_data_i,
      mem_wr_o   => mnic_mem_gtp0_wr_o,

      src_o => mux_snk_gtp0_in(0),
      src_i => mux_snk_gtp0_out(0),
      snk_o => mux_src_gtp0_in(0),
      snk_i => mux_src_gtp0_out(0),

      txtsu_port_id_i     => txtsu_timestamps(0).port_id,
      txtsu_frame_id_i    => txtsu_timestamps(0).frame_id,
      txtsu_tsval_i       => txtsu_timestamps(0).tsval,
      txtsu_tsincorrect_i => txtsu_timestamps(0).incorrect,
      txtsu_stb_i         => txtsu_timestamps(0).stb,
      txtsu_ack_o         => minic_txtsu_gtp0_ack,

      wb_i => minic_gtp0_wb_in,
      wb_o => minic_gtp0_wb_out
      );

  --Mini-NIC GTP1

  MINI_NIC_GTP1 : xwr_mini_nic
    generic map (
      g_interface_mode       => PIPELINED,
      g_address_granularity  => BYTE,
      g_memsize_log2         => f_log2_size(g_sec_dpram_size),
      g_buffer_little_endian => false)
    port map (
      clk_sys_i => clk_sys_i,
      rst_n_i   => rst_net_n,

      mem_data_o => mnic_mem_gtp1_data_o,
      mem_addr_o => mnic_mem_gtp1_addr_o,
      mem_data_i => mnic_mem_gtp1_data_i,
      mem_wr_o   => mnic_mem_gtp1_wr_o,

      src_o => mux_snk_gtp1_in(0),
      src_i => mux_snk_gtp1_out(0),
      snk_o => mux_src_gtp1_in(0),
      snk_i => mux_src_gtp1_out(0),

      txtsu_port_id_i     => txtsu_timestamps(1).port_id,
      txtsu_frame_id_i    => txtsu_timestamps(1).frame_id,
      txtsu_tsval_i       => txtsu_timestamps(1).tsval,
      txtsu_tsincorrect_i => txtsu_timestamps(1).incorrect,
      txtsu_stb_i         => txtsu_timestamps(1).stb,
      txtsu_ack_o         => minic_txtsu_gtp1_ack,

      wb_i => minic_gtp1_wb_in,
      wb_o => minic_gtp1_wb_out
      );

  lm32_irq_slv(31 downto 2) <= (others => '0');
  lm32_irq_slv(0)           <= softpll_irq;  -- according to the doc, it's active low.
  lm32_irq_slv(1)           <= ext_lm32_irq_i;


  -----------------------------------------------------------------------------
  -- Dual-port RAM
  -----------------------------------------------------------------------------

  --GTP0 RAM
  --This memory is used; to store the LM32 firmware and to share memory between
  --the LM32 and the Mini-NIC-GTP0
  DPRAM_GTP0 : xwb_dpram
    generic map(
      g_size                  => g_main_dpram_size,
      g_lm32_ram              => true,
      g_slave1_interface_mode => PIPELINED,
      g_slave2_interface_mode => PIPELINED,
      g_slave1_granularity    => BYTE,
      g_slave2_granularity    => WORD)
    port map(
      clk_sys_i => clk_sys_i,
      rst_n_i   => rst_n_i,

      slave1_i => cbar_master_o(0),
      slave1_o => cbar_master_i(0),

      slave2_i => dpram_gtp0_wbb_i,
      slave2_o => dpram_gtp0_wbb_o
      );

  dpram_gtp0_wbb_i.cyc                                 <= '1';
  dpram_gtp0_wbb_i.stb                                 <= '1';
  dpram_gtp0_wbb_i.adr(c_mnic_memsize_log2-1 downto 0) <= mnic_mem_gtp0_addr_o;
  dpram_gtp0_wbb_i.sel                                 <= "1111";
  dpram_gtp0_wbb_i.we                                  <= mnic_mem_gtp0_wr_o;
  dpram_gtp0_wbb_i.dat                                 <= mnic_mem_gtp0_data_o;
  mnic_mem_gtp0_data_i                                 <= dpram_gtp0_wbb_o.dat;


  --GTP1 RAM
  --Shared memory between the LM32 and the Mini-NIC-GTP1
  DPRAM_GTP1 : xwb_dpram
    generic map(
      g_size                  => g_sec_dpram_size,
      g_lm32_ram              => false,
      g_slave1_interface_mode => PIPELINED,
      g_slave2_interface_mode => PIPELINED,
      g_slave1_granularity    => BYTE,
      g_slave2_granularity    => WORD)
    port map(
      clk_sys_i => clk_sys_i,
      rst_n_i   => rst_n_i,

      slave1_i => cbar_master_o(1),
      slave1_o => cbar_master_i(1),

      slave2_i => dpram_gtp1_wbb_i,
      slave2_o => dpram_gtp1_wbb_o
      );

  dpram_gtp1_wbb_i.cyc                                      <= '1';
  dpram_gtp1_wbb_i.stb                                      <= '1';
  dpram_gtp1_wbb_i.adr(c_mnic_memsize_gtp1_log2-1 downto 0) <= mnic_mem_gtp1_addr_o;
  dpram_gtp1_wbb_i.sel                                      <= "1111";
  dpram_gtp1_wbb_i.we                                       <= mnic_mem_gtp1_wr_o;
  dpram_gtp1_wbb_i.dat                                      <= mnic_mem_gtp1_data_o;
  mnic_mem_gtp1_data_i                                      <= dpram_gtp1_wbb_o.dat;

  -----------------------------------------------------------------------------
  -- LM32
  -----------------------------------------------------------------------------
  LM32_CORE : xwb_lm32
    generic map(g_profile => "medium_icache")  --without debugging. eml.
    port map(
      clk_sys_i => clk_sys_i,
      rst_n_i   => rst_wrc_n,           -- OBP disabled stall_wrpc_reset,
      irq_i     => lm32_irq_slv,

      dwb_o => cbar_slave_i(0),
      dwb_i => cbar_slave_o(0),
      iwb_o => cbar_slave_i(1),
      iwb_i => cbar_slave_o(1)
      );

  -----------------------------------------------------------------------------
  -- WB Peripherials
  -----------------------------------------------------------------------------
  PERIPH : wrc_periph
    generic map(
      g_phys_uart    => g_phys_uart,
      g_virtual_uart => g_virtual_uart,
      g_mem_words    => g_main_dpram_size + g_sec_dpram_size)
    port map(
      clk_sys_i   => clk_sys_i,
      rst_n_i     => rst_n_i,
      rst_net_n_o => rst_net_n,
      rst_wrc_n_o => rst_wrc_n,

      led_red_o   => open,              --led_red_o,
      led_green_o => open,              --led_green_o,
      scl_o       => scl_o,
      scl_i       => scl_i,
      sda_o       => sda_o,
      sda_i       => sda_i,

      --I2C for SFP 1
      sfp0_scl_o => gtp0_scl_o,
      sfp0_scl_i => gtp0_scl_i,
      sfp0_sda_o => gtp0_sda_o,
      sfp0_sda_i => gtp0_sda_i,
      sfp0_det_i => gtp0_det_i,

      --I2C for SFP 2
      sfp1_scl_o => gtp1_scl_o,
      sfp1_scl_i => gtp1_scl_i,
      sfp1_sda_o => gtp1_sda_o,
      sfp1_sda_i => gtp1_sda_i,
      sfp1_det_i => gtp1_det_i,

      memsize_i => "0000",
      btn1_i    => btn1_i,
      btn2_i    => btn2_i,

      slave_i => periph_slave_i,
      slave_o => periph_slave_o,

      uart_rxd_i => uart_rxd_i,
      uart_txd_o => uart_txd_o,

      owr_pwren_o => owr_pwren_o,
      owr_en_o    => owr_en_o,
      owr_i       => owr_i
      );

  U_Adapter : wb_slave_adapter
    generic map(
      g_master_use_struct  => true,
      g_master_mode        => PIPELINED,
      g_master_granularity => BYTE,
      g_slave_use_struct   => false,
      g_slave_mode         => g_interface_mode,
      g_slave_granularity  => g_address_granularity)
    port map (
      clk_sys_i  => clk_sys_i,
      rst_n_i    => rst_n_i,
      master_i   => ext_wb_out,
      master_o   => ext_wb_in,
      sl_adr_i   => wb_adr_i,
      sl_dat_i   => wb_dat_i,
      sl_sel_i   => wb_sel_i,
      sl_cyc_i   => wb_cyc_i,
      sl_stb_i   => wb_stb_i,
      sl_we_i    => wb_we_i,
      sl_dat_o   => wb_dat_o,
      sl_ack_o   => wb_ack_o,
      sl_err_o   => wb_err_o,
      sl_rty_o   => wb_rty_o,
      sl_stall_o => wb_stall_o);

  -- WB intercon
  -----------------------------------------------------------------------------
  WB_CON : xwb_sdb_crossbar
    generic map(
      g_num_masters => 3,
      g_num_slaves  => 4,               --GTP1 RAM Enabled. + Ext bridge.
      g_registered  => true,
      g_wraparound  => true,
      g_layout      => c_layout,
      g_sdb_addr    => c_sdb_address)
    port map(
      clk_sys_i => clk_sys_i,
      rst_n_i   => rst_n_i,
      -- Master connections (INTERCON is a slave)
      slave_i   => cbar_slave_i,
      slave_o   => cbar_slave_o,
      -- Slave connections (INTERCON is a master)
      master_i  => cbar_master_i,       --t_wishbone_slave_out
      master_o  => cbar_master_o);

  -- These connections come from the External Master (Etherbone).
  cbar_slave_i(2) <= ext_wb_in;
  ext_wb_out      <= cbar_slave_o(2);

  -- These connections go to the external crossbar.
  cbar_master_i(3) <= ext_xb_master_i;
  ext_xb_master_o  <= cbar_master_o(3);

  -----------------------------------------------------------------------------
  -- WB Secondary Crossbar
  -----------------------------------------------------------------------------
  WB_SECONDARY_CON : xwb_sdb_crossbar
    generic map(
      g_num_masters => 1,
      g_num_slaves  => 9,
      g_registered  => true,
      g_wraparound  => true,
      g_layout      => c_secbar_layout,
      g_sdb_addr    => c_secbar_sdb_address)
    port map(
      clk_sys_i  => clk_sys_i,
      rst_n_i    => rst_n_i,
      -- Master connections (INTERCON is a slave)
      slave_i(0) => cbar_master_o(2),
      slave_o(0) => cbar_master_i(2),
      -- Slave connections (INTERCON is a master)
      master_i   => secbar_master_i,
      master_o   => secbar_master_o);

  -----------------------------------------------------
  -- GTP0 MINI-NIC & ENDPOINT
  secbar_master_i(0) <= minic_gtp0_wb_out;
  minic_gtp0_wb_in   <= secbar_master_o(0);
  secbar_master_i(1) <= ep_wb_gtp0_out;
  ep_wb_gtp0_in      <= secbar_master_o(1);
  ------------------------------------------------------

  secbar_master_i(2) <= spll_wb_out;
  spll_wb_in         <= secbar_master_o(2);
  secbar_master_i(3) <= ppsg_wb_out;
  ppsg_wb_in         <= secbar_master_o(3);

  --peripherials
  secbar_master_i(4) <= periph_slave_o(0);
  secbar_master_i(5) <= periph_slave_o(1);
  secbar_master_i(6) <= periph_slave_o(2);
  periph_slave_i(0)  <= secbar_master_o(4);
  periph_slave_i(1)  <= secbar_master_o(5);
  periph_slave_i(2)  <= secbar_master_o(6);

  --GTP1 MINI-NIC & ENDPOINT
  secbar_master_i(7) <= minic_gtp1_wb_out;
  minic_gtp1_wb_in   <= secbar_master_o(7);
  secbar_master_i(8) <= ep_wb_gtp1_out;
  ep_wb_gtp1_in      <= secbar_master_o(8);

  -- Time code output.
  tm_link_up_o <= ep_led_link(0) or ep_led_link(1);

  -----------------------------------------------------------------------------
  -- External Tx Timestamping I/F
  -----------------------------------------------------------------------------

  GEN_TIMESTAMP_IF : for I in 0 to g_num_phys-1 generate
    timestamp_array_o(I).port_id   <= txtsu_timestamps(I).port_id;
    timestamp_array_o(I).frame_id  <= txtsu_timestamps(I).frame_id;
    timestamp_array_o(I).tsval     <= txtsu_timestamps(I).tsval;
    timestamp_array_o(I).incorrect <= txtsu_timestamps(I).incorrect;
    timestamp_array_o(I).stb       <= '1' when (txtsu_timestamps(I).stb = '1' and (txtsu_timestamps(I).frame_id /= x"0000")) else '0';
  end generate GEN_TIMESTAMP_IF;

end struct;
