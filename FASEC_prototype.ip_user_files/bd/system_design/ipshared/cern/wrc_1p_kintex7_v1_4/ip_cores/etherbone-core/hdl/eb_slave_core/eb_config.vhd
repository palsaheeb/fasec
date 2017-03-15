--! @file EB_config.vhd
--! @brief EtherBone config space memory
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


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.wishbone_pkg.all;

entity eb_config is 
 generic(
   g_sdb_address : std_logic_vector(63 downto 0));
 port(
		clk_i    		     : in std_logic;                                        --clock
    nRST_i       		 : in std_logic;
		status_i		      : in std_logic;
		status_en		     : in	std_logic;
		status_clr		    : in	std_logic;
		
		my_mac_o  : out std_logic_vector(6*8-1 downto 0);
		my_ip_o   : out std_logic_vector(4*8-1 downto 0);
		my_port_o   : out std_logic_vector(2*8-1 downto 0);
		
		local_slave_o   : out t_wishbone_slave_out;
		local_slave_i   : in t_wishbone_slave_in;	--! local Wishbone master lines
				
		eb_slave_o      : out t_wishbone_slave_out;	--! EB Wishbone slave lines
		eb_slave_i      : in  t_wishbone_slave_in
    );
end eb_config;


architecture behavioral of eb_config is

subtype dword is std_logic_vector(31 downto 0);
type mem is array (0 to 2) of dword ; 
signal my_mem : mem;



signal eb_adr : natural; 
signal local_adr : natural; 
signal local_write_reg : std_logic_vector(31 downto 0);


signal status_reg : std_logic_vector(63 downto 0);
signal p_auto_cfg : std_logic_vector(63 downto 0);

signal my_mac : std_logic_vector(6*8-1 downto 0);
signal my_ip : std_logic_vector(4*8-1  downto 0);
signal my_port : std_logic_vector(2*8-1  downto 0);

constant c_my_default_mac 	: std_logic_vector(6*8-1  downto 0) 	:= x"D15EA5EDBEEF";
constant c_my_default_ip 	: std_logic_vector(4*8-1  downto 0) 	:= x"C0A80064";
constant c_my_default_port 	: std_logic_vector(2*8-1  downto 0) 	:= x"EBD0";

begin
 



eb_adr <= to_integer(unsigned(eb_slave_i.ADR(7 downto 2)) & "00");
local_adr <= to_integer(unsigned(local_slave_i.ADR(7 downto 2)) & "00");

my_mac_o <= my_mac;
my_ip_o <= my_ip;
my_port_o <= my_port;

local_slave_o.STALL <= eb_slave_i.CYC;
local_slave_o.INT <= '0';
local_slave_o.RTY	<= '0';

	
eb_if	:	process (clk_i)
  begin
	if (clk_i'event and clk_i = '1') then
		if(nRSt_i = '0') then

		
		    
		    eb_slave_o	<=   (
					  ACK   => '0',
					  ERR   => '0',
					  RTY   => '0',
					  STALL => '0',
					  INT => '0',
					  DAT   => (others => '0'));
		    
		    local_slave_o.ACK	<= '0';
		    local_slave_o.ERR	<= '0';

		    local_slave_o.DAT	<= (others => '0');
		    
			my_ip   <= c_my_default_ip;
			my_mac  <= c_my_default_mac;
			my_port <= c_my_default_port;	
      p_auto_cfg <= g_sdb_address;
			  
		else
			eb_slave_o.ACK    <= eb_slave_i.CYC AND eb_slave_i.STB;
			
			if(eb_slave_i.STB = '1' AND eb_slave_i.CYC = '1') then 
	      
				if(eb_slave_i.WE ='1') then
					case eb_adr is
						when 0	     => null;
						when 16		    => my_mac(47 downto 16) <= eb_slave_i.DAT(31 downto 0);
						when 20		    => my_mac(15 downto 0) <= eb_slave_i.DAT(31 downto 16);
						when 24		    => my_ip <= eb_slave_i.DAT;
						when 28		   => my_port 		<= eb_slave_i.DAT(31 downto 16);   
						when others => null;
					end case;	
				else
					case eb_adr is
						when 0		    => eb_slave_o.DAT <= status_reg(63 downto 32);
						when 4		    => eb_slave_o.DAT <= status_reg(31 downto 0);
						when 8		    => eb_slave_o.DAT <= p_auto_cfg(63 downto 32);
						when 12		    => eb_slave_o.DAT <= p_auto_cfg(31 downto 0);
						when 16		    => eb_slave_o.DAT <= my_mac(47 downto 16);
						when 20		    => eb_slave_o.DAT <= (my_mac(15 downto 0) & std_logic_vector(to_unsigned(0, 16)));
						when 24		    => eb_slave_o.DAT <= my_ip;
						when 28		   => eb_slave_o.DAT 		<= my_port & std_logic_vector(to_unsigned(0, 16));    
						   
						when others => eb_slave_o.DAT <= status_reg(63 downto 32);
					end case;	
				end if;	
			end if;

        		local_slave_o.ACK <= local_slave_i.STB  AND local_slave_i.CYC  AND NOT eb_slave_i.CYC;
        		
			if(local_slave_i.STB = '1' AND local_slave_i.CYC = '1' AND eb_slave_i.CYC = '0') then 
				if(local_slave_i.WE ='1') then
					local_write_reg <= local_slave_i.DAT;

					case local_adr is
						when 8		=> p_auto_cfg(63 downto 32) 	<=  local_write_reg;
						when 12		=> p_auto_cfg(31 downto 0) 	<=  local_write_reg;						
						when 16		=> my_mac(47 downto 16) 	<= local_write_reg(31 downto 0);
						when 20		=> my_mac(15 downto 0) 		<= local_write_reg(31 downto 16);
						when 24		=> my_ip 			<= local_write_reg;
						when 28		=> my_port 		<= local_write_reg(31 downto 16); 
						when others 	=> null;
					end case;	
				else
					case local_adr is
						when 0		=> local_slave_o.DAT 		<= status_reg(63 downto 32);
						when 4		=> local_slave_o.DAT 		<= status_reg(31 downto 0);
						when 8		=> local_slave_o.DAT 		<= p_auto_cfg(63 downto 32);
						when 12		=> local_slave_o.DAT 		<= p_auto_cfg(31 downto 0);
						when 16		=> local_slave_o.DAT 		<= my_mac(47 downto 16);
						when 20		=> local_slave_o.DAT 		<= my_mac(15 downto 0) & std_logic_vector(to_unsigned(0, 16));
						when 24		=> local_slave_o.DAT 		<= my_ip;
						when 28		=> local_slave_o.DAT 		<= my_port & std_logic_vector(to_unsigned(0, 16)) ;   
						when others 	=> local_slave_o.DAT <= status_reg(63 downto 32);
					end case;	
				end if;	
			end if;
		end if; 	

		end if;    

end process;
	



status_reg_sh : process(clk_i)
begin
	if (clk_i'event and clk_i = '1') then
		if(nRSt_i = '0') then
			status_reg <= (others => '0');
		else
			if(status_clr = '1') then
			    --status_reg <= (others => '0');
			elsif(status_en = '1') then
			    status_reg <= status_reg(status_reg'left-1 downto 0) & status_i;
			end if;
		end if;
	end if;
end process;

  
end behavioral;
