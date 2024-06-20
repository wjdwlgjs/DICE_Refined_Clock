module TimerControl2(/*AUTOARG*/
   // Outputs
   o_ms_up, o_ms_down, o_sec_up, o_sec_down, o_min_up, o_min_down,
   o_hr_up, o_hr_down,
   // Inputs
   i_clk, i_rstn, i_up, i_down, i_right, i_left, i_set, i_ms_pulse,
   i_ms_borrowdown, i_sec_borrowdown, i_min_borrowdown, i_ms, i_sec,
   i_min, i_hr
   );
   input i_clk;
   input i_rstn;

   input i_up;
   input i_down;
   input i_right;
   input i_left;
   input i_set;

   input i_ms_pulse;
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
   wire	     w_any_rlud;

   wire	     w_almost_allzero;
   wire	     w_allzero;

   localparam [2:0] c_init = 3'b000;
   localparam [2:0] c_finish = 3'b001;
   localparam [2:0] c_pause = 3'b010;
   localparam [2:0] c_run = 3'b011;
   localparam [2:0] c_set_sec = 3'b100;
   localparam [2:0] c_set_min = 3'b101;
   localparam [2:0] c_set_hr = 3'b110;

   assign o_ms_up = r_cur_state[2];
   assign o_ms_down = ((r_cur_state == c_run) & i_ms_pulse) | r_cur_state[2];
   assign o_sec_up = ((r_cur_state == c_set_sec) & i_up);
   assign o_sec_down = ((r_cur_state == c_set_sec) & i_down) | ((r_cur_state == c_run) & i_ms_borrowdown);
   assign o_min_up = ((r_cur_state == c_set_min) & i_up);
   assign o_min_down = ((r_cur_state == c_set_min) & i_down) | ((r_cur_state == c_run) & i_sec_borrowdown);
   assign o_hr_up = ((r_cur_state == c_set_hr) & i_up);
   assign o_hr_down = ((r_cur_state == c_set_hr) & i_down) | ((r_cur_state == c_run) & i_min_borrowdown);

   assign w_almost_allzero = {i_hr, i_min, i_sec, i_ms[9:1]} == 26'd0;
   assign w_allzero = w_almost_allzero & ~i_ms[0];
   assign w_any_rlud = i_right | i_left | i_up | i_down;

   
   always @(posedge i_clk or negedge i_rstn) begin
      if (!i_rstn) r_cur_state <= c_init;
      else begin
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
	      endcase // case ({i_set, i_any_rlud})
	   end
	   c_pause: begin
	      case({i_set, w_any_rlud})
		2'b00: r_cur_state <= c_pause;
		2'b01: r_cur_state <= c_run;
		2'b10, 1'b11: r_cur_state <= c_set_sec;
	      endcase // case ({i_set, w_any_rlud})
	   end
	   
	   // corner case: rlud pressed to pause when 1ms remaining, and i_ms_pulse is 1 at the same time
	   // proceed to init instead of pause
	   // state |  run  |  run  |  run  | init  | 
	   // count |   1   |   1   |   1   |   0   |
	   // ms_pu |   0   |   0   |   1   |   0   |
	   // rlud  |   0   |   0   |   1   |   0   |
	   c_run: begin
	      case({i_set, w_any_rlud, w_almost_allzero, i_ms_pulse})
		4'b0000, 4'b0001, 4'b0010: r_cur_state <= c_run;
	        4'b0011: r_cur_state <= c_finish;
		4'b0100, 4'b0101, 4'b0110: r_cur_state <= c_pause;
		4'b0111: r_cur_state <= c_init;
		default: r_cur_state <= c_set_sec;
	      endcase // case ({i_set, i_any_rlud, i_almost_allzero, i_ms_pulse})
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
                  4'b1000, 4'b1001, 4'b1110, 4'b1111: r_cur_state <= c_set_min; // ignore left/right at the same time
                  4'b1010, 4'b1011: r_cur_state <= c_set_sec;
                  4'b1100, 4'b1101: r_cur_state <= c_set_hr; 
               endcase
            end
            c_set_hr: begin
               case({i_set, i_left, i_right, w_allzero})
                  4'b0000, 4'b0010, 4'b0100, 4'b0110: r_cur_state <= c_pause;
                  4'b0001, 4'b0011, 4'b0101, 4'b0111: r_cur_state <= c_init; // transition to 'init' if everything is zero. pause & count==0 cannot be reached
                  4'b1000, 4'b1001, 4'b1110, 4'b1111: r_cur_state <= c_set_hr; // ignore left/right at the same time
                  4'b1010, 4'b1011: r_cur_state <= c_set_min;
                  4'b1100, 4'b1101: r_cur_state <= c_set_sec; 
               endcase
            end
	   default: r_cur_state <= c_init;
	 endcase // case ({r_cur_state})
      end // else: !if(!i_rstn)
   end // always @ (posedge i_clk or negedge i_rstn)
endmodule // TimerControl2


		 
	   
	   
						
