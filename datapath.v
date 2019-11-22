//module datapath(clk, draw_enable, erase_enable,Oout,yOut,colourOut);
//
//input draw_enable, erase_enable, clk;
//output reg [7:0] xOut;
//output reg [6:0] yOut;
//output reg [2:0] colourOut;
//
//wire [7:0]xcar, x_bg;
//wire [6:0]yCar,yOut;
//wire [2:0]carColour,bgColour;
//
//
//always@(posedge clk)
//	begin
//		if(draw_enable)
//			begin
//				xOut<=xCar;
//				yOut<=yCar;
//				colourOut<=carColour;
//			end
//		else if(erase_enable)
//			begin
//				xOut<=x_bg;
//				yOut<=y_bg;
//				colourOut<=bgColour;
//			end
//	end
//	
//endmodule