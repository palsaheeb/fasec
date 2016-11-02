--------------------------------------------------------------------------------
-- File       : system_design_gig_ethernet_pcs_pma_0_0_tx_rate_adapt.vhd
-- Author     : Xilinx Inc.
--------------------------------------------------------------------------------
-- (c) Copyright 2011 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES. 
-- 
-- 
--------------------------------------------------------------------------------
-- Description: This module accepts transmitter data from the GMII/MII style
--              interface from the attached client MAC.  
--              For 10/100 Mbps the lower 4 bits of 8bit GMII_TXD bus are 
--              considered as the MII and are converted to 8 bit 
--              GMII data. 
--              At 1 Gbps, this GMII transmitter data will be valid on evey 
--              clock cycle of the 125MHz reference clock; at 100Mbps, this 
--              data will be repeated for a ten clock period duration of the
--              125MHz reference clock; at 10Mbps, this data will be
--              repeated for a hundred clock period duration of the
--              125MHz reference clock.
--
--              This module will sample the input transmitter GMII data
--              synchronously to the 125MHz reference clock.  This
--              sampled data can then be connected direcly to the input
--              GMII- style interface of the Ethernet 1000BASE-X PCS/PMA
--              or SGMII LogiCORE.


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity system_design_gig_ethernet_pcs_pma_0_0_tx_rate_adapt is
  port (
    reset             : in  std_logic;                      -- Synchronous reset.
    clk125m           : in  std_logic;                      -- Reference 125MHz transmitter clock.
    sgmii_clk_en      : in  std_logic;                      -- Clock enable pulse for the transmitter logic
    sgmii_ddr_clk_en  : in  std_logic;                      -- Double Clock rate enable pulse for the transmitter logic
    speed_is_10_100   : in  std_logic;                      -- Select GMII or MII
    gmii_txd_in       : in  std_logic_vector(7 downto 0);   -- Transmit data from client MAC.
    gmii_tx_en_in     : in  std_logic;                      -- Transmit data valid signal from client MAC.
    gmii_tx_er_in     : in  std_logic;                      -- Transmit error signal from client MAC.
    gmii_txd_out      : out  std_logic_vector(7 downto 0) := (others => '0');  -- Transmit data from client MAC.
    gmii_tx_en_out    : out std_logic := '0';                      -- Transmit data valid signal from client MAC.
    gmii_tx_er_out    : out std_logic := '0'                       -- Transmit error signal from client MAC.
  );
end system_design_gig_ethernet_pcs_pma_0_0_tx_rate_adapt;

architecture rtl of system_design_gig_ethernet_pcs_pma_0_0_tx_rate_adapt is


   signal mii_txd_reg1    : std_logic_vector(3 downto 0);
   signal mii_txd_reg2    : std_logic_vector(3 downto 0);
   signal mii_txd_reg3    : std_logic_vector(3 downto 0);
   signal mii_tx_en_reg1  : std_logic;
   signal mii_tx_en_reg2  : std_logic;
   signal mii_tx_en_reg3  : std_logic;
   signal mii_tx_en_reg4  : std_logic;
   signal mii_tx_er_reg1  : std_logic;
   signal mii_tx_er_reg2  : std_logic;
   signal mii_tx_er_reg3  : std_logic;
   signal align_done      : std_logic;
   signal align_even      : std_logic;
   signal align_even_reg1 : std_logic;
   signal align_even_reg2 : std_logic;
   signal toggle          : std_logic;
   signal toggle_reg1     : std_logic;
   signal gmii_txd_gen    : std_logic_vector(7 downto 0);
   signal gmii_tx_en_gen  : std_logic;
   signal gmii_tx_er_gen  : std_logic;


begin

  reg_block : process (clk125m)
  begin
     if clk125m'event and clk125m = '1' then
        if reset = '1' then  
           mii_txd_reg1    <= "0000";
           mii_txd_reg2    <= "0000";
           mii_txd_reg3    <= "0000";
           mii_tx_en_reg1  <= '0';
           mii_tx_en_reg2  <= '0';
           mii_tx_en_reg3  <= '0';
           mii_tx_en_reg4  <= '0';
           mii_tx_er_reg1  <= '0';
           mii_tx_er_reg2  <= '0';
           mii_tx_er_reg3  <= '0';
           toggle_reg1     <= '0';
           align_even_reg1 <= '0';
           align_even_reg2 <= '0';
        elsif  (sgmii_ddr_clk_en = '1') then
           mii_txd_reg1    <= gmii_txd_in(3 downto 0);
           mii_txd_reg2    <= mii_txd_reg1;
           mii_txd_reg3    <= mii_txd_reg2;
           mii_tx_en_reg1  <= gmii_tx_en_in;
           mii_tx_en_reg2  <= mii_tx_en_reg1;
           mii_tx_en_reg3  <= mii_tx_en_reg2;
           mii_tx_en_reg4  <= mii_tx_en_reg3;
           mii_tx_er_reg1  <= gmii_tx_er_in;
           mii_tx_er_reg2  <= mii_tx_er_reg1;
           mii_tx_er_reg3  <= mii_tx_er_reg2;
           toggle_reg1     <= toggle;
           align_even_reg1 <= align_even;
           align_even_reg2 <= align_even_reg1;
        end if;
     end if;
  end process reg_block;

  process_align : process (clk125m)
  begin
     if clk125m'event and clk125m = '1' then
        if reset = '1' then
           align_done <= '0';
           align_even <= '0';
        elsif (((gmii_txd_in(3 downto 0) & mii_txd_reg1) =  "11010101") and (gmii_tx_en_in = '1') and (sgmii_ddr_clk_en = '1') and (align_done = '0')) then
           align_done <= '1';
           align_even <= toggle;
        elsif ((gmii_tx_en_in = '0') and (sgmii_ddr_clk_en = '1') and (toggle_reg1 = '1')) then
           align_done <= '0';
           align_even <= '0';
        end if;
     end if;
  end process process_align;

    
  process_toggle : process (clk125m)
  begin
     if clk125m'event and clk125m = '1' then
        if reset = '1' then
           toggle <= '0';
        elsif ((gmii_tx_en_in = '1') and (sgmii_ddr_clk_en = '1')) then
           toggle <= not toggle;
        elsif ((mii_tx_en_reg1 = '1') and (toggle = '1') and (sgmii_ddr_clk_en = '1')) then
           toggle <= '0';
        end if;
     end if;
  end process process_toggle;

  sample_gmii_tx_gen : process (clk125m)
  begin
     if clk125m'event and clk125m = '1' then
        if reset = '1' then
           gmii_txd_gen   <= "00000000";
           gmii_tx_en_gen <= '0';
           gmii_tx_er_gen <= '0';
        elsif (speed_is_10_100 = '1') then
            if  ((sgmii_ddr_clk_en = '1') and (toggle_reg1 = '1') and (mii_tx_en_reg2 = '1')) then
               gmii_tx_en_gen <= '1';
               if (((align_done = '1') and (align_even = '0'))) then
                   gmii_txd_gen    <= (mii_txd_reg2 & mii_txd_reg3);
                   gmii_tx_er_gen  <= mii_tx_er_reg2 or mii_tx_er_reg3;
               else
                   gmii_txd_gen    <= (mii_txd_reg1 & mii_txd_reg2);
                   gmii_tx_er_gen  <= mii_tx_er_reg1 or mii_tx_er_reg2;
               end if;
            elsif ((((align_even_reg2 = '1') and (mii_tx_en_reg2 = '0')) or ((mii_tx_en_reg3 = '0') and (mii_tx_en_reg4 = '1')))
                    and (sgmii_ddr_clk_en = '1')) then
               gmii_txd_gen    <= "00000000";
               gmii_tx_er_gen  <= '0';
               gmii_tx_en_gen  <= '0';
            end if;
         else
            gmii_txd_gen    <= gmii_txd_in;
            gmii_tx_er_gen  <= gmii_tx_er_in;
            gmii_tx_en_gen  <= gmii_tx_en_in;
         end if;
    end if;
  end process sample_gmii_tx_gen;


  -- At 1Gbps speeds, sgmii_clk_en is permantly tied to logic 1
  -- and the input data will be sampled on every clock cycle.  At 10Mbs
  -- and 100Mbps speeds, sgmii_clk_en will be at logic 1 only only one clock
  -- cycle in ten, or one clock cycle in a hundred, respectively.

  -- The sampled output GMII transmitter data is sent directly into the
  -- 1G/2.5G Ethernet PCS/PMA or SGMII LogiCORE synchronously to the
  -- 125MHz reference clock.

  sample_gmii_tx: process (clk125m)
  begin
     if clk125m'event and clk125m = '1' then
        if reset = '1' then
           gmii_txd_out   <= "00000000";
           gmii_tx_en_out <= '0';
           gmii_tx_er_out <= '0';
        elsif (sgmii_clk_en = '1') then
           gmii_txd_out   <= gmii_txd_gen;
           gmii_tx_en_out <= gmii_tx_en_gen;
           gmii_tx_er_out <= gmii_tx_er_gen;
        end if;
     end if;
  end process sample_gmii_tx;

end rtl;

