module ClockControl(/*AUTOARG*/
		    // Outputs
		    o_ms_up, o_ms_down, o_sec_up, o_sec_down, o_min_up, o_min_down,
		    o_hr_up, o_hr_down,
		    // Inputs
		    i_clk, i_rstn, i_set, i_up, i_down, i_left, i_right, i_ms_carryup,
		    i_sec_carryup, i_min_carryup
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

   output o_ms_up;
   output o_ms_down;
   output o_sec_up;
   output o_sec_down;
   output o_min_up;
   output o_min_down;
   output o_hr_up;
   output o_hr_down;

   reg [1:0] r_cur_state;

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
   assign o_hr_down = ({r_cur_state, i_set, i_down} == {c_set_hr, 2'b11});

   always @(posedge i_clk or negedge i_rstn) begin
      if (!i_rstn) r_cur_state <= c_run;
      else
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

	endcase
   end


endmodule

