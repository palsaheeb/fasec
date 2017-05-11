-------------------------------------------------------------------------------
-- Title      : Generic FMC module
-- Project    : 
-------------------------------------------------------------------------------
-- File       : general_fmc.vhd
-- Author     : Pieter Van Trappen  <pvantrap@cern.ch>
-- Company    : CERN
-- Created    : 2016-11-22
-- Last update: 2017-05-11
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-- A generic FMC module, allowing for different FMCards configuration through
-- synthesis (the g_FMC generic). Hence no live FMCard swapping possible!
-- Supported for now:
--  EDA-0NONE: all user-IO high-Z
--  EDA-03287: FMC DIO 10i 8o
--  EDA-02327: FMC Carrier Tester
-------------------------------------------------------------------------------
-- Copyright (c) 2016 CERN
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
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2016-11-22  1.0      pieter  Created
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library UNISIM;
use UNISIM.vcomponents.all;

library hdl_lib;
use hdl_lib.main_pkg.all;

entity general_fmc is
  generic(
    g_FMC  : string(1 to 9) := "EDA-0NONE";
    g_DMAX : natural        := 8);
  port (
    clk_i            : in    std_logic;
    rst_i            : in    std_logic;
    -- FMC user IO
    FMC_LA_P_b       : inout std_logic_vector(33 downto 0);
    FMC_LA_N_b       : inout std_logic_vector(33 downto 0);
    -- FMC misc IO
    FMC_PRSNTM2C_n_i : in    std_logic;
    FMC_CLK0M2C_P_i  : in    std_logic;
    FMC_CLK0M2C_N_i  : in    std_logic;
    FMC_CLK0C2M_P_o  : out   std_logic;
    FMC_CLK0C2M_N_o  : out   std_logic;
    -- FMC general purpose
    FMC_GP0_i        : in    std_logic;
    FMC_GP1_i        : in    std_logic;
    FMC_GP2_i        : in    std_logic;
    FMC_GP3_b        : inout std_logic;
    -- generic registers for passing data to top module
    -- rw data, modified by master
    data_rw_i        : in    t_data32(0 to g_DMAX-1);
    -- output data, modified by this module
    data_o           : out   t_data32(0 to g_DMAX-1);
    -- interrupts
    intr_o           : out   std_logic;   -- rising edge on input change
    intr_led_o       : out   std_logic);  -- rising edge on extened input change
end general_fmc;

architecture rtl of general_fmc is
  constant c_DWIDTH          : positive := 32;
  -- EDA-03287 constants
  constant c_COMP            : positive := 20;  -- 20 comparators on EDA-03287
  constant c_DOUTS           : positive := 8;  -- 8 outputs
  constant c_DOUTSGP         : positive := 4;  -- first 4 outputs will be linked to GP signals (for white rabbit debugging)
  constant c_OUTFBD          : positive := 4;  -- of which 4 with feedback
  constant c_NODAC           : positive := 5;
  constant c_NOCHANNELS      : positive := 4;
  constant c_GPMEM           : positive := 8;  -- length of GP memory (starting at 0x00)
  -- FIXME: copied as from FID_FPGA for now, check below constants
  constant c_COUNTERWIDTH    : positive := 24;
  constant c_LEDCOUNTERWIDTH : positive := 32;
  -- memory mapping EDA-03287:
  constant c_ADDR_COMPIN     : positive := 16#00#;
  constant c_ADDR_OUTFB      : positive := 16#01#;
  constant c_ADDR_OUTREQ     : positive := 16#02#;
  constant c_ADDR_FMCCNR     : positive := 16#03#;
  constant c_BIT_USEIN0      : positive := 7;
  constant c_ADDR_COMPEXIN   : positive := 16#04#;
  constant c_ADDR_OUTEX      : positive := 16#05#;
  constant c_ADDR_OUT        : positive := 16#06#;
  -- 0x00 : General Purpose
  --  0x00 ro : bit19-0 comparator input status
  --  0x01 ro : bit3-0 output feedback status
  --  0x02 rw : bit7-0 output request
  --  0x03 rw : FMC & DAC control (see also dac7716_spi.vhd), bit7: use ch0 for
  --    all outs
  --  0x04 ro : bit19-0 extended input status for LEDs
  --  0x05 ro : bit7-0 extended output status for LEDs
  --  0x06 ro : bit7-0 output status
  -- 0x08 rw : 20x channel write request
  -- 0x1C ro : 20x channel read values
  -- 0x30 ro : 20x pulse length counter (assserted pulse)
  -- 0x44 : end (g_DMAX)

  --- signals
  signal s_reset_n       : std_logic;
  signal s_comparators_i : std_logic_vector(c_COMP-1 downto 0);
  signal s_compleds      : std_logic_vector(c_COMP-1 downto 0);
  signal s_cmp_pulse     : std_logic_vector(c_COMP-1 downto 0);
  type t_cmplengths is array (0 to c_COMP-1) of std_logic_vector(c_COUNTERWIDTH-1 downto 0);
  signal s_cmp_lengths   : t_cmplengths;
  signal s_diffouts_o    : std_logic_vector(c_DOUTS-1 downto 0);
  signal s_outleds       : std_logic_vector(c_DOUTS-1 downto 0);
  signal s_outsfeedbak_i : std_logic_vector(c_OUTFBD-1 downto 0);
  signal s_spi_sclk      : std_logic;
  signal s_spi_mosi      : std_logic;
  signal s_spi_miso      : std_logic;
  signal s_spi_cs_n      : std_logic;
  -- components
  component dac7716_spi is
    generic (
      g_NODAC      : natural;
      g_NOCHANNELS : natural);
    port (
      clk_i      : in  std_logic;
      reset_i    : in  std_logic;
      spi_clk_o  : out std_logic;
      spi_sdi_o  : out std_logic;
      spi_sdo_i  : in  std_logic;
      spi_cs_n_o : out std_logic;
      dac_cntr_i : in  unsigned(31 downto 0);
      dac_cntr_o : out unsigned(31 downto 0);
      dac_ch_i   : in  t_data32(0 to g_NODAC*g_NOCHANNELS-1);
      dac_ch_o   : out t_data32(0 to g_NODAC*g_NOCHANNELS-1));
  end component dac7716_spi;
  component pulseMeasure is
    generic (
      g_COUNTERWIDTH    : positive;
      g_LEDCOUNTERWIDTH : natural;
      g_LEDWAIT         : natural;
      g_MISSINGCDC      : boolean);
    port (
      clk_dsp_i       : in  std_logic;
      reset_n_i       : in  std_logic;
      pulse_i         : in  std_logic;
      missingWindow_i : in  unsigned(g_LEDCOUNTERWIDTH-1 downto 0);
      pulse_o         : out std_logic;
      edgeDetected_o  : out std_logic;
      usrLed_o        : out std_logic;
      window_o        : out std_logic;
      pulseLength_o   : out std_logic_vector (g_COUNTERWIDTH-1 downto 0);
      LedCount_o      : out std_logic_vector(g_LEDCOUNTERWIDTH-1 downto 0));
  end component pulseMeasure;
begin
  --=============================================================================
  -- EDA-03287: DIO 10i 8o FMC
  --=============================================================================
  s_reset_n <= not rst_i;
  -- comparator input channels loop
  fmc_03287_channels : for I in 0 to c_COMP-1 generate
    gen_chs : if g_FMC = "EDA-03287" generate
      cmp_IBUFDS_fmc : IBUFDS
        generic map (
          DIFF_TERM    => true,         -- Differential Termination 
          IBUF_LOW_PWR => false)  -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
--        IOSTANDARD   => "LVDS_25")
        port map (
          O  => s_comparators_i(I),     -- Buffer output
          I  => FMC_LA_P_b(I),  -- Diff_p buffer input (connect directly to top-level port)
          IB => FMC_LA_N_b(I));  -- Diff_n buffer input (connect directly to top-level port)
      cmp_ch_pulseMeasure : pulseMeasure
        generic map (
          g_COUNTERWIDTH    => c_COUNTERWIDTH,
          g_LEDCOUNTERWIDTH => c_LEDCOUNTERWIDTH,
          g_LEDWAIT         => 25000000,  -- 250ms when 10ns clock
          g_MISSINGCDC      => false)
        port map (
          clk_dsp_i       => clk_i,     -- for now no clock domain crossing
          reset_n_i       => s_reset_n,
          pulse_i         => s_comparators_i(I),
          missingWindow_i => to_unsigned(0, c_LEDCOUNTERWIDTH),
          pulse_o         => s_cmp_pulse(I),
          edgeDetected_o  => open,
          usrLed_o        => s_compleds(I),
          window_o        => open,
          pulseLength_o   => s_cmp_lengths(I)(c_COUNTERWIDTH-1 downto 0),
          LedCount_o      => open);
      -- clock in lenghs after pulse measurement has finished
      p_clklengths : process(clk_i)
      begin
        if rising_edge(clk_i) then
          if s_cmp_pulse(I) = '0' then
            data_o(I+c_GPMEM+2*(c_NODAC*c_NOCHANNELS)) <= resize(unsigned(
              s_cmp_lengths(I)(s_cmp_lengths(0)'high downto 0)), data_o(0)'length);
          end if;
        end if;
      end process p_clklengths;
    end generate gen_chs;
  end generate fmc_03287_channels;
  -- outputs loop
  fmc_03287_obufds : for I in 0 to c_DOUTS-1 generate
    gen_outs : if g_FMC = "EDA-03287" generate
      -- output LVDS buffers
      cmp_OBUFDS_fmc : OBUFDS
        generic map (
--          IOSTANDARD => "LVDS_25",      -- Specify the output I/O standard
          SLEW => "FAST")               -- Specify the output slew rate
        port map (
          O  => FMC_LA_P_b(c_COMP+I),  -- Diff_p output (connect directly to top-level port)
          OB => FMC_LA_N_b(c_COMP+I),  -- Diff_n output (connect directly to top-level port)
          I  => s_diffouts_o(I));       -- Buffer input
      -- pulse extenders for LEDs
      cmp_outs_pulseMeasure : pulseMeasure
        generic map (
          g_COUNTERWIDTH    => c_COUNTERWIDTH,
          g_LEDCOUNTERWIDTH => c_LEDCOUNTERWIDTH,
          g_LEDWAIT         => 10000000,  -- 100ms when 10ns clock
          g_MISSINGCDC      => false)
        port map (
          clk_dsp_i       => clk_i,     -- for now no clock domain crossing
          reset_n_i       => s_reset_n,
          pulse_i         => s_diffouts_o(I),
          missingWindow_i => to_unsigned(0, c_LEDCOUNTERWIDTH),
          pulse_o         => open,
          edgeDetected_o  => open,
          usrLed_o        => s_outleds(I),
          window_o        => open,
          pulseLength_o   => open,
          LedCount_o      => open);
    end generate gen_outs;
  end generate fmc_03287_obufds;
  -- SPI DAC for comparator reference
  gen_spi : if g_FMC = "EDA-03287" generate
    cmp_dac7716_spi : dac7716_spi
      generic map (
        g_NODAC      => c_NODAC,
        g_NOCHANNELS => c_NOCHANNELS)
      port map (
        clk_i      => clk_i,
        reset_i    => rst_i,
        spi_clk_o  => s_spi_sclk,
        spi_sdi_o  => s_spi_mosi,
        spi_sdo_i  => s_spi_miso,
        spi_cs_n_o => s_spi_cs_n,
        dac_cntr_i => data_rw_i(c_ADDR_FMCCNR),
        dac_cntr_o => open,
        dac_ch_i   => data_rw_i(c_GPMEM to c_GPMEM+(c_NODAC*c_NOCHANNELS)-1),
        dac_ch_o   => data_o(c_GPMEM+(c_NODAC*c_NOCHANNELS) to c_GPMEM+2*(c_NODAC*c_NOCHANNELS)-1));
    -- explicit declaration of this IOBUF needed (with Z) to simulate/synth as
    -- an input
    cmp_spi_miso_iobuf : IOBUF
      port map (
        O  => s_spi_miso,               -- 1-bit output: Buffer output
        I  => '0',                      -- 1-bit input: Buffer input
        IO => FMC_LA_P_b(29),  -- 1-bit inout: Buffer inout (connect directly to top-level port)
        T  => '1'                       -- 1-bit input: 3-state enable input
        );
    cmp_spi_mosi_iobuf : IOBUF
      port map (
        O  => open,                     -- 1-bit output: Buffer output
        I  => s_spi_mosi,               -- 1-bit input: Buffer input
        IO => FMC_LA_N_b(28),  -- 1-bit inout: Buffer inout (connect directly to top-level port)
        T  => '0'                       -- 1-bit input: 3-state enable input
        );
    cmp_spi_sclk_iobuf : IOBUF
      port map (
        O  => open,                     -- 1-bit output: Buffer output
        I  => s_spi_sclk,               -- 1-bit input: Buffer input
        IO => FMC_LA_P_b(28),  -- 1-bit inout: Buffer inout (connect directly to top-level port)
        T  => '0'                       -- 1-bit input: 3-state enable input
        );
    cmp_spi_cs_n_iobuf : IOBUF
      port map (
        O  => open,                     -- 1-bit output: Buffer output
        I  => s_spi_cs_n,               -- 1-bit input: Buffer input
        IO => FMC_LA_N_b(29),  -- 1-bit inout: Buffer inout (connect directly to top-level port)
        T  => '0'                       -- 1-bit input: 3-state enable input
        );
  end generate gen_spi;

  -- for white rabbit debugging, link some FMC outputs directly to GP inputs
  gen_clkouts : if g_FMC = "EDA-03287" generate
    s_diffouts_o(c_DOUTSGP-1 downto 0) <= FMC_GP3_b & FMC_GP2_i & FMC_GP1_i & FMC_GP0_i;
  end generate gen_clkouts;

  p_fmc_03287_io : process(clk_i)
    variable v_cmp     : std_logic_vector(c_COMP-1 downto 0);
    variable v_cmpled  : std_logic_vector(c_COMP-1 downto 0);
    variable v_dout    : std_logic_vector(c_DOUTS-1 downto 0);
    variable v_fbd     : std_logic_vector(c_OUTFBD-1 downto 0);
    variable v_outleds : std_logic_vector(c_DOUTS-1 downto 0);
  begin
    if g_FMC = "EDA-03287" and rising_edge(clk_i) then
      -- in/outputs
      data_o(c_ADDR_OUTFB)                     <= resize(unsigned(v_fbd(c_OUTFBD-1 downto 0)), data_o(1)'length);
      data_o(c_ADDR_OUT)                     <= resize(unsigned(s_diffouts_o(c_DOUTS-1 downto 0)), data_o(0)'length);
      s_diffouts_o(c_DOUTS-1 downto c_DOUTSGP) <= v_dout(c_DOUTS-1 downto c_DOUTSGP);
      -- using the variables to clock-in/out data
      if (data_rw_i(c_ADDR_FMCCNR)(c_BIT_USEIN0) = '1') then
        v_dout(c_DOUTS-1 downto 0) := std_logic_vector(data_rw_i(c_ADDR_OUTREQ)(c_DOUTS-1 downto 0));
      else
        v_dout(c_DOUTS-1 downto 0) := (others => s_cmp_pulse(0));
      end if;
      v_fbd := FMC_LA_P_b(31) & FMC_LA_N_b(31) & FMC_LA_P_b(32) & FMC_LA_N_b(32);
      -- interrupts generation by comparing with previous value
      if (v_cmp /= s_cmp_pulse) then
        intr_o <= '1';
      else
        intr_o <= '0';
      end if;
      if (v_cmpled /= s_compleds) or (v_outleds /= s_outleds) then
        intr_led_o <= '1';
      else
        intr_led_o <= '0';
      end if;
      -- clocking in data for above interrupt generation
      -- only on change of (extended) bitvectors there's an interrupt to reduce
      -- interrupt rate
      v_cmp     := s_cmp_pulse(c_COMP-1 downto 0);
      v_cmpled  := s_compleds(c_COMP-1 downto 0);
      v_outleds := s_outleds(c_DOUTS-1 downto 0);
    end if;
  end process p_fmc_03287_io;
  -- no additional clocking of comparators & LEDs
  data_o(c_ADDR_COMPIN)   <= resize(unsigned(s_cmp_pulse), data_o(0)'length);
  data_o(c_ADDR_COMPEXIN) <= resize(unsigned(s_compleds), data_o(0)'length);
  data_o(c_ADDR_OUTEX)    <= resize(unsigned(s_outleds), data_o(0)'length);
  --=============================================================================
  -- EDA-02327: FMC user lines - clock in for AXI register read by Zynq PS
  --=============================================================================  
  p_i2c_fmc_02327 : process(FMC_LA_P_b(2), FMC_LA_N_b(2))
  begin
    if g_FMC = "EDA-02327" then
      FMC_LA_P_b(2) <= 'Z';             -- scl_vadj, disconnect in xdc
      FMC_LA_N_b(2) <= 'Z';             -- sda_vadj, disconnect in xdc
    end if;
  end process p_i2c_fmc_02327;

  p_reg_fmc_02327 : process(clk_i)
    variable v_fmc_reg0, v_fmc_reg1, v_fmc_reg2 : std_logic_vector(c_DWIDTH-1 downto 0);
  begin
    if g_FMC = "EDA-02327" and rising_edge(clk_i) then
      -- for testing purposes, read-in FMC inputs
      -- 68 lines, hence doesn't fit into 2x32-bit AXI registers
      data_o(0)      <= unsigned(v_fmc_reg0(c_DWIDTH-1 downto 0));
      data_o(0)      <= unsigned(v_fmc_reg1(c_DWIDTH-1 downto 0));
      data_o(2)      <= unsigned(v_fmc_reg2(c_DWIDTH-1 downto 0));
      -- single user lines, auto-gen from .ods file
      -- ** word 1
      v_fmc_reg0(0)  := FMC_LA_N_b(17);
      v_fmc_reg0(1)  := FMC_LA_N_b(19);
      v_fmc_reg0(2)  := FMC_LA_P_b(19);
      v_fmc_reg0(3)  := FMC_LA_P_b(20);
      v_fmc_reg0(4)  := FMC_LA_N_b(20);
      v_fmc_reg0(5)  := FMC_LA_N_b(14);
      v_fmc_reg0(6)  := FMC_LA_P_b(14);
      v_fmc_reg0(7)  := FMC_LA_P_b(17);
      v_fmc_reg0(8)  := FMC_LA_N_b(13);
      v_fmc_reg0(9)  := FMC_LA_P_b(13);
      v_fmc_reg0(10) := FMC_LA_P_b(15);
      v_fmc_reg0(11) := FMC_LA_N_b(15);
      v_fmc_reg0(12) := FMC_LA_P_b(16);
      v_fmc_reg0(13) := FMC_LA_N_b(32);
      v_fmc_reg0(14) := FMC_LA_P_b(33);
      v_fmc_reg0(15) := FMC_LA_N_b(33);
      v_fmc_reg0(16) := FMC_LA_P_b(7);
      v_fmc_reg0(17) := FMC_LA_P_b(5);
      v_fmc_reg0(18) := FMC_LA_N_b(7);
      v_fmc_reg0(19) := FMC_LA_N_b(8);
      v_fmc_reg0(20) := FMC_LA_P_b(8);
      v_fmc_reg0(21) := FMC_LA_N_b(6);
      v_fmc_reg0(22) := FMC_LA_P_b(12);
      v_fmc_reg0(23) := FMC_LA_N_b(9);
      v_fmc_reg0(24) := FMC_LA_N_b(16);
      v_fmc_reg0(25) := FMC_LA_N_b(12);
      v_fmc_reg0(26) := FMC_LA_P_b(11);
      v_fmc_reg0(27) := FMC_LA_N_b(10);
      v_fmc_reg0(28) := FMC_LA_N_b(11);
      v_fmc_reg0(29) := FMC_LA_P_b(10);
      v_fmc_reg0(30) := FMC_LA_P_b(9);
      v_fmc_reg0(31) := FMC_LA_N_b(5);
      -- ** word 2
      v_fmc_reg1(0)  := FMC_LA_P_b(27);
      v_fmc_reg1(1)  := FMC_LA_N_b(23);
      v_fmc_reg1(2)  := FMC_LA_P_b(22);
      v_fmc_reg1(3)  := FMC_LA_N_b(22);
      v_fmc_reg1(4)  := FMC_LA_N_b(18);
      v_fmc_reg1(5)  := FMC_LA_P_b(18);
      v_fmc_reg1(6)  := FMC_LA_P_b(23);
      v_fmc_reg1(7)  := FMC_LA_P_b(21);
      v_fmc_reg1(8)  := FMC_LA_P_b(24);
      v_fmc_reg1(9)  := FMC_LA_N_b(25);
      -- v_fmc_reg1(10)  := TCK (High-Z)
      v_fmc_reg1(11) := FMC_LA_P_b(25);
      v_fmc_reg1(12) := FMC_LA_N_b(27);
      v_fmc_reg1(13) := FMC_LA_P_b(26);
      v_fmc_reg1(14) := FMC_LA_N_b(21);
      v_fmc_reg1(15) := FMC_LA_N_b(26);
      v_fmc_reg1(16) := FMC_LA_P_b(32);
      v_fmc_reg1(17) := FMC_LA_N_b(30);
      -- v_fmc_reg1(19) : GA1 (set at High-Z!)
      v_fmc_reg1(19) := FMC_LA_N_b(31);
      v_fmc_reg1(20) := FMC_LA_P_b(30);
      -- v_fmc_reg1(21) : GA0 (set at High-Z!)
      -- v_fmc_reg1(22)  := TRST (pull-up)
      -- v_fmc_reg1(23)  := TMS (High-Z)
      v_fmc_reg1(24) := FMC_LA_P_b(29);
      v_fmc_reg1(25) := FMC_LA_N_b(29);
      -- v_fmc_reg1(26)  := TDO (X when PRSTNn='1')
      v_fmc_reg1(27) := FMC_LA_P_b(31);
      v_fmc_reg1(28) := FMC_LA_N_b(28);
      v_fmc_reg1(29) := FMC_LA_P_b(28);
      -- v_fmc_reg1(30)  := TDI (X when PRSTNn='1')
      v_fmc_reg1(31) := FMC_LA_N_b(24);
      -- ** word 3 (if not stated -> don't care X)
      v_fmc_reg2(0)  := FMC_CLK0M2C_N_i;
      v_fmc_reg2(1)  := FMC_CLK0M2C_P_i;
      v_fmc_reg2(2)  := FMC_PRSNTM2C_n_i;  -- force at high/high-Z for JTAG!
      -- v_fmc_reg2(17) : PG_C2M (set at High-Z!)
      v_fmc_reg2(18) := FMC_LA_P_b(1);
      v_fmc_reg2(19) := FMC_LA_P_b(6);
      v_fmc_reg2(20) := FMC_LA_N_b(1);
      v_fmc_reg2(21) := FMC_LA_N_b(3);
      v_fmc_reg2(22) := FMC_LA_P_b(4);
      v_fmc_reg2(23) := FMC_LA_P_b(3);
      -- v_fmc_reg2(24) : VREF_M2C (set at 1!)
      v_fmc_reg2(27) := FMC_LA_P_b(0);
      v_fmc_reg2(29) := FMC_LA_N_b(0);
      v_fmc_reg2(31) := FMC_LA_N_b(4);
    end if;
  end process p_reg_fmc_02327;

  --=============================================================================
  -- EDA-0NONE: FMC user lines high-impedance
  --=============================================================================  
  p_reg_fmc_none : process(clk_i)
  begin
    if g_FMC = "EDA-0NONE" then
      if rising_edge(clk_i) then
        data_o(0) <= (others => '0');
        data_o(1) <= (others => '0');
        data_o(2) <= (others => '0');
      end if;
    end if;
  end process p_reg_fmc_none;

  -- primitives needed, if not synthesis will remote e.g. 'Z' values
  fmc_out_highz : for I in 0 to 33 generate
    outs : if g_FMC = "EDA-0NONE" generate
      IOBUF_P : IOBUF
        generic map (
          DRIVE => 12,
          --IOSTANDARD => "DEFAULT",
          SLEW  => "SLOW")
        port map (
          O  => open,
          IO => FMC_LA_P_b(I),
          I  => '0',
          T  => '1');
      IOBUF_N : IOBUF
        generic map (
          DRIVE => 12,
          --IOSTANDARD => "DEFAULT",
          SLEW  => "SLOW")
        port map (
          O  => open,
          IO => FMC_LA_N_b(I),
          I  => '0',
          T  => '1');
    end generate outs;
  end generate fmc_out_highz;

end rtl;
