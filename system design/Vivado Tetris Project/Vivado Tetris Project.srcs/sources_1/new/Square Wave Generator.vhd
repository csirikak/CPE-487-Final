LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY WaveGenerator IS
	PORT (
		aud_clk : IN std_logic; --48.8khz
		note : IN std_logic_vector (4 DOWNTO 0);
		tone : OUT signed (15 DOWNTO 0)
	);
END WaveGenerator;

ARCHITECTURE Behavioral OF WaveGenerator IS
	SIGNAL tmp_clk : std_logic := '0';
BEGIN
	square : PROCESS (aud_clk, tmp_clk, note) 
		VARIABLE div_cnt : INTEGER := 0;
		VARIABLE max_count : INTEGER := 0;
	BEGIN
		CASE note IS --When the clock speed is 48800hz
			WHEN "00000" => max_count := 0; --empty note
			WHEN "00001" => max_count := 28; --A6 28
			WHEN "00010" => max_count := 31; --G6 31
			WHEN "00011" => max_count := 35; --F6 35
			WHEN "00100" => max_count := 37; --E6 37
			WHEN "00101" => max_count := 42; --D6 42
			WHEN "00110" => max_count := 49; --B5 49
			WHEN "00111" => max_count := 52; --A#5 52
			WHEN "01000" => max_count := 55; --A5 55
			WHEN "01001" => max_count := 62; --G562
			WHEN "01010" => max_count := 70; --F5 70
			WHEN "01011" => max_count := 74; --E5 74
			WHEN "01100" => max_count := 83; --D5 83
			WHEN "01101" => max_count := 93; --C5 93
			WHEN "01110" => max_count := 99; --B4 99
			WHEN "01111" => max_count := 105; --A#4 105
			WHEN "10000" => max_count := 111; --A4 111
			WHEN "10001" => max_count := 118; --G#4 118
			WHEN "10010" => max_count := 148; --E4 148
			WHEN "10011" => max_count := 166; --D4 166
			WHEN "10100" => max_count := 187; --C4 187
			WHEN "10101" => max_count := 197; --B3 197
			WHEN "10110" => max_count := 222; --A3 222
			WHEN "10111" => max_count := 235; --G#3 235
			WHEN "11000" => max_count := 296; --E3 296
			WHEN "11001" => max_count := 339; --D3 339
			WHEN "11010" => max_count := 373; --C3 373
			WHEN "11011" => max_count := 470; --G#2 470
			WHEN "11100" => max_count := 47; --C6 47
			WHEN "11101" => max_count := 0; --Unassigned
			WHEN "11110" => max_count := 0; --Unassigned
			WHEN "11111" => max_count := 0; --Unassigned
			WHEN OTHERS => 
		END CASE;
		IF (rising_edge(aud_clk)) THEN
			IF (div_cnt >= max_count) THEN
				tmp_clk <= NOT tmp_clk;
				div_cnt := 0;
			ELSE
				div_cnt := div_cnt + 2;
			END IF;
		END IF;

		IF (note = "00000") THEN
			tone <= "0000000000000000";
		ELSE
			CASE tmp_clk IS
				WHEN '0' => tone <= TO_SIGNED(10240, 16);
				WHEN '1' => tone <= TO_SIGNED( - 10240, 16);
			END CASE;
		END IF;
 
	END PROCESS square;
END Behavioral;