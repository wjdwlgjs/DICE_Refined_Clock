`include "CounterFiftyNine2.v"
`timescale 1ns/1ns

module tb_CounterFiftuNine2();

   /*AUTOREGINPUT*/
   /*AUTOWIRE*/

   CounterFiftyNine2 TestCounter(/*AUTOINST*/);

   always #5 i_clk = ~i_clk;

   initial begin
      
