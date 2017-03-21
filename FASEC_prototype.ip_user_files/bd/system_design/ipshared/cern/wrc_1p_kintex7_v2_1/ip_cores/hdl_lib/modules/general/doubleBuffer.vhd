----------------------------------------------------------------------------------
-- Company: /
-- Engineer:  pvantrap
-- 
-- Create Date:    30/11/2014 
-- Design Name:  Dubble Buffer
-- Module Name:  dubbleBuffer - rtl 
-- Project Name:  /
-- Target Devices: Papilio One 500k + LogicStart Megawing
-- Tool versions: ISE 14.7
-- Tool platform: x86_64 GNU/Linux (Fedora, kernel 3.16.6)
-- Description: dubble clocked buffer for synchronisation
-- Dependencies: 
--
-- Revision: 0.2
-- Revision 0.1 - File Created
-- Revision 0.2 - output_o removed from the p_buffer process
--
-- TODO:
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;

--=============================================================================
-- Entity declaration for double buffer
--=============================================================================
entity doubleBuffer is
  generic (
    g_DEFAULT : std_logic := '0'        -- reset value for internal buffers
    );
  port (
    clk_i     : in  std_logic;          -- buffer clock
    reset_n_i : in  std_logic;          -- reset for internal buffers
    input_i   : in  std_logic;          -- input signal
    output_o  : out std_logic           -- double buffered output signal
    );
end entity doubleBuffer;
--=============================================================================
-- architecture declaration
--=============================================================================
architecture rtl of doubleBuffer is
  signal s_buff1, s_buff2 : std_logic := g_DEFAULT;  -- internal signal buffers (stage 1 and 2)
begin
  --=============================================================================
  -- Begin of double buffer
  --=============================================================================
  -- read: clk_i, reset_n_i, input_i, g_DEFAULT
  -- write: output_o
  -- r/w:       s_buff1, s_buff2
  p_buffer : process (clk_i)
  begin
    if rising_edge(clk_i) then
      if reset_n_i = '0' then
        -- reset all internal buffers to default value
        s_buff1  <= g_DEFAULT;
        s_buff2  <= g_DEFAULT;
      else
        -- propagate signal through buffers (delay = 3 cycles)
        s_buff1  <= input_i;
        s_buff2  <= s_buff1;
      end if;
    end if;
  end process p_buffer;

  -- Output
  output_o <= s_buff2;
end rtl;
