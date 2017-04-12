-------------------------------------------------------------------------------
-- Title      : Parametrizable dual-port synchronous RAM (Xilinx version)
-- Project    : Generics RAMs and FIFOs collection
-------------------------------------------------------------------------------
-- File       : lm32_dpram_sameclock.vhd
-- Author     : Tomasz Wlostowski
-- Company    : CERN BE-CO-HT
-- Created    : 2011-01-25
-- Last update: 2012-07-09
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: True dual-port synchronous RAM for Xilinx FPGAs with:
-- - configurable address and data bus width
-- - byte-addressing mode (data bus width restricted to multiple of 8 bits)
-- Todo:
-- - loading initial contents from file
-- - add support for read-first/write-first address conflict resulution (only
--   supported by Xilinx in VHDL templates)
-------------------------------------------------------------------------------
-- Copyright (c) 2011 CERN
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2011-01-25  1.0      twlostow        Created
-- 2015-10-20  2.0      eml             Same clock for both ports. 
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.wishbone_pkg.all;
use std.textio.all;

library work;
use work.genram_pkg.all;
use work.memory_loader_pkg.all;

--package where is the bin.
use work.wrc_bin_pkg.all;

entity lm32_dpram_sameclock is

  generic (
    g_data_width : natural := 32;
    g_size       : natural := 16384;

    g_with_byte_enable         : boolean := true;
    g_addr_conflict_resolution : string  := "read_first"
    );

  port (
    rst_n_i : in std_logic := '1';      -- synchronous reset, active LO

    -- Port A
    clk_i : in std_logic;

    bwea_i : in  std_logic_vector((g_data_width+7)/8-1 downto 0);		-- (which byte is going to be written).
    wea_i  : in  std_logic;														-- Write enable
    aa_i   : in  std_logic_vector(f_log2_size(g_size)-1 downto 0);	-- address
    da_i   : in  std_logic_vector(g_data_width-1 downto 0);				-- data
    qa_o   : out std_logic_vector(g_data_width-1 downto 0);				-- output

    -- Port B
    bweb_i : in  std_logic_vector((g_data_width+7)/8-1 downto 0);
    web_i  : in  std_logic;
    ab_i   : in  std_logic_vector(f_log2_size(g_size)-1 downto 0);
    db_i   : in  std_logic_vector(g_data_width-1 downto 0);
    qb_o   : out std_logic_vector(g_data_width-1 downto 0)
    );

end lm32_dpram_sameclock;



architecture syn of lm32_dpram_sameclock is

  constant c_num_bytes : integer := (g_data_width + 7)/8;

  signal ram : t_ram_fast_load (0 to g_size-1) := c_wrc_bin_init; -- The RAM is initialized already.

  signal s_we_a     : std_logic_vector(c_num_bytes-1 downto 0);
  signal s_ram_o_a  : std_logic_vector(g_data_width-1 downto 0);
  signal s_we_b     : std_logic_vector(c_num_bytes-1 downto 0);
  signal s_ram_o_b  : std_logic_vector(g_data_width-1 downto 0);


  signal wea_rep, web_rep : std_logic_vector(c_num_bytes-1 downto 0);

  function f_check_bounds(x : integer; minx : integer; maxx : integer) return integer is
  begin
    if(x < minx) then
      return minx;
    elsif(x > maxx) then
      return maxx;
    else
      return x;
    end if;
  end f_check_bounds;

begin

  wea_rep <= (others => wea_i);
  web_rep <= (others => web_i);

  s_we_a <= bwea_i and wea_rep;
  s_we_b <= bweb_i and web_rep;

--the outputs. eml
  qa_o  <= s_ram_o_a;
  qb_o  <= s_ram_o_b;

-- don't use elsif, it never works. eml.
  gen_with_byte_enable_readfirst : if(g_with_byte_enable = true and (g_addr_conflict_resolution = "read_first" or
                                                                     g_addr_conflict_resolution = "dont_care")) generate
   
   --Port A
   process (clk_i)
    begin
      if rising_edge(clk_i) then
        for i in 0 to c_num_bytes-1 loop
          if s_we_a(i) = '1' then
            ram(f_check_bounds(to_integer(unsigned(aa_i)), 0, g_size-1))((i+1)*8-1 downto i*8) <= da_i((i+1)*8-1 downto i*8);
          else 
            s_ram_o_a <= ram(f_check_bounds(to_integer(unsigned(aa_i)), 0, g_size-1));
          end if;	
        end loop;
      end if;
    end process;

   -- Port B
   process (clk_i)
    begin
      if rising_edge(clk_i) then
        for i in 0 to c_num_bytes-1 loop
          if(s_we_b(i) = '1') then
            ram(f_check_bounds(to_integer(unsigned(ab_i)), 0, g_size-1))((i+1)*8-1 downto i*8) <= db_i((i+1)*8-1 downto i*8);
          else
            s_ram_o_b <= ram(f_check_bounds(to_integer(unsigned(ab_i)), 0, g_size-1));
          end if;
        end loop;
      end if;
    end process;

  end generate gen_with_byte_enable_readfirst;



  gen_without_byte_enable_readfirst : if(g_with_byte_enable = false and (g_addr_conflict_resolution = "read_first" or
                                                                         g_addr_conflict_resolution = "dont_care")) generate

-- Port A
   process(clk_i)
    begin
      if rising_edge(clk_i) then
        if(wea_i = '1') then
          ram(to_integer(unsigned(aa_i))) <= da_i;
        else
          s_ram_o_a <= ram(to_integer(unsigned(aa_i)));
        end if;
      end if;
    end process;

-- Port B
   process(clk_i)
    begin
      if rising_edge(clk_i) then
        if (web_i = '1') then
          ram(to_integer(unsigned(ab_i))) <= db_i;
        else
          s_ram_o_b <= ram(to_integer(unsigned(ab_i)));
        end if;
      end if;
    end process;
    
  end generate gen_without_byte_enable_readfirst;

  gen_without_byte_enable_writefirst : if(g_with_byte_enable = false and g_addr_conflict_resolution = "write_first") generate
    
   process(clk_i)
    begin
      if rising_edge(clk_i) then
        if(wea_i = '1') then
          ram(to_integer(unsigned(aa_i))) <= da_i;
          qa_o                            <= da_i;
        else
          qa_o <= ram(to_integer(unsigned(aa_i)));
        end if;
      end if;
    end process;
    
    
   process(clk_i)
    begin
      if rising_edge(clk_i) then
        if(web_i = '1') then
          ram(to_integer(unsigned(ab_i))) <= db_i;
          qb_o                            <= db_i;
        else
          qb_o <= ram(to_integer(unsigned(ab_i)));
        end if;
      end if;
    end process;
    
    
  end generate gen_without_byte_enable_writefirst;


  gen_without_byte_enable_nochange : if(g_with_byte_enable = false and g_addr_conflict_resolution = "no_change") generate
    
  process(clk_i)
    begin
      if rising_edge(clk_i) then
        if(wea_i = '1') then
          ram(to_integer(unsigned(aa_i))) <= da_i;
        else
          qa_o <= ram(to_integer(unsigned(aa_i)));
        end if;
      end if;
  end process;
    
  process(clk_i)
    begin
      if rising_edge(clk_i) then
        if(web_i = '1') then
          ram(to_integer(unsigned(ab_i))) <= db_i;
        else
          qb_o <= ram(to_integer(unsigned(ab_i)));
        end if;
      end if;
  end process;

  end generate gen_without_byte_enable_nochange;
  

end syn;
