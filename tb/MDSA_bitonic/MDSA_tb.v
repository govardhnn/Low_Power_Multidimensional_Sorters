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
//parameter N=8,DW=32;
module MDSA_tb;
reg[2047:0]data;
wire[2047:0]data_out;
reg clk1=1'b1;
reg rst=1'b0;
reg en=1'b0;
//reg clk2=1'b1;
wire rdy;
wire output_enable;
wire trans;
reg start=1'b0;
wire [7:0]dir;
wire[31:0]data_out_tb[63:0];
parameter N=8,DW=32; 
//MDSA_FSM fsm(.clk(clk1),.rst(rst),.en(en),.START(start),.DIRECTION(dir),.READY(rdy),.output_enable(output_enable),.trans(trans));
//MDSA_sorter#(.N(8),.DW(32)) dut(.data_in_new(data),.clk(clk1),.rst(rst),.en(en),.start(start),.dir(dir),.data_out(data_o),.trans(trans));
MDSA_top dut (.data_in(data),.clk(clk1),.rst(rst),.en(en),.start(start),.data_out(data_out),.output_enable(output_enable),.rdy(rdy));
always #5 clk1=~clk1;
//always #5 clk2=~clk2;
initial begin 
//data={64{$urandom}};
data={32'd133,32'd270,32'd79,32'd97,32'd351,32'd318,32'd253,32'd119,32'd437,32'd3,32'd481,32'd292,32'd303,32'd100,32'd518,32'd76,32'd119,32'd138,32'd346,32'd389,32'd235,32'd234,32'd152,32'd460,32'd515,32'd261,32'd135,32'd76,32'd275,32'd128,32'd522,32'd338,32'd280,32'd171,32'd161,32'd439,32'd361,32'd197,32'd250,32'd433,32'd130,32'd51,32'd235,32'd500,32'd102,32'd406,32'd322,32'd21,32'd245,32'd507,32'd68,32'd443,32'd388,32'd163,32'd341,32'd111,32'd534,32'd279,32'd64,32'd256,32'd442,32'd473,32'd29,32'd349};
en=1'b0;
#20;
en=1'b1;
#20;
rst=1'b1;
#20;
rst=1'b0;
#20;
start=1'b1;
#40;
start=1'b0;
#240;
//en=1'b0;
//#40;
//en=1'b1;
#700;
rst=1'b1;
#50;
rst=1'b0;
#10;
en=1'b0;
#10;
en=1'b1;


data={32'd169,32'd581,32'd39,32'd413,32'd254,32'd127,32'd279,32'd49,32'd29,32'd569,32'd565,32'd223,32'd107,32'd17,32'd583,32'd398,32'd503,32'd574,32'd190,32'd250,32'd165,32'd111,32'd310,32'd485,32'd73,32'd68,32'd571,32'd595,32'd389,32'd535,32'd215,32'd143,32'd87,32'd503,32'd185,32'd514,32'd504,32'd193,32'd496,32'd433,32'd237,32'd180,32'd340,32'd561,32'd440,32'd393,32'd192,32'd348,32'd121,32'd574,32'd600,32'd64,32'd541,32'd5,32'd210,32'd181,32'd497,32'd465,32'd248,32'd141,32'd422,32'd438,32'd428};
start=1'b1;
#40;
start=1'b0;

//$monitor("Data :%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d, time : %0t",data_out[255:224],data_out[223:192],data_out[191:160],data_out[159:128],data_out[127:96],data_out[95:64],data_out[63:32],data_out[31:0],$time);
end
wire [31:0]data_o_tb[63:0];
genvar p;
generate 
for(p=1;p<=64;p=p+1) begin 
    assign data_o_tb[p-1]=data_out[p*DW-1:(p-1)*DW];// data_in_wire
    end
endgenerate 

endmodule
