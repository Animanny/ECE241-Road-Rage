// Part 2 skeleton

module fill
    (
        CLOCK_50,                        //    On Board 50 MHz
        // Your inputs and outputs here
        KEY,                            // On Board Keys
        SW,
		  LEDR,
		  HEX0,
		  HEX1,
		  
		  
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
	  output[9:0] LEDR;
	  output[6:0]HEX0;
	  output[6:0]HEX1;
	 
	 
	 
    // Do not change the following outputs
    output            VGA_CLK;                   //    VGA Clock
    output            VGA_HS;                    //    VGA H_SYNC
    output            VGA_VS;                    //    VGA V_SYNC
    output            VGA_BLANK_N;                //    VGA BLANK
    output            VGA_SYNC_N;                //    VGA SYNC
    output    [7:0]    VGA_R;                   //    VGA Red[7:0] Changed from 10 to 8-bit DAC
    output    [7:0]    VGA_G;                     //    VGA Green[7:0]
    output    [7:0]    VGA_B;                   //    VGA Blue[7:0]
	
	 
    
	 
	 
    wire reset;
    assign reset = KEY[0];
    
    // Create the colour, x, y and writeEn wires that are inputs to the controller.

    wire [2:0] cCar,cbg,cPlayer;
    wire [7:0] xbg,xcar,xplayer;
    wire [6:0] ybg,ycar,yplayer;

	 wire done;
    reg plot;
	 reg [7:0] x;
	 reg [6:0] y;
	 
	 
	 wire draw_enable,draw_reset,erase_enable,draw_player_enable;
    //wire Lx, Ly, Lc
	 wire enable; //plot input to vgA adapter set to enable
    reg [2:0] DataColour;

	 
    //assign colour = SW[9:7];
	 
	 assign enable = (draw_enable || erase_enable ||draw_player_enable); //Plot enable signal
	 
	 
	 reg [7:0] xin,xPlayerIn;
	 reg [6:0] yin,yPlayerIn;
	 reg enable_rand;
	 
	 initial enable_rand = 0;
	 initial xin <= 8'd33;
	 initial xPlayerIn <= 8'd33;//left lane inital
	 initial yPlayerIn <= 0;
	 initial yin <=0;
	 
	 wire doneDraw,doneDrawPlayer;
	 wire [2:0]lane_select;
	
	reg collideYes;
	initial collideYes<=0; 
	
	ctrlpath_generate U8342987(.clk(CLOCK_50),.resetn(1),.lane_enable(000),.draw_enable(draw_enable),.collide_yes(collideYes), .draw_reset(draw_reset), .erase_enable(erase_enable),.draw_done(doneDraw),.draw_player_enable(draw_player_enable),.draw_player_done(doneDrawPlayer));
	drawBackground dB(.clk(CLOCK_50), .reset(~reset), .enable(erase_enable), .x(xbg), .y(ybg),.colour(cbg));
	drawCar U1000(.clk(CLOCK_50), .xin(xin), .yin(yin), .reset(~reset),.enable(draw_enable),.x(xcar),.y(ycar),.colour(cCar));
	drawPlayer U2500(.clk(CLOCK_50), .reset(~reset), .enable(draw_player_enable), .xin(xPlayerIn), .yin(7'd89), .x(xplayer),.y(yplayer), .colour(cPlayer));
	LFSR random(.clk(CLOCK_50),.i_Enable(enable_rand),.o_LFSR_Data(lane_select));
	
   decimalDisplay(!collideYes,CLOCK_50, HEX0, HEX1);
	
	 
	 
	 //Select location of cars
	always@(*)
	begin
		if (lane_select[0]==1)
			xin<= 8'd33;
		 else if (lane_select[1]==1)
			xin<= 8'd69;
		 else if (lane_select[2]==1)
			xin<= 8'd106;		
		if(~KEY[1])begin
			xPlayerIn<=8'd106;
		end
		else if(~KEY[2])begin
			xPlayerIn<= 8'd69;
		end
		else if(~KEY[3])begin
			xPlayerIn<=8'd33;
		end
	end
	 
	 
	//Select which mif to read from based on the state 
	always@(posedge CLOCK_50) begin
		if(draw_enable) begin
			x<=xcar;
			y<=ycar;
			DataColour<=cCar;
		end
		else if(draw_player_enable) begin
			x<=xplayer;
			y<=yplayer;
			DataColour<=cPlayer;
		end		
		else if(erase_enable) begin
			x<=xbg;
			y<=ybg;
			DataColour<=cbg;
		end
	end
	
	assign LEDR[0]=draw_player_enable;


	
	//Animate the random car, and determine when to generate a new one
	always@(negedge doneDraw)	
	begin
			yin<=yin+7'b1;
			if((xin==xPlayerIn) && (yin+8'd30>=8'd89)) collideYes<=1'd1;
			else begin
				if(yin==7'd119) 
					yin<=0;
				else if(yin == 7'd68)
					enable_rand<=1;
				else enable_rand<=0;
			end
	end	
	assign LEDR[9]=collideYes;
	
	
    // Create an Instance of a VGA controller - there can be only one!
    // Define the number of colours as well as the initial background
    // image file (.MIF) for the controller.
    vga_adapter VGA(
            .resetn(1),
            .clock(CLOCK_50),
            .colour(DataColour),
            .x(x),
            .y(y),
            .plot(enable),
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
endmodule


module drawBackground(input clk, reset, enable, output[7:0] x, output [6:0] y, output [2:0] colour);
		backgroundImage bG(.address(memCounter),.clock(clk),.q(colour));//iterate through address and read colour from memory
		
	//assign ledr = memCounter;
	
	reg[14:0] memCounter;// = 10'b1;
	reg[7:0] xCounter;// = 8'b0;
	reg[6:0] yCounter;// = 8'b0;
	initial begin
		memCounter = 10'b0;
		xCounter = 8'b0;
		yCounter = 7'b0;
	end
	
	reg done = 1'b0;
	
	always@(posedge clk) begin
		if(reset == 1)begin
			xCounter <= 8'b0;
			yCounter <= 7'b0;
			memCounter <= 15'b0;
		end
		else if(enable)begin
			if (memCounter < 15'd19200) begin
				if(xCounter < 8'd159)begin
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
	
	assign x = xCounter;
	assign y = yCounter;

endmodule


module drawCar(input clk, reset, enable, input [7:0] xin, input[6:0] yin, output[7:0] x, output [6:0] y, output [2:0] colour);
	oppCar U100(.address(memCounter),.clock(clk),.q(colour));//iterate through address and read colour from memory
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
					if(yin + yCounter < 7'd120)
						yCounter <= yCounter + 1'b1;
						
				end
				memCounter <= memCounter + 1'b1;
			end
		end
		else begin
				xCounter <= 8'b0;
				yCounter <= 7'b0;
				memCounter <= 10'b0;
			end
	end
	
	assign x = xin+xCounter;
	assign y = yin+yCounter;

//	assign x = 8'b00100001+xCounter;
//	assign y = 7'b1011000+yCounter;

endmodule 

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


/****************************************************************/




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
    
//endmodule
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


//module drawBackground(clk, reset, enable, done, xCounter, yCounter, cout);
//	input clk;
//	input enable;
//	input reset;
//	output reg done;
//	output [2:0] cout;
//
//	output reg [7:0] xCounter;
//	output reg [6:0] yCounter;
//	reg [14:0] addressCounter;
//	
//	  
//	always@ (posedge clk) begin
//		if(reset) begin
//				done <= 0;
//				addressCounter <= 0;
//				xCounter <= 0;
//				yCounter <= 0;
//		end
//		else if(enable && !done) begin
//			if(addressCounter == 5'd19200)begin
//				done <= 1;
//			end
//			else begin
//				addressCounter <= addressCounter + 1;
//				if(xCounter == 3'd160) begin
//					xCounter <= 0;
//					yCounter <= yCounter +1;
//				end
//				else begin
//					xCounter <= xCounter +1;
//				end
//			end
//		end
//	end
//	backgroundImage bI(.address(addressCounter), .clock(clk), .q(cout));
//
//endmodule