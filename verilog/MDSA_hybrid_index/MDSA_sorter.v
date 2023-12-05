`timescale 10ns / 1ps
`include "HSN_index.sv"
module MDSA_sorter#(parameter N=8,DW=32)(
                   input wire [2047:0]data_in_new,
                   input wire clk,
                   input wire rst,
                   input wire en,
                   input wire start,
                   input wire trans,
                   input wire [7:0]dir,
                   output wire [2047:0]data_out_final
                   );
                  
                  wire [2047:0]data_in_fb;
               
                  reg[2047:0]data_in, data_in_temp;
                  wire [2047:0] data_out;
                                    


                    always@* 
                    begin
                    if(en) begin
                            if(start) begin 
                                data_in_temp = data_in_new;
                            end 
                            else begin 
                                data_in_temp =data_in_fb;
                            end
                        end
                    else begin
                            data_in_temp=data_in; 
                         end
                    end

                    //Register bank
                    always@(posedge trans) begin 
                        if(rst) begin 
                            data_in<='b0;
                        end
                        else begin 
                            data_in<=data_in_temp;
                        end
                    end
                  
                  
                  //4 Transpose data for DPBNs
                  genvar j,k;
                  generate 
                    for(k=1;k<=N;k=k+1) begin
                        for(j=1;j<=N;j=j+1) begin 
                            assign data_in_fb[((j*DW)-1)+(k-1)*N*DW:(j-1)*DW+(k-1)*N*DW]=data_out[(N*DW*j-DW*(k-1)-1):(N*DW*j-DW*(k-1)-DW)];
                        end
                    end
                  endgenerate 
                  

                  genvar i;
                  generate 
                  for(i=1;i<=N;i=i+1) begin 
                  HSN_index#(.DATA_WIDTH(32),.N_INPUTS(8)) DPHI (.clk(clk),.rst(rst),.en(en),.direction(dir[i-1]),.data_in(data_in[((i*N*DW)-1):(i-1)*DW*N]),.data_out(data_out[((i*N*DW)-1):(i-1)*N*DW]));
                 
 
                   end
                   
                  endgenerate
                   
                   assign data_out_final = data_in_fb;
endmodule
