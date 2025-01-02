module game_state_machine (
	input clk,
    input rst,
    input start_game, //switch
    input drop, // switch
	input rotate, // switch
    input left, //button
    input right, //button
	input [2:0] chooseBlock,
	output reg [239:0] game_space_vga,
	output reg [7:0] gamepoints
);

	// Game states
	parameter INIT         = 4'b0000;
	parameter SPAWN_BLOCK  = 4'b0001;
	parameter MOVE_BLOCK   = 4'b0010;
	parameter MOVE_LEFT    = 4'b0011;
	parameter MOVE_RIGHT   = 4'b0100;
	parameter MOVE_DOWN    = 4'b0101;
	parameter EVALUATE     = 4'b0110;
	parameter PREROTATE    = 4'b0111;
	parameter ROTATE_BLOCK = 4'b1000;
	parameter END_GAME     = 4'b1001;
	
	// Registers for game area and block positions
	reg [11:0] game_space[19:0];          // Game area (20 rows, 12 columns)
	reg [11:0] game_space_newblock[3:0];  // New falling block (4 rows)
	reg [11:0] game_space_previous[3:0];  // New falling block (4 rows)
	//reg [239:0] game_space_vga;      // Data sent to the vga
	
	// Game state
	reg [3:0] gamestate;         // Game state (start, new block, moving, left, right)
	
	
	// Block position
	reg [4:0] current_top;   // Block's top row position
	reg [3:0] current_left;  // Block's left column position
	reg [2:0] block_row;
	reg [4:0] game_row;
	
	// Left and right borders of the game area
	wire gameborder_left;
	wire gameborder_right;
	assign gameborder_left  = |(game_space_newblock[0][11] | game_space_newblock[1][11] | game_space_newblock[2][11] | game_space_newblock[3][11]);
	assign gameborder_right = |(game_space_newblock[0][0]  | game_space_newblock[1][0]  | game_space_newblock[2][0]  | game_space_newblock[3][0]);
	// Collision detection
	reg collision;
	reg collision_begin_check;
	reg collision_complete;
	wire fall;
	
	reg quick_fall;
	reg [25:0] cntr;
	reg [7:0] rotate_cntr;
	
	integer i;
	integer row;
	
	// Delay signals, for rising/falling edge detection
	reg left_d;
	reg right_d;
	reg drop_d;
	reg start_game_d;
	reg rotate_d;
	
	always @ (posedge clk) begin
		left_d <= left;
		right_d <= right;
		drop_d <= drop;
		start_game_d <= start_game;
		rotate_d <= rotate;
	end

	// Logic to determine rate of drop
	// A counter that counts up to 49999999 for a fall rate of 1 block per second
	// or counts up to 4999999 for a fall rate of 1/10th of a second
	always @ (posedge clk) begin
		if(rst) begin
			cntr <= 0;  // Reset the counter
		end else begin
			if(~quick_fall && (cntr >= 49999999))
				cntr <= 0;  // Reset the counter if no drop and the counter exceeds 1 second
			else if(quick_fall && (cntr >= 4999999))
				cntr <= 0;  // Reset the counter if drop is active and the counter exceeds 1/10th of a second
			else
				cntr <= cntr + 1;  // Increment the counter
		end
	end

	assign fall = quick_fall?(cntr == 4999999):(cntr == 49999999);
		  
	// Main state machine logic
	always @ (posedge clk) begin
		if (rst) begin
			// Reset game state and variables
			gamestate <= INIT;
			collision_begin_check <= 0;
			gamepoints <= 0;
			quick_fall <= 0;
		end else if(collision_begin_check) begin
			block_row <= block_row +1;
			game_row <= game_row +1;
			if(~collision && (block_row <4) && (game_row <20)) begin
				 if(game_space[game_row] & game_space_newblock[block_row]) begin
					  collision <= 1;
				 end
			end else if((game_row == 20) && (block_row <4) && (game_space_newblock[block_row]!=0))
				 collision <= 1;
			else begin
				 collision_complete <= 1;
				 collision_begin_check <= 0;
			end
		end else begin
			case (gamestate)
				 // State before the game starts
				 INIT: begin
					  if (start_game_d && ~start_game || ~start_game_d && start_game) begin
							// Start the game by clearing the game space and setting up a new block
							gamestate <= SPAWN_BLOCK;  // Transition to SPAWN_BLOCK
							collision_complete <= 0;
							gamepoints <= 0;
							for (i = 0; i < 20; i = i + 1) begin
								 game_space[i] <= 0;  // Clear the game area
							end
					  end
				 end
				 
				 // State for spawning a new block
				 SPAWN_BLOCK: begin
					  if(~collision_complete) begin
							// Initialize new blocks	
							case (chooseBlock)
								3'b000: begin // O-Shape
									 game_space_newblock[0] <= 12'b000011000000;
									 game_space_newblock[1] <= 12'b000011000000;
									 game_space_newblock[2] <= 12'b000000000000;
									 game_space_newblock[3] <= 12'b000000000000;
								end
								3'b001: begin // I-Shape
									 game_space_newblock[0] <= 12'b000011110000;
									 game_space_newblock[1] <= 12'b000000000000;
									 game_space_newblock[2] <= 12'b000000000000;
									 game_space_newblock[3] <= 12'b000000000000;
								end
								3'b010: begin // T-Shape
									 game_space_newblock[0] <= 12'b000001000000;
									 game_space_newblock[1] <= 12'b000011100000;
									 game_space_newblock[2] <= 12'b000000000000;
									 game_space_newblock[3] <= 12'b000000000000;
								end
								3'b011: begin // L-Shape
									 game_space_newblock[0] <= 12'b000011100000;
									 game_space_newblock[1] <= 12'b000000100000;
									 game_space_newblock[2] <= 12'b000000000000;
									 game_space_newblock[3] <= 12'b000000000000;
								end
								3'b100: begin // J-Shape
									 game_space_newblock[0] <= 12'b000011100000;
									 game_space_newblock[1] <= 12'b000010000000;
									 game_space_newblock[2] <= 12'b000000000000;
									 game_space_newblock[3] <= 12'b000000000000;
								end
								3'b101: begin // Z-Shape
									 game_space_newblock[0] <= 12'b000011000000;
									 game_space_newblock[1] <= 12'b000001100000;
									 game_space_newblock[2] <= 12'b000000000000;
									 game_space_newblock[3] <= 12'b000000000000;
								end
								3'b110: begin // S-Shape
									 game_space_newblock[0] <= 12'b000001100000;
									 game_space_newblock[1] <= 12'b000011000000;
									 game_space_newblock[2] <= 12'b000000000000;
									 game_space_newblock[3] <= 12'b000000000000;
								end
							endcase
															
							current_top <= 0;  // Top position for new block
							current_left <= 4; // Left position for new block
							collision_begin_check <= 1;
							collision <= 0;
							quick_fall <= 0;
							block_row <= 0;
							game_row <= 0;
					  end else if (collision) begin
							gamestate <= END_GAME;
					  end else if (collision_complete) begin
							gamestate <= MOVE_BLOCK;
					  end
				 end
				 
				 // State for moving the block
				 MOVE_BLOCK: begin
					  collision_complete <= 0;
					  // Determine the next movement depending on user input and fall rate
					  if(fall) begin
							gamestate <= MOVE_DOWN;
					  end else if ((left_d && ~left) && ~gameborder_left) begin
							gamestate <= MOVE_LEFT;
					  end else if ((right_d && ~right) && ~gameborder_right) begin
							gamestate <= MOVE_RIGHT;
					  end else if(drop_d && ~drop || ~drop_d && drop) begin
							quick_fall <= 1;
					  end else if (rotate_d && ~rotate || ~rotate_d && rotate) begin
							gamestate <= PREROTATE;
							rotate_cntr <= 0;
							for(i=0;i<4;i=i+1) begin
								 game_space_previous[i] <= game_space_newblock[i];
							end
					  end
				 end
	
				 // State for handling left movement of the block
				 MOVE_LEFT: begin
					  if (~collision_complete) begin
							collision <= 0;
							collision_begin_check <= 1;
							block_row <= 0;
							game_row <= current_top;
							// Shift the block to the left
							for(i=0;i<4;i=i+1) begin
								 game_space_newblock[i] <= {game_space_newblock[i][10:0],1'b0};
							end
					  end else begin
							// Block cannot move left, stay in current position
							if(collision) begin
								 // Undo shift
								 for(i=0;i<4;i=i+1) begin
									  game_space_newblock[i] <= {1'b0,game_space_newblock[i][11:1]};
								 end
							end else begin
								 current_left <= current_left - 1;
							end
							gamestate <= MOVE_BLOCK;  // Transition back to moving state
					  end
				 end
	
				 // State for handling right movement of the block
				 MOVE_RIGHT: begin
					  if(~collision_complete) begin
							collision <= 0;
							collision_begin_check <= 1;
							block_row <= 0;
							game_row <= current_top;
							// Shift right
							for(i=0;i<4;i=i+1) begin
								 game_space_newblock[i] <= {1'b0,game_space_newblock[i][11:1]};
							end
					  end else begin
							 if(collision) begin
								 // Undo shift
								 for (i=0;i<4;i=i+1) begin
									  game_space_newblock[i] <= {game_space_newblock[i][10:0],1'b0};
								 end
							 end else begin
								 current_left <= current_left+1;
							 end
							gamestate <= MOVE_BLOCK;
					  end
				 end
				 
				 MOVE_DOWN: begin
					  if(~collision_complete) begin
							// Check collision cases
							if(current_top < 19) begin
								 collision <= 0;
								 collision_begin_check <= 1;
							end else if(current_top == 19 && game_space_newblock[0]!=0) begin
								 collision <= 1;
								 collision_complete <= 1;
							end
							block_row <= 0;
							game_row <= current_top+1;
					  end else if(collision) begin  // Collision either with gamespace or game border bottom
							// Update gamepsace to permenantly place the new block
							for(i=0;i<20;i=i+1) begin
								 if(i>=current_top && (i-current_top) < 4) begin
									game_space[i] <= game_space[i] | game_space_newblock[i-current_top];
								 end
							end
							gamestate <= EVALUATE;
							rotate_cntr <= 0;
							game_row <= 0;
					  end else begin
							// Increment the current_top counter to move the block down
							current_top <= current_top + 1;
							gamestate <= MOVE_BLOCK;
					  end
				 end
				 
				 EVALUATE: begin
					// If we've reached the 20th row (the bottom of the game area)
					if(game_row == 20) begin
						gamestate <= SPAWN_BLOCK; // Transition to the new block state (spawn a new block)
						collision_complete <= 0; // Reset the "collision_check_complete" flag
					end else begin
						// If we haven't reached the bottom row yet
						game_row <= game_row +1; // Move to the next row (continue collision_begin_checking)
						if(game_space[game_row]==12'hFFF) begin
								gamepoints <= gamepoints + 1; // Update the total score                	
							// Shift all the rows down starting from the current row (i = 19, the last row)
								for(i=19;i>0;i=i-1) begin
									if(i<=game_row) begin
										game_space[i] <= game_space[i-1]; // Shift the row down by copying it from the row above
									end
								end
								game_space[0]<=12'h000; // Clear the top row (since all rows shift down)
						end
					end
				end
				
				// State for initializing the rotation		 
				PREROTATE: begin
				  // Shift block to top-left corner
				  if (rotate_cntr < current_left) begin
						for (i = 0; i < 4; i = i + 1) begin
							game_space_newblock[i] <= {game_space_newblock[i][10:0], 1'b0};
							rotate_cntr <= rotate_cntr + 1;
						end
						
					end else begin
						// Rotate block 90 degrees by transposing the 4x4 array
						game_space_newblock[0] <= {game_space_newblock[3][11], game_space_newblock[2][11], game_space_newblock[1][11], game_space_newblock[0][11], 8'h00};
						game_space_newblock[1] <= {game_space_newblock[3][10], game_space_newblock[2][10], game_space_newblock[1][10], game_space_newblock[0][10], 8'h00};
						game_space_newblock[2] <= {game_space_newblock[3][9],  game_space_newblock[2][9], game_space_newblock[1][9],  game_space_newblock[0][9],  8'h00};
						game_space_newblock[3] <= {game_space_newblock[3][8],  game_space_newblock[2][8], game_space_newblock[1][8],  game_space_newblock[0][8],  8'h00};
						rotate_cntr <= 0;
						collision_complete <= 0;
						gamestate <= ROTATE_BLOCK;
					 end
				 end
		 
				 //State for completing the rotation
				 ROTATE_BLOCK: begin
					 if (game_space_newblock[0] == 12'h000) begin
						 // Remove empty top row
						 for (i = 0; i < 3; i = i + 1) begin
							 game_space_newblock[i] <= game_space_newblock[i + 1];
						 end
						 game_space_newblock[3] <= 12'h000;
						
					 end else if (~gameborder_left && rotate_cntr == 0) begin
						 // Shift left if the left column is empty
						 for (i = 0; i < 4; i = i + 1) begin
							game_space_newblock[i] <= {game_space_newblock[i][10:0], 1'b0};
						 end
					 
					 end else if (rotate_cntr < current_left) begin
						 // Shift block to the right, collision_begin_checking boundaries
						 rotate_cntr <= rotate_cntr + 1;
						 if (~gameborder_right) begin
							for (i = 0; i < 4; i = i + 1) begin
							  game_space_newblock[i] <= {1'b0, game_space_newblock[i][11:1]};
							end
						 end else begin
							// Revert to the original block if boundary collision occurs
							gamestate <= MOVE_BLOCK;
							for (i = 0; i < 4; i = i + 1) begin
							  game_space_newblock[i] <= game_space_previous[i];
							end
						  end
						  
					  end else begin
						 // Final collision collision_begin_check and transition
						 if (~collision_complete) begin
							collision_begin_check <= 1;
							collision <= 0;
							block_row <= 0;
							game_row <= current_top;
						 end else if (collision) begin
							// Revert if collision detected
							gamestate <= MOVE_BLOCK;
							for (i = 0; i < 4; i = i + 1) begin
							  game_space_newblock[i] <= game_space_previous[i];
							end
						 end else begin
							gamestate <= MOVE_BLOCK;
						 end
					  end
				 end
				 
				// Game ending state
				END_GAME: begin
				  // Wait for user to start a new game
				  if(start_game_d && ~start_game || ~start_game_d && start_game) begin
					 gamestate <= INIT;
				  end
				end
			endcase // End case
		end // End if
	end // End always
	
	always @ (posedge clk) begin
		// Loop through all 20 rows of the game sapce and map them into game_space_vga
		for (row = 0; row < 20; row = row + 1) begin
			if (row >= current_top && row < current_top + 4) begin
				// If the current row corresponds to one of the rows of the falling block
				// Combine the current game row and the falling block row (OR them together)
				game_space_vga[(row * 12) +: 12] <= game_space[row] | game_space_newblock[row - current_top];
			end else begin
				// Otherwise, just use the current game space row
				game_space_vga[(row * 12) +: 12] <= game_space[row];
			end
		end
	end

endmodule