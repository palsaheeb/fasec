--------------------------------------------------------------------------------
-- File       : system_design_gig_ethernet_pcs_pma_0_0_rx_rate_adapt.vhd
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
-- Description: This module accepts receiver data from the Ethernet
--              1000BASE-X PCS/PMA or SGMII LogiCORE. At 1 Gbps, this
--              data will be valid on evey clock cycle of the 125MHz
--              reference clock; at 100Mbps, LSB 4 bits are repeated 
--              for five clock periods and then MSB 4 bits will be 
--              for next five clock periods; at 10Mbps, LSB 4 bits will
--              be repeated for a fifty clock period duration and then
--              MSB 4 bits will be repeated for fifty clock period 
--              duration of the 125MHz reference clock.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--------------------------------------------------------------------------------
-- The entity declaration
--------------------------------------------------------------------------------

entity system_design_gig_ethernet_pcs_pma_0_0_rx_rate_adapt is
  port (
    reset                : in  std_logic;                     -- Synchronous reset.
    clk125m              : in  std_logic;                     -- Reference 125MHz receiver clock.
    sgmii_ddr_clk_en     : in  std_logic;                     -- Double Clock rate enable pulse for the transmitter logic
    speed_is_10_100      : in  std_logic;                     -- Select GMII or MII
    sgmii_clk_en         : in  std_logic;                     -- Clock enable for the receiver logic (125MHz, 25MHz, 2.5MHz).
    gmii_rxd_in          : in  std_logic_vector(7 downto 0);  -- Receive data from client MAC.
    gmii_rx_dv_in        : in  std_logic;                     -- Receive data valid signal from client MAC.
    gmii_rx_er_in        : in  std_logic;                     -- Receive error signal from client MAC.
    gmii_rxd_out         : out std_logic_vector(7 downto 0) := (others => '0');  -- Receive data from client MAC.
    gmii_rx_dv_out       : out std_logic := '0';                     -- Receive data valid signal from client MAC.
    gmii_rx_er_out       : out std_logic := '0'                      -- Receive error signal from client MAC.
  );
end system_design_gig_ethernet_pcs_pma_0_0_rx_rate_adapt;


architecture rtl of system_design_gig_ethernet_pcs_pma_0_0_rx_rate_adapt is

   signal gmii_rxd_sel    : std_logic_vector(7 downto 0);
   signal gmii_rx_dv_sel  : std_logic;
   signal gmii_rx_er_sel  : std_logic;
   signal toggle          : std_logic;

begin

   gmii_sel: process (clk125m)
   begin
     if clk125m'event and clk125m = '1' then
       if reset = '1' then
          gmii_rxd_sel     <= (others => '0');
          gmii_rx_dv_sel   <= '0';
          gmii_rx_er_sel   <= '0';
       elsif (sgmii_clk_en = '1') then
          gmii_rxd_sel     <= gmii_rxd_in;
          gmii_rx_dv_sel   <= gmii_rx_dv_in;
          gmii_rx_er_sel   <= gmii_rx_er_in;
       end if;
     end if;
   end process gmii_sel;
    

 -- Sample the correctly aligned data

  sample_gmii_rx: process (clk125m)
  begin
     if clk125m'event and clk125m = '1' then
        if reset = '1' then
           gmii_rxd_out   <= (others => '0');
           gmii_rx_dv_out <= '0';
           gmii_rx_er_out <= '0';
        else
           if (speed_is_10_100 = '1')  then
              if (sgmii_ddr_clk_en = '1') then
                 gmii_rx_dv_out <= gmii_rx_dv_sel;
                 gmii_rx_er_out <= gmii_rx_er_sel;
                 if (toggle = '1') then
                    gmii_rxd_out   <= "0000" & gmii_rxd_sel(3 downto 0);
                 else
                    gmii_rxd_out   <= "0000" & gmii_rxd_sel(7 downto 4);
                 end if;
              end if;
           else
              if (sgmii_clk_en = '1') then
                 gmii_rxd_out   <= gmii_rxd_sel;
                 gmii_rx_dv_out <= gmii_rx_dv_sel;
                 gmii_rx_er_out <= gmii_rx_er_sel;
              end if;
           end if;
       
           if (sgmii_clk_en = '1') then
              toggle <= '1';
           elsif (sgmii_ddr_clk_en = '1') then
              toggle <= '0';
           end if;
        end if;
     end if;
  end process sample_gmii_rx;


end rtl;
