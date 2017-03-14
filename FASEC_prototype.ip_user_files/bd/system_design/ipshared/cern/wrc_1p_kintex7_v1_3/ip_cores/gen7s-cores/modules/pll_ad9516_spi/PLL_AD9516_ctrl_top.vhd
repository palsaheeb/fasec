----------------------------------------------------------------------------------
-- Company:        Seven Solutions
-- Engineer:       Miguel Mendez (mmendez@sevensols.com)
-- 
-- Create Date:    11:41:05 07/11/2013 
-- Design Name:    
-- Module Name:    PLL_CPIC_ctrl_top - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library work;
use work.PLL_SPI_ctrl_pkg.all;

entity PLL_AD9516_ctrl_top is

    generic (
      g_data_master1   : t_data_array_data   := (others=>(others=>'0'));
      g_addr_master1   : t_data_array        := (others=>0)
    );
    port ( clk_i        : in  std_logic;
           --clk_p_i    : in  std_logic;
           --clk_n_i    : in  std_logic;
           rst_n_i      : in  std_logic;

           --- Debug signals
           FP_LEDN0     : out std_logic;
           FP_LEDN1     : out std_logic;
           --SI57X_CLK_N : in  std_logic;
           --SI57X_CLK_P : in  std_logic;

           --- PLL status/control
           PLL_LOCK_i   : in std_logic;
           PLL_RESET    : out std_logic;
           PLL_STAT_i   : in std_logic;
           PLL_REFSEL_o : out std_logic;
           PLL_SYNC_n_o : out std_logic;

           -- SPI bus - PLL control
           PLL_CS_n_o  : out std_logic;
           PLL_SCLK_o  : out std_logic;
           PLL_SDI_o   : out std_logic;
           PLL_SDO_i   : in std_logic;
 
           -- SPI controller status
           core_enable_i    : in std_logic;
           core_done_o      : out std_logic;
           core_error_o     : out std_logic
         );
end PLL_AD9516_ctrl_top;

architecture Behavioral of PLL_AD9516_ctrl_top is

  -----------------------------------------------------------------------------
  -- Component declaration
  -----------------------------------------------------------------------------
  component spi_top is
  Port(
  -- Wishbone signals
    wb_clk_i : in std_logic;         -- master clock input
    wb_rst_i : in std_logic;         -- synchronous active high reset
    wb_adr_i : in std_logic_vector(4 downto 0) ;        -- lower address bits
    wb_dat_i : in std_logic_vector(32-1 downto 0) ;     -- databus input
    wb_dat_o : out std_logic_vector(32-1 downto 0) ;    -- databus output
    wb_sel_i : in  std_logic_vector(3 downto 0) ;       -- byte select inputs
    wb_we_i : in   std_logic;          -- write enable input
    wb_stb_i : in  std_logic;         -- stobe/core select signal
    wb_cyc_i : in  std_logic;         -- valid bus cycle input
    wb_ack_o : out std_logic;         -- bus cycle acknowledge output
    wb_err_o : out  std_logic;         -- termination w/ error
    wb_int_o : out  std_logic;         -- interrupt request signal output
    
    -- SPI signals                                     
    -- ss_pad_o : out   std_logic_vector(`SPI_SS_NB-1:0) ;    -- slave select
    ss_pad_o : out   std_logic_vector(8-1 downto 0) ;         -- slave select
    sclk_pad_o : out std_logic;       -- serial clock
    mosi_pad_o : out std_logic;       -- master out slave in
    miso_pad_i : in  std_logic       -- master in slave out
  );
  end component;

  ------------------------------------------------------------------------------
  -- Types declaration
  ------------------------------------------------------------------------------
  -- fsm master
  type t_master is (IDLE, SPIdata_sent, read_SPI_reg, SPI_reg_conf, CTRL_set, SPI_div_clk, st_wait);
  
  -----------------------------------------------------------------------------
  -- Signals declaration
  -----------------------------------------------------------------------------  
  --Wishbone clk
  signal  s_wb_clk_tb             :  std_logic;          

  -- Reset
  signal  s_reset_n_top           :  std_logic;
  signal  s_locked_clk            :  std_logic;
  -- Restart test
  signal  s_restart             : std_logic;

  -- Wishbone slave port
  signal  s_wb_slv_sel       : std_logic_vector(c_MASK_SIZE - 1 downto 0) := (others => '0');
  signal  s_wb_slv_cyc       : std_logic:= '0';
  signal  s_wb_slv_stb       : std_logic:= '0';
  signal  s_wb_slv_we        : std_logic:= '0';
  signal  s_wb_slv_addr      : std_logic_vector(c_ADDR_PORT_SIZE - 1 downto 0):= (others => '0');
  signal  s_wb_slv_data_wr   : std_logic_vector(c_DATA_PORT_SIZE - 1 downto 0):= (others => '0');
  signal  s_wb_slv_data_rd   : std_logic_vector(c_DATA_PORT_SIZE - 1 downto 0):= (others => '0');
  signal  s_wb_slv_ack       : std_logic:= '0';

  signal s_wb_rst :  std_logic;          -- synchronous active high reset
  signal s_wb_err :  std_logic;         -- termination w/ error
  signal s_wb_int :  std_logic;         -- interrupt request signal output


  --- SPI signals                                     
  --ss_pad_o : out   std_logic_vector(`SPI_SS_NB-1:0) ;         -- slave select
  signal s_ss_pad : std_logic_vector(8-1 downto 0) ;         -- slave select
  signal s_sclk_pad : std_logic;        -- serial clock
  signal s_mosi_pad : std_logic;        -- master out slave in
  signal s_miso_pad : std_logic;        -- master in slave out
  -- SPI State Machine signals
  signal s_test_ok          : std_logic;
  signal s_cal_done_reg     : std_logic;
  signal s_addr_pos         : integer; 
  signal s_time_out         : std_logic;
  signal s_active_sm        : std_logic := '0'; 
  
  -- arrays data for slaves and masters

  signal fsm_master         : t_master := IDLE;
  signal next_state         : t_master := IDLE;


--WR-LEN (eml): Configurated according to v6.stp file. OUT 0, 5, 6, 7  & 8= 125 MHz. SYNC resets OUT8, OUT5 & OUT0.
-- PD to outputs 1 2 3 4 & 9. Counter 3 ignores SYNC. VCO divisor = 6

   signal s_data_master1_wr    : t_data_array_data := g_data_master1;
							 
  -- This array contains the address that the master1 writes on the slave
  signal s_addr_master1_wr   :  t_data_array := g_addr_master1;

  signal s_data_master1_rd    : t_data_array_data := g_data_master1;

  signal s_read_write    : std_logic := '0'; 
  signal s_ack_count     : integer range 0 to (c_NUM_SPI_REGISTERS+1) := 0; 
  signal s_data_count    : integer range 0 to (c_NUM_SPI_REGISTERS+1) := 0; 

  -- Debug signals
  signal s_cs_n_db : std_logic := '0';
  signal s_sclk_db : std_logic := '0';
  signal s_sdi_db : std_logic := '0';
  signal s_sdo_db : std_logic := '0';
  signal estado_db : std_logic_vector(3 DOWNTO 0) := x"0";
  signal s_read_reg_SPI : std_logic_vector(15 downto 0) := (others => '0');

--==============================================================================
-- Architecure begin
--==============================================================================
begin

   -- Data from register 0x232 bit 0 is modified because it is the one which safes the data in the PLL from the registers. 
   --Before x"01" and it is selfmodify to 0 when it is done.
   s_data_master1_rd(c_NUM_SPI_REGISTERS-1) <= x"00";

  --===============================================
  -- Component Instantiations 
  --===============================================
  SPI_mod : spi_top 
  Port map(
  -- Wishbone signals
    wb_clk_i => clk_i,          -- master clock input
    wb_rst_i  => s_wb_rst,         -- synchronous active high reset
    wb_adr_i  => s_wb_slv_addr,         -- lower address bits
    wb_dat_i  => s_wb_slv_data_wr,       -- databus input
    wb_dat_o  => s_wb_slv_data_rd,       -- databus output
    wb_sel_i  => s_wb_slv_sel,         -- byte select inputs
    wb_we_i  => s_wb_slv_we,           -- write enable input
    wb_stb_i  => s_wb_slv_stb,         -- stobe/core select signal
    wb_cyc_i  => s_wb_slv_cyc,         -- valid bus cycle input
    wb_ack_o  => s_wb_slv_ack,         -- bus cycle acknowledge output
    wb_err_o  => s_wb_err,         -- termination w/ error
    wb_int_o  => s_wb_int,         -- interrupt request signal output

    -- SPI signals                                     
    --ss_pad_o : out   std_logic_vector(`SPI_SS_NB-1:0) ;         -- slave select
    ss_pad_o  =>  s_ss_pad,           -- slave select
    sclk_pad_o  => s_sclk_pad,        -- serial clock
    mosi_pad_o  => s_mosi_pad,        -- master out slave in
    miso_pad_i  => s_miso_pad         -- master in slave out
  );

  ----------------------------------------------------------------------------
  -- Wishbone bus - Port 1
  ----------------------------------------------------------------------------
  s_wb_rst           <= (not s_reset_n_top);-- cambiado por ser negado;

  -- SPI signals
  PLL_CS_n_o   <= s_ss_pad(0);
  PLL_SCLK_o   <= s_sclk_pad;
  PLL_SDI_o    <= s_mosi_pad;
  s_miso_pad   <= PLL_SDO_i;


  --- PLL and components signals
  --PLL_STAT_i : in std_logic; -- status
  --PLL_LOCK_i : in std_logic; -- status
  PLL_REFSEL_o   <= '0'; -- ref1 (signal low) , ref2 (signal high)
  PLL_SYNC_n_o   <= '1';
  PLL_RESET      <= '1';
  s_locked_clk   <= '1';
  s_reset_n_top  <= rst_n_i;

  
    -----------------------------------------------------------------------
    -- Master 
    -----------------------------------------------------------------------

    p_master1: process(clk_i) is
      constant c_2sec          : integer := 200000000;
      variable v_wait_int      : integer := 0;
  begin
     if ( clk_i'event and clk_i = '1' ) then

       if (s_reset_n_top = '0')then
         s_wb_slv_sel       <= "0000";
         s_wb_slv_cyc       <= '0';
         s_wb_slv_stb       <= '0';
         s_wb_slv_we        <= '0';  
         s_wb_slv_addr      <= (others=>'0');
         s_wb_slv_data_wr   <= (others=>'0');
         s_read_write       <= '1';         
         s_ack_count        <= 0;
         s_data_count       <= 0;
         v_wait_int         := 0;
         s_addr_pos         <= 0;        
         s_test_ok          <= '1';        
         fsm_master         <= IDLE;
         estado_db          <= x"0";
         next_state         <= Idle;
         s_time_out         <= '0';    -- Default value
         s_active_sm        <= '0';
         s_read_reg_SPI     <= (others=>'0');
       -- Master reads and writes from the slave
       else 

         case fsm_master is
           when IDLE =>
             s_addr_pos   <= 0; 
             s_ack_count  <= 0;
             s_data_count <= 0;
             s_test_ok     <= '1'; -- Default value
             s_time_out    <= '0'; -- Default value
             if (s_active_sm = '1') then
               estado_db <= x"1";
               core_done_o   <= '0';
               next_state <= SPI_div_clk;
               fsm_master <= st_wait; --(next state SPI_div_clk)
               --initiate new cycle
               s_wb_slv_sel     <= "1111";
               s_wb_slv_cyc     <= '1';
               s_wb_slv_stb     <= '1';
               s_wb_slv_we      <= '1';
               s_wb_slv_data_wr  <= x"00000001";
               s_wb_slv_addr     <= '1' & x"8";     
             else
               s_wb_slv_sel    <= "0000";
               s_wb_slv_we      <= '0';
               s_wb_slv_cyc    <= '0';
               s_wb_slv_stb    <= '0';       
               fsm_master      <= Idle;
               next_state      <= Idle;
             end if;
           
           when SPI_div_clk => 
             estado_db <= x"2";
             next_state <= CTRL_set;
             fsm_master <= st_wait;  --(next state CTRL_set)
             s_wb_slv_sel     <= "1111";
             s_wb_slv_cyc     <= '1';
             s_wb_slv_stb     <= '1';
             s_wb_slv_we      <= '1'; 
             --s_wb_slv_data_wr  <= x"00000018";-- clk_spi = clk/(div+1)*2 --> 2MHz sclk for 100Mhz input (up to 25MHz)
             s_wb_slv_data_wr  <= x"00000003";-- clk_spi = clk/(div+1)*2 --> 12.5MHz sclk for 100Mhz input (up to 25MHz)
             s_wb_slv_addr     <= '1' & x"4";
               
           when CTRL_set => 
             estado_db <= x"3";
             next_state <= SPI_reg_conf;
             fsm_master      <= st_wait;--(next state SPI_reg_conf)
             s_wb_slv_sel     <= "1111";
             s_wb_slv_cyc     <= '1';
             s_wb_slv_stb     <= '1';
             s_wb_slv_we      <= '1'; 
             s_wb_slv_addr     <= '1' & x"0";
             s_wb_slv_data_wr (31 downto 14)  <= (others => '0');
             s_wb_slv_data_wr (13 downto 0)  <= "1101000" & "0011000"; -- (6:0) how many bits are transmitted in one tranfer
             
               
               
           when SPI_reg_conf => 
             estado_db <= x"4";
             next_state <= SPIdata_sent;
             s_wb_slv_data_wr (31 downto 24)  <= (others => '0');
             s_wb_slv_addr     <= '0' & x"0";
             s_wb_slv_we       <= '1';
             if(s_read_write = '1') then
               -- Write first data
               s_wb_slv_data_wr (20 downto 8)  <= std_logic_vector(to_unsigned(s_addr_master1_wr(s_addr_pos), 13));
               s_wb_slv_data_wr (7 downto 0)  <= s_data_master1_wr(s_addr_pos);
               s_wb_slv_data_wr (23 downto 21) <= "000"; -- 2-R/W ; (1:0)-Bytes to transfer
             else
               -- Read first data
               s_wb_slv_data_wr (20 downto 8)  <= std_logic_vector(to_unsigned(s_addr_master1_wr(s_addr_pos), 13));
               s_wb_slv_data_wr (7 downto 0)  <= s_data_master1_rd(s_addr_pos); -- not necesary
               s_wb_slv_data_wr (23 downto 21) <= "100"; -- 2-R/W ; (1:0)-Bytes to transfer
             end if;
             if(s_ack_count < c_NUM_SPI_REGISTERS) then
               fsm_master     <= st_wait;--(next state SPIdata_sent)
               s_wb_slv_sel    <= "1111";
               s_wb_slv_stb    <= '1';
               s_wb_slv_cyc    <= '1';
             else
               -- terminate register configuration
               s_wb_slv_sel    <= "0000";
               s_wb_slv_cyc    <= '0';
               s_wb_slv_stb    <= '0';
               if s_read_write  = '0' then
                 core_done_o   <= '1';
                 s_active_sm   <= '0';
                 s_read_write  <= '1'; 
               else
                 s_read_write  <= '0'; -- after write all registers, they should be read to verify their value
               end if;
               fsm_master     <= IDLE;
             end if; 
 
 
           when SPIdata_sent =>
             estado_db <= x"5";
             next_state <= st_wait;
             fsm_master     <= st_wait;
             --check if the pipeline is not stalled    
             if(s_data_count < c_NUM_SPI_REGISTERS) then
               if( s_addr_pos < (c_NUM_SPI_REGISTERS - 1)) then
                 -- new address to write
                 s_addr_pos   <= s_addr_pos + 1;
               else
                 s_addr_pos   <= 0;
               end if; 
               s_wb_slv_sel    <= "1111";
               s_wb_slv_stb    <= '1';
               s_wb_slv_cyc    <= '1';
               s_wb_slv_we     <= '1';
               s_wb_slv_addr   <= '1' & x"0";
               s_wb_slv_data_wr (31 downto 14)  <= (others => '0');
               s_wb_slv_data_wr (13 downto 0)  <= "1101010" & "0011000"; -- 8-active transfer + Control register(same as CTRL_set)
                 
               s_data_count <= s_data_count + 1;     
             end if;

           when read_SPI_reg => 
             estado_db <= x"7";
             next_state <= read_SPI_reg;
             s_wb_slv_sel    <= "0011";
             s_wb_slv_we     <= '0';
             s_wb_slv_addr   <= '0' & x"0";
             s_read_reg_SPI  <= x"00" & s_data_master1_rd(s_ack_count-1);
             -- Read data
             if s_wb_slv_ack  = '1' then
               if ((s_read_reg_SPI  = s_wb_slv_data_rd (15 downto 0)) or (s_ack_count = 3 or s_ack_count = 4 or s_ack_count = 21 or s_ack_count = 63)) then
                 -- neither register 0x02 nor 0x1A3 are tested because they are reserved
                 s_test_ok        <= '1';
               else
                 s_test_ok        <= '0';
               end if;
               s_wb_slv_stb    <= '0';
               s_wb_slv_cyc    <= '0';
               fsm_master     <= SPI_reg_conf;
             else
               fsm_master     <= read_SPI_reg;
               s_wb_slv_stb    <= '1';
               s_wb_slv_cyc    <= '1';
             end if;

           when st_wait =>
             if v_wait_int > c_2sec then 
               s_wb_slv_sel    <= "0000";
               s_wb_slv_cyc    <= '0';
               s_wb_slv_stb    <= '0';
               s_wb_slv_we     <= '0';
               v_wait_int      := 0;
               s_active_sm     <= '0';
               s_test_ok       <= '1';
               s_time_out      <= '1';
               s_read_write    <= '1'; 
               fsm_master      <= Idle;
               next_state      <= Idle;
             else
               s_wb_slv_we     <= '1';
               s_wb_slv_cyc    <= '1';
               if(s_wb_slv_ack  = '1') then
                 v_wait_int := 0;
                 s_wb_slv_sel    <= "0000";
                 s_wb_slv_stb    <= '0';
                 fsm_master <= next_state;
                 if next_state = SPIdata_sent then
                   s_wb_slv_we     <= '0';
                   s_wb_slv_cyc    <= '0';
                   s_ack_count     <= s_ack_count + 1;
                 end if;
                 estado_db <= x"6";
               else
                 -- Indicates that the SPI data has already been sent -> we can continue with the next reg. The exception is when
                 --the Int is active for a previous block of configuration. (this deasserted when a read or write of any register)
                 --if (s_wb_int = '1' and next_state /= SPI_div_clk) then 
                 if (s_wb_int = '1' and next_state = st_wait) then 
                   v_wait_int := 0;
                   if (s_read_write = '1') then
                     fsm_master     <= SPI_reg_conf;
                   else
                     fsm_master     <= read_SPI_reg;                     
                   end if;
                 else  -- This state is just to end the loop in case something goes wrong (2 seconds later)
                   v_wait_int := v_wait_int + 1;
                   fsm_master     <= st_wait;
                 end if;
               end if;
             end if;

           when others =>
               estado_db <= x"8";
               s_wb_slv_sel    <= "0000";
               s_wb_slv_cyc    <= '0';
               s_wb_slv_stb    <= '0';
               s_wb_slv_we     <= '0';
               fsm_master     <= IDLE;
           
         end case;

         if (core_enable_i = '1' and  s_active_sm = '0') then
           s_active_sm <= '1';
         end if;
       end if;
     end if;
    end process p_master1;        


  p_error : process( clk_i ) is
  begin
  if clk_i'event and clk_i = '1' then
    if (s_reset_n_top = '0')then
       core_error_o <= '0';
    else 
      if (core_enable_i = '1' and  s_active_sm = '0') then
       core_error_o <= '0';   
      elsif (s_wb_err = '1' or (s_test_ok = '0' or s_time_out = '1')) then
       core_error_o <= '1';
      end if;
    end if;
  end if;
  end process p_error;

-----------------------------------------------------------------------
-- Debug signals - Oscilloscope
-----------------------------------------------------------------------
  s_cs_n_db <= s_ss_pad(0);
  s_sclk_db <= s_sclk_pad;
  s_sdi_db <= s_mosi_pad;
  s_sdo_db <= PLL_SDO_i;
  FP_LEDN1 <= rst_n_i;
  FP_LEDN0 <= PLL_LOCK_i;

end Behavioral;

