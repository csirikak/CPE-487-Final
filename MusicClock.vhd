LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY MusicClock IS
	PORT (
		inclk : IN std_logic;
		MusClk : OUT std_logic
	);
END MusicClock;

ARCHITECTURE Behavioral OF MusicClock IS
	SIGNAL count : INTEGER := 5357144; --was 10714286, but was half speed
	SIGNAL clk_reg : std_logic := '0';
	SIGNAL counter : INTEGER := 0;
BEGIN
	PROCESS (inclk)
	BEGIN
		IF rising_edge(inclk) THEN
			IF (counter >= count) THEN
				counter <= 0;
				clk_reg <= NOT(clk_reg);
			ELSE
				counter <= counter + 1;
			END IF;
		END IF;
	END PROCESS;
	MusClk <= clk_reg;
END Behavioral;
