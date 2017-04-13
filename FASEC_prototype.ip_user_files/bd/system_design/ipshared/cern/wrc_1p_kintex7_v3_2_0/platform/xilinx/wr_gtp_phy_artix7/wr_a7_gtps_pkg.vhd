library ieee;
use ieee.std_logic_1164.all;

library work;
use work.genram_pkg.all;
use work.wishbone_pkg.all;
use work.sysc_wbgen2_pkg.all;
use work.wr_fabric_pkg.all;

package wr_a7_gtps_pkg is

  component wr_gtp_phy_artix7
--    generic (
--      g_simulation : integer := 0);
    port (

    gtp_clk_i          : in std_logic;
    rst_i              : in std_logic;
    tx_out_clk_o       : out std_logic;

    -- Port 0
    ch0_tx_data_i      : in std_logic_vector(15 downto 0) := (others => '0');                 --Increased up to 16
    ch0_tx_k_i         : in std_logic_vector(1 downto 0) := "00";           --Increased up to 2
    ch0_tx_disparity_o : out std_logic;
    ch0_tx_enc_err_o   : out std_logic;
    ch0_rx_rbclk_o     : out std_logic;
    ch0_rx_data_o      : out std_logic_vector(15 downto 0);
    ch0_rx_k_o         : out std_logic_vector(1 downto 0) := "00";          --Increased up to 2
    ch0_rx_enc_err_o   : out std_logic;
    ch0_rx_bitslide_o  : out std_logic_vector(4 downto 0);		            --Increased up to 4.
    ch0_loopen_i       : in std_logic_vector(2 downto 0) := (others => '0');
    ch0_tx_prbs_sel_i  : in std_logic_vector(2 downto 0);
    ch0_ready_o        : out std_logic := '0';

-- Port 1
    ch1_tx_data_i      : in  std_logic_vector(15 downto 0) := (others => '0');  --Increased up to 16
    ch1_tx_k_i         : in std_logic_vector(1 downto 0) := "00";           --Increased up to 2
    ch1_tx_disparity_o : out std_logic;
    ch1_tx_enc_err_o   : out std_logic;
    ch1_rx_data_o      : out std_logic_vector(15 downto 0);                --Increased up to 16
    ch1_rx_rbclk_o     : out std_logic;
    ch1_rx_k_o         : out std_logic_vector(1 downto 0) := "00";          --Increased up to 2
    ch1_rx_enc_err_o   : out std_logic;
    ch1_rx_bitslide_o  : out std_logic_vector(4 downto 0);                 --Increased up to 4.
    ch1_loopen_i       : in std_logic_vector(2 downto 0) := (others => '0');
    ch1_tx_prbs_sel_i  : in std_logic_vector(2 downto 0);
    ch1_ready_o        : out std_logic := '0';

-- Serial I/O
    ch0_pad_txn_o : out std_logic;
    ch0_pad_txp_o : out std_logic;
    ch0_pad_rxn_i : in std_logic := '0';
    ch0_pad_rxp_i : in std_logic := '0';
    ch1_pad_txn_o : out std_logic;
    ch1_pad_txp_o : out std_logic;
    ch1_pad_rxn_i : in std_logic := '0';
    ch1_pad_rxp_i : in std_logic := '0');
  end component;

end wr_a7_gtps_pkg;
