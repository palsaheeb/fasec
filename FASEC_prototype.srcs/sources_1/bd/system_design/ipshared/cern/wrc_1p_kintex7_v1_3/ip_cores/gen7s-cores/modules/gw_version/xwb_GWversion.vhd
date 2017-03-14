--==============================================================================
--! @file xwb_GWversion.vhd
--==============================================================================

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- Wishbone crossbar for DDR3 memory user interface
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--! @brief
--! HW implementation of a WB crossbar connection between Wishbone slave and Diagnostic controller.
---------------------------------------------------------------------------------------------------
--! @details
--!
---------------------------------------------------------------------------------------------------
--! @version
--! 0.1 | mc | 2.08.2013 
--! 0.2 | ac | 22.04.2014 
--!
--! @author
--! mc : Miguel Mendez, Seven Solutions SL
--! oc : Benoit Rat, Seven Solutions SL
---------------------------------------------------------------------------------------------------
--=================================================================================================
--                                      Libraries & Packages
--=================================================================================================
--! Standard library
library IEEE;
--! Standard packages
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
--! Specific packages
library work;
use work.wishbone_pkg.all;

--==============================================================================
-- Entity declaration for Test setup core (xwb_GWversion)
--==============================================================================
entity xwb_GWversion is
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
end xwb_GWversion;
--=================================================================================================
-- Architecture declaration 
--=================================================================================================
architecture rtl of xwb_GWversion is

  component wb_Version_port is
  port (
    rst_n_i                                  : in     std_logic;
    clk_sys_i                                : in     std_logic;
    wb_adr_i                                 : in     std_logic_vector(1 downto 0);
    wb_dat_i                                 : in     std_logic_vector(31 downto 0);
    wb_dat_o                                 : out    std_logic_vector(31 downto 0);
    wb_cyc_i                                 : in     std_logic;
    wb_sel_i                                 : in     std_logic_vector(3 downto 0);
    wb_stb_i                                 : in     std_logic;
    wb_we_i                                  : in     std_logic;
    wb_ack_o                                 : out    std_logic;
    wb_stall_o                               : out    std_logic;
-- Port for std_logic_vector field: 'Board Identification' in reg: 'Board identification'
    wb2ver_board_id_i                        : in     std_logic_vector(31 downto 0);
-- Port for std_logic_vector field: 'GW Build' in reg: 'GW version'
    wb2ver_gw_ver_build_i                    : in     std_logic_vector(15 downto 0);
-- Port for std_logic_vector field: 'Minor GW version' in reg: 'GW version'
    wb2ver_gw_ver_minor_i                    : in     std_logic_vector(7 downto 0);
-- Port for std_logic_vector field: 'Major GW version' in reg: 'GW version'
    wb2ver_gw_ver_major_i                    : in     std_logic_vector(7 downto 0);
-- Port for std_logic_vector field: 'Minute' in reg: 'Synthetisation Date'
    wb2ver_syn_date_sec_i                    : in     std_logic_vector(5 downto 0);
-- Port for std_logic_vector field: 'Hour' in reg: 'Synthetisation Date'
    wb2ver_syn_date_hour_i                   : in     std_logic_vector(4 downto 0);
-- Port for std_logic_vector field: 'Day' in reg: 'Synthetisation Date'
    wb2ver_syn_date_day_i                    : in     std_logic_vector(4 downto 0);
-- Port for std_logic_vector field: 'Month' in reg: 'Synthetisation Date'
    wb2ver_syn_date_month_i                  : in     std_logic_vector(3 downto 0);
-- Port for std_logic_vector field: 'Year' in reg: 'Synthetisation Date'
    wb2ver_syn_date_year_i                   : in     std_logic_vector(6 downto 0);
-- Port for std_logic_vector field: 'Test' in reg: 'Synthetisation Date'
    wb2ver_syn_date_test_o                   : out    std_logic_vector(3 downto 0);
    wb2ver_syn_date_test_i                   : in     std_logic_vector(3 downto 0);
    wb2ver_syn_date_test_load_o              : out    std_logic
  );
  end component;


  --- Signals declaration
  constant c_hour_min_vector	: std_logic_vector(15 downto 0):= "0000001000101010";
  constant c_date_vector        : std_logic_vector(15 downto 0):= "0110100110010001";
  constant c_GW_compilation		: std_logic_vector(15 downto 0):= "0000000000000011";
  
  signal   s_date_test_reg      : std_logic_vector(3 downto 0);
  signal   s_date_test_o        : std_logic_vector(3 downto 0);
  signal   s_date_test_load_o   : std_logic;

--==============================================================================
-- Architecure begin
--==============================================================================
begin  -- rtl
  

  Wrapped_GWversion : wb_Version_port 
  port map(
    rst_n_i           => wb_rst_n_i,
    clk_sys_i         => wb_clk_i,
    wb_adr_i          => slave_i.adr(3 downto 2), -- BAD HACK
    wb_dat_i          => slave_i.dat(31 downto 0),
    wb_dat_o          => slave_o.dat(31 downto 0),
    wb_cyc_i          => slave_i.cyc,
    wb_sel_i          => slave_i.sel,
    wb_stb_i          => slave_i.stb,
    wb_we_i           => slave_i.we,
    wb_ack_o          => slave_o.ack,
    wb_stall_o        => slave_o.stall,
    -- Port for std_logic_vector field: 'Board Identification' in reg: 'Board identification'
    wb2ver_board_id_i      => g_board_id,
    -- Port for std_logic_vector field: 'GW Build' in reg: 'GW version'
    wb2ver_gw_ver_build_i  => c_GW_compilation,
    -- Port for std_logic_vector field: 'Minor GW version' in reg: 'GW version'
    wb2ver_gw_ver_minor_i  => std_logic_vector(to_unsigned(g_ver_minor,8)),
   -- Port for std_logic_vector field: 'Major GW version' in reg: 'GW version'
    wb2ver_gw_ver_major_i  => std_logic_vector(to_unsigned(g_ver_major,8)),
    -- Port for std_logic_vector field: 'Minute' in reg: 'Synthetisation Date'
    wb2ver_syn_date_sec_i  => c_hour_min_vector(5 downto 0),
-- Port for std_logic_vector field: 'Hour' in reg: 'Synthetisation Date'
    wb2ver_syn_date_hour_i  => c_hour_min_vector(10 downto 6),
-- Port for std_logic_vector field: 'Day' in reg: 'Synthetisation Date'
    wb2ver_syn_date_day_i   => c_date_vector(15 downto 11),
-- Port for std_logic_vector field: 'Month' in reg: 'Synthetisation Date'
    wb2ver_syn_date_month_i => c_date_vector(10 downto 7),
-- Port for std_logic_vector field: 'Year' in reg: 'Synthetisation Date'
    wb2ver_syn_date_year_i  => c_date_vector(6 downto 0),
-- Port for std_logic_vector field: 'Test' in reg: 'Synthetisation Date'
    wb2ver_syn_date_test_i  => s_date_test_reg
  );
   -- WB Output
   slave_o.err   <= '0';
   slave_o.int   <= '0';
   slave_o.rty   <= '0';
    
    --For debugging purpose we use a read/write register
    process(wb_clk_i)
    begin
        if rising_edge(wb_clk_i) and s_date_test_load_o = '1' then
            s_date_test_reg <= s_date_test_o;
        end if;
    end process;
    
end rtl;
