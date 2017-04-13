------------------------------------------------------------------------------
-- Title      : OC I2C master through AXI4-Lite slave
-- Project    : FIDS
------------------------------------------------------------------------------
-- Author     : Pieter Van Trappen
-- Company    : CERN TE-ABT-EC
-- Created    : 2016-08-19
-- Last update: 2017-03-23
-- Platform   : FPGA-generic
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: A wrapper around OpenCores I2C master, making it accessible
-- through AXI4-Lite
--
-------------------------------------------------------------------------------
-- axis_to_i2c_wbs.vhd Copyright (c) 2016 CERN
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
-- 2016-08-29  1.0      pvantrap        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl_lib;
use hdl_lib.main_pkg.all;

entity axi_wb_i2c_master is
  generic (
    C_S00_AXI_DATA_WIDTH : integer := 32;
    C_S00_AXI_ADDR_WIDTH : integer := 32);
  port (
    -- i2c and misc ports
    i2c_scl_io      : inout std_logic;
    i2c_sda_io      : inout std_logic;
    axi_int_o       : out   std_logic;  -- axi interrupt signal
    -- Ports of Axi Slave Bus Interface S00_AXI
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
    s00_axi_rready  : in    std_logic
    );
end axi_wb_i2c_master;

architecture rtl of axi_wb_i2c_master is
  -- constants
  constant c_WB_AWIDTH : integer := 3;
  constant c_WB_DWIDTH : integer := 8;
  -- component declaration
  component i2c_master_top is
    generic (
      ARST_LVL : std_logic);
    port (
      wb_clk_i     : in  std_logic;
      wb_rst_i     : in  std_logic;
      arst_i       : in  std_logic;
      wb_adr_i     : in  std_logic_vector(2 downto 0);
      wb_dat_i     : in  std_logic_vector(7 downto 0);
      wb_dat_o     : out std_logic_vector(7 downto 0);
      wb_we_i      : in  std_logic;
      wb_stb_i     : in  std_logic;
      wb_cyc_i     : in  std_logic;
      wb_ack_o     : out std_logic;
      wb_inta_o    : out std_logic;
      scl_pad_i    : in  std_logic;
      scl_pad_o    : out std_logic;
      scl_padoen_o : out std_logic;
      sda_pad_i    : in  std_logic;
      sda_pad_o    : out std_logic;
      sda_padoen_o : out std_logic);
  end component i2c_master_top;
  -- signals from bridge
  signal wb_clk_o     : std_logic;
  signal wb_rst_o     : std_logic := '0';
  signal wb_adr_o     : std_logic_vector(c_WB_AWIDTH-1 downto 0);
  signal wb_dat_o     : std_logic_vector(c_WB_DWIDTH-1 downto 0);
  signal wb_dat_i     : std_logic_vector(c_WB_DWIDTH-1 downto 0);
  signal wb_sel_o     : std_logic_vector((c_WB_DWIDTH/8)-1 downto 0);
  signal wb_we_o      : std_logic;
  signal wb_stb_o     : std_logic;
  signal wb_cyc_o     : std_logic;
  signal wb_ack_i     : std_logic;
  signal wb_err_i     : std_logic;
  signal wb_rty_i     : std_logic;
  signal wb_inta_i    : std_logic;
  signal scl_pad_i    : std_logic;
  signal scl_pad_o    : std_logic;
  signal scl_padoen_o : std_logic;
  signal sda_pad_i    : std_logic;
  signal sda_pad_o    : std_logic;
  signal sda_padoen_o : std_logic;
begin

-- Instantiation of components
  cmp_axis_wbm_bridge : axis_wbm_bridge
    generic map (
      g_AXI_AWIDTH => C_S00_AXI_ADDR_WIDTH,
      g_WB_AWIDTH  => c_WB_AWIDTH,
      g_AXI_DWIDTH => C_S00_AXI_DATA_WIDTH,
      g_WB_DWIDTH  => c_WB_DWIDTH,
      g_WB_BYTEADDR => true)
    port map (
      wb_clk_o      => wb_clk_o,
      wb_rst_o      => wb_rst_o,
      wb_adr_o      => wb_adr_o,
      wb_dat_o      => wb_dat_o,
      wb_dat_i      => wb_dat_i,
      wb_sel_o      => wb_sel_o,
      wb_we_o       => wb_we_o,
      wb_stb_o      => wb_stb_o,
      wb_cyc_o      => wb_cyc_o,
      wb_ack_i      => wb_ack_i,
      wb_err_i      => wb_err_i,
      wb_rty_i      => wb_rty_i,
      wb_inta_i     => wb_inta_i,
      axi_aclk_i    => s00_axi_aclk,
      axi_aresetn_i => s00_axi_aresetn,
      axi_awaddr_i  => s00_axi_awaddr,
      axi_awprot_i  => s00_axi_awprot,
      axi_awvalid_i => s00_axi_awvalid,
      axi_awready_o => s00_axi_awready,
      axi_wdata_i   => s00_axi_wdata,
      axi_wstrb_i   => s00_axi_wstrb,
      axi_wvalid_i  => s00_axi_wvalid,
      axi_wready_o  => s00_axi_wready,
      axi_bresp_o   => s00_axi_bresp,
      axi_bvalid_o  => s00_axi_bvalid,
      axi_bready_i  => s00_axi_bready,
      axi_araddr_i  => s00_axi_araddr,
      axi_arprot_i  => s00_axi_arprot,
      axi_arvalid_i => s00_axi_arvalid,
      axi_arready_o => s00_axi_arready,
      axi_rdata_o   => s00_axi_rdata,
      axi_rresp_o   => s00_axi_rresp,
      axi_rvalid_o  => s00_axi_rvalid,
      axi_rready_i  => s00_axi_rready,
      axi_int_o     => axi_int_o);

  cmp_i2c_master_top : i2c_master_top
    generic map (
      ARST_LVL => '0')
    port map (
      wb_clk_i     => wb_clk_o,
      wb_rst_i     => wb_rst_o,
      arst_i       => '1',
      wb_adr_i     => wb_adr_o,
      wb_dat_i     => wb_dat_o,
      wb_dat_o     => wb_dat_i,
      wb_we_i      => wb_we_o,
      wb_stb_i     => wb_stb_o,
      wb_cyc_i     => wb_cyc_o,
      wb_ack_o     => wb_ack_i,
      wb_inta_o    => wb_inta_i,
      scl_pad_i    => scl_pad_i,
      scl_pad_o    => scl_pad_o,
      scl_padoen_o => scl_padoen_o,
      sda_pad_i    => sda_pad_i,
      sda_pad_o    => sda_pad_o,
      sda_padoen_o => sda_padoen_o);

  -- unused signals
  wb_err_i <= '0';
  wb_rty_i <= '0';

  -- I2C signals (signals have external pull-ups)
  i2c_scl_io <= 'Z' when scl_padoen_o = '1' else scl_pad_o;
  scl_pad_i  <= i2c_scl_io;
  i2c_sda_io <= 'Z' when sda_padoen_o = '1' else sda_pad_o;
  sda_pad_i  <= i2c_sda_io;
  
end rtl;
