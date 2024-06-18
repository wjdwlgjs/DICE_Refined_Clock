`include "TimerModule.v"
`timescale 1ns/1ns

module tb_TimerModule();

   /*AUTOREGINPUT*/
   /*AUTOWIRE*/

   TimerModule TestTimer(/*AUTOINST*/);

   always #5 i_clk = ~i_clk;

   always @(negedge i_rstn) i_rstn = 1;
   
   always @(posedge i_up) i_up <= 0;
   always @(posedge i_down) i_down <= 0;
   always @(posedge i_left) i_left <= 0;
   always @(posedge i_right) i_right <= 0;

   initial begin

      i_clk = 0;
      i_rstn = 0;
      i_set = 0;
      i_up = 0;
      i_down = 0;
      i_left = 0;
      i_right = 0;

      
