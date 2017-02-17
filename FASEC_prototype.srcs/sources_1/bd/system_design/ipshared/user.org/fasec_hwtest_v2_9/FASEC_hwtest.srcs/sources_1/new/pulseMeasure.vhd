----------------------------------------------------------------------------------
-- Company: CERN
-- Engineer: Pieter Van Trappen
-- 
-- Create Date: 07.04.2015 10:46:30
-- Design Name: pulse measurement
-- Module Name: pulseMeasure - rtl
-- Project Name: FIDS
-- Target Devices: Zynq xc7z30
-- Tool Versions: 
-- Description: the pulselenght of the digital pulse_i signal is measured by using a DSP slice
-- 
-- Dependencies: 
-- 
-- Revision: 0.3.1
-- Changelog:
-- v0.1 - File Created
-- v0.2 - Window-generation generic and output added
-- v0.3 - Auto-restart of the LED counter when pulse_i stayed high removed (bug); fixed window signal that stayed high as well(bug)
-- v0.3.1 - Copied into FASEC_hwtest, modified library link
--
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library xil_pvtmisc;
use xil_pvtmisc.myPackage.all;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

--=============================================================================
-- Entity declaration for pulseMeasure
--=============================================================================
entity pulseMeasure is
  generic(g_COUNTERWIDTH    : positive := 24;                                  -- counter width
          g_LEDCOUNTERWIDTH : natural  := 32;                                  -- LED-blinking and window-generation counter width - should be wide enough to fit g_LEDWAIT!
          g_LEDWAIT         : natural  := 62500000;                            -- LED blinking pulse width; default 250ms, value depends on s_clkCnt (now: 4ns)
          g_MISSINGCDC      : boolean  := true);                               -- if true, the missingWindow_i signed is clocked through a dubble buffer because of Clock Domain Crossing
  port (clk_dsp_i      : in  std_logic;
        reset_n_i      : in  std_logic;
        pulse_i        : in  std_logic;
        missingWindow_i : in unsigned(g_LEDCOUNTERWIDTH-1 downto 0);           -- generated window (pulse width+1); default 2us, value depends on s_clkCnt (now: 4ns) - should be smaller than g_LEDWAIT!
        pulse_o        : out std_logic;
        edgeDetected_o : out std_logic;                                        -- for now configured as rising edge detection
        usrLed_o       : out std_logic;
        window_o       : out std_logic;                                        -- because of the way it is implemented, window_o comes high 3 clock pulses later than pulse_0
        pulseLength_o  : out std_logic_vector (g_COUNTERWIDTH-1 downto 0);
        LedCount_o     : out std_logic_vector(g_LEDCOUNTERWIDTH-1 downto 0));  -- counter value of the running LED/window counter, reset to 0 when counter has finished
end pulseMeasure;

--=============================================================================
-- architecture declaration
--=============================================================================
architecture rtl of pulseMeasure is
  -- pulse length measurement signals
  signal s_pulse            : std_logic;
  signal s_pulseEdge        : std_logic;
  signal s_pulseReg         : std_logic;
  signal s_pulseLength      : std_logic_vector(g_COUNTERWIDTH-1 downto 0);
  signal s_pulseLengthLatch : std_logic_vector(g_COUNTERWIDTH-1 downto 0);
  -- LED blinking signals
  signal s_pulseLed         : std_logic;
  signal s_window           : std_logic;
  signal s_pulseLedLength   : std_logic_vector(g_LEDCOUNTERWIDTH-1 downto 0);
  signal s_pulseLedReset    : std_logic;
  -- CDC buffers
  signal s_missingBuff          : unsigned(g_LEDCOUNTERWIDTH-1 downto 0) := (others=>'0');
--=============================================================================
-- architecture begin
--=============================================================================
begin
  -- pulse signal synchronisation (clocking-in with clk_dsp_i)
  cmp_pulseSync : doubleBufferEdge
    generic map (
      g_DEFAULT       => '0',
      g_RISING_EDGE   => true,          -- detect rising edge
      g_DEBOUNCE      => true,          -- debounce the signal for more stability
      g_DEBOUNCEWIDTH => 5
      )          
    port map (
      clk_i     => clk_dsp_i,
      reset_n_i => reset_n_i,
      input_i   => pulse_i,
      output_o  => s_pulse,
      edge_o    => s_pulseEdge);

  -- missingWindow value synchronisation
  p_missingWindowBuffers : process(clk_dsp_i, missingWindow_i)
    variable v_missingBuff1 : unsigned(g_LEDCOUNTERWIDTH-1 downto 0) := (others=>'0');
  begin
      if g_MISSINGCDC=false then
        s_missingBuff(g_LEDCOUNTERWIDTH-1 downto 0) <= missingWindow_i(g_LEDCOUNTERWIDTH-1 downto 0);
      elsif rising_edge(clk_dsp_i) then        
        s_missingBuff(g_LEDCOUNTERWIDTH-1 downto 0) <= v_missingBuff1(g_LEDCOUNTERWIDTH-1 downto 0);
        v_missingBuff1(g_LEDCOUNTERWIDTH-1 downto 0) := missingWindow_i(g_LEDCOUNTERWIDTH-1 downto 0);
      end if;
  end process p_missingWindowBuffers;
  
  -- count the pulse length
  cmp_lengthCounter : counterUpDown
    generic map (
      g_WIDTH => g_COUNTERWIDTH)
    port map (
      clk_i     => clk_dsp_i,
      reset_n_i => s_pulse,             -- reset the counter when no more pulse, ensures next one is counted from 0
      countUp_i => '1',
      enable_i  => s_pulse,             -- count enable as long as we have a pulse
      count_o   => s_pulseLength(g_COUNTERWIDTH-1 downto 0));

  -- generate a LED blink pulse by starting a counter from a pulse rising edge
  -- this counter is also used for the window length extention, so it needs to be reset when a new pulse arrives
  cmp_pulseCounterLED : counterUpDown
    generic map (
      g_WIDTH => g_LEDCOUNTERWIDTH)
    port map (
      clk_i     => clk_dsp_i,
      reset_n_i => s_pulseLedReset,
      countUp_i => '1',
      enable_i  => s_pulseLed,          -- enable is latched when s_pulseEdge=1, see p_pulseLED
      count_o   => s_pulseLedLength(g_LEDCOUNTERWIDTH-1 downto 0));
  -- reset the counter when: LEDcounter has run out OR new pulse has been detected
  s_pulseLedReset <= s_pulseLed and not s_pulseEdge;

  -- clock in the counter values when  pulse_i is high, when low keep the last value
  p_pulseCounterLatch : process(clk_dsp_i, reset_n_i)
  begin
    if reset_n_i = '0' then
      s_pulseLengthLatch <= (others => '0');
      s_pulseReg         <= '0';
    elsif rising_edge(clk_dsp_i) then
      s_pulseReg <= s_pulse;            -- 1 clock-pulse delay necessary because s_pulse is brought down at the same rising edge used by the DSP counter to increase
      if s_pulseReg = '1' then
        s_pulseLengthLatch(g_COUNTERWIDTH-1 downto 0) <= s_pulseLength(g_COUNTERWIDTH-1 downto 0);
      -- s_pulseLengthLatch keeps its value when s_pulseReg='0'
      end if;
    end if;
  end process p_pulseCounterLatch;

  -- extend the pulse to flash a LED (extended pulse length set by g_LEDWAIT and clk_dsp_i)
  p_pulseLED : process(clk_dsp_i, reset_n_i)
  begin
    if reset_n_i = '0' then
      s_pulseLed <= '0';
      s_window   <= '0';
    elsif rising_edge(clk_dsp_i) then
      -- user LED pulse
      if (to_integer(signed(s_pulseLedLength(g_LEDCOUNTERWIDTH-1 downto 0))) = g_LEDWAIT) then
        s_pulseLed <= '0';
      elsif s_pulseEdge = '1' then
        s_pulseLed <= '1';              -- latch on s_pulseEdge (and not s_pulse) otherwise cmp_pulseCounterLED will auto-restart
      end if;
      -- window pulse
      if (to_integer(signed(s_pulseLedLength(g_LEDCOUNTERWIDTH-1 downto 0))) = 0)
        or (to_integer(signed(s_pulseLedLength(g_LEDCOUNTERWIDTH-1 downto 0))) > to_integer(s_missingBuff(g_LEDCOUNTERWIDTH-1 downto 0))) then  -- +1 removed because of change from generic to missingWindow_i
        s_window <= '0';
      elsif s_pulse = '1' then
        s_window <= '1';
      end if;
    end if;
  end process p_pulseLED;

  -- output generation
  pulse_o                                  <= s_pulse;
  edgeDetected_o                           <= s_pulseEdge;
  usrLed_o                                 <= s_pulseLed;
  window_o                                 <= s_window;
  pulseLength_o(g_COUNTERWIDTH-1 downto 0) <= s_pulseLengthLatch(g_COUNTERWIDTH-1 downto 0);
  LedCount_o(g_LEDCOUNTERWIDTH-1 downto 0) <= s_pulseLedLength(g_LEDCOUNTERWIDTH-1 downto 0);
  
end rtl;
--=============================================================================
-- architecture end
--=============================================================================
