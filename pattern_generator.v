module pattern_generator (
	input clk,
    input rst,
    input [9:0]   counter_x,      // Horizontal counter
    input [9:0]   counter_y,      // Vertical counter
	 input [239:0] data,           // Input grid
    output [3:0]  r_red,          // Red output
    output [3:0]  r_green,        // Green output
    output [3:0]  r_blue          // Blue output
);

    // Constants to define Tetris grid
    parameter COL_START = 340;
	 parameter COL_END = COL_START + 12*BLOCK_SIZE + 11*GAP;
    parameter ROW_START = 67;
	 parameter ROW_END = ROW_START + 20*BLOCK_SIZE + 19*GAP;
    parameter BLOCK_SIZE = 17;
    parameter GAP = 4;
    reg [4:0] game_area_row;
    reg valid_line;
	 integer i;

    // Determine which rows to draw the blocks in
	 always @ (posedge clk) begin
	 	 if (rst) begin
			  valid_line <= 0;
	 		  game_area_row <= 0;
		 end else begin
			  valid_line <= 0; // Default to 0 unless a valid line is found
			  for (i = 0; i < 20; i = i + 1) begin
					if ((counter_y >= ROW_START + i * (BLOCK_SIZE + GAP)) &&
						 (counter_y <= ROW_START + i * (BLOCK_SIZE + GAP) + BLOCK_SIZE)) begin
						 game_area_row <= i; // Set the row index
						 valid_line <= 1; // Mark the line as valid
					end
			  end
		 end
	 end

    // Exctact the given row
    reg [11:0] game_area_mx;
	 always @(*) begin
        case (game_area_row)
            19: game_area_mx = valid_line ? data[11:0]    : 12'h000;
            18: game_area_mx = valid_line ? data[23:12]   : 12'h000;
            17: game_area_mx = valid_line ? data[35:24]   : 12'h000;
            16: game_area_mx = valid_line ? data[47:36]   : 12'h000;
            15: game_area_mx = valid_line ? data[59:48]   : 12'h000;
            14: game_area_mx = valid_line ? data[71:60]   : 12'h000;
            13: game_area_mx = valid_line ? data[83:72]   : 12'h000;
            12: game_area_mx = valid_line ? data[95:84]   : 12'h000;
            11: game_area_mx = valid_line ? data[107:96]  : 12'h000;
            10: game_area_mx = valid_line ? data[119:108] : 12'h000;
            9: game_area_mx = valid_line  ? data[131:120] : 12'h000;
            8: game_area_mx = valid_line  ? data[143:132] : 12'h000;
            7: game_area_mx = valid_line  ? data[155:144] : 12'h000;
            6: game_area_mx = valid_line  ? data[167:156] : 12'h000;
            5: game_area_mx = valid_line  ? data[179:168] : 12'h000;
            4: game_area_mx = valid_line  ? data[191:180] : 12'h000;
            3: game_area_mx = valid_line  ? data[203:192] : 12'h000;
            2: game_area_mx = valid_line  ? data[215:204] : 12'h000;
            1: game_area_mx = valid_line  ? data[227:216] : 12'h000;
            0: game_area_mx = valid_line  ? data[239:228] : 12'h000;
            default: game_area_mx = 12'b0;
        endcase
    end

	reg block; // Indicates if a game block condition is met
	reg frame; // Indicates if a border condition is met

	// Determine if a block or frame should be drawn at a given index
	always @ (posedge clk) begin
	  // Initialize flags
	  block = 0;  // Reset block flag
	  frame = 0;  // Reset frame flag

	  // Check game blocks
	  for (i = 0; i < 12; i = i + 1) begin
			if ((game_area_mx[i] == 1) &&
				 (counter_x >= COL_START + i * (BLOCK_SIZE + GAP)) &&
				 (counter_x <= COL_START + i * (BLOCK_SIZE + GAP) + BLOCK_SIZE)) begin
				 block = 1; // Set block flag
			end
	  end

	  // Check border conditions
	  if ((counter_y == ROW_START - GAP || counter_y == ROW_END + GAP) &&
			(counter_x >= COL_START - GAP && counter_x <= COL_END + GAP)) begin
			frame = 1; // Top and bottom borders
	  end else if ((counter_x == COL_START - GAP || counter_x == COL_END + GAP) &&
						(counter_y >= ROW_START - GAP && counter_y <= ROW_END + GAP)) begin
			frame = 1; // Left and right borders
	  end
	end
	
	assign r_red   = (block || frame) && ~rst ? 4'hF : 4'h0;
	assign r_blue  = (block || frame) && ~rst ? 4'hF : 4'h0;
	assign r_green = (block || frame) && ~rst ? 4'hF : 4'h0;
						
endmodule