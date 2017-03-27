----------------------------------------------------------------------------------
-- Company: /
-- Engineer:  pvantrap
-- 
-- Create Date:    30/11/2014 
-- Design Name:  Clock Divider
-- Module Name:  ClockDiv - rtl 
-- Project Name:  /
-- Description: Simple clock divider which has a genereric to specify the dividing factor
--  g_FACTOR = freq clk_in / freq clk_out
--  e.g. with a 32 MHz clock and g_FACTOR 32 000 000 a 1Hz clock will be generated
-- Dependencies: 
--
-- Revision: 0.01
-- Revision 0.01 - File Created
-- Additional Comments: 
--
-- TODO:
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library UNISIM;
use UNISIM.VComponents.all;

--=============================================================================
-- Entity declaration for clockDivider
--=============================================================================
entity clockDivider is
  generic (
    g_FACTOR      : integer range 0 to integer'high;  -- 32 bit
    g_START_LEVEL : std_logic := '0');
  port (
    clk_system_i : in  std_logic;
    reset_i      : in  std_logic;
    clk_div_o    : out std_logic);
end clockDivider;

--=============================================================================
-- architecture declaration
--=============================================================================
architecture rtl of clockDivider is
  signal s_counter : integer   := 0;
  signal s_temp    : std_logic := '1';
--=============================================================================
-- architecture begin
--=============================================================================
begin
  cmp_BUFG : BUFG                       -- bufg primitive to avoid excessive skew on generated clock signals (could lead to PAR warning)
    port map (
      O => clk_div_o,
      I => s_temp
      );

  p_clkGeneration : process(clk_system_i, reset_i)
    constant c_CNTR_MAX : integer := (g_FACTOR/2)-1;
  begin
    if reset_i = '1' then
      s_counter <= 0;
      s_temp    <= g_START_LEVEL;
    elsif rising_edge(clk_system_i) then  -- 15999999 for 1Hz but I've increased it to 4Hz
      s_counter <= s_counter + 1;
      if (s_counter = c_CNTR_MAX) then    -- 32Mhz clock on board
        s_temp    <= not s_temp;
        s_counter <= 0;
      end if;
    end if;
  end process p_clkGeneration;


end rtl;
--=============================================================================
-- architecture end
--=============================================================================
