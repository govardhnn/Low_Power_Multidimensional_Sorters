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

module CAS_dual#(parameter DATA_WIDTH=32)(
    input wire [DATA_WIDTH-1:0] i1,
    input wire [DATA_WIDTH-1:0] i2,
    input wire dir,
    input wire clk,
    input wire rst,
    input wire en,
    output reg[DATA_WIDTH-1:0] o1,
    output reg[DATA_WIDTH-1:0] o2
    );
    reg[DATA_WIDTH-1:0] o1_temp,o2_temp;
    
    always@*
      begin
     if(en) begin 
     //en =1
      if(dir)begin // dir =1 here is ascending
        if(i1>i2) begin 
          o2_temp=i1;
          o1_temp=i2;
        end
        else begin 
          o1_temp=i1;
          o2_temp=i2;
        end
      end
      
      else begin // dir =0 here is descending 
      if(i1>i2) begin 
          o2_temp=i2;
          o1_temp=i1;
      end
        else begin 
          o1_temp=i2;
          o2_temp=i1;
         end
      end
     end
     //en =0
      else begin 
	o1_temp=o1;
	o2_temp=o2;
      end
     end
     
     //Registered output easy to use for pipeline 
    always @(posedge clk or posedge rst)
      begin
	  if(rst) begin 
	  o1<='b0;
	  o2<='b0;
          end
	  else begin
          o1<=o1_temp;
          o2<=o2_temp;
	  end
      end

endmodule
