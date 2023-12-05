`timescale 10ns / 1ps
module MDSA_top(input wire clk,rst,en,start,
                input wire [2047:0]data_in,
                output wire rdy,output_enable,
                output wire [2047:0]data_out);
                
wire trans;
wire[7:0]dir;
localparam N=8,DW=32;
MDSA_FSM fsm(.clk(clk),.rst(rst),.en(en),.START(start),.DIRECTION(dir),.READY(rdy),.output_enable(output_enable),.trans(trans));
MDSA_sorter#(.N(8),.DW(32)) sorter(.data_in_new(data_in),.clk(clk),.rst(rst),.en(en),.start(start),.dir(dir),.data_out_final(data_out),.trans(trans));

endmodule
