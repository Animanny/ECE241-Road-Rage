// Part 2 skeleton

module fill
    (
        CLOCK_50,                        //    On Board 50 MHz
        // Your inputs and outputs here
        KEY,                            // On Board Keys
        SW,
		  LEDR,
        // The ports below are for the VGA output.  Do not change.
        VGA_CLK,                           //    VGA Clock
        VGA_HS,                            //    VGA H_SYNC
        VGA_VS,                            //    VGA V_SYNC
        VGA_BLANK_N,                        //    VGA BLANK
        VGA_SYNC_N,                        //    VGA SYNC
        VGA_R,                           //    VGA Red[9:0]
        VGA_G,                             //    VGA Green[9:0]
        VGA_B                           //    VGA Blue[9:0]
    );

    input            CLOCK_50;                //    50 MHz
    input    [3:0]    KEY;    
    input [9:0] SW;                
    // Declare your inputs and outputs here
    // Do not change the following outputs
    output            VGA_CLK;                   //    VGA Clock
    output            VGA_HS;                    //    VGA H_SYNC
    output            VGA_VS;                    //    VGA V_SYNC
    output            VGA_BLANK_N;                //    VGA BLANK
    output            VGA_SYNC_N;                //    VGA SYNC
    output    [7:0]    VGA_R;                   //    VGA Red[7:0] Changed from 10 to 8-bit DAC
    output    [7:0]    VGA_G;                     //    VGA Green[7:0]
    output    [7:0]    VGA_B;                   //    VGA Blue[7:0]
	 output[9:0] LEDR;
    
    wire reset;
    assign reset = KEY[0];
    
    // Create the colour, x, y and writeEn wires that are inputs to the controller.

    wire [2:0] colour;
    wire [7:0] x;
    wire [6:0] y;
    wire go;
	 wire done;
    reg plot;
    //wire Lx, Ly, Lc
	 wire enable; //plot input to vgA adapter set to enable
    wire [2:0] DataColour;

    assign go = ~KEY[3];
    //assign colour = SW[9:7];
	 
	 assign enable = ~KEY[2];
	 
	 //drawBackground dB(.clk(CLOCK_50), .reset(SW[9]), .enable(enable), .done(done), .xCounter(x), .yCounter(y), .cout(DataColour));
	drawCar U1000(.clk(CLOCK_50), .reset(SW[9]), .enable(SW[6]),.ledr(LEDR[9:0]),.x(x),.y(y),.colour(DataColour));

    

    // Create an Instance of a VGA controller - there can be only one!
    // Define the number of colours as well as the initial background
    // image file (.MIF) for the controller.
    vga_adapter VGA(
            .resetn(reset),
            .clock(CLOCK_50),
            .colour(DataColour),
            .x(x),
            .y(y),
            .plot(1),
            /* Signals for the DAC to drive the monitor. */
            .VGA_R(VGA_R),
            .VGA_G(VGA_G),
            .VGA_B(VGA_B),
            .VGA_HS(VGA_HS),
            .VGA_VS(VGA_VS),
            .VGA_BLANK(VGA_BLANK_N),
            .VGA_SYNC(VGA_SYNC_N),
            .VGA_CLK(VGA_CLK));
        defparam VGA.RESOLUTION = "160x120";
        defparam VGA.MONOCHROME = "FALSE";
        defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
        defparam VGA.BACKGROUND_IMAGE = "crappy road.mif";
            
    // Put your code here. Your code should produce signals x,y,colour and writeEn
    // for the VGA controller, in addition to any other functionality your design may require.
//    control C0(
//        .clk(CLOCK_50),
//        .resetn(reset),
//        .plot(plot),
//        .enable(enable),
//        .go(go),
//
//        .lx(Lx), 
//        .ly(Ly),
//        .lc(Lc)
//    );
//
//    datapath D0(
//        .clk(CLOCK_50),
//        .resetn(reset),
//        .plot(plot),
//        .enable(enable),
//
//        .lx(Lx), 
//        .ly(Ly),
//        .lc(Lc),
//        .lb(~KEY[2]),
//        .xin(SW[6:0]),
//        .yin(SW[6:0]),
//        .colour(colour),
//        .cout(DataColour),
//        .xout(x),
//        .yout(y)
//    );
    
endmodule
//
//module control(clk, resetn, plot, enable, go, lx, ly, lc);
//
//    input clk;
//    input go;
//    input resetn;
//    input plot;
//    output reg enable;
//    output reg lx;
//    output reg ly; 
//    output reg lc;
//
//    reg [3:0] current_state;
//    reg [3:0] next_state;
//    
//    localparam  S_LOAD_X       = 3'd0,
//                S_LOAD_WAIT_X  = 3'd1,
//                S_LOAD_Y          = 3'd2,
//                S_LOAD_WAIT_Y  = 3'd3,
//                CYCLE_0        = 3'd4,
//                S_DONE         = 3'd5;
//                    
//    always@(*)
//    begin: state_table
//            case (current_state)
//                S_LOAD_X: next_state = go ? S_LOAD_WAIT_X : S_LOAD_X;
//                S_LOAD_WAIT_X: next_state = go ? S_LOAD_WAIT_X : S_LOAD_Y; 
//                S_LOAD_Y: next_state = go ? S_LOAD_WAIT_Y : S_LOAD_Y;    
//                S_LOAD_WAIT_Y: next_state = go ? S_LOAD_WAIT_Y : CYCLE_0; 
//                CYCLE_0: next_state = S_DONE;
//                S_DONE: next_state = S_LOAD_X;
//                default: next_state = S_LOAD_X;
//            endcase
//    end
//   
//always @(*)
//    begin: enable_signals
//        // By default make all our signals 0
//        lx = 1'b0;
//        enable = 1'b0;
//        lc = 1'b0;
//        ly = 1'b0;
//  
// 
//        case (current_state)
//            S_LOAD_X: begin
//                lx = 1'b1;
//                lc = 1'b1;
//                enable = 1'b0;    
//                ly = 1'b0;
//            end
//                          
//            S_LOAD_Y: begin
//                lx = 1'b0;
//                lc = 1'b0;
//                enable = 1'b0;    
//                ly = 1'b1;
//            end
//                          
//            CYCLE_0: begin
//                lx = 1'b0;
//                lc = 1'b0;
//                enable = 1'b1;    
//                ly = 1'b0;
//            end
//                          
//            S_DONE: begin
//                lx = 1'b0;
//                lc = 1'b0;
//                enable = 1'b1;    
//                ly = 1'b0;
//            end
//      endcase
//    end
//                    
//    // current_state registers
//    always@(posedge clk)
//    begin: state_FFs
//        if (!resetn)
//            current_state <= S_LOAD_X;
//        else
//            current_state <= next_state;
//    end // state_FFS
//endmodule 


module drawBackground(clk, reset, enable, done, xCounter, yCounter, cout);
	input clk;
	input enable;
	input reset;
	output reg done;
	output [2:0] cout;

	output reg [7:0] xCounter;
	output reg [6:0] yCounter;
	reg [14:0] addressCounter;
	
	  
	always@ (posedge clk) begin
		if(reset) begin
				done <= 0;
				addressCounter <= 0;
				xCounter <= 0;
				yCounter <= 0;
		end
		else if(enable && !done) begin
			if(addressCounter == 5'd19200)begin
				done <= 1;
			end
			else begin
				addressCounter <= addressCounter + 1;
				if(xCounter == 3'd160) begin
					xCounter <= 0;
					yCounter <= yCounter +1;
				end
				else begin
					xCounter <= xCounter +1;
				end
			end
		end
	end
	backgroundImage bI(.address(addressCounter), .clock(clk), .q(cout));

endmodule


//module drawCar(input clk,reset, leftEnable,rightEnable, midEnable, output[9:0]ledr, output  [7:0] x, output  [6:0] y, output [2:0] colour);
//	
//	reg [4:0]xCounter,yCounter;
//	reg [9:0]addressCounter;
//	reg [7:0] xini;
//	
//	assign x =xini+xCounter; //Output x starting from left lane
//	assign y=7'b1011000+yCounter; //Output y
//	assign ledr = addressCounter;
//	
//	playerCar U100(.address(addressCounter),.clock(clk),.q(colour));//iterate through address and read colour from memory
//	//picture is 21x30 pixels
//	
//	always@(posedge clk)
//	begin
//		if (reset==1'b1)
//		begin
//			xCounter<=5'b0;
//			yCounter<=5'b0;
//			addressCounter<=10'b0;
//		end
//		else if(yCounter < 5'b11110 && addressCounter < 10'd630) begin
//			if (leftEnable) //draw in left lane
//				 begin
//					xini<=8'b00100001;
//					if (xCounter < 5'd20) begin
//						xCounter<=xCounter+1'b1;
//					end else begin
//						xCounter <= 0;
//						yCounter <= yCounter+1'b1;
//					end
//					addressCounter<=addressCounter+1'b1;
//				end
//			else if (midEnable) //draw in middle lane
//				begin
//					xini<=8'b01000101;
//					if (xCounter > 5'd20)
//						begin
//							xCounter <= 0;
//							yCounter <= yCounter+1'b1;
//						end
//					else 
//						begin
//							xCounter<=xCounter+1'b1;
//						end
//					addressCounter<=addressCounter+1'b1;
//				end
//			else if (rightEnable) //draw in right lane
//			begin
//				xini<=8'b01101010;				
//				if (xCounter > 5'd20)
//					begin
//						xCounter <= 0;
//						yCounter <= yCounter+1'b1;
//					end
//				else 
//					begin
//						xCounter<=xCounter+1'b1;
//					end
//				addressCounter<=addressCounter+1'b1;
//			end
//		end
//	end		
//endmodule

module drawCar(input clk, reset, enable, output[9:0]ledr, output[7:0] x, output [6:0] y, output [2:0] colour);
	playerCar U100(.address(memCounter),.clock(clk),.q(colour));//iterate through address and read colour from memory
																						 //This image is 21 x 30 px
	assign ledr = memCounter;
	
	reg[9:0] memCounter;
	reg[7:0] xCounter;
	reg[7:0] yCounter;
	reg done = 1'b0;
	initial memCounter = 10'b0;
	initial xCounter = 8'b0;
	initial yCounter = 8'b0;
	
	always@(posedge clk) begin
		if(reset == 1)begin
			xCounter <= 8'b0;
			yCounter <= 8'b0;
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
		end
	end
	
	assign x = 8'b00100001+xCounter;
	assign y = 8'b01011000+yCounter;

endmodule
