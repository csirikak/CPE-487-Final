LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY ChannelCombiner IS
	PORT (
		-- aud_clk : in std_logic; --48.8khz
		aud_CH1 : IN signed (15 DOWNTO 0);
		aud_CH2 : IN signed (15 DOWNTO 0);
		aud_CH3 : IN signed (15 DOWNTO 0);
		tone : OUT signed (15 DOWNTO 0)
	);
END ChannelCombiner;
ARCHITECTURE Behavioral OF ChannelCombiner IS

BEGIN
	Combine : PROCESS (aud_CH1, aud_CH2, aud_CH3)
		VARIABLE combined : INTEGER;
		VARIABLE result : signed (15 DOWNTO 0);
	BEGIN
		combined := TO_INTEGER(aud_ch1) + TO_INTEGER(aud_ch2) + TO_INTEGER(aud_ch3);
		result := TO_SIGNED(combined, 16);
 
		tone <= result;

	END PROCESS Combine;
END Behavioral;