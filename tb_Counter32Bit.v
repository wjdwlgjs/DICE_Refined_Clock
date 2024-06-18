`include "Counter32Bit1.v"
`include "Counter32Bit2.v"
`timescale 1ns/1ns

module tb_Counter32Bit();

   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg			i_clk;			// To TestCounter2 of Counter32Bit2.v
   reg			i_enable;		// To TestCounter2 of Counter32Bit2.v
   reg			i_rstn;			// To TestCounter2 of Counter32Bit2.v
   // End of automatics
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [31:0]		o_count;		// From TestCounter2 of Counter32Bit2.v
   // End of automatics
   

   /*Counter32Bit1 TestCounter1(
			      // Outputs
			      .o_count		(o_count[31:0]),
			      // Inputs
			      .i_clk		(i_clk),
			      .i_rstn		(i_rstn),
			      .i_enable		(i_enable));*/

   Counter32Bit2 TestCounter2(/*AUTOINST*/
			      // Outputs
			      .o_count		(o_count[31:0]),
			      // Inputs
			      .i_clk		(i_clk),
			      .i_rstn		(i_rstn),
			      .i_enable		(i_enable));
   

   always #1 i_clk = ~i_clk;

   always @(negedge i_rstn) #1 i_rstn <= 1;

   initial begin
      i_rstn = 0;
      i_clk = 0;
      i_enable = 0;

      #50;

      i_enable <= 1;


      #30000000;

      $finish;

   end
endmodule // tb_Counter32Bit

      
