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

use IEEE.NUMERIC_STD.ALL;

entity fasec_hwtest is
    Port ( clk_i : in STD_LOGIC;        -- 1oo MHz
           pb_gp_n_i : in STD_LOGIC;
           led_col_pl_o : out STD_LOGIC_VECTOR (3 downto 0);    -- anode green / cathode red
           led_line_en_pl_o : out STD_LOGIC;        -- output 1B Hi-Z when asserted
           led_line_pl_o : out STD_LOGIC);          -- output 1B: cathode green / anode red
end fasec_hwtest;

architecture rtl of fasec_hwtest is
    constant c_FLASH : positive := 10000000;    -- 100 ms @ 100 MHz
begin

p_leds: process(clk_i)
    variable v_pbreg : std_logic_vector(2 downto 0) := (others=>'0');
    variable v_cntr : unsigned(31 downto 0) := (others=>'0');
    variable v_tick : std_logic;
begin
    if rising_edge(clk_i) then
        if (to_integer(v_cntr) < c_FLASH) then
            v_cntr := v_cntr + 1;
        else
            v_cntr := to_unsigned(0,v_cntr'length);
            v_tick := not v_tick;
        end if;    
        v_pbreg(2 downto 0) := v_pbreg(1 downto 0) & pb_gp_n_i;
        if v_pbreg(2)='1' then
            led_line_en_pl_o <= v_tick;
            led_line_pl_o <= '0';
            led_col_pl_o(3 downto 0) <= "1111";
        else
            led_line_en_pl_o <= '1';
            led_line_pl_o <= '1';
            led_col_pl_o(3 downto 0) <= "0000";
        end if;    
    end if;
end process;
    

end rtl;
