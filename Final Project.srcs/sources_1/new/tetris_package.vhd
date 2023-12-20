library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

package tetris_package is
	constant  BOARD_COLUMNS    : positive   := 10;
	constant  BOARD_ROWS       : positive   := 20;
	constant  BLOCKS_PER_PIECE : positive   := 4;

	type      shapeType     is (SHAPE_T, SHAPE_SQUARE, SHAPE_STICK, SHAPE_L_L, SHAPE_L_R, SHAPE_ZIGZAG_L, SHAPE_ZIGZAG_R);
	attribute enum_encoding  : string;
	attribute enum_encoding  of shapeType : type is "one-hot";
	
	-- Board declarations
	type board_cell_type is record
		filled       : std_logic;
		shape        : shapeType;
	end record;	

	type board_cell_array is array(natural range <>, natural range <>) of board_cell_type;
	
	type boardType is record
		cells        :  board_cell_array(0 to (BOARD_COLUMNS-1), 0 to (BOARD_ROWS-1));
	end record;

	-- Piece declarations
	type block_pos_type is record
		col         : integer range 0 to (BOARD_COLUMNS-1);
		row         : integer range 0 to (BOARD_ROWS-1);
	end record;
	
	type block_pos_array is array(natural range <>) of block_pos_type;
	
	type pieceType is record
		shape        : shapeType;
		blocks       : block_pos_array(0 to (BLOCKS_PER_PIECE-1));
	end record;

	-- Piece definitions
	constant PIECE_T : pieceType :=
	(
		shape  => SHAPE_T,
		blocks =>
		(
			(col => 1, row => 0),
			(col => 0, row => 0),
			(col => 2, row => 0),
			(col => 1, row => 1)
		)
	);

	constant PIECE_SQUARE : pieceType :=
	(
		shape  => SHAPE_SQUARE,
		blocks =>
		(
			(col => 0, row => 0),
			(col => 1, row => 0),
			(col => 0, row => 1),
			(col => 1, row => 1)
		)
	);	
	
	constant PIECE_STICK : pieceType :=
	(
		shape  => SHAPE_STICK,
		blocks =>
		(
			(col => 0, row => 1),
			(col => 0, row => 0),
			(col => 0, row => 2),
			(col => 0, row => 3)
		)
	);	

	constant PIECE_L : pieceType :=
	(
		shape  => SHAPE_L_L,
		blocks =>
		(
			(col => 1, row => 0),
			(col => 0, row => 0),
			(col => 2, row => 0),
			(col => 0, row => 1)
		)
	);	
	
	constant PIECE_L_R : pieceType :=
	(
		shape  => SHAPE_L_R,
		blocks =>
		(
			(col => 1, row => 0),
			(col => 0, row => 0),
			(col => 2, row => 0),
			(col => 2, row => 1)
		)
	);
	
	constant PIECE_ZIGZAG_L : pieceType :=
	(
		shape  => SHAPE_ZIGZAG_L,
		blocks =>
		(
			(col => 1, row => 0),
			(col => 1, row => 1),
			(col => 2, row => 0),
			(col => 0, row => 1)
		)
	);	
	
	constant PIECE_ZIGZAG_R : pieceType :=
	(
		shape  => SHAPE_ZIGZAG_R,
		blocks =>
		(
			(col => 1, row => 0),
			(col => 1, row => 1),
			(col => 0, row => 0),
			(col => 2, row => 1)
		)
	);	
	
end package;



