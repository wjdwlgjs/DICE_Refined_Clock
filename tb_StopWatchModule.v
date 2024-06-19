`include "StopWatchModule.v"

module tb_StopWatchModule(/*AUTOARG*/);
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg			i_clk;			// To TestStopwatch of StopWatchModule.v
   reg			i_down;			// To TestStopwatch of StopWatchModule.v
   reg			i_left;			// To TestStopwatch of StopWatchModule.v
   reg			i_ms_pulse;		// To TestStopwatch of StopWatchModule.v
   reg			i_right;		// To TestStopwatch of StopWatchModule.v
   reg			i_rstn;			// To TestStopwatch of StopWatchModule.v
   reg			i_set;			// To TestStopwatch of StopWatchModule.v
   reg			i_up;			// To TestStopwatch of StopWatchModule.v
   // End of automatics
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [4:0]		o_hr;			// From TestStopwatch of StopWatchModule.v
   wire [5:0]		o_min;			// From TestStopwatch of StopWatchModule.v
   wire [5:0]		o_sec;			// From TestStopwatch of StopWatchModule.v
   // End of automatics

   StopWatchModule TestStopwatch(/*AUTOINST*/
				 // Outputs
				 .o_sec			(o_sec[5:0]),
				 .o_min			(o_min[5:0]),
				 .o_hr			(o_hr[4:0]),
				 // Inputs
				 .i_clk			(i_clk),
				 .i_rstn		(i_rstn),
				 .i_set			(i_set),
				 .i_up			(i_up),
				 .i_down		(i_down),
				 .i_right		(i_right),
				 .i_left		(i_left),
				 .i_ms_pulse		(i_ms_pulse));

   always #5 i_clk = ~i_clk;
   always #30 i_ms_pulse = 1'b1;

   always @(posedge i_ms_pulse) #10 i_ms_pulse = 0;

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

      #40;
      i_down = 1;
      #40;
      i_right = 1;
      #40;
      i_left = 1;

      #40;

      #40;
      i_up = 1;

      #40;
      i_down = 1;

      #40;

      #40;

      #40;
      i_left = 1;

      #40;
      i_up = 1;

      #40;
      i_down = 1;

      #40;

      #40;
      i_right = 1;

      #40;
      i_up = 1;

      #40;


      #40;

      #5000000;

      $finish;
   end // initial begin
   

endmodule // tb_StopWatchModule
