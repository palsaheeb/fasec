--------------------------------------------------------------------------------
-- Title      : 62.5 MHz generation from the ext 10 MHz clk.
-- Project    : wr-len/zen
-------------------------------------------------------------------------------
-- File       : ext_pll_10_to_62_compensated.vhd
-- Author     : Emilio Marín López
-- Company    : Seven Solutions
-- Created    : 22-10-2015
-- Last update:
-- Platform   :
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Module to generate a 62.5 Mhz from the external 10MHz (Grand Master).
-- All the complexity of this module is the 90º compensation in real time on the MMCM output.
-- This shift comes from the use of fractional values at CLKFBOUT_MULT_F.
-- The greatest execution time for this FSM is 5.04 ms. Keep it in mind!
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author			Description
-- 22-10-2015  1.0      eml         Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.vcomponents.all;

library work;
use work.gen7s_cores_pkg.all;

entity ext_pll_10_to_62_compensated is
	port (
		-- 10 MHz input clock
		ext_clk_i	: in std_logic;
		-- reset n. (active low).
		rst_n_i		: in std_logic;
		-- pps input.
		pps_i : in std_logic;
		-- Grand Master mode enabled.
		gm_en_i	: in std_logic;
		-- 62.5 Mhz raised up clock.
		clk_ext_mul_o	: out std_logic;
		-- is clk_ext_mul locked?
		clk_ext_mul_locked_o	: out std_logic
);
end ext_pll_10_to_62_compensated;

architecture behavioral of ext_pll_10_to_62_compensated is

	-- FSM.
	type state is (rst_state, wait_gm, wait_lock, wait_pps_r, pattern_detection, phase_detection, phase_shifting, wait_ps_done, ps_done);
	signal shifting_state	: state := rst_state;

	-- Signal to detect the MMCM locking
  signal s_clk_ext_mul_locked 	: std_logic;

	-- Feedback clk (625 MHz)
  signal s_pllout_clk_fb_ext  	: std_logic;

	-- External 62.5 MHz raised up clock.
  signal s_clk_ext_mul        	: std_logic;
	signal s_pllout_clk_ext_mul 	: std_logic;

	-- Gated clock only for sampling.
	signal s_ext_mul_gated_clock : std_logic;

	-- Signal to indicate the FSM ending.
	signal s_dynamic_ps_fsm_done	: std_logic := '0';

  -- Signals to manage the external FSM phase shifting.
  signal s_ext_pattern      : std_logic_vector(7 downto 0) := (others => '0');
  signal s_pattern_detected : std_logic := '0';
  signal s_rising_pps_input : std_logic := '0';
  signal s_pps_i_delayed    : std_logic := '0';
  signal s_pattern_allowed  : std_logic := '0';

	-- Signal to manage the dynamic phase sifthing.
	signal s_ps_en				: std_logic := '0';
	signal s_ps_done			: std_logic := '0';
	signal s_ps_increment : std_logic := '1';	--Increments by default.

	--Phase shifting counter
	signal s_ps_counter	: integer range 0 to 1400 := 0;	 -- 1400 is the greatest shift for 180º

	-- constants to indicate the phase shift number regarding the phase error.
	constant c_0_degrees_shift		: integer := 0;
	constant c_90_degrees_shift		: integer := 700;		--PS increment
	constant c_180_degrees_shift	: integer := 1400;	--PS increment
	constant c_270_degrees_shift	: integer	:= 700;		--PS decrement

	-- These constants define the shift phase error previously measured.
	constant c_0_degrees_pattern		: std_logic_vector(7 downto 0) := x"cc";	--valley
	constant c_90_degrees_pattern		: std_logic_vector(7 downto 0) := x"66";	--rising
	constant c_180_degrees_pattern	: std_logic_vector(7 downto 0) := x"33";	--mountain
	constant c_270_degrees_pattern	: std_logic_vector(7 downto 0) := x"99";	--falling

begin

  -- External clock to raise the 10 MHz to 62.5 MHz clk.
  -- 10 MHz ---> 62.5 MHz.
   cmp_ext_clk_pll : MMCME2_ADV
   generic map
		(BANDWIDTH            => "LOW",
		CLKOUT4_CASCADE      => FALSE,
		COMPENSATION         => "ZHOLD",
		STARTUP_WAIT         => FALSE,
		DIVCLK_DIVIDE        => 1,
		CLKFBOUT_MULT_F      => 62.500,        -- 10 MHz x 62.5 = 625 MHz -- Between 600 and 1200.
		CLKFBOUT_PHASE       => 0.000,
		CLKFBOUT_USE_FINE_PS => FALSE,

		CLKOUT0_DIVIDE_F     => 10.000,        -- 62.5 MHz (T = 16 ns)
		CLKOUT0_PHASE        => 0.000,
		CLKOUT0_DUTY_CYCLE   => 0.500,
		CLKOUT0_USE_FINE_PS  => TRUE,					 -- Phase shifting enabled.

		CLKOUT1_DIVIDE       => 10,            -- 62.5 MHz (T = 16 ns)
		CLKOUT1_PHASE        => 0.000,
		CLKOUT1_DUTY_CYCLE   => 0.500,
		CLKOUT1_USE_FINE_PS  => TRUE,					 -- Phase shifting enabled.

		CLKIN1_PERIOD        => 100.000,			 -- 100 ns means 10 MHz
		REF_JITTER1          => 0.005)
   port map
     -- Output clocks
    (CLKFBOUT            => s_pllout_clk_fb_ext,
     CLKFBOUTB           => open,
     CLKOUT0             => s_pllout_clk_ext_mul,
     CLKOUT0B            => open,
     CLKOUT1             => s_ext_mul_gated_clock,
     CLKOUT1B            => open,
     CLKOUT2             => open,
     CLKOUT2B            => open,
     CLKOUT3             => open,
     CLKOUT3B            => open,
     CLKOUT4             => open,
     CLKOUT5             => open,
     CLKOUT6             => open,

     -- Input clock control
     CLKFBIN             => s_pllout_clk_fb_ext,
     CLKIN1              => ext_clk_i,
     CLKIN2              => '0',

     -- Tied to always select the primary input clock
     CLKINSEL            => '1',

     -- Ports for dynamic reconfiguration
     DADDR               => (others => '0'),
     DCLK                => '0',
     DEN                 => '0',
     DI                  => (others => '0'),
     DO                  => open,
     DRDY                => open,
     DWE                 => '0',

     -- Ports for dynamic phase shift
     PSCLK               => ext_clk_i,
     PSEN                => s_ps_en,
     PSINCDEC            => s_ps_increment,
     PSDONE              => s_ps_done,

     -- Other control and status signals
     LOCKED              => s_clk_ext_mul_locked,
     CLKINSTOPPED        => open,
     CLKFBSTOPPED        => open,
     PWRDWN              => '0',
     RST                 => '0');

	p_phase_shifting_fms : process (ext_clk_i, s_clk_ext_mul_locked, rst_n_i)
		variable p_counter : integer := 0;
	begin
		if (rst_n_i = '0' or s_clk_ext_mul_locked = '0') then
			shifting_state			<= rst_state;
		else
			if rising_edge(ext_clk_i) then

				s_pps_i_delayed <= pps_i;

				case shifting_state is
					when rst_state =>
						p_counter     := 0;
						s_pps_i_delayed				<= '0';
						s_pattern_allowed  		<= '0';
						s_pattern_detected  	<= '0';
						s_dynamic_ps_fsm_done	<= '0';
						s_ps_increment				<= '1';		-- Increments by default.
						shifting_state 				<= wait_gm;

					when wait_gm =>
						if (gm_en_i = '1') then
							shifting_state <= wait_lock;
						end if;

					when wait_lock =>
						if (s_clk_ext_mul_locked = '1' and s_rising_pps_input = '0') then
							shifting_state <= wait_pps_r;
						end if;

					when wait_pps_r =>
						if (s_rising_pps_input = '1') then
							shifting_state <= pattern_detection;
						end if;

					when pattern_detection =>
						s_ext_pattern(p_counter) <= s_ext_mul_gated_clock;
	          p_counter := p_counter + 1;
	          if (p_counter = 8) then
	            shifting_state <= phase_detection;
	          end if;

					when phase_detection =>
						if (s_ext_pattern = c_0_degrees_pattern) then
							s_ps_increment 	<= '1';
							s_ps_counter 		<= c_0_degrees_shift;
						elsif (s_ext_pattern = c_90_degrees_pattern) then
							s_ps_increment 	<= '1';
							s_ps_counter 		<= c_90_degrees_shift;
						elsif (s_ext_pattern = c_180_degrees_pattern) then
							s_ps_increment 	<= '1';
							s_ps_counter 		<= c_180_degrees_shift;
						elsif (s_ext_pattern = c_270_degrees_pattern) then
							s_ps_increment 	<= '0';
							s_ps_counter 		<= c_270_degrees_shift;
						end if;

						shifting_state <= phase_shifting;

					when phase_shifting =>
						if (s_ps_counter = 0) then
							shifting_state <= ps_done;
						else
							s_ps_en 				<= '1';
							s_ps_counter 		<= s_ps_counter - 1;
							shifting_state	<= wait_ps_done;
						end if;

					when wait_ps_done =>
						s_ps_en <= '0';
						if ( s_ps_done = '1' ) then
							shifting_state	<= phase_shifting;
						end if;

					when ps_done =>
						s_dynamic_ps_fsm_done <= '1';
				end case;
			end if;
		end if;
	end process;

s_rising_pps_input 		<= pps_i and (not s_pps_i_delayed);
clk_ext_mul_o 				<= s_clk_ext_mul;
clk_ext_mul_locked_o	<= s_clk_ext_mul_locked and s_dynamic_ps_fsm_done;

cmp_clk_ext_buf : BUFG
 port map (
   O => s_clk_ext_mul,
   I => s_pllout_clk_ext_mul);

end behavioral;
