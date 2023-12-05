`timescale 1ns / 1ps
`include "MDSA_interface.sv"
`include "MDSA_testbench.sv"
module MDSA_tb_top;
    bit clk;
    bit start;
  bit rst;
  //int o=1;
    genvar o;
  
    always #10 clk=~clk;
  
  always #1600 begin 
    rst=1'b1;
    #20;
    rst=1'b0;
    #20;
  	start=1'b1;
    #80;
    start=1'b0;
  end
  
  MDSA_interface itf(clk,start,rst);
    
    MDSA_testbench tb(itf);
    
  MDSA_top dut(.clk(itf.clk),.rst(itf.rst),.en(itf.en),.start(itf.start),.data_in(itf.data_in),.rdy(itf.rdy),.output_enable(itf.output_enable),.data_out(itf.data_out)); 
  initial begin
    $monitor("Start activated at %0t,value=%0d",$time,start);
  end
  
  initial begin 
    $dumpfile("/root/Desktop/N-08/vcd/vcd_dump_OE_index.vcd");$dumpvars;
  end
  
endmodule
