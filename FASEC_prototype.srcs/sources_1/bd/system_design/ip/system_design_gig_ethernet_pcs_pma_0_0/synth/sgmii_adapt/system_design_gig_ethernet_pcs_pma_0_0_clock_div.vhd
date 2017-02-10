--------------------------------------------------------------------------------
-- File       : system_design_gig_ethernet_pcs_pma_0_0_clock_div.vhd
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
--  Description:  This logic describes a standard clock divider to
--                create divided down clocks.  
--                Three clocks are created: 
--                      a> Divide by 5
--                      b> Divide by 10
--                      c> Divide by 50
--
--                The capabilities of this clock divideris extended
--                with the use of the clock enables - it is only the
--                clock-enabled cycles which are divided down.
--
--                The three divided clockw are output directly from a rising
--                edge triggered flip-flop (clocked on the input clk).

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


--------------------------------------------------------------------------------
-- Entity declaration.
-------------------------------------------------------------------------------

entity system_design_gig_ethernet_pcs_pma_0_0_clock_div is
  port (
    reset               : in  std_logic;      -- Synchronous Reset
    clk                 : in  std_logic;      -- Input clock (always at 125MHz)
    clk_div5_neg        : out std_logic;      -- Clock divide by 5
    clk_div5_pos        : out std_logic;      -- Clock divide by 5
    clk_div5_plse_rise  : out std_logic;
    clk_div5_plse_fall  : out std_logic;
    clk_div10           : out std_logic;      -- Clock divide by 10
    clk_div10_plse_rise : out std_logic;
    clk_div10_plse_fall : out std_logic
  );
end system_design_gig_ethernet_pcs_pma_0_0_clock_div;

architecture top_level of system_design_gig_ethernet_pcs_pma_0_0_clock_div is

  signal clk_counter_pos_stg1     : unsigned(2 downto 0);
  signal clk_counter_neg_stg1     : unsigned(2 downto 0);
  signal reset_neg                : std_logic;
  signal clk_div5_reg1            : std_logic;
  signal clk_div5_plse_rise_sig   : std_logic;
  signal clk_div5_plse_fall_sig   : std_logic;
  signal clk_div10_reg1           : std_logic;
  signal clk_div5_pos_int         : std_logic;
  signal clk_div10_int            : std_logic;

begin

  gen_clk_cntr_pos: process (clk)
  begin
     if clk'event and clk= '1' then     -- rising clock edge
        if reset = '1' then
           clk_counter_pos_stg1 <= "000";
        else
           if (clk_counter_pos_stg1 = "100") then
              clk_counter_pos_stg1 <= "000";
           else
              clk_counter_pos_stg1 <= clk_counter_pos_stg1 + "001";
           end if;
        end if;
     end if;
  end process gen_clk_cntr_pos;

  gen_clk_cntr_neg: process (clk)
  begin
     if clk'event and clk= '0' then     -- falling clock edge
        clk_counter_neg_stg1 <= clk_counter_pos_stg1;
        reset_neg            <= reset;
     end if;
  end process gen_clk_cntr_neg;
   
  gen_clk_div5_pos: process (clk)
  begin
     if clk'event and clk= '1' then     -- rising clock edge
        if reset = '1' then
           clk_div5_pos_int <= '0';
        else
           if (clk_counter_neg_stg1 = "001") then
               clk_div5_pos_int <= '1';
           elsif (clk_counter_neg_stg1 = "100") then
               clk_div5_pos_int <= '0';
           end if;
        end if;
     end if;  
  end process gen_clk_div5_pos;

  clk_div5_pos <= clk_div5_pos_int;

  gen_clk_div5_neg: process (clk)
  begin
     if clk'event and clk= '0' then     -- falling clock edge
        if (reset_neg = '1') then
           clk_div5_neg <= '0';
        else
           if (clk_counter_pos_stg1 = "010") then
              clk_div5_neg <= '1';
           elsif (clk_counter_pos_stg1 = "100") then
               clk_div5_neg <= '0';
           end if;
        end if;
     end if;
  end process gen_clk_div5_neg;
   
  process (clk)
  begin
    if clk'event and clk= '1' then     -- rising clock edge
       if reset = '1' then   
          clk_div5_reg1          <= '0';
          clk_div5_plse_rise_sig <= '0';
          clk_div5_plse_fall_sig <= '0';
          clk_div5_plse_rise     <= '0';
          clk_div5_plse_fall     <= '0';
          clk_div10_int          <= '0';
          clk_div10_reg1         <= '0';
          clk_div10_plse_rise    <= '0';
          clk_div10_plse_fall    <= '0';
       else
          clk_div5_reg1          <= clk_div5_pos_int;
          clk_div10_reg1         <= clk_div10_int;
          clk_div5_plse_rise_sig <= clk_div5_pos_int and not clk_div5_reg1;
          clk_div5_plse_fall_sig <= not clk_div5_pos_int and clk_div5_reg1;
          clk_div5_plse_rise     <= clk_div5_plse_rise_sig;
          clk_div5_plse_fall     <= clk_div5_plse_fall_sig;
          clk_div10_plse_rise    <= clk_div10_int and not clk_div10_reg1;
          clk_div10_plse_fall    <= not clk_div10_int and clk_div10_reg1;
          if (clk_div5_pos_int = '1' and clk_div5_reg1 = '0') then
              clk_div10_int     <= not clk_div10_int;
          end if;
       end if;
    end if;
  end process;

clk_div10 <= clk_div10_int;
          
end top_level;

