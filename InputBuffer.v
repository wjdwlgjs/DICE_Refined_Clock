module InputBuffer(/*AUTOARG*/
   // Outputs
   o_up, o_down, o_left, o_right, o_mode,
   // Inputs
   i_clk, i_rstn, i_up, i_down, i_left, i_right, i_mode
   );
   input i_clk;
   input i_rstn;
   
   input i_up;
   input i_down;
   input i_left;
   input i_right;
   input i_mode;

   output o_up;
   output o_down;
   output o_left;
   output o_right;
   output o_mode;

   reg [1:0] r_up_state;
   reg [1:0] r_down_state;
   reg [1:0] r_right_state;
   reg [1:0] r_left_state;
   reg [1:0] r_mode_state;

   always @ (posedge i_clk or negedge i_rstn) begin
      if (!i_rstn) begin
	 r_up_state <= 2'b00;
	 r_down_state <= 2'b00;
	 r_right_state <= 2'b00;
	 r_left_state <= 2'b00;
	 r_mode_state <= 2'b00;
      end
      
      else begin
	 r_up_state <= {r_up_state[0] & i_up, i_up};
	 r_down_state <= {r_down_state[0] & i_down, i_down};
	 r_right_state <= {r_right_state[0] & i_right, i_right};
	 r_left_state <= {r_left_state[0] & i_left, i_left};
	 r_mode_state <= {r_mode_state[0] & i_mode, i_mode};
      end // else: !if(!i_rstn)
      
      
   end // always @ (posedge i_clk or negedge i_rstn)

   assign o_up = r_up_state == 2'b01;
   assign o_down = r_down_state == 2'b01;
   assign o_right = r_right_state == 2'b01;
   assign o_left = r_left_state == 2'b01;
   assign o_mode = r_mode_state == 2'b01;
   
   
   

endmodule // InputBuffer

   
