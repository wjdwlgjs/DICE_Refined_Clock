module Counter32Bit2(/*AUTOARG*/
   // Outputs
   o_count,
   // Inputs
   i_clk, i_rstn, i_enable
   );
   input i_clk;
   input i_rstn;
   input i_enable;

   output [31:0] o_count;

   reg [31:0] 	 r_count;
   localparam [31:0] c_limit = 32'd4999999;

   wire [30:0] 	 w_and_tree;
   wire [31:0] 	 w_toggle;

   assign w_and_tree[0] = r_count[0] & r_count[1];
   assign w_and_tree[1] = r_count[2] & r_count[3];
   assign w_and_tree[2] = r_count[4] & r_count[5];
   assign w_and_tree[3] = r_count[6] & r_count[7];
   assign w_and_tree[4] = r_count[8] & r_count[9];
   assign w_and_tree[5] = r_count[10] & r_count[11];
   assign w_and_tree[6] = r_count[12] & r_count[13];
   assign w_and_tree[7] = r_count[14] & r_count[15];
   assign w_and_tree[8] = r_count[16] & r_count[17];
   assign w_and_tree[9] = r_count[18] & r_count[19];
   assign w_and_tree[10] = r_count[20] & r_count[21];
   assign w_and_tree[11] = r_count[22] & r_count[23];
   assign w_and_tree[12] = r_count[24] & r_count[25];
   assign w_and_tree[13] = r_count[26] & r_count[27];
   assign w_and_tree[14] = r_count[28] & r_count[29];
   assign w_and_tree[15] = r_count[30] & r_count[31];

   assign w_and_tree[16] = w_and_tree[0] & w_and_tree[1];
   assign w_and_tree[17] = w_and_tree[2] & w_and_tree[3];
   assign w_and_tree[18] = w_and_tree[4] & w_and_tree[5];
   assign w_and_tree[19] = w_and_tree[6] & w_and_tree[7];
   assign w_and_tree[20] = w_and_tree[8] & w_and_tree[9];
   assign w_and_tree[21] = w_and_tree[10] & w_and_tree[11];
   assign w_and_tree[22] = w_and_tree[12] & w_and_tree[13];
   assign w_and_tree[23] = w_and_tree[14] & w_and_tree[15];

   assign w_and_tree[24] = w_and_tree[16] & w_and_tree[17];
   assign w_and_tree[25] = w_and_tree[18] & w_and_tree[19];
   assign w_and_tree[26] = w_and_tree[20] & w_and_tree[21];
   assign w_and_tree[27] = w_and_tree[22] & w_and_tree[23];

   assign w_and_tree[28] = w_and_tree[24] & w_and_tree[25];
   assign w_and_tree[29] = w_and_tree[26] & w_and_tree[27];

   assign w_and_tree[30] = w_and_tree[28] & w_and_tree[29];

   
   assign w_toggle[0] = 1'b1; // 0
   assign w_toggle[1] = r_count[0]; // 0
   assign w_toggle[2] = w_and_tree[0]; // 1
   assign w_toggle[3] = w_toggle[2] & r_count[2]; // 2
   assign w_toggle[4] = w_and_tree[16]; // 2
   assign w_toggle[5] = w_toggle[4] & r_count[4]; // 3
   assign w_toggle[6] = w_toggle[4] & w_and_tree[2]; // 3
   assign w_toggle[7] = w_toggle[6] & r_count[6]; // 4
   assign w_toggle[8] = w_and_tree[24]; // 3
   assign w_toggle[9] = w_toggle[8] & r_count[8]; // 4
   assign w_toggle[10] = w_toggle[8] & w_and_tree[4]; // 4
   assign w_toggle[11] = w_toggle[10] & r_count[10]; // 5
   assign w_toggle[12] = w_toggle[8] & w_and_tree[18]; // 5
   assign w_toggle[13] = w_toggle[12] & r_count[12]; // 6
   assign w_toggle[14] = w_toggle[12] & w_and_tree[6]; // 6
   assign w_toggle[15] = w_toggle[14] & r_count[14]; // 7
   assign w_toggle[16] = w_and_tree[28]; // 4
   assign w_toggle[17] = w_toggle[16] & r_count[16]; // 5
   assign w_toggle[18] = w_toggle[16] & w_and_tree[8]; // 5
   assign w_toggle[19] = w_toggle[18] & r_count[18]; // 6
   assign w_toggle[20] = w_toggle[16] & w_and_tree[20]; // 5
   assign w_toggle[21] = w_toggle[20] & r_count[20];
   assign w_toggle[22] = w_toggle[20] & w_and_tree[10];
   assign w_toggle[23] = w_toggle[22] & r_count[22];
   assign w_toggle[24] = w_toggle[16] & w_and_tree[26];
   assign w_toggle[25] = w_toggle[24] & r_count[24];
   assign w_toggle[26] = w_toggle[24] & w_and_tree[12];
   assign w_toggle[27] = w_toggle[26] & r_count[26];
   assign w_toggle[28] = w_toggle[24] & w_and_tree[22];
   assign w_toggle[29] = w_toggle[28] & r_count[28];
   assign w_toggle[30] = w_toggle[28] & w_and_tree[14];
   assign w_toggle[31] = w_toggle[30] & r_count[30];
   
   always @(posedge i_clk or negedge i_rstn) begin
      if (!i_rstn) r_count <= 32'd0;
      else if (!i_enable) r_count <= r_count;
      else
	case(r_count)
	  c_limit: r_count <= 32'd0;
	  default: r_count <= r_count ^ w_toggle;
	endcase // case (r_count)
   end

   assign o_count = r_count;

endmodule // Counter32Bit2

   
