module pattern_generator (
    input wire [9:0] counter_x,    // Horizontal counter
    input wire [9:0] counter_y,    // Vertical counter
    output reg [3:0] r_red,        // Red output
    output reg [3:0] r_green,      // Green output
    output reg [3:0] r_blue        // Blue output
);

    always @ (*) begin
        // Default color values
        r_red = 4'h0;
        r_green = 4'h0;
        r_blue = 4'h0;

        if (counter_y < 135) begin              
            r_red = 4'hF;    // White
            r_blue = 4'hF;
            r_green = 4'hF;
        end else if (counter_y >= 135 && counter_y < 205) begin
            if (counter_x < 324) begin 
                r_red = 4'hF;    // White
                r_blue = 4'hF;
                r_green = 4'hF;
            end else if (counter_x >= 324 && counter_x < 604) begin 
                r_red = 4'hF;    // Yellow
                r_blue = 4'h0;
                r_green = 4'hF;
            end else if (counter_x >= 604) begin 
                r_red = 4'hF;    // White
                r_blue = 4'hF;
                r_green = 4'hF;
            end
        end else if (counter_y >= 205 && counter_y < 217) begin
            if (counter_x < 324) begin 
                r_red = 4'hF;    // White
                r_blue = 4'hF;
                r_green = 4'hF;
            end else if (counter_x >= 324 && counter_x < 371) begin 
                r_red = 4'hF;    // Yellow
                r_blue = 4'h0;
                r_green = 4'hF;
            end else if (counter_x >= 371 && counter_x < 383) begin 
                r_red = 4'h0;    // Black
                r_blue = 4'h0;
                r_green = 4'h0;
            end else if (counter_x >= 383 && counter_x < 545) begin 
                r_red = 4'hF;    // Yellow
                r_blue = 4'h0;
                r_green = 4'hF;
            end else if (counter_x >= 545 && counter_x < 557) begin 
                r_red = 4'h0;    // Black
                r_blue = 4'h0;
                r_green = 4'h0;
            end else if (counter_x >= 557 && counter_x < 604) begin 
                r_red = 4'hF;    // Yellow
                r_blue = 4'h0;
                r_green = 4'hF;
            end else if (counter_x >= 604) begin 
                r_red = 4'hF;    // White
                r_blue = 4'hF;
                r_green = 4'hF;
            end
        end else if (counter_y >= 217 && counter_y < 305) begin
            if (counter_x < 324) begin 
                r_red = 4'hF;    // White
                r_blue = 4'hF;
                r_green = 4'hF;
            end else if (counter_x >= 324 && counter_x < 604) begin 
                r_red = 4'hF;    // Yellow
                r_blue = 4'h0;
                r_green = 4'hF;
            end else if (counter_x >= 604) begin 
                r_red = 4'hF;    // White
                r_blue = 4'hF;
                r_green = 4'hF;
            end
        end else if (counter_y >= 305 && counter_y < 414) begin
            if (counter_x < 324) begin 
                r_red = 4'hF;    // White
                r_blue = 4'hF;
                r_green = 4'hF;
            end else if (counter_x >= 324 && counter_x < 604) begin 
                r_red = 4'hF;    // Yellow
                r_blue = 4'h0;
                r_green = 4'hF;
            end else if (counter_x >= 604) begin 
                r_red = 4'hF;    // White
                r_blue = 4'hF;
                r_green = 4'hF;
            end
        end else if (counter_y >= 414) begin              
            r_red = 4'hF;    // White
            r_blue = 4'hF;
            r_green = 4'hF;
        end
    end
endmodule
