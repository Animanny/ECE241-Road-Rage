module ctrlpath_generate(clk,resetn,lane_enable,collide_yes, draw_enable,draw_reset, erase_enable,draw_done,draw_player_enable,draw_player_done);
	
	input resetn;
	input clk;
	input collide_yes;
	input [2:0] lane_enable;//3 bit signal that describes where to put generated car
	output draw_enable; //Signal to draw
	output draw_player_enable;
	output draw_reset; //Signal that car has passed through the screen, generate new cars
	output erase_enable;
	output draw_done;
	output draw_player_done;
	
	
	
	wire wait_enable;
	wire wait_done,erase_done;
	
	
	reg [2:0] current_state,next_state;
	reg [7:0] draw_count; //describes how many npc cars to generate
	reg[10:0] draw_counter;//describes how many cycles we draw for

	
//	wire [1:0] carCount;
//	assign carCount=lane_enable[2]+lane_enable[1]+lane_enable[0];
	
	
	//STATES
	localparam ERASE=3'b000, DRAWPLAYER=3'b001, DRAW=3'b010, WAIT=3'b011, GAMEOVER=3'b100;
	
	
	//TIMES
	localparam 	DRAW_COUNTER=27'd630, WAIT_COUNTER=27'd800000,ERASE_COUNTER=27'd19200, DRAW_PLAYER_COUNTER=27'd630,SPRITE_SIZE=1'b1;	
	//localparam DRAW_COUNTER=27'd2, WAIT_COUNTER=27'd3,ERASE_COUNTER=27'd4, DRAW_PLAYER_COUNTER=27'd2, SPRITE_SIZE=1'b1;
	initial begin
		draw_count<=8'd0;
	end


	
	//Counters
	counter U1(clk,DRAW_COUNTER,draw_enable,draw_done); //draw for 3 clock cycles
	counter U2(clk,DRAW_PLAYER_COUNTER,draw_player_enable,draw_player_done); //draw for 3 clock cycles
	counter U3(clk,WAIT_COUNTER,wait_enable,wait_done);
	counter U4(clk,ERASE_COUNTER,erase_enable,erase_done);
	
	
	//Output signals
	assign draw_enable = (current_state==DRAW);
	assign wait_enable = (current_state==WAIT);
	assign erase_enable= (current_state==ERASE);
	assign draw_player_enable = (current_state==DRAWPLAYER);
	
	always@(*)
	begin: state_table
		case(current_state)
			ERASE:begin
					if(erase_done ==1'b1) next_state=DRAWPLAYER;
					else next_state=ERASE;
					end
			DRAWPLAYER:begin
					if(draw_player_done == 1'b1) next_state = DRAW;
					else next_state = DRAWPLAYER;
				end
			DRAW:begin
					if(draw_done==1'b1) begin
						if(collide_yes==1'b1) next_state=GAMEOVER;
						else next_state=WAIT;
					end
					else next_state=DRAW;
				end
			WAIT:begin
					if (wait_done==1'b1) next_state=ERASE;
					else next_state=WAIT;
				end
			GAMEOVER:begin
					next_state=GAMEOVER;
				end
			default: next_state=WAIT;
		endcase
	end //end state table
	
	//State register
	always @(posedge clk)
	begin: state_FFS
		if(resetn ==1'b0)
			current_state<=WAIT;
		else
			current_state<=next_state;
	end

//	always@(posedge clk)
//	begin
//		if(draw_done==1'd1) draw_count<=draw_count+8'b1;
//		if(draw_count==7'd2)draw_counter<=(lane_enable[2]+lane_enable[1]+lane_enable[0])*SPRITE_SIZE; //find out how many cars we need to draw
//	end
	
endmodule

