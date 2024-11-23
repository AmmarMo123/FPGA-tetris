module vga_controller (
    input wire clk,         // 50 MHz clock from DE10-Lite
    input wire reset,       // Reset signal
    output reg hsync,       // Horizontal sync signal
    output reg vsync,       // Vertical sync signal
    output reg [3:0] red,   // 4-bit Red signal
    output reg [3:0] green, // 4-bit Green signal
    output reg [3:0] blue   // 4-bit Blue signal
);

    // VGA 640x480 Timing Parameters
    parameter H_DISPLAY   = 640;  // Horizontal display width
    parameter H_FRONT_PORCH = 16; // Horizontal front porch
    parameter H_SYNC_PULSE  = 96; // Horizontal sync pulse width
    parameter H_BACK_PORCH  = 48; // Horizontal back porch
    parameter H_TOTAL       = 800; // Total horizontal time (display + sync + porch)

    parameter V_DISPLAY   = 480;  // Vertical display height
    parameter V_FRONT_PORCH = 10; // Vertical front porch
    parameter V_SYNC_PULSE  = 2;  // Vertical sync pulse width
    parameter V_BACK_PORCH  = 33; // Vertical back porch
    parameter V_TOTAL       = 525; // Total vertical time (display + sync + porch)

    // Pixel clock generation (25 MHz from 50 MHz input clock)
    reg pixel_clk;
    reg [1:0] pixel_clk_div;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pixel_clk_div <= 2'b0;
            pixel_clk <= 1'b0;
        end else begin
            pixel_clk_div <= pixel_clk_div + 1'b1;
            pixel_clk <= (pixel_clk_div == 2'b11) ? ~pixel_clk : pixel_clk;
        end
    end

    // Horizontal and Vertical Counters
    reg [9:0] h_count; // Horizontal counter (0 to H_TOTAL-1)
    reg [9:0] v_count; // Vertical counter (0 to V_TOTAL-1)

    always @(posedge pixel_clk or posedge reset) begin
        if (reset) begin
            h_count <= 0;
            v_count <= 0;
        end else begin
            if (h_count == H_TOTAL - 1) begin
                h_count <= 0;
                if (v_count == V_TOTAL - 1)
                    v_count <= 0;
                else
                    v_count <= v_count + 1'b1;
            end else begin
                h_count <= h_count + 1'b1;
            end
        end
    end

    // Generate sync signals
    always @(posedge pixel_clk or posedge reset) begin
        if (reset) begin
            hsync <= 1'b1;
            vsync <= 1'b1;
        end else begin
            // Horizontal sync
            hsync <= ~(h_count >= (H_DISPLAY + H_FRONT_PORCH) &&
                       h_count < (H_DISPLAY + H_FRONT_PORCH + H_SYNC_PULSE));
            // Vertical sync
            vsync <= ~(v_count >= (V_DISPLAY + V_FRONT_PORCH) &&
                       v_count < (V_DISPLAY + V_FRONT_PORCH + V_SYNC_PULSE));
        end
    end

    // Generate RGB signals
    always @(posedge pixel_clk or posedge reset) begin
        if (reset) begin
            red <= 4'b0;
            green <= 4'b0;
            blue <= 4'b0;
        end else if (h_count < H_DISPLAY && v_count < V_DISPLAY) begin
            // Simple color pattern for testing (you can modify this)
            red <= h_count[7:4];    // Red intensity depends on horizontal position
            green <= v_count[7:4]; // Green intensity depends on vertical position
            blue <= (h_count[7:4] ^ v_count[7:4]); // Blue is a pattern
        end else begin
            red <= 4'b0;
            green <= 4'b0;
            blue <= 4'b0;
        end
    end

endmodule
