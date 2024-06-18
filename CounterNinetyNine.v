module CounterNinetyNine(/*AUTOARG*/);
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
	case ({i_up, i_down, i_ones})
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
