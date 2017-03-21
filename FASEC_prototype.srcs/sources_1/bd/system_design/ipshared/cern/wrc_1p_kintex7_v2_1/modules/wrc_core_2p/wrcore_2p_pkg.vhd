library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.genram_pkg.all;
use work.wishbone_pkg.all;
use work.sysc_wbgen2_pkg.all;
use work.wr_fabric_pkg.all;
use work.endpoint_pkg.all;
use work.softpll_pkg.all;

-- eml
-- use work.etherbone_pkg.all;
use work.gen7s_cores_pkg.all;

package wrcore_2p_pkg is

	---------------------------------------------------
	-- Array between the WRc and the two GTPs
	-- Future work; Move me to a package file
	---------------------------------------------------

  -- Output from WRC core to PHY

  type t_phyif_output is record
    rst         : std_logic;
    loopen      : std_logic_vector(2 downto 0);
    tx_disable  : std_logic;
    syncen      : std_logic;
    tx_data     : std_logic_vector(15 downto 0);
    tx_k        : std_logic_vector(1 downto 0);
    tx_prbs_sel : std_logic_vector(2 downto 0);
  end record;

  type t_phyif_input is record
    tx_disparity : std_logic;
    tx_enc_err   : std_logic;
    rx_data      : std_logic_vector(15 downto 0);
    rx_clk       : std_logic;
    rx_k         : std_logic_vector(1 downto 0);
    rx_enc_err   : std_logic;
    rx_bitslide  : std_logic_vector(4 downto 0);
    rdy          : std_logic;
    tx_fault     : std_logic;
    los          : std_logic;
  end record;

  type t_phyif_output_array is array(integer range <>) of t_phyif_output;
  type t_phyif_input_array is array(integer range <>) of t_phyif_input;


	-- It has been defined in endpoint_pkg.vhdl already.
	--TX timestamps between exchange between the Mini-NIC and the endpoint.
	--type t_txtsu_timestamp is record
	--	stb       : std_logic;
	--	tsval     : std_logic_vector(31 downto 0);
	--	port_id   : std_logic_vector(4 downto 0);
	--	frame_id  : std_logic_vector(15 downto 0);
	--	incorrect : std_logic;
	--end record;
	--type t_txtsu_timestamp_array is array(integer range <>) of t_txtsu_timestamp;

	 -- Functions and constants for the Slave Xbar

     constant c_empty_xbar_sdb : t_sdb_product := (
       vendor_id => x"00000000000075cb",  -- 7sols
       device_id => x"77777777",
       version   => x"00000001",
       date      => x"20152107",
       name          => "WR-empty-xbar      ");

      -- Use the f_xwb_bridge_*_sdb to bridge a crossbar to another
     function f_xwb_bridge_product_manual_sdb( -- take a manual bus size
         g_size        : t_wishbone_address;
         g_sdb_addr    : t_wishbone_address;
         g_sdb_product : t_sdb_product) return t_sdb_bridge;

     function f_xwb_bridge_product_layout_sdb( -- determine bus size from layout
         g_wraparound  : boolean := true;
         g_layout      : t_sdb_record_array;
         g_sdb_addr    : t_wishbone_address;
         g_sdb_product : t_sdb_product) return t_sdb_bridge;

     constant c_empty_bridge_sdb : t_sdb_bridge := f_xwb_bridge_product_manual_sdb(x"ffff", x"10000", c_empty_xbar_sdb);

  -----------------------------------------------------------------------------
  --PPS generator
  -----------------------------------------------------------------------------
  constant c_xwr_pps_gen_sdb : t_sdb_device := (
    abi_class     => x"0000",              -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"01",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"7",                 -- 8/16/32-bit port granularity
    sdb_component => (
      addr_first  => x"0000000000000000",
      addr_last   => x"00000000000000ff",
      product     => (
        vendor_id => x"000000000000CE42",  -- CERN
        device_id => x"de0d8ced",
        version   => x"00000001",
        date      => x"20120305",
        name      => "WR-PPS-Generator   ")));

  component xwr_pps_gen is
    generic(
      g_interface_mode       : t_wishbone_interface_mode;
      g_address_granularity  : t_wishbone_address_granularity;
      g_ref_clock_rate       : integer;
      g_ext_clock_rate       : integer;
      g_with_ext_clock_input : boolean
      );
    port (
      clk_ref_i       : in  std_logic;
      clk_sys_i       : in  std_logic;
      clk_ext_i       : in  std_logic := '0';
      rst_n_i         : in  std_logic;
      slave_i         : in  t_wishbone_slave_in;
      slave_o         : out t_wishbone_slave_out;
      pps_in_i        : in  std_logic;
      pps_csync_o     : out std_logic;
      pps_out_o       : out std_logic;
      pps_led_o       : out std_logic;
      pps_valid_o     : out std_logic;

      sync_pps_valid_o : out std_logic;   -- SYNC stuff

      tm_utc_o        : out std_logic_vector(39 downto 0);
      tm_cycles_o     : out std_logic_vector(27 downto 0);
      tm_time_valid_o : out std_logic;
      set_gm_o        : out std_logic
      );
  end component;

  -----------------------------------------------------------------------------
  --Mini NIC
  -----------------------------------------------------------------------------
  --mini_nic_sdb
	constant c_xwr_mini_nic_sdb : t_sdb_device := (
    abi_class     => x"0000",              -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"01",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"7",                 -- 8/16/32-bit port granularity
    sdb_component => (
      addr_first  => x"0000000000000000",
      addr_last   => x"00000000000000ff",
      product     => (
        vendor_id => x"000000000000CE42",  -- CERN
        device_id => x"ab28633a",
        version   => x"00000001",
        date      => x"20120305",
        name      => "WR-Mini-NIC        ")));

  component xwr_mini_nic
    generic (
      g_interface_mode       : t_wishbone_interface_mode;
      g_address_granularity  : t_wishbone_address_granularity;
      g_memsize_log2         : integer;
      g_buffer_little_endian : boolean);
    port (
      clk_sys_i           : in  std_logic;
      rst_n_i             : in  std_logic;
      mem_data_o          : out std_logic_vector(31 downto 0);
      mem_addr_o          : out std_logic_vector(g_memsize_log2-1 downto 0);
      mem_data_i          : in  std_logic_vector(31 downto 0);
      mem_wr_o            : out std_logic;
      src_o               : out t_wrf_source_out;
      src_i               : in  t_wrf_source_in;
      snk_o               : out t_wrf_sink_out;
      snk_i               : in  t_wrf_sink_in;
      txtsu_port_id_i     : in  std_logic_vector(4 downto 0);
      txtsu_frame_id_i    : in  std_logic_vector(16 - 1 downto 0);
      txtsu_tsval_i       : in  std_logic_vector(28 + 4 - 1 downto 0);
      txtsu_tsincorrect_i : in  std_logic;
      txtsu_stb_i         : in  std_logic;
      txtsu_ack_o         : out std_logic;
      wb_i                : in  t_wishbone_slave_in;
      wb_o                : out t_wishbone_slave_out);
  end component;

  -----------------------------------------------------------------------------
  -- PERIPHERIALS
  -----------------------------------------------------------------------------
  component xwr_syscon_wb
    generic(
      g_interface_mode      : t_wishbone_interface_mode;
      g_address_granularity : t_wishbone_address_granularity
      );
    port (
      rst_n_i   : in std_logic;
      clk_sys_i : in std_logic;

      slave_i : in  t_wishbone_slave_in;
      slave_o : out t_wishbone_slave_out;

      regs_i : in  t_sysc_in_registers;
      regs_o : out t_sysc_out_registers
      );
  end component;

  constant c_wrc_periph0_sdb : t_sdb_device := (
    abi_class     => x"0000",              -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"01",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"7",                 -- 8/16/32-bit port granularity
    sdb_component => (
      addr_first  => x"0000000000000000",
      addr_last   => x"00000000000000ff",
      product     => (
        vendor_id => x"000000000000CE42",  -- CERN
        device_id => x"ff07fc47",
        version   => x"00000001",
        date      => x"20120305",
        name      => "WR-Periph-Syscon   ")));

  constant c_wrc_periph1_sdb : t_sdb_device := (
    abi_class     => x"0000",              -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"01",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"7",                 -- 8/16/32-bit port granularity
    sdb_component => (
      addr_first  => x"0000000000000000",
      addr_last   => x"00000000000000ff",
      product     => (
        vendor_id => x"000000000000CE42",  -- CERN
        device_id => x"e2d13d04",
        version   => x"00000001",
        date      => x"20120305",
        name      => "WR-Periph-UART     ")));

  constant c_wrc_periph2_sdb : t_sdb_device := (
    abi_class     => x"0000",              -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"01",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"7",                 -- 8/16/32-bit port granularity
    sdb_component => (
      addr_first  => x"0000000000000000",
      addr_last   => x"00000000000000ff",
      product     => (
        vendor_id => x"000000000000CE42",  -- CERN
        device_id => x"779c5443",
        version   => x"00000001",
        date      => x"20120305",
        name      => "WR-Periph-1Wire    ")));


  constant c_wrc_periph3_sdb : t_sdb_device := (
    abi_class     => x"0000",              -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"01",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"7",                 -- 8/16/32-bit port granularity
    sdb_component => (
      addr_first  => x"0000000000000000",
      addr_last   => x"00000000000000ff",
      product     => (
        vendor_id => x"000000000000CE42",  -- CERN
        device_id => x"779c5445",
        version   => x"00000001",
        date      => x"20120615",
        name      => "WR-Periph-AuxWB    ")));

  component wrc_periph is
    generic(
      g_phys_uart    : boolean := true;
      g_virtual_uart : boolean := false;
      g_cntr_period  : integer := 62500;
      g_mem_words    : integer := 16384
      );
    port(
      clk_sys_i   : in  std_logic;
      rst_n_i     : in  std_logic;
      rst_net_n_o : out std_logic;
      rst_wrc_n_o : out std_logic;
      led_red_o   : out std_logic;
      led_green_o : out std_logic;
      scl_o       : out std_logic;
      scl_i       : in  std_logic;
      sda_o       : out std_logic;
      sda_i       : in  std_logic;

      sfp0_scl_o   : out std_logic;
      sfp0_scl_i   : in  std_logic;
      sfp0_sda_o   : out std_logic;
      sfp0_sda_i   : in  std_logic;
      sfp0_det_i   : in  std_logic;

      sfp1_scl_o   : out std_logic;
      sfp1_scl_i   : in  std_logic;
      sfp1_sda_o   : out std_logic;
      sfp1_sda_i   : in  std_logic;
      sfp1_det_i   : in  std_logic;

      memsize_i   : in  std_logic_vector(3 downto 0);
      btn1_i      : in  std_logic;
      btn2_i      : in  std_logic;
      slave_i     : in  t_wishbone_slave_in_array(0 to 2);
      slave_o     : out t_wishbone_slave_out_array(0 to 2);
      uart_rxd_i  : in  std_logic;
      uart_txd_o  : out std_logic;
      owr_pwren_o : out std_logic_vector(1 downto 0);
      owr_en_o    : out std_logic_vector(1 downto 0);
      owr_i       : in  std_logic_vector(1 downto 0)
      );
  end component;

  -----------------------------------------------------------------------------
  -- Soft-PLL. The very new & splendid one.
  -----------------------------------------------------------------------------
  constant c_xwr_softpll_ng_sdb : t_sdb_device := (
    abi_class     => x"0000",              -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"01",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"7",                 -- 8/16/32-bit port granularity
    sdb_component => (
      addr_first  => x"0000000000000000",
      addr_last   => x"00000000000000ff",
      product     => (
        vendor_id => x"000000000000CE42",  -- CERN
        device_id => x"65158dc0",
        version   => x"00000002",
        date      => x"20120305",
        name      => "WR-Soft-PLL        ")));
  component xwr_softpll_ng
    generic (
      g_tag_bits             : integer;
      g_num_ref_inputs       : integer;
      g_num_outputs          : integer;
      g_with_debug_fifo      : boolean;
      g_with_ext_clock_input : boolean;
      g_reverse_dmtds        : boolean;
      g_divide_input_by_2    : boolean;
      g_ref_clock_rate       : integer;
      g_ext_clock_rate       : integer;
      g_interface_mode       : t_wishbone_interface_mode;
      g_address_granularity  : t_wishbone_address_granularity);
    port (
      clk_sys_i       : in  std_logic;
      rst_n_i         : in  std_logic;
      clk_ref_i       : in  std_logic_vector(g_num_ref_inputs-1 downto 0);
      clk_fb_i        : in  std_logic_vector(g_num_outputs-1 downto 0);
      clk_dmtd_i      : in  std_logic;
      clk_ext_i       : in  std_logic;
      clk_ext_mul_i   : in  std_logic;
      clk_ext_mul_locked_i : in std_logic;
      pps_csync_p1_i  : in  std_logic;
      pps_ext_a_i     : in  std_logic;
      dac_dmtd_data_o : out std_logic_vector(15 downto 0);
      dac_dmtd_load_o : out std_logic;
      dac_out_data_o  : out std_logic_vector(15 downto 0);
      dac_out_sel_o   : out std_logic_vector(3 downto 0);
      dac_out_load_o  : out std_logic;
      out_enable_i    : in  std_logic_vector(g_num_outputs-1 downto 0);
      out_locked_o    : out std_logic_vector(g_num_outputs-1 downto 0);
      out_status_o    : out std_logic_vector(4*g_num_outputs-1 downto 0);
      slave_i         : in  t_wishbone_slave_in;
      slave_o         : out t_wishbone_slave_out;
      debug_o         : out std_logic_vector(5 downto 0);
      dbg_fifo_irq_o  : out std_logic);
  end component;

  constant cc_unused_master_in : t_wishbone_master_in :=
    ('1', '0', '0', '0', '0', cc_dummy_data);


  -----------------------------------------------------------------------------
  -- Public WR component definitions
  -----------------------------------------------------------------------------
  component xwr_core_2p is
    generic(
      g_simulation                : integer                        := 0;
      g_phys_uart                 : boolean                        := true;
      g_virtual_uart              : boolean                        := false;
      g_with_external_clock_input : boolean                        := false;
      g_aux_clks                  : integer                        := 1;
      g_ep_rxbuf_size             : integer                        := 1024;
      g_main_dpram_initf          : string                         := "default";
      g_main_dpram_size           : integer                        := 90112/4;  --in 32-bit words
      g_sec_dpram_size            : integer                        := 90112/4;  --in 32-bit words
      g_interface_mode            : t_wishbone_interface_mode      := PIPELINED;
      g_address_granularity       : t_wishbone_address_granularity := BYTE;
      g_softpll_channels_config   : t_softpll_channel_config_array := c_softpll_default_channel_config;
      g_softpll_enable_debugger   : boolean                        := false;
      g_num_phys									: integer												 :=	2;
      g_ep_with_rtu               : boolean                        := false;
			g_pcs_16bit                 : boolean												 := false;
	    g_tx_runt_padding           : boolean												 := false;
      g_with_flow_control         : boolean												 := false;
      g_extbar_bridge_sdb         : t_sdb_bridge                   := c_empty_bridge_sdb);
    port(
      clk_sys_i  : in std_logic;
      clk_dmtd_i : in std_logic                               := '0';
      clk_ref_i  : in std_logic;
      clk_aux_i  : in std_logic_vector(g_aux_clks-1 downto 0) := (others => '0');

      clk_ext_i  						: in std_logic	:= '0';
			clk_ext_mul_i					: in std_logic	:= '0';
			clk_ext_mul_locked_i	: in std_logic	:= '0';
      pps_ext_i  						: in std_logic	:= '0';
      rst_n_i    						: in std_logic	:= '0';

      phy_rst_n_o  : out std_logic;

      dac_hpll_load_p1_o : out std_logic;
      dac_hpll_data_o    : out std_logic_vector(15 downto 0);
      dac_dpll_load_p1_o : out std_logic;
      dac_dpll_data_o    : out std_logic_vector(15 downto 0);

			phy_ref_clk_i      : in  std_logic                    := '0';

		-- 2 ports WRC.
			phys_o : out t_phyif_output_array(g_num_phys-1 downto 0);
			phys_i : in  t_phyif_input_array(g_num_phys-1 downto 0);

			pll_sync_n_o : out std_logic;

      led_act_o  : out std_logic_vector(1 downto 0);  -- x 2 ports
      led_link_o : out std_logic_vector(1 downto 0);  -- x 2 ports
      scl_o      : out std_logic;
      scl_i      : in  std_logic := 'H';
      sda_o      : out std_logic;
      sda_i      : in  std_logic := 'H';
      gtp0_scl_o  : out std_logic;
      gtp0_scl_i  : in  std_logic := 'H';
      gtp0_sda_o  : out std_logic;
      gtp0_sda_i  : in  std_logic := 'H';
      gtp0_det_i  : in  std_logic := '1';
      gtp1_scl_o  : out std_logic;
      gtp1_scl_i  : in  std_logic := 'H';
      gtp1_sda_o  : out std_logic;
      gtp1_sda_i  : in  std_logic := 'H';
      gtp1_det_i  : in  std_logic := '1';
      btn1_i     : in  std_logic := 'H';
      btn2_i     : in  std_logic := 'H';

      uart_rxd_i : in  std_logic := 'H';
      uart_txd_o : out std_logic;

	    ep0_fc_tx_pause_req_i   : in  std_logic                     := '0';
	    ep0_fc_tx_pause_delay_i : in  std_logic_vector(15 downto 0) := x"0000";
	    ep0_fc_tx_pause_ready_o : out std_logic;

	    ep1_fc_tx_pause_req_i   : in  std_logic                     := '0';
	    ep1_fc_tx_pause_delay_i : in  std_logic_vector(15 downto 0) := x"0000";
	    ep1_fc_tx_pause_ready_o : out std_logic;

      owr_pwren_o : out std_logic_vector(1 downto 0);
      owr_en_o    : out std_logic_vector(1 downto 0);
      owr_i       : in  std_logic_vector(1 downto 0) := "HH";

      slave_i : in  t_wishbone_slave_in := cc_dummy_slave_in;
      slave_o : out t_wishbone_slave_out;

      ext_xb_master_i  : in  t_wishbone_master_in;
      ext_xb_master_o  : out t_wishbone_master_out;

      wrf_src_array_o : out t_wrf_source_out_array(g_num_phys-1 downto 0);
      wrf_src_array_i : in  t_wrf_source_in_array(g_num_phys-1 downto 0);
      wrf_snk_array_o : out t_wrf_sink_out_array(g_num_phys-1 downto 0);
      wrf_snk_array_i : in  t_wrf_sink_in_array(g_num_phys-1 downto 0);

			timestamp_array_o     : out t_txtsu_timestamp_array(g_num_phys-1 downto 0);
    	timestamp_array_ack_i : in  std_logic_vector(g_num_phys-1 downto 0) := (others => '0');

      tm_link_up_o         : out std_logic;
      tm_dac_value_o       : out std_logic_vector(23 downto 0);
      tm_dac_wr_o          : out std_logic_vector(g_aux_clks-1 downto 0);
      tm_clk_aux_lock_en_i : in  std_logic_vector(g_aux_clks-1 downto 0) := (others => '0');
      tm_clk_aux_locked_o  : out std_logic_vector(g_aux_clks-1 downto 0);
      tm_time_valid_o      : out std_logic;
      tm_tai_o             : out std_logic_vector(39 downto 0);
      tm_cycles_o          : out std_logic_vector(27 downto 0);
      pps_p_o              : out std_logic;
      pps_led_o            : out std_logic;

      ep_rtu_info_array_o : out t_ep_rtu_info_array(g_num_phys-1 downto 0);

      rst_aux_n_o : out std_logic;

      link_ok_o : out std_logic;

      set_gm_o        : out std_logic := '0';
      ext_lm32_irq_i  : in std_logic  := '0');
  end component;

  component wr_core_2p is
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
      g_num_phys									: integer												 :=	2;
      g_ep_with_rtu               : boolean                        := false;
			g_pcs_16bit                 : boolean												 := false;
	    g_tx_runt_padding           : boolean												 := false;
      g_with_flow_control         : boolean												 := false;
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
    clk_dmtd_i : in std_logic := '0';

    -- Timing reference (125 MHz)
    clk_ref_i : in std_logic;

    -- Aux clocks (i.e. the FMC clock), which can be disciplined by the WR Core
    clk_aux_i : in std_logic_vector(g_aux_clks-1 downto 0) := (others => '0');


		-- External 10MHz input clock.
    clk_ext_i  						: in std_logic	:= '0';
		clk_ext_mul_i					: in std_logic	:= '0';
		clk_ext_mul_locked_i	: in std_logic	:= '0';

    -- External PPS input (cesium, GPSDO, etc.), used in Grandmaster mode
    pps_ext_i : in std_logic := '0';

    rst_n_i : in std_logic	:= '1';

    -----------------------------------------
    --Timing system
    -----------------------------------------
    dac_hpll_load_p1_o : out std_logic;
    dac_hpll_data_o    : out std_logic_vector(15 downto 0);

    dac_dpll_load_p1_o : out std_logic;
    dac_dpll_data_o    : out std_logic_vector(15 downto 0);

	  -- PHY I/f. These ports are for one port WRC.
	  phy_ref_clk_i : in std_logic;

    -- AD9516 SYNC
    pll_sync_n_o : out std_logic;

		-- 2 ports WRC.
		phys_o : out t_phyif_output_array(g_num_phys-1 downto 0);
		phys_i : in  t_phyif_input_array(g_num_phys-1 downto 0);

    -----------------------------------------
    --GPIO
    -----------------------------------------
    led_act_o  : out std_logic_vector(1 downto 0);  -- x 2 ports
    led_link_o : out std_logic_vector(1 downto 0);  -- x 2 ports
    scl_o      : out std_logic;
    scl_i      : in  std_logic := '1';
    sda_o      : out std_logic;
    sda_i      : in  std_logic := '1';
    gtp0_scl_o  : out std_logic;
    gtp0_scl_i  : in  std_logic := '1';
    gtp0_sda_o  : out std_logic;
    gtp0_sda_i  : in  std_logic := '1';
    gtp0_det_i  : in  std_logic := '1';
    gtp1_scl_o  : out std_logic;
    gtp1_scl_i  : in  std_logic := '1';
    gtp1_sda_o  : out std_logic;
    gtp1_sda_i  : in  std_logic := '1';
    gtp1_det_i  : in  std_logic := '1';
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
    --External WB interface. Single Line. EB?
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
    ext_xb_master_i  : in  t_wishbone_master_in;
    ext_xb_master_o  : out t_wishbone_master_out;

    -----------------------------------------
    -- Timecode/Servo Control
    -----------------------------------------

    tm_link_up_o         : out std_logic;

    tm_dac_value_o       : out std_logic_vector(23 downto 0);
    tm_dac_wr_o          : out std_logic_vector(g_aux_clks-1 downto 0) ;
    tm_clk_aux_lock_en_i : in  std_logic_vector(g_aux_clks-1 downto 0) := (others => '0');
    tm_clk_aux_locked_o  : out std_logic_vector(g_aux_clks-1 downto 0) ;

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
    ext_lm32_irq_i  : in std_logic := '0');
  end component;

  component spec_serial_dac_arb
    generic(
      g_invert_sclk    : boolean;
      g_num_extra_bits : integer);
    port (
      clk_i       : in  std_logic;
      rst_n_i     : in  std_logic;
      val1_i      : in  std_logic_vector(15 downto 0);
      load1_i     : in  std_logic;
      val2_i      : in  std_logic_vector(15 downto 0);
      load2_i     : in  std_logic;
      dac_cs_n_o  : out std_logic_vector(1 downto 0);
      dac_clr_n_o : out std_logic;
      dac_sclk_o  : out std_logic;
      dac_din_o   : out std_logic);
  end component;

end wrcore_2p_pkg;

package body wrcore_2p_pkg is

function f_xwb_bridge_product_manual_sdb(
    g_size       : t_wishbone_address;
    g_sdb_addr   : t_wishbone_address;
    g_sdb_product: t_sdb_product) return t_sdb_bridge
  is
    variable result : t_sdb_bridge;
  begin
    result.sdb_child := (others => '0');
    result.sdb_child(c_wishbone_address_width-1 downto 0) := g_sdb_addr;
    result.sdb_component.addr_first := (others => '0');
    result.sdb_component.addr_last  := (others => '0');
    result.sdb_component.addr_last(c_wishbone_address_width-1 downto 0) := g_size;
    result.sdb_component.product.vendor_id := g_sdb_product.vendor_id; -- GSI
    result.sdb_component.product.device_id := g_sdb_product.device_id;
    result.sdb_component.product.version   := g_sdb_product.version;
    result.sdb_component.product.date      := g_sdb_product.date;
    result.sdb_component.product.name      := g_sdb_product.name;

    return result;

  end f_xwb_bridge_product_manual_sdb;

  function f_xwb_bridge_product_layout_sdb(
    g_wraparound  : boolean := true;
    g_layout      : t_sdb_record_array;
    g_sdb_addr    : t_wishbone_address;
    g_sdb_product: t_sdb_product) return t_sdb_bridge
  is
    alias c_layout : t_sdb_record_array(g_layout'length-1 downto 0) is g_layout;
    -- How much space does the ROM need?
    constant c_used_entries : natural := c_layout'length + 1;
    constant c_rom_entries  : natural := 2**f_ceil_log2(c_used_entries); -- next power of 2
    constant c_sdb_bytes   : natural := c_sdb_device_length / 8;
    constant c_rom_bytes    : natural := c_rom_entries * c_sdb_bytes;

    -- Step 2. Find the size of the bus

    function f_bus_end return unsigned is
      variable result : unsigned(63 downto 0);
      variable sdb_component : t_sdb_component;
    begin
      if not g_wraparound then
        result := (others => '0');
        for i in 0 to c_wishbone_address_width-1 loop
          result(i) := '1';
        end loop;
      else
        -- The ROM will be an addressed slave as well
        result := (others => '0');
        result(c_wishbone_address_width-1 downto 0) := unsigned(g_sdb_addr);
        result := result + to_unsigned(c_rom_bytes, 64) - 1;

        for i in c_layout'range loop
          sdb_component := f_sdb_extract_component(c_layout(i)(447 downto 8));
          if unsigned(sdb_component.addr_last) > result then
            result := unsigned(sdb_component.addr_last);
          end if;
        end loop;

        -- round result up to a power of two -1

        for i in 62 downto 0 loop
          result(i) := result(i) or result(i+1);
        end loop;

      end if;

      return result;

    end f_bus_end;

    constant bus_end : unsigned(63 downto 0) := f_bus_end;
  begin

    return f_xwb_bridge_product_manual_sdb(std_logic_vector(f_bus_end(c_wishbone_address_width-1 downto 0)), g_sdb_addr, g_sdb_product);

  end f_xwb_bridge_product_layout_sdb;

end wrcore_2p_pkg;
