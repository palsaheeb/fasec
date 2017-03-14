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

-- IP VLNV: CERN:wrc:wrc_1p_kintex7:1.3
-- IP Revision: 5

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY system_design_wrc_1p_kintex7_0_0 IS
  PORT (
    clk_25m_vcxo_i : IN STD_LOGIC;
    clk_aux_p_i : IN STD_LOGIC;
    clk_aux_n_i : IN STD_LOGIC;
    gtp_dedicated_clk_p_i : IN STD_LOGIC;
    gtp_dedicated_clk_n_i : IN STD_LOGIC;
    clk_100mhz_i : IN STD_LOGIC;
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
    pll_cs_n_o : OUT STD_LOGIC;
    pll_sck_o : OUT STD_LOGIC;
    pll_sdi_o : OUT STD_LOGIC;
    pll_sdo_i : IN STD_LOGIC;
    pll_reset_n_o : OUT STD_LOGIC;
    pll_status_i : IN STD_LOGIC;
    pll_sync_n_o : OUT STD_LOGIC;
    pll_refsel_o : OUT STD_LOGIC;
    pll_ld_i : IN STD_LOGIC;
    ext_clk_i : IN STD_LOGIC;
    pps_i : IN STD_LOGIC;
    pps_ctrl_o : OUT STD_LOGIC;
    term_en_o : OUT STD_LOGIC;
    pps_o : OUT STD_LOGIC
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
      clk_25m_vcxo_i : IN STD_LOGIC;
      clk_aux_p_i : IN STD_LOGIC;
      clk_aux_n_i : IN STD_LOGIC;
      gtp_dedicated_clk_p_i : IN STD_LOGIC;
      gtp_dedicated_clk_n_i : IN STD_LOGIC;
      clk_100mhz_i : IN STD_LOGIC;
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
      pll_cs_n_o : OUT STD_LOGIC;
      pll_sck_o : OUT STD_LOGIC;
      pll_sdi_o : OUT STD_LOGIC;
      pll_sdo_i : IN STD_LOGIC;
      pll_reset_n_o : OUT STD_LOGIC;
      pll_status_i : IN STD_LOGIC;
      pll_sync_n_o : OUT STD_LOGIC;
      pll_refsel_o : OUT STD_LOGIC;
      pll_ld_i : IN STD_LOGIC;
      ext_clk_i : IN STD_LOGIC;
      pps_i : IN STD_LOGIC;
      pps_ctrl_o : OUT STD_LOGIC;
      term_en_o : OUT STD_LOGIC;
      pps_o : OUT STD_LOGIC
    );
  END COMPONENT wrc_1p_kintex7;
  ATTRIBUTE X_INTERFACE_INFO : STRING;
  ATTRIBUTE X_INTERFACE_INFO OF clk_aux_p_i: SIGNAL IS "xilinx.com:interface:diff_clock:1.0 clk_aux_i CLK_P";
  ATTRIBUTE X_INTERFACE_INFO OF clk_aux_n_i: SIGNAL IS "xilinx.com:interface:diff_clock:1.0 clk_aux_i CLK_N";
  ATTRIBUTE X_INTERFACE_INFO OF gtp_dedicated_clk_p_i: SIGNAL IS "xilinx.com:interface:diff_clock:1.0 gtp_dedicated_clk_i CLK_P";
  ATTRIBUTE X_INTERFACE_INFO OF gtp_dedicated_clk_n_i: SIGNAL IS "xilinx.com:interface:diff_clock:1.0 gtp_dedicated_clk_i CLK_N";
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
BEGIN
  U0 : wrc_1p_kintex7
    GENERIC MAP (
      TAR_ADDR_WDTH => 13
    )
    PORT MAP (
      clk_25m_vcxo_i => clk_25m_vcxo_i,
      clk_aux_p_i => clk_aux_p_i,
      clk_aux_n_i => clk_aux_n_i,
      gtp_dedicated_clk_p_i => gtp_dedicated_clk_p_i,
      gtp_dedicated_clk_n_i => gtp_dedicated_clk_n_i,
      clk_100mhz_i => clk_100mhz_i,
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
      pll_cs_n_o => pll_cs_n_o,
      pll_sck_o => pll_sck_o,
      pll_sdi_o => pll_sdi_o,
      pll_sdo_i => pll_sdo_i,
      pll_reset_n_o => pll_reset_n_o,
      pll_status_i => pll_status_i,
      pll_sync_n_o => pll_sync_n_o,
      pll_refsel_o => pll_refsel_o,
      pll_ld_i => pll_ld_i,
      ext_clk_i => ext_clk_i,
      pps_i => pps_i,
      pps_ctrl_o => pps_ctrl_o,
      term_en_o => term_en_o,
      pps_o => pps_o
    );
END system_design_wrc_1p_kintex7_0_0_arch;
