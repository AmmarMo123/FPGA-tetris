# Tetris on DE-10 Lite FPGA

## Project Description and Features
This project was part of the EECS 3201 course (Digital Logic Design), and was made with a partner. It implements a fully functional Tetris game on the DE-10 Lite FPGA board. The key features include:

1. **Random Block Generation**
2. **Block Movement (Left/Right)**
3. **Block Drops**
4. **Block Rotation**
5. **Block Collision Detection**
6. **Line Clearing**
7. **Scoring System**
8. **Game Over and Restart Mechanisms**

The game is controlled using the DE-10 Lite's buttons and switches. For switch inputs, only the rising and falling edges of the signals are used, enabling single-move operations with a switch flip. The VGA output displays the Tetris grid and falling blocks, while the seven-segment display shows the current score.

## Approach in Designing
This project consists of several key components, which interact as follows:

### 1. Game State Machine
The Game State Machine processes user inputs (movement, rotation, and drops) to update the game space and calculate the score. The primary states are:

- **SPAWN_BLOCK**: Generates a new block represented by a 4x12 array of 0s and 1s.
- **MOVE_BLOCK**: Decides whether the block should move down, left, right, or rotate, based on user input and a counter controlling the drop pace.
  - **MOVE_LEFT / MOVE_RIGHT**: Shifts the block and updates the respective counters, undoing the shift on collision.
  - **PRE_ROTATE / ROTATE_BLOCK**: Adjusts the block’s position for rotation and restores its state if a collision occurs.
- **MOVE_DOWN**: Updates the block's vertical position unless a collision occurs or the bottom is reached, at which point the block is placed permanently.
- **EVALUATE**: Handles line clearing and score updates.
- **END_GAME**: Triggers when no more moves are possible, waiting for the user to restart.

State machine implementation was incremental: each subset of states was tested independently before integrating new states.

### 2. VGA Module
The VGA module displays the Tetris grid and blocks. Since the DE-10 Lite lacks a 25 MHz clock, an Altera PLL from Quartus Prime’s IP catalog was used to generate the required signals. Key features include:

- **Pattern Generation**: The `pattern_generator` module processes a 240-bit input grid representing the 12x20 board. It determines block and border positions, using parameters like block size, gaps, and grid boundaries.
- **Rendering**: RGB signals are calculated to render blocks and borders appropriately.

### 3. Linear Feedback Shift Register (LFSR)
The LFSR generates pseudorandom sequences for random block selection. The design combines principles from [8] and online resources [9], [10]. It uses a shift register and feedback via XOR gates to produce a pseudorandom sequence based on a non-zero seed value.

## Citations
1. K. Liu, Y. Yang and Y. Zhu, "Tetris game design based on the FPGA," 2012 2nd International Conference on Consumer Electronics, Communications and Networks (CECNet), Yichang, China, 2012, pp. 2925-2928. [Link](https://doi.org/10.1109/CECNet.2012.6202213)
2. Yılmaz, S., & Öztürk, D. (2020). A study on FPGA-based pattern generation for digital displays. *Journal of FPGA Research, 15*(2), 123-135. [Link](https://doi.org/10.1016/j.fpga.2020.02.003)
3. V. Slavkovic, "FPGA_Tetris" [Source code]. GitHub. [Link](https://github.com/ViktorSlavkovic/FPGA_Tetris)
4. Primiano, "tetris-vhdl" [Source code]. GitHub. [Link](https://github.com/primiano/tetris-vhdl)
5. Baliika, "fpga-tetris" [Source code]. GitHub. [Link](https://github.com/baliika/fpga-tetris/tree/main)
6. D. Meads, "VGA_face" [Source code]. GitHub. [Link](https://github.com/dominic-meads/Quartus-Projects/tree/main/VGA_face)
7. A. Kuznetsov, "FPGA-based game development: Tetris clone." Habr. [Link](https://habr.com/en/articles/707224/)
8. S. Brown and Z. Vranesic, *Fundamentals of Digital Logic with Verilog Design,* 3rd ed. New York, NY, USA: McGraw-Hill, 2014.
9. ASIC-World, "Linear Feedback Shift Register (LFSR)." [Link](https://www.asic-world.com/examples/verilog/lfsr.html)
10. Simple FPGA, "Random Number Generator in Verilog (FPGA)." [Link](https://simplefpga.blogspot.com/2013/02/random-number-generator-in-verilog-fpga.html)

