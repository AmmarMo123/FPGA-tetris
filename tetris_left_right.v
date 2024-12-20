module tetris_left_right(
    input clk,
    input rst, //switch
    input action_enter, //switch
    input action_drop, // switch
    input action_left, //button
    input action_right, //button
    output [3:0] red,          // RGB color outputs (for example, controlling the screen color)
    output [3:0] blue,
    output [3:0] green,
    output hsync,              // Horizontal sync signal for VGA display
    output vsync               // Vertical sync signal for VGA display
); // TODO - DEFINE action_left and action_right

    // Game states
    parameter STATE_START     = 4'b0000;  // Start screen / logo state
    parameter STATE_NEWBLOCK  = 4'b0001;  // State for spawning a new block
    parameter STATE_MOVING    = 4'b0010;  // State for moving the block (left, right, etc.)
    parameter STATE_LEFT      = 4'b0011;  // State for moving the block left
    parameter STATE_RIGHT     = 4'b0100;  // State for moving the block right

    // Registers for game area and block positions
    reg [11:0] game_area[19:0];          // Game area (20 rows, 12 columns)
    reg [11:0] game_area_newblock[3:0];  // New falling block (4 rows)
    reg [239:0] game_area_vga_data;      // Data sent to the vga

    // Game state
    (* KEEP = "TRUE" *) reg [3:0] gamestate;         // Game state (start, new block, moving, left, right)

    // Block position
    reg [3:0] cntr_top;   // Block's top row position
    reg [3:0] cntr_left;  // Block's left column position

    // Left and right borders of the game area
    wire gameborder_left;
    wire gameborder_right;
    assign gameborder_left  = |(game_area_newblock[0][11] | game_area_newblock[1][11] | game_area_newblock[2][11] | game_area_newblock[3][11]);
    assign gameborder_right = |(game_area_newblock[0][0]  | game_area_newblock[1][0]  | game_area_newblock[2][0]  | game_area_newblock[3][0]);

    integer i;
    integer row;

    // Collision detection
    reg collision;
    reg check;
    reg checked;
	 
	reg [2:0] rel_cntr;
	reg [4:0] abs_cntr;
	
    reg action_fall;

	reg action_left_d;
	reg action_right_d;
    reg action_drop_d;

    reg [25:0] gamepoints;
    reg [25:0] gamelines;
    reg drop;

    reg [25:0] cntr;

    always @ (posedge clk) begin
    	 action_left_d <= action_left;
		 action_right_d <= action_right;
         action_drop_d <= action_drop;
	end

    // Logic to determine logic for falling
    always @ (posedge clk) begin
        if(rst) begin
            cntr <= 0;  // Reset the counter
        end else begin
            if(~drop && (cntr >= 49999999))
                cntr <= 0;  // Reset the counter if no drop and the counter exceeds the compare value
            else if(drop && (cntr >= 4999999))
                cntr <= 0;  // Reset the counter if drop is active and the counter exceeds the drop value
            else
                cntr <= cntr + 1;  // Increment the counter
        end
    end

    assign action_fall = drop?(cntr == 4999999):(cntr == 49999999);

    // Main state machine logic
    always @ (posedge clk) begin
        if (rst) begin
            // Reset game state and variables
            gamestate <= STATE_START;   // Set to STATE_LOGO (start screen)
            check <= 0;
            gamepoints <= 0;
            gamelines <= 0;
        end else if(check) begin
            rel_cntr <= rel_cntr +1;
            abs_cntr <= abs_cntr +1;
            if(~collision && (rel_cntr <4) && (abs_cntr <20)) begin
                if(game_area[abs_cntr]&game_area_newblock[rel_cntr]) begin
                    collision <= 1;
                end
            end else if((abs_cntr == 20) && (rel_cntr <4) && (game_area_newblock[rel_cntr]!=0))
                collision <= 1;
            else begin
                checked <= 1;
                check <= 0;
            end
        end else begin
            case (gamestate)
                // State when the game is on the logo/start screen
                STATE_START: begin
                    if (action_enter) begin
                        // Start the game by clearing the game area and setting up a new block
                        gamestate <= STATE_NEWBLOCK;  // Transition to STATE_NEWBLOCK
                        checked <= 0;
                        for (i = 0; i < 20; i = i + 1) begin
                            game_area[i] <= 0;  // Clear the game area
                        end
                    end
                end
                
                // State for spawning a new block
                STATE_NEWBLOCK: begin
                    if(~checked) begin
                        // Initialize a new block at the top of the screen
                        game_area_newblock[0] <= 12'b000011000000;  // A sample block (e.g., a 1x1 block)
                        game_area_newblock[1] <= 12'b000011000000;  // Same block for simplicity
                        game_area_newblock[2] <= 0;
                        game_area_newblock[3] <= 0;
                        cntr_top <= 4;  // Top position for new block
                        cntr_left <= 4; // Left position for new block
                        gamestate <= STATE_MOVING;  // Transition to STATE_MOVING
                        checked <= 1;
                        //collision <= 0;
                    end else if (checked) begin
                        gamestate <= STATE_MOVING;
                    end
                end
                
                // State for moving the block
                STATE_MOVING: begin
                    checked <= 0;
                    if(action_fall) begin // TODO - GENERATE THIS
                        gamestate <= STATE_FALL;
                    end else if (action_left_d && ~action_left && ~gameborder_left) begin
                        gamestate <= STATE_LEFT;
                    end else if (action_right_d && ~action_right && ~gameborder_right) begin
                        gamestate <= STATE_RIGHT;
                    end else if(action_drop_d && ~action_drop) begin
                        drop <= 1;
                    end
                end

                // State for handling left movement of the block
                STATE_LEFT: begin
                    if (~checked) begin
                        collision <= 0;
                        // Block can move left
                        check <= 1;
                        rel_cntr <= 0; // TODO: Check this!!
                        abs_cntr <= cntr_top; // TODO: Check this!!
                        for(i=0;i<4;i=i+1) begin
                            game_area_newblock[i] <= {game_area_newblock[i][10:0],1'b0};
                        end
                    end else begin
                        // Block cannot move left, stay in current position
                        if(collision) begin
                            for(i=0;i<4;i=i+1) begin
                                game_area_newblock[i] <= {1'b0,game_area_newblock[i][11:1]};
                            end
                        end else begin
                            cntr_left <= cntr_left - 1;
                        end
                        gamestate <= STATE_MOVING;  // Transition back to moving state
                    end
                end

                // State for handling right movement of the block
                STATE_RIGHT: begin
                    if(~checked) begin
                        collision <= 0;
                        check <= 1;
                        rel_cntr <= 0;
                        abs_cntr <= cntr_top;
                        for(i=0;i<4;i=i+1) begin
                            game_area_newblock[i] <= {1'b0,game_area_newblock[i][11:1]};
                        end
                    end else begin
                         if(collision) begin
                            for (i=0;i<4;i=i+1) begin
                                game_area_newblock[i] <= {game_area_newblock[i][10:0],1'b0};
                            end
                         end else begin
                            cntr_left <= cntr_left+1;
                         end
                        gamestate   <= STATE_MOVING;
                    end
                end
                
                STATE_FALL: begin
                    if(~checked) begin
                        if(cntr_top < 19) begin
                            collision <= 0;
                            check <= 1;
                        end else if(cntr_top == 19 && game_area_newblock[0]!=0) begin
                            collision <= 1;
                            checked <= 1;
                        end
                        rel_cntr <= 0;
                        abs_cntr <= cntr_top+1;
                    end else if(collision) begin  // Collision either with gamespace or game border bottom
                        // Update gamepsace
                        for(i=0;i<20;i=i+1) begin
                            if(i>=cntr_top && (i-cntr_top) < 4)
                            game_area[i] <= game_area[i] | game_area_newblock[i-cntr_top];
                        end
                        gamestate <= STATE_EVAL;
                        cntr_event <= 0; //TODO: WHAT IS THIS
                        abs_cntr <= 0; //TODO: WHAT IS THIS
                    end else begin
                        cntr_top <= cntr_top + 1;
                        gamestate <= STATE_MOVING;
                    end
                end
                STATE_EVAL: begin
                    // If we've reached the 20th row (the bottom of the game area)
                    if(abs_cntr == 20) begin
                        gamestate <= STATE_NEWBLOCK; // Transition to the new block state (spawn a new block)
                        checked <= 0; // Reset the "checked" flag (collision check flag)
                    end else begin
                        // If we haven't reached the bottom row yet
                        abs_cntr <= abs_cntr +1; // Move to the next row (continue checking)
                        if(game_area[abs_cntr]==12'hFFF) begin
                            gamelines <= gamelines + 1; // Increment the number of lines cleared
                            gamepoints <= gamepoints + 100; // Update the total score

                            // Shift all the rows down starting from the current row (i = 19, the last row)
                            for(i=19;i>0;i=i-1) begin
                                if(i<=abs_cntr) begin
                                    game_area[i] <= game_area[i-1]; // Shift the row down by copying it from the row above
                                end
                            end
                            game_area[0]<=12'h000; // Clear the top row (since all rows shift down)
                        end
                    end
                end
            endcase
        end

		 // Loop through all 20 rows of the game area and map them into game_area_vga_data
		 for (row = 0; row < 20; row = row + 1) begin
			  if (row >= cntr_top && row < cntr_top + 4) begin
					// If the current row corresponds to one of the rows of the falling block
					// Combine the current game row and the falling block row (OR them together)
					game_area_vga_data[(row * 12) +: 12] <= game_area[row] | game_area_newblock[row - cntr_top];
			  end else begin
					// Otherwise, just use the current game area row
					game_area_vga_data[(row * 12) +: 12] <= game_area[row];
			  end
		 end
		 
		 action_left_d <= action_left;
		 action_right_d <= action_right;
         action_drop_d <= action_drop;
	 end

    // TODO: FIGURE OUT test DECLARATION AND DATA PROVIDED TO IT!!!!
    // Instantiate the test module
    test test_inst (
        .clock50MHz(clk),  // Connect the main clock to the test module
        .data(game_area_vga_data),
        .red(red),                // Connect output red signal
        .blue(blue),              // Connect output blue signal
        .green(green),            // Connect output green signal
        .hsync(hsync),            // Connect the horizontal sync signal
        .vsync(vsync)             // Connect the vertical sync signal
    );
	 		

endmodule