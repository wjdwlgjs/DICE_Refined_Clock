`include "ClockTop.v"

module tb_ClockTop();

   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg			i_clk;			// To TestClock of ClockTop.v
   reg			i_down;			// To TestClock of ClockTop.v
   reg			i_left;			// To TestClock of ClockTop.v
   reg			i_mode;			// To TestClock of ClockTop.v
   reg			i_right;		// To TestClock of ClockTop.v
   reg			i_rstn;			// To TestClock of ClockTop.v
   reg			i_set;			// To TestClock of ClockTop.v
   reg			i_up;			// To TestClock of ClockTop.v
   // End of automatics
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [4:0]		o_hr;			// From TestClock of ClockTop.v
   wire [5:0]		o_min;			// From TestClock of ClockTop.v
   wire [5:0]		o_sec;			// From TestClock of ClockTop.v
   // End of automatics

   ClockTop TestClock(/*AUTOINST*/
		      // Outputs
		      .o_sec		(o_sec[5:0]),
		      .o_min		(o_min[5:0]),
		      .o_hr		(o_hr[4:0]),
		      // Inputs
		      .i_clk		(i_clk),
		      .i_rstn		(i_rstn),
		      .i_up		(i_up),
		      .i_down		(i_down),
		      .i_left		(i_left),
		      .i_right		(i_right),
		      .i_mode		(i_mode),
		      .i_set		(i_set));

   always #5 i_clk = ~i_clk;
   always @(negedge i_rstn) i_rstn = 1;

   always @(posedge i_up) #50 i_up <= 0;
   always @(posedge i_down) #50 i_down <= 0;
   always @(posedge i_right) #50 i_right <= 0;
   always @(posedge i_left) #50 i_left <= 0;
   always @(posedge i_mode) #50 i_mode <= 0;
   

   initial begin
      i_clk = 1;
      i_rstn = 0;

      i_down = 0;
      i_up = 0;
      i_mode = 0;
      i_right = 0;
      i_left = 0;

      #100;

      i_set = 1;

      #100;
      i_up = 1;

      #100; 
      i_down = 1;

      #100;
      i_right = 1;

      #100;

      i_up = 1;

      #100;
      i_down = 1;

      #100;
      i_right = 1;

      #100;

      i_up = 1;

      #100;

      i_down = 1;

      #100;

      i_right = 1;

      #100;
      i_up = 1;

      #100;

      i_left = 1;

      #100;
      i_up = 1;

      #100;
      i_left = 1;

      #100;
      i_up = 1;

      #100;

      i_up = 1;

      #100;
      i_mode = 1;

      #100;

      i_mode = 1;

      #100;

      i_set = 0;

      #100;

      i_up = 1;


      #1000;


      $finish;

      

      
   end // initial begin
   
      


endmodule // tb_ClockTop
