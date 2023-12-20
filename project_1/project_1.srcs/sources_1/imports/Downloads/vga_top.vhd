LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all; 

ENTITY vga_top IS
    PORT (
        clk_in    : IN STD_LOGIC;
        leftClickButton: IN STD_LOGIC;
        rightClickButton: IN STD_LOGIC;
        upClickButton: IN STD_LOGIC;
        downClickButton: IN STD_LOGIC;
        centerClickButton: IN STD_LOGIC;
        resetClickButton: IN STD_LOGIC;
        pauseClickButton: IN STD_LOGIC;
        vga_red   : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        vga_green : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        vga_blue  : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        vga_hsync : OUT STD_LOGIC;
        vga_vsync : OUT STD_LOGIC;
        dac_MCLK : OUT STD_LOGIC; -- outputs to PMODI2L DAC
		dac_LRCK : OUT STD_LOGIC;
		dac_SCLK : OUT STD_LOGIC;
		dac_SDIN : OUT STD_LOGIC

    );
END vga_top;

    ARCHITECTURE Behavioral OF vga_top IS
    SIGNAL pxl_clk : STD_LOGIC;
    -- internal signals to connect modules
    SIGNAL S_red, S_green, S_blue : STD_LOGIC_vector (3 downto 0);
    SIGNAL S_vsync : STD_LOGIC;
    SIGNAL S_pixel_row, S_pixel_col : STD_LOGIC_VECTOR (10 DOWNTO 0);
    SIGNAL grid_S             :  STD_LOGIC_VECTOR (2 DOWNTO 0);
    SIGNAL nextShapeGrid_S        :  UNSIGNED (7 DOWNTO 0);
	SIGNAL nextShapeGridAddress_S :   UNSIGNED (2 DOWNTO 0);
	SIGNAL score_S             :  UNSIGNED (10 DOWNTO 0);
	SIGNAL lines_S             :  UNSIGNED (5 DOWNTO 0);
	SIGNAL level_S             :  UNSIGNED (5 DOWNTO 0);
	SIGNAL gridAddress_S          :  UNSIGNED (7 DOWNTO 0);
    COMPONENT TetrisMusic IS
	PORT (
		clk_in : IN STD_LOGIC;
		dac_MCLK : OUT STD_LOGIC; -- outputs to PMODI2L DAC
		dac_LRCK : OUT STD_LOGIC;
		dac_SCLK : OUT STD_LOGIC;
		dac_SDIN : OUT STD_LOGIC
	);
    END COMPONENT;
    COMPONENT GPU IS
        PORT (
        pixel_row: in std_logic_vector(10 downto 0);
		pixel_col: in std_logic_vector(10 downto 0);
		color_in: in std_logic_vector (2 downto 0);
		address: out unsigned (7 downto 0);
		red: out std_logic_vector (3 downto 0);
		green: out std_logic_vector (3 downto 0);
		blue: out std_logic_vector (3 downto 0)		
        );
    END COMPONENT;
    COMPONENT vga_sync IS
        PORT (
            pixel_clk : IN STD_LOGIC;
            red_in    : IN STD_LOGIC_vector (3 downto 0);
            green_in  : IN STD_LOGIC_vector (3 downto 0);
            blue_in   : IN STD_LOGIC_vector (3 downto 0);
            red_out   : OUT STD_LOGIC_vector (3 downto 0);
            green_out : OUT STD_LOGIC_vector (3 downto 0);
            blue_out  : OUT STD_LOGIC_vector (3 downto 0);
            hsync     : OUT STD_LOGIC;
            vsync     : OUT STD_LOGIC;
            pixel_row : OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
            pixel_col : OUT STD_LOGIC_VECTOR (10 DOWNTO 0)
        );
    END COMPONENT;
    
    component clk_wiz_0 is
    port (
      clk_in1  : in std_logic;
      clk_out1 : out std_logic
    );
    end component;
    
    component tetrisComponent is
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
	end component;
    
    
BEGIN
    -- vga_driver only drives MSB of red, green & blue
    -- so set other bits to zero
    music: TetrisMusic
	PORT MAP (
		clk_in => clk_in,
		dac_MCLK =>dac_MCLK, -- outputs to PMODI2L DAC
		dac_LRCK => dac_LRCK,
		dac_SCLK => dac_SCLK,
		dac_SDIN => dac_SDIN
	);
    my_gpu : GPU
    PORT MAP(
        pixel_row => S_pixel_row,
        pixel_col => S_pixel_col,
        color_in =>grid_s,
        address =>gridAddress_S,
        red => S_red,
        green => S_green,
        blue => S_blue
    );
    

    vga_driver : vga_sync
    PORT MAP(
        --instantiate vga_sync component
        pixel_clk => pxl_clk, 
        red_in    => S_red, 
        green_in  => S_green, 
        blue_in   => S_blue, 
        red_out   => vga_red, 
        green_out => vga_green, 
        blue_out  => vga_blue, 
        pixel_row => S_pixel_row, 
        pixel_col => S_pixel_col, 
        hsync     => vga_hsync, 
        vsync     => S_vsync
    );
    vga_vsync <= S_vsync; --connect output vsync
        
    clk_wiz_0_inst : clk_wiz_0
    port map (
      clk_in1 => clk_in,
      clk_out1 => pxl_clk
    );
    
    tetrisGame : tetrisComponent
    port map (
        gridOut => grid_S,
        nextShapeGrid => nextShapeGrid_S,
        nextShapeGridAddress => nextShapeGridAddress_S,
        scoreOut => score_S,
        linesOut => lines_S,
        levelOut => level_S,
        gridAddress => gridAddress_S,
        clk => clk_in,
        leftClick => leftClickButton, 
        rightClick => rightClickButton,
        upClick => upClickButton,
        downClick => downClickButton,
        centerClick => centerClickButton,
        resetClick => resetClickButton,
        pauseClick => pauseClickButton
    );
   
END Behavioral;