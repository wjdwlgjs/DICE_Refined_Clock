`include "CounterTwentyThree2.v"
`timescale 1ns/1ns

module tb_CounterTwentyThree2();
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg			i_clk;			// To TestCounter of CounterTwentyThree2.v
   reg			i_down;			// To TestCounter of CounterTwentyThree2.v
   reg			i_rstn;			// To TestCounter of CounterTwentyThree2.v
   reg			i_up;			// To TestCounter of CounterTwentyThree2.v
   // End of automatics
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			o_borrowdown;		// From TestCounter of CounterTwentyThree2.v
   wire			o_carryup;		// From TestCounter of CounterTwentyThree2.v
   wire [4:0]		o_count;		// From TestCounter of CounterTwentyThree2.v
   // End of automatics

   CounterTwentyThree2 TestCounter(/*AUTOINST*/
				   // Outputs
				   .o_count		(o_count[4:0]),
				   .o_carryup		(o_carryup),
				   .o_borrowdown	(o_borrowdown),
				   // Inputs
				   .i_clk		(i_clk),
				   .i_rstn		(i_rstn),
				   .i_up		(i_up),
				   .i_down		(i_down));

   always #5 i_clk = ~i_clk;

   always @(negedge i_rstn) #1 i_rstn = 1;

   initial begin
      i_clk = 0;
      i_rstn = 0;

      i_up = 0;
      i_down = 0;

      #100; 
      i_up = 1;

      #50000;
      i_down = 1;

      #100;

      i_up = 0;

      #50000;

      $finish;

   end // initial begin
endmodule // CounterTwentyThree2
