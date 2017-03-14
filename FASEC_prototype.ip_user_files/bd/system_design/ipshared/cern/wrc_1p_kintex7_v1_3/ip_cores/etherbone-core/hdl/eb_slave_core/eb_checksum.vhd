--! @file EB_checksum.vhd
--! @brief IP checksum generator for EtherBone
--!
--! Copyright (C) 2011-2012 GSI Helmholtz Centre for Heavy Ion Research GmbH 
--!
--! Important details about its implementation
--! should go in these comments.
--!
--! @author Mathias Kreider <m.kreider@gsi.de>
--!
--! @bug No know bugs.
--!
--------------------------------------------------------------------------------
--! This library is free software; you can redistribute it and/or
--! modify it under the terms of the GNU Lesser General Public
--! License as published by the Free Software Foundation; either
--! version 3 of the License, or (at your option) any later version.
--!
--! This library is distributed in the hope that it will be useful,
--! but WITHOUT ANY WARRANTY; without even the implied warranty of
--! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
--! Lesser General Public License for more details.
--!  
--! You should have received a copy of the GNU Lesser General Public
--! License along with this library. If not, see <http://www.gnu.org/licenses/>.
---------------------------------------------------------------------------------

---! Standard library
library IEEE;
--! Standard packages    
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--! Additional library
library work;
--! Additional packages    
use work.EB_HDR_PKG.all;

entity EB_checksum is
port(
		clk_i	: in std_logic;
		nRst_i	: in std_logic;
		
		en_i	: in std_logic; 
		data_i	: in std_logic_vector(15 downto 0);
		
		done_o	: out std_logic;
		sum_o	: out std_logic_vector(15 downto 0)
);
end EB_checksum;

architecture behavioral of EB_checksum is

constant c_width_int : integer := 28;

type st is (IDLE, ADDUP, CARRIES, FINALISE, OUTPUT);

signal state 	: st := IDLE;
signal sum  	: unsigned(c_width_int-1 downto 0);
signal data 	: std_logic_vector(15 downto 0);

begin

adder: process(clk_i)
begin
	if rising_edge(clk_i) then
       --==========================================================================
	   -- SYNC RESET                         
       --========================================================================== 
		if (nRST_i = '0') then
			done_o 	<= '0';
			sum 	<= (others => '0');	
			state 		<= IDLE;	
			
		else
			--register input data
			data <= data_i;
			sum_o <= NOT(std_logic_vector(sum(15 downto 0)));
			
			case state is 
				when IDLE 		=> 	--clear internal states and output
									done_o 	<= '0';
									sum 	<= (others => '0');									
									
									-- if enable flag is set, start checksum generation
									if(en_i = '1') then
										state <= ADDUP;
									end if;
				
				when ADDUP 	  	=> 	-- add up all incoming 16 bit words
									sum <= sum + resize(unsigned(data), c_width_int);
									
									-- end of data block. add carry bits from hi word to low word
									if(en_i = '0') then
										state <= CARRIES;
									end if;
				
				when CARRIES 	=>	sum <= resize(sum(15 downto 0), c_width_int) + resize(sum(c_width_int-1 downto 16), c_width_int);
									state <= FINALISE;
				
				when FINALISE 	=>	-- add carry bits from hi word to low word again, in case last sum produced overflow
									sum <= resize(sum(15 downto 0), c_width_int) + resize(sum(c_width_int-1 downto 16), c_width_int);
									state <= OUTPUT;
				
				when OUTPUT		=>  -- invert sum lo word, write to output. assert done flag
									done_o <= '1';
									state  <= IDLE;
				
				when others 	=> 	state <= IDLE;
			end case;
		end if;
	end if;    
	
end process;

end behavioral;
