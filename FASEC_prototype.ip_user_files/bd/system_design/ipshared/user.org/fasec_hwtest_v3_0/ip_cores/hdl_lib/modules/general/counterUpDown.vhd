----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.02.2015 14:49:46
-- Design Name: 
-- Module Name: counterUpDown - rtl
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
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

--=============================================================================
-- Entity declaration for counterUpDown
--=============================================================================
entity counterUpDown is
  generic(
    g_WIDTH : natural := 24);  -- 24 bit is max. for DSP48E1 SIMD
  port(
    clk_i     : in  std_logic;
    reset_n_i : in  std_logic;
    countUp_i : in  std_logic;                   -- 1 for up, 0 for counting down
    enable_i  : in  std_logic;
    count_o   : out std_logic_vector(g_WIDTH-1 downto 0));
  -- attributes, for details see ug901 and ug479
  attribute use_mult  : string;         -- do not use the multiplier, saves power
  attribute use_dsp48 : string;         -- force DSP block implementation because by default not inferred for adders
  attribute use_simd : string;          -- we want to use the two 24-bit adder mode
  attribute autoreset_patdet : string;
--  attribute mask : std_logic_vector(47 downto 0);
--  attribute pattern : std_logic_vector(47 downto 0);
  attribute use_pattern_detect : string;
  attribute use_dsp48 of counterUpDown : entity is "yes";
  attribute use_mult of counterUpDown : entity is "none";
  attribute use_simd of counterUpDown : entity is "two24";
  --attribute autoreset_patdet of counterUpDown : entity is "reset_match";        -- reset when over/underflow
  --attribute mask of counterUpDown : entity is x"0000003FFFFF";                  -- bit 1 means ignore, set for 24 bit over/under flow (1 MSB lost!)
  --attribute pattern of counterUpDown : entity is x"000000000000";
  --attribute use_pattern_detect of counterUpDown : entity is "patd";
end counterUpDown;

architecture rtl of counterUpDown is
  constant c_LIMIT : integer := 2**(g_WIDTH-1)-1;
  signal s_count   : integer range -c_LIMIT to c_LIMIT;    -- rang is important, if not a 32-bit integer register will be inferred
begin
  count_o(g_WIDTH-1 downto 0) <= std_logic_vector(to_signed(s_count, g_WIDTH));

  p_counter : process(clk_i, reset_n_i)
  begin
    if rising_edge(clk_i) then
      if reset_n_i = '0' then           -- synchronous reset to speed up the adder design
        s_count <= 0;
      elsif enable_i = '1' then
        if countUp_i = '1' then
          --if s_count = c_LIMIT then   -- check what happens in case of DSP adder over/underflow!
          --  s_count <= 0;
          --else
            s_count <= s_count + 1;
          --end if;
        else                            -- count down
          --if s_count = 0 then
          --  s_count <= c_LIMIT;
          --else
            s_count <= s_count - 1;
          --end if;
        end if;
      end if;
    end if;
  end process p_counter;
  
end rtl;
