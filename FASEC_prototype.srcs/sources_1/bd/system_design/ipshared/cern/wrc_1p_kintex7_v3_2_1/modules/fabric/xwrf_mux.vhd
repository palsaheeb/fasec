-------------------------------------------------------------------------------
-- Title      : Simple Pipelined Wishbone MUX/DEMUX for WRPC
-- Project    : WhiteRabbit
-------------------------------------------------------------------------------
-- File       : wrf_mux.vhd
-- Author     : Grzegorz Daniluk
-- Company    : CERN BE-CO-HT
-- Created    : 2011-08-11
-- Last update: 2017-03-14
-- Platform   : FPGA-generics
-- Standard   : VHDL
-------------------------------------------------------------------------------
-- Description:
-- This is the simple multiplexer/demultiplexer for WR Fabric interface
-- (Pipelined Wishbone interface). It forwards ethernet frames between
-- WR endpoint, Mini-NIC and external Fabric interface in both directions.
-- In the direction 'from' WR endpoint it also decides whether the packet
-- has to be forwarded to Mini-NIC (if it is the PTP message) or to the
-- external interface (others).
-------------------------------------------------------------------------------
-- Copyright (c) 2012 Grzegorz Daniluk
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2011-08-11  1.0      greg.d          Created
-- 2012-10-16  2.0      greg.d          generic number of ports
-- 2015-16-12  3.0      eml             Buffering have been added.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

use ieee.numeric_std.all;

library work;
use work.wr_fabric_pkg.all;
use work.genram_pkg.all;

entity xwrf_mux is
  generic(
    g_muxed_ports : integer := 2);
  port(
    clk_sys_i   : in  std_logic;
    rst_n_i     : in  std_logic;
    --ENDPOINT
    ep_src_o    : out t_wrf_source_out;
    ep_src_i    : in  t_wrf_source_in;
    ep_snk_o    : out t_wrf_sink_out;
    ep_snk_i    : in  t_wrf_sink_in;
    --Muxed ports
      -- Outgoing
    mux_src_o   : out t_wrf_source_out_array(g_muxed_ports-1 downto 0);
    mux_src_i   : in  t_wrf_source_in_array(g_muxed_ports-1 downto 0);
      --Incoming
    mux_snk_o   : out t_wrf_sink_out_array(g_muxed_ports-1 downto 0);
    mux_snk_i   : in  t_wrf_sink_in_array(g_muxed_ports-1 downto 0);
    --
    mux_class_i : in  t_wrf_mux_class(g_muxed_ports-1 downto 0)
    );
end xwrf_mux;

architecture behaviour of xwrf_mux is

  function f_hot_to_bin(x : std_logic_vector(g_muxed_ports-1 downto 0))
    return integer is
    variable rv : integer;
  begin
    rv := 0;
    -- if there are few ones set in _x_ then the least significant will be
    -- translated to bin
    for i in g_muxed_ports-1 downto 0 loop
      if x(i) = '1' then
        rv := i;
      end if;
    end loop;
    return rv;
  end function;

  function f_match_class(port_mask, pkt_mask : std_logic_vector(7 downto 0)) return std_logic is
    variable ret : std_logic;
  begin
    if((port_mask and pkt_mask) /= x"00") then
      return '1';
    else
      return '0';
    end if;
  end function;

  function f_select_input_fifo_data(
      data_in     : std_logic_vector(17 downto 0);
      select_bit  : std_logic)
  return std_logic_vector(17 downto 0) is
    variable v_ret : std_logic_vector(17 downto 0) := (others => '0');
  begin
    if( select_bit = '1' ) then
      v_ret := data_in;
    else
      v_ret := (others => '0');
    end if;
    return v_ret;
  end function;

  --==================================--
  --  Masters to Endpoint mux signals --
  --==================================--
  type   t_mux is (MUX_SEL, MUX_TRANSFER);
  signal mux        : t_mux;
  signal mux_cycs   : std_logic_vector(g_muxed_ports-1 downto 0);
  signal mux_rrobin : std_logic_vector(g_muxed_ports-1 downto 0);
  signal mux_select : std_logic_vector(g_muxed_ports-1 downto 0);

  --==================================--
  -- Endpoint to Slaves demux signals --
  --==================================--
  -- To write into the FIFO.
  type   t_demux_into_fifo is (DMUX_INTO_FIFO_WAIT, DMUX_INTO_FIFO_STATUS, DMUX_INTO_FIFO_WRITING);
  signal demux_into_fifo_fsm        : t_demux_into_fifo;
  signal dmux_into_fifo_sel         : std_logic_vector(g_muxed_ports-1 downto 0);
  signal dmux_into_fifo_select      : std_logic_vector(g_muxed_ports-1 downto 0);
  signal dmux_into_fifo_status_reg  : std_logic_vector(15 downto 0);
  signal ep_snk_out_stall           : std_logic;

  -- To read from the FIFO.
  type   t_demux_from_fifo is (DMUX_FROM_FIFO_WAIT, DMUX_FROM_FIFO_SEND);
  type   t_demux_from_fifo_fsm_array is array(g_muxed_ports-1 downto 0) of t_demux_from_fifo;
  signal demux_from_fifo_fsm_array  : t_demux_from_fifo_fsm_array;
  signal dmux_fifo_rd_en            : std_logic_vector(g_muxed_ports-1 downto 0) := (others => '0');
  signal dmux_fifo_wr_en            : std_logic := '0';

  type t_dmux_fifo_data_out is array (g_muxed_ports-1 downto 0) of std_logic_vector(17 downto 0);
  signal dmux_fifo_data_out     : t_dmux_fifo_data_out;
  signal dmux_fifo_data_in      : std_logic_vector(17 downto 0);
  signal dmux_fifo_full_out     : std_logic_vector(g_muxed_ports-1 downto 0);
  signal dmux_fifo_empty_out    : std_logic_vector(g_muxed_ports-1 downto 0);
  signal dmux_fifo_valid_out    : std_logic_vector(g_muxed_ports-1 downto 0);
  signal dmux_fifo_prog_full    : std_logic_vector(g_muxed_ports-1 downto 0);

  -- Constant to manage the prog_full triggering.
  constant c_prog_full_thresh_assert : std_logic_vector(4 downto 0) := "11100"; -- 28
  constant c_prog_full_thresh_negate : std_logic_vector(4 downto 0) := "11010"; -- 26

  constant c_zeros : std_logic_vector(g_muxed_ports-1 downto 0) := (others => '0');

  -- Signal to store the output mux source.
  signal s_mux_src_out_array : t_wrf_source_out_array(g_muxed_ports-1 downto 0);

  -- Just to receive the last 16 bits from the fifo.
  signal s_fifo_empty_delayed : std_logic_vector(g_muxed_ports-1 downto 0) := (others => '1');

  -- Just to discard the first read from the FIFOs
  signal s_fifo_trash_read : std_logic_vector(g_muxed_ports-1 downto 0) := (others => '0');

  -- The FIFO is USED to store the demux packets.
    component mux_buffering_fifo is
      port (
        clk         : in std_logic;
        srst         : in std_logic;    --pvt
        din         : in std_logic_vector(17 downto 0);
        wr_en       : in std_logic;
        rd_en       : in std_logic;
        dout        : out std_logic_vector(17 downto 0);
        full        : out std_logic;
        empty       : out std_logic;
        valid       : out std_logic;
        prog_full   : out std_logic;
        prog_full_thresh_assert : in std_logic_vector(4 downto 0);
        prog_full_thresh_negate : in std_logic_vector(4 downto 0));
    end component;

begin

  --=============================================--
  --                                             --
  --   Many Fabric Masters talking to ENDPOINT   --
  --                                             --
  --=============================================--
  GEN_MUX_CYCS_REG : for I in 0 to g_muxed_ports-1 generate
    mux_cycs(I) <= mux_snk_i(I).cyc;
  end generate;

  p_mux : process(clk_sys_i)
  begin
    if rising_edge(clk_sys_i) then
      if (rst_n_i = '0') then
        mux_rrobin(0)                        <= '1';
        mux_rrobin(g_muxed_ports-1 downto 1) <= (others => '0');
        mux                                  <= MUX_SEL;
      else
        case mux is
          when MUX_SEL =>
            if (unsigned(mux_cycs and mux_rrobin) /= 0)then
              mux_select <= mux_cycs and mux_rrobin;
              mux        <= MUX_TRANSFER;
            else
              mux_select <= (others => '0');
              mux_rrobin <= mux_rrobin(0) & mux_rrobin(g_muxed_ports-1 downto 1);
            end if;

          when MUX_TRANSFER =>
            if(unsigned(mux_cycs and mux_select) = 0) then  --cycle end
              mux_rrobin <= mux_rrobin(0) & mux_rrobin(g_muxed_ports-1 downto 1);
              mux        <= MUX_SEL;
            end if;
        end case;

      end if;
    end if;
  end process;


  GEN_MUX_CONNS : for J in 0 to g_muxed_ports-1 generate
    mux_snk_o(J).ack <= ep_src_i.ack when(mux /= MUX_SEL and mux_select(J) = '1') else
                        '0';
    mux_snk_o(J).stall <= ep_src_i.stall when(mux /= MUX_SEL and mux_select(J) = '1') else
                          '1';
    mux_snk_o(J).err <= ep_src_i.err when(mux /= MUX_SEL and mux_select(J) = '1') else
                        '0';
  end generate;

  ep_src_o.cyc <= mux_snk_i(f_hot_to_bin(mux_select)).cyc when(mux /= MUX_SEL) else
                  '0';
  ep_src_o.stb <= mux_snk_i(f_hot_to_bin(mux_select)).stb when(mux /= MUX_SEL) else
                  '0';
  ep_src_o.adr <= mux_snk_i(f_hot_to_bin(mux_select)).adr;
  ep_src_o.dat <= mux_snk_i(f_hot_to_bin(mux_select)).dat;
  ep_src_o.sel <= mux_snk_i(f_hot_to_bin(mux_select)).sel;
  ep_src_o.we  <= '1';

  --================================================================================================--
  --                                                                                                --
  --                               ENDPOINT talking to many Fabric Slaves                           --
  --                                                                                                --
  --================================================================================================--

  -- To detect the destination multiplexed sink.
  CLASS_MATCH : for I in 0 to g_muxed_ports-1 generate
    dmux_into_fifo_sel(I) <= f_match_class(mux_class_i(I), f_unmarshall_wrf_status(dmux_into_fifo_status_reg).match_class);
  end generate;

  -- FSM to detect the destination source port and queue the packets into its FIFO.

  DMUX_PUT_INTO_FIFO_FSM : process(clk_sys_i)
  begin
    if rising_edge(clk_sys_i) then
      if (rst_n_i = '0') then
        dmux_into_fifo_select     <= (others => '0');
        dmux_into_fifo_status_reg <= (others => '0');
        dmux_fifo_data_in         <= (others => '0');
        dmux_fifo_wr_en           <= '0';
        demux_into_fifo_fsm       <= DMUX_INTO_FIFO_WAIT;
        ep_snk_out_stall          <= '0';
      else
        case demux_into_fifo_fsm is
          ---------------------------------------------------------------
          --State DMUX_WAIT: Wait for the WRF cycle to start and then
          --                 wait for the STATUS word
          ---------------------------------------------------------------
          when DMUX_INTO_FIFO_WAIT =>
          dmux_into_fifo_select     <= (others => '0');
          dmux_into_fifo_status_reg <= (others => '0');
          ep_snk_out_stall          <= '0';

          dmux_fifo_data_in <= (others => '0');
          dmux_fifo_wr_en   <= '0';

          if(ep_snk_i.cyc = '1' and ep_snk_i.stb = '1' and ep_snk_i.adr = c_WRF_STATUS) then
            ep_snk_out_stall          <= '1';           -- The next state doesn't receive any data.
            dmux_into_fifo_status_reg <= ep_snk_i.dat;
            demux_into_fifo_fsm       <= DMUX_INTO_FIFO_STATUS;
          end if;

        ---------------------------------------------------------------
        --State DMUX_STATUS: Send Status word to appropriate interface
        ---------------------------------------------------------------
          when DMUX_INTO_FIFO_STATUS =>
            if(to_integer(unsigned(dmux_into_fifo_sel)) = 0) then  --class not matched to anything, pass pkt to last port
              dmux_into_fifo_select(g_muxed_ports-1)  <= '1';
            else
              dmux_into_fifo_select <= dmux_into_fifo_sel;
            end if;

            dmux_fifo_data_in(17 downto 16) <= c_WRF_STATUS;
            dmux_fifo_data_in(15 downto 0)  <= dmux_into_fifo_status_reg;

            dmux_fifo_wr_en     <= '1';
            ep_snk_out_stall    <= '0';
            demux_into_fifo_fsm <= DMUX_INTO_FIFO_WRITING;

          ---------------------------------------------------------------
          --State DMUX_STATUS: Send the Packet to the aproppiate FIFO.
          ---------------------------------------------------------------
            when DMUX_INTO_FIFO_WRITING =>

              dmux_fifo_data_in(17 downto 16) <= ep_snk_i.adr;  -- data type.
              dmux_fifo_data_in(15 downto 0)  <= ep_snk_i.dat;  -- data

              -- Modified to fix EB lost cycles.
              dmux_fifo_wr_en   <=  ep_snk_i.stb and not(ep_snk_out_stall);   -- problems with the EB core
--              dmux_fifo_wr_en   <=  ep_snk_i.stb;                           -- problems with the EPs.

              -- Till some trick to avoid FIFO fill out had been developed, we're able to accept all the packets.
              if ( dmux_fifo_prog_full = c_zeros ) then
                ep_snk_out_stall  <= '0';
              else
                ep_snk_out_stall  <= '1';
              end if;

              -- End of the CYC.
              if(ep_snk_i.cyc = '0') then
                demux_into_fifo_fsm <= DMUX_INTO_FIFO_WAIT;
              end if;

            when others =>
              demux_into_fifo_fsm <= DMUX_INTO_FIFO_WAIT;
        end case;

      end if;
    end if;
  end process;

  -- To the endpoint source.
  ep_snk_o.ack    <= dmux_fifo_wr_en;
  ep_snk_o.stall  <= ep_snk_out_stall;
  ep_snk_o.err    <= '0';
  ep_snk_o.rty    <= '0';

  -- The FIFOs to store the packets meanwhile the source demux ports weren't availabe.
  -- One FIFO per demux output source.
  GEN_FIFOS : for I in 0 to g_muxed_ports-1 generate
    GEN_BUFFERING_FIFO_X : mux_buffering_fifo
      port map (
        clk         => clk_sys_i,
        srst         => not(rst_n_i),   -- pvt, vivado 2016.2
        wr_en       => dmux_fifo_wr_en and dmux_into_fifo_select(I),
        din         => f_select_input_fifo_data(dmux_fifo_data_in, dmux_into_fifo_select(I)),

        rd_en       => dmux_fifo_rd_en(I),
        dout        => dmux_fifo_data_out(I),

        full        => dmux_fifo_full_out(I),
        empty       => dmux_fifo_empty_out(I),
        valid       => dmux_fifo_valid_out(I),

        prog_full   => dmux_fifo_prog_full(I),

        prog_full_thresh_assert => c_prog_full_thresh_assert,
        prog_full_thresh_negate => c_prog_full_thresh_negate);
  end generate;

  ----------------------------------------------------------------------

  DEMUX_GET_FROM_FIFO_FSM : for I in 0 to g_muxed_ports-1 generate

    DMUX_GET_FROM_FIFO_FSM_X : process(clk_sys_i)
      variable v_oob_cntr 			: integer := 0;
    begin
      if rising_edge(clk_sys_i) then
        if (rst_n_i = '0') then

          demux_from_fifo_fsm_array(I)  <= DMUX_FROM_FIFO_WAIT;
          v_oob_cntr                    := 0;
          s_fifo_empty_delayed(I)       <= '1';
          s_fifo_trash_read(I)          <= '0';

        else

          s_fifo_empty_delayed(I) <= dmux_fifo_empty_out(I);

          case demux_from_fifo_fsm_array(I) is
            when DMUX_FROM_FIFO_WAIT =>

              v_oob_cntr            := 0;
              s_fifo_trash_read(I)  <= '0';

              -- There is data to read inside the FIFO.
              if ( dmux_fifo_empty_out(I) = '0' ) then

                if ( dmux_fifo_data_out(I)(17 downto 16) = c_WRF_STATUS and dmux_fifo_data_out(I)(15 downto 0) /= x"0002" ) then
                  s_fifo_trash_read(I) <= '0';
                else
                  s_fifo_trash_read(I) <= '1';
                end if;

                demux_from_fifo_fsm_array(I)  <= DMUX_FROM_FIFO_SEND;
              end if;

            when DMUX_FROM_FIFO_SEND =>

            -- The first read if trash.
             s_fifo_trash_read(I)  <= '0';

            -- The packet is about to be finished. Only three OOB infos remain.
            if (s_mux_src_out_array(I).stb = '1' and s_mux_src_out_array(I).adr = c_WRF_OOB) then
              v_oob_cntr := v_oob_cntr + 1;
            end if;

            -- The packet has been transmitted or interrupted (error).
            if ( v_oob_cntr = 3  or (s_mux_src_out_array(I).adr = c_WRF_STATUS and s_mux_src_out_array(I).dat = x"0002" and s_mux_src_out_array(I).stb = '1')) then
              demux_from_fifo_fsm_array(I)  <= DMUX_FROM_FIFO_WAIT;
            end if;

          end case;
        end if;
      end if;
    end process;

  -- Output source.
  s_mux_src_out_array(I).cyc  <= '1' when (demux_from_fifo_fsm_array(I) =  DMUX_FROM_FIFO_SEND and s_fifo_trash_read(I) = '0') else '0';

  s_mux_src_out_array(I).dat  <= dmux_fifo_data_out(I)(15 downto 0) when (demux_from_fifo_fsm_array(I) =  DMUX_FROM_FIFO_SEND)
                              else (others => '0');

  s_mux_src_out_array(I).adr  <= dmux_fifo_data_out(I)(17 downto 16) when (demux_from_fifo_fsm_array(I) =  DMUX_FROM_FIFO_SEND)
                              else (others => '0');

  s_mux_src_out_array(I).stb  <= '1' when (demux_from_fifo_fsm_array(I) =  DMUX_FROM_FIFO_SEND and
                              mux_src_i(I).stall = '0' and s_fifo_empty_delayed(I) = '0' and s_fifo_trash_read(I) = '0')
                              else '0'; -- or valid = '1'

  s_mux_src_out_array(I).sel  <= (others => '1') when (demux_from_fifo_fsm_array(I) =  DMUX_FROM_FIFO_SEND) else (others => '0');

  s_mux_src_out_array(I).we   <= '1';

  dmux_fifo_rd_en(I)          <= '1' when ((demux_from_fifo_fsm_array(I) =  DMUX_FROM_FIFO_SEND and
                              mux_src_i(I).stall = '0' and dmux_fifo_empty_out(I) = '0') or (s_fifo_trash_read(I) = '1') )
                              else '0';

  end generate;

  -- The mux source output array.
  mux_src_o <= s_mux_src_out_array;

end behaviour;
