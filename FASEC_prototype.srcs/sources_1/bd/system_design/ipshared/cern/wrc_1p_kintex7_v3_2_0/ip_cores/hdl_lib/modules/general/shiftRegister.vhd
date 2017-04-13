----------------------------------------------------------------------------------
-- Company: /
-- Engineer:  pvantrap
-- 
-- Create Date:    07/12/2014 
-- Design Name:  shift register
-- Module Name:  shiftRegister - rtl 
-- Project Name:  /
-- Target Devices: Papilio One 500k + LogicStart Megawing
-- Tool versions: ISE 14.7
-- Tool platform: x86_64 GNU/Linux (Fedora, kernel 3.16.6)
-- Description: Simple multifunctional shitfregister, based on the TI SN54198
-- see http://www.ti.com/lit/ds/symlink/sn74199.pdf
-- mode_i		s1s0
--								1 1 : parallel load
--								0 0 : inhibit clock (i.e. do nothing)
--								0 1 : shift right synchronously
--								1 0 : shift left synchronously

-- Dependencies: 
--
-- Revision: 0.01
-- Revision 0.01 - File Created
-- Additional Comments: 
--
-- TODO:
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity shiftRegister is
    Generic(
			g_DATA_WIDTH 		: natural range 1 to 32:= 8;
			g_DEFAULT : std_logic := '0' 														-- reset value for internal buffers
		);
		Port ( clear_n_i : in  STD_LOGIC;
           mode_i : in  STD_LOGIC_VECTOR (1 downto 0);
           serialLoadLeft_i : in  STD_LOGIC;
           serialLoadRight_i : in  STD_LOGIC;
					 clk_i	: in std_logic;
           parallelLoad_i : in  STD_LOGIC_VECTOR (g_DATA_WIDTH-1 downto 0)	:= (others=>g_DEFAULT);
           outputs_o : out  STD_LOGIC_VECTOR (g_DATA_WIDTH-1 downto 0) := (others=>g_DEFAULT)
		);
end shiftRegister;

architecture rtl of shiftRegister is
	signal s_register : std_logic_vector(g_DATA_WIDTH-1 downto 0);
begin
	-- assign internal register ot outputs
	outputs_o(g_DATA_WIDTH-1 downto 0) <=  s_register(g_DATA_WIDTH-1 downto 0);
	
	-- shift process
	p_shift: process(clear_n_i, mode_i, clk_i)
	begin
		if clear_n_i = '0' then			-- asynchronous clearing
			s_register(g_DATA_WIDTH-1 downto 0) <= (others =>g_DEFAULT);
		elsif mode_i = "00" then		-- asynchronous inhibit clock
			s_register(g_DATA_WIDTH-1 downto 0) <= s_register(g_DATA_WIDTH-1 downto 0);
		elsif rising_edge(clk_i) then
			case mode_i(1 downto 0) is
				when "11" => s_register(g_DATA_WIDTH-1 downto 0) <= parallelLoad_i(g_DATA_WIDTH-1 downto 0);		-- load
				when "01" => s_register(g_DATA_WIDTH-1 downto 0) <= serialLoadRight_i & s_register(g_DATA_WIDTH-1 downto 1);				-- shift right
				when "10" => s_register(g_DATA_WIDTH-1 downto 0) <= s_register(g_DATA_WIDTH-2 downto 0) & serialLoadLeft_i;				-- shift left
				when others => s_register(g_DATA_WIDTH-1 downto 0)  <= s_register(g_DATA_WIDTH-1 downto 0) ;		-- should never happen
			end case;
		end if;
	end process p_shift;

end rtl;

