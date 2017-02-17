------------------------------------------------------------------------------
-- Title      : FASEC HW-Test
-- Project    : FIDS
------------------------------------------------------------------------------
-- Author     : Pieter Van Trappen
-- Company    : CERN TE-ABT-EC
-- Created    : 2016-08-19
-- Last update: 2017-02-16
-- Platform   : FPGA-generic
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description:
-- A top-level design for testing the FASEC hardware, incorperating
-- most of the hardware directly linked to the PL banks: 2 FMC slots, LEDs,
-- digital IOs and the SFP IP GEM status vector.
-- Excludes the i2c signals which are handled by seperate IPs.
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
    g_FMC1               : string  := "EDA-03287";  -- unconstrained, otherwise Vivado
                                        -- produces errors when integrating in
                                        -- Block Design; EDA-0NONE
    g_FMC2               : string  := "EDA-03287";
    g_USE_GEM_LEDS       : boolean := false);
  port (
    ps_clk_i            : in    std_logic;  -- clock from Zynq PS (100 MHz)
    osc100_clk_i        : in    std_logic;  -- clock from oscillator (100 MHz)
    -- FMC 1-2 user IO
    FMC2_LA_P_b         : inout std_logic_vector(33 downto 0);
    FMC2_LA_N_b         : inout std_logic_vector(33 downto 0);
    FMC1_LA_P_b         : inout std_logic_vector(33 downto 0);
    FMC1_LA_N_b         : inout std_logic_vector(33 downto 0);
    -- FMC misc IO
    FMC2_PRSNTM2C_n_i   : in    std_logic;
    FMC2_CLK0M2C_P_i    : in    std_logic;
    FMC2_CLK0M2C_N_i    : in    std_logic;
    FMC2_CLK0C2M_P_o    : out   std_logic;
    FMC2_CLK0C2M_N_o    : out   std_logic;
    FMC2_GP0_b          : inout std_logic;
    FMC2_GP1_b          : inout std_logic;
    FMC2_GP2_b          : inout std_logic;
    FMC2_GP3_b          : inout std_logic;
    FMC1_PRSNTM2C_n_i   : in    std_logic;
    FMC1_CLK0M2C_P_i    : in    std_logic;
    FMC1_CLK0M2C_N_i    : in    std_logic;
    FMC1_CLK0C2M_P_o    : out   std_logic;
    FMC1_CLK0C2M_N_o    : out   std_logic;
    FMC1_GP0_b          : inout std_logic;
    FMC1_GP1_b          : inout std_logic;
    FMC1_GP2_b          : inout std_logic;
    FMC1_GP3_b          : inout std_logic;
    -- FASEC signals
    pb_gp_n_i           : in    std_logic;
    led_col_pl_o        : out   std_logic_vector (3 downto 0);  -- anode green / cathode red
    led_line_en_pl_o    : out   std_logic;  -- output 1B Hi-Z when asserted
    led_line_pl_o       : out   std_logic;  -- output 1B: cathode green / anode red
    watchdog_pl_o       : out   std_logic;
    dig_in1_i           : in    std_logic;
    dig_in2_i           : in    std_logic;
    dig_in3_n_i         : in    std_logic;
    dig_in4_n_i         : in    std_logic;
    dig_outs_i          : out   std_logic_vector(3 downto 0);  -- on schematic: 4 downto 1
    dig_out5_n          : out   std_logic;
    dig_out6_n          : out   std_logic;
    -- misc. signals
    gem_status_vector_i : in    std_logic_vector(15 downto 0);
    -- AXI4-LITE slave interface
    s00_axi_aclk        : in    std_logic;
    s00_axi_aresetn     : in    std_logic;
    s00_axi_awaddr      : in    std_logic_vector(g_S00_AXI_ADDR_WIDTH-1 downto 0);
    s00_axi_awprot      : in    std_logic_vector(2 downto 0);
    s00_axi_awvalid     : in    std_logic;
    s00_axi_awready     : out   std_logic;
    s00_axi_wdata       : in    std_logic_vector(g_S00_AXI_DATA_WIDTH-1 downto 0);
    s00_axi_wstrb       : in    std_logic_vector((g_S00_AXI_DATA_WIDTH/8)-1 downto 0);
    s00_axi_wvalid      : in    std_logic;
    s00_axi_wready      : out   std_logic;
    s00_axi_bresp       : out   std_logic_vector(1 downto 0);
    s00_axi_bvalid      : out   std_logic;
    s00_axi_bready      : in    std_logic;
    s00_axi_araddr      : in    std_logic_vector(g_S00_AXI_ADDR_WIDTH-1 downto 0);
    s00_axi_arprot      : in    std_logic_vector(2 downto 0);
    s00_axi_arvalid     : in    std_logic;
    s00_axi_arready     : out   std_logic;
    s00_axi_rdata       : out   std_logic_vector(g_S00_AXI_DATA_WIDTH-1 downto 0);
    s00_axi_rresp       : out   std_logic_vector(1 downto 0);
    s00_axi_rvalid      : out   std_logic;
    s00_axi_rready      : in    std_logic);
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
      FMC_GP0_b        : inout std_logic;
      FMC_GP1_b        : inout std_logic;
      FMC_GP2_b        : inout std_logic;
      FMC_GP3_b        : inout std_logic;
      data_rw_i        : in    t_data32(0 to g_DMAX-1);
      data_o           : out   t_data32(0 to g_DMAX-1));
  end component general_fmc;

  -- FASEC memory mapping
  ------------------------------------
  -- memory mapping, using EDA-03287:
  ------------------------------------
  --  0x00: FASEC
  --    0x00: FMC generic ASCII
  --    0x01: b0-b5: digital ins
  --    0x02: b0-b15: GEM AN status vector
  --    0x03: output control: b0 @1 all outs connected to dig_in1; b1 @1 all outs
  --          connected to s_tick frequency
  --  0x08: FMC1 (see general_fmc.vhd)
  --  0x4C: FMC2 (see general_fmc.vhd)
  --  0x90: end
  ------------------------------------
  -- TODO: make constants for each register (in a seperate package cause
  -- needed in multiple files?). Especially for the below function and
  -- gen_data_readwrite process (x*c_FMC_DMAX etc.)!
  ------------------------------------
  constant c_FASEC_BASE : natural                    := 0;
  constant c_FASEC_DMAX : positive                   := 8;
  constant c_FMC_DMAX   : positive                   := 68;
  constant c_MEMMAX     : positive                   := c_FASEC_DMAX + 2*c_FMC_DMAX;
  constant c_REG_OUTCTRL : positive := 3;
  
  function fill_mem_fasec(length : integer) return t_iomem32 is
    variable m : t_iomem32(0 to length);
  begin
    for i in 0 to length loop
      m(i).resetval := (others => '0');
      -- .ro is by default initialised to '1'
      case i is
        when c_REG_OUTCTRL =>
          m(i).ro       := '0';
          m(i).resetval := x"00000001";
        when c_FASEC_DMAX+2 | c_FASEC_DMAX+c_FMC_DMAX+2 =>
          -- FMC output request
          m(i).ro := '0';
        when c_FASEC_DMAX+3 | c_FASEC_DMAX+c_FMC_DMAX+3 =>
          -- FMC DAC control
          m(i).ro := '0';
          m(i).resetval := x"00000002";         --0x2 for autostart
        when c_FASEC_DMAX+8 to c_FASEC_DMAX+27 =>
          -- FMC1 20x channel write requests 
          m(i).ro       := '0';
          m(i).resetval := x"000003ff";  --bipolar max. positive /2
        when c_FASEC_DMAX+c_FMC_DMAX+8 to c_FASEC_DMAX+c_FMC_DMAX+27 =>
          -- FMC2 20x channel write requests
          m(i).ro       := '0';
          m(i).resetval := x"000003ff";  --bipolar max. positive /2
        when others =>
          m(i).resetval := (others => '0');
          m(i).ro       := '1';
      end case;
    end loop;
    return m;
  end;

  -- constants and signals
  constant c_FLASH      : positive                   := 40000000;  -- 400 ms @ 100 MHz
  signal s_data         : t_data32(0 to c_MEMMAX-1)  := (others => (others => '0'));
  signal s_data_rw      : t_data32(0 to c_MEMMAX-1)  := (others => (others => '0'));
  constant c_FASECMEM   : t_iomem32(0 to c_MEMMAX-1) := fill_mem_fasec(c_MEMMAX-1);

  -- FMC1-2 signals
  signal s_tick       : std_logic;
  signal s_datao_fmc1 : t_data32(0 to c_FMC_DMAX-1);
  signal s_datao_fmc2 : t_data32(0 to c_FMC_DMAX-1);
  -- misc.
  signal s_leds       : std_logic_vector(3 downto 0) := (others => '0');
  signal s_led_line   : std_logic                    := '1';
  signal s_gem_leds   : std_logic_vector(3 downto 0);
  signal s_reset      : std_logic;
  signal s_ins        : std_logic_vector(3 downto 0) := (others => '0');
  signal s_outs       : std_logic_vector(5 downto 0) := (others => '0');
begin
  -- reset, ModelSim doesn't like the not(..) in a port instantiation
  s_reset <= not s00_axi_aresetn;
  --=============================================================================
  -- FMC1 component
  --=============================================================================  
  cmp_general_fmc1 : general_fmc
    generic map (
      g_FMC  => g_FMC1,
      g_DMAX => c_FMC_DMAX)
    port map (
      clk_i            => s00_axi_aclk,
      rst_i            => s_reset,
      FMC_LA_P_b       => FMC1_LA_P_b(33 downto 0),
      FMC_LA_N_b       => FMC1_LA_N_b(33 downto 0),
      FMC_PRSNTM2C_n_i => FMC1_PRSNTM2C_n_i,
      FMC_CLK0M2C_P_i  => FMC1_CLK0M2C_P_i,
      FMC_CLK0M2C_N_i  => FMC1_CLK0M2C_N_i,
      FMC_CLK0C2M_P_o  => FMC1_CLK0C2M_P_o,
      FMC_CLK0C2M_N_o  => FMC1_CLK0C2M_N_o,
      FMC_GP0_b        => FMC1_GP0_b,
      FMC_GP1_b        => FMC1_GP1_b,
      FMC_GP2_b        => FMC1_GP2_b,
      FMC_GP3_b        => FMC1_GP3_b,
      data_rw_i        => s_data(c_FASEC_DMAX to c_FASEC_DMAX+c_FMC_DMAX-1),
      data_o           => s_datao_fmc1(0 to c_FMC_DMAX-1));

  --=============================================================================
  -- FMC2 component
  --=============================================================================  
  cmp_general_fmc2 : general_fmc
    generic map (
      g_FMC  => g_FMC2,
      g_DMAX => c_FMC_DMAX)
    port map (
      clk_i            => s00_axi_aclk,
      rst_i            => s_reset,
      FMC_LA_P_b       => FMC2_LA_P_b(33 downto 0),
      FMC_LA_N_b       => FMC2_LA_N_b(33 downto 0),
      FMC_PRSNTM2C_n_i => FMC2_PRSNTM2C_n_i,
      FMC_CLK0M2C_P_i  => FMC2_CLK0M2C_P_i,
      FMC_CLK0M2C_N_i  => FMC2_CLK0M2C_N_i,
      FMC_CLK0C2M_P_o  => FMC2_CLK0C2M_P_o,
      FMC_CLK0C2M_N_o  => FMC2_CLK0C2M_N_o,
      FMC_GP0_b        => FMC2_GP0_b,
      FMC_GP1_b        => FMC2_GP1_b,
      FMC_GP2_b        => FMC2_GP2_b,
      FMC_GP3_b        => FMC2_GP3_b,
      data_rw_i        => s_data(c_FASEC_DMAX+c_FMC_DMAX to c_FASEC_DMAX+(2*c_FMC_DMAX)-1),
      data_o           => s_datao_fmc2(0 to c_FMC_DMAX-1));

  --=============================================================================
  -- FASEC IP memory mapping, see above for memory map
  -- by default all data is read-only
  --=============================================================================
  --TODO: add synthesis timestamp (from top project!), FASEC IO control, FMC
  -- PS read data
  s_data(c_FASEC_BASE+0) <= (others => '0');  -- TODO: generic FMC string
  s_data(c_FASEC_BASE+1) <= resize(unsigned(s_ins), g_S00_AXI_DATA_WIDTH);
  s_data(c_FASEC_BASE+2) <= resize(unsigned(gem_status_vector_i), g_S00_AXI_DATA_WIDTH);
  -- s_data(c_FASEC_BASE+3).data used in p_fasec_dio
  s_data(c_FASEC_BASE+6) <= x"DEADBEE1";  -- tcl-script will put unix build time
  s_data(c_FASEC_BASE+7) <= x"DEADBEE2";  -- tcl-script will put git commit id
  -- copy in rw data, 'for generate' only possible with constants!
  gen_data_readwrite : for i in 0 to c_MEMMAX-1 generate
    gen_fasec : if c_FASECMEM(i).ro = '0' generate
      -- no check for i because rw access possible for 'general' FASEC memory range
      s_data(i) <= s_data_rw(i)(g_S00_AXI_DATA_WIDTH-1 downto 0);
    end generate gen_fasec;
    gen_fmc1 : if i >= c_FASEC_DMAX and i < c_FASEC_DMAX+c_FMC_DMAX and c_FASECMEM(i).ro = '1' generate
      s_data(i) <= s_datao_fmc1(i-c_FASEC_DMAX);
    end generate gen_fmc1;
    gen_fmc2 : if i >= c_FASEC_DMAX+c_FMC_DMAX and i < c_FASEC_DMAX+2*c_FMC_DMAX and c_FASECMEM(i).ro = '1' generate
      s_data(i) <= s_datao_fmc2(i-(c_FASEC_DMAX+c_FMC_DMAX));
    end generate gen_fmc2;
  end generate gen_data_readwrite;

  --=============================================================================
  -- FASEC digital IOs
  --=============================================================================
  p_fasec_dio : process(ps_clk_i, s_data, s_ins, s_tick)
    variable v_ins      : std_logic_vector(3 downto 0) := (others => '0');
    variable v_out_cntr : std_logic_vector(g_S00_AXI_DATA_WIDTH-1 downto 0);
  begin
    -- inputs, clocked
    if rising_edge(ps_clk_i) then
      -- ins
      s_ins    <= v_ins(3 downto 0);
      v_ins(0) := dig_in1_i;
      v_ins(1) := dig_in2_i;
      v_ins(2) := not dig_in3_n_i;
      v_ins(3) := not dig_in4_n_i;
    end if;
    -- outputs, not reclocked
    v_out_cntr := std_logic_vector(s_data(c_FASEC_BASE+c_REG_OUTCTRL)(g_S00_AXI_DATA_WIDTH-1 downto 0));
    if v_out_cntr(0) = '1' then
      s_outs(5 downto 0) <= (others => s_ins(0));
    elsif v_out_cntr(1) = '1' then
      s_outs(5 downto 0) <= (others => s_tick);
    else
      s_outs(5 downto 0) <= (others => '0');
    end if;
  end process p_fasec_dio;
  dig_outs_i(3 downto 0) <= s_outs(3 downto 0);
  dig_out5_n             <= not s_outs(4);
  dig_out6_n             <= not s_outs(5);
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
  -- FASEC watchdog_pl frequency, 2 ms period
  --=============================================================================
  cmp_watchdog : clockDivider
    generic map (
      g_FACTOR      => 200000,
      g_START_LEVEL => '0')
    port map (
      clk_system_i => ps_clk_i,
      reset_i      => s_reset,
      clk_div_o    => watchdog_pl_o);

  --=============================================================================
  -- FASEC LEDs output
  --=============================================================================
  p_leds : process(ps_clk_i)
    variable v_pbreg : std_logic_vector(2 downto 0) := (others => '0');
    variable v_shift : std_logic_vector(7 downto 0) := "00000001";
  begin
    if rising_edge(ps_clk_i) then
      -- always on
      led_line_en_pl_o    <= '1';
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
          s_led_line         <= '0';
          s_leds(3 downto 0) <= v_shift(3 downto 0);
        elsif unsigned(v_shift(7 downto 4)) /= 0 then
          s_led_line         <= '1';
          s_leds(3 downto 0) <= not(v_shift(7 downto 4));
        end if;
      else
        -- button pressed, all LEDs red
        s_led_line         <= '1';
        s_leds(3 downto 0) <= "0000";
      end if;
    end if;
  end process;

  p_leds_gem : process(ps_clk_i)
    variable v_buf, v_buf1 : std_logic_vector(gem_status_vector_i'left downto 0);
  begin
    if rising_edge(ps_clk_i) then
      -- from PG047: bit-0 link status, bit-10/11 speed, bit-12 duplex
      s_gem_leds(3 downto 0) <= v_buf1(12 downto 10) & v_buf1(0);
      v_buf1                 := v_buf;
    end if;
  end process p_leds_gem;

  -- select led outputs depending on generic
  led_col_pl_o(3 downto 0) <= s_gem_leds(3 downto 0) when g_USE_GEM_LEDS = true else
                              s_leds(3 downto 0);
  led_line_pl_o <= '0' when g_USE_GEM_LEDS = true else
                   s_led_line;

  --=============================================================================
  -- AXI4-Lite slave for control from PS
  --=============================================================================
  axi4lite_slave : entity xil_pvtmisc.axi4lite_slave
    generic map (
      C_S_AXI_DATA_WIDTH => g_S00_AXI_DATA_WIDTH,
      C_S_AXI_ADDR_WIDTH => g_S00_AXI_ADDR_WIDTH,
      g_MAXMEM           => c_MEMMAX,
      g_CLOCKMEM         => '0',        -- FIXME: for vhdl validation, '0'
      g_IOMEM            => c_FASECMEM)
    port map (
      data_i        => s_data,
      data_rw_o     => s_data_rw,
      S_AXI_ACLK    => s00_axi_aclk,
      S_AXI_ARESETN => s00_axi_aresetn,
      S_AXI_AWADDR  => s00_axi_awaddr,
      S_AXI_AWPROT  => s00_axi_awprot,
      S_AXI_AWVALID => s00_axi_awvalid,
      S_AXI_AWREADY => s00_axi_awready,
      S_AXI_WDATA   => s00_axi_wdata,
      S_AXI_WSTRB   => s00_axi_wstrb,
      S_AXI_WVALID  => s00_axi_wvalid,
      S_AXI_WREADY  => s00_axi_wready,
      S_AXI_BRESP   => s00_axi_bresp,
      S_AXI_BVALID  => s00_axi_bvalid,
      S_AXI_BREADY  => s00_axi_bready,
      S_AXI_ARADDR  => s00_axi_araddr,
      S_AXI_ARPROT  => s00_axi_arprot,
      S_AXI_ARVALID => s00_axi_arvalid,
      S_AXI_ARREADY => s00_axi_arready,
      S_AXI_RDATA   => s00_axi_rdata,
      S_AXI_RRESP   => s00_axi_rresp,
      S_AXI_RVALID  => s00_axi_rvalid,
      S_AXI_RREADY  => s00_axi_rready);
end rtl;
