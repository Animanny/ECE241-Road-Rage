//module drawCar(input clk,reset, leftEnable, output reg [7:0] x, output reg [6:0] y, output reg[2:0] colour);
//	
//	reg [4:0]xCounter,yCounter;
//	reg [9:0]addressCounter;
//	wire [2:0]toOutput;
//	
//	
//	playerCar U100(.address(addressCounter),.clock(clk),.q(toOutput));//iterate through address and read colour from memory
//	//picture is 21x30 pixels
//	
//	always@(posedge clk)
//	begin
//		if (reset==1'b1)
//		begin
//			colour <= 000;
//			xCounter<=5'b0;
//			yCounter<=5'b0;
//			addressCounter<=10'b0;
//		end
//		if(yCounter < 5'b11110 && addressCounter < 10'd630) begin
//			if (leftEnable) //draw in left lane
//				 begin
//				 
//				 colour <= toOutput;
//				 x<=8'b00100001+xCounter; //Output x starting from left lane
//				 y<=7'b1011000+yCounter; //Output y
//				 
//					if (xCounter >= 5'd20) begin
//						xCounter <= 0;
//						yCounter <= yCounter+1'b1;
//					end else begin
//						xCounter<=xCounter+1'b1;
//					end
//					
//					addressCounter<=addressCounter+1'b1;
//				end
//			end
//		end		
//endmodule
