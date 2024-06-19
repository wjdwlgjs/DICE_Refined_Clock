module StopWatchControl(/*AUTOARG*/
   // Outputs
   o_ms_up, o_ms_down, o_sec_up, o_sec_down, o_min_up, o_min_down,
   o_hr_up, o_hr_down,
   // Inputs
   i_clk, i_rstn, i_set, i_up, i_down, i_left, i_right, i_ms_pulse,
   i_ms_carryup, i_sec_carryup, i_min_carryup, i_hr_carryup
   );

   input i_clk;
   input i_rstn;
   input i_set;
   input i_up;
   input i_down;
   input i_left;
   input i_right;
   
   input i_ms_pulse; 
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

   assign o_ms_up = (r_run & i_ms_pulse) | i_set; 
   assign o_ms_down = i_set;
   assign o_sec_up = (r_run & i_ms_carryup) | i_set;
   assign o_sec_down = i_set;
   assign o_min_up = (r_run & i_sec_carryup) | i_set;
   assign o_min_down = i_set;
   assign o_hr_up = (r_run & i_min_carryup) | i_set;
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


