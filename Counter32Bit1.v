module Counter32Bit1(/*AUTOARG*/
   // Outputs
   o_count,
   // Inputs
   i_clk, i_rstn, i_enable
   );

   input i_clk;
   input i_rstn;
   input i_enable;

   output [31:0] o_count;
   output	 o_ms_pulse;

   reg [31:0] r_count;
   localparam [31:0] c_limit = 32'd4999999;

   assign o_ms_pulse = r_count == c_limit;

   always @(posedge i_clk or negedge i_rstn) begin
      if (!i_rstn) r_count <= 32'd0;
      else case(i_enable)
	     1'b1: r_count <= r_count + 32'd1;
	     1'b0: r_count <= 32'd0;
	     
	   endcase // case (i_enable)
   end

   assign o_count = r_count;

endmodule // Counter32Bit1

