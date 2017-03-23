----------------------------------------------------------------------------------
-- Company: /
-- Engineer:  pvantrap
-- 
-- Create Date:    30/11/2014 
-- Design Name:  Dubble Buffer for vectors
-- Module Name:  dubbleBufferVector - rtl 
-- Project Name:  /
-- Target Devices: Papilio One 500k + LogicStart Megawing
-- Tool versions: ISE 14.7
-- Tool platform: x86_64 GNU/Linux (Fedora, kernel 3.16.6)
-- Description: dubble clocked buffer for synchronisation of std_logic_vector

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
entity dubbleBufferVector is
  generic (
    g_DEFAULT    : std_logic             := '0';                        -- reset value for internal buffers
    g_DATA_WIDTH : natural range 1 to 64 := 8
    );
  port (
    clk_i     : in  std_logic;                                          -- buffer clock
    reset_n_i : in  std_logic;                                          -- reset for internal buffers
    input_i   : in  std_logic_vector(g_DATA_WIDTH-1 downto 0);          -- input signal
    output_o  : out std_logic_vector(g_DATA_WIDTH-1 downto 0)           -- double buffered output signal
    );
end entity dubbleBufferVector;
--=============================================================================
-- architecture declaration
--=============================================================================
architecture rtl of dubbleBufferVector is
  signal s_buff1, s_buff2 : std_logic_vector(g_DATA_WIDTH-1 downto 0);  -- internal signal buffers (stage 1 and 2)
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
        s_buff1(g_DATA_WIDTH-1 downto 0)  <= (others => g_DEFAULT);
        s_buff2(g_DATA_WIDTH-1 downto 0)  <= (others => g_DEFAULT);
      else
        -- propagate signal through buffers (delay = 3 cycles)
        s_buff1(g_DATA_WIDTH-1 downto 0)  <= input_i(g_DATA_WIDTH-1 downto 0);
        s_buff2(g_DATA_WIDTH-1 downto 0)  <= s_buff1(g_DATA_WIDTH-1 downto 0);
      end if;
    end if;
  end process p_buffer;

  -- Outputs
  output_o(g_DATA_WIDTH-1 downto 0) <= s_buff2(g_DATA_WIDTH-1 downto 0);

end rtl;
