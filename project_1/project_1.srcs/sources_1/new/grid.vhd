library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all; 
entity grid is
    Port ( 
    x: in unsigned (10 downto 0);
    y: in unsigned (10 downto 0);
    color_in: in std_logic_vector (2 downto 0);
    address: out unsigned (7 downto 0);
    color: out std_logic_vector(11 downto 0)
    );
end grid;

architecture Behavioral of grid is
COMPONENT square IS
		PORT (
        x: in unsigned (10 downto 0);
        y: in unsigned (10 downto 0);
        color_in: in std_logic_vector (2 downto 0);
        color_out: out std_logic_vector(11 downto 0)
		);
	END COMPONENT;
	signal x_norm: unsigned (10 downto 0);
	signal y_norm: unsigned (10 downto 0);
begin
    address <= shift_right((shift_right(x,5)+5*shift_right(y,5)),0) (7 downto 0);
    
    x_norm<=shift_right((x-32*shift_right(x,5)),0)(10 downto 0);
    y_norm<=shift_right((y-32*shift_right(y,5)),0)(10 downto 0);
    sq: square
	PORT MAP(
	x => x_norm,
    y => y_norm,
    color_in => color_in,
    color_out => color
    );

end Behavioral;
