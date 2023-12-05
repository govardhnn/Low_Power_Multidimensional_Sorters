`timescale 1ns / 1ps
//`include "CAS_dual.v"

module OEN#(parameter DATA_WIDTH=32,N_INPUTS=8)(
                        input wire [N_INPUTS*DATA_WIDTH-1:0] data_in,
                        input wire clk,
                        input wire rst,
                        input wire en,
                        input wire direction,
                        output wire [N_INPUTS*DATA_WIDTH-1:0]data_out);
                        
                        //Stage 1
                        wire [N_INPUTS*DATA_WIDTH-1:0] stage_1_out;
                        genvar i;
                        generate 
                          for(i=1;i<=4;i=i+1) begin 
                                CAS_dual#(.DATA_WIDTH(DATA_WIDTH)) CAS_stage_1 (
                                .i1(data_in[DATA_WIDTH*i + DATA_WIDTH*(i-1) -1 : DATA_WIDTH*i + DATA_WIDTH*(i-1) - DATA_WIDTH]),
                                .i2(data_in[DATA_WIDTH*i + DATA_WIDTH*(i-1) + DATA_WIDTH -1 : DATA_WIDTH*i + DATA_WIDTH*(i-1)]),
                                .dir(direction),.clk(clk),.rst(rst),.en(en),
                                .o1(stage_1_out[DATA_WIDTH*i + DATA_WIDTH*(i-1) -1 : DATA_WIDTH*i + DATA_WIDTH*(i-1) - DATA_WIDTH]),
                                .o2(stage_1_out[DATA_WIDTH*i + DATA_WIDTH*(i-1) -1 + DATA_WIDTH : DATA_WIDTH*i + DATA_WIDTH*(i-1)]));
                            end
                        endgenerate
                        
                        //Stage 2
                        wire [N_INPUTS*DATA_WIDTH -1:0] stage_2_out;
                        genvar n;
                        generate
                            for(n=1;n<=2;n=n+1) begin 
                                CAS_dual#(.DATA_WIDTH(DATA_WIDTH)) CAS_stage_2(
                                .i1(stage_1_out[n*DATA_WIDTH -1 : DATA_WIDTH*(n-1)]),
                                .i2(stage_1_out[ (n+2)*DATA_WIDTH -1 : DATA_WIDTH*(n+1)]),
                                .dir(direction),.clk(clk),.rst(rst),.en(en),
                                .o1(stage_2_out[n*DATA_WIDTH -1 : DATA_WIDTH*(n-1)]),
                                .o2(stage_2_out[(n+2)*DATA_WIDTH -1 : DATA_WIDTH*(n+1)]));
                            end
                        endgenerate
                        
                        genvar o;
                        generate
                            for(o=1;o<=2;o=o+1) begin 
                                CAS_dual#(.DATA_WIDTH(DATA_WIDTH)) CAS_stage_2(
                                .i1(stage_1_out[(DATA_WIDTH*4) + o*DATA_WIDTH -1 : (DATA_WIDTH*4) + DATA_WIDTH*(o-1)]),
                                .i2(stage_1_out[(DATA_WIDTH*4) + (o+2)*DATA_WIDTH -1 : (DATA_WIDTH*4) + DATA_WIDTH*(o+1)]),
                                .dir(direction),.clk(clk),.rst(rst),.en(en),
                                .o1(stage_2_out[(DATA_WIDTH*4) + o*DATA_WIDTH -1 : (DATA_WIDTH*4) + DATA_WIDTH*(o-1)]),
                                .o2(stage_2_out[(DATA_WIDTH*4) + (o+2)*DATA_WIDTH -1 : (DATA_WIDTH*4) + DATA_WIDTH*(o+1)]));
                            end
                        endgenerate
                        
                        //Stage 3
                        wire [N_INPUTS*DATA_WIDTH -1:0] stage_3_out;
                        generate 
                            for (i=1; i<=2; i=i+1) begin  //CAE BLOCKS                                
                                CAS_dual #(.DATA_WIDTH(DATA_WIDTH)) CAS_STAGE3(
                                .i1(stage_2_out[DATA_WIDTH*(4*i-2) -1 : DATA_WIDTH*(4*i-3)]),
                                .i2(stage_2_out[DATA_WIDTH*(4*i-1) -1 : DATA_WIDTH*(4*i-2)]),
                                .dir(direction),.clk(clk),.rst(rst),.en(en),
                                .o1(stage_3_out[DATA_WIDTH*(4*i-2) -1 : DATA_WIDTH*(4*i-3)]),
                                .o2(stage_3_out[DATA_WIDTH*(4*i-1) -1 : DATA_WIDTH*(4*i-2)])
                                );
                            end
                            
                            for(i=1;i<=2;i=i+1) begin //direct connections
                            assign stage_3_out[DATA_WIDTH*(4*i-3) -1 : DATA_WIDTH*(4*i-4)] 
                            = stage_2_out[DATA_WIDTH*(4*i-3) -1 : DATA_WIDTH*(4*i-4)];
                            assign stage_3_out[DATA_WIDTH*(4*i) -1 : DATA_WIDTH*(4*i-1)] 
                            = stage_2_out[DATA_WIDTH*(4*i) -1 : DATA_WIDTH*(4*i-1)];
                            end
                            
                        endgenerate   
                                             
                        //Stage 4
                        wire [N_INPUTS*DATA_WIDTH -1:0] stage_4_out;
                        generate
                        for (i=1; i<=4; i=i+1) begin 
                        CAS_dual #(.DATA_WIDTH(DATA_WIDTH))CAS_STAGE4(
                                .i1(stage_3_out[DATA_WIDTH*(i) -1 : DATA_WIDTH*(i-1)]),
                                .i2(stage_3_out[DATA_WIDTH*(i+4) -1 : DATA_WIDTH*(i+3)]),
                                .dir(direction),.clk(clk),.rst(rst),.en(en),
                                .o1(stage_4_out[DATA_WIDTH*(i) -1 : DATA_WIDTH*(i-1)]),
                                .o2(stage_4_out[DATA_WIDTH*(i+4) -1 : DATA_WIDTH*(i+3)])
                                );  
                         end
                         endgenerate          
                                           
                        //Stage 5 
                        wire [N_INPUTS*DATA_WIDTH -1:0] stage_5_out;
                        generate 
                            for (i=1; i<=2; i=i+1) begin  //CAE BLOCKS                                
                                CAS_dual #(.DATA_WIDTH(DATA_WIDTH)) 
                                CAS_STAGE5(
                                .i1(stage_4_out[DATA_WIDTH*(i+2) -1 : DATA_WIDTH*(i+1)]),
                                .i2(stage_4_out[DATA_WIDTH*(i+4) -1 : DATA_WIDTH*(i+3)]),
                                .dir(direction),.clk(clk),.rst(rst),.en(en),
                                .o1(stage_5_out[DATA_WIDTH*(i+2) -1 : DATA_WIDTH*(i+1)]),
                                .o2(stage_5_out[DATA_WIDTH*(i+4) -1 : DATA_WIDTH*(i+3)])
                                );
                            end
                        endgenerate
                            
                        generate
                        for (i=1; i<=2; i=i+1) 
                        begin 
                            assign stage_5_out[DATA_WIDTH*(i) -1 : DATA_WIDTH*(i-1)] 
                            = stage_4_out[DATA_WIDTH*(i) -1 : DATA_WIDTH*(i-1)];
                            assign stage_5_out[DATA_WIDTH*(i+6) -1 : DATA_WIDTH*(i+6-1)] 
                            = stage_4_out[DATA_WIDTH*(i+6) -1 : DATA_WIDTH*(i+6-1)];
                         end
                         endgenerate                        
                        
                        //Stage 6
                        wire [N_INPUTS*DATA_WIDTH -1:0] stage_6_out;
                        generate 
                            for (i=1; i<=3; i=i+1) begin  //CAE BLOCKS                                
                                CAS_dual #(.DATA_WIDTH(DATA_WIDTH)) 
                                CAS_STAGE6
                                (.i1(stage_5_out[DATA_WIDTH*(2*i) -1 : DATA_WIDTH*(2*i-1)]),
                                .i2(stage_5_out[DATA_WIDTH*(2*i+1) -1 : DATA_WIDTH*(2*i)]),
                                .dir(direction),.clk(clk),.rst(rst),.en(en),
                                .o1(stage_6_out[DATA_WIDTH*(2*i) -1 : DATA_WIDTH*(2*i-1)]),
                                .o2(stage_6_out[DATA_WIDTH*(2*i+1) -1 : DATA_WIDTH*(2*i)])
                                );
                            end
                        endgenerate
                        generate
                        for (i=1; i<=2; i=i+1) //direct connections
                        begin 
                            assign stage_6_out[DATA_WIDTH*(i*i*i) -1 : DATA_WIDTH*(i*i*i-1)] 
                            = stage_5_out[DATA_WIDTH*(i*i*i) -1 : DATA_WIDTH*(i*i*i-1)];
                            
                         end
                         endgenerate
                        
                        assign data_out = stage_6_out;
endmodule
