------------------------------------------------------------------------------
-- Title      : FASEC HW-Test
-- Project    : FIDS
------------------------------------------------------------------------------
-- Author     : Pieter Van Trappen
-- Company    : CERN TE-ABT-EC
-- Created    : 2016-08-19
-- Last update: 2016-08-31
-- Platform   : FPGA-generic
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: A generic design for an FMC slot, supporting a different set
-- of FMC card (set by top level gneeric)
-------------------------------------------------------------------------------
-- top_mod.vhd Copyright (c) 2016 CERN
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
-- (see also version_info.txt)
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library xil_pvtmisc;
use xil_pvtmisc.myPackage.all;

entity fasec_hwtest is
  generic(
    -- Parameters of Axi Slave Bus Interface S00_AXI
    g_S00_AXI_DATA_WIDTH : integer := 32;
    g_S00_AXI_ADDR_WIDTH : integer := 32;
    g_FMC1 : String := "EDA-0NONE";     -- unconstrained, otherwise Vivado
                                        -- produces errors when integrating in
                                        -- Block Design
    g_FMC2 : String := "EDA-0NONE");
  port (
    ps_clk_i          : in    std_logic;  -- clock from Zynq PS (100 MHz)
    osc100_clk_i      : in    std_logic;  -- clock from oscillator (100 MHz)
    -- FMC 1-2 user IO
    FMC2_LA_P_b       : inout std_logic_vector(33 downto 0);
    FMC2_LA_N_b       : inout std_logic_vector(33 downto 0);
    FMC1_LA_P_b       : inout std_logic_vector(33 downto 0);
    FMC1_LA_N_b       : inout std_logic_vector(33 downto 0);
    -- FMC misc IO
    FMC2_PRSNTM2C_n_i : in    std_logic;
    FMC2_CLK0M2C_P_i  : in    std_logic;
    FMC2_CLK0M2C_N_i  : in    std_logic;
    FMC2_CLK0C2M_P_o  : out   std_logic;
    FMC2_CLK0C2M_N_o  : out   std_logic;
    FMC1_PRSNTM2C_n_i : in    std_logic;
    FMC1_CLK0M2C_P_i  : in    std_logic;
    FMC1_CLK0M2C_N_i  : in    std_logic;
    FMC1_CLK0C2M_P_o  : out   std_logic;
    FMC1_CLK0C2M_N_o  : out   std_logic;
    -- FASEC signals
    pb_gp_n_i         : in    std_logic;
    led_col_pl_o      : out   std_logic_vector (3 downto 0);  -- anode green / cathode red
    led_line_en_pl_o  : out   std_logic;  -- output 1B Hi-Z when asserted
    led_line_pl_o     : out   std_logic;  -- output 1B: cathode green / anode red
    -- AXI4-LITE slave interface
    s00_axi_aclk      : in    std_logic;
    s00_axi_aresetn   : in    std_logic;
    s00_axi_awaddr    : in    std_logic_vector(g_S00_AXI_ADDR_WIDTH-1 downto 0);
    s00_axi_awprot    : in    std_logic_vector(2 downto 0);
    s00_axi_awvalid   : in    std_logic;
    s00_axi_awready   : out   std_logic;
    s00_axi_wdata     : in    std_logic_vector(g_S00_AXI_DATA_WIDTH-1 downto 0);
    s00_axi_wstrb     : in    std_logic_vector((g_S00_AXI_DATA_WIDTH/8)-1 downto 0);
    s00_axi_wvalid    : in    std_logic;
    s00_axi_wready    : out   std_logic;
    s00_axi_bresp     : out   std_logic_vector(1 downto 0);
    s00_axi_bvalid    : out   std_logic;
    s00_axi_bready    : in    std_logic;
    s00_axi_araddr    : in    std_logic_vector(g_S00_AXI_ADDR_WIDTH-1 downto 0);
    s00_axi_arprot    : in    std_logic_vector(2 downto 0);
    s00_axi_arvalid   : in    std_logic;
    s00_axi_arready   : out   std_logic;
    s00_axi_rdata     : out   std_logic_vector(g_S00_AXI_DATA_WIDTH-1 downto 0);
    s00_axi_rresp     : out   std_logic_vector(1 downto 0);
    s00_axi_rvalid    : out   std_logic;
    s00_axi_rready    : in    std_logic);
end fasec_hwtest;

architecture rtl of fasec_hwtest is
  -- components
  component general_fmc is
    generic (
      g_FMC  : string(1 to 9);
      g_DMAX : natural);
    port (
      clk_i            : in    std_logic;
      rst_i            : in    std_logic;
      FMC_LA_P_b       : inout std_logic_vector(33 downto 0);
      FMC_LA_N_b       : inout std_logic_vector(33 downto 0);
      FMC_PRSNTM2C_n_i : in    std_logic;
      FMC_CLK0M2C_P_i  : in    std_logic;
      FMC_CLK0M2C_N_i  : in    std_logic;
      FMC_CLK0C2M_P_o  : out   std_logic;
      FMC_CLK0C2M_N_o  : out   std_logic;
      data_i           : in    t_data32(0 to g_DMAX-1);
      data_o           : out    t_data32(0 to g_DMAX-1));
  end component general_fmc;

  -- constants and signals
  constant c_FLASH          : positive                                         := 40000000;  -- 400 ms @ 100 MHz
  constant c_SLAVE_MAXREAD  : positive                                         := 8;
  constant c_SLAVE_MAXWRITE : positive                                         := 8;
  constant c_SLAVE_MAXMEM   : positive                                         := c_SLAVE_MAXREAD + c_SLAVE_MAXWRITE;
  -- AXI slave signals
  signal s_sAxi_dataR       : t_axiMemory(0 to c_SLAVE_MAXREAD-1)              := (others => (others => '0'));
  signal s_sAxi_dataW       : t_axiMemory(c_SLAVE_MAXREAD to c_SLAVE_MAXMEM-1) := (others => (others => '0'));  -- also put to zero in the slave AXI module (cuz buffer)
  signal s_sAxi_dataResetW  : t_axiMemory(c_SLAVE_MAXREAD to c_SLAVE_MAXMEM-1) := (others => (others => '0'));
  -- FMC1-2 signals
  constant c_FMC_DMAX : natural := 8;
  signal s_tick             : std_logic;
  signal s_fmc1_datai, s_fmc1_datao : t_data32(0 to c_FMC_DMAX-1);
  signal s_fmc2_datai, s_fmc2_datao : t_data32(0 to c_FMC_DMAX-1);
begin
  --=============================================================================
  -- FMC1 component
  --=============================================================================  
  general_fmc1: general_fmc
    generic map (
      g_FMC  => g_FMC1,
      g_DMAX => c_FMC_DMAX)
    port map (
      clk_i            => s00_axi_aclk,
      rst_i            => not(s00_axi_aresetn),
      FMC_LA_P_b       => FMC1_LA_P_b(33 downto 0),
      FMC_LA_N_b       => FMC1_LA_N_b(33 downto 0),
      FMC_PRSNTM2C_n_i => FMC1_PRSNTM2C_n_i,
      FMC_CLK0M2C_P_i  => FMC1_CLK0M2C_P_i,
      FMC_CLK0M2C_N_i  => FMC1_CLK0M2C_N_i,
      FMC_CLK0C2M_P_o  => FMC1_CLK0C2M_P_o,
      FMC_CLK0C2M_N_o  => FMC1_CLK0C2M_N_o,
      data_i           => s_fmc1_datai(0 to c_FMC_DMAX-1),
      data_o           => s_fmc1_datao(0 to c_FMC_DMAX-1));
  
  s_sAxi_dataR(0) <= (others=>'0');     -- TODO: generic FMC string
  s_sAxi_dataR(1) <= s_fmc1_datao(0);
  s_sAxi_dataR(2) <= s_fmc1_datao(1);
  s_sAxi_dataR(3) <= s_fmc1_datao(2);

  --=============================================================================
  -- FMC2 component
  --=============================================================================  
  general_fmc2: general_fmc
    generic map (
      g_FMC  => g_FMC2,
      g_DMAX => c_FMC_DMAX)
    port map (
      clk_i            => s00_axi_aclk,
      rst_i            => not(s00_axi_aresetn),
      FMC_LA_P_b       => FMC2_LA_P_b(33 downto 0),
      FMC_LA_N_b       => FMC2_LA_N_b(33 downto 0),
      FMC_PRSNTM2C_n_i => FMC2_PRSNTM2C_n_i,
      FMC_CLK0M2C_P_i  => FMC2_CLK0M2C_P_i,
      FMC_CLK0M2C_N_i  => FMC2_CLK0M2C_N_i,
      FMC_CLK0C2M_P_o  => FMC2_CLK0C2M_P_o,
      FMC_CLK0C2M_N_o  => FMC2_CLK0C2M_N_o,
      data_i           => s_fmc2_datai(0 to c_FMC_DMAX-1),
      data_o           => s_fmc2_datao(0 to c_FMC_DMAX-1));
  
  s_sAxi_dataR(4) <= (others=>'0');     -- TODO: generic FMC string
  s_sAxi_dataR(5) <= s_fmc2_datao(0);
  s_sAxi_dataR(6) <= s_fmc2_datao(1);
  s_sAxi_dataR(7) <= s_fmc2_datao(2);
  
  --=============================================================================
  -- tick generation, depending on constant c_FLASH
  --=============================================================================
  p_tick : process(ps_clk_i)
    variable v_cntr : unsigned(31 downto 0) := (others => '0');
  begin
    if rising_edge(ps_clk_i) then
      if (to_integer(v_cntr) < c_FLASH) then
        v_cntr := v_cntr + 1;
      else
        v_cntr := to_unsigned(0, v_cntr'length);
        s_tick <= not s_tick;
      end if;
    end if;
  end process p_tick;

  --=============================================================================
  -- FASEC LEDs output
  --=============================================================================
  p_leds : process(ps_clk_i)
    variable v_pbreg : std_logic_vector(2 downto 0) := (others => '0');
    variable v_shift : std_logic_vector(7 downto 0) := "00000001";
  begin
    if rising_edge(ps_clk_i) then
      -- clock in pushbutton input
      v_pbreg(2 downto 0) := v_pbreg(1 downto 0) & pb_gp_n_i;
      -- shift-register
      if s_tick = '1' then
        v_shift(7 downto 0) := v_shift(6 downto 0) & v_shift(7);
      end if;
      -- LEDs output selection
      if v_pbreg(2) = '1' then
        -- button not pressed, light one by one (4x green, 4x red)
        if unsigned(v_shift(3 downto 0)) /= 0 then
          led_line_en_pl_o         <= '0';
          led_line_pl_o            <= '0';
          led_col_pl_o(3 downto 0) <= v_shift(3 downto 0);
        elsif unsigned(v_shift(7 downto 4)) /= 0 then
          led_line_en_pl_o         <= '1';
          led_line_pl_o            <= '0';
          led_col_pl_o(3 downto 0) <= not(v_shift(7 downto 4));
        end if;
      else
        -- button pressed, all LEDs red
        led_line_en_pl_o         <= '1';
        led_line_pl_o            <= '1';
        led_col_pl_o(3 downto 0) <= "0000";
      end if;
    end if;
  end process;

  --=============================================================================
  -- AXI4-Lite slave for control from PS
  --=============================================================================
  axi4lite_slave : entity xil_pvtmisc.axi4lite_slave
    generic map (
      C_S_AXI_DATA_WIDTH => g_S00_AXI_DATA_WIDTH,
      C_S_AXI_ADDR_WIDTH => g_S00_AXI_ADDR_WIDTH,
      g_MAXREAD          => c_SLAVE_MAXREAD,
      g_MAXWRITE         => c_SLAVE_MAXWRITE)
    port map (
      s_axi_dataR      => s_sAxi_dataR,
      s_axi_dataW      => s_sAxi_dataW,
      s_axi_dataResetW => s_sAxi_dataResetW,
      S_AXI_ACLK       => s00_axi_aclk,
      S_AXI_ARESETN    => s00_axi_aresetn,
      S_AXI_AWADDR     => s00_axi_awaddr,
      S_AXI_AWPROT     => s00_axi_awprot,
      S_AXI_AWVALID    => s00_axi_awvalid,
      S_AXI_AWREADY    => s00_axi_awready,
      S_AXI_WDATA      => s00_axi_wdata,
      S_AXI_WSTRB      => s00_axi_wstrb,
      S_AXI_WVALID     => s00_axi_wvalid,
      S_AXI_WREADY     => s00_axi_wready,
      S_AXI_BRESP      => s00_axi_bresp,
      S_AXI_BVALID     => s00_axi_bvalid,
      S_AXI_BREADY     => s00_axi_bready,
      S_AXI_ARADDR     => s00_axi_araddr,
      S_AXI_ARPROT     => s00_axi_arprot,
      S_AXI_ARVALID    => s00_axi_arvalid,
      S_AXI_ARREADY    => s00_axi_arready,
      S_AXI_RDATA      => s00_axi_rdata,
      S_AXI_RRESP      => s00_axi_rresp,
      S_AXI_RVALID     => s00_axi_rvalid,
      S_AXI_RREADY     => s00_axi_rready);
end rtl;
