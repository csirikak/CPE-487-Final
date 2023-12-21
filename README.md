# CPE 487 Tetris Final Project

* Our project was to create a working Tetris video game with music that runs entirely and natively on the provided FPGA, the Nexys A7-100T.
* The project is designed to be stored and run natively on the Nexys A7-100T and requires the following external parts:
  * A VGA Monitor and cable to display the game from the VGA output on the FPGA.
  * A Pmod I2S DAC and speaker to output the game music.
      * This isn't required for the game to work, but there won't be any music without it.

## Game Logic
Tetris is a 80s game from the Soviet Union, consisting of 7 tetrominos (5 when considering chiral pairs). A game world of 10x20 grids, the objective is to move the tetrominos into completed rows while they tick downwards at an ever increasing pace. The user is allowed to perform linear translation and rotation operations on the active shape.
* The game logic must perform the following:
  * Spawn a new shape randomly from a list of tetrominos
  * Move the shape downward on every game tick
  * Allow the user to perform linear translation and rotation operations asynchronously, but not during the (nearly instantaneous IRL but not in VHDL) downward movement.
  * Merge the active shape with the grid on (bottom) collision with another block or grid bottom.
  * Handle user inputs to perform translation and rotation operations once per click.
  * Pass the color of a grid location given the x and y location to the Display Logic.
### tetrisComponent.vhd
This file contains all the game logic
* Functions:
  * `lookupColor`
    *  returns the 3 bit color when given a shape.
  * `nextPieceSelection`
    * returns a new piece when given an integer (intended to be used with a PRNG)
  * `checkRotationCollision`
    * returns whether a shape will collide if rotated. It accomplishes this by creating a ghost shape and performing a rotation operation, then checking for overlaps.
    * Inputs:
      * current active shape
      * the grid state
      * rotation direction (0 -- CW, 1 -- CCW) 
* Processes:
  * `clockProcess`
    * This increments the counter with each 100 MHz clock cycle
    * This also allows for pausing by stopping the increment.
  * `gameTickToggle`
    * This toggles the signal `gameTick` to coordinate the falling of the blocks, the check for completed rows, and the spawning of new shapes.
    * The `gameTick` is meant to speed up but the past implementation was unstable, so it is fixed for now.
  * `gameTickProcess`
    * This handles the logic for getting the next shape and the following things:
    * Handling reset operations: clearing the grid, getting a new shape, resetting the tick value.
    * Move the active shape with each rising edge of the tick
    * Add the active shape to the grid when the active shape collides on the bottom and spawning a new shape
    * TODO: Clear the grid when a row is completed.
    * Send a signal when the process is busy manupulating the active shape.
  * `processMovement`
    * This is meant to coordinate the movement from the user and `gameTickProcess` and prevent writing to `activeShape` simultaneously.
    * By using if and elsif statements as well as wait for constant values it avoids collisions
    * Ideally, each source of change would emit a signal and once 0, `activeShape` would be modified.
  * `processUserMovement`
    * This is meant to perform translation and rotation operations then pass the resulting shape to `processMovement`
    * The operation should occur once with each press of the button.
  * `processControls`
    * This is meant to produce a single pulse that triggers a single operation of `processMovement`, this might be an inherently flawed approach.
    * The trigger is a press of a button.
  * `checkCollision`
    * The collisions are checked whenever the active shape moves, since rotation operations haven't been achieved as of yet, it is possible that the check must happen sooner due to timing issues.
  * `processBoardOutput`
    * This processes the requested x and y address from the display logic and returns the current color of the grid or active shape in that location. 
### tetris_package.vhd
This file contains the custom types and the constants for the grid and tetrominos.
* `shapeType` this holds the possible shapes and serves as a reference for the color.
* `boardType` is a 2D array of cells containing `filled` and `shape`. The `filled` is a binary value indicating whether a cell is filled and `shape` allows a reference to the color.
* `pieceType` is a 1D array of 4 blocks (`block`) and a `shape` reference
* `block` contains col and row refering to the location of a block with respect to the grid. Intended for use with active shapes.
* The rest of the constants are the declarations for the tetronimos.
## Display Logic

### CPE 487 Display Logic Overview
* In pursuit of optimal graphics design, a primary objective was to minimize memory usage, prompted by initial challenges encountered when attempting to store 1280x720x3 in block RAM. Additionally, our aim was to demonstrate proficiency in leveraging both raster and vector graphics.

### gpu.vhd
* The principal file within the graphics module, 'gpu.vhd,' serves to partition the screen into distinct div/containers, allowing for differential treatment and the application of various outputs from different modules.

### vga_sync.vhd
* The 'vga_sync.vhd' file is responsible for generating synchronization signals for the VGA. Adapted from lab 3, it has been updated to accommodate a resolution of 1280x720.

### clk_wiz_0.vhd and clk_wiz_0_clk_wiz.vhd
* These files are instrumental in generating a pixel clock from the built-in 100MHz clock specifically for the VGA.

### word_handle.vhd
* By dividing the container into six smaller containers and normalizing the x and y coordinates, 'word_handle.vhd' sets the stage for utilization in 'letter_handle.vhd.'

### letter_handle.vhd
* Within 'letter_handle.vhd' resides a lookup table encompassing all characters employed in the project. It produces color outputs based on the given x and y coordinates.

### inttoword.vhd
* Serving as a component interface, 'inttoword.vhd' streamlines the process of displaying numbers by taking integer inputs and generating word outputs for 'word_handle.'

### Grid
* This module divides the container into 32x32 squares, ask for color information, and conveys data, including color, x, and y coordinates, to 'square.vhd.'

### square.vhd
* 'Square.vhd' encapsulates the equations essential for drawing squares with shadows, contributing to the overall graphics presentation.

## Music Logic
* The music logic is similar to a primative midi player that operates on a fixed note duration and uses only square waves, where each note or non-note is 107ms or a whole multiple of 107ms in duration.
* I used a short tetris midi file I found on an online midi sequencer to create my own note sequences used to create the music. The link to the midi I based my note sequence on is https://onlinesequencer.net/96845  

* The code required to generate and output the tetris theme comes from the following modules. A brief description is included below each:
   * TetrisMusic.vhd
      * This is a modified version of the lab 5 code which retains the code necessary to get the dac output working.
   * dac.vhd
      * This is the same module taken from the *dac_if* module of lab 5, this is also required to get the dac output working.
   * Square_Wave_Generator.vhd
      * A variable clock divider that generates specific square wave frequencies that become the audio signal that eventually gets output by the DAC. 
   * MusicBox.vhd
      * This module iterates through one of three 128-entry long note lists, and outputs a 5-bit vector depending on the note stored.
   * ChannelCombiner.vhd
      * This module takes the outputs of the three audio signals sent to it by the three square wave generator entities and combined their audio signals into a single 16-bit signed to be sent to the DAC. 
   * ClkDiv2.vhd
      * This divides the 100MHz system clock we use to 50MHz to be used as an input clock for the code taken from lab 5 because that code was written with a 50MHz system clock in mind.
   * MusicClock.vhd
      * This divides the 100MHz system clock down to be a 18.666Hz clock, which powers the MusicBox's logic.

### Modifications and created code for Music Logic
* Modifications
  * I modified the top-level module from lab 5 *siren.vhd* to create the top-level module *TetrisMusic.vhd*, which retained the same timing logic and logic necessary to get the DAC working, but has all of the code and logic I used to generate the music and signals that are then combined to be input into the dac code in a similar way that the wail instance sent it's data into the DAC.
  * I also kept the *dac_if* module that was in lab 5 and simplified the name to just be *dac* since it also was necessary to get the DAC to operate properly.

 * Created code
    * I created two different clock dividers which were necessary to ensure the DAC operated as intended and also another clock divider that sends its clock into the *MusicBox* to give it the proper timing signals to work as intended and at the correct speed.
       * The *ClkDiv2.vhd* module divides the system clock of 100MHz by 2 to be a 50MHz clock, this is necessary because the code I took from lab 5 that powers the DAC requires a 50MHz clock, but our project uses the 100MHz clock and I couldn't implement an additional 50MHz clock without Vivado getting angry at me.
       * The *MusicClock* module divides the system clock of 100MHz by 5357144 to create a 18.666Hz clock that I use in the *MusicBox.vhd* module to generate the proper timings for the music. I figured out we needed an 18.666Hz clock for the music because the tempo of the music is 140BPM and it allows for a fixed note length of 107ms which I use to time the length of the notes and breaks in each channel of audio.
         
    * I then created a new module, *Square_Wave_Generator.vhd* that inputs the 48.8KHz audio sampling rate the DAC uses and also will take in a 5-bit logic vector that is used to select the current note that will be generated. The code also outputs a 16-bit signed value which represents the audio signal of the output.
       * The first part of the code compares the 5-bit input to a 32-entry lookup table that relates each bit combination to a specific note, so for example the bit combination "01000" will relate to the note A5, which has a value of 55.
       * Each of these notes has a calculated value that gets used in the next step, a clock divider, which divides the input 48.8KHz clock by the value found from the table, so in the case of A5, we divide the 48800Hz clock by 55 and get a signal with the frequency of 887Hz, which is as close as we can get to A5's actual value of 880Hz.
       * After we get a new, temporary clock with the desired clock frequency, a function outputs a 16-bit signed with either the value of 10240 or -10240, depending on whether the new clock signal is low or high respectively.
       * Additionally, in my code there is also a note that represents no-note, or no audio for that period, this is when the 5-bit input is "00000" and for that case, no clock division is performed and instead the 16-bit signed output will have a value of 0 for the entire period.
    * To feed the "Square_Wave_Generator.vhd" with notes to play, I created a "MusicBox.vhd" module, which inputs the MusicClock of 18.666Hz, a 2-bit vector which determines which of the three tracks to play, and an output 5-bit vector that gets sent directly into the *Square_Wave_Generator.vhd" module above.
       * The architecture of this module has two parts, a counter that counts at the 18.666Hz clock speed and counts over the range of 0 to 127, and a set of three 128-long tables, each table contains the note sequence for each channel and a note value for each value of the counter.
          * The counter is clocked at the 18.666Hz that is provided to it from the "MusicClock.vhd" module and counts from 0 to 127, once it reaches 127 it'll start over at 0 again.
          * Depending on the input channel, we have three different tables that will be interated downards with the counter, each coresponding to a channel of audio and will result in polyphony once the three channels are combined. So for the first instance of MusicBox, it'll be initialized with a constant Channel value of "00", so it'll iterate down the first list of notes and change it's current note output every clock of the counter. The second channel will be with "01" and that results in a different note list being used and a new note being sent to a *SquareWaveGenerator* instance, same thing for the third channel.
          * Each table ranges from 0 to 127, just like the counter, and the output will be a 5-bit value sent to *SquareWaveGenerator* that coresponds to the note that should be generated, such as "01000" being A5.
          * Each note and non-note has a fixed length of 107ms using this approach, and will change every clock pulse of MusicClock when the counter is incremented by 1.       
      * This is a brief example of the the note selector works. When the channel is "00" it'll use this table, so every 107ms the counter will increase by 1 and move down the list, where the output vector (CurrentNote) becomes the current value assigned to the counter value. Once the counter reaches 127, it goes back to 0 and loops.
      
![image](https://github.com/csirikak/CPE-487-Final/assets/90861355/6527a93f-5b79-4e2c-9b4e-773e522a04ec)

   * After all three instances of *Square_Wave_Generator.vhd* generates an audio signal, each of their audio signals is sent into *ChannelCombiner.vhd*, where it takes three inputs, each being a 16-bit signed generated from each instance of SquareWaveGenerator, and then it outputs a single 16-bit signed that represents the combined signal of all three channels.
      * The process to combine the three signals is very simple, I simply made an intermediate integer variable called *combined*, which I then set equal to the TO_INTEGER of all three input audio channels added together.
      * From there, I had another temporary value, *result* which was equal to the TO_SIGNED(combined, 16), which just converted the integer value calculated above, back into a signed so the types would match, this value was then assigned to the output.
      * I didn't have to worry about any logic to avoid clipping because of my implementation of SquareWaveGenerator, which I chose the signed values of being 10240 and -10240 because I knew that I would be using three channels and that in the event that all three channels were 10240 and were added together, the highest/lowest value that would be output by the channel combiner would be 30720 and -30720, which fits within the 16-bit signed range of (32768,-32768) naturally.

### Block Diagram and Video for Music
![Block Diagram](MusicBoxSchematic.PNG)

* This is a block diagram that shows only the music portion of the code. As is shown, the MusicClock feeds into the MusicBox(1-3) instances which provides them their timing singnals necessary for the 107ms note lengths. Each of these also get their own Channel value, of "00", "01" and "10" respectively which makes them each generate a different sequence of 5-bit vectors. Each of these three output their 5-bit CurrentNote vector into their respective WaveGen(1-3) entities, which also have an input for their 48.8KHz audio clock, which they use to generate square waves with a frequency specified by the note. Each WaveGen then outputs their 16-bit signed value of the audio signal to the ChannelCombine entity which combines all three channels of audio into one and sends it into the DAC, which then outputs the final song.  

https://github.com/csirikak/CPE-487-Final/assets/90861355/0e17b16b-fe72-4b88-b302-b8643e4d9bb4

## Summary
Each member of the group worked on a separate part of the project code
* Armand Rome worked on the music and music logic
* Chiripol Sirikakan worked on the game Logic
* Dorzhi Denisov worked on the graphics and display logic
