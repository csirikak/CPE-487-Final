LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.tetris_package.ALL;

ENTITY tetrisComponent IS
    PORT (
        gridOut              : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
        nextShapeGrid        : OUT UNSIGNED (7 DOWNTO 0);
        nextShapeGridAddress : IN  UNSIGNED (2 DOWNTO 0);
        scoreOut             : OUT UNSIGNED (10 DOWNTO 0);
        linesOut             : OUT UNSIGNED (5 DOWNTO 0);
        levelOut             : OUT UNSIGNED (5 DOWNTO 0);
        gridAddress          : IN  UNSIGNED (7 DOWNTO 0);
        clk                  : IN  STD_LOGIC;
        leftClick            : IN  STD_LOGIC;
        rightClick           : IN  STD_LOGIC;
        upClick              : IN  STD_LOGIC;
        downClick            : IN  STD_LOGIC;
        centerClick          : IN  STD_LOGIC;
        resetClick           : IN  STD_LOGIC;
        pauseClick           : IN  STD_LOGIC
    );
END ENTITY;

ARCHITECTURE BEHAVIORIAL OF tetrisComponent IS
begin
clockProcess : PROCESS(gridAddress)
    BEGIN
        case ((gridAddress(0)))is
        when '0' =>
            gridOut <= "001";
        when '1' =>
            gridOut <= "010";
        END case;
    END PROCESS;
end architecture;
