---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- DDR3 Package File 
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--! @brief
--! DDR3 Package File .
---------------------------------------------------------------------------------------------------
--! @details
--! This package defines supplemental types, subtypes, constants, and functions of DDR3 controller.
--!
---------------------------------------------------------------------------------------------------
--! @version
--! 0.1 | mc | 12.06.2013 
--!
--! @author
--! mc : Miguel Mendez, Seven Solutions SL
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package PLL_SPI_ctrl_pkg is

  -----------------------------------------------------------------------------
  -- Functions and constants declaration
  -----------------------------------------------------------------------------
  
  -----------------------------------------------------------------------------
  -- Constants declaration
  -----------------------------------------------------------------------------
  constant c_NUM_SPI_REGISTERS    : integer := 68;
  -- Wishbone address width
  constant c_ADDR_PORT_SIZE : integer := 5;
  -- Wishbone data width
  constant c_DATA_PORT_SIZE : integer := 32;
  -- Wishbone data mask size
  constant c_MASK_SIZE : integer := 4;
  
  constant Low    : std_logic	:= '0';
  constant High   : std_logic	:= '1';
  
  
  -- Array data where masters and slaves read and write
  --type t_data_array is array(c_NUM_SPI_REGISTERS-1 downto 0) of integer;
  type t_data_array_data is array(0 to c_NUM_SPI_REGISTERS-1) of std_logic_Vector(7 downto 0);
  type t_data_array is array(0 to c_NUM_SPI_REGISTERS-1) of integer;

------------------------------------------------------------------------------
-- Components declaration
-------------------------------------------------------------------------------
 
  component PLL_AD9516_ctrl_top is
    generic (
      g_data_master1   : t_data_array_data   := (others=>(others=>'0'));
      g_addr_master1   : t_data_array        := (others=> 0)
    );

    port ( clk_i        : in  std_logic;
           --clk_p_i    : in  std_logic;
           --clk_n_i    : in  std_logic;
           rst_n_i      : in  std_logic;

           --- Debug signals
           FP_LEDN0     : out std_logic;
           FP_LEDN1     : out std_logic;
           --SI57X_CLK_N : in  std_logic;
           --SI57X_CLK_P : in  std_logic;

           --- PLL status/control
           PLL_LOCK_i   : in std_logic;
           PLL_RESET    : out std_logic;
           PLL_STAT_i   : in std_logic;
           PLL_REFSEL_o : out std_logic;
           PLL_SYNC_n_o : out std_logic;

           -- SPI bus - PLL control
           PLL_CS_n_o  : out std_logic;
           PLL_SCLK_o  : out std_logic;
           PLL_SDI_o   : out std_logic;
           PLL_SDO_i   : in std_logic;
 
           -- SPI controller status
           core_enable_i    : in std_logic;
           core_done_o      : out std_logic;
           core_error_o     : out std_logic
         );
  end component;


-- type <new_type> is
--  record
--    <type_name>        : std_logic_vector( 7 downto 0);
--    <type_name>        : std_logic;
-- end record;
--
-- Declare constants
--
-- constant <constant_name>		: time := <time_unit> ns;
-- constant <constant_name>		: integer := <value;
--
-- Declare functions and procedure
--
-- function <function_name>  (signal <signal_name> : in <type_declaration>) return <type_declaration>;
-- procedure <procedure_name> (<type_declaration> <constant_name>	: in <type_declaration>);
--


end PLL_SPI_ctrl_pkg;

package body PLL_SPI_ctrl_pkg is

---- Example 1
--  function <function_name>  (signal <signal_name> : in <type_declaration>  ) return <type_declaration> is
--    variable <variable_name>     : <type_declaration>;
--  begin
--    <variable_name> := <signal_name> xor <signal_name>;
--    return <variable_name>; 
--  end <function_name>;

---- Example 2
--  function <function_name>  (signal <signal_name> : in <type_declaration>;
--                         signal <signal_name>   : in <type_declaration>  ) return <type_declaration> is
--  begin
--    if (<signal_name> = '1') then
--      return <signal_name>;
--    else
--      return 'Z';
--    end if;
--  end <function_name>;

---- Procedure Example
--  procedure <procedure_name>  (<type_declaration> <constant_name>  : in <type_declaration>) is
--    
--  begin
--    
--  end <procedure_name>;
 
end PLL_SPI_ctrl_pkg;
