module ClockTop(/*AUTOARG*/
   // Outputs
   o_sec, o_min, o_hr,
   // Inputs
   i_clk, i_rstn, i_up, i_down, i_left, i_right, i_mode, i_summertime
   );

   input i_clk;
   input i_rstn;

   input i_up;
   input i_down;
   input i_left;
   input i_right;
   input i_mode;
   input i_summertime;

   output [5:0] o_sec;
   output [5:0] o_min;
   output [4:0] o_hr;

   reg [1:0] r_cur_state;

   localparam [1:0] c_clock_mode = 2'b00;
   localparam [1:0] c_stopwatch_mode = 2'b01;
   localparam [1:0] c_timer_mode = 2'b10;

   wire		    w_ms_pulse;

   wire      w_clock_set;
   wire      w_clock_up;
   wire      w_clock_down;
   wire      w_clock_left;
   wire      w_clock_right;

   wire [5:0]     w_clock_sec;
   wire [5:0]     w_clock_min;
   wire [4:0]     w_clock_hr;

   wire      w_stopwatch_set;
   wire      w_stopwatch_up;
   wire      w_stopwatch_down;
   wire      w_stopwatch_right;
   wire      w_stopwatch_left;

   wire [5:0] w_stopwatch_sec;
   wire [5:0] w_stopwatch_min;
   wire [5:0] w_stopwatch_hr;

   wire       w_timer_set;
   wire       w_timer_up;
   wire       w_timer_down;
   wire       w_timer_left;
   wire       w_timer_right;

   wire [5:0] w_timer_sec;
   wire [5:0] w_timer_min;
   wire [4:0] w_timer_hr;

   always @(posedge i_clk or negedge i_rstn) begin
      if (!i_rstn) r_cur_state <= 2'b00;
      else
	case({r_cur_state, i_mode})
	  {c_clock_mode, 1'b0}: r_cur_state <= c_clock_mode;
	  {c_clock_mode, 1'b1}: r_cur_state <= c_stopwatch_mode;
	  {c_stopwatch_mode, 1'b0}: r_cur_state <= c_stopwatch_mode;
	  // {c_stopwatch_mode, 1'b1} r_cur_state <= c_timer_mode;
	  // {c_timer_mode, 1'b0} r_cur_state <= c_timer_mode;
	  // {c_timer_mode, 1'b1} r_cur_state <= c_clock_mode;
	  {c_stopwatch_mode, 1'b1}: r_cur_state <= c_clock_mode;
	  default: r_cur_state <= c_clock_mode;

	endcase // case ({r_cur_state, i_mode})
   end // always @ (posedge i_clk or negedge i_rstn)

   assign {w_clock_set, w_clock_up, w_clock_down, w_clock_left, w_clock_right} = {5{(r_cur_state == c_clock_mode)}} & {i_set, i_up, i_down, i_left, i_right};

   assign {w_stopwatch_set, w_stopwatch_up, w_stopwatch_down, w_stopwatch_left, w_stopwatch_right} = {5{(r_cur_state == c_stopwatch_mode)}} & {i_set, i_up, i_down, i_left, i_right};

   assign {w_timer_set, w_timer_up, w_timer_down, w_timer_left, w_timer_right} = {5{(r_cur_state == c_timer_mode)}} & {i_set, i_up, i_down, i_left, i_right};

   assign o_sec = (w_clock_sec & {6{(r_cur_state == c_clock_mode)}}) | (w_stopwatch_sec & {6{(r_cur_state == c_stopwatch_mode)}}) | (w_timer_sec & {6{(r_cur_state == c_timer_mode)}});

   assign o_min = (w_clock_min & {6{(r_cur_state == c_clock_mode)}}) | (w_stopwatch_min & {6{(r_cur_state == c_stopwatch_mode)}}) | (w_timer_min & {6{(r_cur_state == c_timer_mode)}});

   assign o_hr = (w_clock_hr & {5{(r_cur_state == c_clock_mode)}}) | (w_stopwarch_hr & {5{(r_cur_state == c_stopwatch_mode)}}) | (w_timer_hr & {5{(r_cur_state == c_timer_mode)}});

   Counter32Bit2 MSPulseGen(// Outputs
			    .o_count		(),
			    .o_ms_pulse		(o_ms_pulse),
			    // Inputs
			    .i_clk		(i_clk),
			    .i_rstn		(i_rstn),
			    .i_enable		(1'b1));
   

   ClockModule Clock(// Outputs
		     .o_sec		(w_clock_sec[5:0]),
		     .o_min		(w_clock_min[5:0]),
		     .o_hr		(w_clock_hr[4:0]),
		     // Inputs
		     .i_clk		(i_clk),
		     .i_down		(w_clock_down),
		     .i_left		(w_clock_left),
		     .i_right		(w_clock_right),
		     .i_rstn		(i_rstn),
		     .i_set		(w_clock_set),
		     .i_up		(w_clock_up),
		     .i_ms_pulse        (w_ms_pulse),
		     .i_summertime      (i_summertime));
   

   StopWatchModule StopWatch(// Outputs
			     .o_sec		(w_stopwatch_sec[5:0]),
			     .o_min		(w_stopwatch_min[5:0]),
			     .o_hr		(w_stopwatch_hr[4:0]),
			     // Inputs
			     .i_clk		(i_clk),
			     .i_rstn		(i_rstn),
			     .i_set		(w_stopwatch_set),
			     .i_up		(w_stopwatch_up),
			     .i_down		(w_stopwatch_down),
			     .i_right		(w_stopwatch_right),
			     .i_left		(w_stopwatch_left),
			     .i_ms_pulse        (w_ms_pulse));

   /* TimerModule Timer(// Outputs
		     .o_sec		(w_timer_sec[5:0]),
		     .o_min		(w_timer_min[5:0]),
		     .o_hr		(w_timer_hr[4:0]),
		     // Inputs
		     .i_clk		(i_clk),
		     .i_rstn		(i_rstn),
		     .i_set		(w_timer_set),
		     .i_up		(w_timer_up),
		     .i_down		(w_timer_down),
		     .i_left		(w_timer_left),
		     .i_right		(w_timer_right)); */

   

endmodule // ClockTop


   

   
   
   
   
   
