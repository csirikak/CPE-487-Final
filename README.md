# CPE 487 Tetris Final Project

* Our project was to create a working Tetris video game with music that runs entirely and natively on the provided FPGA, the Nexys A7-100T.
* The project is designed to be stored and run natively on the Nexys A7-100T and requires the following external parts:
  * A VGA Monitor and cable to display the game from the VGA output on the FPGA.
  * A Pmod I2S DAC and speaker to output the game music.
      * This isn't required for the game to work, but there won't be any music without it.

## Game Logic

## Display Logic

## Music Logic
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
    * I created two different clock dividers which were necessary to ensure the DAC operated as intended and also a clock divider that sends its clock into the *MusicBox*
