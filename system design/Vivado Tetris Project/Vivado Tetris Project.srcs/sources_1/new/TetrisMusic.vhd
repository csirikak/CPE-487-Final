LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY TetrisMusic IS
	PORT (
		clk_in : IN STD_LOGIC;
		dac_MCLK : OUT STD_LOGIC; -- outputs to PMODI2L DAC
		dac_LRCK : OUT STD_LOGIC;
		dac_SCLK : OUT STD_LOGIC;
		dac_SDIN : OUT STD_LOGIC
	);
END TetrisMusic;

ARCHITECTURE Behavioral OF TetrisMusic IS
	COMPONENT dac_if IS
		PORT (
			SCLK : IN STD_LOGIC;
			L_start : IN STD_LOGIC;
			R_start : IN STD_LOGIC;
			L_data : IN signed (15 DOWNTO 0);
			R_data : IN signed (15 DOWNTO 0);
			SDATA : OUT STD_LOGIC
		);
	END COMPONENT;
 
	COMPONENT ChannelCombiner IS
		PORT (
			aud_CH1 : IN signed (15 DOWNTO 0);
			aud_CH2 : IN signed (15 DOWNTO 0);
			aud_CH3 : IN signed (15 DOWNTO 0);
			tone : OUT signed (15 DOWNTO 0)
		);
	END COMPONENT;
 
 
	COMPONENT CLKDiv2 IS
		PORT (
			inclk : IN std_logic;
			Clk50 : OUT std_logic
		);
	END COMPONENT;
 
	COMPONENT MusicClock IS
		PORT (
			inclk : IN std_logic;
			MusClk : OUT std_logic
		);
	END COMPONENT;
 
	COMPONENT WaveGenerator IS
		PORT (
			aud_clk : IN std_logic;
			note : IN std_logic_vector (4 DOWNTO 0);
			tone : OUT signed (15 DOWNTO 0)
		);
	END COMPONENT;
 
	COMPONENT MusicBox IS
		PORT (
			MusicClk : IN std_logic;
			Channel : IN std_logic_vector (1 DOWNTO 0);
			CurrentNote : OUT std_logic_vector
		);
	END COMPONENT;
 
	SIGNAL clk_50mhz : std_logic;
	SIGNAL CurNote1 : std_logic_vector(4 DOWNTO 0);
	SIGNAL CurNote2 : std_logic_vector(4 DOWNTO 0);
	SIGNAL CurNote3 : std_logic_vector(4 DOWNTO 0);
	SIGNAL Audio1 : signed(15 DOWNTO 0);
	SIGNAL Audio2 : signed(15 DOWNTO 0);
	SIGNAL Audio3 : signed(15 DOWNTO 0);
	SIGNAL MusClk : std_logic;
	SIGNAL tcount : unsigned (19 DOWNTO 0) := (OTHERS => '0'); -- timing counter
	SIGNAL data_L, data_R : SIGNED (15 DOWNTO 0); -- 16-bit signed audio data
	SIGNAL dac_load_L, dac_load_R : STD_LOGIC; -- timing pulses to load DAC shift reg.
	SIGNAL slo_clk, sclk, audio_CLK : STD_LOGIC;
BEGIN
	-- this process sets up a 20 bit binary counter clocked at 50MHz. This is used
	-- to generate all necessary timing signals. dac_load_L and dac_load_R are pulses
	-- sent to dac_if to load parallel data into shift register for serial clocking
	-- out to DAC
	tim_pr : PROCESS
	BEGIN
		WAIT UNTIL rising_edge(clk_50MHz);
		IF (tcount(9 DOWNTO 0) >= X"00F") AND (tcount(9 DOWNTO 0) < X"02E") THEN
			dac_load_L <= '1';
		ELSE
			dac_load_L <= '0';
		END IF;
		IF (tcount(9 DOWNTO 0) >= X"20F") AND (tcount(9 DOWNTO 0) < X"22E") THEN
			dac_load_R <= '1';
		ELSE
			dac_load_R <= '0';
		END IF;
		tcount <= tcount + 1;
	END PROCESS;
	dac_MCLK <= NOT tcount(1); -- DAC master clock (12.5 MHz)
	audio_CLK <= tcount(9); -- audio sampling rate (48.8 kHz)
	dac_LRCK <= audio_CLK; -- also sent to DAC as left/right clock
	sclk <= tcount(4); -- serial data clock (1.56 MHz)
	dac_SCLK <= sclk; -- also sent to DAC as SCLK
	slo_clk <= tcount(19); -- clock to control wailing of tone (47.6 Hz)
 
	clk50 : ClkDiv2
	PORT MAP(
		inclk => clk_in, 
		Clk50 => clk_50mhz
		);
 
 
		dac : dac_if
		PORT MAP(
			SCLK => sclk, -- instantiate parallel to serial DAC interface
			L_start => dac_load_L, 
			R_start => dac_load_R, 
			L_data => data_L, 
			R_data => data_R, 
			SDATA => dac_SDIN
		);
		a1 : WaveGenerator
		PORT MAP(
			aud_clk => audio_CLK, 
			note => CurNote1, 
			tone => Audio1
		);
 
		a2 : WaveGenerator
		PORT MAP(
			aud_clk => audio_CLK, 
			note => CurNote2, 
			tone => Audio2
		);
 
		a3 : WaveGenerator
		PORT MAP(
			aud_clk => audio_CLK, 
			note => CurNote3, 
			tone => Audio3
		);
 
		mc1 : MusicClock
		PORT MAP(
			inclk => clk_in, 
			MusClk => MusClk
		);
 
		mb1 : MusicBox
		PORT MAP(
			MusicClk => MusCLK, 
			Channel => "00", 
			CurrentNote => CurNote1
		);
 
		mb2 : MusicBox
		PORT MAP(
			MusicClk => MusCLK, 
			Channel => "01", 
			CurrentNote => CurNote2
		);
 
		mb3 : MusicBox
		PORT MAP(
			MusicClk => MusCLK, 
			Channel => "10", 
			CurrentNote => CurNote3
		);
 
		ChCb : ChannelCombiner
		PORT MAP(
			aud_CH1 => Audio1, 
			aud_CH2 => Audio2, 
			aud_CH3 => Audio3, 
		tone => data_L); 

		data_R <= data_L; -- duplicate data on right channel
END Behavioral;