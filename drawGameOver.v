module drawGameOver(input clk, reset, enable, output[7:0] x, output [6:0] y, output [2:0] colour);
		gameOver gameover(.address(memCounter),.clock(clk),.q(colour));//iterate through address and read colour from memory
		
		
	//72 width
	//59 h	
	//assign ledr = memCounter;
	
	reg[14:0] memCounter = 10'b0;
	reg[7:0] xCounter = 8'b0;
	reg[6:0] yCounter = 8'b0;
//	initial begin
//		memCounter = 10'b0;
//		xCounter = 8'b0;
//		yCounter = 7'b0;
//	end
		
	always@(posedge clk) begin
		if(reset == 1)begin
			xCounter <= 8'b0;
			yCounter <= 7'b0;
			memCounter <= 15'b0;
		end
		else if(enable)begin
			if (memCounter < 15'd4248) begin
				if(xCounter < 8'd71)begin
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
				memCounter <= 15'b0;
			end
		end
	end
	
	assign x = 8'd43 + xCounter;
	assign y = 8'd33 + yCounter;

endmodule

