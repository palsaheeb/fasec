----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/29/2016 07:05:52 PM
-- Design Name: 
-- Module Name: top_mod - rtl
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_mod is
    Port ( clk_i : in STD_LOGIC;
           pb_gp_i : in STD_LOGIC;
           led_col_pl_o : out STD_LOGIC_VECTOR (3 downto 0);
           led_line_en_pl_o : out STD_LOGIC;
           led_line_pl_o : out STD_LOGIC);
end top_mod;

architecture rtl of top_mod is
begin

p_leds: process(clk_i)
    variable v_pbreg : std_logic_vector(2 downto 0) := (others=>'0');
begin
    if rising_edge(clk_i) then
        v_pbreg(2 downto 0) := v_pbreg(1 downto 0) & pb_gp_i;
        if v_pbreg(2)='1' then
            led_line_en_pl_o <= '1';
            led_line_pl_o <= '0';
            led_col_pl_o <= "1111";
        else
            led_line_en_pl_o <= '0';
            led_line_pl_o <= '1';
            led_col_pl_o <= "0000";
        end if;    
    end if;
end process;
    

end rtl;
