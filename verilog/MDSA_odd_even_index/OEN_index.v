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
module OEN_index#(parameter DATA_WIDTH=32,N_INPUTS=8,INDEX_WIDTH=$clog2(N_INPUTS))( //32bit wide 8 inputs to be sorted
                        input wire [N_INPUTS*DATA_WIDTH-1:0] data_in,
                        input wire clk,
                        input wire rst,
                        input wire en,
                        input wire direction,
                        output wire [N_INPUTS*DATA_WIDTH-1:0]data_out
                        );
                        reg [N_INPUTS*DATA_WIDTH-1:0] stat_buff;
			            reg [N_INPUTS*DATA_WIDTH-1:0] stat_buff_temp;
                        wire [DATA_WIDTH-1:0]stat_buff_wire[N_INPUTS-1:0];
                        
                        genvar z;
                        generate 
                            for(z=1;z<=8;z=z+1) begin 
                                assign stat_buff_wire[z-1]=stat_buff[DATA_WIDTH*z -1 : DATA_WIDTH*(z-1)];
                            end
                        endgenerate 
                        
                        always@* begin 
                            if(en) begin 
                                stat_buff_temp=data_in;
                            end
                            else begin 
                                stat_buff_temp=stat_buff;
                            end
                        end
                        
                        always@(posedge clk) begin 
                            if(!rst) begin 
                                stat_buff<=stat_buff_temp;
                            end
                            else begin 
                                stat_buff<='b0;
                            end
                        end
                        
                        genvar i;
                        wire [31:0]data_in_test[7:0];
                        generate 
                        for(i=1;i<=N_INPUTS;i=i+1) begin 
                        assign data_in_test[i-1]=data_in[i*DATA_WIDTH-1:(i-1)*DATA_WIDTH];
                        
                        end
                        endgenerate 
                        //stage 1
                        wire [N_INPUTS*INDEX_WIDTH-1:0] 
                        stage_1_index={3'd7,3'd6,3'd5,3'd4,3'd3,3'd2,3'd1,3'd0};
                        
                        
                        wire [N_INPUTS*DATA_WIDTH-1:0] stage_1_out;
                        wire [N_INPUTS*INDEX_WIDTH-1:0] stage_2_index;
                        //wire[N_INPUTS* DATA_WIDTH-1:0] stage_1_out;
                        generate 
                            for (i=1; i<=4; i=i+1) begin                                
                                CAS_index#(.DATA_WIDTH(DATA_WIDTH),.N_INPUTS(N_INPUTS)) 
                                CAS_STAGE1
                                (
                                .i1(data_in[DATA_WIDTH*(2*i-1) -1 : DATA_WIDTH*(2*i-2)]),
                                .i2(data_in[DATA_WIDTH*(2*i) -1 : DATA_WIDTH*(2*i-1)]),
                                .id1(stage_1_index[INDEX_WIDTH*(2*i-1) -1 : INDEX_WIDTH*(2*i-2)]),
                                .id2(stage_1_index[INDEX_WIDTH*(2*i) -1 : INDEX_WIDTH*(2*i-1)]),
                                
                                .dir(direction),
                                .clk(clk),
                                .rst(rst),
                                .en(en),
//                                .o1(stage_1_out[DATA_WIDTH*(2*i-1) -1 : DATA_WIDTH*(2*i-2)]),
//                                .o2(stage_1_out[DATA_WIDTH*(2*i) -1 : DATA_WIDTH*(2*i-1)])
                                 .od1(stage_2_index[INDEX_WIDTH*(2*i-1) -1 : INDEX_WIDTH*(2*i-2)]),
                                 .od2(stage_2_index[INDEX_WIDTH*(2*i) -1 : INDEX_WIDTH*(2*i-1)])
                                 );
                            end
                        endgenerate                  
                        
                        //Recovery unit
                        genvar y;
                        generate 
                        for(y=1;y<=8;y=y+1) begin
                            assign stage_1_out[DATA_WIDTH*y -1 : DATA_WIDTH*(y-1)]=stat_buff_wire[stage_2_index[INDEX_WIDTH*y -1 : INDEX_WIDTH*(y-1)]];
                            end
                        endgenerate 
                        
                        //stage 2
                        //upper block
                        wire [N_INPUTS* DATA_WIDTH-1:0]stage_2_out;
                        wire [N_INPUTS*INDEX_WIDTH-1:0] stage_3_index;

                        generate 
                            for (i=1; i<=2; i=i+1) begin                                
                                CAS_index#(.DATA_WIDTH(DATA_WIDTH),.N_INPUTS(N_INPUTS)) 
                                CAS_STAGE21
                                (.i1(stage_1_out[DATA_WIDTH*(i) -1 : DATA_WIDTH*(i-1)]),
                                .i2(stage_1_out[DATA_WIDTH*(i+2) -1 : DATA_WIDTH*(i+2-1)]),
                                .id1(stage_2_index[INDEX_WIDTH*(i) -1 : INDEX_WIDTH*(i-1)]),
                                .id2(stage_2_index[INDEX_WIDTH*(i+2) -1 : INDEX_WIDTH*(i+2-1)]),
                                .dir(direction),
                                .clk(clk),
                                .rst(rst),
                                .en(en),
//                                .o1(stage_2_out[DATA_WIDTH*(i) -1 : DATA_WIDTH*(i-1)]),
//                                .o2(stage_2_out[DATA_WIDTH*(i+2) -1 : DATA_WIDTH*(i+2-1)])
                                .od1(stage_3_index[INDEX_WIDTH*(i) -1 : INDEX_WIDTH*(i-1)]),
                                .od2(stage_3_index[INDEX_WIDTH*(i+2) -1 : INDEX_WIDTH*(i+2-1)])
                                );
                            end
                        endgenerate 

                        generate 
                            for (i=1; i<=2; i=i+1) begin                                
                                CAS_index#(.DATA_WIDTH(DATA_WIDTH),.N_INPUTS(N_INPUTS))
                                CAS_STAGE21
                                (.i1(stage_1_out[DATA_WIDTH*(i+4) -1 : DATA_WIDTH*(i+4-1)]),
                                .i2(stage_1_out[DATA_WIDTH*(i+6) -1 : DATA_WIDTH*(i+6-1)]),
                                .id1(stage_2_index[INDEX_WIDTH*(i+4) -1 : INDEX_WIDTH*(i+4-1)]),
                                .id2(stage_2_index[INDEX_WIDTH*(i+6) -1 : INDEX_WIDTH*(i+6-1)]),
                                .dir(direction),
                                .clk(clk),
                                .rst(rst),
                                .en(en),
//                                .o1(stage_2_out[DATA_WIDTH*(i+4) -1 : DATA_WIDTH*(i+4-1)]),
//                                .o2(stage_2_out[DATA_WIDTH*(i+6) -1 : DATA_WIDTH*(i+6-1)])
                                .od1(stage_3_index[INDEX_WIDTH*(i+4) -1 : INDEX_WIDTH*(i+4-1)]),
                                .od2(stage_3_index[INDEX_WIDTH*(i+6) -1 : INDEX_WIDTH*(i+6-1)])
                                );
                            end
                        endgenerate 
                        //Recovery unit
                        generate 
                        for(y=1;y<=8;y=y+1) begin
                            assign stage_2_out[DATA_WIDTH*y -1 : DATA_WIDTH*(y-1)]=stat_buff_wire[stage_3_index[INDEX_WIDTH*y -1 : INDEX_WIDTH*(y-1)]];
                            end
                        endgenerate 
                        
                        //stage 3
                        
                        wire[N_INPUTS* DATA_WIDTH-1:0] stage_3_out; 
                        wire [N_INPUTS*INDEX_WIDTH-1:0] stage_4_index;
                        generate // can merge the below two for loops but separated for clarity
                            
                            for (i=1; i<=2; i=i+1) begin  //CAE BLOCKS                                
                                CAS_index#(.DATA_WIDTH(DATA_WIDTH),.N_INPUTS(N_INPUTS))
                                CAS_STAGE3
                                (.i1(stage_2_out[DATA_WIDTH*(4*i-2) -1 : DATA_WIDTH*(4*i-3)]),
                                .i2(stage_2_out[DATA_WIDTH*(4*i-1) -1 : DATA_WIDTH*(4*i-2)]),
                                .id1(stage_3_index[INDEX_WIDTH*(4*i-2) -1 : INDEX_WIDTH*(4*i-3)]),
                                .id2(stage_3_index[INDEX_WIDTH*(4*i-1) -1 : INDEX_WIDTH*(4*i-2)]),
                                .dir(direction),
                                .clk(clk),
                                .rst(rst),
                                .en(en),
//                                .o1(stage_3_out[DATA_WIDTH*(4*i-2) -1 : DATA_WIDTH*(4*i-3)]),
//                                .o2(stage_3_out[DATA_WIDTH*(4*i-1) -1 : DATA_WIDTH*(4*i-2)])
                                .od1(stage_4_index[INDEX_WIDTH*(4*i-2) -1 : INDEX_WIDTH*(4*i-3)]),
                                .od2(stage_4_index[INDEX_WIDTH*(4*i-1) -1 : INDEX_WIDTH*(4*i-2)])
                                                           
                                );
                                //recovery cas
                                assign stage_3_out[DATA_WIDTH*(4*i-2) -1 : DATA_WIDTH*(4*i-3)]
                                =stat_buff_wire[stage_4_index[INDEX_WIDTH*(4*i-2) -1 : INDEX_WIDTH*(4*i-3)]];
                                assign stage_3_out[DATA_WIDTH*(4*i-1) -1 : DATA_WIDTH*(4*i-2)]
                                =stat_buff_wire[stage_4_index[INDEX_WIDTH*(4*i-1) -1 : INDEX_WIDTH*(4*i-2)]];
                            end
                       
                            for(i=1;i<=2;i=i+1) begin //direct connections
                            assign stage_3_out[DATA_WIDTH*(4*i-3) -1 : DATA_WIDTH*(4*i-4)] 
                            = stat_buff_wire[stage_4_index[INDEX_WIDTH*(4*i-3) -1 : INDEX_WIDTH*(4*i-4)]];
                            assign stage_3_out[DATA_WIDTH*(4*i) -1 : DATA_WIDTH*(4*i-1)] 
                            = stat_buff_wire[stage_4_index[INDEX_WIDTH*(4*i) -1 : INDEX_WIDTH*(4*i-1)]];
                            
                            //recovery direct
                            assign stage_4_index[INDEX_WIDTH*(4*i-3) -1 : INDEX_WIDTH*(4*i-4)] =stage_3_index[INDEX_WIDTH*(4*i-3) -1 : INDEX_WIDTH*(4*i-4)];
                            assign stage_4_index[INDEX_WIDTH*(4*i) -1 : INDEX_WIDTH*(4*i-1)] =stage_3_index[INDEX_WIDTH*(4*i) -1 : INDEX_WIDTH*(4*i-1)];
                            end
                            
                        endgenerate
                        
                        //Stage 4
                        wire [N_INPUTS*DATA_WIDTH -1:0] stage_4_out;
                        wire [N_INPUTS*INDEX_WIDTH-1:0] stage_5_index;
                        generate
                        for (i=1; i<=4; i=i+1) begin 
                                CAS_index#(.DATA_WIDTH(DATA_WIDTH),.N_INPUTS(N_INPUTS)) 
                                CAS_STAGE4(
                                .i1(stage_3_out[DATA_WIDTH*(i) -1 : DATA_WIDTH*(i-1)]),
                                .i2(stage_3_out[DATA_WIDTH*(i+4) -1 : DATA_WIDTH*(i+3)]),
                                .id1(stage_4_index[INDEX_WIDTH*(i) -1 : INDEX_WIDTH*(i-1)]),
                                .id2(stage_4_index[INDEX_WIDTH*(i+4) -1 : INDEX_WIDTH*(i+3)]),
                                .dir(direction),.clk(clk),.rst(rst),.en(en),
//                                .o1(stage_4_out[DATA_WIDTH*(i) -1 : DATA_WIDTH*(i-1)]),
//                                .o2(stage_4_out[DATA_WIDTH*(i+4) -1 : DATA_WIDTH*(i+3)])
                                .od1(stage_5_index[INDEX_WIDTH*(i) -1 : INDEX_WIDTH*(i-1)]),
                                .od2(stage_5_index[INDEX_WIDTH*(i+4) -1 : INDEX_WIDTH*(i+3)])
                                );  
                         
                         //recovery CAS

                         assign stage_4_out[DATA_WIDTH*(i) -1 : DATA_WIDTH*(i-1)]=stat_buff_wire[stage_5_index[INDEX_WIDTH*(i) -1 : INDEX_WIDTH*(i-1)]];        
                         assign stage_4_out[DATA_WIDTH*(i+4) -1 : DATA_WIDTH*(i+3)]=stat_buff_wire[stage_5_index[INDEX_WIDTH*(i+4) -1 : INDEX_WIDTH*(i+3)]];        
                         end
                         endgenerate   
                                    
                        //Stage 5 
                        wire [N_INPUTS*DATA_WIDTH -1:0] stage_5_out;
                        wire [N_INPUTS*INDEX_WIDTH-1:0] stage_6_index;
                        generate 
                            for (i=1; i<=2; i=i+1) begin  //CAE BLOCKS                                
                                CAS_index#(.DATA_WIDTH(DATA_WIDTH),.N_INPUTS(N_INPUTS)) 
                                CAS_STAGE5(
                                .i1(stage_4_out[DATA_WIDTH*(i+2) -1 : DATA_WIDTH*(i+1)]),
                                .i2(stage_4_out[DATA_WIDTH*(i+4) -1 : DATA_WIDTH*(i+3)]),
                                .id1(stage_5_index[INDEX_WIDTH*(i+2) -1 : INDEX_WIDTH*(i+1)]),
                                .id2(stage_5_index[INDEX_WIDTH*(i+4) -1 : INDEX_WIDTH*(i+3)]),
                                .dir(direction),.clk(clk),.rst(rst),.en(en),
//                                .o1(stage_5_out[DATA_WIDTH*(i+2) -1 : DATA_WIDTH*(i+1)]),
//                                .o2(stage_5_out[DATA_WIDTH*(i+4) -1 : DATA_WIDTH*(i+3)])
                                .od1(stage_6_index[INDEX_WIDTH*(i+2) -1 : INDEX_WIDTH*(i+1)]),
                                .od2(stage_6_index[INDEX_WIDTH*(i+4) -1 : INDEX_WIDTH*(i+3)])

                                );
                                
                                //recovery CAS 
                                assign stage_5_out[DATA_WIDTH*(i+2) -1 : DATA_WIDTH*(i+1)]=stat_buff_wire[stage_6_index[INDEX_WIDTH*(i+2) -1 : INDEX_WIDTH*(i+1)]];
                                assign stage_5_out[DATA_WIDTH*(i+4) -1 : DATA_WIDTH*(i+3)]=stat_buff_wire[stage_6_index[INDEX_WIDTH*(i+4) -1 : INDEX_WIDTH*(i+3)]];
                            end
                        endgenerate
                            
                        generate //direct connections
                        for (i=1; i<=2; i=i+1) 
                        begin 
                            assign stage_5_out[DATA_WIDTH*(i) -1 : DATA_WIDTH*(i-1)] 
                            = stage_4_out[DATA_WIDTH*(i) -1 : DATA_WIDTH*(i-1)];
                            assign stage_5_out[DATA_WIDTH*(i+6) -1 : DATA_WIDTH*(i+6-1)] 
                            = stage_4_out[DATA_WIDTH*(i+6) -1 : DATA_WIDTH*(i+6-1)];
                         
                         //recovery direct
                         
                         assign stage_6_index[INDEX_WIDTH*(i) -1 : INDEX_WIDTH*(i-1)] =stage_5_index[INDEX_WIDTH*(i) -1 : INDEX_WIDTH*(i-1)];
                         assign stage_6_index[INDEX_WIDTH*(i+6) -1 : INDEX_WIDTH*(i+6-1)] =stage_5_index[INDEX_WIDTH*(i+6) -1 : INDEX_WIDTH*(i+6-1)];
                         end 
                         endgenerate                        
                        
                        
                        //till here
                        //Stage 6
                        wire [N_INPUTS*DATA_WIDTH -1:0] stage_6_out;
                        wire [N_INPUTS*INDEX_WIDTH-1:0] stage_7_index;
                        generate 
                            for (i=1; i<=3; i=i+1) begin  //CAE BLOCKS                                
                                CAS_index#(.DATA_WIDTH(DATA_WIDTH),.N_INPUTS(N_INPUTS)) 
                                CAS_STAGE6
                                (.i1(stage_5_out[DATA_WIDTH*(2*i) -1 : DATA_WIDTH*(2*i-1)]),
                                .i2(stage_5_out[DATA_WIDTH*(2*i+1) -1 : DATA_WIDTH*(2*i)]),
                                .id1(stage_6_index[INDEX_WIDTH*(2*i) -1 : INDEX_WIDTH*(2*i-1)]),
                                .id2(stage_6_index[INDEX_WIDTH*(2*i+1) -1 : INDEX_WIDTH*(2*i)]),
                                .dir(direction),.clk(clk),.rst(rst),.en(en),
//                                .o1(stage_6_out[DATA_WIDTH*(2*i) -1 : DATA_WIDTH*(2*i-1)]),
//                                .o2(stage_6_out[DATA_WIDTH*(2*i+1) -1 : DATA_WIDTH*(2*i)])
                                .od1(stage_7_index[INDEX_WIDTH*(2*i) -1 : INDEX_WIDTH*(2*i-1)]),
                                .od2(stage_7_index[INDEX_WIDTH*(2*i+1) -1 : INDEX_WIDTH*(2*i)]) 

                                 );
                            //recovery CAS
                            assign stage_6_out[DATA_WIDTH*(2*i) -1 : DATA_WIDTH*(2*i-1)]=stat_buff_wire[stage_7_index[INDEX_WIDTH*(2*i) -1 : INDEX_WIDTH*(2*i-1)]];
                            assign stage_6_out[DATA_WIDTH*(2*i+1) -1 : DATA_WIDTH*(2*i)]=stat_buff_wire[stage_7_index[INDEX_WIDTH*(2*i+1) -1 : INDEX_WIDTH*(2*i)]];
                            end  
                        endgenerate
                        generate
                        for (i=1; i<=2; i=i+1) //direct connections
                        begin 
                            assign stage_7_index[INDEX_WIDTH*(i*i*i) -1 : INDEX_WIDTH*(i*i*i-1)] 
                            = stage_6_index[INDEX_WIDTH*(i*i*i) -1 : INDEX_WIDTH*(i*i*i-1)];
                         
                         //recovery direct
                         assign stage_6_out[DATA_WIDTH*(i*i*i) -1 : DATA_WIDTH*(i*i*i-1)] = stat_buff_wire[stage_7_index[INDEX_WIDTH*(i*i*i) -1 : INDEX_WIDTH*(i*i*i-1)]];
                         end
                         endgenerate
                         
                        assign data_out = stage_6_out;
                        
                        wire [31:0]data_out_tb[7:0];
                        genvar j;
                        generate 
                        for(j=1;j<=N_INPUTS;j=j+1) begin 
                        assign data_out_tb[j-1]=data_out[j*DATA_WIDTH-1:(j-1)*DATA_WIDTH];
                        end
                        endgenerate     
endmodule
