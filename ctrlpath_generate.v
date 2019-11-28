module ctrlpath_generate(clk,resetn,lane_enable,collide_yes, draw_enable,draw_reset, erase_enable,draw_done,draw_done2,draw_enable2,draw_player_enable,draw_player_done,wait_enable);
	
	input resetn;
	input clk;
	input collide_yes;
	input [2:0] lane_enable;//3 bit signal that describes where to put generated car
	output draw_enable,draw_enable2; //Signal to draw
	output draw_player_enable;
	output draw_reset; //Signal that car has passed through the screen, generate new cars
	output erase_enable;
	output draw_done,draw_done2;
	output draw_player_done;
	
	
	
	output wait_enable;
	wire wait_done,erase_done;
	
	
	reg [2:0] current_state,next_state;
	reg [7:0] draw_count; //describes how many npc cars to generate
	reg[10:0] draw_counter;//describes how many cycles we draw for

	
	wire [1:0] carCount;
	assign carCount=/*3'd2;*/lane_enable[2]+lane_enable[1]+lane_enable[0];
	
	
	//STATES
	localparam ERASE=3'b000, DRAWPLAYER=3'b001, DRAW=3'b010, DRAW2=3'b011, WAIT=3'b100, GAMEOVER=3'b101;
	
	
	//TIMES
	localparam 	DRAW_COUNTER=27'd630, WAIT_COUNTER=27'd812242,ERASE_COUNTER=27'd19200, DRAW_PLAYER_COUNTER=27'd630,SPRITE_SIZE=1'b1;	
	//localparam DRAW_COUNTER=27'd2, WAIT_COUNTER=27'd3,ERASE_COUNTER=27'd4, DRAW_PLAYER_COUNTER=27'd2, SPRITE_SIZE=1'b1;



	
	//Counters
	counter U1(clk,DRAW_COUNTER,draw_enable,draw_done); 
	counter U5(clk,DRAW_COUNTER,draw_enable2,draw_done2); 
	counter U2(clk,DRAW_PLAYER_COUNTER,draw_player_enable,draw_player_done); 
	counter U3(clk,WAIT_COUNTER,wait_enable,wait_done);
	counter U4(clk,ERASE_COUNTER,erase_enable,erase_done);
	
	
	//Output signals
	assign draw_enable = (current_state==DRAW);
	assign draw_enable2 = (current_state==DRAW2);
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
						else if(carCount==2'd2)next_state=DRAW2;
						else next_state=WAIT;
					end
					else next_state=DRAW;
				end
			DRAW2:begin
					if(draw_done2==1'b1) begin
							if(collide_yes==1'b1) next_state=GAMEOVER;
							else next_state=WAIT;
					end
					else next_state=DRAW2;
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

endmodule

