`include "CounterNNN.v"
`include "CounterFiftyNine2.v"
`include "CounterTwentyThree2.v"
`include "ClockControl.v"

module ClockModule(/*AUTOARG*/
   // Outputs
   o_sec, o_min, o_hr,
   // Inputs
   i_clk, i_down, i_left, i_right, i_rstn, i_set, i_up, i_ms_pulse
   );


   input			i_clk;			// To MSCounter of CounterNNN.v, ...
   input			i_down;			// To MSCounter of CounterNNN.v, ...
   input			i_left;			// To Controller of ClockControl.v
   input			i_right;		// To Controller of ClockControl.v
   input			i_rstn;			// To MSCounter of CounterNNN.v, ...
   input			i_set;			// To Controller of ClockControl.v
   input			i_up;			// To MSCounter of CounterNNN.v, ...
   input			i_ms_pulse;
   input			i_summertime;

   output [5:0] 		o_sec;
   output [5:0] 		o_min;
   output [4:0] 		o_hr;
   
   wire			w_min_carryup;		// To Controller of ClockControl.v
   wire			w_ms_carryup;		// To Controller of ClockControl.v
   wire			w_sec_carryup;		// To Controller of ClockControl.v

   wire			w_hr_down;		// From Controller of ClockControl.v
   wire			w_hr_up;		// From Controller of ClockControl.v
   wire			w_min_down;		// From Controller of ClockControl.v
   wire			w_min_up;		// From Controller of ClockControl.v
   wire			w_ms_down;		// From Controller of ClockControl.v
   wire			w_ms_up;		// From Controller of ClockControl.v
   wire			w_sec_down;		// From Controller of ClockControl.v
   wire			w_sec_up;		// From Controller of ClockControl.v

   wire [5:0] 		w_sec;
   wire [5:0] 		w_min;
   wire [4:0] 		w_hr;

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
				 .o_carryup		(),
				 .o_borrowdown		(),
				 // Inputs
				 .i_clk			(i_clk),
				 .i_rstn		(i_rstn),
				 .i_up			(w_hr_up),
				 .i_down		(w_hr_down),
				 .i_summertime          (i_summertime));

   ClockControl Controller(// Outputs
			   .o_ms_up		(w_ms_up),
			   .o_ms_down		(w_ms_down),
			   .o_sec_up		(w_sec_up),
			   .o_sec_down		(w_sec_down),
			   .o_min_up		(w_min_up),
			   .o_min_down		(w_min_down),
			   .o_hr_up		(w_hr_up),
			   .o_hr_down		(w_hr_down),
			   // Inputs
			   .i_clk		(i_clk),
			   .i_rstn		(i_rstn),
			   .i_set		(i_set),
			   .i_up		(i_up),
			   .i_down		(i_down),
			   .i_left		(i_left),
			   .i_right		(i_right),
			   .i_ms_pulse          (i_ms_pulse),
			   .i_ms_carryup	(w_ms_carryup),
			   .i_sec_carryup	(w_sec_carryup),
			   .i_min_carryup	(w_min_carryup));
   

endmodule // ClockModule

