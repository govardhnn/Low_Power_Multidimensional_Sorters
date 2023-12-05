/*
MIT License Copyright (c) 2023 Samahith S A and Sai Govardhan

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
``Software''), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ``AS IS'', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
*/
`timescale 1ns / 1ps


module Bitonic_8_tb;
reg clk=1'b1;
reg dir;
reg rst=1'b0;
reg en=1'b1;
reg start=1'b0;
reg [255:0]data_in;
wire [255:0]data_out;
wire [23:0] test_out_index;
always #5 clk=~clk;
//.DATA_WIDTH(32),.N_INPUTS(8)
BSN /*#(.DATA_WIDTH(32),.N_INPUTS(8))*/ dut(.clk(clk),.rst(rst),.en(en),.data_in(data_in),.direction(dir),.data_out(data_out));//,.test_out_index(test_out_index).start(start),.trans(trans)
initial begin 
dir=1'b0;
data_in={32'd5,32'd7,32'd4,32'd1,32'd0,32'd6,32'd3,32'd2};
start=1'b1;
#20;
start=1'b0;
$monitor("Data :%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d, time : %0t",data_out[255:224],data_out[223:192],data_out[191:160],data_out[159:128],data_out[127:96],data_out[95:64],data_out[63:32],data_out[31:0],$time);
//$monitor("index :%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d",test_out_index[23:21],test_out_index[20:18],test_out_index[17:15],test_out_index[14:12],test_out_index[11:9],test_out_index[8:6],test_out_index[5:3],test_out_index[2:0]);
//#500 $finish;
end
endmodule
