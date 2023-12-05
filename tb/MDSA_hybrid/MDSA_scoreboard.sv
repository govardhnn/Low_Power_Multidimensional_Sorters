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
//`include "MDSA_reference_model.sv"
class MDSA_scoreboard;
  int x=0;
  int o=1;
    mailbox mon2scb;
    
    function new(mailbox mon2scb);
        this.mon2scb=mon2scb;
    endfunction 
    
//     function int reset_test(input logic rst,input logic [2047:0]data_out);
//         if(rst) begin
//             if(data_out=='b0) begin 
//                     reset_test=1'b1;
//                 end
//             end
//     endfunction    
    
  task main(input int n);
    repeat(n) 
    	begin
    	MDSA_packet pkt;
      	#1600; // time needed to sort if reset is 0 and enable is 1             
                mon2scb.get(pkt);
//                 if(reset_test(pkt.rst,pkt.data_out)) begin 
//                     $display("reset tested succesfully");
//                 end
//                 else 
//                     $display("failed");
//           pkt.display("Scoreboard",x++);
//                #490; // time needed to sort if reset is 0 and enable is 1
            end
    endtask
endclass
