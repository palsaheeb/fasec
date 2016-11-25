----------------------------------------------------------------------------------
-- Company: /
-- Engineer:  pvantrap
-- 
-- Create Date:    30/11/2014 
-- Design Name:  Dubble Buffer with edge detection
-- Module Name:  dubbleBufferEdge - rtl 
-- Project Name:  /
-- Target Devices: Papilio One 500k + LogicStart Megawing
-- Tool versions: ISE 14.7
-- Tool platform: x86_64 GNU/Linux (Fedora, kernel 3.16.6)
-- Description: dubble clocked buffer for synchronisation with edge detection pulse of 1 clock period

-- Dependencies: 
--
-- Revision: 0.2
-- Revision 0.1 - File Created
-- Revision 0.2 - Outputs removed from the p_buffer process because of the unwanted additional registers
--
-- TODO:
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;

--=============================================================================
-- Entity declaration for double buffer with edge detection
--=============================================================================
entity doubleBufferEdge is
  generic (
    g_DEFAULT       : std_logic := '0';          -- reset value for internal buffers
    g_RISING_EDGE   : boolean   := true;         -- if false then falling edge detection
    g_DEBOUNCE      : boolean   := false;        -- if true the input will be debounced
    g_DEBOUNCEWIDTH : natural   := 5             -- width of the shift register for input debouncing
    );
  port (
    clk_i     : in  std_logic;                   -- buffer clock
    reset_n_i : in  std_logic;                   -- reset for internal buffers
    input_i   : in  std_logic;                   -- input signal
    output_o  : out std_logic;                   -- double buffered output signal
    edge_o    : out std_logic                    -- high for 1 pulse when edge is detected
    );
end entity doubleBufferEdge;
--=============================================================================
-- architecture declaration
--=============================================================================
architecture rtl of doubleBufferEdge is
  signal s_buff1, s_buff2, s_buff3 : std_logic := g_DEFAULT;  -- internal signal buffers (stage 1 and 2)
  signal s_debounce                : std_logic_vector(g_DEBOUNCEWIDTH-1 downto 0);
begin
  --=============================================================================
  -- Begin of double buffer
  --=============================================================================
  -- read: clk_i, reset_n_i, input_i, g_DEFAULT
  -- r/w:  s_buff1, s_buff2, s_buff3
  p_buffer : process (clk_i)
  begin
    if rising_edge(clk_i) then
      if reset_n_i = '0' then
        -- reset all internal buffers to default value
        s_buff1 <= g_DEFAULT;
        s_buff2 <= g_DEFAULT;
        s_buff3 <= g_DEFAULT;
      else
        -- propagate signal through buffers
        s_buff1 <= input_i;
        if g_DEBOUNCE then
          -- debounce if requested
          s_debounce(g_DEBOUNCEWIDTH-1 downto 0) <= s_debounce(g_DEBOUNCEWIDTH-2 downto 0) & s_buff1;
          if (s_debounce = (s_debounce'range => '1')) then
            s_buff2 <= '1';                      -- 1 only if all shift register bits are 1
          elsif (s_debounce = (s_debounce'range => '0')) then
            s_buff2 <= '0';                      -- 0 only if all shift register bits are 0
          end if;
        else
          -- in case no debounce, simply pass the the next FF
          s_buff2 <= s_buff1;
        end if;
        s_buff3 <= s_buff2;                      -- buff3 used for edge detection only
      end if;
    end if;
  end process p_buffer;

  -- outputs
  output_o <= s_buff2;
  edge_o   <= (s_buff2 and not(s_buff3)) when g_RISING_EDGE else (not(s_buff2) and s_buff3);  -- rising/falling edge detection
end rtl;
