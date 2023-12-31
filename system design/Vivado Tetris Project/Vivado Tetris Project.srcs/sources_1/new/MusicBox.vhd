LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY MusicBox IS
	PORT (
		MusicClk : IN std_logic;
		Channel : IN std_logic_vector (1 DOWNTO 0);
		CurrentNote : OUT std_logic_vector (4 DOWNTO 0)
	);
END MusicBox;

ARCHITECTURE Behavioral OF MusicBox IS
	SIGNAL songcase : std_logic_vector (3 DOWNTO 0);
	SIGNAL count : INTEGER := 127;
	SIGNAL counter : INTEGER := 0;
 
BEGIN
	music1 : PROCESS (MusicClk)
	BEGIN
		IF rising_edge(MusicCLK) THEN
			IF (counter >= count) THEN
				counter <= 0;
			ELSE
				counter <= counter + 1;
			END IF;
		END IF;
 
		IF Channel = "00" THEN 
			CASE counter IS
				WHEN 0 => CurrentNote <= "00100";
				WHEN 1 => CurrentNote <= "00000";
				WHEN 2 => CurrentNote <= "00000";
				WHEN 3 => CurrentNote <= "00000";
				WHEN 4 => CurrentNote <= "00110";
				WHEN 5 => CurrentNote <= "00000";
				WHEN 6 => CurrentNote <= "11100";
				WHEN 7 => CurrentNote <= "00000";
				WHEN 8 => CurrentNote <= "00101";
				WHEN 9 => CurrentNote <= "00000";
				WHEN 10 => CurrentNote <= "00100";
				WHEN 11 => CurrentNote <= "00101";
				WHEN 12 => CurrentNote <= "11100";
				WHEN 13 => CurrentNote <= "00000";
				WHEN 14 => CurrentNote <= "00110";
				WHEN 15 => CurrentNote <= "00000";
				WHEN 16 => CurrentNote <= "01000";
				WHEN 17 => CurrentNote <= "00000";
				WHEN 18 => CurrentNote <= "00000";
				WHEN 19 => CurrentNote <= "00000";
				WHEN 20 => CurrentNote <= "01000";
				WHEN 21 => CurrentNote <= "00000";
				WHEN 22 => CurrentNote <= "11100";
				WHEN 23 => CurrentNote <= "00000";
				WHEN 24 => CurrentNote <= "00100";
				WHEN 25 => CurrentNote <= "00000";
				WHEN 26 => CurrentNote <= "00000";
				WHEN 27 => CurrentNote <= "00000";
				WHEN 28 => CurrentNote <= "00101";
				WHEN 29 => CurrentNote <= "00000";
				WHEN 30 => CurrentNote <= "11100";
				WHEN 31 => CurrentNote <= "00000";
				WHEN 32 => CurrentNote <= "00110";
				WHEN 33 => CurrentNote <= "00000";
				WHEN 34 => CurrentNote <= "00000";
				WHEN 35 => CurrentNote <= "00000";
				WHEN 36 => CurrentNote <= "00110";
				WHEN 37 => CurrentNote <= "00111";
				WHEN 38 => CurrentNote <= "11100";
				WHEN 39 => CurrentNote <= "00000";
				WHEN 40 => CurrentNote <= "00101";
				WHEN 41 => CurrentNote <= "00000";
				WHEN 42 => CurrentNote <= "00000";
				WHEN 43 => CurrentNote <= "00000";
				WHEN 44 => CurrentNote <= "00100";
				WHEN 45 => CurrentNote <= "00000";
				WHEN 46 => CurrentNote <= "00000";
				WHEN 47 => CurrentNote <= "00000";
				WHEN 48 => CurrentNote <= "11100";
				WHEN 49 => CurrentNote <= "00000";
				WHEN 50 => CurrentNote <= "00000";
				WHEN 51 => CurrentNote <= "00000";
				WHEN 52 => CurrentNote <= "01000";
				WHEN 53 => CurrentNote <= "00000";
				WHEN 54 => CurrentNote <= "00000";
				WHEN 55 => CurrentNote <= "00000";
				WHEN 56 => CurrentNote <= "01000";
				WHEN 57 => CurrentNote <= "00000";
				WHEN 58 => CurrentNote <= "00000";
				WHEN 59 => CurrentNote <= "00000";
				WHEN 60 => CurrentNote <= "00000";
				WHEN 61 => CurrentNote <= "00000";
				WHEN 62 => CurrentNote <= "00000";
				WHEN 63 => CurrentNote <= "00000";
				WHEN 64 => CurrentNote <= "00101";
				WHEN 65 => CurrentNote <= "00000";
				WHEN 66 => CurrentNote <= "00000";
				WHEN 67 => CurrentNote <= "00000";
				WHEN 68 => CurrentNote <= "00101";
				WHEN 69 => CurrentNote <= "00000";
				WHEN 70 => CurrentNote <= "00011";
				WHEN 71 => CurrentNote <= "00000";
				WHEN 72 => CurrentNote <= "00001";
				WHEN 73 => CurrentNote <= "00000";
				WHEN 74 => CurrentNote <= "00000";
				WHEN 75 => CurrentNote <= "00000";
				WHEN 76 => CurrentNote <= "00010";
				WHEN 77 => CurrentNote <= "00000";
				WHEN 78 => CurrentNote <= "00011";
				WHEN 79 => CurrentNote <= "00000";
				WHEN 80 => CurrentNote <= "00100";
				WHEN 81 => CurrentNote <= "00000";
				WHEN 82 => CurrentNote <= "00000";
				WHEN 83 => CurrentNote <= "00000";
				WHEN 84 => CurrentNote <= "00100";
				WHEN 85 => CurrentNote <= "00000";
				WHEN 86 => CurrentNote <= "11100";
				WHEN 87 => CurrentNote <= "00000";
				WHEN 88 => CurrentNote <= "00100";
				WHEN 89 => CurrentNote <= "00000";
				WHEN 90 => CurrentNote <= "00000";
				WHEN 91 => CurrentNote <= "00000";
				WHEN 92 => CurrentNote <= "00101";
				WHEN 93 => CurrentNote <= "00000";
				WHEN 94 => CurrentNote <= "11100";
				WHEN 95 => CurrentNote <= "00000";
				WHEN 96 => CurrentNote <= "00110";
				WHEN 97 => CurrentNote <= "00000";
				WHEN 98 => CurrentNote <= "00000";
				WHEN 99 => CurrentNote <= "00000";
				WHEN 100 => CurrentNote <= "00110";
				WHEN 101 => CurrentNote <= "00111";
				WHEN 102 => CurrentNote <= "11100";
				WHEN 103 => CurrentNote <= "00000";
				WHEN 104 => CurrentNote <= "00101";
				WHEN 105 => CurrentNote <= "00000";
				WHEN 106 => CurrentNote <= "00000";
				WHEN 107 => CurrentNote <= "00000";
				WHEN 108 => CurrentNote <= "00100";
				WHEN 109 => CurrentNote <= "00000";
				WHEN 110 => CurrentNote <= "00000";
				WHEN 111 => CurrentNote <= "00000";
				WHEN 112 => CurrentNote <= "11100";
				WHEN 113 => CurrentNote <= "00000";
				WHEN 114 => CurrentNote <= "00000";
				WHEN 115 => CurrentNote <= "00000";
				WHEN 116 => CurrentNote <= "01000";
				WHEN 117 => CurrentNote <= "00000";
				WHEN 118 => CurrentNote <= "00000";
				WHEN 119 => CurrentNote <= "00000";
				WHEN 120 => CurrentNote <= "01000";
				WHEN 121 => CurrentNote <= "00000";
				WHEN 122 => CurrentNote <= "00000";
				WHEN 123 => CurrentNote <= "00000";
				WHEN 124 => CurrentNote <= "00000";
				WHEN 125 => CurrentNote <= "00000";
				WHEN 126 => CurrentNote <= "00000";
				WHEN 127 => CurrentNote <= "00000";
				WHEN OTHERS => 
			END CASE;
		ELSIF Channel = "01" THEN
			CASE counter IS
				WHEN 127 => CurrentNote <= "00000";
				WHEN 0 => CurrentNote <= "01011";
				WHEN 1 => CurrentNote <= "00000";
				WHEN 2 => CurrentNote <= "00000";
				WHEN 3 => CurrentNote <= "00000";
				WHEN 4 => CurrentNote <= "01110";
				WHEN 5 => CurrentNote <= "00000";
				WHEN 6 => CurrentNote <= "01101";
				WHEN 7 => CurrentNote <= "00000";
				WHEN 8 => CurrentNote <= "01100";
				WHEN 9 => CurrentNote <= "00000";
				WHEN 10 => CurrentNote <= "01011";
				WHEN 11 => CurrentNote <= "01100";
				WHEN 12 => CurrentNote <= "01101";
				WHEN 13 => CurrentNote <= "00000";
				WHEN 14 => CurrentNote <= "01110";
				WHEN 15 => CurrentNote <= "00000";
				WHEN 16 => CurrentNote <= "10000";
				WHEN 17 => CurrentNote <= "00000";
				WHEN 18 => CurrentNote <= "10000";
				WHEN 19 => CurrentNote <= "00000";
				WHEN 20 => CurrentNote <= "10000";
				WHEN 21 => CurrentNote <= "00000";
				WHEN 22 => CurrentNote <= "01101";
				WHEN 23 => CurrentNote <= "00000";
				WHEN 24 => CurrentNote <= "01011";
				WHEN 25 => CurrentNote <= "00000";
				WHEN 26 => CurrentNote <= "10000";
				WHEN 27 => CurrentNote <= "00000";
				WHEN 28 => CurrentNote <= "01100";
				WHEN 29 => CurrentNote <= "00000";
				WHEN 30 => CurrentNote <= "01101";
				WHEN 31 => CurrentNote <= "00000";
				WHEN 32 => CurrentNote <= "01110";
				WHEN 33 => CurrentNote <= "00000";
				WHEN 34 => CurrentNote <= "10001";
				WHEN 35 => CurrentNote <= "00000";
				WHEN 36 => CurrentNote <= "01110";
				WHEN 37 => CurrentNote <= "01111";
				WHEN 38 => CurrentNote <= "01101";
				WHEN 39 => CurrentNote <= "00000";
				WHEN 40 => CurrentNote <= "01100";
				WHEN 41 => CurrentNote <= "00000";
				WHEN 42 => CurrentNote <= "00000";
				WHEN 43 => CurrentNote <= "00000";
				WHEN 44 => CurrentNote <= "01011";
				WHEN 45 => CurrentNote <= "00000";
				WHEN 46 => CurrentNote <= "00000";
				WHEN 47 => CurrentNote <= "00000";
				WHEN 48 => CurrentNote <= "01101";
				WHEN 49 => CurrentNote <= "00000";
				WHEN 50 => CurrentNote <= "10000";
				WHEN 51 => CurrentNote <= "00000";
				WHEN 52 => CurrentNote <= "10000";
				WHEN 53 => CurrentNote <= "00000";
				WHEN 54 => CurrentNote <= "10000";
				WHEN 55 => CurrentNote <= "00000";
				WHEN 56 => CurrentNote <= "10000";
				WHEN 57 => CurrentNote <= "00000";
				WHEN 58 => CurrentNote <= "00000";
				WHEN 59 => CurrentNote <= "00000";
				WHEN 60 => CurrentNote <= "00000";
				WHEN 61 => CurrentNote <= "00000";
				WHEN 62 => CurrentNote <= "00000";
				WHEN 63 => CurrentNote <= "00000";
				WHEN 64 => CurrentNote <= "01100";
				WHEN 65 => CurrentNote <= "00000";
				WHEN 66 => CurrentNote <= "00000";
				WHEN 67 => CurrentNote <= "00000";
				WHEN 68 => CurrentNote <= "01100";
				WHEN 69 => CurrentNote <= "00000";
				WHEN 70 => CurrentNote <= "01010";
				WHEN 71 => CurrentNote <= "00000";
				WHEN 72 => CurrentNote <= "01000";
				WHEN 73 => CurrentNote <= "00000";
				WHEN 74 => CurrentNote <= "00000";
				WHEN 75 => CurrentNote <= "00000";
				WHEN 76 => CurrentNote <= "01001";
				WHEN 77 => CurrentNote <= "00000";
				WHEN 78 => CurrentNote <= "01010";
				WHEN 79 => CurrentNote <= "00000";
				WHEN 80 => CurrentNote <= "01011";
				WHEN 81 => CurrentNote <= "00000";
				WHEN 82 => CurrentNote <= "00000";
				WHEN 83 => CurrentNote <= "00000";
				WHEN 84 => CurrentNote <= "01011";
				WHEN 85 => CurrentNote <= "00000";
				WHEN 86 => CurrentNote <= "01101";
				WHEN 87 => CurrentNote <= "00000";
				WHEN 88 => CurrentNote <= "01011";
				WHEN 89 => CurrentNote <= "00000";
				WHEN 90 => CurrentNote <= "00000";
				WHEN 91 => CurrentNote <= "00000";
				WHEN 92 => CurrentNote <= "01100";
				WHEN 93 => CurrentNote <= "00000";
				WHEN 94 => CurrentNote <= "01101";
				WHEN 95 => CurrentNote <= "00000";
				WHEN 96 => CurrentNote <= "01110";
				WHEN 97 => CurrentNote <= "00000";
				WHEN 98 => CurrentNote <= "00000";
				WHEN 99 => CurrentNote <= "00000";
				WHEN 100 => CurrentNote <= "01110";
				WHEN 101 => CurrentNote <= "00111";
				WHEN 102 => CurrentNote <= "01101";
				WHEN 103 => CurrentNote <= "00000";
				WHEN 104 => CurrentNote <= "01100";
				WHEN 105 => CurrentNote <= "00000";
				WHEN 106 => CurrentNote <= "00000";
				WHEN 107 => CurrentNote <= "00000";
				WHEN 108 => CurrentNote <= "01011";
				WHEN 109 => CurrentNote <= "00000";
				WHEN 110 => CurrentNote <= "00000";
				WHEN 111 => CurrentNote <= "00000";
				WHEN 112 => CurrentNote <= "01101";
				WHEN 113 => CurrentNote <= "00000";
				WHEN 114 => CurrentNote <= "10000";
				WHEN 115 => CurrentNote <= "00000";
				WHEN 116 => CurrentNote <= "10000";
				WHEN 117 => CurrentNote <= "00000";
				WHEN 118 => CurrentNote <= "10000";
				WHEN 119 => CurrentNote <= "00000";
				WHEN 120 => CurrentNote <= "10000";
				WHEN 121 => CurrentNote <= "00000";
				WHEN 122 => CurrentNote <= "10000";
				WHEN 123 => CurrentNote <= "00000";
				WHEN 124 => CurrentNote <= "00000";
				WHEN 125 => CurrentNote <= "00000";
				WHEN 126 => CurrentNote <= "00000";
				WHEN OTHERS => 
			END CASE;
		ELSE
			--elsif Channel = "10" then
			CASE counter IS
				WHEN 127 => CurrentNote <= "00000";
				WHEN 0 => CurrentNote <= "11000";
				WHEN 1 => CurrentNote <= "00000";
				WHEN 2 => CurrentNote <= "10010";
				WHEN 3 => CurrentNote <= "00000";
				WHEN 4 => CurrentNote <= "11000";
				WHEN 5 => CurrentNote <= "00000";
				WHEN 6 => CurrentNote <= "10010";
				WHEN 7 => CurrentNote <= "00000";
				WHEN 8 => CurrentNote <= "11000";
				WHEN 9 => CurrentNote <= "00000";
				WHEN 10 => CurrentNote <= "10010";
				WHEN 11 => CurrentNote <= "00000";
				WHEN 12 => CurrentNote <= "11000";
				WHEN 13 => CurrentNote <= "00000";
				WHEN 14 => CurrentNote <= "10010";
				WHEN 15 => CurrentNote <= "00000";
				WHEN 16 => CurrentNote <= "10110";
				WHEN 17 => CurrentNote <= "00000";
				WHEN 18 => CurrentNote <= "00000";
				WHEN 19 => CurrentNote <= "00000";
				WHEN 20 => CurrentNote <= "10110";
				WHEN 21 => CurrentNote <= "00000";
				WHEN 22 => CurrentNote <= "00000";
				WHEN 23 => CurrentNote <= "00000";
				WHEN 24 => CurrentNote <= "10110";
				WHEN 25 => CurrentNote <= "00000";
				WHEN 26 => CurrentNote <= "00000";
				WHEN 27 => CurrentNote <= "00000";
				WHEN 28 => CurrentNote <= "10110";
				WHEN 29 => CurrentNote <= "00000";
				WHEN 30 => CurrentNote <= "00000";
				WHEN 31 => CurrentNote <= "00000";
				WHEN 32 => CurrentNote <= "10111";
				WHEN 33 => CurrentNote <= "00000";
				WHEN 34 => CurrentNote <= "00000";
				WHEN 35 => CurrentNote <= "00000";
				WHEN 36 => CurrentNote <= "10111";
				WHEN 37 => CurrentNote <= "00000";
				WHEN 38 => CurrentNote <= "00000";
				WHEN 39 => CurrentNote <= "00000";
				WHEN 40 => CurrentNote <= "11000";
				WHEN 41 => CurrentNote <= "00000";
				WHEN 42 => CurrentNote <= "10010";
				WHEN 43 => CurrentNote <= "00000";
				WHEN 44 => CurrentNote <= "11000";
				WHEN 45 => CurrentNote <= "00000";
				WHEN 46 => CurrentNote <= "10010";
				WHEN 47 => CurrentNote <= "00000";
				WHEN 48 => CurrentNote <= "10110";
				WHEN 49 => CurrentNote <= "00000";
				WHEN 50 => CurrentNote <= "00000";
				WHEN 51 => CurrentNote <= "00000";
				WHEN 52 => CurrentNote <= "10110";
				WHEN 53 => CurrentNote <= "00000";
				WHEN 54 => CurrentNote <= "00000";
				WHEN 55 => CurrentNote <= "00000";
				WHEN 56 => CurrentNote <= "10110";
				WHEN 57 => CurrentNote <= "00000";
				WHEN 58 => CurrentNote <= "10110";
				WHEN 59 => CurrentNote <= "00000";
				WHEN 60 => CurrentNote <= "10101";
				WHEN 61 => CurrentNote <= "00000";
				WHEN 62 => CurrentNote <= "10100";
				WHEN 63 => CurrentNote <= "00000";
				WHEN 64 => CurrentNote <= "11011";
				WHEN 65 => CurrentNote <= "00000";
				WHEN 66 => CurrentNote <= "10011";
				WHEN 67 => CurrentNote <= "00000";
				WHEN 68 => CurrentNote <= "11011";
				WHEN 69 => CurrentNote <= "00000";
				WHEN 70 => CurrentNote <= "10011";
				WHEN 71 => CurrentNote <= "00000";
				WHEN 72 => CurrentNote <= "11011";
				WHEN 73 => CurrentNote <= "00000";
				WHEN 74 => CurrentNote <= "10011";
				WHEN 75 => CurrentNote <= "00000";
				WHEN 76 => CurrentNote <= "11011";
				WHEN 77 => CurrentNote <= "00000";
				WHEN 78 => CurrentNote <= "10011";
				WHEN 79 => CurrentNote <= "00000";
				WHEN 80 => CurrentNote <= "11010";
				WHEN 81 => CurrentNote <= "00000";
				WHEN 82 => CurrentNote <= "10100";
				WHEN 83 => CurrentNote <= "00000";
				WHEN 84 => CurrentNote <= "11010";
				WHEN 85 => CurrentNote <= "00000";
				WHEN 86 => CurrentNote <= "10100";
				WHEN 87 => CurrentNote <= "00000";
				WHEN 88 => CurrentNote <= "11010";
				WHEN 89 => CurrentNote <= "00000";
				WHEN 90 => CurrentNote <= "10100";
				WHEN 91 => CurrentNote <= "00000";
				WHEN 92 => CurrentNote <= "11010";
				WHEN 93 => CurrentNote <= "00000";
				WHEN 94 => CurrentNote <= "10100";
				WHEN 95 => CurrentNote <= "00000";
				WHEN 96 => CurrentNote <= "11011";
				WHEN 97 => CurrentNote <= "00000";
				WHEN 98 => CurrentNote <= "10111";
				WHEN 99 => CurrentNote <= "00000";
				WHEN 100 => CurrentNote <= "11011";
				WHEN 101 => CurrentNote <= "00000";
				WHEN 102 => CurrentNote <= "10111";
				WHEN 103 => CurrentNote <= "00000";
				WHEN 104 => CurrentNote <= "11000";
				WHEN 105 => CurrentNote <= "00000";
				WHEN 106 => CurrentNote <= "10010";
				WHEN 107 => CurrentNote <= "00000";
				WHEN 108 => CurrentNote <= "11000";
				WHEN 109 => CurrentNote <= "00000";
				WHEN 110 => CurrentNote <= "10010";
				WHEN 111 => CurrentNote <= "00000";
				WHEN 112 => CurrentNote <= "10110";
				WHEN 113 => CurrentNote <= "00000";
				WHEN 114 => CurrentNote <= "00000";
				WHEN 115 => CurrentNote <= "00000";
				WHEN 116 => CurrentNote <= "10110";
				WHEN 117 => CurrentNote <= "00000";
				WHEN 118 => CurrentNote <= "00000";
				WHEN 119 => CurrentNote <= "00000";
				WHEN 120 => CurrentNote <= "10110";
				WHEN 121 => CurrentNote <= "00000";
				WHEN 122 => CurrentNote <= "00000";
				WHEN 123 => CurrentNote <= "00000";
				WHEN 124 => CurrentNote <= "10110";
				WHEN 125 => CurrentNote <= "00000";
				WHEN 126 => CurrentNote <= "00000";
				WHEN OTHERS => 
			END CASE;
		END IF;
	END PROCESS;

END Behavioral;