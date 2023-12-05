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
