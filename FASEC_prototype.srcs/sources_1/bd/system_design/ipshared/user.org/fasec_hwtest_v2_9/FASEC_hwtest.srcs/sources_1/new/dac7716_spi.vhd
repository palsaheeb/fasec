-------------------------------------------------------------------------------
-- Title      : Wrapper file to control DAC7716
-- Project    : 
-------------------------------------------------------------------------------
-- File       : dac7716_spi.vhd
-- Author     : Pieter Van Trappen  <pvantrap@cern.ch>
-- Company    : 
-- Created    : 2016-11-22
-- Last update: 2017-02-17
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
-- dac_cntr, 32 bits, RW?:
--  bit0: request DAC-update --FIXME:implement
--  bit1: send continuously
--  bit2: all channels update from ch0
--  bit3:
--  bit4: DAC-update done --FIXME:implement
-------------------------------------------------------------------------------
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
    clk_i      : in  std_logic;
    reset_i    : in  std_logic;
    -- SPI lines
    spi_clk_o  : out std_logic;
    spi_sdi_o  : out std_logic;
    spi_sdo_i  : in  std_logic;
    spi_cs_n_o : out std_logic;
    -- dac control/read registers
    dac_cntr_i : in  unsigned(31 downto 0);
    dac_cntr_o : out unsigned(31 downto 0);
    -- first n regs for writing, then n for reading
    dac_ch_i   : in  t_data32(0 to g_NODAC*g_NOCHANNELS-1);
    dac_ch_o   : out t_data32(0 to g_NODAC*g_NOCHANNELS-1));
end dac7716_spi;
--=============================================================================
-- architecture declaration
--============================================================================
architecture rtl of dac7716_spi is
  -- design signals and constants
  constant c_SPIWIDTH : positive := 24;
  constant c_CMDWIDTH : positive := c_SPIWIDTH*g_NODAC;
  constant c_REGS     : positive := g_NODAC*g_NOCHANNELS;
  constant c_REQDEPTH : positive := 12;

  type t_state is (idle, checkcond, writestart, writing);
  type t_req is record
    value   : unsigned(c_REQDEPTH-1 downto 0);
    changed : std_logic;
  end record;
  type t_reqarray is array (0 to c_REGS-1) of t_req;
  signal s_state      : t_state;
  signal s_reqs       : t_reqarray := (others => ((others => '0'), '0'));
  signal s_tx_data    : std_logic_vector(c_CMDWIDTH-1 downto 0);
  signal s_rx_data    : std_logic_vector(c_CMDWIDTH-1 downto 0);
  signal s_start      : std_logic;
  signal s_done       : std_logic;
  signal s_flag_reset : std_logic_vector(g_NOCHANNELS-1 downto 0);
-- (spi_transceiver component in xil_pvtmisc.myPackage)

  -- functions etc.
  impure function fill_dac_vector(ch_address : integer; only_ch0 : std_logic) return std_logic_vector is
    -- impure cause of s_reqs signal
    variable v_cmddac    : std_logic_vector(c_SPIWIDTH-1 downto 0);
    variable v_ret       : std_logic_vector(c_CMDWIDTH-1 downto 0);
    constant c_DACOFFSET : natural := 4;
    variable v_ch        : integer range 0 to c_REGS-1;
  begin
    -- create vector for all DAC devices (daisy-chained)
    for i in 0 to g_NODAC-1 loop
      if only_ch0 = '1' then
        v_ch := 0;
      else
        v_ch := (g_NOCHANNELS*i)+ch_address;
      end if;
      v_cmddac := B"0000" & std_logic_vector(to_unsigned(ch_address+c_DACOFFSET, 4))
                  & std_logic_vector(s_reqs(v_ch).value) & "0000";
      v_ret(((i+1)*v_cmddac'length)-1 downto i*v_cmddac'length) := v_cmddac;
    end loop;
    -- v_ret consists of a sequence of g_NODAC * v_cmddac
    return v_ret;
  end;
begin
  --=============================================================================
  -- components
  --=============================================================================
  cmp_spi : spi_transceiver
    generic map (
      -- clock divider at 2 to have 12.5MHz with 100MHz in
      g_CLOCK_DIVIDER  => 2,
      g_ACT_ON_FALLING => '0',
      g_DATA_WIDTH     => c_CMDWIDTH)
    port map (
      clk_i      => clk_i,
      reset_i    => reset_i,
      spi_clk_o  => spi_clk_o,
      spi_sdi_o  => spi_sdi_o,
      spi_sdo_i  => spi_sdo_i,
      spi_cs_n_o => spi_cs_n_o,
      tx_data_i  => s_tx_data(c_CMDWIDTH-1 downto 0),
      rx_data_o  => s_rx_data(c_CMDWIDTH-1 downto 0),
      start_i    => s_start,
      done_o     => s_done);

  --=============================================================================
  -- channel request change detection
  --=============================================================================
  p_req_change : process(clk_i)
    variable v_ch : integer range 0 to c_REGS-1;
  begin
    for i in 0 to g_NODAC-1 loop
      for j in 0 to g_NOCHANNELS-1 loop
        v_ch := (i*g_NOCHANNELS)+j;
        if rising_edge(clk_i) then
          -- set/reset changed flag
          if s_flag_reset(j) = '1' then
            s_reqs(v_ch).changed <= '0';
          elsif s_reqs(v_ch).value(c_REQDEPTH-1 downto 0) /= dac_ch_i(v_ch)(c_REQDEPTH-1 downto 0) then
            s_reqs(v_ch).changed <= '1';
          end if;
          -- register channel requests
          s_reqs(v_ch).value <= dac_ch_i(v_ch)(c_REQDEPTH-1 downto 0);
        end if;
      end loop;
    end loop;
  end process p_req_change;

  --=============================================================================
  -- state machine to control DAC channel requests to spi_transceiver
  -- (transitions and outputs together)
  --=============================================================================
  p_state_moore : process(clk_i)
    variable v_ch0        : unsigned(31 downto 0);
    variable v_ch_address : integer range 0 to g_NOCHANNELS-1;
    variable v_changed    : std_logic_vector(g_NODAC-1 downto 0);
    constant c_ZEROS      : std_logic_vector(g_NODAC-1 downto 0) := (others => '0');
  begin
    if rising_edge(clk_i) then
      if reset_i = '1' then
        s_state      <= idle;
        s_start      <= '0';
        s_flag_reset <= (others => '0');
      else
        dac_cntr_o(3) <= '0';
        case s_state is
          when idle =>                  -- idle, wait for start
            dac_cntr_o(3) <= '1';
            s_start       <= '0';
            v_ch_address  := 0;
            if s_done = '1' then
              s_state <= checkcond;
            end if;
          when checkcond =>             -- check start conditions
            for i in 0 to g_NODAC-1 loop
              v_changed(i) := s_reqs(i+v_ch_address).changed;
            end loop;
            if (v_changed /= c_ZEROS or dac_cntr_i(1) = '1') then
              s_state <= writestart;
            elsif v_ch_address < g_NOCHANNELS-1 then
              -- no req changes so let's check next channel series
              v_ch_address := v_ch_address+1;
            else
              -- all channel series checked, back to idle
              s_state <= idle;
            end if;
          when writestart =>            -- create vector and start comm
            -- reset changed flags when writing according channels
            s_tx_data                  <= fill_dac_vector(v_ch_address, dac_cntr_i(2));
            s_flag_reset(v_ch_address) <= '1';
            -- request comm start
            s_start                    <= '1';
            if s_done = '0' then
              s_state <= writing;
            end if;
          when writing =>     -- wait until comm done, send more or finish
            s_flag_reset(v_ch_address) <= '0';
            if s_done = '1' then
              -- iterate over all DAC channels
              if v_ch_address < g_NOCHANNELS-1 then
                v_ch_address := v_ch_address+1;
                s_state      <= checkcond;
              else
                s_state     <= idle;
                -- FIXME, first NOP should be sent and then 120-bit reponse split
                -- in channels for proper response reading
                dac_ch_o(0) <= resize(unsigned(s_rx_data), 32);
              end if;
            end if;
        end case;
      end if;
    end if;
  end process p_state_moore;

end rtl;

