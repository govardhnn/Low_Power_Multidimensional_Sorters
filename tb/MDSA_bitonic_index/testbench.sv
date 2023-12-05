/*
MIT License

Copyright (c) 2023 Samahith S A and Sai Govardhan

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
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
    $dumpfile("/root/Desktop/N-08/vcd/vcd_dump_bitonic_index.vcd");$dumpvars;
  end
  
endmodule
