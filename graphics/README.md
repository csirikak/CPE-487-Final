## CPE 487 Display Logic Overview
* In pursuit of optimal graphics design, a primary objective was to minimize memory usage, prompted by initial challenges encountered when attempting to store 1280x720x3 in block RAM. Additionally, our aim was to demonstrate proficiency in leveraging both raster and vector graphics.

## gpu.vhd
* The principal file within the graphics module, 'gpu.vhd,' serves to partition the screen into distinct div/containers, allowing for differential treatment and the application of various outputs from different modules.

## vga_sync.vhd
* The 'vga_sync.vhd' file is responsible for generating synchronization signals for the VGA. Adapted from lab 3, it has been updated to accommodate a resolution of 1280x720.

## clk_wiz_0.vhd and clk_wiz_0_clk_wiz.vhd
* These files are instrumental in generating a pixel clock from the built-in 100MHz clock specifically for the VGA.

## word_handle.vhd
* By dividing the container into six smaller containers and normalizing the x and y coordinates, 'word_handle.vhd' sets the stage for utilization in 'letter_handle.vhd.'

## letter_handle.vhd
* Within 'letter_handle.vhd' resides a lookup table encompassing all characters employed in the project. It produces color outputs based on the given x and y coordinates.

## inttoword.vhd
* Serving as a component interface, 'inttoword.vhd' streamlines the process of displaying numbers by taking integer inputs and generating word outputs for 'word_handle.'

## Grid
* This module divides the container into 32x32 squares, ask for color information, and conveys data, including color, x, and y coordinates, to 'square.vhd.'

## square.vhd
* 'Square.vhd' encapsulates the equations essential for drawing squares with shadows, contributing to the overall graphics presentation.
