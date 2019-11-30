module counter(CLOCK_50, count ,enable_count, enable);
	input CLOCK_50;
	input enable_count;
	input [26:0]count;
	
	reg [26:0] counter;
	output enable;

	initial counter <= 27'b000000000000000000000000000;
	assign enable = (counter == 27'b000000000000000000000000000) ? 1 : 0;
	
	
	always@(posedge CLOCK_50 && enable_count)
		begin
            if (counter >= count)
                counter <= 27'b000000000000000000000000000;
            else
                counter <= counter + 1;
		end
endmodule
