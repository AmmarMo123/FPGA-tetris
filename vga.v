//////////////////////////////////////////////////////////////////////////////////
// 
// Module Name:   vga 
// Project Name:  Tetris Game
// Description:   VGA display module for drawing the entire game area.
// 
//////////////////////////////////////////////////////////////////////////////////
module vga(
  // General
  input clk,
  input rst,
  // Game Area - 20 rows by 12 columns
  input [11:0] game_area[19:0],
  // VGA signals
  output reg vga_hs,
  output reg vga_vs,
  output [1:0] vga_red,
  output [1:0] vga_green,
  output [1:0] vga_blue
);

  // Region Counters (Horizontal and Vertical Position)
  reg [10:0] cntr_hr;
  reg [9:0] cntr_vr;

  always @ (posedge clk) begin
    if (rst) begin
      cntr_hr <= 0;
      cntr_vr <= 0;
    end else begin
      // Horizontal counter (increments until the end of a horizontal line)
      if (cntr_hr == 1039) begin
        cntr_hr <= 0;
        // Increment the vertical counter at the end of each horizontal line
        if (cntr_vr == 665)
          cntr_vr <= 0;
        else
          cntr_vr <= cntr_vr + 1;
      end else begin
        cntr_hr <= cntr_hr + 1;
      end
    end
  end

  // VGA Blank Region Signals
  wire blank_hr;
  wire blank_vr;
  reg blank_region;

  assign blank_hr = (cntr_hr >= 800);
  assign blank_vr = (cntr_vr >= 600);

  always @ (posedge clk) begin
    if (rst)
      blank_region <= 0;
    else
      blank_region <= blank_hr | blank_vr; // One pixel delay added for sync
  end

  // Generating VGA Sync Signals (HSync and VSync)
  always @ (posedge clk) begin
    if (rst) begin
      vga_hs <= 0;
      vga_vs <= 0;
    end else begin
      // Horizontal Sync
      vga_hs <= (cntr_hr >= 856 && cntr_hr <= 975); // Pulse width
      // Vertical Sync
      vga_vs <= (cntr_vr >= 637 && cntr_vr <= 643); // Pulse width
    end
  end

  // Drawing Logic
  reg [1:0] red;
  reg [1:0] green;
  reg [1:0] blue;

  integer i; // Loop variable for indexing rows

  always @ (posedge clk) begin
    if (rst) begin
      red <= 0;
      green <= 0;
      blue <= 0;
    end else begin
      // Draw Game Area - Only if in the valid game area display region
      if ((cntr_hr >= 140) && (cntr_hr < (140 + 12 * 18)) && 
          (cntr_vr >= 129) && (cntr_vr < (129 + 20 * 18))) begin
        // Calculate the row and column of the game area being drawn
        integer row = (cntr_vr - 129) / 18;  // Each row is 18 pixels high
        integer col = (cntr_hr - 140) / 18;  // Each column is 18 pixels wide

        // Ensure the row and col values are within the bounds of the game area
        if (row < 20 && col < 12) begin
          if (game_area[row][11 - col]) begin // The bit is set, indicating a filled cell
            red <= 2'b11;    // Set RGB values for filled block (e.g., white)
            green <= 2'b11;
            blue <= 2'b11;
          end else begin
            red <= 2'b00;    // Set RGB values for empty block (e.g., black)
            green <= 2'b00;
            blue <= 2'b00;
          end
        end else begin
          red <= 2'b00;      // Default to black outside game area
          green <= 2'b00;
          blue <= 2'b00;
        end
      end else begin
        red <= 2'b00;        // Default to black for blank regions
        green <= 2'b00;
        blue <= 2'b00;
      end
    end
  end

  // Assigning VGA Color Outputs
  assign vga_red = blank_region ? 2'b00 : red;
  assign vga_green = blank_region ? 2'b00 : green;
  assign vga_blue = blank_region ? 2'b00 : blue;

endmodule