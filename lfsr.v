module lfsr(
    input clk,            // Clock input
    input reset,          // Reset input
    output reg [2:0] rnd  // 3-bit random number output (0 to 6)
);

    // Internal LFSR register
    reg [15:0] lfsr;
    wire feedback;

    // XOR feedback taps for 16-bit LFSR
    // Polynomial: x^16 + x^14 + x^13 + x^11 + 1
    assign feedback = lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10];

    // Sequential logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Initialize LFSR to a non-zero value on reset
            lfsr <= 16'hACE1; // Example seed value
            //rnd <= 0;
        end else begin
            // Shift LFSR and insert feedback bit
            lfsr <= {lfsr[14:0], feedback};
            // Take modulo 7 of the LFSR output for a range of 0 to 6
            rnd <= lfsr[15:13] % 7;
        end
    end

endmodule