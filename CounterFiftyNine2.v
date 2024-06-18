module CounterFiftyNine2(/*AUTOARG*/);

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
   

   assign w_next_countup = r_count == 6'd59? 6'd0 : r_count + 6'd1;
   assign w_next_countdown = r_count == 6'd0? 6'd59 : r_count - 6'd1;

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
   assign w_next_countup = {i_up, i_down, r_count} == {2'b10, 4'd59};
   assign w_next_countdown = {i_up, i_down, r_count} == {2'b01, 4'd0};

endmodule // CounterFiftyNine2
