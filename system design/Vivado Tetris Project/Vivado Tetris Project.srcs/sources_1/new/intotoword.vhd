library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all; 
entity intotoword is
    Port ( 
    x: in unsigned (10 downto 0);
    y: in unsigned (10 downto 0);
    res: in unsigned (2 downto 0);
    space: in unsigned (3 downto 0);
    size: in unsigned (4 downto 0);
    num: in integer range 0 to 99999;
    color: out std_logic_vector(11 downto 0)
    );
end intotoword;

architecture Behavioral of intotoword is
COMPONENT word_handle IS
		PORT (
        x: in unsigned (10 downto 0);
        y: in unsigned (10 downto 0);
        word: in unsigned (29 downto 0);
        res: in unsigned (2 downto 0);
        space: in unsigned (3 downto 0);
        size: in unsigned (4 downto 0);
        color: out std_logic_vector(11 downto 0)
		);
	END COMPONENT;
	signal word: unsigned(29 downto 0);   
begin
    process (num)
    variable number:integer;
    variable digit:integer;
    begin
    number:=num;
    for i in 0 to 4 loop
    digit:=number mod 10;
    word(25-i*5-1 downto 25-(i+1)*5)<=to_unsigned(digit,5);
    number:= number/10;
    end loop;
    end process;
    whint: word_handle
		PORT MAP(
        x => x,
        y => y,
        word => word,
        res => res,
        space => space,
        size => size,
        color => color
		);
end Behavioral;
