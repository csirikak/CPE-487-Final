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
	SIGNAL counter                                                       : unsigned (41 DOWNTO 0);
	SIGNAL gameTick                                                      : STD_LOGIC;
	SIGNAL paused                                                        : BOOLEAN := false;
	SIGNAL score                                                         : UNSIGNED (15 DOWNTO 0);
	SIGNAL lines, level                                                  : UNSIGNED (5 DOWNTO 0);
	SIGNAL board                                                         : boardType;
	SIGNAL deleteRow, merge                                              : BOOLEAN := false;
	SIGNAL ROW_INDEX                                                     : INTEGER RANGE 0 TO (BOARD_ROWS - 1);
	SIGNAL activeShape, nextActiveShape, nextShape                       : pieceType;
	SIGNAL needShape                                                     : STD_LOGIC;
	SIGNAL pseudoRandom                                                  : INTEGER RANGE 1 TO 2047 := 1; -- insert pseudorandom seed here
	SIGNAL canMoveDown, canMoveLeft, canMoveRight, canMoveCW, canMoveCCW : STD_LOGIC;
	TYPE affectedByMergeType IS ARRAY(NATURAL RANGE <>, NATURAL RANGE <>) OF STD_LOGIC;
	SIGNAL cellAffectedByMerge                       : affectedByMergeType(0 TO BOARD_COLUMNS - 1, 0 TO BOARD_ROWS - 1);

	FUNCTION nextPieceSelection (SIGNAL pseudoRandom : INTEGER RANGE 1 TO 2047)
		RETURN pieceType IS
	BEGIN
		CASE (pseudoRandom MOD 7) IS
			WHEN 0 =>
				RETURN PIECE_T;
			WHEN 1 =>
				RETURN PIECE_SQUARE;
			WHEN 2 =>
				RETURN PIECE_STICK;
			WHEN 3 =>
				RETURN PIECE_L;
			WHEN 4 =>
				RETURN PIECE_L_R;
			WHEN 5 =>
				RETURN PIECE_ZIGZAG_L;
			WHEN 6 =>
				RETURN PIECE_ZIGZAG_R;
			WHEN OTHERS =>
				RETURN PIECE_T;
		END CASE;
	END FUNCTION;

	FUNCTION lookupColor (shape : shapeType)
		RETURN STD_LOGIC_VECTOR IS
		VARIABLE color : STD_LOGIC_VECTOR (2 DOWNTO 0);
	BEGIN
		CASE (shape) IS
			WHEN SHAPE_T =>
				color := "110";
			WHEN SHAPE_SQUARE =>
				color := "100";
			WHEN SHAPE_STICK =>
				color := "001";
			WHEN SHAPE_L_L | SHAPE_L_R =>
				color := "011";
			WHEN SHAPE_ZIGZAG_L | SHAPE_ZIGZAG_R =>
				color := "010";
		END CASE;
		RETURN color;
	END FUNCTION;

BEGIN

	clockProcess : PROCESS
	BEGIN
		WAIT UNTIL rising_edge(clk);
		IF (NOT paused) THEN
			counter <= counter + 1;
		END IF;
	END PROCESS;

	gameTickProcess : PROCESS (counter)
	BEGIN
		IF ((counter MOD 10000000) = 0) AND NOT paused THEN
			pseudoRandom <= (3 * pseudoRandom + 5) MOD 7;
			gameTick     <= NOT gameTick;
		END IF;
	END PROCESS;

	moveActiveShape : PROCESS (gameTick, resetClick)
		CONSTANT PIECE_AT_RESET   : pieceType := PIECE_SQUARE;
		CONSTANT NEW_PIECE_OFFSET : INTEGER   := BOARD_COLUMNS/2 - 2;
		VARIABLE temporaryPiece   : pieceType;
	BEGIN
		IF (resetClick = '1') THEN
			activeShape     <= PIECE_AT_RESET;
			nextActiveShape <= PIECE_AT_RESET;
		ELSIF (rising_edge(gameTick)) THEN

			IF (needShape = '1') THEN
				nextActiveShape <= nextShape;
				temporaryPiece := nextActiveShape;
				FOR i IN 0 TO BLOCKS_PER_PIECE - 1 LOOP
					nextActiveShape.blocks(i).col <= temporaryPiece.blocks(i).col + NEW_PIECE_OFFSET;
				END LOOP;
				nextShape <= nextPieceSelection(pseudoRandom);
			ELSE
				activeShape <= nextActiveShape;
			END IF;
		END IF;
	END PROCESS;

	processActiveShapeOnUserInput : PROCESS (activeShape, centerClick, leftClick, rightClick, upClick, downClick)
		VARIABLE pivot : block_pos_type;
	BEGIN
		activeShape <= nextActiveShape;
		pivot := activeShape.blocks(0);

		FOR i IN 0 TO BLOCKS_PER_PIECE - 1 LOOP
			IF (centerClick = '1') THEN
				nextActiveShape.blocks(i).row <= activeShape.blocks(i).row + 1;

			ELSIF (downClick = '1') THEN
				IF (i /= 0) THEN -- the pivot does not require any transformation
					nextActiveShape.blocks(i).col <=
					pivot.col - (activeShape.blocks(i).row - pivot.row);

					nextActiveShape.blocks(i).row <=
					pivot.row + (activeShape.blocks(i).col - pivot.col);
				END IF;
			ELSIF (upClick = '1') THEN
				IF (i /= 0) THEN -- the pivot does not require any transformation
					nextActiveShape.blocks(i).col <=
					pivot.col - (activeShape.blocks(i).row - pivot.row);

					nextActiveShape.blocks(i).row <=
					pivot.row + (activeShape.blocks(i).col - pivot.col);
				END IF;
			ELSIF (leftClick = '1') THEN
				nextActiveShape.blocks(i).col <= activeShape.blocks(i).col - 1;

			ELSIF (rightClick = '1') THEN
				nextActiveShape.blocks(i).col <= activeShape.blocks(i).col + 1;
			END IF;
		END LOOP;
	END PROCESS;

	checkCollision : PROCESS (activeShape, board)
		VARIABLE currentBlock       : block_pos_type;
		VARIABLE left_cell_filled   : STD_LOGIC;
		VARIABLE right_cell_filled  : STD_LOGIC;
		VARIABLE bottom_cell_filled : STD_LOGIC;
	BEGIN
		canMoveLeft  <= '1';
		canMoveRight <= '1';
		canMoveDown  <= '1';
		FOR i IN 0 TO BLOCKS_PER_PIECE - 1 LOOP
			currentBlock := activeShape.blocks(i);

			IF (currentBlock.col = 0) THEN
				canMoveLeft <= '0';
			ELSE
				left_cell_filled := board.cells((currentBlock.col - 1), currentBlock.row).filled;
				IF (left_cell_filled = '1') THEN
					canMoveLeft <= '0';
				END IF;
			END IF;

			IF (currentBlock.col = (BOARD_COLUMNS - 1)) THEN
				canMoveRight <= '0';
			ELSE
				right_cell_filled := board.cells((currentBlock.col + 1), currentBlock.row).filled;
				IF (right_cell_filled = '1') THEN
					canMoveRight <= '0';
				END IF;
			END IF;

			IF (currentBlock.row = (BOARD_ROWS - 1)) THEN
				canMoveDown <= '0';
			ELSE
				bottom_cell_filled := board.cells(currentBlock.col, (currentBlock.row + 1)).filled;
				IF (bottom_cell_filled = '1') THEN
					canMoveDown <= '0';
				END IF;
			END IF;
		END LOOP;
	END PROCESS;

	checkRotationCollision : PROCESS (activeShape, board)
		VARIABLE currentBlock          : block_pos_type;
		VARIABLE temporaryRotatedShape : pieceType;
	BEGIN
		temporaryRotatedShape := activeShape;
		canMoveCW  <= '1';
		canMoveCCW <= '1';
		FOR i IN 0 TO BLOCKS_PER_PIECE - 1 LOOP
		END LOOP;
	END PROCESS;

	gameBoardUpdate : PROCESS (gameTick, resetClick)
	BEGIN
		IF (resetClick = '1') THEN
			FOR col IN 0 TO BOARD_COLUMNS - 1 LOOP
				FOR row IN 0 TO BOARD_ROWS - 1 LOOP
					board.cells(col, row).filled <= '0';
				END LOOP;
			END LOOP;

		ELSIF (rising_edge(gameTick)) THEN

			FOR col IN 0 TO BOARD_COLUMNS - 1 LOOP
				FOR row IN 0 TO BOARD_ROWS - 1 LOOP

					IF (deleteRow) THEN
						IF (row = 0) THEN
							board.cells(col, row).filled <= '0';
						ELSIF (row                   <= ROW_INDEX) THEN
							board.cells(col, row)        <= board.cells(col, row - 1);
						END IF;

					ELSIF (merge) THEN
						IF (cellAffectedByMerge(col, row) = '1') THEN
							board.cells(col, row).filled <= '1';
							board.cells(col, row).shape  <= activeShape.shape;
						END IF;

					END IF;

				END LOOP;
			END LOOP;

		END IF;
	END PROCESS;
	computeCellAffectedByMerge : PROCESS (board, activeShape)
	BEGIN
		cellAffectedByMerge <= ((OTHERS => (OTHERS => '0')));

		FOR i IN 0 TO BLOCKS_PER_PIECE - 1 LOOP
			cellAffectedByMerge(
			activeShape.blocks(i).col,
			activeShape.blocks(i).row
			) <= '1';
		END LOOP;

	END PROCESS;

	findCompletedRows : PROCESS (board)
		VARIABLE ROW_IS_COMPLETE : BOOLEAN := true;
	BEGIN
		FOR y IN 0 TO (BOARD_ROWS - 1) LOOP
			FOR x IN 0 TO (BOARD_COLUMNS - 1) LOOP
				IF (board.cells(x, y).filled = '0') THEN
					ROW_IS_COMPLETE := false;
				END IF;
			END LOOP;
			IF (ROW_IS_COMPLETE) THEN
				ROW_INDEX <= y;
				deleteRow <= true;
				lines     <= lines + 1;
			END IF;
		END LOOP;
	END PROCESS;

	processBoardOutput : PROCESS (board, activeShape, gridAddress)
		VARIABLE selected_cell   : board_cell_type;
		VARIABLE activeShapeCell : block_pos_type;
	BEGIN
		activeShapeCell.col := TO_INTEGER(gridAddress) MOD BOARD_ROWS;
		activeShapeCell.row := TO_INTEGER(gridAddress)/BOARD_ROWS;
		selected_cell       := board.cells(TO_INTEGER(gridAddress) MOD BOARD_ROWS, TO_INTEGER(gridAddress)/BOARD_ROWS);
		IF (selected_cell.filled = '1') THEN
			gridOut <= lookupColor(selected_cell.shape);
		ELSE
			gridOut <= "000";
		END IF;
		FOR i IN 0 TO BLOCKS_PER_PIECE - 1 LOOP
			IF (activeShape.blocks(i) = activeShapeCell) THEN
				gridOut <= lookupColor(activeShape.shape);
			END IF;
		END LOOP;
	END PROCESS;

	processNextShapeOutput : PROCESS (nextShape, nextShapeGridAddress)
		VARIABLE currentCell : block_pos_type;
	BEGIN
		currentCell.col := TO_INTEGER(gridAddress) MOD 3;
		currentCell.row := TO_INTEGER(gridAddress)/3;
		gridOut <= "000";
		FOR i IN 0 TO BLOCKS_PER_PIECE - 1 LOOP
			IF (nextShape.blocks(i) = currentCell) THEN
				gridOut <= lookupColor(nextShape.shape);
			END IF;
		END LOOP;
	END PROCESS;

END ARCHITECTURE;