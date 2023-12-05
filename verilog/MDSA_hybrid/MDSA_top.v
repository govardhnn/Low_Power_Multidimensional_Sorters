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
//`include "MDSA_sorter.v"
//`include "MDSA_FSM.v"

module MDSA_top#(parameter N=8,DW=32)(
    input wire [2047:0]data_in, 
    input wire clk, rst, en,
    input wire start,
    output wire [2047:0]data_out,
    output wire rdy, output_enable
    );
  wire [7:0] dir;
    MDSA_sorter sorter( .data_in_new(data_in),
     .clk(clk), .rst(rst), .en(en), .dir(dir), .start(start) , .trans(trans),
                        .data_out_final(data_out)
                   );
    MDSA_FSM fsm(.START(start), .clk(clk), .rst(rst), .en(en), .DIRECTION(dir), .READY(rdy),.trans(trans), .output_enable(output_enable)); 
    
endmodule
