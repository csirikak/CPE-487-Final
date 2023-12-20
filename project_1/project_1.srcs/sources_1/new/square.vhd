library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all; 
entity square is
    Port ( 
    x: in unsigned (10 downto 0);
    y: in unsigned (10 downto 0);
    color_in: in std_logic_vector (2 downto 0);
    color_out: out std_logic_vector(11 downto 0)
    );
end square;

architecture Behavioral of square is
    signal colors_in: std_logic_vector(11 downto 0);
    signal color: std_logic_vector(11 downto 0);
begin
    colors_in(3 downto 0)<=(others => color_in(0));
    colors_in(7 downto 4)<=(others => color_in(1));
    colors_in(11 downto 8)<=(others => color_in(2));
    process(x,y)
    variable space : integer:=1;
    variable inner_space : integer:=9;
    begin
    if x<space or x>31-space or y<space or y>31-space then color<=(others => '0');
    else
        if x>=inner_space and x<=31-inner_space and y>=inner_space and y<=31-inner_space then
            color <= colors_in and "111011101110" ;
        elsif  x+y=31 and (x<=inner_space or x>=31-inner_space) then
            color <= colors_in and "111011101110" ;
        elsif  x+31-y=31 and (x<=inner_space or x>=31-inner_space) then
            color <= colors_in and "111011101110" ;
        elsif  x+31-y<31 and x+y<31 then
            color <= colors_in and "111011101110" ;
        elsif  x+31-y>31 and x+y<31 then
            color <= colors_in and "111111111111" ;
        elsif  x+31-y<31 and x+y>31 then
            color <= colors_in and "100010001000" ;
        elsif  x+31-y>31 and x+y>31 then
            color <= colors_in and "110011001100" ;
        end if;
    end if;
    end process;
    color_out<=color;

end Behavioral;
