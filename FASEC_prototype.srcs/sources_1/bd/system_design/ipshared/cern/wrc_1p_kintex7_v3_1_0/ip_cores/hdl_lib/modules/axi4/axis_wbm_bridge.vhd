------------------------------------------------------------------------------
-- Title      : AXI4-Lite slave to Wishbone master
-- Project    : General Core Collection (gencores) Library
------------------------------------------------------------------------------
-- Author     : Pieter Van Trappen
-- Company    : CERN TE-ABT-EC
-- Created    : 2016-08-19
-- Last update: 2017-03-23
-- Platform   : FPGA-generic
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: An AXI4-Lite slave to Wishbone master,
-- allows easy integration of OpenCores. For now only
-- implementation of WB single read/write cycles as AXI4-Lite
-- doesn't support bursts.
-- Some limitations:
-- * both buses share the same clock (axi_aclk_i)
-- * in case of g_AXI_AWIDTH=g_WB_AWIDTH, not all WB address space is available
-- (see ADDR_LSB)
-- * no fault in case of unresponsive WB slaves
-------------------------------------------------------------------------------
-- axis_wbm_bridge.vhd Copyright (c) 2016 CERN
-------------------------------------------------------------------------------
-- GNU LESSER GENERAL PUBLIC LICENSE
-------------------------------------------------------------------------------
-- This source file is free software; you can redistribute it and/or modify it
-- under the terms of the GNU Lesser General Public License as published by the
-- Free Software Foundation; either version 2.1 of the License, or (at your
-- option) any later version. This source is distributed in the hope that it
-- will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
-- of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
-- See the GNU Lesser General Public License for more details. You should have
-- received a copy of the GNU Lesser General Public License along with this
-- source; if not, download it from http://www.gnu.org/licenses/lgpl-2.1.html
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2016-08-19  1.0      pvantrap        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axis_wbm_bridge is
  generic (
    g_AXI_AWIDTH : integer := 32;
    g_WB_AWIDTH  : integer := 4;
    g_AXI_DWIDTH : integer := 32;
    g_WB_DWIDTH  : integer := 8;
    g_WB_BYTEADDR : boolean := false);  -- true if WB needs byte (<>word) addressing
  port (
    -- wishbone master signals
    wb_clk_o  : out std_logic;          -- master clock output
    wb_rst_o  : out std_logic := '0';   -- synchronous active high reset
    wb_adr_o  : out std_logic_vector(g_WB_AWIDTH-1 downto 0);  -- lower address bits
    wb_dat_o  : out std_logic_vector(g_WB_DWIDTH-1 downto 0);  -- Databus output
    wb_dat_i  : in  std_logic_vector(g_WB_DWIDTH-1 downto 0);  -- Databus input
    wb_sel_o  : out std_logic_vector((g_WB_DWIDTH/8)-1 downto 0);  -- Databus validity signals
    wb_we_o   : out std_logic;          -- Write enable output
    wb_stb_o  : out std_logic;          -- Strobe signals / core select signal
    wb_cyc_o  : out std_logic;          -- Valid bus cycle input
    wb_ack_i  : in  std_logic;          -- Bus cycle acknowledge input
    wb_err_i  : in  std_logic;          -- abnormal cycle termination
    wb_rty_i  : in  std_logic;  -- interface not ready to accept or send data
    -- wishbone non-standard signals
    wb_inta_i : in  std_logic;          -- interrupt request input signal

    -- AXI4-Lite slave signals
    -- Global Clock Signal
    axi_aclk_i    : in  std_logic;
    -- Global Reset Signal. This Signal is Active LOW
    axi_aresetn_i : in  std_logic;
    -- Write address (issued by master, acceped by Slave)
    axi_awaddr_i  : in  std_logic_vector(g_AXI_AWIDTH-1 downto 0);
    -- Write channel Protection type. This signal indicates the
    -- privilege and security level of the transaction, and whether
    -- the transaction is a data access or an instruction access.
    axi_awprot_i  : in  std_logic_vector(2 downto 0);
    -- Write address valid. This signal indicates that the master signaling
    -- valid write address and control information.
    axi_awvalid_i : in  std_logic;
    -- Write address ready. This signal indicates that the slave is ready
    -- to accept an address and associated control signals.
    axi_awready_o : out std_logic;
    -- Write data (issued by master, acceped by Slave) 
    axi_wdata_i   : in  std_logic_vector(g_AXI_DWIDTH-1 downto 0);
    -- Write strobes. This signal indicates which byte lanes hold
    -- valid data. There is one write strobe bit for each eight
    -- bits of the write data bus.    
    axi_wstrb_i   : in  std_logic_vector((g_AXI_DWIDTH/8)-1 downto 0);
    -- Write valid. This signal indicates that valid write
    -- data and strobes are available.
    axi_wvalid_i  : in  std_logic;
    -- Write ready. This signal indicates that the slave
    -- can accept the write data.
    axi_wready_o  : out std_logic;
    -- Write response. This signal indicates the status
    -- of the write transaction.
    axi_bresp_o   : out std_logic_vector(1 downto 0);
    -- Write response valid. This signal indicates that the channel
    -- is signaling a valid write response.
    axi_bvalid_o  : out std_logic;
    -- Response ready. This signal indicates that the master
    -- can accept a write response.
    axi_bready_i  : in  std_logic;
    -- Read address (issued by master, acceped by Slave)
    axi_araddr_i  : in  std_logic_vector(g_AXI_AWIDTH-1 downto 0);
    -- Protection type. This signal indicates the privilege
    -- and security level of the transaction, and whether the
    -- transaction is a data access or an instruction access.
    axi_arprot_i  : in  std_logic_vector(2 downto 0);
    -- Read address valid. This signal indicates that the channel
    -- is signaling valid read address and control information.
    axi_arvalid_i : in  std_logic;
    -- Read address ready. This signal indicates that the slave is
    -- ready to accept an address and associated control signals.
    axi_arready_o : out std_logic;
    -- Read data (issued by slave)
    axi_rdata_o   : out std_logic_vector(g_AXI_DWIDTH-1 downto 0);
    -- Read response. This signal indicates the status of the
    -- read transfer.
    axi_rresp_o   : out std_logic_vector(1 downto 0);
    -- Read valid. This signal indicates that the channel is
    -- signaling the required read data.
    axi_rvalid_o  : out std_logic;
    -- Read ready. This signal indicates that the master can
    -- accept the read data and response information.
    axi_rready_i  : in  std_logic;

    -- AXI4 non-standard signals
    axi_int_o : out std_logic);

end entity axis_wbm_bridge;

architecture rtl of axis_wbm_bridge is
  -- ADDR_LSB is used for addressing 32/64 bit registers/memories
  -- ARM busses, as AXI4, do not accept address addressing by using the 2 LSB - hence memory is byte-wise addressed
  constant ADDR_LSB : integer := (g_AXI_DWIDTH/32)+1;
  -- buses signals
  signal s_stb_r          : std_logic;
  signal s_arready        : std_logic;  -- internal arvalid signal
  signal s_awready        : std_logic;
  signal s_wready         : std_logic;
  signal s_rvalid         : std_logic;
  signal s_bvalid         : std_logic;
  signal s_addr           : std_logic_vector(g_AXI_AWIDTH-1 downto 0) := (others => '0');
  signal s_rdata, s_wdata : std_logic_vector(g_WB_DWIDTH-1 downto 0)  := (others => '0');
  signal s_rresp, s_bresp : std_logic_vector(1 downto 0)              := (others => '0');
  signal s_we_r           : std_logic;
begin  -- architecture rtl

  --=============================================================================
  -- Concurrent statements for the bridge
  --=============================================================================
  wb_clk_o                                       <= axi_aclk_i;
  wb_rst_o                                       <= not axi_aresetn_i;
  -- WB addresses
  wb_addr_shift : if g_WB_BYTEADDR=true generate
    wb_adr_o(g_WB_AWIDTH-1 downto 0)               <= s_addr(g_WB_AWIDTH+ADDR_LSB-1 downto ADDR_LSB) when g_WB_AWIDTH+ADDR_LSB<g_AXI_AWIDTH
                                                      else std_logic_vector(resize(unsigned(s_addr(g_AXI_AWIDTH-1 downto ADDR_LSB)),g_WB_AWIDTH));
  end generate wb_addr_shift;
  wb_addr_gen: if g_WB_BYTEADDR=false generate
   wb_adr_o(g_WB_AWIDTH-1 downto 0)               <= s_addr(g_WB_AWIDTH-1 downto 0);
  end generate wb_addr_gen;
  
  -- strobe output, valid data transfer cycle
  -- asserted when ar/awvalid are asserted, also depends on clocked logic below
  wb_stb_o                                       <= s_stb_r;
  wb_cyc_o                                       <= s_stb_r;
  -- write enable signal (negated during read-cycles)
  wb_we_o                                        <= s_we_r;
  -- read/write reponse data valid
  axi_rvalid_o                                   <= s_rvalid and not s_we_r;
  axi_bvalid_o                                   <= s_bvalid and s_we_r;
  -- rdata and wdata arrays
  axi_rdata_o(g_WB_DWIDTH-1 downto 0)            <= s_rdata(g_WB_DWIDTH-1 downto 0);
  axi_rdata_o(g_AXI_DWIDTH-1 downto g_WB_DWIDTH) <= (others => '0');
  wb_dat_o(g_WB_DWIDTH-1 downto 0)               <= axi_wdata_i(g_WB_DWIDTH-1 downto 0);
  -- axi response signalling
  axi_rresp_o(1 downto 0)                        <= s_rresp(1 downto 0) when s_rvalid = '1'
                                                    else "--";
  axi_bresp_o(1 downto 0) <= s_bresp(1 downto 0) when s_bvalid = '1'
                             else "--";
  -- internal signals to outputs
  axi_arready_o                        <= s_arready;
  axi_awready_o                        <= s_awready;
  axi_wready_o                         <= s_wready;
  -- misc. direct assignments
  axi_int_o                            <= wb_inta_i;

  --=============================================================================
  -- clocked process for WB write-enable signal
  --=============================================================================
  p_wb_we : process(axi_aclk_i)
  begin
    if rising_edge(axi_aclk_i) then
      if axi_aresetn_i = '0' then
        s_we_r <= '0';
      else
        -- only a asserted a-valid can switch this signal
        if axi_arvalid_i = '1' then
          s_we_r <= '0';
        elsif axi_awvalid_i = '1' then
          s_we_r <= '1';
        end if;
      end if;
    end if;
  end process p_wb_we;

  --=============================================================================
  -- clocked process for WB strobe and address signals
  --=============================================================================
  p_stb_we : process(axi_aclk_i)
  begin
    if rising_edge(axi_aclk_i) then
      if axi_aresetn_i = '0' then
        s_stb_r                         <= '0';
        s_addr(g_AXI_AWIDTH-1 downto 0) <= (others => '0');
      else
        if axi_arvalid_i = '1' then
          s_addr(g_AXI_AWIDTH-1 downto 0) <= axi_araddr_i(g_AXI_AWIDTH-1 downto 0);
          s_stb_r                         <= '1';
        elsif axi_awvalid_i = '1' then
          s_addr(g_AXI_AWIDTH-1 downto 0) <= axi_awaddr_i(g_AXI_AWIDTH-1 downto 0);
          s_stb_r                         <= '1';
        elsif wb_ack_i = '1' then
          s_stb_r <= '0';
        end if;
      end if;
    end if;
  end process p_stb_we;

  --=============================================================================
  -- clocked process for read-channel handshake signals
  --=============================================================================
  p_mux_read : process(axi_aclk_i)
  begin
    if rising_edge(axi_aclk_i) then
      if axi_aresetn_i = '0' then
        s_arready                       <= '0';
        s_rvalid                        <= '0';
        s_rdata(g_WB_DWIDTH-1 downto 0) <= (others => '0');
        s_rresp(1 downto 0)             <= "00";
      else
        -- register the data
        if wb_ack_i = '1' and s_we_r = '0' then
          s_rdata(g_WB_DWIDTH-1 downto 0) <= wb_dat_i(g_WB_DWIDTH-1 downto 0);
          s_rvalid                        <= '1';
          s_rresp                         <= "00";
        elsif (wb_rty_i = '1' or wb_err_i = '1') and s_we_r = '0' then
          s_rdata(g_WB_DWIDTH-1 downto 0) <= (others => '-');
          s_rvalid                        <= '1';
          s_rresp                         <= "10";
        elsif s_rvalid = '1' and axi_rready_i = '1' then
          s_rvalid <= '0';
        end if;
        -- axi_arready asserted for T when arvalid=1
        if axi_arvalid_i = '1' and s_arready = '0' then
          s_arready <= '1';
        else
          s_arready <= '0';
        end if;
      end if;
    end if;
  end process p_mux_read;

  --=============================================================================
  -- clocked process for write-channel handshake signals
  --=============================================================================
  p_mux_write : process(axi_aclk_i)
  begin
    if rising_edge(axi_aclk_i) then
      if axi_aresetn_i = '0' then
        s_awready                       <= '0';
        s_wready                        <= '0';
        s_bvalid                        <= '0';
        s_wdata(g_WB_DWIDTH-1 downto 0) <= (others => '0');
      else
        -- axi_awready asserted for T when awvalid=1 and wvalid=1
        if axi_awvalid_i = '1' and axi_wvalid_i = '1' and s_awready = '0' then
          s_awready                       <= '1';
          s_wdata(g_WB_DWIDTH-1 downto 0) <= axi_wdata_i(g_WB_DWIDTH-1 downto 0);
        else
          s_awready <= '0';
        end if;
        -- axi_wready asserted for T when awvalid=1 and wvalid=1
        if axi_awvalid_i = '1' and axi_wvalid_i = '1' and s_wready = '0' then
          s_wready <= '1';
        else
          s_wready <= '0';
        end if;
        -- axi bvalid asserted for min. T;
        -- needs to stay asserted until master ack. with bready
        if s_we_r='1' and (wb_ack_i='1' or wb_err_i='1' or wb_rty_i='1') and s_bvalid='0' then
          s_bresp(1 downto 0) <= not wb_ack_i & '0';
          s_bvalid <= '1';
        elsif s_bvalid = '1' and axi_bready_i = '1' then
          s_bvalid <= '0';
        end if;
        -- clock axi write-strobes as well
        wb_sel_o((g_WB_DWIDTH/8)-1 downto 0) <= axi_wstrb_i((g_WB_DWIDTH/8)-1 downto 0);
      end if;
    end if;
  end process p_mux_write;

end architecture rtl;
