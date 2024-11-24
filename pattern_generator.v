module pattern_generator (
	input clk,
    input rst,
    input [9:0] counter_x,        // Horizontal counter
    input [9:0] counter_y,        // Vertical counter
	input [239:0] data,           // Input grid
    output reg [3:0] r_red,       // Red output
    output reg [3:0] r_green,     // Green output
    output reg [3:0] r_blue       // Blue output
);

    // Constants to define Tetris grid
    parameter COL_START = 340;
    parameter ROW_START = 67;
    parameter BLOCK_SIZE = 17;
    parameter GAP = 4;
    reg [4:0] game_area_row;
    reg valid_line;

    // Determine which rows to draw the blocks in
    always @ (posedge clk)
    begin
        if(rst) begin
            valid_line <= 0;
            game_area_row <= 0;
        end else begin
            if((counter_y >= ROW_START) && (counter_y <= ROW_START + BLOCK_SIZE)) begin
            game_area_row <= 0;
            valid_line <= 1;
            end else if((counter_y >= ROW_START + BLOCK_SIZE + GAP) && (counter_y <= ROW_START + 2*BLOCK_SIZE + GAP)) begin
            game_area_row <= 1;
            valid_line <= 1;
            end else if((counter_y >= ROW_START + 2*BLOCK_SIZE + 2*GAP) && (counter_y<= ROW_START + 3*BLOCK_SIZE + 2*GAP)) begin
            game_area_row <= 2;
            valid_line <= 1;
            end else if((counter_y >= ROW_START + 3*BLOCK_SIZE + 3*GAP) && (counter_y <= ROW_START + 4*BLOCK_SIZE + 3*GAP)) begin
            game_area_row <= 3;
            valid_line <= 1;
            end else if((counter_y >= ROW_START + 4*BLOCK_SIZE + 4*GAP) && (counter_y <= ROW_START + 5*BLOCK_SIZE + 4*GAP)) begin
            game_area_row <= 4;
            valid_line <= 1;
            end else if((counter_y >= ROW_START + 5*BLOCK_SIZE + 5*GAP) && (counter_y <= ROW_START + 6*BLOCK_SIZE + 5*GAP)) begin
            game_area_row <= 5;
            valid_line <= 1;
            end else if((counter_y >= ROW_START + 6*BLOCK_SIZE + 6*GAP) && (counter_y <= ROW_START + 7*BLOCK_SIZE + 6*GAP)) begin
            game_area_row <= 6;
            valid_line <= 1;
            end else if((counter_y >= ROW_START + 7*BLOCK_SIZE + 7*GAP) && (counter_y <= ROW_START + 8*BLOCK_SIZE + 7*GAP)) begin
            game_area_row <= 7;
            valid_line <= 1;
            end else if((counter_y >= ROW_START + 8*BLOCK_SIZE + 8*GAP) && (counter_y <= ROW_START + 9*BLOCK_SIZE + 8*GAP)) begin
            game_area_row <= 8;
            valid_line <= 1;
            end else if((counter_y >= ROW_START + 9*BLOCK_SIZE + 9*GAP) && (counter_y <= ROW_START + 10*BLOCK_SIZE + 9*GAP)) begin
            game_area_row <= 9;
            valid_line <= 1;
            end else if((counter_y >= ROW_START + 10*BLOCK_SIZE + 10*GAP) && (counter_y <= ROW_START + 11*BLOCK_SIZE + 10*GAP)) begin
            game_area_row <= 10;
            valid_line <= 1;
            end else if((counter_y >= ROW_START + 11*BLOCK_SIZE + 11*GAP) && (counter_y <= ROW_START + 12*BLOCK_SIZE + 11*GAP)) begin
            game_area_row <= 11;
            valid_line <= 1;
            end else if((counter_y >= ROW_START + 12*BLOCK_SIZE + 12*GAP) && (counter_y <= ROW_START + 13*BLOCK_SIZE + 12*GAP)) begin
            game_area_row <= 12;
            valid_line <= 1;
            end else if((counter_y >= ROW_START + 13*BLOCK_SIZE + 13*GAP) && (counter_y <= ROW_START + 14*BLOCK_SIZE + 13*GAP)) begin
            game_area_row <= 13;
            valid_line <= 1;
            end else if((counter_y >= ROW_START + 14*BLOCK_SIZE + 14*GAP) && (counter_y <= ROW_START + 15*BLOCK_SIZE + 14*GAP)) begin
            game_area_row <= 14;
            valid_line <= 1;
            end else if((counter_y >= ROW_START + 15*BLOCK_SIZE + 15*GAP) && (counter_y <= ROW_START + 16*BLOCK_SIZE + 15*GAP)) begin
            game_area_row <= 15;
            valid_line <= 1;
            end else if((counter_y >= ROW_START + 16*BLOCK_SIZE + 16*GAP) && (counter_y <= ROW_START + 17*BLOCK_SIZE + 16*GAP)) begin
            game_area_row <= 16;
            valid_line <= 1;
            end else if((counter_y >= ROW_START + 17*BLOCK_SIZE + 17*GAP) && (counter_y <= ROW_START + 18*BLOCK_SIZE + 17*GAP)) begin
            game_area_row <= 17;
            valid_line <= 1;
            end else if((counter_y >= ROW_START + 18*BLOCK_SIZE + 18*GAP) && (counter_y <= ROW_START + 19*BLOCK_SIZE + 18*GAP)) begin
            game_area_row <= 18;
            valid_line <= 1;
            end else if((counter_y >= ROW_START + 19*BLOCK_SIZE + 19*GAP) && (counter_y <= ROW_START + 20*BLOCK_SIZE + 19*GAP)) begin
            game_area_row <= 19;
            valid_line <= 1;
            end else
            valid_line <= 0;
        end
    end  // 1st always

    // Exctact the given row
    wire [11:0] game_area_mx;
    assign game_area_mx = valid_line ? data[(game_area_row)*12 : (game_area_row)*12 + 12] : 12'h000;

    // Determine the columns and draw the blocks
    always @ (posedge clk)
    begin
        if(rst) begin
            r_red   <= 4'h0;
            r_blue  <= 4'h0;
            r_green <= 4'h0;
        end else begin
            // Game stage
            if((game_area_mx[0] == 1) && ((counter_x >= COL_START) && (counter_x <= COL_START + BLOCK_SIZE))) begin
            r_red   <= 4'hF;
            r_blue  <= 4'hF;
            r_green <= 4'hF;
            end else if((game_area_mx[1] == 1) && ((counter_x >= COL_START + BLOCK_SIZE + GAP) && (counter_x <= COL_START + 2*BLOCK_SIZE + GAP))) begin
            r_red   <= 4'hF;
            r_blue  <= 4'hF;
            r_green <= 4'hF;
            end else if((game_area_mx[2] == 1) && ((counter_x >= COL_START + 2*BLOCK_SIZE + 2*GAP) && (counter_x <= COL_START + 3*BLOCK_SIZE + 2*GAP))) begin
            r_red   <= 4'hF;
            r_blue  <= 4'hF;
            r_green <= 4'hF;
            end else if((game_area_mx[3] == 1) && ((counter_x >= COL_START + 3*BLOCK_SIZE + 3*GAP) && (counter_x <= COL_START + 4*BLOCK_SIZE + 3*GAP)))) begin
            r_red   <= 4'hF;
            r_blue  <= 4'hF;
            r_green <= 4'hF;
            end else if((game_area_mx[4] == 1) && ((counter_x >= COL_START + 4*BLOCK_SIZE + 4*GAP) && (counter_x <= COL_START + 5*BLOCK_SIZE + 4*GAP))) begin
            r_red   <= 4'hF;
            r_blue  <= 4'hF;
            r_green <= 4'hF;
            end else if((game_area_mx[5] == 1) && ((counter_x >= COL_START + 5*BLOCK_SIZE + 5*GAP) && (counter_x <= COL_START + 6*BLOCK_SIZE + 5*GAP))) begin
            r_red   <= 4'hF;
            r_blue  <= 4'hF;
            r_green <= 4'hF;
            end else if((game_area_mx[6] == 1) && ((counter_x >= COL_START + 6*BLOCK_SIZE + 6*GAP) && (counter_x <= COL_START + 7*BLOCK_SIZE + 6*GAP))) begin
            r_red   <= 4'hF;
            r_blue  <= 4'hF;
            r_green <= 4'hF;
            end else if((game_area_mx[7] == 1) && ((counter_x >= COL_START + 7*BLOCK_SIZE + 7*GAP) && (counter_x <= COL_START + 8*BLOCK_SIZE + 7*GAP))) begin
            r_red   <= 4'hF;
            r_blue  <= 4'hF;
            r_green <= 4'hF;
            end else if((game_area_mx[8] == 1) && ((counter_x >= COL_START + 8*BLOCK_SIZE + 8*GAP) && (counter_x <= COL_START + 9*BLOCK_SIZE + 8*GAP))) begin
            r_red   <= 4'hF;
            r_blue  <= 4'hF;
            r_green <= 4'hF;
            end else if((game_area_mx[9] == 1) && ((counter_x >= COL_START + 9*BLOCK_SIZE + 9*GAP) && (counter_x <= COL_START + 10*BLOCK_SIZE + 9*GAP))) begin
            r_red   <= 4'hF;
            r_blue  <= 4'hF;
            r_green <= 4'hF;
            end else if((game_area_mx[10] == 1) && ((counter_x >= COL_START + 10*BLOCK_SIZE + 10*GAP) && (counter_x <= COL_START + 11*BLOCK_SIZE + 10*GAP))) begin
            r_red   <= 4'hF;
            r_blue  <= 4'hF;
            r_green <= 4'hF;
            end else if((game_area_mx[11] == 1) && ((counter_x >= COL_START + 11*BLOCK_SIZE + 11*GAP) && (counter_x <= COL_START + 12*BLOCK_SIZE + 11*GAP))) begin
            r_red   <= 4'hF;
            r_blue  <= 4'hF;
            r_green <= 4'hF;
            end
        end
    end // 2nd always
						
endmodule