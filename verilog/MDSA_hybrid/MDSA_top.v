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
