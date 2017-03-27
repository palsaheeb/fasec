
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.gencores_pkg.all;
use work.wrcore_2p_pkg.all;
use work.wr_fabric_pkg.all;
use work.wr_a7_gtps_pkg.all;
use work.PLL_SPI_ctrl_pkg.all;

-- pvt: don't use all, only xwr_core needed from wr-cores submodule!
library xil_defaultlib;
use xil_defaultlib.wrcore_pkg.xwr_core;

-- used for axis_wbm_bridge
library hdl_lib;
use hdl_lib.main_pkg.all;

library UNISIM;
use UNISIM.vcomponents.all;

library work;
use work.wishbone_pkg.all;
use work.gen7s_cores_pkg.all;

entity wrc_1p_kintex7 is
  generic
    (
      TAR_ADDR_WDTH : integer := 13          -- not used for this project
      );
  port
    (
      -------------------------------------------------------------------------
      -- clocks
      -------------------------------------------------------------------------      
      clk_20m_vcxo_i        : in std_logic;  -- 25MHz VCXO clock
      gtp_dedicated_clk_p_i : in std_logic;  -- GTP transceiver & internal 125
                                             -- MHz PLL clock
      gtp_dedicated_clk_n_i : in std_logic;

      -- FASEC clock outputs for debugging
      -- inouts to match existing fasec_hwtest module
      clk_dmtd_b     : inout std_logic;
      clk_ref_b      : inout std_logic;
      clk_rx_rbclk_b : inout std_logic;

      -- Front panel LEDs
      -- GTP0
      gtp0_activity_led_o : out std_logic;
      gtp0_synced_led_o   : out std_logic;  -- Not used
      gtp0_link_led_o     : out std_logic;
      gtp0_wrmode_led_o   : out std_logic;  -- Not used

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
      -- pll_cs_n_o    : out std_logic;
      -- pll_sck_o     : out std_logic;
      -- pll_sdi_o     : out std_logic;
      -- pll_sdo_i     : in  std_logic;
      -- pll_reset_n_o : out std_logic;
      -- pll_status_i  : in  std_logic;
      -- pll_sync_n_o  : out std_logic;
      -- pll_refsel_o  : out std_logic;
      -- pll_ld_i      : in  std_logic;

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
      pps_o : out std_logic;

      ------------------------------------------
      -- Axi Slave Bus Interface S00_AXI
      ------------------------------------------
      -- aclk provided by this IP, wire to master!
      axi_int_o       : out std_logic;  -- axi interrupt signal
      s00_axi_aclk_o  : out std_logic;
      s00_axi_aresetn : in  std_logic;
      s00_axi_awaddr  : in  std_logic_vector(c_wishbone_address_width-1 downto 0);
      s00_axi_awprot  : in  std_logic_vector(2 downto 0);
      s00_axi_awvalid : in  std_logic;
      s00_axi_awready : out std_logic;
      s00_axi_wdata   : in  std_logic_vector(c_wishbone_data_width-1 downto 0);
      s00_axi_wstrb   : in  std_logic_vector((c_wishbone_data_width/8)-1 downto 0);
      s00_axi_wvalid  : in  std_logic;
      s00_axi_wready  : out std_logic;
      s00_axi_bresp   : out std_logic_vector(1 downto 0);
      s00_axi_bvalid  : out std_logic;
      s00_axi_bready  : in  std_logic;
      s00_axi_araddr  : in  std_logic_vector(c_wishbone_address_width-1 downto 0);
      s00_axi_arprot  : in  std_logic_vector(2 downto 0);
      s00_axi_arvalid : in  std_logic;
      s00_axi_arready : out std_logic;
      s00_axi_rdata   : out std_logic_vector(c_wishbone_data_width-1 downto 0);
      s00_axi_rresp   : out std_logic_vector(1 downto 0);
      s00_axi_rvalid  : out std_logic;
      s00_axi_rready  : in  std_logic);
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
  signal clk_gtx      : std_logic;
  signal clk_125m_ref : std_logic;

  signal pllout_clk_sys     : std_logic;
  signal pllout_clk_dmtd    : std_logic;
  signal pllout_clk_fb_aux  : std_logic;
  signal pllout_clk_fb_dmtd : std_logic;

  signal clk_20m_vcxo_buf : std_logic;
  signal clk_sys          : std_logic;
  signal clk_dmtd         : std_logic;
  signal clk_125m_pllref  : std_logic;

  signal dac_rst_n  : std_logic;
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

  signal bridge_wbm_out : t_wishbone_master_out;
  signal bridge_wbm_in  : t_wishbone_master_in;

  --Duplicate GTPs. Duplicate signals from/to GTPs.
  --WR_LEN.
  -- signal to_phys   : t_phyif_output_array(c_NUM_PHYS-1 downto 0);
  -- signal from_phys : t_phyif_input_array(c_NUM_PHYS-1 downto 0);

  -- 100 MHz clock to configure the AD9516
  -- signal s_100mhz_clk : std_logic;

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
  -- FASEC clock outputs for debugging
  clk_dmtd_b     <= clk_dmtd;           --62,5 MHz, from 20 MHz
  clk_ref_b      <= clk_125m_ref;       --125 MHz, GTP tx clock
  clk_rx_rbclk_b <= phy_rx_rbclk;       -- GTP rx clock

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
     CLKIN1       => clk_125m_pllref,
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

  -- PLL_BASE(S6) ---> MMCME2_ADV(A7)
  -- pvt: modified, was 25 MHz for WR-LEN
  -- 20 MHz -> 62,5 MHz. Generate the dmtd clk
  cmp_dmtd_clk_pll : MMCME2_ADV
    generic map
    (BANDWIDTH            => "OPTIMIZED",
     CLKOUT4_CASCADE      => false,
     COMPENSATION         => "ZHOLD",
     STARTUP_WAIT         => false,
     DIVCLK_DIVIDE        => 1,
     CLKFBOUT_MULT_F      => 50.000,    -- 20 MHz -> 1 GHz
     CLKFBOUT_PHASE       => 0.000,
     CLKFBOUT_USE_FINE_PS => false,
     CLKOUT0_DIVIDE_F     => 16.000,    -- 1GHz/16 -> 62.5 MHz
     CLKOUT0_PHASE        => 0.000,
     CLKOUT0_DUTY_CYCLE   => 0.500,
     CLKOUT0_USE_FINE_PS  => false,
     CLKOUT1_DIVIDE       => 16,        -- 1GHz/16 -> 62.5 MHz
     CLKOUT1_PHASE        => 0.000,
     CLKOUT1_DUTY_CYCLE   => 0.500,
     CLKOUT1_USE_FINE_PS  => false,
     CLKIN1_PERIOD        => 50.000,    -- 50ns for 20 MHz
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
     CLKIN1       => clk_20m_vcxo_buf,
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
      local_reset_n_d0 <= button_rst_n_i;
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
      O => clk_20m_vcxo_buf,
      I => clk_20m_vcxo_i);

  cmp_clk_125m_pllref_buf : BUFG
    port map(
      O => clk_125m_pllref,
      I => clk_gtx);

  -----------------------------------------------------------------------------
  -- The infamous registering process to ensure the PPS & 10 MHz stability strikes again.
  -----------------------------------------------------------------------------

  p_latch_pps : process(clk_125m_ref)
  begin
    if rising_edge(clk_125m_ref) then
      pps_o <= pps;
    end if;
  end process;

  ------------------------------------------------------------------------------
  -- Dedicated clocks for GTP.
  ------------------------------------------------------------------------------
  cmp_gtp_dedicated_clk : IBUFDS_GTE2
    generic map(
      CLKCM_CFG    => true,
      CLKRCV_TRST  => true,
      CLKSWING_CFG => "11")
    port map (
      O     => clk_gtx,
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
  -- cmp_100mhz_clk : IBUFG
  -- port map (
  --   O => s_100mhz_clk,
  --   I => clk_100mhz_i);

  ------------------------------------------------------------------------------
  -- External MHz clock
  ------------------------------------------------------------------------------
  -- pvt: commented out cause of IBUFG unplaced error when put to GND (slave mode)
  -- when used/connected IBUFG is inferred I suppose
  s_ext_clk <= ext_clk_i;
  -- ext_clk_buf : IBUFG
  --   port map (
  --     O => s_ext_clk,
  --     I => ext_clk_i);

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
      clk_ref_i            => clk_125m_ref,
      clk_aux_i            => (others => '0'),
      clk_ext_i            => s_ext_clk,
      rst_n_i              => local_reset_n,
      clk_ext_mul_i        => s_clk_ext_mul,
      clk_ext_mul_locked_i => s_clk_ext_mul_locked,
      -- clk_ext_stopped_i    => clk_ext_stopped_i,
      -- clk_ext_rst_o        => clk_ext_rst_o,

      pps_ext_i => s_pps_input,

      dac_hpll_load_p1_o => dac_hpll_load_p1,
      dac_hpll_data_o    => dac_hpll_data,
      dac_dpll_load_p1_o => dac_dpll_load_p1,
      dac_dpll_data_o    => dac_dpll_data,

      phy_ref_clk_i        => clk_125m_ref,
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
      aux_master_o => open,
      aux_master_i => cc_dummy_master_in,
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
      link_ok_o => open);

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
  --------------------------------------------------------------------------------

  s_rxuart   <= uart_rxd_i;
  uart_txd_o <= s_txuart;

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
      slave_i(0)  => bridge_wbm_out,
      slave_o(0)  => bridge_wbm_in,
      master_i(0) => wrc_slave_o,
      master_o(0) => wrc_slave_i);

  -----------------------------------------
  -- Single GTP ports. FASEC.
  ----------------------------------------  
  U_GTP : wr_gtx_phy_kintex7
    generic map(
      g_simulation => 0)
    port map(
      clk_gtx_i      => clk_gtx,
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

      pad_txn_o => gtp0_txn_o,
      pad_txp_o => gtp0_txp_o,
      pad_rxn_i => gtp0_rxn_i,
      pad_rxp_i => gtp0_rxp_i,

      tx_out_clk_o  => clk_125m_ref,
      tx_locked_o   => open,
      tx_prbs_sel_i => phy_prbs_sel,
      rdy_o         => phy_rdy);

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

  -----------------------------------------
  -- AXI4-Lite slave (to WB master)
  ----------------------------------------
  -- clocked by this module's clk_sys for ease of integration (62.5 MHz)
  s00_axi_aclk_o <= clk_sys;
  u_axis_wbm_bridge : axis_wbm_bridge
    generic map (
      g_AXI_AWIDTH  => c_wishbone_address_width,
      g_WB_AWIDTH   => c_wishbone_address_width,
      g_AXI_DWIDTH  => c_wishbone_data_width,
      g_WB_DWIDTH   => c_wishbone_data_width,
      g_WB_BYTEADDR => false)
    port map (
      wb_clk_o      => open,
      wb_rst_o      => open,
      wb_adr_o      => bridge_wbm_out.adr,
      wb_dat_o      => bridge_wbm_out.dat,
      wb_dat_i      => bridge_wbm_in.dat,
      wb_sel_o      => bridge_wbm_out.sel,
      wb_we_o       => bridge_wbm_out.we,
      wb_stb_o      => bridge_wbm_out.stb,
      wb_cyc_o      => bridge_wbm_out.cyc,
      wb_ack_i      => bridge_wbm_in.ack,
      wb_err_i      => bridge_wbm_in.err,
      wb_rty_i      => bridge_wbm_in.rty,
      wb_inta_i     => bridge_wbm_in.int,
      axi_aclk_i    => clk_sys,
      axi_aresetn_i => s00_axi_aresetn,
      axi_awaddr_i  => s00_axi_awaddr,
      axi_awprot_i  => s00_axi_awprot,
      axi_awvalid_i => s00_axi_awvalid,
      axi_awready_o => s00_axi_awready,
      axi_wdata_i   => s00_axi_wdata,
      axi_wstrb_i   => s00_axi_wstrb,
      axi_wvalid_i  => s00_axi_wvalid,
      axi_wready_o  => s00_axi_wready,
      axi_bresp_o   => s00_axi_bresp,
      axi_bvalid_o  => s00_axi_bvalid,
      axi_bready_i  => s00_axi_bready,
      axi_araddr_i  => s00_axi_araddr,
      axi_arprot_i  => s00_axi_arprot,
      axi_arvalid_i => s00_axi_arvalid,
      axi_arready_o => s00_axi_arready,
      axi_rdata_o   => s00_axi_rdata,
      axi_rresp_o   => s00_axi_rresp,
      axi_rvalid_o  => s00_axi_rvalid,
      axi_rready_i  => s00_axi_rready,
      axi_int_o     => axi_int_o);

end rtl;
