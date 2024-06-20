module R_DIGITAL_CLOCK(/*AUTOARG*/
   // Outputs
   SECOND, MINUTES, HOURS, O_MC,
   // Inputs
   CLK, RSTN, SET, UP, DOWN, LEFT, RIGHT, I_MC, i_mode
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
	       .i_mode			(i_mode));
   

   

endmodule // Top
