module LFSR 
(
   input clk,
   input i_Enable,

 
   output [2:0] o_LFSR_Data
   );
 
  reg [3:1] r_LFSR = 0;
  reg r_XNOR;
	
	
	initial r_LFSR <= 1010;
	
	//assign LEDR [2:0] = o_LFSR_Data[2:0];
 
  //run LFSR when enabled.
  always @(posedge clk)
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
  
endmodule // LFSR
