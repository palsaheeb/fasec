----------------------------------------------------------------------------------
-- Company: CERN
-- Engineer: Pieter Van Trappen
-- 
-- Create Date: 08.01.2015 12:42:27
-- Design Name: 
-- Module Name: myPackage - Behavioral
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

package myPackage is    
  -- types
  type t_adc_array is array (integer range <>) of unsigned(11 downto 0);
  -- when using VHDL2008, unsigned can be non-constrained
  type t_axiMemory is array (integer range <>) of unsigned(31 downto 0);
  
  -- constants
  constant BCD_D             : integer := 4;   -- BCD digits for the to_bcd function
  constant BCD_WIDTH         : integer := 16;  -- width of the input unsigned for the to_bcd function

  -- functions
  function to_bcd (bin       : unsigned(BCD_WIDTH-1 downto 0)) return unsigned;
  function xadc_to_axi (xadc : integer; length : natural) return unsigned;
  function clogb2 (bit_depth : integer) return integer;
 
  -- components
  component clockDivider is                                                                  -- see clockDivider.vhd
    generic (
      g_FACTOR      : integer range 0 to integer'high;
      g_START_LEVEL : std_logic := '0');
    port(
      clk_system_i : in  std_logic;
      reset_i      : in  std_logic;
      clk_div_o    : out std_logic
      );
  end component clockDivider;
  component shiftRegister is                                                                 -- see shiftRegsiter.vhd
    generic(
      g_DATA_WIDTH : natural range 1 to 32 := 8;
      g_DEFAULT    : std_logic             := '0'
      );
    port(
      clear_n_i         : in  std_logic;
      mode_i            : in  std_logic_vector(1 downto 0);
      serialLoadLeft_i  : in  std_logic;
      serialLoadRight_i : in  std_logic;
      clk_i             : in  std_logic;
      parallelLoad_i    : in  std_logic_vector(g_DATA_WIDTH-1 downto 0) := (others => '0');  -- necessary if we want to leave it uninitialised, i.e. open     
      outputs_o         : out std_logic_vector(g_DATA_WIDTH-1 downto 0)
      );
  end component;
  component doubleBuffer is
    generic (
      g_DEFAULT : std_logic);
    port (
      clk_i     : in  std_logic;
      reset_n_i : in  std_logic;
      input_i   : in  std_logic;
      output_o  : out std_logic);
  end component doubleBuffer;
  component doubleBufferEdge is
    generic (
      g_DEFAULT       : std_logic;
      g_RISING_EDGE   : boolean;
      g_DEBOUNCE      : boolean;
      g_DEBOUNCEWIDTH : natural);
    port (
      clk_i     : in  std_logic;
      reset_n_i : in  std_logic;
      input_i   : in  std_logic;
      output_o  : out std_logic;
      edge_o    : out std_logic);
  end component doubleBufferEdge;
  component dubbleBufferVector is
    generic(
      g_DEFAULT    : std_logic             := '0';
      g_DATA_WIDTH : natural range 1 to 64 := 8
      );
    port(
      clk_i     : in  std_logic;
      reset_n_i : in  std_logic;
      input_i   : in  std_logic_vector(g_DATA_WIDTH-1 downto 0);
      output_o  : out std_logic_vector(g_DATA_WIDTH-1 downto 0)
      );
  end component dubbleBufferVector;
  component counterUpDown is
    generic (
      g_WIDTH : natural);
    port (
      clk_i     : in  std_logic;
      reset_n_i : in  std_logic;
      countUp_i : in  std_logic;
      enable_i  : in  std_logic;
      count_o   : out std_logic_vector(g_WIDTH-1 downto 0));
  end component counterUpDown;
  component axi4lite_slave is
    generic (
      C_S_AXI_DATA_WIDTH : integer;
      C_S_AXI_ADDR_WIDTH : integer;
      g_MAXREAD          : integer;
      g_MAXWRITE         : integer);
    port (
      s_axi_dataR      : in     t_axiMemory(0 to g_MAXREAD-1);
      s_axi_dataW      : buffer t_axiMemory(g_MAXREAD to g_MAXREAD+g_MAXWRITE-1) := (others => (others => '0'));
      s_axi_dataResetW : in     t_axiMemory(g_MAXREAD to g_MAXREAD+g_MAXWRITE-1);
      S_AXI_ACLK       : in     std_logic;
      S_AXI_ARESETN    : in     std_logic;
      S_AXI_AWADDR     : in     std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
      S_AXI_AWPROT     : in     std_logic_vector(2 downto 0);
      S_AXI_AWVALID    : in     std_logic;
      S_AXI_AWREADY    : out    std_logic;
      S_AXI_WDATA      : in     std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
      S_AXI_WSTRB      : in     std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
      S_AXI_WVALID     : in     std_logic;
      S_AXI_WREADY     : out    std_logic;
      S_AXI_BRESP      : out    std_logic_vector(1 downto 0);
      S_AXI_BVALID     : out    std_logic;
      S_AXI_BREADY     : in     std_logic;
      S_AXI_ARADDR     : in     std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
      S_AXI_ARPROT     : in     std_logic_vector(2 downto 0);
      S_AXI_ARVALID    : in     std_logic;
      S_AXI_ARREADY    : out    std_logic;
      S_AXI_RDATA      : out    std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
      S_AXI_RRESP      : out    std_logic_vector(1 downto 0);
      S_AXI_RVALID     : out    std_logic;
      S_AXI_RREADY     : in     std_logic);
  end component axi4lite_slave;
end myPackage;

package body myPackage is

  -- function called clogb2 that returns an integer which has the
  -- value of the ceiling of the log base 2
  function clogb2 (bit_depth : integer) return integer is
    variable depth : integer := bit_depth;
    variable count : integer := 1;
  begin
    for clogb2 in 1 to bit_depth loop   -- Works for up to 32 bit integers
      if (bit_depth <= 2) then
        count := 1;
      else
        if(depth <= 1) then
          count := count;
        else
          depth := depth / 2;
          count := count + 1;
        end if;
      end if;
    end loop;
    return(count);
  end;

  function xadc_to_axi (xadc : integer; length : natural) return unsigned is
    -- pvantrap, 03/2015
    -- the XADC internal register addresses need to be converted to the memory mapping used by the LogiCore IP AXI XADC (PG019) 
    constant mask : unsigned(length-1 downto 0) := to_unsigned(16#80#, length);
  begin
    return SHIFT_LEFT((to_unsigned(xadc, length)+mask), 2);  -- OR mask doesn't work?
  end xadc_to_axi;

  function to_bcd (bin : unsigned(BCD_WIDTH-1 downto 0)) return unsigned is
    --(c)2012 Enthusiasticgeek for Stack Overflow. 
    -- modified by pvantrap 11/2014
    -- high latency and not very nice in logic but synthesizable and 'easy'
    variable i    : integer                        := 0;
    variable bcd  : unsigned((4*BCD_D)-1 downto 0) := (others => '0');
    variable bint : unsigned(BCD_WIDTH-1 downto 0) := bin;
  begin
    for i in 0 to BCD_WIDTH-1 loop                                  -- repeating for the length of the binair input
      bcd((4*BCD_D)-1 downto 1)  := bcd((4*BCD_D)-2 downto 0);  --shifting the bits.
      bcd(0)                     := bint(BCD_WIDTH-1);
      bint(BCD_WIDTH-1 downto 1) := bint(BCD_WIDTH-2 downto 0);
      bint(0)                    := '0';

      -- 10^0
      if(i < BCD_WIDTH-1 and bcd(3 downto 0) > "0100") then  --add 3 if BCD digit is 5 or greater (after shift left i.e. x2, converts from 16 to 10)
        bcd(3 downto 0) := bcd(3 downto 0) + "0011";
      end if;

      -- 10^1
      if(i < BCD_WIDTH-1 and bcd(7 downto 4) > "0100") then
        bcd(7 downto 4) := bcd(7 downto 4) + "0011";
      end if;

      -- 10^2
      if(i < BCD_WIDTH-1 and bcd(11 downto 8) > "0100") then
        bcd(11 downto 8) := bcd(11 downto 8) + "0011";
      end if;

      -- 10^3
      if(i < BCD_WIDTH-1 and bcd(15 downto 12) > "0100") then
        bcd(15 downto 12) := bcd(15 downto 12) + "0011";
      end if;
    end loop;
    return bcd;
  end to_bcd;
end myPackage;
