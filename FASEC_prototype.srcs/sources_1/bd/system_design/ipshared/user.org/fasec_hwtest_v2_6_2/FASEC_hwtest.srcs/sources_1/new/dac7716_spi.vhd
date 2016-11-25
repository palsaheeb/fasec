-------------------------------------------------------------------------------
-- Title      : Wrapper file to control DAC7716
-- Project    : 
-------------------------------------------------------------------------------
-- File       : dac7716_spi.vhd
-- Author     : Pieter Van Trappen  <pvantrap@cern.ch>
-- Company    : 
-- Created    : 2016-11-22
-- Last update: 2016-11-23
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
--  this wrapper implements a state machine to write and read the multiple channel
--  registers of the TI DAC7716. Daisy-chain mode is supported.
-------------------------------------------------------------------------------
-- Copyright CERN (c) 2016 
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
-- Date        Version  Author          Description
-- 2016-11-22  1.0      pvantrap        Created
-------------------------------------------------------------------------------
-- Regiser description :
-- dac_cntr, 32 bits, RW:
--      bit0 : when high, use only dac_ch_i(0) as reference for all channels
--      bit1 : when high, update depending on bit2; low, update on change
--      bit2 : update channels on rising edge if bit1=1
--      bit3 : update processed if bit1=1
-------------------------------------------------------------------------------
-- TODO:
-- * make a record of (u32, bit) to indicate changed register
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library UNISIM;
use UNISIM.vcomponents.all;

library xil_pvtmisc;
use xil_pvtmisc.myPackage.all;

entity dac7716_spi is
  generic(
    -- number of daisy-chained chips
    g_NODAC      : natural := 5;
    -- number of channels per chip/dac
    g_NOCHANNELS : natural := 4);
  port (
    clk_i      : in     std_logic;
    reset_i    : in     std_logic;
    -- SPI lines
    spi_clk_o  : out    std_logic;
    spi_sdi_o  : out    std_logic;
    spi_sdo_i  : in     std_logic;
    spi_cs_n_o : out    std_logic;
    -- dac contro/read registers
    dac_cntr_b : buffer unsigned(31 downto 0);
    dac_ch_i   : in     t_data32(0 to g_NODAC*g_NOCHANNELS-1);
    dac_ch_o   : out    t_data32(0 to g_NODAC*g_NOCHANNELS-1));
end dac7716_spi;
--=============================================================================
-- architecture declaration
--============================================================================
architecture rtl of dac7716_spi is
  -- design signals and constants
  type t_state is (idle, writestart, writing);
  signal s_state : t_state;

  -- 24 for test, should be 120
  constant c_SPIWIDTH : positive := 24;
  signal s_tx_data    : std_logic_vector(c_SPIWIDTH-1 downto 0);
  signal s_rx_data    : std_logic_vector(c_SPIWIDTH-1 downto 0);
  signal s_start      : std_logic;
  signal s_done       : std_logic;
-- (spi_transceiver component in xil_pvtmisc.myPackage)
begin
  --=============================================================================
  -- components
  --=============================================================================
  cmp_spi : spi_transceiver
    generic map (
      g_CLOCK_DIVIDER  => 0,
      g_ACT_ON_FALLING => '0',
      g_DATA_WIDTH     => 24)
    port map (
      clk_i      => clk_i,
      reset_i    => reset_i,
      spi_clk_o  => spi_clk_o,
      spi_sdi_o  => spi_sdi_o,
      spi_sdo_i  => spi_sdo_i,
      spi_cs_n_o => spi_cs_n_o,
      tx_data_i  => s_tx_data(c_SPIWIDTH-1 downto 0),
      rx_data_o  => s_rx_data(c_SPIWIDTH-1 downto 0),
      start_i    => s_start,
      done_o     => s_done);

  --=============================================================================
  -- state machine transitions and outputs together
  --=============================================================================
  p_state_moore : process(clk_i)
    variable v_ch0        : unsigned(31 downto 0);
    variable v_ch0_latched : unsigned(31 downto 0);
  begin
    if rising_edge(clk_i) then
      if reset_i = '1' then
        s_state <= idle;
      else
        dac_cntr_b(3) <= '0';
        case s_state is
          when idle =>
            dac_cntr_b(3) <= '1';
            if s_done = '1' and (v_ch0 /= dac_ch_i(0) or dac_cntr_b(2 downto 1) = "11") then
              s_state      <= writestart;
              v_ch0_latched := dac_ch_i(0);
            end if;
          when writestart =>
            -- test, write to channel 0 only
            s_tx_data <= B"0000_0100" & std_logic_vector(v_ch0_latched(11 downto 0)) & B"0000";
            s_start  <= '1';
            if s_done = '0' then
              s_state <= writing;
            end if;
          when writing =>
            if s_done = '1' then
              s_state <= idle;
              -- test, first NOP should be sent
              dac_ch_o(0) <= resize(unsigned(s_rx_data), 32);
            end if;
        end case;
        v_ch0 := dac_ch_i(0)(31 downto 0);
      end if;
    end if;
  end process p_state_moore;

end rtl;

