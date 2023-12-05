`timescale 1ns / 1ps

interface MDSA_interface(input wire clk,start,rst);
    logic en;
    logic[2047:0] data_in;
    logic output_enable,rdy;
    logic[2047:0] data_out;
endinterface
