module CounterNNN(/*AUTOARG*/);
   input i_clk;
   input i_rstn;
   input i_up;
   input i_down;

   output o_carryup;
   output o_borrowdown;

   wire [9:0] w_next_countup;
   wire [9:0] w_next_countdown;
   reg [9:0]  r_count;

   assign w_next_countup = r_count == 10'd999? 10'd0 : r_count + 10d1;
   assign w_next_countdown = r_count == 10'd0? 10'd999 : r_count - 10'd1;

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

endmodule // CounterNNN