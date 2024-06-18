module KHzClkGen(/*AUTOARG*/);
   input i_clk;
   input i_rstn;
   input [31:0] i_count32;

   output reg	o_pulse;

   localparam [31:0] c_half = 32'd2499999;
   localparam [31:0] c_final = 32'd4999999;

   always @(posedge i_clk or negedge i_rstn) begin
      if (!i_rstn) o_pulse <= 1;
      else case(i_count32)
	     c_half: o_pulse <= 0;
	     c_final: o_pulse <= 1;
	     default: o_pulse <= o_pulse;
	   endcase // case (i_count32)
   end

endmodule // KHzClkGen

