-------------------------------------------------------------------------------
-- Title      : Testbench for design "axis_to_i2c_wbs_v1_0"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : axis_to_i2c_wbs_v1_0_tb.vhd
-- Author     : Pieter Van Trappen  <pieter@>
-- Company    : 
-- Created    : 2016-08-22
-- Last update: 2016-08-26
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2016-08-22  1.0      pieter  Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------

entity axis_to_i2c_wbs_v1_0_tb is

end entity axis_to_i2c_wbs_v1_0_tb;

-------------------------------------------------------------------------------

architecture behavioural of axis_to_i2c_wbs_v1_0_tb is
  -- component generics
  constant C_S00_AXI_DATA_WIDTH : integer := 32;
  constant C_S00_AXI_ADDR_WIDTH : integer := 32;

  -- component
  component axi_wb_i2c_master_v1_0 is
    --generic (
    --  C_S00_AXI_DATA_WIDTH : integer;
    --  C_S00_AXI_ADDR_WIDTH : integer);
    port (
      i2c_scl_io      : inout std_logic;
      i2c_sda_io      : inout std_logic;
      axi_int_o       : out   std_logic;  -- axi interrupt signal
      s00_axi_aclk    : in    std_logic;
      s00_axi_aresetn : in    std_logic;
      s00_axi_awaddr  : in    std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
      s00_axi_awprot  : in    std_logic_vector(2 downto 0);
      s00_axi_awvalid : in    std_logic;
      s00_axi_awready : out   std_logic;
      s00_axi_wdata   : in    std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
      s00_axi_wstrb   : in    std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
      s00_axi_wvalid  : in    std_logic;
      s00_axi_wready  : out   std_logic;
      s00_axi_bresp   : out   std_logic_vector(1 downto 0);
      s00_axi_bvalid  : out   std_logic;
      s00_axi_bready  : in    std_logic;
      s00_axi_araddr  : in    std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
      s00_axi_arprot  : in    std_logic_vector(2 downto 0);
      s00_axi_arvalid : in    std_logic;
      s00_axi_arready : out   std_logic;
      s00_axi_rdata   : out   std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
      s00_axi_rresp   : out   std_logic_vector(1 downto 0);
      s00_axi_rvalid  : out   std_logic;
      s00_axi_rready  : in    std_logic);
  end component axi_wb_i2c_master_v1_0;

  -- component ports
  signal i2c_scl_io      : std_logic;
  signal i2c_sda_io      : std_logic;
  signal axi_int_o       : std_logic;
  signal s00_axi_aclk    : std_logic;
  signal s00_axi_aresetn : std_logic;
  signal s00_axi_awaddr  : std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
  signal s00_axi_awprot  : std_logic_vector(2 downto 0);
  signal s00_axi_awvalid : std_logic;
  signal s00_axi_awready : std_logic;
  signal s00_axi_wdata   : std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
  signal s00_axi_wstrb   : std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
  signal s00_axi_wvalid  : std_logic;
  signal s00_axi_wready  : std_logic;
  signal s00_axi_bresp   : std_logic_vector(1 downto 0);
  signal s00_axi_bvalid  : std_logic;
  signal s00_axi_bready  : std_logic;
  signal s00_axi_araddr  : std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
  signal s00_axi_arprot  : std_logic_vector(2 downto 0);
  signal s00_axi_arvalid : std_logic;
  signal s00_axi_arready : std_logic;
  signal s00_axi_rdata   : std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
  signal s00_axi_rresp   : std_logic_vector(1 downto 0);
  signal s00_axi_rvalid  : std_logic;
  signal s00_axi_rready  : std_logic;

  -- clock and misc.
  signal Clk     : std_logic := '1';
  constant CWAIT : time      := 620 ns;

  -- signals for Axi slave testing
  constant c_READAMAX                  : natural   := 3;
  constant c_WRITEMAX                  : natural   := 3;
  signal s_readCounter, s_writeCounter : natural   := 0;
  signal s_readData                    : std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
  type t_addressArrayS is array (natural range <>) of unsigned(C_S00_AXI_ADDR_WIDTH-1 downto 0);
  type t_dataArrayS is array (natural range <>) of std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
  signal s_readAddresses               : t_addressArrayS(0 to c_READAMAX-1);
  signal s_writeAddresses              : t_addressArrayS(0 to c_WRITEMAX-1);
  signal s_writeData                   : t_dataArrayS(0 to c_WRITEMAX-1);
  signal s_testWrite                   : std_logic := '0';
  signal s_xready                      : std_logic := '0';

begin  -- architecture behavioural

  -- component instantiation
  DUT : axi_wb_i2c_master_v1_0
    --generic map (
    --C_S00_AXI_DATA_WIDTH => C_S00_AXI_DATA_WIDTH,
    --C_S00_AXI_ADDR_WIDTH => C_S00_AXI_ADDR_WIDTH)
    port map (
      i2c_scl_io      => i2c_scl_io,
      i2c_sda_io      => i2c_sda_io,
      axi_int_o       => axi_int_o,
      s00_axi_aclk    => s00_axi_aclk,
      s00_axi_aresetn => s00_axi_aresetn,
      s00_axi_awaddr  => s00_axi_awaddr,
      s00_axi_awprot  => s00_axi_awprot,
      s00_axi_awvalid => s00_axi_awvalid,
      s00_axi_awready => s00_axi_awready,
      s00_axi_wdata   => s00_axi_wdata,
      s00_axi_wstrb   => s00_axi_wstrb,
      s00_axi_wvalid  => s00_axi_wvalid,
      s00_axi_wready  => s00_axi_wready,
      s00_axi_bresp   => s00_axi_bresp,
      s00_axi_bvalid  => s00_axi_bvalid,
      s00_axi_bready  => s00_axi_bready,
      s00_axi_araddr  => s00_axi_araddr,
      s00_axi_arprot  => s00_axi_arprot,
      s00_axi_arvalid => s00_axi_arvalid,
      s00_axi_arready => s00_axi_arready,
      s00_axi_rdata   => s00_axi_rdata,
      s00_axi_rresp   => s00_axi_rresp,
      s00_axi_rvalid  => s00_axi_rvalid,
      s00_axi_rready  => s00_axi_rready);

  -- clock generation
  Clk          <= not Clk after 10 ns;
  s00_axi_aclk <= Clk;

  -- waveform generation
  p_tests : process
    variable v_time0 : time := 0 ns;
  begin
    s00_axi_aresetn <= '0';
    s_testWrite     <= '0';
    s_xready        <= '0';
    wait for 100 ns;

    -- start processes
    s00_axi_aresetn <= '1';
    wait for CWAIT;
    -- 2 times 3 read-cycles finished, test writing
    s_testWrite     <= '1';
    wait for CWAIT;
    -- write finished, test reading again to see changed values
    s_testWrite     <= '0';
    wait for CWAIT;
    -- read but now with rready asserted
    s_xready        <= '1';
    s_testWrite     <= '1';
    wait for CWAIT;
    -- write but now with bready asserted
    s_testWrite     <= '0';
    wait for CWAIT;
    report "** simulation finished**";
    wait;
  end process p_tests;

  --=============================================================================
  -- AXI4-Lite slave tests by simulating a master
  -- by trying to reading and writing a few addresses
  -- for now only tests 'valid before ready' asserted
  -- ! addresses shifted left (<<2) because it's AXI
  --=============================================================================
  s_readAddresses(0)  <= x"00000004";
  s_readAddresses(1)  <= x"00000008";
  s_readAddresses(2)  <= x"00000010";
  s_writeAddresses(0) <= x"00000000";
  s_writeAddresses(1) <= x"00000008";
  s_writeAddresses(2) <= x"00000010";
  s_writeData(0)      <= x"000000DE";
  s_writeData(1)      <= x"000000AD";
  s_writeData(2)      <= x"000000BE";
  --=============================================================================
  -- read-cycle
  -- parameters: s_xready - when asserted, rready will be always asserted; if
  -- not it waits for rvalid
  --=============================================================================  
  axi_slave_test_readAddress : process
  begin
    -- wait for rising edge resetn, only when low
    if s00_axi_aresetn = '0' then
      s00_axi_arvalid <= '0';
      wait on s00_axi_aresetn until s00_axi_aresetn = '1';
    end if;
    if s_testWrite = '1' then
      s00_axi_arvalid <= '0';
      wait until s_testWrite = '0';
      report "axi_slave_test_readAddress: starting signal received ...";
    end if;
    -- at rising edge of the clock
    wait until s00_axi_aclk'event and s00_axi_aclk = '1';
    if s00_axi_arvalid = '0' and s_testWrite = '0' then
      s00_axi_araddr  <= std_logic_vector(s_readAddresses(s_readCounter));
      s00_axi_arvalid <= '1';           -- VALID asserted by master
    elsif s00_axi_arready = '1' then    -- accepted by slave
      s00_axi_arvalid <= '0';
      wait until s00_axi_rvalid = '1';  -- wait until read-cycle is finished
      wait until s00_axi_aclk'event and s00_axi_aclk = '1';  -- wait one period
    end if;
  end process axi_slave_test_readAddress;

  axi_slave_test_readData : process
    variable v_rvalid_r : std_logic := '0';  -- rising edge detection
  begin
    if s00_axi_aresetn = '0' then
      s00_axi_rready <= '0';
      wait on s00_axi_aresetn until s00_axi_aresetn = '1';
      report "axi_slave_test_readData: resetn rising edge seen ...";
    end if;
    wait until s00_axi_aclk'event and s00_axi_aclk = '1';
    s00_axi_rready <= s_xready;
    if s00_axi_rvalid = '1' then  -- wait for slave to indicate valid data
      if v_rvalid_r = '0' and s00_axi_rvalid = '1' then
        -- count, read and assert only once
        s00_axi_rready                       <= '1';
        s_readData(s_readData'high downto 0) <= s00_axi_rdata(s_readData'high downto 0);
        if s_readCounter < c_READAMAX-1 then
          s_readCounter <= s_readCounter+1;
        else
          s_readCounter <= 0;
        end if;
      else
        --bring down after T
        s00_axi_rready <= s_xready;
      end if;
    end if;
    v_rvalid_r := s00_axi_rvalid;
  end process axi_slave_test_readData;
  --=============================================================================
  -- write-cycle
  -- parameters: s_xready - when asserted, bready will be always asserted; if
  -- not it waits for bready
  --=============================================================================
  axi_slave_test_write : process
  begin
    -- start-conditions
    if s00_axi_aresetn = '0' then
      s00_axi_awvalid <= '0';
      s00_axi_wvalid  <= '0';
      wait on s00_axi_aresetn until s00_axi_aresetn = '1';
    end if;
    if s_testWrite = '0' then
      s00_axi_awvalid <= '0';
      s00_axi_wvalid  <= '0';
      wait until s_testWrite = '1';
      report "axi_slave_test_write: starting signal received";
    end if;
    -- at rising edge of the clock
    wait until s00_axi_aclk'event and s00_axi_aclk = '1';
    if s00_axi_awvalid = '0' and s_testWrite = '1' then
      s00_axi_awaddr                                     <= std_logic_vector(s_writeAddresses(s_writeCounter));
      s00_axi_awvalid                                    <= '1';  -- VALID asserted by master
      s00_axi_wdata                                      <= s_writeData(s_writeCounter);
      s00_axi_wvalid                                     <= '1';
      s00_axi_wstrb((C_S00_AXI_DATA_WIDTH/8)-1 downto 0) <= (others => '1');
    end if;
    if s00_axi_awvalid = '1' and s00_axi_awready = '1' then  -- addr accepted by slave
      s00_axi_awvalid <= '0';
    end if;
    if s00_axi_wvalid = '1' and s00_axi_wready = '1' then  -- data accepted by slave
      s00_axi_wvalid <= '0';
      wait until s00_axi_bvalid = '1';  -- wait until write-cycle has ended
      wait until s00_axi_aclk'event and s00_axi_aclk = '1';  -- wait one cycle
    end if;
  end process axi_slave_test_write;

  axi_slave_test_writeResponse : process
    variable v_bvalid_r : std_logic := '0';  -- rising edge detection
  begin
    if s00_axi_aresetn = '0' then
      s00_axi_bready <= '0';
      s_writeCounter <= 0;
      wait on s00_axi_aresetn until s00_axi_aresetn = '1';
    end if;
    wait until s00_axi_aclk'event and s00_axi_aclk = '1';
    s00_axi_bready <= s_xready;
    if s00_axi_bvalid = '1' then  -- wait for slave to indicate valid cycle
      if v_bvalid_r = '0' and s00_axi_bvalid = '1' then
        -- count and assert only once
        s00_axi_bready <= '1';
        if s_writeCounter < c_WRITEMAX-1 then
          s_writeCounter <= s_writeCounter+1;
        else
          s_writeCounter <= 0;
        end if;
      else
        -- bring down after T
        s00_axi_bready <= s_xready;
      end if;
    end if;
    v_bvalid_r := s00_axi_bvalid;
  end process axi_slave_test_writeResponse;
  
end architecture behavioural;

-------------------------------------------------------------------------------

--configuration axis_to_i2c_wbs_v1_0_tb_behavioural_cfg of axis_to_i2c_wbs_v1_0_tb is
--  for behavioural
--  end for;
--end axis_to_i2c_wbs_v1_0_tb_behavioural_cfg;

-------------------------------------------------------------------------------
