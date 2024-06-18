`include "ClockModule.v"
`timescale 1ns/1ns

module tb_ClockModule();

   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg			i_clk;			// To TestClock of ClockModule.v
   reg			i_down;			// To TestClock of ClockModule.v
   reg			i_left;			// To TestClock of ClockModule.v
   reg			i_right;		// To TestClock of ClockModule.v
   reg			i_rstn;			// To TestClock of ClockModule.v
   reg			i_set;			// To TestClock of ClockModule.v
   reg			i_up;			// To TestClock of ClockModule.v
   // End of automatics
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [4:0]		o_hr;			// From TestClock of ClockModule.v
   wire [5:0]		o_min;			// From TestClock of ClockModule.v
   wire [5:0]		o_sec;			// From TestClock of ClockModule.v
   // End of automatics

   ClockModule TestClock(/*AUTOINST*/
			 // Outputs
			 .o_sec			(o_sec[5:0]),
			 .o_min			(o_min[5:0]),
			 .o_hr			(o_hr[4:0]),
			 // Inputs
			 .i_clk			(i_clk),
			 .i_down		(i_down),
			 .i_left		(i_left),
			 .i_right		(i_right),
			 .i_rstn		(i_rstn),
			 .i_set			(i_set),
			 .i_up			(i_up));

   always #5 i_clk = ~i_clk;

   always @(negedge i_rstn) #1 i_rstn = 1;

   always @(posedge i_up) #10 i_up <= 0;
   always @(posedge i_down) #10 i_down <= 0;
   always @(posedge i_right) #10 i_right <= 0;
   always @(posedge i_left) #10 i_left <= 0;

   initial begin
      i_clk = 0;
      i_rstn = 0;
      i_set = 0;
      i_down = 0;
      i_up = 0;
      i_left = 0;
      i_right = 0;

      #100;

      i_up = 1;

      #20;
      i_down = 1;
      #20;
      i_right = 1;
      #20;
      i_left = 1;

      #20;

      i_set = 1;

      #40;
      i_up = 1;

      #40;
      i_down = 1;

      #40;
      i_set = 0;

      #40;
      i_set = 1;

      #40;
      i_left = 1;

      #40;
      i_up = 1;

      #40;
      i_down = 1;

      #40;
      i_set = 0;

      #40;
      i_set = 1;

      #40;
      i_right = 1;

      #40;
      i_up = 1;

      #40;

      i_down = 1;

      #40;
      i_set = 0;

      #5000000;

      $finish;
   end // initial begin
endmodule // tb_ClockModule

      
