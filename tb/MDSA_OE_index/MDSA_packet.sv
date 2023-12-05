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
class MDSA_packet;
  	parameter DATA_WIDTH=32;
    rand bit [2047:0]data_in;
    rand bit en;
    //rand bit rst;
  	//bit start;
  //constraint rst_off{rst==0;}
  constraint en_on{en==1;}
    
    bit [2047:0] data_out;
    bit rdy,output_enable;
  
  logic [63:0][31:0]data_in_reg;
  logic [63:0][31:0]data_out_reg;
  
    
  function void display(input string name,int iter);
    	//MDSA_tb_top.display_arr();
      	data_in_reg=data_in;
      	data_out_reg=data_out;
        $display("------------------------------------------");
        $display("Name: %s",name);
    	$display("Iteration: %0d",iter);
    	$display(", en =%0d",en);
      	$display("Data_in=%0p",data_in_reg);
        $display("rdy=%0d, output_enable=%0d",rdy,output_enable);  
      	$display("Data_out=%0p",data_out_reg);
    	$display("At time: %0t",$time);
        $display("------------------------------------------");
    endfunction
    

endclass
