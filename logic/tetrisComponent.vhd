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
		led                  : OUT  STD_LOGIC_VECTOR (5 DOWNTO 0);
        addressX, addressY   : IN INTEGER range 0 to 20;
        clk                  : IN  STD_LOGIC;
        leftClick            : IN  STD_LOGIC;
        rightClick           : IN  STD_LOGIC;
        upClick              : IN  STD_LOGIC;
        downClick            : IN  STD_LOGIC;
        centerClick          : IN  STD_LOGIC;
        resetClick           : IN  STD_LOGIC;
        pauseClick           : IN  STD_LOGIC
    );
END tetrisComponent;



ARCHITECTURE BEHAVIORIAL OF tetrisComponent IS
	SIGNAL counter                                                       : unsigned (41 DOWNTO 0);
	SIGNAL gameTick                                                      : STD_LOGIC;
	SIGNAL paused, gameStarted, movedDown                                : BOOLEAN := false;
	SIGNAL score                                                         : INTEGER range 0 to 99999;
	SIGNAL lines, level                                                  : INTEGER range 0 to 99999;
	SIGNAL board                                                         : boardType;
	SIGNAL deleteRow, merge, moveFlag                                    : BOOLEAN := false;
	SIGNAL ROW_INDEX                                                     : INTEGER RANGE 0 TO (BOARD_ROWS - 1);
	SIGNAL activeShape, nextActiveShape, nextShape, nextUserShape        : pieceType := PIECE_ZIGZAG_L;
	SIGNAL needShape                                                     : boolean := true;
	SIGNAL pseudoRandom                                                  : INTEGER RANGE 1 TO 2047 := 1; -- insert pseudorandom seed here
	SIGNAL canMoveDown, canMoveLeft, canMoveRight, canMoveCW, canMoveCCW : STD_LOGIC := '1';
    SIGNAL gameTickRate : integer RANGE 0 to 1000 := 725; -- how long to wait to do a gametick in ms
    SIGNAL gameTickCount : INTEGER range 0 to 1000000  := 0;
    SIGNAL controls : std_logic_vector (4 downto 0) := "00000";
    SIGNAL inGameTick : STD_LOGIC := '0';
	
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
	
	FUNCTION checkRotationCollision (activeShape : pieceType;
        direction : std_logic; -- 0 clockwise, 1 counter-clockwise
        board : boardType) RETURN std_logic IS
        VARIABLE canRotate : std_logic := '1';
        VARIABLE xCenter : INTEGER RANGE -5 TO (BOARD_COLUMNS + 4);
        VARIABLE yCenter : INTEGER RANGE -5 TO (BOARD_ROWS + 4);
        VARIABLE temporaryRotatedShape : pieceType;
        VARIABLE selected_cell : board_cell_type;
    BEGIN
        temporaryRotatedShape := activeShape;
        xCenter := activeShape.blocks(0).col;
        yCenter := activeShape.blocks(0).row;
        IF (direction = '0') THEN
            FOR i IN 1 TO BLOCKS_PER_PIECE - 1 LOOP
                temporaryRotatedShape.blocks(i).row := activeShape.blocks(i).row + activeShape.blocks(i).col - yCenter;
                temporaryRotatedShape.blocks(i).col := activeShape.blocks(i).col - activeShape.blocks(i).row - xCenter;
            END LOOP;
        elsif (direction = '1') THEN
            FOR i IN 1 TO BLOCKS_PER_PIECE - 1 LOOP
                temporaryRotatedShape.blocks(i).row := activeShape.blocks(i).col - activeShape.blocks(i).col - yCenter;
                temporaryRotatedShape.blocks(i).col := activeShape.blocks(i).col + activeShape.blocks(i).row - xCenter;
            END LOOP;
        end if;
        FOR i IN 0 TO BLOCKS_PER_PIECE - 1 LOOP
            selected_cell := board.cells(temporaryRotatedShape.blocks(i).row, temporaryRotatedShape.blocks(i).col);
            IF (selected_cell.filled = '1') THEN
                canRotate := '0';
            elsif (
                temporaryRotatedShape.blocks(i).col < 0
                OR temporaryRotatedShape.blocks(i).col > BOARD_COLUMNS
                OR temporaryRotatedShape.blocks(i).row < 0
                OR temporaryRotatedShape.blocks(i).row > BOARD_ROWS) THEN
                    canRotate := '0';
            END IF;
        END LOOP;
        RETURN canRotate;
    END FUNCTION;
    
begin
    
	clockProcess : PROCESS
	BEGIN
		WAIT UNTIL rising_edge(clk);
		IF (NOT paused) THEN
			counter <= counter + 1;
		END IF;
		if (pauseClick = '1') then
		    paused <= true;
		else
		    paused <= false;
		end if;
		

	END PROCESS;
	
	gameTickToggle : PROCESS(counter(23))
	BEGIN
	    -- IF ((TO_INTEGER(counter) MOD gameTickRate*1000000000) = 0) THEN
		IF (rising_edge(counter(23))) THEN
			gameTick     <= NOT gameTick;
		END IF;
    end process;
    
	gameTickProcess : PROCESS (gameTick, nextUserShape)
		CONSTANT NEW_PIECE_OFFSET : INTEGER   := 3;
		VARIABLE clearRow : INTEGER range 0 to BOARD_ROWS;
		variable filledRow : boolean := true;
	BEGIN
	    if (not gameStarted or resetClick = '1') then
	       gameStarted <= true;
	       needShape <= true;
	       gameTickCount <= 0;
	       
	       for y in 0 to BOARD_ROWS - 1 loop
	           for x in 0 to BOARD_COLUMNS - 1 loop
	                board.cells(x, y).filled <= '0';
	           end loop;
	       end loop;
       elsif (needShape) THEN
            --nextActiveShape <= PIECE_ZIGZAG_L;
            --FOR i IN 0 TO 3 loop
            --    nextActiveShape.blocks(i).col <= nextActiveShape.blocks(i).col + NEW_PIECE_OFFSET;
            --END loop;
            --nextShape <= PIECE_L;
            nextShape <= nextPieceSelection(gameTickCount);
            needShape <= false;
            nextActiveShape <= nextShape;
        elsif (rising_edge(gameTick)) then
            inGameTick <= '1';
            nextActiveShape <= activeShape;
            if (gameTickCount < 1000) then
                gameTickCount <= gameTickCount + 1;
            end if;
            if (canMoveDown = '1') then
               FOR i IN 0 TO BLOCKS_PER_PIECE - 1 LOOP
                   nextActiveShape.blocks(i).row <= nextActiveShape.blocks(i).row + 1;
               end loop;
            else
                if (gameTickCount > 7) then
                    FOR i IN 0 TO BLOCKS_PER_PIECE - 1 LOOP
                        board.cells(activeShape.blocks(i).col, activeShape.blocks(i).row).filled <= '1';
                        board.cells(activeShape.blocks(i).col, activeShape.blocks(i).row).shape  <= activeShape.shape;
                    END LOOP;
                    needShape <= true;
                end if;
            end if;
            inGameTick <= '0';
        end if;
	END PROCESS;
	
	processMovement : PROCESS
	       variable lastNextActiveShape : pieceType;
	       variable lastNextUserShape : pieceType;
	       variable temporaryShape : pieceType;
	   begin
	   if (gameTickCount > 2) then
	       temporaryShape := activeShape;
	       wait for 100000ns;
	       --wait until inGameTick = '0';
           if (lastNextActiveShape /= nextActiveShape) then
               lastNextActiveShape := nextActiveShape;
               temporaryShape := nextActiveShape;
           elsif (nextUserShape /= activeShape) then
               temporaryShape := nextUserShape;
               lastNextActiveShape := nextUserShape;
           end if;
           wait for 100000ns;
           activeShape <= temporaryShape;
       end if;
     end process;
     
     processUserMovement : PROCESS (controls, activeShape)
	       variable lastControls : std_logic_vector (4 downto 0);
	       variable temporaryShape : pieceType;
	       VARIABLE pivot : block_pos_type;  
	   begin
	   if (gameTickCount > 2) then
	       temporaryShape := activeShape;
            pivot := activeShape.blocks(0);
            FOR i IN 0 TO BLOCKS_PER_PIECE - 1 LOOP
                IF (controls(4) = '1') THEN
                    temporaryShape.blocks(i).row := activeShape.blocks(i).row + 1;
                ELSIF (controls(3) = '1') THEN
                    canMoveCCW <= checkRotationCollision(activeShape, '1', board);
                    IF (i /= 0 and canMoveCCW = '1') THEN -- the pivot does not require any transformation
                        temporaryShape.blocks(i).col :=
                        pivot.col - (activeShape.blocks(i).row - pivot.row);
    
                        temporaryShape.blocks(i).row :=
                        pivot.row + (activeShape.blocks(i).col - pivot.col);
                    END IF;
                ELSIF (controls(3) = '1') THEN
                    canMoveCW <= checkRotationCollision(activeShape, '0', board);
                    IF (i /= 0 and canMoveCCW = '1') THEN -- the pivot does not require any transformation
                        temporaryShape.blocks(i).col :=
                        pivot.col + (activeShape.blocks(i).row - pivot.row);
                        temporaryShape.blocks(i).row :=
                        pivot.row - (activeShape.blocks(i).col - pivot.col);
                    END IF;
                ELSIF (controls(0) = '1') THEN
                    temporaryShape.blocks(i).col := activeShape.blocks(i).col - 1;
    
                ELSIF (controls(1) = '1') THEN
                    temporaryShape.blocks(i).col := activeShape.blocks(i).col + 1;
                END IF;
            END LOOP;
           lastControls := controls;
           nextUserShape <= temporaryShape;
       end if;
     end process;

	processControls : process (leftClick, rightClick, upClick, downClick, centerClick)
	   variable output : std_logic_vector(4 downto 0) := "00000";
	begin
	   output := "00000";
	   if (rising_edge(leftClick)) then
	       output := "00001";
	   end if;
	   if (rising_edge(rightClick)) then
	       output := "00010";
	   end if;
	   if (rising_edge(upClick)) then
	       output := "00100";
	   end if;
	   if (rising_edge(downClick)) then
	       output := "01000";
	   end if;
	   if (rising_edge(centerClick)) then
	       output := "10000";
	   end if;
	   controls <= output;
	   if output /= "00000" then
	       led <= output & '0';
	   end if;
	end process;
	/*
	processControls : process (leftClick, rightClick, upClick, downClick, centerClick)
	   variable outputToggled : std_logic_vector (4 downto 0 ) := "00000";
	begin
	   if (leftClick = '1' and outputToggled(0) = '0') then
	       controls(0) <= leftClick;
	       outputToggled(0) := '1';
	   elsif (leftClick = '1' and outputToggled(0) = '1') then
	       controls(0) <= '0';
	       outputToggled(0) := '1';
	   elsif (leftClick = '0' and outputToggled(0) = '1') then
	       outputToggled(1) := '1';
	   end if;
	   led(0) <= controls(0);
    end process;
    */
           
	checkCollision : PROCESS (activeShape, board, nextActiveShape, gameTick)
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
   
    
	processBoardOutput : PROCESS (board, addressX, addressY)
		VARIABLE selected_cell   : board_cell_type;
		VARIABLE activeShapeCell : block_pos_type;
	BEGIN
		activeShapeCell.col := addressX;
		activeShapeCell.row := addressY;
		selected_cell       := board.cells(addressX, addressY);
		IF (selected_cell.filled = '1') THEN
			gridOut <= lookupColor(selected_cell.shape);
			--gridOut <= "100";    
		ELSE
			gridOut <= "000";
		END IF;
		FOR i IN 0 TO BLOCKS_PER_PIECE - 1 LOOP
			IF (activeShape.blocks(i) = activeShapeCell) THEN
				gridOut <= lookupColor(activeShape.shape);
			END IF;
		END LOOP;
	END PROCESS;
	
end architecture;
