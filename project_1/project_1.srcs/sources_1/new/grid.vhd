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
begin
    address <= shift_right((shift_right(x,5)+5*shift_right(y,5)),0) (7 downto 0);
    color(0)<=color_in(0);
    color(1)<=color_in(0);
    color(2)<=color_in(0);
    color(3)<=color_in(0);
    color(4)<=color_in(1);
    color(5)<=color_in(1);
    color(6)<=color_in(1);
    color(7)<=color_in(1);
    color(8)<=color_in(2);
    color(9)<=color_in(2);
    color(10)<=color_in(2);
    color(11)<=color_in(2);
    

end Behavioral;
