
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.gencores_pkg.all;
use work.wrcore_2p_pkg.all;
use work.wr_fabric_pkg.all;
use work.wr_a7_gtps_pkg.all;
use work.etherbone_pkg.all;
use work.PLL_SPI_ctrl_pkg.all;

library xil_defaultlib;
-- pvt: don't use all, only xwr_core needed from wr-cores submodule!
use xil_defaultlib.wrcore_pkg.xwr_core;

library UNISIM;
use UNISIM.vcomponents.all;

library work;
use work.wishbone_pkg.all;
use work.gen7s_cores_pkg.all;

-- Modifications to fit wrc into wrc_2p by eml. emilio<AT>sevensols.com

entity wrc_1p_kintex7 is
  generic
    (
      TAR_ADDR_WDTH : integer := 13     -- not used for this project
      );
  port
    (
      --Clocks
      clk_25m_vcxo_i : in std_logic;    -- 25MHz VCXO clock

      clk_aux_p_i : in std_logic;       -- 125 PLL auxiliary clock.
      clk_aux_n_i : in std_logic;

      gtp_dedicated_clk_p_i : in std_logic;  -- Dedicated clock for Xilinx GTP transceiver
      gtp_dedicated_clk_n_i : in std_logic;

      --Dedicated CLK to configure the AD9516 PLL (100MHz by default)
      clk_100mhz_i : in std_logic;
      -- clk_100mhz_n_i : in std_logic;

      --SERDES CLK. AD9516 OUT 5.
--      clk_serdes_p_i : in std_logic;
--      clk_serdes_n_i : in std_logic;

      -- Front panel LEDs
      -- GTP0
      gtp0_activity_led_o : out std_logic;
      gtp0_synced_led_o   : out std_logic;  -- Not used
      gtp0_link_led_o     : out std_logic;
      gtp0_wrmode_led_o   : out std_logic;  -- Not used

      -- GTP1
      -- gtp1_activity_led_o : out std_logic;
      -- gtp1_synced_led_o   : out std_logic;  -- Not used
      -- gtp1_link_led_o     : out std_logic;
      -- gtp1_wrmode_led_o   : out std_logic;  -- Not used

      -- DAC Signals
      dac_sclk_o  : out std_logic;
      dac_din_o   : out std_logic;
      dac_cs1_n_o : out std_logic;
      dac_cs2_n_o : out std_logic;


      fpga_scl_b : inout std_logic;
      fpga_sda_b : inout std_logic;

      button_rst_n_i : in std_logic := '1';

      thermo_id : inout std_logic;      -- 1-Wire interface for DS18B20

      -------------------------------------------------------------------------
      -- GTP0 pins
      -------------------------------------------------------------------------
      gtp0_txp_o : out std_logic;
      gtp0_txn_o : out std_logic;

      gtp0_rxp_i : in std_logic;
      gtp0_rxn_i : in std_logic;

      gtp0_mod_def0_b    : in    std_logic;  -- gtp0 detect
      gtp0_mod_def1_b    : inout std_logic;  -- scl
      gtp0_mod_def2_b    : inout std_logic;  -- sda
      gtp0_rate_select_b : inout std_logic;
      gtp0_tx_fault_i    : in    std_logic;
      gtp0_tx_disable_o  : out   std_logic;
      gtp0_los_i         : in    std_logic;

      -------------------------------------------------------------------------
      -- GTP1 pins
      -------------------------------------------------------------------------
      -- gtp1_txp_o : out std_logic;
      -- gtp1_txn_o : out std_logic;

      -- gtp1_rxp_i : in std_logic;
      -- gtp1_rxn_i : in std_logic;

      -- gtp1_mod_def0_b    : in    std_logic;  -- gtp1 detect
      -- gtp1_mod_def1_b    : inout std_logic;  -- scl
      -- gtp1_mod_def2_b    : inout std_logic;  -- sda
      -- gtp1_rate_select_b : inout std_logic;
      -- gtp1_tx_fault_i    : in    std_logic;
      -- gtp1_tx_disable_o  : out   std_logic;
      -- gtp1_los_i         : in    std_logic;

      -----------------------------------------
      --UART
      -----------------------------------------
      uart_rxd_i : in  std_logic;
      uart_txd_o : out std_logic;

      ------------------------------------------
      -- AD9516 SPI
      ------------------------------------------
      pll_cs_n_o    : out std_logic;
      pll_sck_o     : out std_logic;
      pll_sdi_o     : out std_logic;
      pll_sdo_i     : in  std_logic;
      pll_reset_n_o : out std_logic;
      pll_status_i  : in  std_logic;
      pll_sync_n_o  : out std_logic;
      pll_refsel_o  : out std_logic;
      pll_ld_i      : in  std_logic;

      ------------------------------------------
      -- EXT CLK REF (GPS)
      ------------------------------------------
      ext_clk_i : in std_logic;

      --PPS in
      pps_i : in std_logic;

      -- IN/OUT control for PPS.
      -- pps_i OK --> pps_ctrl_o <= '1';
      -- pps_o OK --> pps_ctrl_o <= '0';
      pps_ctrl_o : out std_logic := '1';


      --Termination for PPS.
      -- pps_i OK --> grandmaster ok            --> term_en_o <= '1';
      -- pps_o OK --> grandmaster mode disabled --> term_en_o <= '0';
      term_en_o : out std_logic := '1';

      --PPS out
      pps_o : out std_logic);

end wrc_1p_kintex7;

architecture rtl of wrc_1p_kintex7 is

  ------------------------------------------------------------------------------
  -- Components declaration
  ------------------------------------------------------------------------------
  component reset_gen
    port (
      clk_sys_i        : in  std_logic;
      rst_pcie_n_a_i   : in  std_logic;
      rst_button_n_a_i : in  std_logic;
      rst_n_o          : out std_logic);
  end component;

  component wr_gtx_phy_kintex7
    generic(
      g_simulation : integer := 0);
    port (
      clk_gtx_i      : in  std_logic;
      tx_data_i      : in  std_logic_vector(15 downto 0);
      tx_k_i         : in  std_logic_vector(1 downto 0);
      tx_disparity_o : out std_logic;
      tx_enc_err_o   : out std_logic;
      rx_rbclk_o     : out std_logic;
      rx_data_o      : out std_logic_vector(15 downto 0);
      rx_k_o         : out std_logic_vector(1 downto 0);
      rx_enc_err_o   : out std_logic;
      rx_bitslide_o  : out std_logic_vector(4 downto 0);
      rst_i          : in  std_logic;
      loopen_i       : in  std_logic_vector(2 downto 0);
      pad_txn_o      : out std_logic;
      pad_txp_o      : out std_logic;
      pad_rxn_i      : in  std_logic := '0';
      pad_rxp_i      : in  std_logic := '0';
      tx_out_clk_o   : out std_logic;
      tx_locked_o    : out std_logic;
      tx_prbs_sel_i  : in  std_logic_vector(2 downto 0);
      rdy_o          : out std_logic);
  end component wr_gtx_phy_kintex7;

  ------------------------------------------------------------------------------
  -- WRC-2P VERSION
  ------------------------------------------------------------------------------
  constant c_ver_major : integer := 1;
  constant c_ver_minor : integer := 0;

  ------------------------------------------------------------------------------
  -- Constants declaration
  ------------------------------------------------------------------------------
  constant c_NUM_PHYS : integer := 2;   --WR-LEN
  ------------------------------------------------------------------------------
  -- Signals declaration
  ------------------------------------------------------------------------------
  signal s_txuart     : std_logic;
  signal s_rxuart     : std_logic;

  -- Dedicated clock for GTP transceiver
  --GTP dedicated clock.
  signal gtp_dedicated_clk : std_logic;

  -- Reference clock disciplined by WR. 62.5 MHz
  signal wr_ref_clk : std_logic;

  signal pllout_clk_sys     : std_logic;
  signal pllout_clk_dmtd    : std_logic;
  signal pllout_clk_fb_aux  : std_logic;
  signal pllout_clk_fb_dmtd : std_logic;

  signal clk_25m_vcxo_buf : std_logic;
  signal clk_aux          : std_logic;
  signal clk_sys          : std_logic;
  signal clk_dmtd         : std_logic;

  signal dac_rst_n : std_logic;

  signal wrc_scl_o  : std_logic;
  signal wrc_scl_i  : std_logic;
  signal wrc_sda_o  : std_logic;
  signal wrc_sda_i  : std_logic;
  signal gtp0_scl_o : std_logic;
  signal gtp0_scl_i : std_logic;
  signal gtp0_sda_o : std_logic;
  signal gtp0_sda_i : std_logic;
  -- signal gtp1_scl_o : std_logic;
  -- signal gtp1_scl_i : std_logic;
  -- signal gtp1_sda_o : std_logic;
  -- signal gtp1_sda_i : std_logic;

  signal dac_hpll_load_p1 : std_logic;
  signal dac_dpll_load_p1 : std_logic;
  signal dac_hpll_data    : std_logic_vector(15 downto 0);
  signal dac_dpll_data    : std_logic_vector(15 downto 0);

  signal local_reset_n    : std_logic;
  signal local_reset_n_d0 : std_logic;
  signal local_reset_n_d1 : std_logic;

  signal wrc_slave_i : t_wishbone_slave_in;
  signal wrc_slave_o : t_wishbone_slave_out;

  signal owr_en : std_logic_vector(1 downto 0);
  signal owr_i  : std_logic_vector(1 downto 0);

  signal etherbone_rst_n : std_logic;

  signal etherbone_src_out : t_wrf_source_out;
  signal etherbone_src_in  : t_wrf_source_in;
  signal etherbone_snk_out : t_wrf_sink_out;
  signal etherbone_snk_in  : t_wrf_sink_in;

  signal etherbone_wb_out : t_wishbone_master_out;
  signal etherbone_wb_in  : t_wishbone_master_in;

  --Duplicate GTPs. Duplicate signals from/to GTPs.
  --WR_LEN.
  -- signal to_phys   : t_phyif_output_array(c_NUM_PHYS-1 downto 0);
  -- signal from_phys : t_phyif_input_array(c_NUM_PHYS-1 downto 0);

  -- 100 MHz clock to configure the AD9516
  signal s_100mhz_clk : std_logic;

  --- PLL external signals
  signal s_PLL_en      : std_logic;
  signal s_PLL_done    : std_logic;
  signal s_PLL_ERR     : std_logic;
  signal rst_PLLor_err : std_logic;

  --For debugging the input PPS
  signal s_pps_input : std_logic;

  --Set Grand Master mode. It enables the PPS input.
  signal set_gm : std_logic;

  -- Single SERDES clock to configure the PPS IODELAY
  signal clk_serdes : std_logic;

  ----------------------------------------------------------
  --Signals to manage the external 10 MHz clock
  signal s_ext_clk            : std_logic;
  signal s_clk_ext_mul_locked : std_logic;
  signal s_clk_ext_mul        : std_logic;

  ----------------------------------------------------------------------------
  --WB intercon with the external crossbar (SLAVE).
  ----------------------------------------------------------------------------
  constant c_EXT_XBAR_MASTERS : integer := 2;
  constant c_EXT_XBAR_SLAVES  : integer := 1;

  constant c_SLAVE_ETHERBONE : integer := 0;
  constant c_SLAVE_GW_VER    : integer := 1;

  constant c_ext_xb_layout : t_sdb_record_array(c_EXT_XBAR_MASTERS-1 downto 0) :=
    (c_SLAVE_ETHERBONE => f_sdb_embed_device(c_etherbone_sdb, x"00000000"),  -- Etherbone slave interface
     c_SLAVE_GW_VER    => f_sdb_embed_device(c_xwb_gw_ver_sdb, x"00001000")  -- GW Version.
     );

  constant c_ext_xb_sdb_address : t_wishbone_address := x"00000200";

  constant c_ext_xb_bridge_sdb : t_sdb_bridge :=
    f_xwb_bridge_layout_sdb(true, c_ext_xb_layout, c_ext_xb_sdb_address);

  -- Signals to wb slave module. Etherbone
  signal s_etherbone_cfg_in  : t_wishbone_slave_in;
  signal s_etherbone_cfg_out : t_wishbone_slave_out;

  -- Signals to wb slave module. GW Version.
  signal s_gw_ver_wb_in  : t_wishbone_slave_in;
  signal s_gw_ver_wb_out : t_wishbone_slave_out;

  -- Master interface. From wrc_2p
  signal s_ext_xb_slave_in  : t_wishbone_slave_in;
  signal s_ext_xb_slave_out : t_wishbone_slave_out;

  -- Slaves at the external crossbar.
  signal s_ext_xb_master_in  : t_wishbone_master_in_array(c_EXT_XBAR_MASTERS-1 downto 0);
  signal s_ext_xb_master_out : t_wishbone_master_out_array(c_EXT_XBAR_MASTERS-1 downto 0);

  -----------------------------------------
  -- External Fabric I/F
  ----------------------------------------
  -- signal s_ext_wrf_src_out : t_wrf_source_out_array(c_NUM_PHYS-1 downto 0);
  -- signal s_ext_wrf_src_in  : t_wrf_source_in_array(c_NUM_PHYS-1 downto 0);
  -- signal s_ext_wrf_snk_out : t_wrf_sink_out_array(c_NUM_PHYS-1 downto 0);
  -- signal s_ext_wrf_snk_in  : t_wrf_sink_in_array(c_NUM_PHYS-1 downto 0);

  -- Signals to latch the PPS output with the incoming serdes clk.
  signal pps : std_logic;

  -- PHY signals
  signal phy_tx_data      : std_logic_vector(15 downto 0);
  signal phy_tx_k         : std_logic_vector(1 downto 0);
  signal phy_tx_disparity : std_logic;
  signal phy_tx_enc_err   : std_logic;
  signal phy_rx_data      : std_logic_vector(15 downto 0);
  signal phy_rx_rbclk     : std_logic;
  signal phy_rx_k         : std_logic_vector(1 downto 0);
  signal phy_rx_enc_err   : std_logic;
  signal phy_rx_bitslide  : std_logic_vector(4 downto 0);
  signal phy_rst          : std_logic;
  signal phy_loopen       : std_logic;
  --loopen_i determines (7 Series Transceiver User Guide(UG476) Figure 2-23 and Table 2-37):
  --'0' => gtx_loopback = "000" => normal operation
  --'1' => gtx_loopback = "100" => Far-end PMA Loopback
  signal phy_loopen_vec   : std_logic_vector(2 downto 0);
  signal phy_prbs_sel     : std_logic_vector(2 downto 0);
  signal phy_rdy          : std_logic;

begin

-- AD9516 STUFF
  p_PLL_active : process(s_100mhz_clk)
    variable v_cnt_enable : integer := 0;
  begin
    if rising_edge(s_100mhz_clk) then
      if (v_cnt_enable > 150) then      -- Case that the PLL is already program
        s_PLL_en <= '0';
        if s_PLL_err = '1' then         -- If error then start SPI again
          v_cnt_enable := 0;
        end if;
        rst_PLLor_err <= '1';
      elsif (v_cnt_enable > 120) then
        s_PLL_en      <= '1';
        v_cnt_enable  := v_cnt_enable + 1;
        rst_PLLor_err <= '1';
      elsif (v_cnt_enable > 40) then
        v_cnt_enable  := v_cnt_enable + 1;
        rst_PLLor_err <= '1';
      else
        rst_PLLor_err <= '0';
        s_PLL_en      <= '0';
        v_cnt_enable  := v_cnt_enable + 1;
      end if;
    end if;
  end process;

  -- Instantation SPI AD9516
  comp_PLL_SPI : PLL_AD9516_ctrl_top
    generic map (
      --WR-LEN (eml): Configurated according to v11.stp file. OUT 3, 7= 125 MHz & OUT 8 = 10 MHz. SYNC resets OUT 8.
      -- PD to outputs 0 1 2 4 5 6 & 9. Counter 1, 2 & 3.1 ignore SYNC. VCO divisor = 6
      g_data_master1 => (x"99", x"00", x"10", x"C3", x"00", x"7C", x"05", x"00", x"0C", x"12", x"00", x"05", x"88", x"01", x"00", x"00",
                         x"00", x"02", x"00", x"00", x"0E", x"01", x"00", x"00", x"01", x"00", x"00", x"01", x"00", x"38", x"01", x"00",
                         x"00", x"0B", x"0B", x"0B", x"08", x"0B", x"0B", x"43", x"42", x"4A", x"4F", x"00", x"00", x"00", x"00", x"40",
                         x"00", x"11", x"C0", x"00", x"00", x"00", x"00", x"28", x"00", x"CB", x"00", x"10", x"20", x"00", x"00", x"04",
                         x"02", x"00", x"00", x"01"),

      g_addr_master1 => (0, 1, 2, 3, 4, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26,
                         27, 28, 29, 30, 31, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170,
                         171, 240, 241, 242, 243, 244, 245, 320, 321, 322, 323, 400, 401, 402, 403, 404,
                         405, 406, 407, 408, 409, 410, 411, 412, 413, 414, 415, 416, 417, 418, 419, 480,
                         481, 560, 561, 562)
      )
    port map(
      clk_i   => s_100mhz_clk,
      rst_n_i => rst_PLLor_err,  -- Before start it should be reset...if not...error programing PLL!

      --- PLL status/control
      PLL_LOCK_i   => low,
      PLL_RESET    => pll_reset_n_o,
      PLL_STAT_i   => pll_status_i,
      PLL_REFSEL_o => pll_refsel_o,
      PLL_SYNC_n_o => open,

      -- SPI bus - PLL control
      PLL_CS_n_o => pll_cs_n_o,
      PLL_SCLK_o => pll_sck_o,
      PLL_SDI_o  => pll_sdi_o,
      PLL_SDO_i  => pll_sdo_i,

      -- SPI controller status
      core_enable_i => s_PLL_en,
      core_done_o   => s_PLL_done,
      core_error_o  => s_PLL_err
      );

  -------------------------------------------------------------
  -- PLL stuff

  --PLL_BASE(S6) ---> MMCME2_ADV(A7)
  -- 125 MHz -> 62,5 MHz. Generate the sys clk

  cmp_sys_clk_pll : MMCME2_ADV
    generic map
    (BANDWIDTH            => "OPTIMIZED",
     CLKOUT4_CASCADE      => false,
     COMPENSATION         => "ZHOLD",
     STARTUP_WAIT         => false,
     DIVCLK_DIVIDE        => 1,
     CLKFBOUT_MULT_F      => 8.000,     -- 125 MHz x 8.
     CLKFBOUT_PHASE       => 0.000,
     CLKFBOUT_USE_FINE_PS => false,

     CLKOUT0_DIVIDE_F    => 16.000,     -- 62.5 MHz sys clock
     CLKOUT0_PHASE       => 0.000,
     CLKOUT0_DUTY_CYCLE  => 0.500,
     CLKOUT0_USE_FINE_PS => false,

     CLKIN1_PERIOD => 8.000,            -- 8 ns means 125 MHz
     REF_JITTER1   => 0.010)
    port map
    -- Output clocks
    (CLKFBOUT     => pllout_clk_fb_aux,
     CLKFBOUTB    => open,
     CLKOUT0      => pllout_clk_sys,
     CLKOUT0B     => open,
     CLKOUT1      => open,
     CLKOUT1B     => open,
     CLKOUT2      => open,
     CLKOUT2B     => open,
     CLKOUT3      => open,
     CLKOUT3B     => open,
     CLKOUT4      => open,
     CLKOUT5      => open,
     CLKOUT6      => open,
     -- Input clock control
     CLKFBIN      => pllout_clk_fb_aux,
     CLKIN1       => clk_aux,
     CLKIN2       => '0',
     -- Tied to always select the primary input clock
     CLKINSEL     => '1',
     -- Ports for dynamic reconfiguration
     DADDR        => (others => '0'),
     DCLK         => '0',
     DEN          => '0',
     DI           => (others => '0'),
     DO           => open,
     DRDY         => open,
     DWE          => '0',
     -- Ports for dynamic phase shift
     PSCLK        => '0',
     PSEN         => '0',
     PSINCDEC     => '0',
     PSDONE       => open,
     -- Other control and status signals
     LOCKED       => open,
     CLKINSTOPPED => open,
     CLKFBSTOPPED => open,
     PWRDWN       => '0',
     RST          => '0');

--PLL_BASE(S6) ---> MMCME2_ADV(A7)
-- 25 MHz -> 62,5 MHz. Generate the dmtd clk
  cmp_dmtd_clk_pll : MMCME2_ADV
    generic map
    (BANDWIDTH            => "OPTIMIZED",
     CLKOUT4_CASCADE      => false,
     COMPENSATION         => "ZHOLD",
     STARTUP_WAIT         => false,
     DIVCLK_DIVIDE        => 1,
     CLKFBOUT_MULT_F      => 30.000,    -- 25 MHz -> 750 MHz
     CLKFBOUT_PHASE       => 0.000,
     CLKFBOUT_USE_FINE_PS => false,
     CLKOUT0_DIVIDE_F     => 12.000,    -- 62.5 MHz
     CLKOUT0_PHASE        => 0.000,
     CLKOUT0_DUTY_CYCLE   => 0.500,
     CLKOUT0_USE_FINE_PS  => false,
     CLKOUT1_DIVIDE       => 12,        -- 62.5 MHz
     CLKOUT1_PHASE        => 0.000,
     CLKOUT1_DUTY_CYCLE   => 0.500,
     CLKOUT1_USE_FINE_PS  => false,
     CLKIN1_PERIOD        => 40.000,    -- 40ns means 25 MHz
     REF_JITTER1          => 0.010)
    port map
    -- Output clocks
    (CLKFBOUT     => pllout_clk_fb_dmtd,
     CLKFBOUTB    => open,
     CLKOUT0      => pllout_clk_dmtd,
     CLKOUT0B     => open,
     CLKOUT1      => open,
     CLKOUT1B     => open,
     CLKOUT2      => open,
     CLKOUT2B     => open,
     CLKOUT3      => open,
     CLKOUT3B     => open,
     CLKOUT4      => open,
     CLKOUT5      => open,
     CLKOUT6      => open,
     -- Input clock control
     CLKFBIN      => pllout_clk_fb_dmtd,
     CLKIN1       => clk_25m_vcxo_buf,
     CLKIN2       => '0',
     -- Tied to always select the primary input clock
     CLKINSEL     => '1',
     -- Ports for dynamic reconfiguration
     DADDR        => (others => '0'),
     DCLK         => '0',
     DEN          => '0',
     DI           => (others => '0'),
     DO           => open,
     DRDY         => open,
     DWE          => '0',
     -- Ports for dynamic phase shift
     PSCLK        => '0',
     PSEN         => '0',
     PSINCDEC     => '0',
     PSDONE       => open,
     -- Other control and status signals
     LOCKED       => open,
     CLKINSTOPPED => open,
     CLKFBSTOPPED => open,
     PWRDWN       => '0',
     RST          => '0');


  n0 : process (clk_sys) is             -- EASE/HDL sens.list
  begin
    if(rising_edge(clk_sys)) then
      local_reset_n_d0 <= button_rst_n_i and pll_ld_i;
      local_reset_n_d1 <= local_reset_n_d0;
      local_reset_n    <= local_reset_n_d1;
    end if;
  end process n0;


  cmp_clk_sys_buf : BUFG
    port map (
      O => clk_sys,
      I => pllout_clk_sys);

  cmp_clk_dmtd_buf : BUFG
    port map (
      O => clk_dmtd,
      I => pllout_clk_dmtd);

  cmp_clk_vcxo : BUFG
    port map (
      O => clk_25m_vcxo_buf,
      I => clk_25m_vcxo_i);

  cmp_auxclk_buf : IBUFGDS
    generic map (
      DIFF_TERM    => false,            -- Differential Termination
      IBUF_LOW_PWR => true,  -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
      IOSTANDARD   => "DEFAULT")
    port map (
      O  => clk_aux,                    -- Buffer output
      I  => clk_aux_p_i,  -- Diff_p buffer input (connect directly to top-level port)
      IB => clk_aux_n_i  -- Diff_n buffer input (connect directly to top-level port)
      );

--------------------------------------------------------------------------------------------------------
  -- The SERDES CLOCK is used as WR CLK (62.5MHz)
--   cmp_pllserdes_buf : IBUFGDS
--   generic map (
--     DIFF_TERM    => false,      -- Differential Termination
--     IBUF_LOW_PWR => true,      -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
--     IOSTANDARD   => "DEFAULT")
--   port map (
--     O  => open,     -- Buffer output
--     I  => clk_serdes_p_i,  -- Diff_p buffer input (connect directly to top-level port)
--     IB => clk_serdes_n_i   -- Diff_n buffer input (connect directly to top-level port)
--     );

  -----------------------------------------------------------------------------
  -- The infamous registering process to ensure the PPS & 10 MHz stability strikes again.
  -----------------------------------------------------------------------------

  p_latch_pps : process(wr_ref_clk)
  begin
    if rising_edge(wr_ref_clk) then
      pps_o <= pps;
    end if;
  end process;

  ------------------------------------------------------------------------------
  -- Dedicated clocks for GTP.
  ------------------------------------------------------------------------------
  cmp_gtp_dedicated_clk : IBUFDS_GTE2
    port map (
      O     => gtp_dedicated_clk,
      ODIV2 => open,
      CEB   => '0',
      I     => gtp_dedicated_clk_p_i,
      IB    => gtp_dedicated_clk_n_i
      );

  ------------------------------------------------------------------------------
  -- 100 MHz clock to initialize the AD9516
  ------------------------------------------------------------------------------
  -- cmp_100mhz_clk : IBUFGDS
  --   generic map(
  --     DIFF_TERM    => false,
  --     IBUF_LOW_PWR => true,
  --     IOSTANDARD   => "DEFAULT")
  --   port map (
  --     O  => s_100mhz_clk,
  --     I  => clk_100mhz_p_i,
  --     IB => clk_100mhz_n_i);
    cmp_100mhz_clk : IBUFG
    port map (
      O => s_100mhz_clk,
      I => clk_100mhz_i);

  ------------------------------------------------------------------------------
  -- External MHz clock
  ------------------------------------------------------------------------------

  ext_clk_buf : IBUFG
    port map (
      O => s_ext_clk,
      I => ext_clk_i);

  -- Ext 10 MHz -> 62,5 MHz.

  U_ext_pll_10_to_62 : ext_pll_10_to_62_compensated
    port map (
      ext_clk_i            => s_ext_clk,
      rst_n_i              => local_reset_n,
      gm_en_i              => set_gm,
      pps_i                => (s_pps_input and set_gm),
      clk_ext_mul_o        => s_clk_ext_mul,
      clk_ext_mul_locked_o => s_clk_ext_mul_locked
      );

------------------------------------------------------------------------------
  --EEPROM
  fpga_scl_b <= '0' when wrc_scl_o = '0' else 'Z';
  fpga_sda_b <= '0' when wrc_sda_o = '0' else 'Z';
  wrc_scl_i  <= fpga_scl_b;
  wrc_sda_i  <= fpga_sda_b;

  --SFP 1 I2C
  gtp0_mod_def1_b <= '0' when gtp0_scl_o = '0' else 'Z';
  gtp0_mod_def2_b <= '0' when gtp0_sda_o = '0' else 'Z';
  gtp0_scl_i      <= gtp0_mod_def1_b;
  gtp0_sda_i      <= gtp0_mod_def2_b;

  --SFP 2 I2C
  -- gtp1_mod_def1_b <= '0' when gtp1_scl_o = '0' else 'Z';
  -- gtp1_mod_def2_b <= '0' when gtp1_sda_o = '0' else 'Z';
  -- gtp1_scl_i      <= gtp1_mod_def1_b;
  -- gtp1_sda_i      <= gtp1_mod_def2_b;

  thermo_id <= '0' when owr_en(0) = '1' else 'Z';
  owr_i(0)  <= thermo_id;

  U_WR_CORE : xil_defaultlib.wrcore_pkg.xwr_core
    generic map (
      -- 'merged' from xwr_core_2p and kintex7_top
      g_simulation                => 0,
      g_with_external_clock_input => true,
      g_phys_uart                 => true,
      g_virtual_uart              => true,
      g_aux_clks                  => 1,
      g_ep_rxbuf_size             => 1024,
--      g_tx_runt_padding           => true,
      g_dpram_initf               => "",
      g_dpram_size                => 131072/4,
      g_interface_mode            => PIPELINED,
      g_address_granularity       => BYTE,
      g_aux_sdb                   => c_wrc_periph3_sdb,
      g_softpll_enable_debugger   => false,
      g_vuart_fifo_size           => 1024,
      g_pcs_16bit                 => true)
    -- g_records_for_phy           => g_records_for_phy,
    -- g_diag_id                   => g_diag_id,
    -- g_diag_ver                  => g_diag_ver,
    -- g_diag_ro_size              => g_diag_ro_size,
    -- g_diag_rw_size              => g_diag_rw_size)
    port map (
      clk_sys_i            => clk_sys,
      clk_dmtd_i           => clk_dmtd,
      clk_ref_i            => wr_ref_clk,
      clk_aux_i            => (others => '0'),
      clk_ext_i            => s_ext_clk,
      rst_n_i   => local_reset_n,
      clk_ext_mul_i        => s_clk_ext_mul,
      clk_ext_mul_locked_i => s_clk_ext_mul_locked,
      -- clk_ext_stopped_i    => clk_ext_stopped_i,
      -- clk_ext_rst_o        => clk_ext_rst_o,

      pps_ext_i => s_pps_input,

      dac_hpll_load_p1_o => dac_hpll_load_p1,
      dac_hpll_data_o    => dac_hpll_data,
      dac_dpll_load_p1_o => dac_dpll_load_p1,
      dac_dpll_data_o    => dac_dpll_data,

      phy_ref_clk_i        => wr_ref_clk,
      phy_tx_data_o        => phy_tx_data,
      phy_tx_k_o           => phy_tx_k,
      phy_tx_disparity_i   => phy_tx_disparity,
      phy_tx_enc_err_i     => phy_tx_enc_err,
      phy_rx_data_i        => phy_rx_data,
      phy_rx_rbclk_i       => phy_rx_rbclk,
      phy_rx_k_i           => phy_rx_k,
      phy_rx_enc_err_i     => phy_rx_enc_err,
      phy_rx_bitslide_i    => phy_rx_bitslide,
      phy_rst_o            => phy_rst,
      phy_rdy_i            => phy_rdy,
      phy_loopen_o         => open,
      phy_loopen_vec_o     => phy_loopen_vec,
      phy_tx_prbs_sel_o    => phy_prbs_sel,
      phy_sfp_tx_fault_i   => gtp0_tx_fault_i,
      phy_sfp_los_i        => gtp0_los_i,
      phy_sfp_tx_disable_o => gtp0_tx_disable_o,
      -- phy8_o               => phy8_o,
      -- phy8_i               => phy8_i,
      -- phy16_o              => phy16_o,
      -- phy16_i              => phy16_i,

      led_act_o  => gtp0_activity_led_o,
      led_link_o => gtp0_link_led_o,

      scl_o => wrc_scl_o,
      scl_i => wrc_scl_i,
      sda_o => wrc_sda_o,
      sda_i => wrc_sda_i,

      -- I2C for SFP
      sfp_scl_o => gtp0_scl_o,
      sfp_scl_i => gtp0_scl_i,
      sfp_sda_o => gtp0_sda_o,
      sfp_sda_i => gtp0_sda_i,
      sfp_det_i => gtp0_mod_def0_b,

      btn1_i => button_rst_n_i,
      btn2_i => '1',

      spi_sclk_o => open,
      spi_ncs_o  => open,
      spi_mosi_o => open,
      spi_miso_i => '0',

      uart_rxd_i => s_rxuart,
      uart_txd_o => s_txuart,

      owr_pwren_o => open,
      owr_en_o    => owr_en,
      owr_i       => owr_i,

      slave_i      => wrc_slave_i, 
      slave_o      => wrc_slave_o,
      aux_master_o => s_ext_xb_slave_in,
      aux_master_i => s_ext_xb_slave_out,
      wrf_src_o    => open,
      wrf_src_i    => c_dummy_src_in,
      wrf_snk_o    => open,
      wrf_snk_i    => c_dummy_snk_in,

      timestamps_o        => open,
      timestamps_ack_i    => '1',
      fc_tx_pause_req_i   => '0',
      fc_tx_pause_delay_i => x"0000",
      fc_tx_pause_ready_o => open,

      tm_link_up_o         => open,
      tm_dac_value_o       => open,
      tm_dac_wr_o          => open,
      tm_clk_aux_lock_en_i => (others => '0'),
      tm_clk_aux_locked_o  => open,
      tm_time_valid_o      => open,
      tm_tai_o             => open,
      tm_cycles_o          => open,

      pps_p_o   => pps,
      pps_led_o => open,

      rst_aux_n_o => open,

      -- aux_diag_i => aux_diag_i,
      -- aux_diag_o => aux_diag_o,
      link_ok_o  => open);

  -- U_WR_CORE2P : xwr_core_2p
  --   generic map (
  --     g_simulation                => 0,
  --     g_with_external_clock_input => true,
  --     --
  --     g_phys_uart                 => true,
  --     g_virtual_uart              => true,
  --     g_aux_clks                  => 1,
  --     g_ep_rxbuf_size             => 1024,
  --     g_main_dpram_initf          => "",  -- There is not .ram file. wrc.vhd file is taken by default..
  --     g_main_dpram_size           => 110000/4,  -- Size_in_bytes = (dpram_size)x4. (110000)
  --     g_sec_dpram_size            => 2048,  -- Secundary RAM. Just for GTP1 packet interchange.
  --     g_interface_mode            => PIPELINED,
  --     g_address_granularity       => BYTE,
  --     g_num_phys                  => c_NUM_PHYS,

  --     g_ep_with_rtu       => false,
  --     g_pcs_16bit         => true,
  --     g_tx_runt_padding   => false,
  --     g_with_flow_control => false,

  --     g_extbar_bridge_sdb => c_ext_xb_bridge_sdb)
  --   port map (
  --     clk_sys_i  => clk_sys,
  --     clk_dmtd_i => clk_dmtd,
  --     clk_ref_i  => wr_ref_clk,
  --     clk_aux_i  => (others => '0'),
  --     pps_ext_i  => s_pps_input,
  --     rst_n_i    => local_reset_n,

  --     clk_ext_i            => s_ext_clk,
  --     clk_ext_mul_i        => s_clk_ext_mul,
  --     clk_ext_mul_locked_i => s_clk_ext_mul_locked,

  --     phy_rst_n_o => open,

  --     pll_sync_n_o => pll_sync_n_o,

  --     dac_hpll_load_p1_o => dac_hpll_load_p1,
  --     dac_hpll_data_o    => dac_hpll_data,
  --     dac_dpll_load_p1_o => dac_dpll_load_p1,
  --     dac_dpll_data_o    => dac_dpll_data,
  --     phy_ref_clk_i      => wr_ref_clk,

  --     phys_o => to_phys,
  --     phys_i => from_phys,

  --     led_act_o(0) => gtp0_activity_led_o,
  --     led_act_o(1) => gtp1_activity_led_o,

  --     led_link_o(0) => gtp0_link_led_o,
  --     led_link_o(1) => gtp1_link_led_o,

  --     scl_o => wrc_scl_o,
  --     scl_i => wrc_scl_i,
  --     sda_o => wrc_sda_o,
  --     sda_i => wrc_sda_i,

  --     --I2C for SFP1
  --     gtp0_scl_o => gtp0_scl_o,
  --     gtp0_scl_i => gtp0_scl_i,
  --     gtp0_sda_o => gtp0_sda_o,
  --     gtp0_sda_i => gtp0_sda_i,
  --     gtp0_det_i => gtp0_mod_def0_b,

  --     --I2C for SFP2
  --     gtp1_scl_o => gtp1_scl_o,
  --     gtp1_scl_i => gtp1_scl_i,
  --     gtp1_sda_o => gtp1_sda_o,
  --     gtp1_sda_i => gtp1_sda_i,
  --     gtp1_det_i => gtp1_mod_def0_b,

  --     btn1_i => button_rst_i,
  --     btn2_i => '1',                    -- Only one button in the WR-LEN.

  --     uart_rxd_i => s_rxuart,
  --     uart_txd_o => s_txuart,

  --     owr_en_o => owr_en,
  --     owr_i    => owr_i,

  --     slave_i => wrc_slave_i,  -- Master interface to the internal crossbars
  --     slave_o => wrc_slave_o,

  --     tm_dac_value_o       => open,
  --     tm_dac_wr_o          => open,
  --     tm_clk_aux_lock_en_i => (others => '0'),
  --     tm_clk_aux_locked_o  => open,
  --     tm_time_valid_o      => open,
  --     tm_tai_o             => open,
  --     tm_cycles_o          => open,
  --     pps_p_o              => pps,
  --     pps_led_o            => open,

  --     rst_aux_n_o => etherbone_rst_n,

  --     set_gm_o        => set_gm,
  --     ---------------------------------------------------------------------
  --     wrf_src_array_o => s_ext_wrf_src_out,  -- x2
  --     wrf_src_array_i => s_ext_wrf_src_in,   -- x2
  --     wrf_snk_array_o => s_ext_wrf_snk_out,  -- x2
  --     wrf_snk_array_i => s_ext_wrf_snk_in,   -- x2

  --     ext_xb_master_o => s_ext_xb_slave_in,
  --     ext_xb_master_i => s_ext_xb_slave_out,

  --     ext_lm32_irq_i => '0');
  -- ---------------------------------------------------------------------
  -- -- By the moment both of the external fabrics are connected between themselves. EB is not available.
  -- -- EP0 --> EP1
  -- s_ext_wrf_snk_in(1) <= s_ext_wrf_src_out(0);
  -- s_ext_wrf_src_in(0) <= s_ext_wrf_snk_out(1);

  -- -- EP1 --> EP0
  -- s_ext_wrf_snk_in(0) <= s_ext_wrf_src_out(1);
  -- s_ext_wrf_src_in(1) <= s_ext_wrf_snk_out(0);

-----------------------------------------------------------------------------
-- WB External Slave Crossbar. Slv: EB
-----------------------------------------------------------------------------
  ext_slavebar : xwb_sdb_crossbar
    generic map(
      g_num_masters => c_EXT_XBAR_SLAVES,
      g_num_slaves  => c_EXT_XBAR_MASTERS,
      g_registered  => true,
      g_wraparound  => true,
      g_layout      => c_ext_xb_layout,
      g_sdb_addr    => c_ext_xb_sdb_address)
    port map(
      clk_sys_i => clk_sys,
      rst_n_i   => local_reset_n,

      -- Master connections (INTERCON is a slave)
      -- pvt: external axi-wb-bridge needed here!?
      slave_i(0) => s_ext_xb_slave_in,
      slave_o(0) => s_ext_xb_slave_out,
      -- Slave connections (INTERCON is a master)
      master_i   => s_ext_xb_master_in,
      master_o   => s_ext_xb_master_out);

  -- Slave 0. Eb
  -- Slave 1. GW Version.
  s_etherbone_cfg_in <= s_ext_xb_master_out(c_SLAVE_ETHERBONE);
  s_gw_ver_wb_in     <= s_ext_xb_master_out(c_SLAVE_GW_VER);

  s_ext_xb_master_in(c_SLAVE_ETHERBONE) <= s_etherbone_cfg_out;
  s_ext_xb_master_in(c_SLAVE_GW_VER)    <= s_gw_ver_wb_out;
--------------------------------------------------------------------------------

  s_rxuart   <= uart_rxd_i;
  uart_txd_o <= s_txuart;

  -- Etherbone module
  Etherbone : eb_slave_core
    generic map (
      g_sdb_address => x"0000000000070000")  --I think that it should match with g_sdb_address at wr_core main crossbar. eml.
    port map (
      clk_i       => clk_sys,
      nRst_i      => etherbone_rst_n,
      src_o       => etherbone_src_out,
      src_i       => etherbone_src_in,
      snk_o       => etherbone_snk_out,
      snk_i       => etherbone_snk_in,
      cfg_slave_o => s_etherbone_cfg_out,
      cfg_slave_i => s_etherbone_cfg_in,
      master_o    => etherbone_wb_out,
      master_i    => etherbone_wb_in);

  -- WB GW Version module

  U_GWver : xwb_GWversion
    generic map(
      g_board_id            => x"7502C1C0",
      g_ver_major           => c_ver_major,
      g_ver_minor           => c_ver_minor,
      g_interface_mode      => PIPELINED,
      g_address_granularity => BYTE
      )
    port map(
      ---Clock signals
      wb_clk_i   => clk_sys,
      wb_rst_n_i => local_reset_n,
      ---Wishbone slave
      slave_i    => s_gw_ver_wb_in,
      slave_o    => s_gw_ver_wb_out);

  -----------------------------------------------------------------------------
  -- WB External Master Crossbar
  -----------------------------------------------------------------------------
  ext_masterbar : xwb_crossbar
    generic map (
      g_num_masters => 1,
      g_num_slaves  => 1,
      g_registered  => false,
      g_address     => (0 => x"00000000"),
      g_mask        => (0 => x"00000000"))
    port map (
      clk_sys_i   => clk_sys,
      rst_n_i     => local_reset_n,
      slave_i(0)  => etherbone_wb_out,
      slave_o(0)  => etherbone_wb_in,
      master_i(0) => wrc_slave_o,
      master_o(0) => wrc_slave_i);

  -----------------------------------------
  -- Single GTP ports. FASEC.
  ----------------------------------------  
  U_GTP : wr_gtx_phy_kintex7
    generic map(
      g_simulation => 0)
    port map(
      clk_gtx_i      => gtp_dedicated_clk,
      tx_data_i      => phy_tx_data,
      tx_k_i         => phy_tx_k,
      tx_disparity_o => phy_tx_disparity,
      tx_enc_err_o   => phy_tx_enc_err,
      rx_rbclk_o     => phy_rx_rbclk,
      rx_data_o      => phy_rx_data,
      rx_k_o         => phy_rx_k,
      rx_enc_err_o   => phy_rx_enc_err,
      rx_bitslide_o  => phy_rx_bitslide,
      rst_i          => not local_reset_n,
      loopen_i       => phy_loopen_vec,
      
      pad_txn_o      => gtp0_txn_o,
      pad_txp_o      => gtp0_txp_o,
      pad_rxn_i      => gtp0_rxn_i,
      pad_rxp_i      => gtp0_rxp_i,
      
      tx_out_clk_o   => wr_ref_clk,
      tx_locked_o    => open,
      tx_prbs_sel_i  => phy_prbs_sel,
      rdy_o          => phy_rdy);
  
  -----------------------------------------
  -- Dual GTP ports. WR-LEN.
  ----------------------------------------
  -- U_GTP_2Ports : wr_gtp_phy_artix7
  --   port map(

  --     gtp_clk_i    => gtp_dedicated_clk,
  --     rst_i        => not local_reset_n,  --local_reset_n
  --     tx_out_clk_o => wr_ref_clk,

  --     -- Port 0
  --     ch0_tx_data_i      => to_phys(0).tx_data,
  --     ch0_tx_k_i         => to_phys(0).tx_k,           --Increased up to 2
  --     ch0_tx_disparity_o => from_phys(0).tx_disparity,
  --     ch0_tx_enc_err_o   => from_phys(0).tx_enc_err,
  --     ch0_rx_rbclk_o     => from_phys(0).rx_clk,
  --     ch0_rx_data_o      => from_phys(0).rx_data,
  --     ch0_rx_k_o         => from_phys(0).rx_k,         --Increased up to 2
  --     ch0_rx_enc_err_o   => from_phys(0).rx_enc_err,
  --     ch0_rx_bitslide_o  => from_phys(0).rx_bitslide,  --Increased up to 4.
  --     ch0_loopen_i       => to_phys(0).loopen,
  --     ch0_tx_prbs_sel_i  => to_phys(0).tx_prbs_sel,
  --     ch0_ready_o        => from_phys(0).rdy,

  --     -- Port 1
  --     ch1_tx_data_i      => to_phys(1).tx_data,        --Increased up to 16
  --     ch1_tx_k_i         => to_phys(1).tx_k,           --Increased up to 2
  --     ch1_tx_disparity_o => from_phys(1).tx_disparity,
  --     ch1_tx_enc_err_o   => from_phys(1).tx_enc_err,
  --     ch1_rx_data_o      => from_phys(1).rx_data,      --Increased up to 16
  --     ch1_rx_rbclk_o     => from_phys(1).rx_clk,
  --     ch1_rx_k_o         => from_phys(1).rx_k,
  --     ch1_rx_enc_err_o   => from_phys(1).rx_enc_err,
  --     ch1_rx_bitslide_o  => from_phys(1).rx_bitslide,  --Increased up to 4.
  --     ch1_loopen_i       => to_phys(1).loopen,
  --     ch1_tx_prbs_sel_i  => to_phys(1).tx_prbs_sel,
  --     ch1_ready_o        => from_phys(1).rdy,

  --     -- Serial I/O
  --     ch0_pad_txn_o => gtp0_txn_o,
  --     ch0_pad_txp_o => gtp0_txp_o,
  --     ch0_pad_rxn_i => gtp0_rxn_i,
  --     ch0_pad_rxp_i => gtp0_rxp_i,

  --     ch1_pad_txn_o => gtp1_txn_o,
  --     ch1_pad_txp_o => gtp1_txp_o,
  --     ch1_pad_rxn_i => gtp1_rxn_i,
  --     ch1_pad_rxp_i => gtp1_rxp_i);

  ---------------------------------------------------------------

  U_DAC_ARB : spec_serial_dac_arb
    generic map (
      g_invert_sclk    => false,
      g_num_extra_bits => 8)

    port map (
      clk_i   => clk_sys,
      rst_n_i => local_reset_n,

      val1_i  => dac_dpll_data,
      load1_i => dac_dpll_load_p1,

      val2_i  => dac_hpll_data,
      load2_i => dac_hpll_load_p1,

      dac_cs_n_o(0) => dac_cs1_n_o,
      dac_cs_n_o(1) => dac_cs2_n_o,
      dac_clr_n_o   => open,
      dac_sclk_o    => dac_sclk_o,
      dac_din_o     => dac_din_o);

  --Enabling the SFPs transmission
  -- gtp0_tx_disable_o <= '0';
  -- gtp1_tx_disable_o <= '0';

  --------------------------------------------------------------------------------

  --External reference clock
  p_ext_ctrl : process(clk_sys, local_reset_n)
  begin
    if rising_edge(clk_sys) then
      if local_reset_n = '0' then
        pps_ctrl_o <= '0';
        term_en_o  <= '0';
      else
        if set_gm = '1' then
          pps_ctrl_o <= '1';
          term_en_o  <= '1';
        else
          pps_ctrl_o <= '0';
          term_en_o  <= '0';
        end if;
      end if;
    end if;
  end process;

  s_pps_input <= pps_i;

end rtl;
