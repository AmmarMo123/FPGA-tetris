module tvPattern(
input [9:0] x,
input [9:0] y,
output reg [3:0] red,
output reg [3:0] green,
output reg [3:0] blue);

always @(x||y)
begin
if(x>=0 && x<100 && y>=0 && y<100)) 
	begin
		red <= 4'hF;
		green <= 4'hF;
		blue <= 4'hF;
	end
end



endmodule