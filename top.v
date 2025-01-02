module top(
    input clk,                 // Clock
    input rst,                 // Reset
    input start_game,          // Switch for game control
    input drop,                // Switch for game control
    input rotate,              // Switch for game control
    input left,                // Button for game control
    input right,               // Button for game control
    output [3:0] red,          // RGB color outputs
    output [3:0] blue,
    output [3:0] green,
    output hsync,              // Horizontal sync signal for VGA display
    output vsync,              // Vertical sync signal for VGA display
    output [7:0] disp0,        // Score display (ones)
    output [7:0] disp1         // Score display (tens) 
);
	reg [3:0] ones;
	reg [3:0] tens;
	
	// Game state machine declaration
	game_state_machine game_state_machine_inst (
		.clk(clk),
		.rst(rst),
		.start_game(start_game),
		.drop(drop),
		.rotate(rotate),
		.left(left),
		.right(right),
		.chooseBlock(chooseBlock),
		.game_space_vga(game_space_vga),
		.gamepoints(gamepoints)
	);
	
	// vga declaration
	vga vga_inst (
		.clock50MHz(clk),
		.data(game_space_vga),
		.red(red),
		.blue(blue),
		.green(green),
		.hsync(hsync),
		.vsync(vsync)
	);
	
	// Logic for exctracting ones and tens value for 7 segment display
	always @ (posedge clk) begin
		ones <= gamepoints % 10;
		tens <= gamepoints / 10;
	end
	
	// 7 segment display declaration
	DisplayNum (ones, disp0);
	DisplayNum (tens, disp1);
	
	// lfsr random number generator declaration
	lfsr random_block_generator (
		.clk(clk),
		.reset(rst),
		.rnd(chooseBlock)
	);

endmodule
