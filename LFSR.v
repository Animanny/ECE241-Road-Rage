module LFSR 
(
   input [3:0]KEY,
   input [9:0]SW,

 
   output [2:0] o_LFSR_Data,
   output o_LFSR_Done,
	output [9:0]LEDR
   );
 
  reg [3:1] r_LFSR = 0;
  reg r_XNOR;
  
	wire i_Enable,i_Seed_DV;
	
	assign i_Enable=SW[9];
	assign i_Seed_DV=SW[8];
	
	initial r_LFSR <= 1110;
	
	assign LEDR [2:0] = o_LFSR_Data [2:0];
 
  //run LFSR when enabled.
  always @(posedge ~KEY[0])
    begin
      if (i_Enable == 1'b1)
        begin
            r_LFSR <= {r_LFSR[2:1], r_XNOR};
        end
    end
	 
  always @(*)
    begin
          r_XNOR = r_LFSR[3] ^~ r_LFSR[2];
    end // always @ (*)
 
 
  assign o_LFSR_Data = r_LFSR[3:1];
 
  // Conditional Assignment (?)
  assign o_LFSR_Done = (r_LFSR[3:1] == 3'b110) ? 1'b1 : 1'b0;
  
 
   
endmodule // LFSR
