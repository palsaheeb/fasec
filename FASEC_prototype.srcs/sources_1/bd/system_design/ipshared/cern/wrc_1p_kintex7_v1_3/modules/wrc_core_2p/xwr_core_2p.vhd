-------------------------------------------------------------------------------
-- Title      : WhiteRabbit PTP Core
-- Project    : WhiteRabbit
-------------------------------------------------------------------------------
-- File       : wr_core.vhd
-- Author     : Grzegorz Daniluk
-- Company    : Elproma
-- Created    : 2011-02-02
-- Last update: 2017-03-13
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
-- wishbone interface (using wb crossbar and bus fanout). Separate pipelined
-- wishbone bus is used for passing packets between Endpoint, Mini-NIC
-- and External MAC interface.
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
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.wrcore_2p_pkg.all;
use work.genram_pkg.all;
use work.wishbone_pkg.all;
use work.endpoint_pkg.all;
use work.wr_fabric_pkg.all;
use work.sysc_wbgen2_pkg.all;
use work.softpll_pkg.all;
use work.gen7s_cores_pkg.all;

entity xwr_core_2p is
  generic(
    --if set to 1, then blocks in PCS use smaller calibration counter to speed
    --up simulation
    g_simulation                : integer                        := 0;
    g_with_external_clock_input : boolean                        := false;
    --
    g_phys_uart                 : boolean                        := true;
    g_virtual_uart              : boolean                        := false;
    g_aux_clks                  : integer                        := 1;
    g_ep_rxbuf_size             : integer                        := 1024;
    g_main_dpram_initf          : string                         := "";
    g_main_dpram_size           : integer                        := 90112/4;  --in 32-bit words
    g_sec_dpram_size            : integer                        := 90112/4;  --in 32-bit words
    g_interface_mode            : t_wishbone_interface_mode      := PIPELINED;
    g_address_granularity       : t_wishbone_address_granularity := WORD;
    g_softpll_channels_config   : t_softpll_channel_config_array := c_softpll_default_channel_config;
    g_softpll_enable_debugger   : boolean                        := false;
    g_num_phys									: integer												 :=	2;
    g_ep_with_rtu               : boolean                        := false;

    g_pcs_16bit                 : boolean                        := true;
    g_tx_runt_padding           : boolean                        := true;
    g_with_flow_control         : boolean                        := false;

    g_extbar_bridge_sdb         : t_sdb_bridge                   := c_empty_bridge_sdb);
  port(
    ---------------------------------------------------------------------------
    -- Clocks/resets
    ---------------------------------------------------------------------------

    -- system reference clock (any frequency <= f(clk_ref_i))
    clk_sys_i : in std_logic;

    --Reset for the ethernet chipset.
    phy_rst_n_o  : out std_logic;

    -- DDMTD offset clock (125.x MHz)
    clk_dmtd_i : in std_logic;

    -- Timing reference (125 MHz)
    clk_ref_i : in std_logic;

    -- Aux clock (i.e. the FMC clock), which can be disciplined by the WR Core
    clk_aux_i : in std_logic_vector(g_aux_clks-1 downto 0) := (others => '0');

    -- External 10 MHz reference (cesium, GPSDO, etc.), used in Grandmaster mode and its multiplied freq.
    clk_ext_i             : in std_logic := '0';
    clk_ext_mul_i         : in std_logic := '0';
    clk_ext_mul_locked_i  : in std_logic := '0';

    -- External PPS input (cesium, GPSDO, etc.), used in Grandmaster mode
    pps_ext_i : in std_logic := '0';

    rst_n_i : in std_logic := '1';

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
    gtp0_scl_o  : out std_logic;
    gtp0_scl_i  : in  std_logic := '1';
    gtp0_sda_o  : out std_logic;
    gtp0_sda_i  : in  std_logic := '1';
    gtp0_det_i  : in  std_logic;
    gtp1_scl_o  : out std_logic;
    gtp1_scl_i  : in  std_logic := '1';
    gtp1_sda_o  : out std_logic;
    gtp1_sda_i  : in  std_logic := '1';
    gtp1_det_i  : in  std_logic;
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
    --External WB interface. To connect some master. EB?
    -----------------------------------------
    slave_i : in  t_wishbone_slave_in := cc_dummy_slave_in;
    slave_o : out t_wishbone_slave_out;

    -----------------------------------------
    -- External Fabric I/F
    -----------------------------------------
    wrf_src_array_o : out t_wrf_source_out_array(g_num_phys-1 downto 0);
    wrf_src_array_i : in  t_wrf_source_in_array(g_num_phys-1 downto 0);
    wrf_snk_array_o : out t_wrf_sink_out_array(g_num_phys-1 downto 0);
    wrf_snk_array_i : in  t_wrf_sink_in_array(g_num_phys-1 downto 0);

    -----------------------------------------
    -- External TSU I/F
    -----------------------------------------
    timestamp_array_o     : out t_txtsu_timestamp_array(g_num_phys-1 downto 0);
    timestamp_array_ack_i : in  std_logic_vector(g_num_phys-1 downto 0) := (others => '0');

    -----------------------------------------
    --  External WB interface Slave. To Ext Crossbar
    -----------------------------------------
    ext_xb_master_i  : in  t_wishbone_master_in;
    ext_xb_master_o  : out t_wishbone_master_out;

    -----------------------------------------
    -- Timecode/Servo Control
    -----------------------------------------
    tm_link_up_o         : out std_logic;
    -- DAC Control
    tm_dac_value_o       : out std_logic_vector(23 downto 0);
    tm_dac_wr_o          : out std_logic_vector(g_aux_clks-1 downto 0);
    -- Aux clock lock enable
    tm_clk_aux_lock_en_i : in  std_logic_vector(g_aux_clks-1 downto 0) := (others => '0');
    -- Aux clock locked flag
    tm_clk_aux_locked_o  : out std_logic_vector(g_aux_clks-1 downto 0);
    -- Timecode output
    tm_time_valid_o      : out std_logic;
    tm_tai_o             : out std_logic_vector(39 downto 0);
    tm_cycles_o          : out std_logic_vector(27 downto 0);
    -- 1PPS output
    pps_p_o              : out std_logic;
    pps_led_o            : out std_logic;

    rst_aux_n_o : out std_logic;

    link_ok_o : out std_logic;

    -- Info about the EP incoming packets.
    ep_rtu_info_array_o : out t_ep_rtu_info_array(g_num_phys-1 downto 0);

    --Set Grand Master mode. It enables the PPS input.
     set_gm_o        : out std_logic;
     
    -- External LM32 interruption
    ext_lm32_irq_i  : in std_logic);
end xwr_core_2p;

architecture struct of xwr_core_2p is
begin

  WRPC : wr_core_2p
    generic map(
      g_simulation                => g_simulation,
      g_phys_uart                 => g_phys_uart,
      g_virtual_uart              => g_virtual_uart,
      g_rx_buffer_size            => g_ep_rxbuf_size,
      g_with_external_clock_input => g_with_external_clock_input,
      g_aux_clks                  => g_aux_clks,
      g_main_dpram_initf          => g_main_dpram_initf,
      g_main_dpram_size           => g_main_dpram_size,
      g_sec_dpram_size            => g_sec_dpram_size,
      g_interface_mode            => g_interface_mode,
      g_address_granularity       => g_address_granularity,
      g_softpll_channels_config   => g_softpll_channels_config,
      g_softpll_enable_debugger   => g_softpll_enable_debugger,
      g_num_phys								  => g_num_phys,
      g_ep_with_rtu               => g_ep_with_rtu,
      g_pcs_16bit                 => g_pcs_16bit,
      g_tx_runt_padding           => g_tx_runt_padding,
      g_with_flow_control         => g_with_flow_control,
      g_extbar_bridge_sdb         => g_extbar_bridge_sdb
	)
    port map(
      clk_sys_i  => clk_sys_i,
      clk_dmtd_i => clk_dmtd_i,
      clk_ref_i  => clk_ref_i,
      clk_aux_i  => clk_aux_i,

      clk_ext_i             => clk_ext_i,
      clk_ext_mul_i         => clk_ext_mul_i,
      clk_ext_mul_locked_i  => clk_ext_mul_locked_i,

      pps_ext_i  => pps_ext_i,
      rst_n_i    => rst_n_i,

      phy_rst_n_o  => phy_rst_n_o,

      dac_hpll_load_p1_o => dac_hpll_load_p1_o,
      dac_hpll_data_o    => dac_hpll_data_o,
      dac_dpll_load_p1_o => dac_dpll_load_p1_o,
      dac_dpll_data_o    => dac_dpll_data_o,
      pll_sync_n_o       => pll_sync_n_o,

			phys_o		 => phys_o,
			phys_i		 => phys_i,

      phy_ref_clk_i => phy_ref_clk_i,

      led_act_o  => led_act_o,
      led_link_o => led_link_o,
      scl_o      => scl_o,
      scl_i      => scl_i,
      sda_o      => sda_o,
      sda_i      => sda_i,

      gtp0_scl_o  => gtp0_scl_o,
      gtp0_scl_i  => gtp0_scl_i,
      gtp0_sda_o  => gtp0_sda_o,
      gtp0_sda_i  => gtp0_sda_i,
      gtp0_det_i  => gtp0_det_i,

      gtp1_scl_o  => gtp1_scl_o,
      gtp1_scl_i  => gtp1_scl_i,
      gtp1_sda_o  => gtp1_sda_o,
      gtp1_sda_i  => gtp1_sda_i,
      gtp1_det_i  => gtp1_det_i,

      ep0_fc_tx_pause_req_i   => ep0_fc_tx_pause_req_i,
      ep0_fc_tx_pause_delay_i => ep0_fc_tx_pause_delay_i,
      ep0_fc_tx_pause_ready_o => ep0_fc_tx_pause_ready_o,

      ep1_fc_tx_pause_req_i   => ep1_fc_tx_pause_req_i,
      ep1_fc_tx_pause_delay_i => ep1_fc_tx_pause_delay_i,
      ep1_fc_tx_pause_ready_o => ep1_fc_tx_pause_ready_o,

      btn1_i     => btn1_i,
      btn2_i     => btn2_i,
      uart_rxd_i => uart_rxd_i,
      uart_txd_o => uart_txd_o,

      owr_pwren_o => owr_pwren_o,
      owr_en_o    => owr_en_o,
      owr_i       => owr_i,

      wb_adr_i   => slave_i.adr,
      wb_dat_i   => slave_i.dat,
      wb_dat_o   => slave_o.dat,
      wb_sel_i   => slave_i.sel,
      wb_we_i    => slave_i.we,
      wb_cyc_i   => slave_i.cyc,
      wb_stb_i   => slave_i.stb,
      wb_ack_o   => slave_o.ack,
      wb_err_o   => slave_o.err,
      wb_rty_o   => slave_o.rty,
      wb_stall_o => slave_o.stall,

      ext_wrf_src_o => wrf_src_array_o,
      ext_wrf_src_i => wrf_src_array_i,
      ext_wrf_snk_o => wrf_snk_array_o,
      ext_wrf_snk_i => wrf_snk_array_i,

      timestamp_array_o => timestamp_array_o,
      timestamp_array_ack_i => timestamp_array_ack_i,

      ext_xb_master_i  => ext_xb_master_i,
      ext_xb_master_o  => ext_xb_master_o,

      tm_link_up_o         => tm_link_up_o,
      tm_dac_value_o       => tm_dac_value_o,
      tm_dac_wr_o          => tm_dac_wr_o,
      tm_clk_aux_lock_en_i => tm_clk_aux_lock_en_i,
      tm_clk_aux_locked_o  => tm_clk_aux_locked_o,
      tm_time_valid_o      => tm_time_valid_o,
      tm_tai_o             => tm_tai_o,
      tm_cycles_o          => tm_cycles_o,
      pps_p_o              => pps_p_o,
      pps_led_o            => pps_led_o,

      rst_aux_n_o => rst_aux_n_o,

      link_ok_o => link_ok_o,

      ep_rtu_info_array_o => ep_rtu_info_array_o,

      set_gm_o  => set_gm_o,
      
      ext_lm32_irq_i => ext_lm32_irq_i);

end struct;
