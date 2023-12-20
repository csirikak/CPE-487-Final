LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all; 


ENTITY GPU IS
	PORT (
		pixel_row: in std_logic_vector(10 downto 0);
		pixel_col: in std_logic_vector(10 downto 0);
		color_in: in std_logic_vector (2 downto 0);
		address: out unsigned (7 downto 0);
		red: out std_logic_vector (3 downto 0);
		green: out std_logic_vector (3 downto 0);
		blue: out std_logic_vector (3 downto 0)
	);
END GPU;

ARCHITECTURE Behavioral OF GPU IS 
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
	COMPONENT grid IS
		PORT (
		x: in unsigned (10 downto 0);
        y: in unsigned (10 downto 0);
        color_in: in std_logic_vector (2 downto 0);
        address: out unsigned (7 downto 0);
        color: out std_logic_vector(11 downto 0)
		);
	END COMPONENT;
    signal x: unsigned (10 downto 0);
    signal y: unsigned (10 downto 0);
    signal output: std_logic_vector (11 downto 0);
    signal output_word: std_logic_vector (11 downto 0);
    signal output_letter: std_logic_vector (11 downto 0);
    signal output_grid: std_logic_vector (11 downto 0);
    signal sel: std_logic_vector (1 downto 0);
    signal word: unsigned (29 downto 0);
    signal x_norm: unsigned(10 downto 0);
    signal y_norm: unsigned(10 downto 0);
    signal res:  unsigned(2 downto 0) ;
    signal space: unsigned(3 downto 0);
    signal size:  unsigned(4 downto 0);
    constant screen_w: integer:=1280;
    constant screen_h: integer:=720;
    constant title_size: integer:=16;
    constant text_size: integer:=8;
    constant title_spacing: integer:=10;
    constant text_spacing_x: integer:=5;
    constant text_spacing_y: integer:=5;
    constant x_right: integer:=930;
    constant x_left: integer:=130;
    constant y_score: integer:=160;
    constant y_next: integer:=320;
BEGIN
    x <= unsigned(pixel_col);
    y <= unsigned(pixel_row);    
	PROCESS (x, y) is
	BEGIN
	    sel<="00";
	    --TETRIS
        if (x>=((screen_w-6*(5*title_size+title_spacing))/2)) and (x<((screen_w+6*(5*title_size+title_spacing))/2)) and (y>=0) and (y<5*title_size) then
        x_norm<=x-((screen_w-6*(5*title_size+title_spacing))/2);
        y_norm<=y;
        word<="100010110010000100100101110010";
        res<="100";
        space<="1010";
        size<="10000";
        sel<= "01";
        --LINES
        elsif (x>=x_left) and (x<(x_left+5*(5*text_size+text_spacing_x))) and (y>=y_score) and (y<y_score+5*text_size) then
        x_norm<=x-x_left;
        y_norm<=y-y_score;
        word<="101011000101011011100110001101";
        res<="011";
        space<="0101";
        size<="01000";
        sel<= "01";
        --LINESNUM
        elsif (x>=x_left) and (x<(x_left+5*(5*text_size+text_spacing_x))) and (y>=y_score+5*text_size+text_spacing_y) and (y<y_score+10*text_size+text_spacing_y) then
        x_norm<=x-x_left;
        y_norm<=y-(y_score+5*text_size+text_spacing_y);
        word<="101010010100100000110001000001";
        res<="011";
        space<="0101";
        size<="01000";
        sel<= "01";
        --LEVEL
        elsif (x>=x_left) and (x<(x_left+5*(5*text_size+text_spacing_x))) and (y>=y_next) and (y<y_next+5*text_size) then
        x_norm<=x-x_left;
        y_norm<=y-y_next;
        word<="101010110101011100110101101101";
        res<="011";
        space<="0101";
        size<="01000";
        sel<= "01";
        --LEVELNUM
        elsif (x>=x_left) and (x<(x_left+5*(5*text_size+text_spacing_x))) and (y>=y_next+5*text_size+text_spacing_y) and (y<y_next+10*text_size+text_spacing_y) then
        x_norm<=x-x_left;
        y_norm<=y-(y_next+5*text_size+text_spacing_y);
        word<="101010010100100000110001000001";
        res<="011";
        space<="0101";
        size<="01000";
        sel<= "01";
        --SCORE
        elsif (x>=x_right) and (x<(x_right+5*(5*text_size+text_spacing_x))) and (y>=y_score) and (y<y_score+5*text_size) then
        x_norm<=x-x_right;
        y_norm<=y-y_score;
        word<="101010101110000011110101010001";
        res<="011";
        space<="0101";
        size<="01000";
        sel<= "01";
        --SCORENUM
        elsif (x>=x_right) and (x<(x_right+5*(5*text_size+text_spacing_x))) and (y>=y_score+5*text_size+text_spacing_y) and (y<y_score+10*text_size+text_spacing_y) then
        x_norm<=x-x_right;
        y_norm<=y-(y_score+5*text_size+text_spacing_y);
        word<="101010000001001010000011100110";
        res<="011";
        space<="0101";
        size<="01000";
        sel<= "01";
        --NEXT
        elsif (x>=950) and (x<(950+4*(5*text_size+text_spacing_x))) and (y>=y_next) and (y<y_next+5*text_size) then
        x_norm<=x-950;
        y_norm<=y-y_next;
        word<="101011010110010101000101101110";
        res<="011";
        space<="0101";
        size<="01000";
        sel<= "01";
        --NEXTFIG
        elsif (x>=976) and (x<(976+4*32)) and (y>=y_next+5*text_size+text_spacing_y) and (y<y_next+5*text_size+text_spacing_y+2*32) then
        x_norm <=x-976;
        y_norm <=y-(y_next+5*text_size+text_spacing_y);
        sel<= "10"; 
        --GRID
        elsif (x>=((screen_w-10*32)/2)) and (x<((screen_w+10*32)/2)) and (y>=5*title_size) and (y<screen_h) then
        x_norm <=x-((screen_w-10*32)/2);
        y_norm <=y-5*title_size;
        sel<= "10"; 
        end if;
	END PROCESS;
	output <= output_word when sel = "01" else
	          output_grid when sel = "10" else
	          "111111111111";
	red <= output(11 downto 8);
	green <= output(7 downto 4);
	blue <= output(3 downto 0);
	wh1: word_handle
		PORT MAP(
        x => x_norm,
        y => y_norm,
        word => word,
        res => res,
        space => space,
        size => size,
        color => output_word
		);
	g1: grid
	PORT MAP(
	x => x_norm,
    y => y_norm,
    color_in => color_in,
    address => address,
    color => output_grid
    );
END Behavioral;