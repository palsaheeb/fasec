library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.wishbone_pkg.all;

package gen7s_cores_pkg is

  component ext_pll_10_to_62_compensated is
    port(
		ext_clk_i             : in std_logic;
		rst_n_i               : in std_logic;
    gm_en_i               : in std_logic;
		pps_i                 : in std_logic;
		clk_ext_mul_o	        : out std_logic;
		clk_ext_mul_locked_o	: out std_logic);
  end component ext_pll_10_to_62_compensated;

  component second_counter is
    generic(
      g_cntr_period : integer);
    port (
      clk_sys_i     : in std_logic;
      rst_n_i       : in std_logic;
      second_o      : out std_logic_vector(5 downto 0);
      scnd_begins_o : out std_logic);
  end component;

  -- From the EP.
  type t_ep_rtu_info is record
    valid    : std_logic;
    smac     : std_logic_vector(47 downto 0);
    dmac     : std_logic_vector(47 downto 0);
    vid      : std_logic_vector(11 downto 0);
    has_vid  : std_logic;
    prio     : std_logic_vector(2 downto 0);
    has_prio : std_logic;
  end record;
  type t_ep_rtu_info_array is array(integer range <>) of t_ep_rtu_info;

  -- From the requesting module
  type t_forwarding_rtu_request is record
    valid    : std_logic;
    smac     : std_logic_vector(47 downto 0);
    dmac     : std_logic_vector(47 downto 0);
  end record;
  type t_forwarding_rtu_request_array is array(integer range <>) of t_forwarding_rtu_request;
  constant c_empty_forwarding_request : t_forwarding_rtu_request := ('0', (others => '0'), (others => '0'));

  -- Response to the requesting module.
  type t_forwarding_rtu_response is record
    send_here : std_logic;
    valid     : std_logic;
  end record;
	type t_forwarding_rtu_response_array is array(integer range <>) of t_forwarding_rtu_response;
  constant c_empty_forwarding_response    : t_forwarding_rtu_response := ('0', '0');  --Don't send it here either it's valid.
  constant c_complete_forwarding_response : t_forwarding_rtu_response := ('1', '1');  --Send it here as well as it's valid

  -- Constants to define the match words for the ETH multiplexer.
  constant c_to_ep0_mw    : std_logic_vector( 7 downto 0 ) := x"07";
  constant c_to_ep1_mw    : std_logic_vector( 7 downto 0 ) := x"E0";
  constant c_broadcast_mw : std_logic_vector( 7 downto 0 ) := x"18";

  -- Types to store the age & mac from ETH RTU entries.
  type t_mac_array is array(integer range <>) of std_logic_vector(47 downto 0);
  type t_age_array is array(integer range <>) of std_logic_vector(5 downto 0);


  constant c_xwb_gw_ver_sdb : t_sdb_device := (
  	abi_class => x"0000",
  	abi_ver_major => x"01",
  	abi_ver_minor => x"01",
  	wbd_endian    => c_sdb_endian_big,
  	wbd_width     => x"7",
  	sdb_component => (
  	addr_first  => x"0000000000000000",
  	addr_last   => x"00000000000000ff",
  	product     => (
  	vendor_id => x"0000000000007501",  -- 7 Sols
  	device_id => x"c1f77c10",          -- echo -n "xwb_GWversion" | md5sum - | cut -c1-8
  	version   => x"00000001",
  	date      => x"20151002",
  	name      => "WB GW Version      ")));

    component xwb_GWversion
    generic(
    	-- WB crossbar
    	g_interface_mode         : t_wishbone_interface_mode      := CLASSIC;
    	g_address_granularity    : t_wishbone_address_granularity := WORD;

    	-- Version configuration
    	g_board_id				 : std_logic_vector(31 downto 0) := x"F155CB00";
    	g_ver_major				 : integer                       := 1;
    	g_ver_minor				 : integer                       := 0;

    	-- Wishbone address width
    	g_WB_ADDR_SIZE : integer := 32;
    	-- Wishbone data width
    	g_WB_DATA_SIZE : integer := 32;
    	-- Wishbone data mask size
    	g_WB_MASK_SIZE : integer := (32/8)
    );
    port(
    	----------------------------------------------------------------------------
    	-- Wishbone Crossbar Slave implementation
    	----------------------------------------------------------------------------
    	---Clock signals
    	wb_clk_i          : in  std_logic;
    	wb_rst_n_i        : in  std_logic;
    	---Wishbone slave
    	slave_i : in  t_wishbone_slave_in;
    	slave_o : out t_wishbone_slave_out
    );
    end component;

end gen7s_cores_pkg;
