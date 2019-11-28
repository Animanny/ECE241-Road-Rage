module drawPlayer(input clk, reset, enable, input [7:0] xin, input[6:0] yin, output[7:0] x, output [6:0] y, output [2:0] colour);
	playerCar U450(.address(memCounter),.clock(clk),.q(colour));//iterate through address and read colour from memory
																						 //This image is 21 x 30 px	
	reg[9:0] memCounter;// = 10'b1;
	reg[7:0] xCounter;// = 8'b0;
	reg[6:0] yCounter;// = 8'b0;
	initial begin
		memCounter = 10'b0;
		xCounter = 8'b0;
		yCounter = 7'b0;
	end
		
	always@(posedge clk) begin
		if(reset == 1)begin
			xCounter <= 8'b0;
			yCounter <= 7'b0;
			memCounter <= 10'b0;
		end
		else if(enable)begin
			if (memCounter < 10'b1001110110) begin 
				if(xCounter < 8'b10100)begin
					xCounter <= xCounter +  1'b1;
				end
				else begin
					xCounter <= 0;
					yCounter <= yCounter + 1'b1;
						
				end
				memCounter <= memCounter + 1'b1;
			end
			else begin
				xCounter <= 8'b0;
				yCounter <= 7'b0;
				memCounter <= 10'b0;
			end
		end
	end
	
	assign x = xin+xCounter;
	assign y = yin+yCounter;

//	assign x = 8'b00100001+xCounter;
//	assign y = 7'b1011000+yCounter;

endmodule 