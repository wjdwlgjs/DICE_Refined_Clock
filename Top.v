module Top(/*AUTOARG*/
   // Outputs
   SECOND, MINUTES, HOURS, O_MC,
   // Inputs
   CLK, RSTN, SET, UP, DOWN, LEFT, RIGHT, I_MC, i_mode, i_summertime_set
   );
   input CLK;
   input RSTN;
   input SET;
   input UP;
   input DOWN;
   input LEFT;
   input RIGHT;
   input [7:0] I_MC;
   input i_mode;
   input i_summertime_set;
   

   output [5:0] SECOND;
   output [5:0] MINUTES;
   output [4:0] HOURS;
   output [9:0] O_MC; 




   ClockTop i0(
	       // Outputs
	       .o_sec			(SECOND[5:0]),
	       .o_min			(MINUTES[5:0]),
	       .o_hr			(HOURS[4:0]),
	       // Inputs
	       .i_clk			(CLK),
	       .i_rstn			(RSTN),
	       .i_up			(UP),
	       .i_down			(DOWN),
	       .i_left			(LEFT),
	       .i_right			(RIGHT),
	       .i_mode			(i_mode),
	       .i_summertime_set        (i_summertime_set));
   

   

endmodule // Top
///////////////////////////////////////////////////////////////////////
//                                                                   //
//                                                                   //
//                                                                   //
///////////////////////////////////////////////////////////////////////
module ClockControl(/*AUTOARG*/
   // Outputs
   o_ms_up, o_ms_down, o_sec_up, o_sec_down, o_min_up, o_min_down,
   o_hr_up, o_hr_down,
   // Inputs
   i_clk, i_rstn, i_set, i_up, i_down, i_left, i_right, i_ms_carryup,
   i_sec_carryup, i_min_carryup, i_summertime_set
   );

   input i_clk;
   input i_rstn;
   input i_set;
   input i_up;
   input i_down;
   input i_left;
   input i_right;

   input i_ms_carryup;
   input i_sec_carryup;
   input i_min_carryup;
   input i_summertime_set;
   

   output o_ms_up;
   output o_ms_down;
   output o_sec_up;
   output o_sec_down;
   output o_min_up;
   output o_min_down;
   output o_hr_up;
   output o_hr_down;

   reg [1:0] r_cur_state;
   reg 	     r_summertime_applied; // chasing whether summertime applied or not

   localparam [1:0] c_run = 2'b00;
   localparam [1:0] c_set_sec = 2'b01;
   localparam [1:0] c_set_min = 2'b10;
   localparam [1:0] c_set_hr = 2'b11;

   assign o_ms_up = 1'b1;
   assign o_ms_down = r_cur_state != c_run; // clear and keep at 0 in set modes
   // set, up inputs are all synchronized, so this doesn't make this a mealy
   // machine?
   // count up if set sec mode, and up button pressed. (clear if up/down both
   // pressed in set sec mode. count up if ms counter is
   // carrying up.
   assign o_sec_up = ({r_cur_state, i_set, i_up} == {c_set_sec, 2'b11}) | ({r_cur_state, i_ms_carryup} == {c_run, 1'b1});
   assign o_sec_down = ({r_cur_state, i_set, i_down} == {c_set_sec, 2'b11});

   assign o_min_up = ({r_cur_state, i_set, i_up} == {c_set_min, 2'b11}) | ({r_cur_state, i_sec_carryup} == {c_run, 1'b1});
   assign o_min_down = ({r_cur_state, i_set, i_down} == {c_set_min, 2'b11});

   assign o_hr_up = ({r_cur_state, i_set, i_up} == {c_set_hr, 2'b11}) | ({r_cur_state, i_min_carryup} == {c_run, 1'b1});
   assign o_hr_down = ({r_cur_state, i_set, i_down} == {c_set_hr, 2'b11}) | i_summertime_set;

   //appliy summertime: if i_summer_time, time decrease 1hour
   
   always @(posedge i_clk or negedge i_rstn) begin 
      if (!i_rstn) begin
	 r_cur_state <= c_run;
	 r_summertime_applied <= 1'b0;
      end     
      else begin
	 if (i_summertime_set) begin
	    r_summertime_applied <= 1'b1;
	 end	 
	 case({r_cur_state, i_set}) 
	   {c_run, 1'b1}: r_cur_state <= c_set_sec;
	   {c_set_sec, 1'b1}: begin
	      case({i_left, i_right}) 
		2'b01: r_cur_state <= c_set_hr;
		2'b10: r_cur_state <= c_set_min;
		default: r_cur_state <= r_cur_state;
	      endcase
	   end
	   {c_set_min, 1'b1}: begin
	      case({i_left, i_right})
		2'b01: r_cur_state <= c_set_sec;
		2'b10: r_cur_state <= c_set_hr;
		default: r_cur_state <= r_cur_state;
	      endcase
	   end
	   {c_set_hr, 1'b1}: begin
	      case({i_left, i_right}) 
		2'b01: r_cur_state <= c_set_min;
		2'b10: r_cur_state <= c_set_sec;
		default: r_cur_state <= r_cur_state;
	      endcase
	  end
	  default: r_cur_state <= c_run;

	endcase // case ({r_cur_state, i_set})
      end // else: !if(!i_rstn)
   end // always @ (posedge i_clk or negedge i_rstn)
   
endmodule // ClockControl
///////////////////////////////////////////////////////////////////////
//                                                                   //
//                                                                   //
//                                                                   //
///////////////////////////////////////////////////////////////////////
module ClockModule(
    // Outputs
    o_sec, o_min, o_hr,
    // Inputs
    i_clk, i_down, i_left, i_right, i_rstn, i_set, i_up, i_summertime_set
    );

    input i_clk;
    input i_down;
    input i_left;
    input i_right;
    input i_rstn;
    input i_set;
    input i_up;
    input i_summertime_set; // setting summertime

    output [5:0] o_sec;
    output [5:0] o_min;
    output [4:0] o_hr;

    wire w_min_carryup;
    wire w_ms_carryup;
    wire w_sec_carryup;

    wire w_hr_down;
    wire w_hr_up;
    wire w_min_down;
    wire w_min_up;
    wire w_ms_down;
    wire w_ms_up;
    wire w_sec_down;
    wire w_sec_up;

    wire [5:0] w_sec;
    wire [5:0] w_min;
    wire [4:0] w_hr;

    assign o_sec = w_sec;
    assign o_min = w_min;
    assign o_hr = w_hr;

    CounterNNN MSCounter(
        .o_carryup(w_ms_carryup),
        .o_borrowdown(),
        .o_count(),
        .i_clk(i_clk),
        .i_rstn(i_rstn),
        .i_up(w_ms_up),
        .i_down(w_ms_down)
    );

    CounterFiftyNine2 SecCounter(
        .o_count(w_sec[5:0]),
        .o_carryup(w_sec_carryup),
        .o_borrowdown(),
        .i_clk(i_clk),
        .i_rstn(i_rstn),
        .i_up(w_sec_up),
        .i_down(w_sec_down)
    );

    CounterFiftyNine2 MinCounter(
        .o_count(w_min[5:0]),
        .o_carryup(w_min_carryup),
        .o_borrowdown(),
        .i_clk(i_clk),
        .i_rstn(i_rstn),
        .i_up(w_min_up),
        .i_down(w_min_down)
    );

    CounterTwentyThree2 HrCounter(
        .o_count(w_hr[4:0]),
        .o_carryup(),
        .o_borrowdown(),
        .i_clk(i_clk),
        .i_rstn(i_rstn),
        .i_up(w_hr_up),
        .i_down(w_hr_down)
    );

    ClockControl Controller(
        .o_ms_up(w_ms_up),
        .o_ms_down(w_ms_down),
        .o_sec_up(w_sec_up),
        .o_sec_down(w_sec_down),
        .o_min_up(w_min_up),
        .o_min_down(w_min_down),
        .o_hr_up(w_hr_up),
        .o_hr_down(w_hr_down),
        .i_clk(i_clk),
        .i_rstn(i_rstn),
        .i_set(i_set),
        .i_up(i_up),
        .i_down(i_down),
        .i_left(i_left),
        .i_right(i_right),
        .i_ms_carryup(w_ms_carryup),
        .i_sec_carryup(w_sec_carryup),
        .i_min_carryup(w_min_carryup),
        .i_summertime_set(i_summertime_set) 
    );
endmodule // ClockModule
///////////////////////////////////////////////////////////////////////
//                                                                   //
//                                                                   //
//                                                                   //
///////////////////////////////////////////////////////////////////////
module ClockTop(/*AUTOARG*/
   // Outputs
   o_sec, o_min, o_hr,
   // Inputs
   i_clk, i_rstn, i_set, i_up, i_down, i_left, i_right, i_mode,
   i_summertime_set
   );

   input i_clk;
   input i_rstn;
   input i_set;
   
   input i_up;
   input i_down;
   input i_left;
   input i_right;
   input i_mode;
   input i_summertime_set;
   

   output [5:0] o_sec;
   output [5:0] o_min;
   output [4:0] o_hr;

   reg [1:0] r_cur_state;

   localparam [1:0] c_clock_mode = 2'b00;
   localparam [1:0] c_stopwatch_mode = 2'b01;
   localparam [1:0] c_timer_mode = 2'b10;

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
	  {c_stopwatch_mode, 1'b1}: r_cur_state <= c_timer_mode;
	  {c_timer_mode, 1'b0}: r_cur_state <= c_timer_mode;
	  {c_timer_mode, 1'b1}: r_cur_state <= c_clock_mode;
	  default: r_cur_state <= c_clock_mode;

	endcase // case ({r_cur_state, i_mode})
   end // always @ (posedge i_clk or negedge i_rstn)

   assign {w_clock_set, w_clock_up, w_clock_down, w_clock_left, w_clock_right} = {5{(r_cur_state == c_clock_mode)}} & {i_set, i_up, i_down, i_left, i_right};

   assign {w_stopwatch_set, w_stopwatch_up, w_stopwatch_down, w_stopwatch_left, w_stopwatch_right} = {5{(r_cur_state == c_stopwatch_mode)}} & {i_set, i_up, i_down, i_left, i_right};

   assign {w_timer_set, w_timer_up, w_timer_down, w_timer_left, w_timer_right} = {5{(r_cur_state == c_timer_mode)}} & {i_set, i_up, i_down, i_left, i_right};

   assign o_sec = (w_clock_sec & {6{(r_cur_state == c_clock_mode)}}) | (w_stopwatch_sec & {6{(r_cur_state == c_stopwatch_mode)}}) | (w_timer_sec & {6{(r_cur_state == c_timer_mode)}});

   assign o_min = (w_clock_min & {6{(r_cur_state == c_clock_mode)}}) | (w_stopwatch_min & {6{(r_cur_state == c_stopwatch_mode)}}) | (w_timer_min & {6{(r_cur_state == c_timer_mode)}});

   assign o_hr = (w_clock_hr & {5{(r_cur_state == c_clock_mode)}}) | (w_stopwatch_hr & {5{(r_cur_state == c_stopwatch_mode)}}) | (w_timer_hr & {5{(r_cur_state == c_timer_mode)}});
   

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
		     .i_summertime_set  (i_summertime_set));

   StopWatchModule StopWatch(/*AUTOINST*/
			     // Outputs
			     .o_sec		(o_sec[5:0]),
			     .o_min		(o_min[5:0]),
			     .o_hr		(o_hr[4:0]),
			     // Inputs
			     .i_clk		(i_clk),
			     .i_rstn		(i_rstn),
			     .i_set		(i_set),
			     .i_up		(i_up),
			     .i_down		(i_down),
			     .i_right		(i_right),
			     .i_left		(i_left));

   TimerModule Timer(/*AUTOINST*/
		     // Outputs
		     .o_sec		(o_sec[5:0]),
		     .o_min		(o_min[5:0]),
		     .o_hr		(o_hr[4:0]),
		     // Inputs
		     .i_clk		(i_clk),
		     .i_rstn		(i_rstn),
		     .i_set		(i_set),
		     .i_up		(i_up),
		     .i_down		(i_down),
		     .i_left		(i_left),
		     .i_right		(i_right));

   

endmodule // ClockTop   
///////////////////////////////////////////////////////////////////////
//                                                                   //
//                                                                   //
//                                                                   //
///////////////////////////////////////////////////////////////////////
module CounterFiftyNine2(/*AUTOARG*/
   // Outputs
   o_count, o_carryup, o_borrowdown,
   // Inputs
   i_clk, i_rstn, i_up, i_down
   );

   input i_clk;
   input i_rstn;
   input i_up;
   input i_down;

   output [5:0] o_count;
   output 	o_carryup;
   output 	o_borrowdown;

   wire [5:0] 	w_next_countup;
   wire [5:0] 	w_next_countdown;

   reg [5:0] 	r_count;
   

   assign w_next_countup = r_count == 6'd59 ? 6'd0 : r_count + 6'd1;
   assign w_next_countdown = r_count == 6'd0 ? 6'd59 : r_count - 6'd1;

   always @(posedge i_clk or negedge i_rstn) begin
      if (!i_rstn) r_count <= 6'd0;
      else
	case({i_up, i_down})
	  2'b00: r_count <= r_count;
	  2'b01: r_count <= w_next_countdown;
	  2'b10: r_count <= w_next_countup;
	  2'b11: r_count <= 6'd0;
	endcase // case ({i_up, i_down})
   end

   assign o_count = r_count;
   assign o_carryup = {i_up, i_down, r_count} == {2'b10, 6'd59};
   assign o_borrowdown = {i_up, i_down, r_count} == {2'b01, 6'd0};

endmodule // CounterFiftyNine2
///////////////////////////////////////////////////////////////////////
//                                                                   //
//                                                                   //
//                                                                   //
///////////////////////////////////////////////////////////////////////
module CounterNinetyNine(/*AUTOARG*/
   // Outputs
   o_tens, o_ones, o_carryup, o_borrowdown,
   // Inputs
   i_clk, i_rstn, i_up, i_down, i_clear
   );
   input i_clk;
   input i_rstn;
   input i_up;
   input i_down;
   input i_clear;

   output [3:0] o_tens;
   output [3:0] o_ones;
   output 	o_carryup;
   output 	o_borrowdown;

   reg [3:0] 	r_tens;
   reg [3:0] 	r_ones;

   always @(posedge i_clk or negedge i_rstn) begin
      if (!i_rstn) r_tens <= 4'd0;
      else if (i_clear) r_tens <= 4'd0;
      else
	case({i_up, i_down, r_tens, r_ones})
	  {2'b10, 4'd0, 4'd9}: r_tens <= 4'd1;
	  {2'b10, 4'd1, 4'd9}: r_tens <= 4'd2;
	  {2'b10, 4'd2, 4'd9}: r_tens <= 4'd3;
	  {2'b10, 4'd3, 4'd9}: r_tens <= 4'd4;
	  {2'b10, 4'd4, 4'd9}: r_tens <= 4'd5;
	  {2'b10, 4'd5, 4'd9}: r_tens <= 4'd6;
	  {2'b10, 4'd6, 4'd9}: r_tens <= 4'd7;
	  {2'b10, 4'd7, 4'd9}: r_tens <= 4'd8;
	  {2'b10, 4'd8, 4'd9}: r_tens <= 4'd9;
	  {2'b10, 4'd9, 4'd9}: r_tens <= 4'd0;
	  
	  {2'b01, 4'd0, 4'd0}: r_tens <= 4'd9;
	  {2'b01, 4'd1, 4'd0}: r_tens <= 4'd0;
	  {2'b01, 4'd2, 4'd0}: r_tens <= 4'd1;
	  {2'b01, 4'd3, 4'd0}: r_tens <= 4'd2;
	  {2'b01, 4'd4, 4'd0}: r_tens <= 4'd3;
	  {2'b01, 4'd5, 4'd0}: r_tens <= 4'd4;
	  {2'b01, 4'd6, 4'd0}: r_tens <= 4'd5;
	  {2'b01, 4'd7, 4'd0}: r_tens <= 4'd6;
	  {2'b01, 4'd8, 4'd0}: r_tens <= 4'd7;
	  {2'b01, 4'd9, 4'd0}: r_tens <= 4'd8;

	  default: r_tens <= r_tens;
	endcase // case ({i_up, i_down, r_tens, r_ones})
   end // always @ (posedge i_clk or negedge i_rstn)

   always @(posedge i_clk or negedge i_rstn) begin
      if (!i_rstn) r_ones <= 4'd0;
      else if (i_clear) r_ones <= 4'd0;
      else
	case ({i_up, i_down, r_ones})
	  {2'b10, 4'd0}: r_ones <= 4'd1;
	  {2'b10, 4'd1}: r_ones <= 4'd2;
	  {2'b10, 4'd2}: r_ones <= 4'd3;
	  {2'b10, 4'd3}: r_ones <= 4'd4;
	  {2'b10, 4'd4}: r_ones <= 4'd5;
	  {2'b10, 4'd5}: r_ones <= 4'd6;
	  {2'b10, 4'd6}: r_ones <= 4'd7;
	  {2'b10, 4'd7}: r_ones <= 4'd8;
	  {2'b10, 4'd8}: r_ones <= 4'd9;
	  {2'b10, 4'd9}: r_ones <= 4'd0;

	  {2'b01, 4'd0}: r_ones <= 4'd9;
	  {2'b01, 4'd1}: r_ones <= 4'd0;
	  {2'b01, 4'd2}: r_ones <= 4'd1;
	  {2'b01, 4'd3}: r_ones <= 4'd2;
	  {2'b01, 4'd4}: r_ones <= 4'd3;
	  {2'b01, 4'd5}: r_ones <= 4'd4;
	  {2'b01, 4'd6}: r_ones <= 4'd5;
	  {2'b01, 4'd7}: r_ones <= 4'd6;
	  {2'b01, 4'd8}: r_ones <= 4'd7;
	  {2'b01, 4'd9}: r_ones <= 4'd8;

	  default: r_ones <= r_ones;
	endcase // case ({i_up, i_down, i_ones})
   end // always @ (posedge i_clk or negedge i_rstn)

   assign o_carryup = {i_up, i_down, r_tens, r_ones} == {2'b10, 4'd9, 4'd9};
   assign o_borrowdown = {i_up, i_down, r_tens, r_ones} == {2'b01, 4'd0, 4'd0};

   assign o_tens = r_tens;
   assign o_ones = r_ones;

endmodule // CounterNinetyNine
///////////////////////////////////////////////////////////////////////
//                                                                   //
//                                                                   //
//                                                                   //
///////////////////////////////////////////////////////////////////////
module CounterNNN(/*AUTOARG*/
   // Outputs
   o_carryup, o_borrowdown, o_count,
   // Inputs
   i_clk, i_rstn, i_up, i_down
   );
   input i_clk;
   input i_rstn;
   input i_up;
   input i_down;

   output o_carryup;
   output o_borrowdown;
   output [9:0] o_count;

   wire [9:0] w_next_countup;
   wire [9:0] w_next_countdown;
   reg [9:0]  r_count;

   assign w_next_countup = r_count == 10'd999 ? 10'd0 : r_count + 10'd1;
   assign w_next_countdown = r_count == 10'd0 ? 10'd999 : r_count - 10'd1;

   always @(posedge i_clk or negedge i_rstn) begin
      if (!i_rstn) r_count <= 10'd0;
      else
	case({i_up, i_down})
	  2'b00: r_count <= r_count;
	  2'b01: r_count <= w_next_countdown;
	  2'b10: r_count <= w_next_countup;
	  2'b11: r_count <= 10'd0;
	endcase // case ({i_up, i_down})
   end

   assign o_carryup = {i_up, i_down, r_count} == {2'b10, 10'd999};
   assign o_borrowdown = {i_up, i_down, r_count} == {2'b01, 10'd0};
   assign o_count = r_count;

endmodule // CounterNNN
///////////////////////////////////////////////////////////////////////
//                                                                   //
//                                                                   //
//                                                                   //
///////////////////////////////////////////////////////////////////////
module CounterTwentyThree2(/*AUTOARG*/
   // Outputs
   o_count, o_carryup, o_borrowdown,
   // Inputs
   i_clk, i_rstn, i_up, i_down
   );
   input i_clk;
   input i_rstn;
   input i_up;
   input i_down;

   output [4:0] o_count;
   output 	o_carryup;
   output 	o_borrowdown;

   wire [4:0] 	w_next_countup;
   wire [4:0] 	w_next_countdown;
   reg [4:0] 	r_count;

   assign w_next_countup = r_count == 5'd23 ? 5'd0 : r_count + 5'd1;
   assign w_next_countdown = r_count == 5'd0 ? 5'd23 : r_count - 5'd1;

   always @(posedge i_clk or negedge i_rstn) begin
      if (!i_rstn) r_count <= 5'd0;
      else
	case({i_up, i_down})
	  2'b00: r_count <= r_count;
	  2'b01: r_count <= w_next_countdown;
	  2'b10: r_count <= w_next_countup;
	  2'b11: r_count <= 5'd0;
	endcase // case ({i_up, i_down})
   end

   assign o_count = r_count;
   assign o_carryup = {i_up, i_down, r_count} == {2'b10, 5'd23};
   assign o_borrowdown = {i_up, i_down, r_count} == {2'b01, 5'd0};

endmodule // CounterTwnetyThree2
///////////////////////////////////////////////////////////////////////
//                                                                   //
//                                                                   //
//                                                                   //
///////////////////////////////////////////////////////////////////////
module StopWatchControl(/*AUTOARG*/
   // Outputs
   o_ms_up, o_ms_down, o_sec_up, o_sec_down, o_min_up, o_min_down,
   o_hr_up, o_hr_down,
   // Inputs
   i_clk, i_rstn, i_set, i_up, i_down, i_left, i_right, i_ms_carryup,
   i_sec_carryup, i_min_carryup, i_hr_carryup
   );

   input i_clk;
   input i_rstn;
   input i_set;
   input i_up;
   input i_down;
   input i_left;
   input i_right;

   input i_ms_carryup;
   input i_sec_carryup;
   input i_min_carryup;
   input i_hr_carryup;

   output o_ms_up;
   output o_ms_down;
   output o_sec_up;
   output o_sec_down;
   output o_min_up;
   output o_min_down;
   output o_hr_up;
   output o_hr_down;

   reg 	  r_run;
   wire   w_any_rlud;

   assign w_any_rlud = i_up | i_down | i_left | i_right;

   assign o_ms_up = r_run | i_set;
   assign o_ms_down = i_set;
   assign o_sec_up = r_run & i_ms_carryup | i_set;
   assign o_sec_down = i_set;
   assign o_min_up = r_run & i_sec_carryup | i_set;
   assign o_min_down = i_set;
   assign o_hr_up = r_run & i_min_carryup | i_set;
   assign o_hr_down = i_set;

   always @(posedge i_clk or negedge i_rstn) begin

      if (!i_rstn) r_run <= 1'b0;

      else begin

	 case({r_run, w_any_rlud, i_set})
	   3'b000: r_run <= 1'b0;
	   3'b001: r_run <= 1'b0;
	   3'b010: r_run <= 1'b1;
	   3'b011: r_run <= 1'b0;
	   3'b100: r_run <= 1'b1;
	   3'b101: r_run <= 1'b0;
	   3'b110: r_run <= 1'b0;
	   3'b111: r_run <= 1'b0;
	 endcase
      end // else: !if(!i_rstn)
   end // always @ (posedge i_clk or negedge i_rstn)
   

endmodule // StopWatchControl
///////////////////////////////////////////////////////////////////////
//                                                                   //
//                                                                   //
//                                                                   //
///////////////////////////////////////////////////////////////////////
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
///////////////////////////////////////////////////////////////////////
//                                                                   //
//                                                                   //
//                                                                   //
///////////////////////////////////////////////////////////////////////
module TimerControl(/*AUTOARG*/
   // Outputs
   o_ms_up, o_ms_down, o_sec_up, o_sec_down, o_min_up, o_min_down,
   o_hr_up, o_hr_down,
   // Inputs
   i_clk, i_rstn, i_set, i_up, i_down, i_left, i_right,
   i_ms_borrowdown, i_sec_borrowdown, i_min_borrowdown, i_ms, i_sec,
   i_min, i_hr
   );

   input i_clk;
   input i_rstn;
   input i_set;
   input i_up;
   input i_down;
   input i_left;
   input i_right;

   input i_ms_borrowdown;
   input i_sec_borrowdown;
   input i_min_borrowdown;

   input [9:0] i_ms;
   input [5:0] i_sec;
   input [5:0] i_min;
   input [4:0] i_hr;

   output o_ms_up;
   output o_ms_down;
   output o_sec_up;
   output o_sec_down;
   output o_min_up;
   output o_min_down;
   output o_hr_up;
   output o_hr_down;

   reg [2:0] r_cur_state;
   wire w_almost_allzero;
   wire w_allzero;
   wire w_any_rlud;

   assign w_almost_allzero = {i_hr, i_min, i_hr, i_ms[9:1]} == 26'd0;
   assign w_allzero = w_almost_allzero & ~i_ms[0];
   assign w_any_rlud = i_right | i_left | i_up | i_down;

   localparam [2:0] c_init = 3'b000;
   localparam [2:0] c_finish = 3'b001;
   localparam [2:0] c_pause = 3'b010;
   localparam [2:0] c_run = 3'b011;
   localparam [2:0] c_set_sec = 3'b100;
   localparam [2:0] c_set_min = 3'b101;
   localparam [2:0] c_set_hr = 3'b110;
   

   assign o_ms_up = r_cur_state[2];
   assign o_ms_down = r_cur_state == c_run;
   assign o_sec_up = ((r_cur_state == c_set_sec) & i_up);
   assign o_sec_down = ((r_cur_state == c_run) & i_ms_borrowdown) | ((r_cur_state == c_set_sec) & i_down);
   assign o_min_up = ((r_cur_state == c_set_min) & i_up);
   assign o_min_down = ((r_cur_state == c_run) & i_sec_borrowdown) | ((r_cur_state == c_set_min) & i_down);
   assign o_hr_up = ((r_cur_state == c_set_hr) & i_up);
   assign o_hr_down = ((r_cur_state == c_run) & i_min_borrowdown) | ((r_cur_state == c_set_hr) & i_up);


   always @(posedge i_clk or negedge i_rstn) begin
      if (!i_rstn) r_cur_state <= c_init;
      else 
         case({r_cur_state})
            c_init: begin
               if (i_set) r_cur_state <= c_set_sec;
               else r_cur_state <= c_init;
            end
            c_finish: begin
               case({i_set, w_any_rlud})
                  2'b00: r_cur_state <= c_finish;
                  2'b01: r_cur_state <= c_init;
                  2'b10, 2'b11: r_cur_state <= c_set_sec;
               endcase
            end
            // corner case 1: pause when 2ms remaining, or(and) resume when
            // 1ms remaining: 
            // nothing special
            // state | run   | pause  | pause  | pause  | run   |finish|
            // count |  2    |   1    |   1    |   1    |  1    |  0   |
            // rlud  |  1    |   0    |   0    |   1    |  0    |  0   |
            // almost|  0    |   1    |   1    |   1    |  1    |  1   |
            // zero  |  0    |   0    |   0    |   0    |  0    |  1   |
            //
            // corner case 2: pause when 1ms remaining:
            // ignore rlud and proceed to finish. 
            // pause & count==0 cannot be reached
            // state | run   | run    |finish|
            // count |  2    |  1     |  0
            // almost|  0    |  1     |  1
            // zero  |  0    |  0     |  1
            c_pause: begin
               case({i_set, w_any_rlud}) 
                  2'b00: r_cur_state <= c_pause;
                  2'b01: r_cur_state <= c_run;
                  2'b10, 2'b11: r_cur_state <= c_set_sec;
               endcase
            end
            c_run: begin
               case({i_set, w_any_rlud, w_almost_allzero})
                  3'b000: r_cur_state <= c_run;
                  3'b001: r_cur_state <= c_finish;
                  3'b010: r_cur_state <= c_pause;
                  3'b011: r_cur_state <= c_finish;
                  default: r_cur_state <= c_set_sec;
               endcase
            end
            c_set_sec: begin
               case({i_set, i_left, i_right, w_allzero})
                  4'b0000, 4'b0010, 4'b0100, 4'b0110: r_cur_state <= c_pause;
                  4'b0001, 4'b0011, 4'b0101, 4'b0111: r_cur_state <= c_init; // transition to 'init' if everything is zero. pause & count==0 cannot be reached
                  4'b1000, 4'b1001, 4'b1110, 4'b1111: r_cur_state <= c_set_sec; // ignore left/right at the same time
                  4'b1010, 4'b1011: r_cur_state <= c_set_hr;
                  4'b1100, 4'b1101: r_cur_state <= c_set_min; 
               endcase
            end
            c_set_min: begin
               case({i_set, i_left, i_right, w_allzero})
                  4'b0000, 4'b0010, 4'b0100, 4'b0110: r_cur_state <= c_pause;
                  4'b0001, 4'b0011, 4'b0101, 4'b0111: r_cur_state <= c_init; // transition to 'init' if everything is zero. pause & count==0 cannot be reached
                  4'b1000, 4'b1001, 4'b1110, 4'b1111: r_cur_state <= c_set_sec; // ignore left/right at the same time
                  4'b1010, 4'b1011: r_cur_state <= c_set_sec;
                  4'b1100, 4'b1101: r_cur_state <= c_set_hr; 
               endcase
            end
            c_set_hr: begin
               case({i_set, i_left, i_right, w_allzero})
                  4'b0000, 4'b0010, 4'b0100, 4'b0110: r_cur_state <= c_pause;
                  4'b0001, 4'b0011, 4'b0101, 4'b0111: r_cur_state <= c_init; // transition to 'init' if everything is zero. pause & count==0 cannot be reached
                  4'b1000, 4'b1001, 4'b1110, 4'b1111: r_cur_state <= c_set_sec; // ignore left/right at the same time
                  4'b1010, 4'b1011: r_cur_state <= c_set_min;
                  4'b1100, 4'b1101: r_cur_state <= c_set_sec; 
               endcase
            end
            default: r_cur_state <= c_init;
         endcase
   end
endmodule // TimerControl
///////////////////////////////////////////////////////////////////////
//                                                                   //
//                                                                   //
//                                                                   //
///////////////////////////////////////////////////////////////////////
module TimerModule(/*AUTOARG*/
   // Outputs
   o_sec, o_min, o_hr,
   // Inputs
   i_clk, i_rstn, i_set, i_up, i_down, i_left, i_right
   );

   input i_clk;
   input i_rstn;
   input i_set;
   input i_up;
   input i_down;
   input i_left;
   input i_right;

   output [5:0] o_sec;
   output [5:0] o_min;
   output [4:0] o_hr;

   wire 	w_ms_borrowdown;
   wire 	w_sec_borrowdown;
   wire 	w_min_borrowdown;

   wire 	w_ms_up;
   wire 	w_ms_down;
   wire 	w_sec_up;
   wire 	w_sec_down;
   wire 	w_min_up;
   wire 	w_min_down;
   wire 	w_hr_up;
   wire 	w_hr_down;

   wire [9:0] 	w_ms;
   wire [5:0] 	w_sec;
   wire [5:0] 	w_min;
   wire [4:0] 	w_hr;

   assign o_sec = w_sec;
   assign o_min = w_min;
   assign o_hr = w_hr;
   

   TimerControl Controller(// Outputs
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
			   .i_ms_borrowdown	(w_ms_borrowdown),
			   .i_sec_borrowdown	(w_sec_borrowdown),
			   .i_min_borrowdown	(w_min_borrowdown),
			   .i_ms		(w_ms[9:0]),
			   .i_sec		(w_sec[5:0]),
			   .i_min		(w_min[5:0]),
			   .i_hr		(w_hr[4:0]));

   CounterNNN MSCounter(// Outputs
			.o_carryup	(),
			.o_borrowdown	(w_ms_borrowdown),
			.o_count        (w_ms[9:0]),
			// Inputs
			.i_clk		(i_clk),
			.i_rstn		(i_rstn),
			.i_up		(w_ms_up),
			.i_down		(w_ms_down));

   CounterFiftyNine2 SecCounter(// Outputs
				.o_count	(w_sec[5:0]),
				.o_carryup	(),
				.o_borrowdown	(w_sec_borrowdown),
				// Inputs
				.i_clk		(i_clk),
				.i_rstn		(i_rstn),
				.i_up		(w_sec_up),
				.i_down		(w_sec_down));

   CounterFiftyNine2 MinCounter(// Outputs
				.o_count	(w_min[5:0]),
				.o_carryup	(),
				.o_borrowdown	(w_min_borrowdown),
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
				 .i_down		(w_hr_down));

endmodule // TimerModule
///////////////////////////////////////////////////////////////////////
//                                                                   //
//                                                                   //
//                                                                   //
///////////////////////////////////////////////////////////////////////
