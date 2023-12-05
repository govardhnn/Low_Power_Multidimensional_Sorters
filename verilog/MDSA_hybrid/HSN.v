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
//`include "CAS_dual.sv"

module HSN#(parameter DATA_WIDTH=32,N_INPUTS=8)( //32bit wide 8 inputs to be sorted
                        input wire [N_INPUTS*DATA_WIDTH-1:0] data_in,
                        input wire clk,
                        input wire rst,
                        input wire en,
                        input wire direction,
                        output wire [N_INPUTS*DATA_WIDTH-1:0]data_out
                        );
                       genvar i;
                        //stage 1
                        wire[N_INPUTS* DATA_WIDTH-1:0] stage_1_out;
                        generate 
                            for (i=1; i<=4; i=i+1) begin                                
                                CAS_dual #(.DATA_WIDTH(DATA_WIDTH)) 
                                CAS_STAGE1
                                (.i1(data_in[DATA_WIDTH*(2*i-1) -1 : DATA_WIDTH*(2*i-2)]),
                                .i2(data_in[DATA_WIDTH*(2*i) -1 : DATA_WIDTH*(2*i-1)]),
                                .dir(direction),
                                .clk(clk),
                                .rst(rst),
                                .en(en),
                                .o1(stage_1_out[DATA_WIDTH*(2*i-1) -1 : DATA_WIDTH*(2*i-2)]),
                                .o2(stage_1_out[DATA_WIDTH*(2*i) -1 : DATA_WIDTH*(2*i-1)])
                                );
                            end
                        endgenerate                  
                        
                        //stage 2
                        //upper block
                        wire [N_INPUTS* DATA_WIDTH-1:0]stage_2_out;
                        generate 
                            for (i=1; i<=2; i=i+1) begin                                
                                CAS_dual #(.DATA_WIDTH(DATA_WIDTH)) 
                                CAS_STAGE21
                                (.i1(stage_1_out[DATA_WIDTH*(i) -1 : DATA_WIDTH*(i-1)]),
                                .i2(stage_1_out[DATA_WIDTH*(i+2) -1 : DATA_WIDTH*(i+2-1)]),
                                .dir(direction),
                                .clk(clk),
                                .rst(rst),
                                .en(en),
                                .o1(stage_2_out[DATA_WIDTH*(i) -1 : DATA_WIDTH*(i-1)]),
                                .o2(stage_2_out[DATA_WIDTH*(i+2) -1 : DATA_WIDTH*(i+2-1)])
                                );
                            end
                        endgenerate 
                        //stage 2
                        //lower block
                     
                        generate 
                            for (i=1; i<=2; i=i+1) begin                                
                                CAS_dual #(.DATA_WIDTH(DATA_WIDTH)) 
                                CAS_STAGE21
                                (.i1(stage_1_out[DATA_WIDTH*(i+4) -1 : DATA_WIDTH*(i+4-1)]),
                                .i2(stage_1_out[DATA_WIDTH*(i+6) -1 : DATA_WIDTH*(i+6-1)]),
                                .dir(direction),
                                .clk(clk),
                                .rst(rst),
                                .en(en),
                                .o1(stage_2_out[DATA_WIDTH*(i+4) -1 : DATA_WIDTH*(i+4-1)]),
                                .o2(stage_2_out[DATA_WIDTH*(i+6) -1 : DATA_WIDTH*(i+6-1)])
                                );
                            end
                        endgenerate 
                        
                        //stage 3
                        
                        wire[N_INPUTS* DATA_WIDTH-1:0] stage_3_out; 
                        generate // can merge the below two for loops but separated for clarity
                            
                            for (i=1; i<=2; i=i+1) begin  //CAE BLOCKS                                
                                CAS_dual #(.DATA_WIDTH(DATA_WIDTH)) 
                                CAS_STAGE3
                                (.i1(stage_2_out[DATA_WIDTH*(4*i-2) -1 : DATA_WIDTH*(4*i-3)]),
                                .i2(stage_2_out[DATA_WIDTH*(4*i-1) -1 : DATA_WIDTH*(4*i-2)]),
                                .dir(direction),
                                .clk(clk),
                                .rst(rst),
                                .en(en),
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
                        
                        ////////////////////////////
                        //stage 4
                        
                        wire[N_INPUTS* DATA_WIDTH-1:0] stage_4_out;
                        
                        generate
                        for (i=1; i<2; i=i+1) begin //only for i=1
                        CAS_dual #(.DATA_WIDTH(DATA_WIDTH))
                        CAS_STAGE41
                                (.i1(stage_3_out[DATA_WIDTH*(4*i-3) -1 : DATA_WIDTH*(4*i-4)]),
                                .i2(stage_3_out[DATA_WIDTH*(4*i+1) -1 : DATA_WIDTH*(4*i)]),
                                .dir(direction),
                                .clk(clk),
                                .rst(rst),
                                .en(en),
                                .o1(stage_4_out[DATA_WIDTH*(4*i-3) -1 : DATA_WIDTH*(4*i-4)]),
                                .o2(stage_4_out[DATA_WIDTH*(4*i+1) -1 : DATA_WIDTH*(4*i)])
                                );
                        CAS_dual #(.DATA_WIDTH(DATA_WIDTH))
                        CAS_STAGE42
                                (.i1(stage_3_out[DATA_WIDTH*(4*i) -1 : DATA_WIDTH*(4*i-1)]),
                                .i2(stage_3_out[DATA_WIDTH*(4*i+4) -1 : DATA_WIDTH*(4*i+4-1)]),
                                .dir(direction),
                                .clk(clk),
                                .rst(rst),
                                .en(en),
                                .o1(stage_4_out[DATA_WIDTH*(4*i) -1 : DATA_WIDTH*(4*i-1)]),
                                .o2(stage_4_out[DATA_WIDTH*(4*i+4) -1 : DATA_WIDTH*(4*i+4-1)])
                                );    
                         end
                         endgenerate    
                                
                        generate 
                        for(i=1;i<=2;i=i+1) begin //direct connections                                
                                                                       
                        assign stage_4_out[DATA_WIDTH*(i+1) -1 : DATA_WIDTH*(i)] 
                            = stage_3_out[DATA_WIDTH*(i+1) -1 : DATA_WIDTH*(i)];
                        assign stage_4_out[DATA_WIDTH*(i+5) -1 : DATA_WIDTH*(i+5-1)] 
                            = stage_3_out[DATA_WIDTH*(i+5) -1 : DATA_WIDTH*(i+5-1)];
                        
                        end
                        endgenerate
                        
                        //stage 5
                      
                        wire[N_INPUTS* DATA_WIDTH-1:0] stage_5_out;
                        generate 
                        for(i=1;i<=3;i=i+1) begin //cae blocks:3
                        CAS_dual #(.DATA_WIDTH(DATA_WIDTH)) 
                                CAS_STAGE5
                                (.i1(stage_4_out[DATA_WIDTH*(i+1) -1 : DATA_WIDTH*(i)]),
                                .i2(stage_4_out[DATA_WIDTH*(i+4) -1 : DATA_WIDTH*(i+3)]),
                                .dir(direction),
                                .clk(clk),
                                .rst(rst),
                                .en(en),
                                .o1(stage_5_out[DATA_WIDTH*(i+1) -1 : DATA_WIDTH*(i)]),
                                .o2(stage_5_out[DATA_WIDTH*(i+4) -1 : DATA_WIDTH*(i+3)])
                                );
                              
                        end
                        endgenerate
                        generate
                        for (i=1; i<2; i=i+1) begin //only for i=1 direct connections
                            assign stage_5_out[DATA_WIDTH*(i) -1 : DATA_WIDTH*(i-1)] 
                            = stage_4_out[DATA_WIDTH*(i) -1 : DATA_WIDTH*(i-1)];
                            assign stage_5_out[DATA_WIDTH*(8*i) -1 : DATA_WIDTH*(8*i-1)] 
                            = stage_4_out[DATA_WIDTH*(8*i) -1 : DATA_WIDTH*(8*i-1)];
                         end
                         endgenerate  
                        
                        //stage 6
                        wire[N_INPUTS* DATA_WIDTH-1:0] stage_6_out;
                        generate // can merge the below two for loops but separated for clarity
                            for (i=1; i<=2; i=i+1) begin  //CAE BLOCKS                                
                                CAS_dual #(.DATA_WIDTH(DATA_WIDTH)) 
                                CAS_STAGE6
                                (.i1(stage_5_out[DATA_WIDTH*(i+2) -1 : DATA_WIDTH*(i+1)]),
                                .i2(stage_5_out[DATA_WIDTH*(i+4) -1 : DATA_WIDTH*(i+3)]),
                                .dir(direction),
                                .clk(clk),
                                .rst(rst),
                                .en(en),
                                .o1(stage_6_out[DATA_WIDTH*(i+2) -1 : DATA_WIDTH*(i+1)]),
                                .o2(stage_6_out[DATA_WIDTH*(i+4) -1 : DATA_WIDTH*(i+3)])
                                );
                            end
                        endgenerate
                            
                        generate
                        for (i=1; i<=2; i=i+1) 
                        begin //only for i=1 direct connections
                            assign stage_6_out[DATA_WIDTH*(i) -1 : DATA_WIDTH*(i-1)] 
                            = stage_5_out[DATA_WIDTH*(i) -1 : DATA_WIDTH*(i-1)];
                            assign stage_6_out[DATA_WIDTH*(i+6) -1 : DATA_WIDTH*(i+6-1)] 
                            = stage_5_out[DATA_WIDTH*(i+6) -1 : DATA_WIDTH*(i+6-1)];
                         end
                         endgenerate     
                            
                        //stage 7
                        wire[N_INPUTS* DATA_WIDTH-1:0] stage_7_out;
                        generate // can merge the below two for loops but separated for clarity
                            for (i=1; i<=3; i=i+1) begin  //CAE BLOCKS                                
                                CAS_dual #(.DATA_WIDTH(DATA_WIDTH)) 
                                CAS_STAGE7
                                (.i1(stage_6_out[DATA_WIDTH*(2*i) -1 : DATA_WIDTH*(2*i-1)]),
                                .i2(stage_6_out[DATA_WIDTH*(2*i+1) -1 : DATA_WIDTH*(2*i)]),
                                .dir(direction),
                                .clk(clk),
                                .rst(rst),
                                .en(en),
                                .o1(stage_7_out[DATA_WIDTH*(2*i) -1 : DATA_WIDTH*(2*i-1)]),
                                .o2(stage_7_out[DATA_WIDTH*(2*i+1) -1 : DATA_WIDTH*(2*i)])
                                );
                            end
                        endgenerate
                        generate
                        for (i=1; i<=2; i=i+1) //direct connections
                        begin 
                            assign stage_7_out[DATA_WIDTH*(i*i*i) -1 : DATA_WIDTH*(i*i*i-1)] 
                            = stage_6_out[DATA_WIDTH*(i*i*i) -1 : DATA_WIDTH*(i*i*i-1)];
                            
                         end
                         endgenerate  
                        
                        //stage 8
                        
                        wire[N_INPUTS* DATA_WIDTH-1:0] stage_8_out;
                        generate // can merge the below two for loops but separated for clarity
                            for (i=1; i<=2; i=i+1) begin  //CAE BLOCKS                                
                                CAS_dual #(.DATA_WIDTH(DATA_WIDTH)) 
                                CAS_STAGE8
                                (.i1(stage_7_out[DATA_WIDTH*(2*i+1) -1 : DATA_WIDTH*(2*i)]),
                                .i2(stage_7_out[DATA_WIDTH*(2*i+2) -1 : DATA_WIDTH*(2*i+1)]),
                                .dir(direction),
                                .clk(clk),
                                .rst(rst),
                                .en(en),
                                .o1(stage_8_out[DATA_WIDTH*(2*i+1) -1 : DATA_WIDTH*(2*i)]),
                                .o2(stage_8_out[DATA_WIDTH*(2*i+2) -1 : DATA_WIDTH*(2*i+1)])
                                );
                            end
                        endgenerate
                        
                        generate
                        for (i=1; i<=2; i=i+1) 
                        begin // direct connections
                            assign stage_8_out[DATA_WIDTH*(i) -1 : DATA_WIDTH*(i-1)] 
                            = stage_7_out[DATA_WIDTH*(i) -1 : DATA_WIDTH*(i-1)];
                            assign stage_8_out[DATA_WIDTH*(i+6) -1 : DATA_WIDTH*(i+6-1)] 
                            = stage_7_out[DATA_WIDTH*(i+6) -1 : DATA_WIDTH*(i+6-1)];
                            
                         end
                         endgenerate  
                        
                        
                        //stage 9
                        
                        wire[N_INPUTS* DATA_WIDTH-1:0] stage_9_out;
                        CAS_dual #(.DATA_WIDTH(DATA_WIDTH)) 
                                CAS_STAGE9
                                (.i1(stage_8_out[DATA_WIDTH*(4) -1 : DATA_WIDTH*(4-1)]),
                                .i2(stage_8_out[DATA_WIDTH*(5) -1 : DATA_WIDTH*(5-1)]),
                                .dir(direction),
                                .clk(clk),
                                .rst(rst),
                                .en(en),
                                .o1(stage_9_out[DATA_WIDTH*(4) -1 : DATA_WIDTH*(4-1)]),
                                .o2(stage_9_out[DATA_WIDTH*(5) -1 : DATA_WIDTH*(5-1)])
                                );
                        generate
                        for (i=1; i<=3; i=i+1) 
                        begin // direct connections
                            assign stage_9_out[DATA_WIDTH*(i) -1 : DATA_WIDTH*(i-1)] 
                            = stage_8_out[DATA_WIDTH*(i) -1 : DATA_WIDTH*(i-1)];
                            assign stage_9_out[DATA_WIDTH*(i+5) -1 : DATA_WIDTH*(i+5-1)] 
                            = stage_8_out[DATA_WIDTH*(i+5) -1 : DATA_WIDTH*(i+5-1)];
                            
                         end
                         endgenerate  
                        ////////////////////////////
                        
                        //data_out assignment 
                        assign data_out= stage_9_out;
                        
endmodule
