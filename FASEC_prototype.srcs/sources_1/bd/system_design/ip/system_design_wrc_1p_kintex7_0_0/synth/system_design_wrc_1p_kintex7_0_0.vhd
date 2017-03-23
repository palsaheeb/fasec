-- (c) Copyright 1995-2017 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- DO NOT MODIFY THIS FILE.

-- IP VLNV: CERN:wrc:wrc_1p_kintex7:2.3.1
-- IP Revision: 13

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY system_design_wrc_1p_kintex7_0_0 IS
  PORT (
    clk_20m_vcxo_i : IN STD_LOGIC;
    clk_aux_p_i : IN STD_LOGIC;
    clk_aux_n_i : IN STD_LOGIC;
    gtp_dedicated_clk_p_i : IN STD_LOGIC;
    gtp_dedicated_clk_n_i : IN STD_LOGIC;
    gtp0_activity_led_o : OUT STD_LOGIC;
    gtp0_synced_led_o : OUT STD_LOGIC;
    gtp0_link_led_o : OUT STD_LOGIC;
    gtp0_wrmode_led_o : OUT STD_LOGIC;
    dac_sclk_o : OUT STD_LOGIC;
    dac_din_o : OUT STD_LOGIC;
    dac_cs1_n_o : OUT STD_LOGIC;
    dac_cs2_n_o : OUT STD_LOGIC;
    fpga_scl_b : INOUT STD_LOGIC;
    fpga_sda_b : INOUT STD_LOGIC;
    button_rst_n_i : IN STD_LOGIC;
    thermo_id : INOUT STD_LOGIC;
    gtp0_txp_o : OUT STD_LOGIC;
    gtp0_txn_o : OUT STD_LOGIC;
    gtp0_rxp_i : IN STD_LOGIC;
    gtp0_rxn_i : IN STD_LOGIC;
    gtp0_mod_def0_b : IN STD_LOGIC;
    gtp0_mod_def1_b : INOUT STD_LOGIC;
    gtp0_mod_def2_b : INOUT STD_LOGIC;
    gtp0_rate_select_b : INOUT STD_LOGIC;
    gtp0_tx_fault_i : IN STD_LOGIC;
    gtp0_tx_disable_o : OUT STD_LOGIC;
    gtp0_los_i : IN STD_LOGIC;
    uart_rxd_i : IN STD_LOGIC;
    uart_txd_o : OUT STD_LOGIC;
    ext_clk_i : IN STD_LOGIC;
    pps_i : IN STD_LOGIC;
    pps_ctrl_o : OUT STD_LOGIC;
    term_en_o : OUT STD_LOGIC;
    pps_o : OUT STD_LOGIC;
    axi_int_o : OUT STD_LOGIC;
    s00_axi_aclk_o : OUT STD_LOGIC;
    s00_axi_aresetn : IN STD_LOGIC;
    s00_axi_awaddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s00_axi_awprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    s00_axi_awvalid : IN STD_LOGIC;
    s00_axi_awready : OUT STD_LOGIC;
    s00_axi_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s00_axi_wstrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s00_axi_wvalid : IN STD_LOGIC;
    s00_axi_wready : OUT STD_LOGIC;
    s00_axi_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s00_axi_bvalid : OUT STD_LOGIC;
    s00_axi_bready : IN STD_LOGIC;
    s00_axi_araddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s00_axi_arprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    s00_axi_arvalid : IN STD_LOGIC;
    s00_axi_arready : OUT STD_LOGIC;
    s00_axi_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    s00_axi_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s00_axi_rvalid : OUT STD_LOGIC;
    s00_axi_rready : IN STD_LOGIC
  );
END system_design_wrc_1p_kintex7_0_0;

ARCHITECTURE system_design_wrc_1p_kintex7_0_0_arch OF system_design_wrc_1p_kintex7_0_0 IS
  ATTRIBUTE DowngradeIPIdentifiedWarnings : STRING;
  ATTRIBUTE DowngradeIPIdentifiedWarnings OF system_design_wrc_1p_kintex7_0_0_arch: ARCHITECTURE IS "yes";
  COMPONENT wrc_1p_kintex7 IS
    GENERIC (
      TAR_ADDR_WDTH : INTEGER
    );
    PORT (
      clk_20m_vcxo_i : IN STD_LOGIC;
      clk_aux_p_i : IN STD_LOGIC;
      clk_aux_n_i : IN STD_LOGIC;
      gtp_dedicated_clk_p_i : IN STD_LOGIC;
      gtp_dedicated_clk_n_i : IN STD_LOGIC;
      gtp0_activity_led_o : OUT STD_LOGIC;
      gtp0_synced_led_o : OUT STD_LOGIC;
      gtp0_link_led_o : OUT STD_LOGIC;
      gtp0_wrmode_led_o : OUT STD_LOGIC;
      dac_sclk_o : OUT STD_LOGIC;
      dac_din_o : OUT STD_LOGIC;
      dac_cs1_n_o : OUT STD_LOGIC;
      dac_cs2_n_o : OUT STD_LOGIC;
      fpga_scl_b : INOUT STD_LOGIC;
      fpga_sda_b : INOUT STD_LOGIC;
      button_rst_n_i : IN STD_LOGIC;
      thermo_id : INOUT STD_LOGIC;
      gtp0_txp_o : OUT STD_LOGIC;
      gtp0_txn_o : OUT STD_LOGIC;
      gtp0_rxp_i : IN STD_LOGIC;
      gtp0_rxn_i : IN STD_LOGIC;
      gtp0_mod_def0_b : IN STD_LOGIC;
      gtp0_mod_def1_b : INOUT STD_LOGIC;
      gtp0_mod_def2_b : INOUT STD_LOGIC;
      gtp0_rate_select_b : INOUT STD_LOGIC;
      gtp0_tx_fault_i : IN STD_LOGIC;
      gtp0_tx_disable_o : OUT STD_LOGIC;
      gtp0_los_i : IN STD_LOGIC;
      uart_rxd_i : IN STD_LOGIC;
      uart_txd_o : OUT STD_LOGIC;
      ext_clk_i : IN STD_LOGIC;
      pps_i : IN STD_LOGIC;
      pps_ctrl_o : OUT STD_LOGIC;
      term_en_o : OUT STD_LOGIC;
      pps_o : OUT STD_LOGIC;
      axi_int_o : OUT STD_LOGIC;
      s00_axi_aclk_o : OUT STD_LOGIC;
      s00_axi_aresetn : IN STD_LOGIC;
      s00_axi_awaddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s00_axi_awprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      s00_axi_awvalid : IN STD_LOGIC;
      s00_axi_awready : OUT STD_LOGIC;
      s00_axi_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s00_axi_wstrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      s00_axi_wvalid : IN STD_LOGIC;
      s00_axi_wready : OUT STD_LOGIC;
      s00_axi_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      s00_axi_bvalid : OUT STD_LOGIC;
      s00_axi_bready : IN STD_LOGIC;
      s00_axi_araddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s00_axi_arprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      s00_axi_arvalid : IN STD_LOGIC;
      s00_axi_arready : OUT STD_LOGIC;
      s00_axi_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      s00_axi_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      s00_axi_rvalid : OUT STD_LOGIC;
      s00_axi_rready : IN STD_LOGIC
    );
  END COMPONENT wrc_1p_kintex7;
  ATTRIBUTE X_CORE_INFO : STRING;
  ATTRIBUTE X_CORE_INFO OF system_design_wrc_1p_kintex7_0_0_arch: ARCHITECTURE IS "wrc_1p_kintex7,Vivado 2016.2";
  ATTRIBUTE CHECK_LICENSE_TYPE : STRING;
  ATTRIBUTE CHECK_LICENSE_TYPE OF system_design_wrc_1p_kintex7_0_0_arch : ARCHITECTURE IS "system_design_wrc_1p_kintex7_0_0,wrc_1p_kintex7,{}";
  ATTRIBUTE X_INTERFACE_INFO : STRING;
  ATTRIBUTE X_INTERFACE_INFO OF gtp0_txp_o: SIGNAL IS "xilinx.com:interface:sfp:1.0 gtp_wr TXP";
  ATTRIBUTE X_INTERFACE_INFO OF gtp0_txn_o: SIGNAL IS "xilinx.com:interface:sfp:1.0 gtp_wr TXN";
  ATTRIBUTE X_INTERFACE_INFO OF gtp0_rxp_i: SIGNAL IS "xilinx.com:interface:sfp:1.0 gtp_wr RXP";
  ATTRIBUTE X_INTERFACE_INFO OF gtp0_rxn_i: SIGNAL IS "xilinx.com:interface:sfp:1.0 gtp_wr RXN";
  ATTRIBUTE X_INTERFACE_INFO OF gtp0_mod_def0_b: SIGNAL IS "xilinx.com:interface:sfp:1.0 gtp_wr MOD_ABS";
  ATTRIBUTE X_INTERFACE_INFO OF gtp0_mod_def1_b: SIGNAL IS "xilinx.com:interface:sfp:1.0 gtp_wr SCL";
  ATTRIBUTE X_INTERFACE_INFO OF gtp0_mod_def2_b: SIGNAL IS "xilinx.com:interface:sfp:1.0 gtp_wr SDA";
  ATTRIBUTE X_INTERFACE_INFO OF gtp0_tx_fault_i: SIGNAL IS "xilinx.com:interface:sfp:1.0 gtp_wr TX_FAULT";
  ATTRIBUTE X_INTERFACE_INFO OF gtp0_tx_disable_o: SIGNAL IS "xilinx.com:interface:sfp:1.0 gtp_wr TX_DISABLE";
  ATTRIBUTE X_INTERFACE_INFO OF gtp0_los_i: SIGNAL IS "xilinx.com:interface:sfp:1.0 gtp_wr RX_LOS";
  ATTRIBUTE X_INTERFACE_INFO OF uart_rxd_i: SIGNAL IS "xilinx.com:interface:uart:1.0 uart_wr RxD";
  ATTRIBUTE X_INTERFACE_INFO OF uart_txd_o: SIGNAL IS "xilinx.com:interface:uart:1.0 uart_wr TxD";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_aclk_o: SIGNAL IS "xilinx.com:signal:clock:1.0 s00_clk CLK";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_aresetn: SIGNAL IS "xilinx.com:signal:reset:1.0 s00_resetn RST";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_awaddr: SIGNAL IS "xilinx.com:interface:aximm:1.0 s00_axi AWADDR";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_awprot: SIGNAL IS "xilinx.com:interface:aximm:1.0 s00_axi AWPROT";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_awvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 s00_axi AWVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_awready: SIGNAL IS "xilinx.com:interface:aximm:1.0 s00_axi AWREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_wdata: SIGNAL IS "xilinx.com:interface:aximm:1.0 s00_axi WDATA";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_wstrb: SIGNAL IS "xilinx.com:interface:aximm:1.0 s00_axi WSTRB";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_wvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 s00_axi WVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_wready: SIGNAL IS "xilinx.com:interface:aximm:1.0 s00_axi WREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_bresp: SIGNAL IS "xilinx.com:interface:aximm:1.0 s00_axi BRESP";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_bvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 s00_axi BVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_bready: SIGNAL IS "xilinx.com:interface:aximm:1.0 s00_axi BREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_araddr: SIGNAL IS "xilinx.com:interface:aximm:1.0 s00_axi ARADDR";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_arprot: SIGNAL IS "xilinx.com:interface:aximm:1.0 s00_axi ARPROT";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_arvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 s00_axi ARVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_arready: SIGNAL IS "xilinx.com:interface:aximm:1.0 s00_axi ARREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_rdata: SIGNAL IS "xilinx.com:interface:aximm:1.0 s00_axi RDATA";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_rresp: SIGNAL IS "xilinx.com:interface:aximm:1.0 s00_axi RRESP";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_rvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 s00_axi RVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_rready: SIGNAL IS "xilinx.com:interface:aximm:1.0 s00_axi RREADY";
BEGIN
  U0 : wrc_1p_kintex7
    GENERIC MAP (
      TAR_ADDR_WDTH => 13
    )
    PORT MAP (
      clk_20m_vcxo_i => clk_20m_vcxo_i,
      clk_aux_p_i => clk_aux_p_i,
      clk_aux_n_i => clk_aux_n_i,
      gtp_dedicated_clk_p_i => gtp_dedicated_clk_p_i,
      gtp_dedicated_clk_n_i => gtp_dedicated_clk_n_i,
      gtp0_activity_led_o => gtp0_activity_led_o,
      gtp0_synced_led_o => gtp0_synced_led_o,
      gtp0_link_led_o => gtp0_link_led_o,
      gtp0_wrmode_led_o => gtp0_wrmode_led_o,
      dac_sclk_o => dac_sclk_o,
      dac_din_o => dac_din_o,
      dac_cs1_n_o => dac_cs1_n_o,
      dac_cs2_n_o => dac_cs2_n_o,
      fpga_scl_b => fpga_scl_b,
      fpga_sda_b => fpga_sda_b,
      button_rst_n_i => button_rst_n_i,
      thermo_id => thermo_id,
      gtp0_txp_o => gtp0_txp_o,
      gtp0_txn_o => gtp0_txn_o,
      gtp0_rxp_i => gtp0_rxp_i,
      gtp0_rxn_i => gtp0_rxn_i,
      gtp0_mod_def0_b => gtp0_mod_def0_b,
      gtp0_mod_def1_b => gtp0_mod_def1_b,
      gtp0_mod_def2_b => gtp0_mod_def2_b,
      gtp0_rate_select_b => gtp0_rate_select_b,
      gtp0_tx_fault_i => gtp0_tx_fault_i,
      gtp0_tx_disable_o => gtp0_tx_disable_o,
      gtp0_los_i => gtp0_los_i,
      uart_rxd_i => uart_rxd_i,
      uart_txd_o => uart_txd_o,
      ext_clk_i => ext_clk_i,
      pps_i => pps_i,
      pps_ctrl_o => pps_ctrl_o,
      term_en_o => term_en_o,
      pps_o => pps_o,
      axi_int_o => axi_int_o,
      s00_axi_aclk_o => s00_axi_aclk_o,
      s00_axi_aresetn => s00_axi_aresetn,
      s00_axi_awaddr => s00_axi_awaddr,
      s00_axi_awprot => s00_axi_awprot,
      s00_axi_awvalid => s00_axi_awvalid,
      s00_axi_awready => s00_axi_awready,
      s00_axi_wdata => s00_axi_wdata,
      s00_axi_wstrb => s00_axi_wstrb,
      s00_axi_wvalid => s00_axi_wvalid,
      s00_axi_wready => s00_axi_wready,
      s00_axi_bresp => s00_axi_bresp,
      s00_axi_bvalid => s00_axi_bvalid,
      s00_axi_bready => s00_axi_bready,
      s00_axi_araddr => s00_axi_araddr,
      s00_axi_arprot => s00_axi_arprot,
      s00_axi_arvalid => s00_axi_arvalid,
      s00_axi_arready => s00_axi_arready,
      s00_axi_rdata => s00_axi_rdata,
      s00_axi_rresp => s00_axi_rresp,
      s00_axi_rvalid => s00_axi_rvalid,
      s00_axi_rready => s00_axi_rready
    );
END system_design_wrc_1p_kintex7_0_0_arch;
