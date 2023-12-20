LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all; 


ENTITY GPU IS
	PORT (
	    clock: in std_logic;
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
		clock: in std_logic;
        x: in unsigned (10 downto 0);
        y: in unsigned (10 downto 0);
        word: in unsigned (29 downto 0);
        res: in integer;
        space: in integer ;
        size: in integer;
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
    signal x: unsigned (10 downto 0);
    signal y: unsigned (10 downto 0);
    signal output: std_logic_vector (11 downto 0);
    signal output_word: std_logic_vector (11 downto 0);
    signal output_grid: std_logic_vector (11 downto 0);
    signal sel: std_logic_vector (1 downto 0);
    signal word: unsigned (29 downto 0);
    signal x_norm: unsigned(10 downto 0);
    signal y_norm: unsigned(10 downto 0);
    signal res:  integer ;
    signal size:  integer;
    signal space: integer;
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
        sel<= "11";
        --LINES
        elsif (x>=x_left) and (x<(x_left+5*(5*text_size+text_spacing_x))) and (y>=y_score) and (y<y_score+5*text_size) then
        sel<="11";
        --LINESNUM
        elsif (x>=x_left) and (x<(x_left+5*(5*text_size+text_spacing_x))) and (y>=y_score+5*text_size+text_spacing_y) and (y<y_score+10*text_size+text_spacing_y) then
        sel<="11";
        --LEVEL
        elsif (x>=x_left) and (x<(x_left+5*(5*text_size+text_spacing_x))) and (y>=y_next) and (y<y_next+5*text_size) then
        sel<="11";
        --LEVELNUM
        elsif (x>=x_left) and (x<(x_left+5*(5*text_size+text_spacing_x))) and (y>=y_next+5*text_size+text_spacing_y) and (y<y_next+10*text_size+text_spacing_y) then
        sel<="11";
        --SCORE
        elsif (x>=x_right) and (x<(x_right+5*(5*text_size+text_spacing_x))) and (y>=y_score) and (y<y_score+5*text_size) then
        sel<="11";
        --SCORENUM
        elsif (x>=x_right) and (x<(x_right+5*(5*text_size+text_spacing_x))) and (y>=y_score+5*text_size+text_spacing_y) and (y<y_score+10*text_size+text_spacing_y) then
        sel<="11";
        --NEXT
        elsif (x>=950) and (x<(950+4*(5*text_size+text_spacing_x))) and (y>=y_next) and (y<y_next+5*text_size) then
        sel<="11";
        --NEXTFIG
        elsif (x>=976) and (x<(976+4*32)) and (y>=y_next+5*text_size+text_spacing_y) and (y<y_next+5*text_size+text_spacing_y+2*32) then
        sel<="11";
        --TESTletter
        elsif (x>=0) and (x<(6*5*16+10)) and (y>=0) and (y<5*16) then
        x_norm<=x;
        y_norm<=y;
        res <=4;
        space <=10;
        size <=16;
        sel<="01";
        --GRID
        elsif (x>=((screen_w-10*32)/2)) and (x<((screen_w+10*32)/2)) and (y>=5*title_size) and (y<screen_h) then
        x_norm <=x-((screen_w-10*32)/2);
        y_norm <=y-5*title_size;
        sel<= "10"; 
        end if;
	END PROCESS;
    wh1: word_handle
		PORT MAP(
		clock =>clock,
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
	output <= output_word when sel = "01" else
	          output_grid when sel = "10" else
	          "110001000100" when sel = "11" else
	          "111111111111";
	red <= output(11 downto 8);
	green <= output(7 downto 4);
	blue <= output(3 downto 0);
	
END Behavioral;