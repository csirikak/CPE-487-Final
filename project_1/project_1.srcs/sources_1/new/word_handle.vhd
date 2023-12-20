library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all; 
entity word_handle is
  Port ( 
    clock: in std_logic;
    x: in unsigned (10 downto 0);
    y: in unsigned (10 downto 0);
    word: in unsigned (29 downto 0);
    res: in integer;
    space: in integer;
    size: in integer ;
    color: out std_logic_vector(11 downto 0)
    );
end word_handle;

architecture Behavioral of word_handle is
    COMPONENT alphabet IS
		PORT (
		clock: in std_logic;
	    rom_enable: in std_logic;
		x: in unsigned (10 downto 0);
		y: in unsigned (10 downto 0);
		char: in unsigned (4 downto 0); 
		res: in integer;
		size: in integer;
		output: out std_logic_vector (11 downto 0)
		);
	END COMPONENT;
    signal x_norm: unsigned (10 downto 0);
    signal char: unsigned (4 downto 0);
    signal rom_enable: std_logic;

begin
    sel: process(x,y)
    begin
    if (x>=0) and (x<5*size+space)  then
        x_norm<=x;
        char<=word(4 downto 0);
    elsif (x>=5*size+space) and (x<2*(5*size+space)) then
        x_norm<=resize(x-5*size-space,11);
        char<=word(9 downto 5);
    elsif (x>=2*(5*size+space)) and (x<3*(5*size+space)) then
        x_norm<=resize(x-2*(5*size+space),11);
        char<=word(14 downto 10);
    elsif (x>=3*(5*size+space)) and (x<4*(5*size+space)) then
        x_norm<=resize(x-3*(5*size+space),11);
        char<=word(19 downto 15);
    elsif (x>=4*(5*size+space)) and (x<5*(5*size+space)) then
        x_norm<=resize(x-4*(5*size+space),11);
        char<=word(24 downto 20);
    elsif (x>=5*(5*size+space)) and (x<6*(5*size+space)) then
        x_norm<=resize(x-5*(5*res+space),11);
        char<=word(29 downto 25);
    end if;
    end process;
    letter: alphabet
    PORT MAP(
		clock =>clock,
	    rom_enable => '1',
		x => x_norm,
		y =>y,
		char=> char, 
		res => res,
		size => size,
		output => color
		);
end Behavioral;
