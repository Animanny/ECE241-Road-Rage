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

    wire [2:0] cCar,cCar2,cbg,cPlayer;
    wire [7:0] xbg,xcar,xcar2,xplayer;
    wire [6:0] ybg,ycar,ycar2,yplayer;

	 reg [7:0] x;
	 reg [6:0] y;
	 
	 
	 wire draw_enable,draw_enable2,erase_enable,draw_player_enable,wait_enable;
	 wire enable; //plot input to vgA adapter set to enable
    reg [2:0] DataColour;

	 
	 
	 assign enable = (draw_enable || erase_enable ||draw_player_enable || draw_enable2); //Plot enable signal
	 
	 
	 reg [7:0] xin,xin2,xPlayerIn;
	 reg [6:0] yin;
	 reg enable_rand;
	 
	 initial enable_rand = 1'd0;
	 initial xPlayerIn <= 8'd33;//left lane inital
	 initial xin<=8'd106;
	 initial xin2<=8'd106;
	 initial yin <=0;
	 
	 wire doneDraw,doneDraw2,doneDrawPlayer;
	 wire [2:0]lane_select;
	
	reg collideYes;
	initial collideYes<=0; 
	
	ctrlpath_generate ctrlpath(.clk(CLOCK_50),.resetn(1),.lane_enable(lane_select),.draw_enable(draw_enable),.collide_yes(collideYes), 
		.draw_reset(draw_reset), .erase_enable(erase_enable),.draw_done(doneDraw),.draw_done2(doneDraw2),
		.draw_player_enable(draw_player_enable),.draw_player_done(doneDrawPlayer),.wait_enable(wait_enable),.draw_enable2(draw_enable2)
	);
	
	
	drawBackground dB(.clk(CLOCK_50), .reset(~reset), .enable(erase_enable), .x(xbg), .y(ybg),.colour(cbg));
	drawCar U1000(.clk(CLOCK_50), .xin(xin), .yin(yin), .reset(~reset),.enable(draw_enable),.x(xcar),.y(ycar),.colour(cCar));
	drawCar U2000(.clk(CLOCK_50), .xin(xin2), .yin(yin), .reset(~reset),.enable(draw_enable2),.x(xcar2),.y(ycar2),.colour(cCar2));

	
	drawPlayer U2500(.clk(CLOCK_50), .reset(~reset), .enable(draw_player_enable), .xin(xPlayerIn), .yin(7'd89), .x(xplayer),.y(yplayer), .colour(cPlayer));
	LFSR random(.clk(CLOCK_50),.i_Enable(enable_rand),.o_LFSR_Data(lane_select));
	
   decimalDisplay displayhexstuff(!collideYes,CLOCK_50, HEX0, HEX1);
	
	reg drewOneCar  = 0;
	reg drewTwoCars =0;

	//Select location of cars
	always@(posedge enable_rand)
	begin
		drewOneCar <= 0;
		drewTwoCars<= 0;

		if (lane_select[0]==1)begin
				drewOneCar <= 1;
				xin= 8'd33;
			end
		if (lane_select[1]==1)begin
			if(drewOneCar == 0) begin //have not drawn car yet
				xin= 8'd69;
				drewOneCar <= 1;
			end
			else begin
				xin2 = 8'd69; //have drawn two cars
				drewTwoCars<=1;
				drewOneCar<=0; 
			end
		end
		if (lane_select[2]==1)begin
			if(drewOneCar == 0) begin 
				xin= 8'd106;
				drewOneCar <= 1;
			end
			else begin
				xin2 = 8'd106;		
				drewTwoCars<=1;
				drewOneCar<=0; 
			end
		end
		if(drewOneCar)xin2=xin;
	end				

	always@(negedge doneDraw)begin
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
		else if(draw_enable2)begin
			x<= xcar2;
			y<=ycar2;
			DataColour <= cCar2;			
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
	
	assign LEDR[0]=enable_rand;


	//Animate the random car, and determine when to generate a new one
	always@(negedge doneDraw)	
	begin
			yin<=yin+7'd1;
			//if(((xin == xPlayerIn) || (xin2 == xPlayerIn)) && (yin+8'd30>=8'd89)) collideYes<=1'd1;
			//else
			if(yin==7'd119) begin
					yin<=0;
					enable_rand<=1;
				end
			else enable_rand<=0;

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



