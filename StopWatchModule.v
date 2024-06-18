module StopWatchModule(/*AUTOARG*/
   // Outputs
   o_sec, o_min, o_hr,
   // Inputs
   i_clk, i_rstn, i_set, i_up, i_down, i_right, i_left
   );

   input i_clk;
   input i_rstn;
   input i_set;
   input i_up;
   input i_down;
   input i_right;
   input i_left;

   output [5:0] o_sec;
   output [5:0] o_min;
   output [4:0] o_hr;

   wire  w_ms_carryup;
   wire  w_sec_carryup;
   wire  w_min_carryup;
   wire  w_hr_carryup; // counters -> control

   wire  w_ms_up;
   wire  w_ms_down;
   wire  w_sec_up;
   wire  w_sec_down;
   wire  w_min_up;
   wire  w_min_down;
   wire  w_hr_up;
   wire  w_hr_down; // control -> counters

   wire [5:0] w_sec;
   wire [5:0] w_min;
   wire [4:0] w_hr; // counters -> output

   assign o_sec = w_sec;
   assign o_min = w_min;
   assign o_hr = w_hr;

   CounterNNN MSCounter(// Outputs
			.o_carryup	(w_ms_carryup),
			.o_borrowdown	(),
			.o_count(),
			// Inputs
			.i_clk		(i_clk),
			.i_rstn		(i_rstn),
			.i_up		(w_ms_up),
			.i_down		(w_ms_down));

   CounterFiftyNine2 SecCounter(// Outputs
				.o_count	(w_sec[5:0]),
				.o_carryup	(w_sec_carryup),
				.o_borrowdown	(),
				// Inputs
				.i_clk		(i_clk),
				.i_rstn		(i_rstn),
				.i_up		(w_sec_up),
				.i_down		(w_sec_down));

   CounterFiftyNine2 MinCounter(// Outputs
				.o_count	(w_min[5:0]),
				.o_carryup	(w_min_carryup),
				.o_borrowdown	(),
				// Inputs
				.i_clk		(i_clk),
				.i_rstn		(i_rstn),
				.i_up		(w_min_up),
				.i_down		(w_min_down));

   CounterTwentyThree2 HrCounter(// Outputs
				 .o_count		(w_hr[4:0]),
				 .o_carryup		(w_hr_carryup),
				 .o_borrowdown		(),
				 // Inputs
				 .i_clk			(i_clk),
				 .i_rstn		(i_rstn),
				 .i_up			(w_hr_up),
				 .i_down		(w_hr_down));
   

   StopWatchControl Controller(// Outputs
			       .o_ms_up		(w_ms_up),
			       .o_ms_down	(w_ms_down),
			       .o_sec_up	(w_sec_up),
			       .o_sec_down	(w_sec_down),
			       .o_min_up	(w_min_up),
			       .o_min_down	(w_min_down),
			       .o_hr_up		(w_hr_up),
			       .o_hr_down	(w_hr_down),
			       // Inputs
			       .i_clk		(i_clk),
			       .i_rstn		(i_rstn),
			       .i_set		(i_set),
			       .i_up            (i_up),
			       .i_down          (i_down),
			       .i_right         (i_right),
			       .i_left          (i_left),
			       .i_ms_carryup	(w_ms_carryup),
			       .i_sec_carryup	(w_sec_carryup),
			       .i_min_carryup	(w_min_carryup),
			       .i_hr_carryup	(w_hr_carryup));

   

endmodule // StopWatchModule


    
