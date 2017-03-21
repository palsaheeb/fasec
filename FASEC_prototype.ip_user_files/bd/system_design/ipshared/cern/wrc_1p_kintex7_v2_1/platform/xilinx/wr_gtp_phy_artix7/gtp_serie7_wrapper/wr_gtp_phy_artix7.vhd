-------------------------------------------------------------------------------
-- Title      : Deterministic Xilinx GTPE wrapper - Artix-7 top module
-- Project    : White Rabbit Switch
-------------------------------------------------------------------------------
-- File       : wr_gtp_phy_artix7.vhd
-- Author     : Emilio Marín, Tomasz Wlostowski
-- Company    : CERN BE-CO-HT
-- Created    : 2014-10-21
-- Last update: 2014-10-21
-- Platform   : FPGA-generic
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Dual channel wrapper for Xilinx Artix-7 GTP adapted for
-- deterministic delays at 1.25 Gbps.
-------------------------------------------------------------------------------
--
-- Copyright (c) 2010 CERN / Tomasz Wlostowski
--
-- This source file is free software; you can redistribute it
-- and/or modify it under the terms of the GNU Lesser General
-- Public License as published by the Free Software Foundation;
-- either version 2.1 of the License, or (at your option) any
-- later version.
--
-- This source is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE.  See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from http://www.gnu.org/licenses/lgpl-2.1.html
--
--
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author    Description
-- 2014-10-21  0.1      emilioml  Initial release based on "wr_gtx_phy_spartan6.vhd" & "wr_gtx_phy_virtex6.vhd"
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library work;
use work.disparity_gen_pkg.all;
use work.gencores_pkg.all;

entity wr_gtp_phy_artix7 is

  generic (
    -- set to non-zero value to speed up the simulation by reducing some delays
    g_simulation      : integer := 0
    );

  port (

    -- dedicated GTP clock input
    gtp_clk_i : in std_logic;

	 -- reset input, active hi
    rst_i : in std_logic;

    -- TX path, synchronous to tx_out_clk_o (62.5 MHz): NEW REF CLOCK.
    tx_out_clk_o : out std_logic;

    -- Port 0

    -- TX path, synchronous to ch0_ref_clk_i
    -- ch0_ref_clk_i : in std_logic; -- Not needed

    -- data input (8 bits, not 8b10b-encoded)
    ch0_tx_data_i : in std_logic_vector(15 downto 0);

    -- 1 when tx_data_i contains a control code, 0 when it's a data byte
    ch0_tx_k_i : in std_logic_vector(1 downto 0) := "00";           --Increased up to 2

    -- disparity of the currently transmitted 8b10b code (1 = plus, 0 = minus).
    -- Necessary for the PCS to generate proper frame termination sequences.
    ch0_tx_disparity_o : out std_logic;

    -- Encoding error indication (1 = error, 0 = no error)
    ch0_tx_enc_err_o : out std_logic;

    -- RX path, synchronous to ch0_rx_rbclk_o.

    -- RX recovered clock
    ch0_rx_rbclk_o : out std_logic;

    -- 8b10b-decoded data output. The data output must be kept invalid before
    -- the transceiver is locked on the incoming signal to prevent the EP from
    -- detecting a false carrier.
    ch0_rx_data_o : out std_logic_vector(15 downto 0) := (others => '0');

    -- 1 when the byte on rx_data_o is a control code
    ch0_rx_k_o : out std_logic_vector(1 downto 0) := "00";           --Increased up to 2

    -- encoding error indication
    ch0_rx_enc_err_o : out std_logic;

    -- RX bitslide indication, indicating the delay of the RX path of the
    -- transceiver (in UIs). Must be valid when ch0_rx_data_o is valid.
    ch0_rx_bitslide_o : out std_logic_vector(4 downto 0);		--Increased up to 4.

    -- local loopback enable (Tx->Rx), active hi
    ch0_loopen_i : in std_logic_vector(2 downto 0);

    -- transmitter PRBS generator test pattern.
    ch0_tx_prbs_sel_i : in std_logic_vector(2 downto 0);

    -- The channel 0 is ready.
    ch0_ready_o : out std_logic;

-- Port 1

    -- ch1_tx_out_clk_o : out std_logic;
    -- ch1_ref_clk_i    : in std_logic;     --Not needed

    ch1_tx_data_i      : in  std_logic_vector(15 downto 0) := (others => '0');  --Increased up to 16
    ch1_tx_k_i         : in std_logic_vector(1 downto 0) := "00";           --Increased up to 2
    ch1_tx_disparity_o : out std_logic;
    ch1_tx_enc_err_o   : out std_logic;

    ch1_rx_data_o     : out std_logic_vector(15 downto 0);                 --Increased up to 16
    ch1_rx_rbclk_o    : out std_logic;
    ch1_rx_k_o        : out std_logic_vector(1 downto 0) := "00";
    ch1_rx_enc_err_o  : out std_logic;
    ch1_rx_bitslide_o : out std_logic_vector(4 downto 0);                  --Increased up to 4
    ch1_loopen_i      : in std_logic_vector(2 downto 0);

    ch1_tx_prbs_sel_i : in std_logic_vector(2 downto 0);
    ch1_ready_o       : out std_logic;

-- Serial I/O

    ch0_pad_txn_o : out std_logic;
    ch0_pad_txp_o : out std_logic;

    ch0_pad_rxn_i : in std_logic := '0';
    ch0_pad_rxp_i : in std_logic := '0';

    ch1_pad_txn_o : out std_logic;
    ch1_pad_txp_o : out std_logic;

    ch1_pad_rxn_i : in std_logic := '0';
    ch1_pad_rxp_i : in std_logic := '0'

    );
end wr_gtp_phy_artix7;

architecture rtl of wr_gtp_phy_artix7 is

----------------------------------
----- Components declaration. ----
----------------------------------

component WHITERABBIT_GTPE_2PCHANNEL_WRAPPER_GT
  generic
  (
    -- Simulation attributes
    WRAPPER_SIM_GTRESET_SPEEDUP    : string   := "false" -- Set to "true" to speed up sim reset
  );
  port
  (

	 SYS_CLK_IN               : in   std_logic;  --Ref clock used for TX phase align. eml.

    --------------------------- TX Phase Align Ports --------------------------
    run_tx_phalignment_i                     : in   std_logic;
    rst_tx_phalignment_i                     : in   std_logic;
    tx_phalignment_done_o                    : out  std_logic;


    --GT0  (X0Y0)
    GT0_DRPADDR_IN                          : in   std_logic_vector(8 downto 0);
    GT0_DRPCLK_IN                           : in   std_logic;
    GT0_DRPDI_IN                            : in   std_logic_vector(15 downto 0);
    GT0_DRPDO_OUT                           : out  std_logic_vector(15 downto 0);
    GT0_DRPEN_IN                            : in   std_logic;
    GT0_DRPRDY_OUT                          : out  std_logic;
    GT0_DRPWE_IN                            : in   std_logic;
    GT0_EYESCANDATAERROR_OUT                : out  std_logic;
    GT0_LOOPBACK_IN                         : in   std_logic_vector(2 downto 0);
    GT0_RXUSERRDY_IN                        : in   std_logic;
    GT0_RXCHARISK_OUT                       : out  std_logic_vector(1 downto 0);
    GT0_RXDISPERR_OUT                       : out  std_logic_vector(1 downto 0);
    GT0_RXNOTINTABLE_OUT                    : out  std_logic_vector(1 downto 0);
    GT0_RXBYTEISALIGNED_OUT                 : out  std_logic;
    GT0_RXSLIDE_IN                          : in   std_logic;
    GT0_RXCOMMADET_OUT                      : out  std_logic;  --eml. Added.
    GT0_GTRXRESET_IN                        : in   std_logic;
    GT0_RXDATA_OUT                          : out  std_logic_vector(15 downto 0);
    GT0_RXOUTCLK_OUT                        : out  std_logic;
    GT0_RXPMARESET_IN                       : in   std_logic;
    GT0_RXUSRCLK_IN                         : in   std_logic;
    GT0_RXUSRCLK2_IN                        : in   std_logic;
    GT0_GTPRXN_IN                           : in   std_logic;
    GT0_GTPRXP_IN                           : in   std_logic;
    GT0_RXCDRRESET_IN                       : in   std_logic;  --eml. Added.
    GT0_RXCDRLOCK_OUT                       : out  std_logic;
    GT0_RXELECIDLE_OUT                      : out  std_logic;
    GT0_RXLPMHFHOLD_IN                      : in   std_logic;
    GT0_RXLPMLFHOLD_IN                      : in   std_logic;
    GT0_RXRESETDONE_OUT                     : out  std_logic;
    GT0_TXUSERRDY_IN                        : in   std_logic;
    GT0_TXCHARISK_IN                        : in   std_logic_vector(1 downto 0);
    GT0_GTTXRESET_IN                        : in   std_logic;
    GT0_TXDATA_IN                           : in   std_logic_vector(15 downto 0);
    GT0_TXOUTCLK_OUT                        : out  std_logic;
    GT0_TXOUTCLKFABRIC_OUT                  : out  std_logic;
    GT0_TXOUTCLKPCS_OUT                     : out  std_logic;
    GT0_TXUSRCLK_IN                         : in   std_logic;
    GT0_TXUSRCLK2_IN                        : in   std_logic;
    GT0_GTPTXN_OUT                          : out  std_logic;
    GT0_GTPTXP_OUT                          : out  std_logic;
    GT0_TXRESETDONE_OUT                     : out  std_logic;
    GT0_TXPRBSSEL_IN                        : in   std_logic_vector(2 downto 0);

    --GT1  (X0Y1)
    GT1_DRPADDR_IN                          : in   std_logic_vector(8 downto 0);
    GT1_DRPCLK_IN                           : in   std_logic;
    GT1_DRPDI_IN                            : in   std_logic_vector(15 downto 0);
    GT1_DRPDO_OUT                           : out  std_logic_vector(15 downto 0);
    GT1_DRPEN_IN                            : in   std_logic;
    GT1_DRPRDY_OUT                          : out  std_logic;
    GT1_DRPWE_IN                            : in   std_logic;
    GT1_EYESCANDATAERROR_OUT                : out  std_logic;
    GT1_LOOPBACK_IN                         : in   std_logic_vector(2 downto 0);
    GT1_RXUSERRDY_IN                        : in   std_logic;
    GT1_RXCHARISK_OUT                       : out  std_logic_vector(1 downto 0);
    GT1_RXDISPERR_OUT                       : out  std_logic_vector(1 downto 0);
    GT1_RXNOTINTABLE_OUT                    : out  std_logic_vector(1 downto 0);
    GT1_RXBYTEISALIGNED_OUT                 : out  std_logic;
    GT1_RXSLIDE_IN                          : in   std_logic;
    GT1_RXCOMMADET_OUT                      : out  std_logic;  --Added. eml.
    GT1_GTRXRESET_IN                        : in   std_logic;
    GT1_RXDATA_OUT                          : out  std_logic_vector(15 downto 0);
    GT1_RXOUTCLK_OUT                        : out  std_logic;
    GT1_RXPMARESET_IN                       : in   std_logic;
    GT1_RXUSRCLK_IN                         : in   std_logic;
    GT1_RXUSRCLK2_IN                        : in   std_logic;
    GT1_GTPRXN_IN                           : in   std_logic;
    GT1_GTPRXP_IN                           : in   std_logic;
    GT1_RXCDRRESET_IN                       : in   std_logic;  --Added eml.
    GT1_RXCDRLOCK_OUT                       : out  std_logic;
    GT1_RXELECIDLE_OUT                      : out  std_logic;
    GT1_RXLPMHFHOLD_IN                      : in   std_logic;
    GT1_RXLPMLFHOLD_IN                      : in   std_logic;
    GT1_RXRESETDONE_OUT                     : out  std_logic;
    GT1_TXUSERRDY_IN                        : in   std_logic;
    GT1_TXCHARISK_IN                        : in   std_logic_vector(1 downto 0);
    GT1_GTTXRESET_IN                        : in   std_logic;
    GT1_TXDATA_IN                           : in   std_logic_vector(15 downto 0);
    GT1_TXOUTCLK_OUT                        : out  std_logic;
    GT1_TXOUTCLKFABRIC_OUT                  : out  std_logic;
    GT1_TXOUTCLKPCS_OUT                     : out  std_logic;
    GT1_TXUSRCLK_IN                         : in   std_logic;
    GT1_TXUSRCLK2_IN                        : in   std_logic;
    GT1_GTPTXN_OUT                          : out  std_logic;
    GT1_GTPTXP_OUT                          : out  std_logic;
    GT1_TXRESETDONE_OUT                     : out  std_logic;
    GT1_TXPRBSSEL_IN                        : in   std_logic_vector(2 downto 0);

    ---------------------------- Common Block - Ports --------------------------
    GT0_GTREFCLK0_IN                        : in   std_logic;
    GT0_PLL0LOCK_OUT                        : out  std_logic;
    GT0_PLL0LOCKDETCLK_IN                   : in   std_logic;
    GT0_PLL0REFCLKLOST_OUT                  : out  std_logic;
    GT0_PLL0RESET_IN                        : in   std_logic);
  end component;

  component BUFG
    port (
      O : out std_ulogic;
      I : in  std_ulogic);
  end component;

  component gtp_bitslide
    generic (
      g_simulation : integer;
      g_target     : string := "artix7");
    port (
      gtp_rst_i                : in  std_logic;
      gtp_rx_clk_i             : in  std_logic;
      gtp_rx_comma_det_i       : in  std_logic;
      gtp_rx_byte_is_aligned_i : in  std_logic;
      serdes_ready_i           : in  std_logic;
      gtp_rx_slide_o           : out std_logic;
      gtp_rx_cdr_rst_o         : out std_logic;
      bitslide_o               : out std_logic_vector(4 downto 0);
      synced_o                 : out std_logic);
  end component;

--------------------------------
---  Constants declaration.  ---
--------------------------------

  constant c_rxcdrlock_max            : integer := 30;
  constant c_reset_cnt_max            : integer := 128;	 -- Reset pulse width 64 * 8 = 512 ns

--------------------------------
----- Signals declaration. -----
--------------------------------

	signal ch0_gtp_reset        : std_logic;
	signal ch0_gtp_loopback     : std_logic_vector(2 downto 0) := "000";
	signal ch0_gtp_pll_lockdet  : std_logic;
	signal ch0_tx_pma_set_phase : std_logic                    := '0';

	signal ch0_tx_rundisp_vec : std_logic_vector(3 downto 0);

	signal ch0_tx_en_pma_phase_align : std_logic := '0';

	signal ch0_rx_data_int                : std_logic_vector(15 downto 0);
	signal ch0_rx_k_int                   : std_logic_vector(1 downto 0);
	signal ch0_rx_disp_err                : std_logic_vector(1 downto 0);
  signal ch0_rx_invcode                 : std_logic_vector(1 downto 0);

	signal ch0_rx_byte_is_aligned : std_logic;
	signal ch0_rx_comma_det       : std_logic;
	signal ch0_rx_cdr_rst         : std_logic := '0';
	signal ch0_rx_divclk          : std_logic;
	signal ch0_rx_slide           : std_logic := '0';

	signal ch0_gtp_locked : std_logic;
	signal ch0_align_done : std_logic;
	signal ch0_rx_synced  : std_logic;

	signal ch0_gtp_clkout_int                                : std_logic_vector(1 downto 0);
	signal ch0_rx_enable_output, ch0_rx_enable_output_synced : std_logic;


	signal ch1_gtp_reset        : std_logic;
	signal ch1_gtp_loopback     : std_logic_vector(2 downto 0) := "000";
	signal ch1_gtp_pll_lockdet  : std_logic;
	signal ch1_tx_pma_set_phase : std_logic                    := '0';

	signal ch1_tx_rundisp_vec : std_logic_vector(3 downto 0);

	signal ch1_tx_en_pma_phase_align : std_logic := '0';

	signal ch1_rx_data_int                : std_logic_vector(15 downto 0);
	signal ch1_rx_k_int                   : std_logic_vector(1 downto 0);
	signal ch1_rx_disp_err                : std_logic_vector(1 downto 0);
  signal ch1_rx_invcode                 : std_logic_vector(1 downto 0);

	signal ch1_rx_byte_is_aligned : std_logic;
	signal ch1_rx_comma_det       : std_logic;
	signal ch1_rx_cdr_rst         : std_logic := '0';
	signal ch1_rx_divclk          : std_logic;
	signal ch1_rx_slide           : std_logic := '0';

	signal ch1_gtp_locked : std_logic;
	signal ch1_align_done : std_logic;
	signal ch1_rx_synced  : std_logic;

	signal ch1_gtp_clkout_int                                : std_logic_vector(1 downto 0);
	signal ch1_rx_enable_output, ch1_rx_enable_output_synced : std_logic;

	signal ch0_rx_bitslide_int : std_logic_vector(4 downto 0);
	signal ch1_rx_bitslide_int : std_logic_vector(4 downto 0);


	signal ch0_disparity_set : std_logic;
	signal ch1_disparity_set : std_logic;

	signal ch0_tx_chardispmode : std_logic;
	signal ch1_tx_chardispmode : std_logic;

	signal ch0_tx_chardispval : std_logic;
	signal ch1_tx_chardispval : std_logic;

	signal ch0_rx_cdr_lock : std_logic;
	signal ch1_rx_cdr_lock : std_logic;

  signal ch0_gtreset : std_logic;
  signal ch1_gtreset : std_logic;

  signal ch0_tx_is_k_swapped : std_logic_vector(1 downto 0);
  signal ch0_tx_data_swapped : std_logic_vector(15 downto 0);
  signal ch1_tx_is_k_swapped : std_logic_vector(1 downto 0);
  signal ch1_tx_data_swapped : std_logic_vector(15 downto 0);

  signal ch0_rx_rec_clk_bufin   : std_logic;
  signal ch1_rx_rec_clk_bufin   : std_logic;
  signal ch0_rx_rec_clk         : std_logic;
  signal ch1_rx_rec_clk         : std_logic;

  signal qpll_lockdet   : std_logic;

	signal ch0_tx_out_clk_bufin   : std_logic;
	signal ch0_tx_out_clk         : std_logic;

  signal ch0_rx_rst_done    : std_logic;
  signal ch0_tx_rst_done    : std_logic;
  signal ch0_rst_done       : std_logic;
  signal ch0_rst_done_n     : std_logic;
  signal ch1_rx_rst_done    : std_logic;
  signal ch1_tx_rst_done    : std_logic;
  signal ch1_rst_done       : std_logic;
  signal ch1_rst_done_n     : std_logic;

  signal ch0_pll_lockdet    : std_logic;
  signal ch0_is_ready       : std_logic;
  signal ch1_pll_lockdet    : std_logic;
  signal ch1_is_ready       : std_logic;

  signal ch0_cur_disp : t_8b10b_disparity;
  signal ch1_cur_disp : t_8b10b_disparity;

  --Reset stuff
  signal rst_synced    : std_logic;
  signal rst_int       : std_logic := '1';

  -- Delay in cdr lock stuff
  signal ch0_rx_cdr_lock_filtered  :  std_logic;
  signal ch1_rx_cdr_lock_filtered  :  std_logic;

  --debugging stuff
  signal ch0_rxpll_lockdet  : std_logic;
  signal ch0_txpll_lockdet  : std_logic;

  signal ch1_rxpll_lockdet  : std_logic;
  signal ch1_txpll_lockdet  : std_logic;

  --Debugging stuff. eml.
  signal pll_clk_lost : std_logic;
  signal s_ch0_rx_bitslide : std_logic_vector(4 downto 0);
  signal s_ch1_rx_bitslide : std_logic_vector(4 downto 0);

  -- Singular resets for Rx and TX before all resets went together (ch0_gtreset).
  signal ch0_rx_reset : std_logic := '0';
  signal ch0_tx_reset : std_logic := '0';
  signal ch1_rx_reset : std_logic := '0';
  signal ch1_tx_reset : std_logic := '0';

  -- Signal to TX phase align
  signal ch0_serdes_ready        : std_logic := '0';
  signal ch1_serdes_ready        : std_logic := '0';

  signal s_run_tx_phalignment    : std_logic := '0';
  signal s_rst_tx_phalignment    : std_logic := '0';
  signal s_tx_phalignment_done   : std_logic := '0';

  begin --rlt

  -- Reset Stuff
  U_EdgeDet_rst_i : gc_sync_ffs port map (
    clk_i    => gtp_clk_i,
    rst_n_i  => '1',
    data_i   => rst_i,
    ppulse_o => open,

    synced_o => rst_synced,
    npulse_o => open
    );

  p_reset_pulse : process(gtp_clk_i, rst_synced)
    variable reset_cnt      : integer range 0 to c_reset_cnt_max := c_reset_cnt_max;
  begin
    if(rst_synced = '1') then
      reset_cnt := 0;
      rst_int <= '1';
    elsif rising_edge(gtp_clk_i) then
      if reset_cnt /= c_reset_cnt_max then
         reset_cnt := reset_cnt + 1;
		   rst_int <= '1';
      else
         rst_int <= '0';
      end if;
    end if;
  end process;


  --Delay for rx_cdr_lock

  p_rx_cdr_lock_filter_ch0 : process(ch0_rx_rec_clk, rst_int)
    variable rxcdrlock_cnt      : integer range 0 to c_rxcdrlock_max;
  begin
    if(rst_int = '1') then
      rxcdrlock_cnt := 0;
      ch0_rx_cdr_lock_filtered <= '0';
    elsif rising_edge(ch0_rx_rec_clk) then
      if ch0_rx_cdr_lock = '0' then
        if rxcdrlock_cnt /= c_rxcdrlock_max then
           rxcdrlock_cnt := rxcdrlock_cnt + 1;
        else
           ch0_rx_cdr_lock_filtered <= '0';
        end if;
      else
        rxcdrlock_cnt := 0;
        ch0_rx_cdr_lock_filtered <= '1';
      end if;
    end if;
  end process;


  p_rx_cdr_lock_filter_ch1 : process(ch1_rx_rec_clk, rst_int)
    variable rxcdrlock_cnt      : integer range 0 to c_rxcdrlock_max;
  begin
    if(rst_int = '1') then
      rxcdrlock_cnt := 0;
      ch1_rx_cdr_lock_filtered <= '0';
    elsif rising_edge(ch1_rx_rec_clk) then
      if ch1_rx_cdr_lock = '0' then
        if rxcdrlock_cnt /= c_rxcdrlock_max then
           rxcdrlock_cnt := rxcdrlock_cnt + 1;
        else
           ch1_rx_cdr_lock_filtered <= '0';
        end if;
      else
        rxcdrlock_cnt := 0;
        ch1_rx_cdr_lock_filtered <= '1';
      end if;
    end if;
  end process;


ch0_tx_enc_err_o <= '0';
ch1_tx_enc_err_o <= '0';

-- loopen_i determines:
--   '0' => gtp_loopback = "000" => normal operation
--   '1' => gtp_loopback = "010" => Near end PMA Loopback
ch0_gtp_loopback <= ch0_loopen_i;
ch1_gtp_loopback <= ch1_loopen_i;


	--Recovered clocks
CH0_U_BUF_RxRecClk : BUFG
   port map (
     I => ch0_rx_rec_clk_bufin,
     O => ch0_rx_rec_clk);

CH1_U_BUF_RxRecClk : BUFG
   port map (
     I => ch1_rx_rec_clk_bufin,
     O => ch1_rx_rec_clk);

-- drive the recovered clock outputs
 ch0_rx_rbclk_o <= ch0_rx_rec_clk;
 ch1_rx_rbclk_o <= ch1_rx_rec_clk;


-- swapping the TX data
 ch0_tx_is_k_swapped <= ch0_tx_k_i(0) & ch0_tx_k_i(1);
 ch0_tx_data_swapped <= ch0_tx_data_i(7 downto 0) & ch0_tx_data_i(15 downto 8);

 ch1_tx_is_k_swapped <= ch1_tx_k_i(0) & ch1_tx_k_i(1);
 ch1_tx_data_swapped <= ch1_tx_data_i(7 downto 0) & ch1_tx_data_i(15 downto 8);

-- Drive the TX clocks
  CH0_U_BUF_TxOutClk : BUFG
    port map (
      I => ch0_tx_out_clk_bufin,
      O => ch0_tx_out_clk);


-- GT0_TXOUTCLK is driven to TXUSRCLK1/2 for both GTs, so GT1_TXOUTCLK is no needed.
-- GT0_TXOUTCLK is the REF_CLK for the whole WRPC. This is a very important remark.

tx_out_clk_o <= ch0_tx_out_clk;

-- Reset done
ch0_rst_done    <= ch0_rx_rst_done and ch0_tx_rst_done;
ch0_rst_done_n  <= not ch0_rst_done;

ch1_rst_done    <= ch1_rx_rst_done and ch1_tx_rst_done;
ch1_rst_done_n  <= not ch1_rst_done;

--Ready?
ch0_txpll_lockdet  <= qpll_lockdet;
ch0_rxpll_lockdet  <= ch0_rx_cdr_lock_filtered;
ch0_rx_reset       <= (not qpll_lockdet) or ch0_rx_cdr_rst;	--The lack of locking in the internal PLL or the bitslide module could reset the Rx.
ch0_tx_reset		   <= (not qpll_lockdet);			-- Ch0 Tx module without reset
ch0_pll_lockdet    <= ch0_txpll_lockdet;

ch0_serdes_ready   <= ch0_rst_done and ch0_pll_lockdet;
ch0_is_ready       <= ch0_serdes_ready and s_tx_phalignment_done;
ch0_ready_o        <= ch0_is_ready;

ch1_txpll_lockdet  <= qpll_lockdet;
ch1_rxpll_lockdet  <= ch1_rx_cdr_lock_filtered;
ch1_rx_reset       <= (not qpll_lockdet) or ch1_rx_cdr_rst;
ch1_tx_reset		   <= (not qpll_lockdet);
ch1_pll_lockdet    <= ch1_txpll_lockdet;

ch1_serdes_ready   <= ch1_rst_done and ch1_pll_lockdet;
ch1_is_ready       <= ch1_serdes_ready and s_tx_phalignment_done;
ch1_ready_o        <= ch1_is_ready;

--TX Phase align signal
s_run_tx_phalignment <= ch0_serdes_ready and ch1_serdes_ready;
s_rst_tx_phalignment <= (not qpll_lockdet);
----------------------------------------------------------------------------------------------------------------

--Bitslides.

-- Channel 0

  CH0_U_Bitslide : gtp_bitslide
    generic map (
      g_simulation => g_simulation,
      g_target     => "artix7")
    port map (
      gtp_rst_i                => ch0_rst_done_n,
      gtp_rx_clk_i             => ch0_rx_rec_clk,
      gtp_rx_comma_det_i       => ch0_rx_comma_det,
      gtp_rx_byte_is_aligned_i => ch0_rx_byte_is_aligned,
      serdes_ready_i           => ch0_is_ready,
      gtp_rx_slide_o           => ch0_rx_slide,
      gtp_rx_cdr_rst_o         => ch0_rx_cdr_rst,
      bitslide_o               => s_ch0_rx_bitslide,
      synced_o                 => ch0_rx_synced);


-- Channel 1

  CH1_U_Bitslide : gtp_bitslide
    generic map (
      g_simulation => g_simulation,
      g_target     => "artix7")
    port map (
      gtp_rst_i                => ch1_rst_done_n,
      gtp_rx_clk_i             => ch1_rx_rec_clk,
      gtp_rx_comma_det_i       => ch1_rx_comma_det,
      gtp_rx_byte_is_aligned_i => ch1_rx_byte_is_aligned,
      serdes_ready_i           => ch1_is_ready,
      gtp_rx_slide_o           => ch1_rx_slide,
      gtp_rx_cdr_rst_o         => ch1_rx_cdr_rst,
      bitslide_o               => s_ch1_rx_bitslide,
      synced_o                 => ch1_rx_synced);


   ch0_rx_bitslide_o <= s_ch0_rx_bitslide;
   ch1_rx_bitslide_o <= s_ch1_rx_bitslide;
----------------------------------------------------------------------------------------------------------------
-- Put in order the Rx data

-- Channel 0
  ch0_p_gen_rx_outputs : process(ch0_rx_rec_clk, ch0_rst_done_n)
  begin
    if(ch0_rst_done_n = '1') then
      ch0_rx_data_o    <= (others => '0');
      ch0_rx_k_o       <= (others => '0');
      ch0_rx_enc_err_o <= '0';
    elsif rising_edge(ch0_rx_rec_clk) then
      if(ch0_is_ready = '1' and ch0_rx_synced = '1') then
        ch0_rx_data_o    <= ch0_rx_data_int(7 downto 0) & ch0_rx_data_int(15 downto 8);
        ch0_rx_k_o       <= ch0_rx_k_int(0) & ch0_rx_k_int(1);
        ch0_rx_enc_err_o <= ch0_rx_disp_err(0) or ch0_rx_disp_err(1) or ch0_rx_invcode(0) or ch0_rx_invcode(1);
      else
        ch0_rx_data_o    <= (others => '1');
        ch0_rx_k_o       <= (others => '1');
        ch0_rx_enc_err_o <= '1';
      end if;
    end if;
  end process;

-- Channel 1
  ch1_p_gen_rx_outputs : process(ch1_rx_rec_clk, ch1_rst_done_n)
  begin
    if(ch1_rst_done_n = '1') then
      ch1_rx_data_o    <= (others => '0');
      ch1_rx_k_o       <= (others => '0');
      ch1_rx_enc_err_o <= '0';
    elsif rising_edge(ch1_rx_rec_clk) then
      if(ch1_is_ready = '1' and ch1_rx_synced = '1') then
        ch1_rx_data_o    <= ch1_rx_data_int(7 downto 0) & ch1_rx_data_int(15 downto 8);
        ch1_rx_k_o       <= ch1_rx_k_int(0) & ch1_rx_k_int(1);
        ch1_rx_enc_err_o <= ch1_rx_disp_err(0) or ch1_rx_disp_err(1) or ch1_rx_invcode(0) or ch1_rx_invcode(1);
      else
        ch1_rx_data_o    <= (others => '1');
        ch1_rx_k_o       <= (others => '1');
        ch1_rx_enc_err_o <= '1';
      end if;
    end if;
  end process;
----------------------------------------------------------------------------------------------------------------
-- Generate disparity

-- Channel 0

  ch0_p_gen_tx_disparity : process(ch0_tx_out_clk, ch0_rst_done_n)
  begin
    if rising_edge(ch0_tx_out_clk) then
      if ch0_rst_done_n = '1' then
        ch0_cur_disp <= RD_MINUS;
      else
        ch0_cur_disp <= f_next_8b10b_disparity16(ch0_cur_disp, ch0_tx_k_i, ch0_tx_data_i);
      end if;
    end if;
  end process;

  ch0_tx_disparity_o <= to_std_logic(ch0_cur_disp);

-- Channel 1

-- ch0_tx_out_clk instead channel 1.

  ch1_p_gen_tx_disparity : process(ch0_tx_out_clk, ch1_rst_done_n)
  begin
    if rising_edge(ch0_tx_out_clk) then
      if ch1_rst_done_n = '1' then
        ch1_cur_disp <= RD_MINUS;
      else
        ch1_cur_disp <= f_next_8b10b_disparity16(ch1_cur_disp, ch1_tx_k_i, ch1_tx_data_i);
      end if;
    end if;
  end process;

  ch1_tx_disparity_o <= to_std_logic(ch1_cur_disp);
----------------------------------------------------------------------------------------------------------------

U_GTP_INST : WHITERABBIT_GTPE_2PCHANNEL_WRAPPER_GT
	generic map(
		 -- Simulation attributes
		WRAPPER_SIM_GTRESET_SPEEDUP => "false")
  port map
	(

    SYS_CLK_IN               => ch0_tx_out_clk,

    --------------------------- TX Phase Align Ports --------------------------
    run_tx_phalignment_i    =>  s_run_tx_phalignment,
    rst_tx_phalignment_i    =>  s_rst_tx_phalignment,
    tx_phalignment_done_o   =>  s_tx_phalignment_done,

    --_________________________________________________________________________
    --GT0  (X0Y0)
    --_________________________________________________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
    GT0_DRPADDR_IN            => (others => '0'),
    GT0_DRPCLK_IN             => ch0_tx_out_clk,  -- Be careful with the input clock
    GT0_DRPDI_IN              => (others => '0'),
    GT0_DRPDO_OUT             => open,
    GT0_DRPEN_IN              => '0',
    GT0_DRPRDY_OUT            => open,
    GT0_DRPWE_IN              => '0',
    -------------------------- RX Margin Analysis Ports ------------------------
    GT0_EYESCANDATAERROR_OUT  => open,
    ------------------------------- Loopback Ports -----------------------------
    GT0_LOOPBACK_IN           => ch0_gtp_loopback,
    --------------------- RX Initialization and Reset Ports --------------------
    GT0_RXUSERRDY_IN          => ch0_rx_cdr_lock_filtered,
    ------------------- Receive Ports - RX8B/10B Decoder Ports -----------------
    GT0_RXCHARISK_OUT         => ch0_rx_k_int,
    GT0_RXCDRRESET_IN         => '0',								--Don't use this pin. Before ch0_rx_cdr_rst
    GT0_RXCDRLOCK_OUT         => ch0_rx_cdr_lock,
    GT0_RXDISPERR_OUT         => ch0_rx_disp_err,
    GT0_RXNOTINTABLE_OUT      => ch0_rx_invcode,
    --------------- Receive Ports - Comma Detection and Alignment --------------
    GT0_RXBYTEISALIGNED_OUT   => ch0_rx_byte_is_aligned,
    GT0_RXSLIDE_IN            => ch0_rx_slide,
    GT0_RXCOMMADET_OUT        => ch0_rx_comma_det,
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
    GT0_GTRXRESET_IN          => ch0_rx_reset,
    GT0_RXPMARESET_IN         => '0',
    ------------------ Receive Ports - FPGA RX interface Ports -----------------
    GT0_RXDATA_OUT            => ch0_rx_data_int,
    --------------- Receive Ports - RX Fabric Output Control Ports -------------
    GT0_RXOUTCLK_OUT          => ch0_rx_rec_clk_bufin,

    ------------------ Receive Ports - FPGA RX Interface Ports -----------------
    GT0_RXUSRCLK_IN           => ch0_rx_rec_clk,	--check the pag 220 to understand better
    GT0_RXUSRCLK2_IN          => ch0_rx_rec_clk,

    --------------------------- Receive Ports - RX AFE -------------------------
    GT0_GTPRXN_IN             => ch0_pad_rxn_i,
    GT0_GTPRXP_IN             => ch0_pad_rxp_i,

    --------------------------- Receive Ports - PCIe, SATA/SAS status ----------
    GT0_RXELECIDLE_OUT        => open,

    --------------------- Receive Ports - RX Equilizer Ports -------------------
    GT0_RXLPMHFHOLD_IN        => '0',
    GT0_RXLPMLFHOLD_IN        => '0',

    -------------- Receive Ports -RX Initialization and Reset Ports ------------
    GT0_RXRESETDONE_OUT       => ch0_rx_rst_done,
    --------------------- TX Initialization and Reset Ports --------------------
    GT0_TXUSERRDY_IN          => qpll_lockdet,
    GT0_GTTXRESET_IN          => ch0_tx_reset,

    --------------------- Transmit Ports - TX Gearbox Ports --------------------
    GT0_TXCHARISK_IN          => ch0_tx_is_k_swapped,

    ------------------ Transmit Ports - TX Data Path interface -----------------
    GT0_TXDATA_IN             => ch0_tx_data_swapped,

    ----------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
    GT0_TXOUTCLK_OUT          => ch0_tx_out_clk_bufin,
    GT0_TXOUTCLKFABRIC_OUT    => open,
    GT0_TXOUTCLKPCS_OUT       => open,

    ------------------ Transmit Ports - FPGA TX Interface Ports ----------------
    GT0_TXUSRCLK_IN           => ch0_tx_out_clk,		-- NOT REF CLOCK
    GT0_TXUSRCLK2_IN          => ch0_tx_out_clk,		-- NOT REF CLOCK

    ---------------- Transmit Ports - TX Driver and OOB signaling --------------
    GT0_GTPTXN_OUT            => ch0_pad_txn_o,
    GT0_GTPTXP_OUT            => ch0_pad_txp_o,

    ------------- Transmit Ports - TX Initialization and Reset Ports -----------
    GT0_TXRESETDONE_OUT       => ch0_tx_rst_done,
    ------------------ Transmit Ports - pattern Generator Ports ----------------
    GT0_TXPRBSSEL_IN          => ch0_tx_prbs_sel_i,

    --_________________________________________________________________________
    --GT1  (X0Y1)
    --_________________________________________________________________________
    ---------------------------- Channel - DRP Ports  --------------------------
    GT1_DRPADDR_IN            => (others => '0'),
    GT1_DRPCLK_IN             => ch0_tx_out_clk,  -- Be careful with the input clock
    GT1_DRPDI_IN              => (others => '0'),
    GT1_DRPDO_OUT             => open,
    GT1_DRPEN_IN              => '0',
    GT1_DRPRDY_OUT            => open,
    GT1_DRPWE_IN              => '0',

    -------------------------- RX Margin Analysis Ports ------------------------
    GT1_EYESCANDATAERROR_OUT  => open,

    ------------------------------- Loopback Ports -----------------------------
    GT1_LOOPBACK_IN           => ch1_gtp_loopback,

    -------------------- RX Initialization and Reset Ports --------------------
    GT1_RXUSERRDY_IN          => ch1_rx_cdr_lock_filtered,

    --------------------- RX Initialization and Reset Ports --------------------
    GT1_RXCHARISK_OUT         => ch1_rx_k_int,
    GT1_RXCDRLOCK_OUT         => ch1_rx_cdr_lock,
	  GT1_RXCDRRESET_IN         => '0',					--Don't use this pin. ch1_rx_cdr_rst,
    GT1_RXDISPERR_OUT         => ch1_rx_disp_err,
    GT1_RXNOTINTABLE_OUT      => ch1_rx_invcode,

     --------------- Receive Ports - Comma Detection and Alignment --------------
    GT1_RXBYTEISALIGNED_OUT   => ch1_rx_byte_is_aligned,
    GT1_RXSLIDE_IN            => ch1_rx_slide,
    GT1_RXCOMMADET_OUT        => ch1_rx_comma_det,
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
    GT1_GTRXRESET_IN          => ch1_rx_reset,
    GT1_RXPMARESET_IN         => '0',

    ------------------ Receive Ports - FPGA RX interface Ports -----------------
    GT1_RXDATA_OUT            => ch1_rx_data_int,

    --------------- Receive Ports - RX Fabric Output Control Ports -------------
    GT1_RXOUTCLK_OUT          => ch1_rx_rec_clk_bufin,

    ------------------ Receive Ports - FPGA RX Interface Ports -----------------
    GT1_RXUSRCLK_IN           => ch1_rx_rec_clk,	--check the pag 220 to understand better
    GT1_RXUSRCLK2_IN          => ch1_rx_rec_clk,

    --------------------------- Receive Ports - RX AFE -------------------------
    GT1_GTPRXN_IN             => ch1_pad_rxn_i,
    GT1_GTPRXP_IN             => ch1_pad_rxp_i,

    --------------------------- Receive Ports - RX AFE -------------------------
    GT1_RXELECIDLE_OUT        => open,

    --------------------- Receive Ports - RX Equilizer Ports -------------------
    GT1_RXLPMHFHOLD_IN        => '0',
    GT1_RXLPMLFHOLD_IN        => '0',

    -------------- Receive Ports -RX Initialization and Reset Ports ------------
    GT1_RXRESETDONE_OUT        => ch1_rx_rst_done,

    --------------------- TX Initialization and Reset Ports --------------------
    GT1_TXUSERRDY_IN           => qpll_lockdet,
    GT1_GTTXRESET_IN           => ch1_tx_reset,

    --------------------- Transmit Ports - TX Gearbox Ports --------------------
    GT1_TXCHARISK_IN           => ch1_tx_is_k_swapped,

     ------------------ Transmit Ports - TX Data Path interface -----------------
    GT1_TXDATA_IN              => ch1_tx_data_swapped,

    ----------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
    GT1_TXOUTCLK_OUT           => open,	-- ch1_tx_out_clk_bufin is no needed. The ch0 is the important one.
    GT1_TXOUTCLKFABRIC_OUT     => open,
    GT1_TXOUTCLKPCS_OUT        => open,

    ----------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
    GT1_TXUSRCLK_IN            => ch0_tx_out_clk,
    GT1_TXUSRCLK2_IN           => ch0_tx_out_clk,

    ------------------ Transmit Ports - FPGA TX Interface Ports ----------------
    GT1_GTPTXN_OUT             => ch1_pad_txn_o,
    GT1_GTPTXP_OUT             => ch1_pad_txp_o,

    ------------- Transmit Ports - TX Initialization and Reset Ports -----------
    GT1_TXRESETDONE_OUT        => ch1_tx_rst_done,

    ------------------ Transmit Ports - pattern Generator Ports ----------------
    GT1_TXPRBSSEL_IN          => ch1_tx_prbs_sel_i,

    ---------------------------- Common Block - Ports --------------------------
    GT0_GTREFCLK0_IN          => gtp_clk_i,     -- Accoding to the CoreGen configuration this clock must be 125MHz (gtp dedicated clock)
    GT0_PLL0LOCK_OUT          => qpll_lockdet,
    GT0_PLL0LOCKDETCLK_IN     => '0',
    GT0_PLL0REFCLKLOST_OUT    => pll_clk_lost,
    GT0_PLL0RESET_IN          => rst_int);		-- Before rst_int. for v15

end rtl;
