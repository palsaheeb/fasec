--Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2016.2 (lin64) Build 1577090 Thu Jun  2 16:32:35 MDT 2016
--Date        : Wed Nov 30 15:00:47 2016
--Host        : lapte24154 running 64-bit openSUSE Leap 42.1 (x86_64)
--Command     : generate_target system_design_wrapper.bd
--Design      : system_design_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity system_design_wrapper is
  port (
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_cas_n : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    FMC1_CLK0C2M_N_o : out STD_LOGIC;
    FMC1_CLK0C2M_P_o : out STD_LOGIC;
    FMC1_CLK0M2C_N_i : in STD_LOGIC;
    FMC1_CLK0M2C_P_i : in STD_LOGIC;
    FMC1_LA_N_b : inout STD_LOGIC_VECTOR ( 33 downto 0 );
    FMC1_LA_P_b : inout STD_LOGIC_VECTOR ( 33 downto 0 );
    FMC1_PRSNTM2C_n_i : in STD_LOGIC;
    FMC2_CLK0C2M_N_o : out STD_LOGIC;
    FMC2_CLK0C2M_P_o : out STD_LOGIC;
    FMC2_CLK0M2C_N_i : in STD_LOGIC;
    FMC2_CLK0M2C_P_i : in STD_LOGIC;
    FMC2_LA_N_b : inout STD_LOGIC_VECTOR ( 33 downto 0 );
    FMC2_LA_P_b : inout STD_LOGIC_VECTOR ( 33 downto 0 );
    FMC2_PRSNTM2C_n_i : in STD_LOGIC;
    diff_clock_rtl_clk_n : in STD_LOGIC;
    diff_clock_rtl_clk_p : in STD_LOGIC;
    dig_in1_i : in STD_LOGIC;
    dig_in2_i : in STD_LOGIC;
    dig_in3_n_i : in STD_LOGIC;
    dig_in4_n_i : in STD_LOGIC;
    dig_out5_n : out STD_LOGIC;
    dig_out6_n : out STD_LOGIC;
    dig_outs_i : out STD_LOGIC_VECTOR ( 3 downto 0 );
    eeprom_scl : inout STD_LOGIC;
    eeprom_sda : inout STD_LOGIC;
    fmcx_scl : inout STD_LOGIC;
    fmcx_sda : inout STD_LOGIC;
    led_col_pl_o : out STD_LOGIC_VECTOR ( 3 downto 0 );
    led_line_en_pl_o : out STD_LOGIC;
    led_line_pl_o : out STD_LOGIC;
    osc100_clk_i : in STD_LOGIC;
    pb_gp_i : in STD_LOGIC;
    sfp_moddef1_scl : inout STD_LOGIC;
    sfp_moddef2_sda : inout STD_LOGIC;
    sfp_rtl_rxn : in STD_LOGIC;
    sfp_rtl_rxp : in STD_LOGIC;
    sfp_rtl_txn : out STD_LOGIC;
    sfp_rtl_txp : out STD_LOGIC;
    t_wr_txdisable : out STD_LOGIC_VECTOR ( 0 to 0 );
    watchdog_pl_o : out STD_LOGIC
  );
end system_design_wrapper;

architecture STRUCTURE of system_design_wrapper is
  component system_design is
  port (
    DDR_cas_n : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
    diff_clock_rtl_clk_n : in STD_LOGIC;
    diff_clock_rtl_clk_p : in STD_LOGIC;
    sfp_rtl_rxn : in STD_LOGIC;
    sfp_rtl_rxp : in STD_LOGIC;
    sfp_rtl_txn : out STD_LOGIC;
    sfp_rtl_txp : out STD_LOGIC;
    pb_gp_i : in STD_LOGIC;
    led_col_pl_o : out STD_LOGIC_VECTOR ( 3 downto 0 );
    led_line_en_pl_o : out STD_LOGIC;
    led_line_pl_o : out STD_LOGIC;
    fmcx_scl : inout STD_LOGIC;
    fmcx_sda : inout STD_LOGIC;
    eeprom_scl : inout STD_LOGIC;
    eeprom_sda : inout STD_LOGIC;
    FMC2_LA_P_b : inout STD_LOGIC_VECTOR ( 33 downto 0 );
    FMC2_LA_N_b : inout STD_LOGIC_VECTOR ( 33 downto 0 );
    FMC1_LA_P_b : inout STD_LOGIC_VECTOR ( 33 downto 0 );
    FMC1_LA_N_b : inout STD_LOGIC_VECTOR ( 33 downto 0 );
    FMC2_PRSNTM2C_n_i : in STD_LOGIC;
    FMC2_CLK0M2C_P_i : in STD_LOGIC;
    FMC2_CLK0M2C_N_i : in STD_LOGIC;
    FMC1_PRSNTM2C_n_i : in STD_LOGIC;
    FMC1_CLK0M2C_P_i : in STD_LOGIC;
    FMC1_CLK0M2C_N_i : in STD_LOGIC;
    FMC2_CLK0C2M_P_o : out STD_LOGIC;
    FMC2_CLK0C2M_N_o : out STD_LOGIC;
    FMC1_CLK0C2M_P_o : out STD_LOGIC;
    FMC1_CLK0C2M_N_o : out STD_LOGIC;
    osc100_clk_i : in STD_LOGIC;
    t_wr_txdisable : out STD_LOGIC_VECTOR ( 0 to 0 );
    sfp_moddef1_scl : inout STD_LOGIC;
    sfp_moddef2_sda : inout STD_LOGIC;
    watchdog_pl_o : out STD_LOGIC;
    dig_outs_i : out STD_LOGIC_VECTOR ( 3 downto 0 );
    dig_out5_n : out STD_LOGIC;
    dig_out6_n : out STD_LOGIC;
    dig_in1_i : in STD_LOGIC;
    dig_in2_i : in STD_LOGIC;
    dig_in3_n_i : in STD_LOGIC;
    dig_in4_n_i : in STD_LOGIC
  );
  end component system_design;
begin
system_design_i: component system_design
     port map (
      DDR_addr(14 downto 0) => DDR_addr(14 downto 0),
      DDR_ba(2 downto 0) => DDR_ba(2 downto 0),
      DDR_cas_n => DDR_cas_n,
      DDR_ck_n => DDR_ck_n,
      DDR_ck_p => DDR_ck_p,
      DDR_cke => DDR_cke,
      DDR_cs_n => DDR_cs_n,
      DDR_dm(3 downto 0) => DDR_dm(3 downto 0),
      DDR_dq(31 downto 0) => DDR_dq(31 downto 0),
      DDR_dqs_n(3 downto 0) => DDR_dqs_n(3 downto 0),
      DDR_dqs_p(3 downto 0) => DDR_dqs_p(3 downto 0),
      DDR_odt => DDR_odt,
      DDR_ras_n => DDR_ras_n,
      DDR_reset_n => DDR_reset_n,
      DDR_we_n => DDR_we_n,
      FIXED_IO_ddr_vrn => FIXED_IO_ddr_vrn,
      FIXED_IO_ddr_vrp => FIXED_IO_ddr_vrp,
      FIXED_IO_mio(53 downto 0) => FIXED_IO_mio(53 downto 0),
      FIXED_IO_ps_clk => FIXED_IO_ps_clk,
      FIXED_IO_ps_porb => FIXED_IO_ps_porb,
      FIXED_IO_ps_srstb => FIXED_IO_ps_srstb,
      FMC1_CLK0C2M_N_o => FMC1_CLK0C2M_N_o,
      FMC1_CLK0C2M_P_o => FMC1_CLK0C2M_P_o,
      FMC1_CLK0M2C_N_i => FMC1_CLK0M2C_N_i,
      FMC1_CLK0M2C_P_i => FMC1_CLK0M2C_P_i,
      FMC1_LA_N_b(33 downto 0) => FMC1_LA_N_b(33 downto 0),
      FMC1_LA_P_b(33 downto 0) => FMC1_LA_P_b(33 downto 0),
      FMC1_PRSNTM2C_n_i => FMC1_PRSNTM2C_n_i,
      FMC2_CLK0C2M_N_o => FMC2_CLK0C2M_N_o,
      FMC2_CLK0C2M_P_o => FMC2_CLK0C2M_P_o,
      FMC2_CLK0M2C_N_i => FMC2_CLK0M2C_N_i,
      FMC2_CLK0M2C_P_i => FMC2_CLK0M2C_P_i,
      FMC2_LA_N_b(33 downto 0) => FMC2_LA_N_b(33 downto 0),
      FMC2_LA_P_b(33 downto 0) => FMC2_LA_P_b(33 downto 0),
      FMC2_PRSNTM2C_n_i => FMC2_PRSNTM2C_n_i,
      diff_clock_rtl_clk_n => diff_clock_rtl_clk_n,
      diff_clock_rtl_clk_p => diff_clock_rtl_clk_p,
      dig_in1_i => dig_in1_i,
      dig_in2_i => dig_in2_i,
      dig_in3_n_i => dig_in3_n_i,
      dig_in4_n_i => dig_in4_n_i,
      dig_out5_n => dig_out5_n,
      dig_out6_n => dig_out6_n,
      dig_outs_i(3 downto 0) => dig_outs_i(3 downto 0),
      eeprom_scl => eeprom_scl,
      eeprom_sda => eeprom_sda,
      fmcx_scl => fmcx_scl,
      fmcx_sda => fmcx_sda,
      led_col_pl_o(3 downto 0) => led_col_pl_o(3 downto 0),
      led_line_en_pl_o => led_line_en_pl_o,
      led_line_pl_o => led_line_pl_o,
      osc100_clk_i => osc100_clk_i,
      pb_gp_i => pb_gp_i,
      sfp_moddef1_scl => sfp_moddef1_scl,
      sfp_moddef2_sda => sfp_moddef2_sda,
      sfp_rtl_rxn => sfp_rtl_rxn,
      sfp_rtl_rxp => sfp_rtl_rxp,
      sfp_rtl_txn => sfp_rtl_txn,
      sfp_rtl_txp => sfp_rtl_txp,
      t_wr_txdisable(0) => t_wr_txdisable(0),
      watchdog_pl_o => watchdog_pl_o
    );
end STRUCTURE;
