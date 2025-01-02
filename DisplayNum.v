module DisplayNum (num, hex); 
input [3:0] num;
output [7:0] hex;

reg [7:0] hex;
	always @(num) begin
		case (num)
		
		0 : hex = 8'b11000000;
		1 : hex = 8'b11111001;
		2 : hex = 8'b10100100;
		3 : hex = 8'b10110000;
		4 : hex = 8'b10011001;
		5 : hex = 8'b10010010;
		6 : hex = 8'b10000010;
		7 : hex = 8'b11111000;
		8 : hex = 8'b10000000;
		9 : hex = 8'b10010000;
		
		default : hex = 8'b1111111;
		endcase
	end
endmodule
