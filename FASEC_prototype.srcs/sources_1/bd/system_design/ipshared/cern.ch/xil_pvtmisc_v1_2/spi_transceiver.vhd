---------------------------------------------------------------------------------
-- Company: CERN
-- Engineer: Pieter Van Trappen
-- 
-- Create Date: 08.01.2015 12:32:20
-- Design Name: SPI transmit
-- Module Name: SPI_transmit - rtl
-- Project Name: FIDS
-- Target Devices: Zynq xc7z010
-- Tool Versions: 
-- Description:
--  * transmits the provided parallel data to a device using SPI
--   first design for the AD8403 with requirements TDS and TDH 5ns;
--   TCSS and TCSW 10ns => clk_i @ 100MHz and spi_clk_0 @ 25MHz
--  * implicit reading
-- 
-- Dependencies: xil_pvtmisc library
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Revision 0.2 - rework to support DAC7716
-- Additional Comments:
-- * only tested for g_CLOCK_DIVIDER=0 and g_ACT_ON_FALLING=0
--
-- TODO:
-- * spi_clk gating if ever required
----------------------------------------------------------------------------------
library xil_pvtmisc;
use xil_pvtmisc.myPackage.all;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

--=============================================================================
-- Entity declaration for SPI transmit
--=============================================================================
entity spi_transceiver is
  generic (
    -- clock divider, bit-wise so 0: /2, 1: /4
    g_CLOCK_DIVIDER  : natural   := 0;
    -- '1' to act on falling, '0' for rising edge
    -- act on rising e.g. when SPI clocks in at falling
    g_ACT_ON_FALLING : std_logic := '0';
    g_DATA_WIDTH     : natural   := 10);
  port (
    clk_i      : in  std_logic;
    reset_i    : in  std_logic;
    spi_clk_o  : out std_logic;
    spi_sdi_o  : out std_logic;
    spi_sdo_i  : in  std_logic;
    spi_cs_n_o : out std_logic;
    tx_data_i  : in  std_logic_vector(g_DATA_WIDTH-1 downto 0);
    rx_data_o  : out std_logic_vector(g_DATA_WIDTH-1 downto 0);
    -- start tx/rx action
    start_i    : in  std_logic;
    -- action done, stays high until restart; rx_data_o valid
    done_o     : out std_logic);
end spi_transceiver;
--=============================================================================
-- architecture declaration
--=============================================================================
architecture rtl of spi_transceiver is
  type t_state is (idle, start_edge, start_cs, tx, rx, stop_cs);
  signal s_state : t_state;

  constant c_FALLING      : unsigned(g_CLOCK_DIVIDER downto 0)        := (others => '1');
  signal s_counter        : unsigned(g_CLOCK_DIVIDER downto 0)        := (others => '0');
  signal s_spi_clk        : std_logic;
  signal s_rxdat, s_txdat : std_logic_vector(g_DATA_WIDTH-1 downto 0) := (others => '0');
  signal s_rising         : unsigned(g_CLOCK_DIVIDER downto 0)        := (others => '1');
  signal s_act, s_nact    : unsigned(g_CLOCK_DIVIDER downto 0);
--=============================================================================
-- architecture begin
--=============================================================================
begin
  --=============================================================================
  -- basic combinational logic 
  --=============================================================================
  -- s_compare is used for rising/falling edge detection with s_counter
  s_rising(g_CLOCK_DIVIDER) <= '0';  -- dirty way but we need '011..' constant
  s_act                     <= c_FALLING when g_ACT_ON_FALLING = '1' else s_rising;
  s_nact                    <= s_rising  when g_ACT_ON_FALLING = '1' else c_FALLING;
  s_spi_clk                 <= s_counter(g_CLOCK_DIVIDER);
  spi_clk_o                 <= s_spi_clk;

  --=============================================================================
  -- SPI clock divider counter
  --=============================================================================
  p_divide_clock : process(clk_i)
    variable v_ones : unsigned(g_CLOCK_DIVIDER downto 0) := (others => '1');
  begin
    if rising_edge(clk_i) then
      if reset_i = '1' then
        s_counter <= (others => '0');
      else
        if (s_counter = v_ones(g_CLOCK_DIVIDER downto 0)) then
          s_counter <= (others => '0');
        else
          s_counter <= s_counter+1;
        end if;
      end if;
    end if;
  end process p_divide_clock;

  --=============================================================================
  -- state machine transitions
  --=============================================================================  
  p_state_moore : process(clk_i)
    variable v_cnt : integer range 0 to g_DATA_WIDTH := 0;
  begin
    if rising_edge(clk_i) then
      if reset_i = '1' then
        s_state <= idle;
        s_rxdat <= (others => '0');
        s_txdat <= (others => '0');
        v_cnt   := 0;
      else
        case s_state is
          -- idle, wait for start command
          when idle =>
            rx_data_o <= s_rxdat(g_DATA_WIDTH-1 downto 0);
            if start_i = '1' then
              s_txdat <= tx_data_i(g_DATA_WIDTH-1 downto 0);
              s_state <= start_edge;
              v_cnt   := 0;
            end if;
          -- wait for spi clock edge so we're synchronised
          when start_edge =>
            if s_counter = s_act(g_CLOCK_DIVIDER downto 0) then
              s_state <= start_cs;
            end if;
          -- deassert cs_n
          when start_cs =>
            if s_counter = s_nact(g_CLOCK_DIVIDER downto 0) then
              s_state <= rx;
              -- clock in data on edge
              s_rxdat <= s_rxdat(g_DATA_WIDTH-2 downto 0) & spi_sdo_i;
              v_cnt   := v_cnt +1;      -- when 1, bit 0 sent; etc.
            end if;
          -- rx, triggered by oposite edge (hence before 'not s_compare')
          when rx =>
            if s_counter = s_act(g_CLOCK_DIVIDER downto 0) then
              if v_cnt = g_DATA_WIDTH then
                s_state <= stop_cs;
              else
                s_state <= tx;
                -- shift on edge only
                s_txdat <= s_txdat(g_DATA_WIDTH-2 downto 0) & '0';
              end if;
            end if;
          -- transmit, shift bits
          when tx =>
            if s_counter = s_nact(g_CLOCK_DIVIDER downto 0) then
              s_state <= rx;
              -- clock in data on edge
              s_rxdat <= s_rxdat(g_DATA_WIDTH-2 downto 0) & spi_sdo_i;
              v_cnt   := v_cnt +1;      -- when 1, bit 0 sent; etc.
            end if;
          -- assert cs_n, no additional wait needed because of rx state
          when stop_cs =>
            if s_counter = s_act(g_CLOCK_DIVIDER downto 0) then
              s_state <= idle;
            end if;
        end case;
      end if;
    end if;
  end process p_state_moore;

  --=============================================================================
  -- state machine outputs (not clocked)
  --=============================================================================
  p_state_outs : process(s_state, s_counter, s_txdat)
  begin
    -- default values
    spi_sdi_o  <= '1';
    spi_cs_n_o <= '1';
    done_o     <= '0';

    case s_state is
      when idle =>
        spi_sdi_o  <= '1';
        spi_cs_n_o <= '1';
        done_o     <= '1';
      when start_edge =>
        spi_sdi_o  <= '1';
        spi_cs_n_o <= '1';
      when start_cs =>
        spi_sdi_o  <= s_txdat(s_txdat'left);
        spi_cs_n_o <= '0';
      when rx =>
        spi_sdi_o  <= s_txdat(s_txdat'left);
        spi_cs_n_o <= '0';
      when tx =>
        spi_sdi_o  <= s_txdat(s_txdat'left);
        spi_cs_n_o <= '0';
      when stop_cs =>
        spi_sdi_o  <= '1';
        spi_cs_n_o <= '1';
        done_o     <= '1';
    end case;
  end process p_state_outs;

end rtl;
--=============================================================================
-- architecture end
--=============================================================================
