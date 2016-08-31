------------------------------------------------------------------------------
-- Title      : Generic FMC module
-- Project    : FIDS
------------------------------------------------------------------------------
-- Author     : Pieter Van Trappen
-- Company    : CERN TE-ABT-EC
-- Created    : 2016-08-19
-- Last update: 2016-08-31
-- Platform   : FPGA-generic
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: A generic FMC module
--
-------------------------------------------------------------------------------
-- general_fmc.vhd Copyright (c) 2016 CERN
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


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library UNISIM;
use UNISIM.vcomponents.all;

library xil_pvtmisc;
use xil_pvtmisc.myPackage.all;

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
    -- generic registers for passing data to top module
    data_i           : in    t_data32(0 to g_DMAX-1);
    data_o           : out   t_data32(0 to g_DMAX-1));
end general_fmc;

architecture rtl of general_fmc is
  constant c_DWIDTH : positive := 32;
begin
--=============================================================================
  -- EDA-02327: FMC user lines - clock in for AXI register read by Zynq PS
  --=============================================================================  
  p_reg_fmc_02327 : process(clk_i)
    variable v_fmc_reg0, v_fmc_reg1, v_fmc_reg2 : std_logic_vector(c_DWIDTH-1 downto 0);
  begin
    if g_FMC = "EDA-02327" and rising_edge(clk_i) then
      -- for testing purposes, read-in FMC inputs
      -- 68 lines, hence doesn't fit into 2x32-bit AXI registers
      data_o(0)      <= unsigned(v_fmc_reg0(c_DWIDTH-1 downto 0));
      data_o(1)      <= unsigned(v_fmc_reg1(c_DWIDTH-1 downto 0));
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
          DRIVE      => 12,
          --IOSTANDARD => "DEFAULT",
          SLEW       => "SLOW")
        port map (
          O  => open,
          IO => FMC_LA_P_b(I),
          I  => '0',
          T  => '1');
      IOBUF_N : IOBUF
        generic map (
          DRIVE      => 12,
          --IOSTANDARD => "DEFAULT",
          SLEW       => "SLOW")
        port map (
          O  => open,
          IO => FMC_LA_N_b(I),
          I  => '0',
          T  => '1');
    end generate outs;
  end generate fmc_out_highz;
  
end rtl;
