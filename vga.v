module vga(
   input clock50MHz,
   input [239:0] data, 
   output [3:0] red,
   output [3:0] blue,
   output [3:0] green,
   output hsync,
   output vsync
);
	reg [9:0] counter_x = 0;  // horizontal counter
	reg [9:0] counter_y = 0;  // vertical counter
	wire [3:0] r_red;
	wire [3:0] r_blue;
	wire [3:0] r_green;
	
	reg reset = 0;  // for PLL
	
	wire clk25MHz;
	
	// clk divider 50 MHz to 25 MHz
	ip ip1(
		.areset(reset),
		.inclk0(clock50MHz),
		.c0(clk25MHz),
		.locked()
		);  

	// counter and sync generation
	always @(posedge clk25MHz)  // horizontal counter
		begin 
			if (counter_x < 799)
				counter_x <= counter_x + 1;  // horizontal counter (including off-screen horizontal 160 pixels) total of 800 pixels 
			else
				counter_x <= 0;              
		end  // always 
	
	always @ (posedge clk25MHz)  // vertical counter
		begin 
			if (counter_x == 799)  // only counts up 1 count after horizontal finishes 800 counts
				begin
					if (counter_y < 525)  // vertical counter (including off-screen vertical 45 pixels) total of 525 pixels
						counter_y <= counter_y + 1;
					else
						counter_y <= 0;              
				end 
		end

	// hsync and vsync output assignments
	assign hsync = (counter_x >= 0 && counter_x < 96) ? 1:0;  // hsync high for 96 counts                                                 
	assign vsync = (counter_y >= 0 && counter_y < 2) ? 1:0;   // vsync high for 2 counts

	// pattern generator
	pattern_generator pattern_gen(
		.clk(clk25MHz),
		.rst(reset),
		.counter_x(counter_x),
		.counter_y(counter_y),
		.data(data),
		.r_red(r_red),
		.r_green(r_green),
		.r_blue(r_blue)
	);			

	// color output assignments
	// only output the colors if the counters are within the adressable video time constraints
	assign red = (counter_x > 144 && counter_x <= 787 && counter_y > 35 && counter_y <= 514) ? r_red : 4'h0;
	assign blue = (counter_x > 144 && counter_x <= 787 && counter_y > 35 && counter_y <= 514) ? r_blue : 4'h0;
	assign green = (counter_x > 144 && counter_x <= 787 && counter_y > 35 && counter_y <= 514) ? r_green : 4'h0;

endmodule
