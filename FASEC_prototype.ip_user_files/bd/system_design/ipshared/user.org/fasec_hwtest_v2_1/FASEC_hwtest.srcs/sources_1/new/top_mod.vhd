----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/29/2016 07:05:52 PM
-- Design Name: 
-- Module Name: top_mod - rtl
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library xil_pvtmisc;
use xil_pvtmisc.myPackage.all;

entity fasec_hwtest is
  generic(
    -- Parameters of Axi Slave Bus Interface S00_AXI
    g_S00_AXI_DATA_WIDTH : integer := 32;
    g_S00_AXI_ADDR_WIDTH : integer := 32);
  port (
    ps_clk_i         : in    std_logic;  -- clock from Zynq PS (100 MHz)
    osc100_clk_i     : in    std_logic;  -- clock from oscillator (100 MHz)
    -- FMC 1-2 user IO
    FMC2_LA_P_b      : inout std_logic_vector(33 downto 0);
    FMC2_LA_N_b      : inout std_logic_vector(33 downto 0);
    FMC1_LA_P_b      : inout std_logic_vector(33 downto 0);
    FMC1_LA_N_b      : inout std_logic_vector(33 downto 0);
    -- FMC misc IO
    FMC2_PRSNTM2C_n_i  : in    std_logic;
    FMC2_CLK0M2C_P_i   : in    std_logic;
    FMC2_CLK0M2C_N_i   : in    std_logic;
    FMC2_CLK0C2M_P_o   : out   std_logic;
    FMC2_CLK0C2M_N_o   : out   std_logic;
    FMC1_PRSNTM2C_n_i  : in    std_logic;
    FMC1_CLK0M2C_P_i   : in    std_logic;
    FMC1_CLK0M2C_N_i   : in    std_logic;
    FMC1_CLK0C2M_P_o   : out   std_logic;
    FMC1_CLK0C2M_N_o   : Out   std_logic;
    -- FASEC signals
    pb_gp_n_i        : in    std_logic;
    led_col_pl_o     : out   std_logic_vector (3 downto 0);  -- anode green / cathode red
    led_line_en_pl_o : out   std_logic;  -- output 1B Hi-Z when asserted
    led_line_pl_o    : out   std_logic;  -- output 1B: cathode green / anode red
    -- AXI4-LITE slave interface
    s00_axi_aclk     : in    std_logic;
    s00_axi_aresetn  : in    std_logic;
    s00_axi_awaddr   : in    std_logic_vector(g_S00_AXI_ADDR_WIDTH-1 downto 0);
    s00_axi_awprot   : in    std_logic_vector(2 downto 0);
    s00_axi_awvalid  : in    std_logic;
    s00_axi_awready  : out   std_logic;
    s00_axi_wdata    : in    std_logic_vector(g_S00_AXI_DATA_WIDTH-1 downto 0);
    s00_axi_wstrb    : in    std_logic_vector((g_S00_AXI_DATA_WIDTH/8)-1 downto 0);
    s00_axi_wvalid   : in    std_logic;
    s00_axi_wready   : out   std_logic;
    s00_axi_bresp    : out   std_logic_vector(1 downto 0);
    s00_axi_bvalid   : out   std_logic;
    s00_axi_bready   : in    std_logic;
    s00_axi_araddr   : in    std_logic_vector(g_S00_AXI_ADDR_WIDTH-1 downto 0);
    s00_axi_arprot   : in    std_logic_vector(2 downto 0);
    s00_axi_arvalid  : in    std_logic;
    s00_axi_arready  : out   std_logic;
    s00_axi_rdata    : out   std_logic_vector(g_S00_AXI_DATA_WIDTH-1 downto 0);
    s00_axi_rresp    : out   std_logic_vector(1 downto 0);
    s00_axi_rvalid   : out   std_logic;
    s00_axi_rready   : in    std_logic);
end fasec_hwtest;

architecture rtl of fasec_hwtest is
  constant c_FLASH          : positive                                         := 40000000;  -- 400 ms @ 100 MHz
  constant c_SLAVE_MAXREAD  : positive                                         := 8;
  constant c_SLAVE_MAXWRITE : positive                                         := 8;
  constant c_SLAVE_MAXMEM   : positive                                         := c_SLAVE_MAXREAD + c_SLAVE_MAXWRITE;
  -- AXI slave signals
  signal s_sAxi_dataR       : t_axiMemory(0 to c_SLAVE_MAXREAD-1)              := (others => (others => '0'));
  signal s_sAxi_dataW       : t_axiMemory(c_SLAVE_MAXREAD to c_SLAVE_MAXMEM-1) := (others => (others => '0'));  -- also put to zero in the slave AXI module (cuz buffer)
  signal s_sAxi_dataResetW  : t_axiMemory(c_SLAVE_MAXREAD to c_SLAVE_MAXMEM-1) := (others => (others => '0'));
  -- FMC1-2 signals
  signal s_tick             : std_logic;
begin
  --=============================================================================
  -- FMC1 user lines - clock in for AXI register read by Zynq PS
  --=============================================================================  
  p_reg_fmc1 : process(s00_axi_aclk)
    variable v_fmc_reg0, v_fmc_reg1, v_fmc_reg2 : std_logic_vector(g_S00_AXI_DATA_WIDTH-1 downto 0);
  begin
    if rising_edge(s00_axi_aclk) then
      -- for testing purposes, read-in FMC1 inputs
      -- 68 lines, hence doesn't fit into 2x32-bit AXI registers
      s_sAxi_dataR(0) <= unsigned(v_fmc_reg0(g_S00_AXI_DATA_WIDTH-1 downto 0));
      s_sAxi_dataR(1) <= unsigned(v_fmc_reg1(g_S00_AXI_DATA_WIDTH-1 downto 0));
      s_sAxi_dataR(2) <= unsigned(v_fmc_reg2(g_S00_AXI_DATA_WIDTH-1 downto 0));
      -- single user lines, auto-gen from .ods file
      -- ** word 1
      v_fmc_reg0(0)   := FMC1_LA_N_b(17);
      v_fmc_reg0(1)   := FMC1_LA_N_b(19);
      v_fmc_reg0(2)   := FMC1_LA_P_b(19);
      v_fmc_reg0(3)   := FMC1_LA_P_b(20);
      v_fmc_reg0(4)   := FMC1_LA_N_b(20);
      v_fmc_reg0(5)   := FMC1_LA_N_b(14);
      v_fmc_reg0(6)   := FMC1_LA_P_b(14);
      v_fmc_reg0(7)   := FMC1_LA_P_b(17);
      v_fmc_reg0(8)   := FMC1_LA_N_b(13);
      v_fmc_reg0(9)   := FMC1_LA_P_b(13);
      v_fmc_reg0(10)  := FMC1_LA_P_b(15);
      v_fmc_reg0(11)  := FMC1_LA_N_b(15);
      v_fmc_reg0(12)  := FMC1_LA_P_b(16);
      v_fmc_reg0(13)  := FMC1_LA_N_b(32);
      v_fmc_reg0(14)  := FMC1_LA_P_b(33);
      v_fmc_reg0(15)  := FMC1_LA_N_b(33);
      v_fmc_reg0(16)  := FMC1_LA_P_b(7);
      v_fmc_reg0(17)  := FMC1_LA_P_b(5);
      v_fmc_reg0(18)  := FMC1_LA_N_b(7);
      v_fmc_reg0(19)  := FMC1_LA_N_b(8);
      v_fmc_reg0(20)  := FMC1_LA_P_b(8);
      v_fmc_reg0(21)  := FMC1_LA_N_b(6);
      v_fmc_reg0(22)  := FMC1_LA_P_b(12);
      v_fmc_reg0(23)  := FMC1_LA_N_b(9);
      v_fmc_reg0(24)  := FMC1_LA_N_b(16);
      v_fmc_reg0(25)  := FMC1_LA_N_b(12);
      v_fmc_reg0(26)  := FMC1_LA_P_b(11);
      v_fmc_reg0(27)  := FMC1_LA_N_b(10);
      v_fmc_reg0(28)  := FMC1_LA_N_b(11);
      v_fmc_reg0(29)  := FMC1_LA_P_b(10);
      v_fmc_reg0(30)  := FMC1_LA_P_b(9);
      v_fmc_reg0(31)  := FMC1_LA_N_b(5);
      -- ** word 2
      v_fmc_reg1(0)   := FMC1_LA_P_b(27);
      v_fmc_reg1(1)   := FMC1_LA_N_b(23);
      v_fmc_reg1(2)   := FMC1_LA_P_b(22);
      v_fmc_reg1(3)   := FMC1_LA_N_b(22);
      v_fmc_reg1(4)   := FMC1_LA_N_b(18);
      v_fmc_reg1(5)   := FMC1_LA_P_b(18);
      v_fmc_reg1(6)   := FMC1_LA_P_b(23);
      v_fmc_reg1(7)   := FMC1_LA_P_b(21);
      v_fmc_reg1(8)   := FMC1_LA_P_b(24);
      v_fmc_reg1(9)   := FMC1_LA_N_b(25);
      -- v_fmc_reg1(10)  := TCK (High-Z)
      v_fmc_reg1(11)  := FMC1_LA_P_b(25);
      v_fmc_reg1(12)  := FMC1_LA_N_b(27);
      v_fmc_reg1(13)  := FMC1_LA_P_b(26);
      v_fmc_reg1(14)  := FMC1_LA_N_b(21);
      v_fmc_reg1(15)  := FMC1_LA_N_b(26);
      v_fmc_reg1(16)  := FMC1_LA_P_b(32);
      v_fmc_reg1(17)  := FMC1_LA_N_b(30);
      -- v_fmc_reg1(19) : GA1 (set at High-Z!)
      v_fmc_reg1(19)  := FMC1_LA_N_b(31);
      v_fmc_reg1(20)  := FMC1_LA_P_b(30);
      -- v_fmc_reg1(21) : GA0 (set at High-Z!)
      -- v_fmc_reg1(22)  := TRST (pull-up)
      -- v_fmc_reg1(23)  := TMS (High-Z)
      v_fmc_reg1(24)  := FMC1_LA_P_b(29);
      v_fmc_reg1(25)  := FMC1_LA_N_b(29);
      -- v_fmc_reg1(26)  := TDO (X when PRSTNn='1')
      v_fmc_reg1(27)  := FMC1_LA_P_b(31);
      v_fmc_reg1(28)  := FMC1_LA_N_b(28);
      v_fmc_reg1(29)  := FMC1_LA_P_b(28);
      -- v_fmc_reg1(30)  := TDI (X when PRSTNn='1')
      v_fmc_reg1(31)  := FMC1_LA_N_b(24);
      -- ** word 3 (if not stated -> don't care X)
      v_fmc_reg2(0) := FMC1_CLK0M2C_N_i;
      v_fmc_reg2(1) := FMC1_CLK0M2C_P_i;
      v_fmc_reg2(2) := FMC1_PRSNTM2C_n_i;       -- force at high/high-Z for JTAG!
      -- v_fmc_reg2(17) : PG_C2M (set at High-Z!)
      v_fmc_reg2(18) := FMC1_LA_P_b(1);
      v_fmc_reg2(19) := FMC1_LA_P_b(6);
      v_fmc_reg2(20) := FMC1_LA_N_b(1);
      v_fmc_reg2(21) := FMC1_LA_N_b(3);
      v_fmc_reg2(22) := FMC1_LA_P_b(4);
      v_fmc_reg2(23) := FMC1_LA_P_b(3);
      -- v_fmc_reg2(24) : VREF_M2C (set at 1!)
      v_fmc_reg2(27) := FMC1_LA_P_b(0);
      v_fmc_reg2(29) := FMC1_LA_N_b(0);
      v_fmc_reg2(31) := FMC1_LA_N_b(4);
    end if;
  end process p_reg_fmc1;

  --=============================================================================
  -- FMC2 user lines - clock in for AXI register read by Zynq PS
  --=============================================================================  
  p_reg_fmc2 : process(s00_axi_aclk)
    variable v_fmc_reg0, v_fmc_reg1, v_fmc_reg2 : std_logic_vector(g_S00_AXI_DATA_WIDTH-1 downto 0);
  begin
    if rising_edge(s00_axi_aclk) then
      -- for testing purposes, read-in FMC1 inputs
      -- 68 lines, hence doesn't fit into 2x32-bit AXI registers
      s_sAxi_dataR(4) <= unsigned(v_fmc_reg0(g_S00_AXI_DATA_WIDTH-1 downto 0));
      s_sAxi_dataR(5) <= unsigned(v_fmc_reg1(g_S00_AXI_DATA_WIDTH-1 downto 0));
      s_sAxi_dataR(6) <= unsigned(v_fmc_reg2(g_S00_AXI_DATA_WIDTH-1 downto 0));
      -- single user lines, auto-gen from .ods file
      -- ** word 1
      v_fmc_reg0(0)   := FMC2_LA_N_b(17);
      v_fmc_reg0(1)   := FMC2_LA_N_b(19);
      v_fmc_reg0(2)   := FMC2_LA_P_b(19);
      v_fmc_reg0(3)   := FMC2_LA_P_b(20);
      v_fmc_reg0(4)   := FMC2_LA_N_b(20);
      v_fmc_reg0(5)   := FMC2_LA_N_b(14);
      v_fmc_reg0(6)   := FMC2_LA_P_b(14);
      v_fmc_reg0(7)   := FMC2_LA_P_b(17);
      v_fmc_reg0(8)   := FMC2_LA_N_b(13);
      v_fmc_reg0(9)   := FMC2_LA_P_b(13);
      v_fmc_reg0(10)  := FMC2_LA_P_b(15);
      v_fmc_reg0(11)  := FMC2_LA_N_b(15);
      v_fmc_reg0(12)  := FMC2_LA_P_b(16);
      v_fmc_reg0(13)  := FMC2_LA_N_b(32);
      v_fmc_reg0(14)  := FMC2_LA_P_b(33);
      v_fmc_reg0(15)  := FMC2_LA_N_b(33);
      v_fmc_reg0(16)  := FMC2_LA_P_b(7);
      v_fmc_reg0(17)  := FMC2_LA_P_b(5);
      v_fmc_reg0(18)  := FMC2_LA_N_b(7);
      v_fmc_reg0(19)  := FMC2_LA_N_b(8);
      v_fmc_reg0(20)  := FMC2_LA_P_b(8);
      v_fmc_reg0(21)  := FMC2_LA_N_b(6);
      v_fmc_reg0(22)  := FMC2_LA_P_b(12);
      v_fmc_reg0(23)  := FMC2_LA_N_b(9);
      v_fmc_reg0(24)  := FMC2_LA_N_b(16);
      v_fmc_reg0(25)  := FMC2_LA_N_b(12);
      v_fmc_reg0(26)  := FMC2_LA_P_b(11);
      v_fmc_reg0(27)  := FMC2_LA_N_b(10);
      v_fmc_reg0(28)  := FMC2_LA_N_b(11);
      v_fmc_reg0(29)  := FMC2_LA_P_b(10);
      v_fmc_reg0(30)  := FMC2_LA_P_b(9);
      v_fmc_reg0(31)  := FMC2_LA_N_b(5);
      -- ** word 2
      v_fmc_reg1(0)   := FMC2_LA_P_b(27);
      v_fmc_reg1(1)   := FMC2_LA_N_b(23);
      v_fmc_reg1(2)   := FMC2_LA_P_b(22);
      v_fmc_reg1(3)   := FMC2_LA_N_b(22);
      v_fmc_reg1(4)   := FMC2_LA_N_b(18);
      v_fmc_reg1(5)   := FMC2_LA_P_b(18);
      v_fmc_reg1(6)   := FMC2_LA_P_b(23);
      v_fmc_reg1(7)   := FMC2_LA_P_b(21);
      v_fmc_reg1(8)   := FMC2_LA_P_b(24);
      v_fmc_reg1(9)   := FMC2_LA_N_b(25);
      -- v_fmc_reg1(10)  := TCK (High-Z)
      v_fmc_reg1(11)  := FMC2_LA_P_b(25);
      v_fmc_reg1(12)  := FMC2_LA_N_b(27);
      v_fmc_reg1(13)  := FMC2_LA_P_b(26);
      v_fmc_reg1(14)  := FMC2_LA_N_b(21);
      v_fmc_reg1(15)  := FMC2_LA_N_b(26);
      v_fmc_reg1(16)  := FMC2_LA_P_b(32);
      v_fmc_reg1(17)  := FMC2_LA_N_b(30);
      -- v_fmc_reg1(19) : GA1 (set at High-Z!)
      v_fmc_reg1(19)  := FMC2_LA_N_b(31);
      v_fmc_reg1(20)  := FMC2_LA_P_b(30);
      -- v_fmc_reg1(21) : GA0 (set at High-Z!)
      -- v_fmc_reg1(22)  := TRST (pull-up)
      -- v_fmc_reg1(23)  := TMS (High-Z)
      v_fmc_reg1(24)  := FMC2_LA_P_b(29);
      v_fmc_reg1(25)  := FMC2_LA_N_b(29);
      -- v_fmc_reg1(26)  := TDO (X when PRSTNn='1')
      v_fmc_reg1(27)  := FMC2_LA_P_b(31);
      v_fmc_reg1(28)  := FMC2_LA_N_b(28);
      v_fmc_reg1(29)  := FMC2_LA_P_b(28);
      -- v_fmc_reg1(30)  := TDI (X when PRSTNn='1')
      v_fmc_reg1(31)  := FMC2_LA_N_b(24);
      -- ** word 3 (if not stated -> don't care X)
      v_fmc_reg2(0) := FMC1_CLK0M2C_N_i;
      v_fmc_reg2(1) := FMC1_CLK0M2C_P_i;
      v_fmc_reg2(2) := FMC1_PRSNTM2C_n_i;       -- force at high/high-Z for JTAG!
      -- v_fmc_reg2(17) : PG_C2M (set at High-Z!)
      v_fmc_reg2(18) := FMC2_LA_P_b(1);
      v_fmc_reg2(19) := FMC2_LA_P_b(6);
      v_fmc_reg2(20) := FMC2_LA_N_b(1);
      v_fmc_reg2(21) := FMC2_LA_N_b(3);
      v_fmc_reg2(22) := FMC2_LA_P_b(4);
      v_fmc_reg2(23) := FMC2_LA_P_b(3);
      -- v_fmc_reg2(24) : VREF_M2C (set at 1!)
      v_fmc_reg2(27) := FMC2_LA_P_b(0);
      v_fmc_reg2(29) := FMC2_LA_N_b(0);
      v_fmc_reg2(31) := FMC2_LA_N_b(4);
    end if;
  end process p_reg_fmc2;

  --=============================================================================
  -- tick generation, depending on constant c_FLASH
  --=============================================================================
  p_tick : process(ps_clk_i)
    variable v_cntr : unsigned(31 downto 0) := (others => '0');
  begin
    if rising_edge(ps_clk_i) then
      if (to_integer(v_cntr) < c_FLASH) then
        v_cntr := v_cntr + 1;
      else
        v_cntr := to_unsigned(0, v_cntr'length);
        s_tick <= not s_tick;
      end if;
    end if;
  end process p_tick;

  --=============================================================================
  -- FASEC LEDs output
  --=============================================================================
  p_leds : process(ps_clk_i)
    variable v_pbreg : std_logic_vector(2 downto 0) := (others => '0');
    variable v_shift : std_logic_vector(7 downto 0) := "00000001";
  begin
    if rising_edge(ps_clk_i) then
      -- clock in pushbutton input
      v_pbreg(2 downto 0) := v_pbreg(1 downto 0) & pb_gp_n_i;
      -- shift-register
      if s_tick = '1' then
        v_shift(7 downto 0) := v_shift(6 downto 0) & v_shift(7);
      end if;
      -- LEDs output selection
      if v_pbreg(2) = '1' then
        -- button not pressed, light one by one (4x green, 4x red)
        if unsigned(v_shift(3 downto 0)) /= 0 then
          led_line_en_pl_o         <= '0';
          led_line_pl_o            <= '0';
          led_col_pl_o(3 downto 0) <= v_shift(3 downto 0);
        elsif unsigned(v_shift(7 downto 4)) /= 0 then
          led_line_en_pl_o         <= '1';
          led_line_pl_o            <= '0';
          led_col_pl_o(3 downto 0) <= not(v_shift(7 downto 4));
        end if;
      else
        -- button pressed, all LEDs red
        led_line_en_pl_o         <= '1';
        led_line_pl_o            <= '1';
        led_col_pl_o(3 downto 0) <= "0000";
      end if;
    end if;
  end process;

  --=============================================================================
  -- AXI4-Lite slave for control from PS
  --=============================================================================
  axi4lite_slave : entity xil_pvtmisc.axi4lite_slave
    generic map (
      C_S_AXI_DATA_WIDTH => g_S00_AXI_DATA_WIDTH,
      C_S_AXI_ADDR_WIDTH => g_S00_AXI_ADDR_WIDTH,
      g_MAXREAD          => c_SLAVE_MAXREAD,
      g_MAXWRITE         => c_SLAVE_MAXWRITE)
    port map (
      s_axi_dataR      => s_sAxi_dataR,
      s_axi_dataW      => s_sAxi_dataW,
      s_axi_dataResetW => s_sAxi_dataResetW,
      S_AXI_ACLK       => s00_axi_aclk,
      S_AXI_ARESETN    => s00_axi_aresetn,
      S_AXI_AWADDR     => s00_axi_awaddr,
      S_AXI_AWPROT     => s00_axi_awprot,
      S_AXI_AWVALID    => s00_axi_awvalid,
      S_AXI_AWREADY    => s00_axi_awready,
      S_AXI_WDATA      => s00_axi_wdata,
      S_AXI_WSTRB      => s00_axi_wstrb,
      S_AXI_WVALID     => s00_axi_wvalid,
      S_AXI_WREADY     => s00_axi_wready,
      S_AXI_BRESP      => s00_axi_bresp,
      S_AXI_BVALID     => s00_axi_bvalid,
      S_AXI_BREADY     => s00_axi_bready,
      S_AXI_ARADDR     => s00_axi_araddr,
      S_AXI_ARPROT     => s00_axi_arprot,
      S_AXI_ARVALID    => s00_axi_arvalid,
      S_AXI_ARREADY    => s00_axi_arready,
      S_AXI_RDATA      => s00_axi_rdata,
      S_AXI_RRESP      => s00_axi_rresp,
      S_AXI_RVALID     => s00_axi_rvalid,
      S_AXI_RREADY     => s00_axi_rready);
end rtl;
