module decimalDisplay(CLOCK_50, HEX0, HEX1);
    input CLOCK_50;
	 
	 
    output [6:0] HEX0;
    output [6:0] HEX1;
	 
	 
	 reg[26:0] count;
    reg [3:0] ones;
	 reg [3:0] tens;
    reg [26:0] counter;
    wire enable;

    initial ones <= 4'b0;
	 initial tens <= 4'b0;
    initial count <= 27'b010111110101111000010000000;
    initial counter <= 27'b000000000000000000000000000;
    assign enable = (counter == 27'b000000000000000000000000000) ? 1 : 0;

    seg7decoder u1(ones, HEX0);
	 seg7decoder u2(tens, HEX1);

//    always@(*)
//        begin
//                2'b00: count = 27'b000000000000000000000000001;	50mhz
//                2'b01: count = 27'b001011111010111100001000000; 2 hz
//                2'b10: count = 27'b010111110101111000010000000; 1 hz
//                2'b11: count = 27'b101111101011110000100000000; 0.5 hz
//                default: count = 27'b000000000000000000000000001;
//            endcase
//        end

    always@(posedge CLOCK_50)
        begin
            if (counter >= count)
                counter <= 27'b000000000000000000000000000;
            else
                counter <= counter + 1;

            if (enable)
                ones <= ones + 1;
					 if(ones == 4'd10)
					 begin
						ones<=4'd0;
						tens<=tens+4'd1;
					end
					if(tens == 4'd10)
					 begin
						ones<=4'd0;
						tens<=4'd0;
					end
        end

endmodule

module seg7decoder (input [3:0]Input, output [6:0] HEX);
//Input[3] corresponds to c3, Input[2] to c2, Input[1] to c1, and Input[0] to c0

	assign HEX[0]= (~Input[3] & ~Input[2]  & ~Input[1]  & Input[0])+ (~Input[3] & Input[2]  & ~Input[1]  & ~Input[0]) + ( Input[3] & ~Input[2]  & Input[1]  & Input[0]) + (Input[3] & Input[2]  & ~Input[1]  &Input[0]);
	assign HEX[1]= (~Input[3] & Input[2]  & ~Input[1]  & Input[0]) + (~Input[3] & Input[2]  & Input[1]  & ~Input[0]) + (Input[3] & ~Input[2]  & Input[1]  & Input[0]) + (Input[3] & Input[2]  & ~Input[1]  & ~Input[0]) + (Input[3] & Input[2]  & Input[1]  & ~Input[0]) + (Input[3] & Input[2]  & Input[1]  & Input[0]);
	assign HEX[2]= (~Input[3] & ~Input[2]  & Input[1]  & ~Input[0]) + (Input[3] & Input[2]  & ~Input[1]  & ~Input[0]) + (Input[3] & Input[2]  & Input[1]  & ~Input[0]) + (Input[3] & Input[2]  & Input[1]  & Input[0]);
	assign HEX[3]= (~Input[3] & ~Input[2]  & ~Input[1]  & Input[0]) + (~Input[3] & Input[2]  & ~Input[1]  & ~Input[0]) + (~Input[3] & Input[2]  & Input[1]  & Input[0]) + (Input[3] & ~Input[2]  & ~Input[1]  & Input[0]) + (Input[3] & ~Input[2]  & Input[1]  & ~Input[0]) + (Input[3] & Input[2]  & Input[1]  & Input[0]);
	assign HEX[4]= (~Input[3] & ~Input[2]  & ~Input[1]  & Input[0]) + (~Input[3] & ~Input[2]  & Input[1]  & Input[0]) + (~Input[3] & Input[2]  & ~Input[1]  & ~Input[0]) + (~Input[3] & Input[2]  & ~Input[1]  & Input[0]) + (~Input[3] & Input[2]  & Input[1]  & Input[0]) + (Input[3] & ~Input[2]  & ~Input[1]  & Input[0]);
	assign HEX[5]= (~Input[3] & ~Input[2]  & ~Input[1]  & Input[0]) + (~Input[3] & ~Input[2]  & Input[1]  & ~Input[0]) + (~Input[3] & ~Input[2]  & Input[1]  & Input[0]) + (~Input[3] & Input[2]  & Input[1]  & Input[0]) + (Input[3] & Input[2]  & ~Input[1]  & Input[0]);
	assign HEX[6]= (~Input[3] & ~Input[2]  & ~Input[1]  & ~Input[0]) + (~Input[3] & ~Input[2]  & ~Input[1]  & Input[0]) + (~Input[3] & Input[2]  & Input[1]  & Input[0]) + (Input[3] & Input[2]  & ~Input[1]  & ~Input[0]);

endmodule