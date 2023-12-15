LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
entity tetrisComponent is
    port(
        gridOut : OUT STD_LOGIC_VECTOR (599 DOWNTO 0);
        nextShapeGrid : OUT STD_LOGIC_VECTOR (29 DOWNTO 0);
        scoreOut : OUT UNSIGNED (10 DOWNTO 0);
        linesOut : OUT UNSIGNED (5 DOWNTO 0);
        levelOut : OUT UNSIGNED (5 DOWNTO 0);
        clk : IN STD_LOGIC;
        leftClick : IN STD_LOGIC;
        rightClick : IN STD_LOGIC;
        upClick : IN STD_LOGIC;
        downClick : IN STD_LOGIC;
        centerClick : IN STD_LOGIC;
        resetClick : IN STD_LOGIC;
        pauseClick : IN STD_LOGIC
    )
end tetrisComponent;
architecture BEHAVIORIAL of tetrisComponent is
    SIGNAL counter : UNSIGNED (31 DOWNTO 0);
    SIGNAL gameTick, paused : STD_LOGIC;
    SIGNAL score : UNSIGNED (15 DOWNTO 0);
    SIGNAL lines, level : UNSIGNED (5 DOWNTO 0);
    SIGNAL grid : STD_LOGIC_VECTOR (599 DOWNTO 0);
    SIGNAL activeShape : STD_LOGIC_VECTOR (27 DOWNTO 0);
    SIGNAL nextShape, nextColor : STD_LOGIC_VECTOR (2 DOWNTO 0);
    SIGNAL needShape : STD_LOGIC;
    SIGNAL pseudoRandom : UNSIGNED (5 DOWNTO 0) := to_unsigned(1, 5); -- insert pseudorandom seed here
    SIGNAL activeShapeLocationX, activeShapeLocationY : INTEGER range -5 to 25;
    --rotation performed by translating x_1 to y_1..x_n to y_n where x_n is the nth row and y_n is the nth col.
    CONSTANT shapes : STD_LOGIC_VECTOR (55 DOWNTO 0) := "";
    --if a shape is inside an exising block go up.

    clockProcess : PROCESS(clk, counter) is
    begin
        WAIT UNTIL rising_edge(clk);
        if (not paused) then
            counter <= counter + 1;
        end if;
    END PROCESS;

    nextShapeSelection : PROCESS(needShape) is --generate pseudorandom for now for next shape selection;
    begin
        WAIT UNTIL rising_edge(needShape);
        pseudoRandom <= pseudoRandom + (pseudoRandom mod 4);
        nextShape <= (pseudoRandom mod 7);
        nextColor <= (pseudoRandom mod 6) + 1;
        needShape <= '0';
    END PROCESS;

    nextShapeToGrid : PROCESS(nextShape) is -- applies the next shape to the output grid
    begin
        nextShapeGrid <= shapes((7+8*nextShape) DOWNTO (0+8*nextShape)) & nextColor; 
    END PROCESS;
    
    pure function checkCollision (
        inputGrid : STD_LOGIC_VECTOR (24 DOWNTO 0);
        collisionGrid : STD_LOGIC_VECTOR (24 DOWNTO 0))
        return boolean is;
        begin
            return (inputGrid and collisionGrid) /= '0'; -- checks to see if bitwise and operation results in 1
    end function;

    function rotateShape (
        activeShape : STD_LOGIC_VECTOR (27 DOWNTO 0);
        rotationDirection : INTEGER range -1 to 1) -- 1 cw, -1 ccw
        return STD_LOGIC_VECTOR is
        signal rotatedActiveShape : STD_LOGIC_VECTOR (27 DOWNTO 0);
        begin
            if rotationDirection = 0 then
                return activeShape;
            else
                for x in 0 to 4 loop
                    for y in 0 to 4 loop
                        if rotationDirection = 1 then
                            rotatedActiveShape(x+y*5) <= activeShape((20-x*5)+y); -- clockwise rotation of 5x5 grid 
                        elsif rotationDirection = -1 then
                            rotatedActiveShape(x+y*5) <= activeShape((x*5)+(4-y)); -- counter-clockwise rotation of 5x5 grid 
                        end if;
                    end loop;
                end loop;
            end if;
            rotatedActiveShape <= activeShape (27 DOWNTO 25) & rotatedActiveShape (24 DOWNTO 0);
            return rotatedActiveShape;
    end function;

    function returnCollisionGrid (
        locationX, locationY : INTEGER range -5 to 25;
        rotationDirection : INTEGER range -1 to 1)
        return STD_LOGIC_VECTOR is 
        signal collisionGrid : STD_LOGIC_VECTOR (24 DOWNTO 0);
        begin
            for x in locationX to (locationX + 4) loop
                for y in locationY to (locationY + 4) loop
                    if (x >= 0 and y >= 0 and x <= 9 and y <= 19) THEN
                        if (rotationDirection = 0) THEN
                            collisionGrid(x-locationX+(y-locationY)*5) <= (grid(2+(x*3)+(y*5*3) DOWNTO (x*3)+(y*5*3)) /= '0'); -- creates 5x5 collision grid from grid location
                        elsif (rotationDirection = 1) THEN
                            collisionGrid(x-locationX+(y-locationY)*5) <= (grid((2+3*((20-x*5)+y)) DOWNTO (3*((20-x*5)+y))) /= '0'); -- same as above with rotation
                        elsif (rotationDirection = -1) THEN
                            collisionGrid(x-locationX+(y-locationY)*5) <= (grid((2+3*((x*5)+(4-y))) DOWNTO (3*((x*5)+(4-y)))) /= '0');
                    else
                        collisionGrid(x-locationX+(y-locationY)*5) <= '1';
                    end if;
                end loop;
            end loop;
            return collisionGrid;
    end function;


    handleUserInput : PROCESS
        variable collisionGrid : STD_LOGIC_VECTOR (24 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0, 25);
    begin
        if rising_edge(leftClick) THEN -- process left moving of active shape
            if (not checkCollision(returnCollisionGrid(activeShapeLocationX - 1, activeShapeLocationY, 0))) THEN
                activeShapeLocationX <= activeShapeLocationX - 1;
            end if;

        elsif rising_edge(rightClick) THEN -- process right moving of active shape
            if (not checkCollision(returnCollisionGrid(activeShapeLocationX + 1, activeShapeLocationY, 0))) THEN
                activeShapeLocationX <= activeShapeLocationX + 1;
            end if;

        elsif rising_edge(upClick) THEN -- process clockwise rotation of active shape
            if (not checkCollision(returnCollisionGrid(activeShapeLocationX, activeShapeLocationY, 1))) THEN
                activeShape <= rotateShape(activeShape, 1);
            end if;

        elsif rising_edge(downClick) THEN -- process counter-clockwise rotation of active shape
            if (not checkCollision(returnCollisionGrid(activeShapeLocationX, activeShapeLocationY, 1))) THEN
                activeShape <= rotateShape(activeShape, -1);
            end if;
    end process;
    
    completedRow : PROCESS -- loops through all cells and finds completed rows
        variable foundRow : boolean;
    begin
        for y in 0 to 19 loop
            foundRow <= '1';
            for x in 0 to 9 loop
                if (grid(2+(x*3)+(y*5*3) DOWNTO (x*3)+(y*5*3)) = "000") then
                    foundRow <= '0';
                    exit loop; -- terminate if a cell in a row is empty
                end if;
            end loop;
            if (foundRow) then
                for x in 0 to 9 loop
                    grid(2+(x*3)+(y*5*3) DOWNTO (x*3)+(y*5*3)) <= "000"; -- clear cells in the row
                end loop;
                for y_upper in 0 to y-1 loop
                    for x in 0 to 9 loop
                        grid(2+(x*3)+((y+1)*5*3) DOWNTO (x*3)+((y+1)*5*3)) <= grid(2+(x*3)+(y*5*3) DOWNTO (x*3)+(y*5*3)); -- iterate through all cells above cleared row and move them down by 1
                    end loop;
                end loop;
                grid(599 DOWNTO 569) <= (others => '0'); -- set the top row to be cleared
                score <= score + 40 * (level + 1); -- update score
                lines <= lines + 1;
                if ((lines mod 10) = '0') then -- update level every 10 cleared rows
                    level <= level + 1;
                end if;
            end if;
        end loop;
    end process;

    onTickActiveShape : PROCESS(gameTick) is 
    begin
        if checkCollision(returnCollisionGrid(activeShapeLocationX, activeShapeLocationY + 1, 0)) then -- checks collision on downward direction
            for y in 0 to 4 loop
                for x in 0 to 4 loop
                    if (activeShape(x+y*5) = '1') then
                        grid(2+((activeShapeLocationX + x) + (activeShapeLocationY + y) * 10) DOWNTO ((activeShapeLocationX + x) + (activeShapeLocationY + y) * 10)) <= activeShape(27 DOWNTO 25); --superimposes the activeShapes color onto the grid.
                    end if;
                end loop;
            end loop;
            activeShapeLocationX <= '4';
            activeShapeLocationY <= '0';
            for y in 0 to 1 loop
                for x in 0 to 3 loop
                    activeShape(2+x+(2+y)*5) <= shapes(nextShape*8+(x+y*4)); -- moves the next shape from shapes to activeShape
                end loop;
            end loop;
            activeShape <= nextColor & activeShape(24 DOWNTO 0); -- adds the color to activeShape
            needShape <= '1';
        else
            score <= score + 1;
            activeShapeLocationY <= activeShapeLocationY + 1;
        end if;
    end process;

    tickProcess : PROCESS(counter, pauseClick, resetClick) is
        if rising_edge(pauseClick) then
            paused <= not paused;
        
        elsif rising_edge(resetClick) or reset = '1' then
            reset <= '0';
            grid <= (others => '0');
            score <= '0';
            level <= '0';
            lines <= '0';
            needShape <= '1';
            activeShapeLocationX <= '4';
            activeShapeLocationY <= '0';
            for y in 0 to 1 loop
                for x in 0 to 3 loop
                    activeShape(2+x+(2+y)*5) <= shapes(nextShape*8+(x+y*4)); -- moves the next shape from shapes to activeShape
                end loop;
            end loop;
            activeShape <= nextColor & activeShape(24 DOWNTO 0);
        
        elsif rising_edge(counter) then
            -- produce a tick signal to move the blocks

        -- missing:
        -- write grid and activeShape to output
        -- handle level and score properly
        -- speed up game with each level
        -- 


