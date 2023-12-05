`timescale 10ns / 1ps
//`include "CAS_index.sv"
module HSN_index#(parameter DATA_WIDTH=32,N_INPUTS=8,INDEX_WIDTH=$clog2(N_INPUTS))( //32bit wide 8 inputs to be sorted
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
                        //genvar i;
                        
                       
                        
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
//                        //Recovery unit redundant here, done at the end of stage 2
//                        generate 
//                        for(y=1;y<=8;y=y+1) begin
//                            assign stage_2_out[DATA_WIDTH*y -1 : DATA_WIDTH*(y-1)]=stat_buff_wire[stage_3_index[INDEX_WIDTH*y -1 : INDEX_WIDTH*(y-1)]];
//                            end
//                        endgenerate 
                        //stage 2
                        //lower block
                     
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
                        //Recovery unit
//                        generate 
//                        for(y=1;y<=8;y=y+1) begin
//                            assign stage_3_out[DATA_WIDTH*y -1 : DATA_WIDTH*(y-1)]=stat_buff_wire[stage_4_index[INDEX_WIDTH*y -1 : INDEX_WIDTH*(y-1)]];
//                            end
//                        endgenerate 
                        
                        
                        ////////////////////////////
                        //stage 4
                        
                        wire[N_INPUTS* DATA_WIDTH-1:0] stage_4_out;
                        wire [N_INPUTS*INDEX_WIDTH-1:0] stage_5_index;

                        
                        generate
                        for (i=1; i<2; i=i+1) begin //only for i=1
                                CAS_index#(.DATA_WIDTH(DATA_WIDTH),.N_INPUTS(N_INPUTS))
                        CAS_STAGE41
                                (.i1(stage_3_out[DATA_WIDTH*(4*i-3) -1 : DATA_WIDTH*(4*i-4)]),
                                .i2(stage_3_out[DATA_WIDTH*(4*i+1) -1 : DATA_WIDTH*(4*i)]),
                                .id1(stage_4_index[INDEX_WIDTH*(4*i-3) -1 : INDEX_WIDTH*(4*i-4)]),
                                .id2(stage_4_index[INDEX_WIDTH*(4*i+1) -1 : INDEX_WIDTH*(4*i)]),
                                .dir(direction),
                                .clk(clk),
                                .rst(rst),
                                .en(en),
//                                .o1(stage_4_out[DATA_WIDTH*(4*i-3) -1 : DATA_WIDTH*(4*i-4)]),
//                                .o2(stage_4_out[DATA_WIDTH*(4*i+1) -1 : DATA_WIDTH*(4*i)])
                                .od1(stage_5_index[INDEX_WIDTH*(4*i-3) -1 : INDEX_WIDTH*(4*i-4)]),
                                .od2(stage_5_index[INDEX_WIDTH*(4*i+1) -1 : INDEX_WIDTH*(4*i)])
                                );
                        CAS_index#(.DATA_WIDTH(DATA_WIDTH),.N_INPUTS(N_INPUTS))
                        CAS_STAGE42
                                (.i1(stage_3_out[DATA_WIDTH*(4*i) -1 : DATA_WIDTH*(4*i-1)]),
                                .i2(stage_3_out[DATA_WIDTH*(4*i+4) -1 : DATA_WIDTH*(4*i+4-1)]),
                                .id1(stage_4_index[INDEX_WIDTH*(4*i) -1 : INDEX_WIDTH*(4*i-1)]),
                                .id2(stage_4_index[INDEX_WIDTH*(4*i+4) -1 : INDEX_WIDTH*(4*i+4-1)]),
                                .dir(direction),
                                .clk(clk),
                                .rst(rst),
                                .en(en),
//                                .o1(stage_4_out[DATA_WIDTH*(4*i) -1 : DATA_WIDTH*(4*i-1)]),
//                                .o2(stage_4_out[DATA_WIDTH*(4*i+4) -1 : DATA_WIDTH*(4*i+4-1)])
                                .od1(stage_5_index[INDEX_WIDTH*(4*i) -1 : INDEX_WIDTH*(4*i-1)]),
                                .od2(stage_5_index[INDEX_WIDTH*(4*i+4) -1 : INDEX_WIDTH*(4*i+4-1)])
                                );    
                                
                         //recovery cas
                         assign stage_4_out[DATA_WIDTH*(4*i-3) -1 : DATA_WIDTH*(4*i-4)]=stat_buff_wire[stage_5_index[INDEX_WIDTH*(4*i-3) -1 : INDEX_WIDTH*(4*i-4)]];   
                         assign stage_4_out[DATA_WIDTH*(4*i+1) -1 : DATA_WIDTH*(4*i)]=stat_buff_wire[stage_5_index[INDEX_WIDTH*(4*i+1) -1 : INDEX_WIDTH*(4*i)]]; 
                         assign stage_4_out[DATA_WIDTH*(4*i) -1 : DATA_WIDTH*(4*i-1)]=stat_buff_wire[stage_5_index[INDEX_WIDTH*(4*i) -1 : INDEX_WIDTH*(4*i-1)]];   
                         assign stage_4_out[DATA_WIDTH*(4*i+4) -1 : DATA_WIDTH*(4*i+4-1)]=stat_buff_wire[stage_5_index[INDEX_WIDTH*(4*i+4) -1 : INDEX_WIDTH*(4*i+4-1)]];   
                                
                         end
                         endgenerate    
                                
                        generate 
                        for(i=1;i<=2;i=i+1) begin //direct connections                                
                                                                       
                        assign stage_4_out[DATA_WIDTH*(i+1) -1 : DATA_WIDTH*(i)] 
                            = stat_buff_wire[stage_5_index[INDEX_WIDTH*(i+1) -1 : INDEX_WIDTH*(i)]];
                        assign stage_4_out[DATA_WIDTH*(i+5) -1 : DATA_WIDTH*(i+5-1)] 
                            =  stat_buff_wire[stage_5_index[INDEX_WIDTH*(i+5) -1 : INDEX_WIDTH*(i+5-1)]];
                            
                        //recovery direct
                        assign stage_5_index[INDEX_WIDTH*(i+1) -1 : INDEX_WIDTH*(i)] =stage_4_index[INDEX_WIDTH*(i+1) -1 : INDEX_WIDTH*(i)];
                        assign stage_5_index[INDEX_WIDTH*(i+5) -1 : INDEX_WIDTH*(i+5-1)] =stage_4_index[INDEX_WIDTH*(i+5) -1 : INDEX_WIDTH*(i+5-1)];
                            
                        
                        end
                        endgenerate
                        
                        //Recovery unit
//                        generate 
//                        for(y=1;y<=8;y=y+1) begin
//                            assign stage_4_out[DATA_WIDTH*y -1 : DATA_WIDTH*(y-1)]=stat_buff_wire[stage_5_index[INDEX_WIDTH*y -1 : INDEX_WIDTH*(y-1)]];
//                            end
//                        endgenerate 
                        
                        
                        //stage 5
                      
                        wire[N_INPUTS* DATA_WIDTH-1:0] stage_5_out;
                        wire [N_INPUTS*INDEX_WIDTH-1:0] stage_6_index;

                        generate 
                        for(i=1;i<=3;i=i+1) begin //cae blocks:3
                                CAS_index#(.DATA_WIDTH(DATA_WIDTH),.N_INPUTS(N_INPUTS))
                                CAS_STAGE5
                                (.i1(stage_4_out[DATA_WIDTH*(i+1) -1 : DATA_WIDTH*(i)]),
                                .i2(stage_4_out[DATA_WIDTH*(i+4) -1 : DATA_WIDTH*(i+3)]),
                                .id1(stage_5_index[INDEX_WIDTH*(i+1) -1 : INDEX_WIDTH*(i)]),
                                .id2(stage_5_index[INDEX_WIDTH*(i+4) -1 : INDEX_WIDTH*(i+3)]),
                                .dir(direction),
                                .clk(clk),
                                .rst(rst),
                                .en(en),
//                                .o1(stage_5_out[DATA_WIDTH*(i+1) -1 : DATA_WIDTH*(i)]),
//                                .o2(stage_5_out[DATA_WIDTH*(i+4) -1 : DATA_WIDTH*(i+3)])
                                .od1(stage_6_index[INDEX_WIDTH*(i+1) -1 : INDEX_WIDTH*(i)]),
                                .od2(stage_6_index[INDEX_WIDTH*(i+4) -1 : INDEX_WIDTH*(i+3)])
                                );
                              
                              //recovery cas
                         assign stage_5_out[DATA_WIDTH*(i+1) -1 : DATA_WIDTH*(i)]=stat_buff_wire[stage_6_index[INDEX_WIDTH*(i+1) -1 : INDEX_WIDTH*(i)]];   
                         assign stage_5_out[DATA_WIDTH*(i+4) -1 : DATA_WIDTH*(i+3)]=stat_buff_wire[stage_6_index[INDEX_WIDTH*(i+4) -1 : INDEX_WIDTH*(i+3)]];   
                        end
                        endgenerate
                        
                        
                        generate
                        for (i=1; i<2; i=i+1) begin //only for i=1 direct connections
                            assign stage_5_out[DATA_WIDTH*(i) -1 : DATA_WIDTH*(i-1)] 
                            =  stat_buff_wire[stage_6_index[INDEX_WIDTH*(i) -1 : INDEX_WIDTH*(i-1)]];
                            assign stage_5_out[DATA_WIDTH*(8*i) -1 : DATA_WIDTH*(8*i-1)] 
                            =  stat_buff_wire[stage_6_index[INDEX_WIDTH*(8*i) -1 : INDEX_WIDTH*(8*i-1)]];
                            
                            //recovery direct
                            assign stage_6_index[INDEX_WIDTH*(i) -1 : INDEX_WIDTH*(i-1)] =stage_5_index[INDEX_WIDTH*(i) -1 : INDEX_WIDTH*(i-1)];
                            assign stage_6_index[INDEX_WIDTH*(8*i) -1 : INDEX_WIDTH*(8*i-1)] =stage_5_index[INDEX_WIDTH*(8*i) -1 : INDEX_WIDTH*(8*i-1)];
                            
                         end
                         endgenerate  
                         
                         //Recovery unit
//                        generate 
//                        for(y=1;y<=8;y=y+1) begin
//                            assign stage_5_out[DATA_WIDTH*y -1 : DATA_WIDTH*(y-1)]=stat_buff_wire[stage_6_index[INDEX_WIDTH*y -1 : INDEX_WIDTH*(y-1)]];
//                            end
//                        endgenerate 
                        
                        //stage 6
                        wire[N_INPUTS* DATA_WIDTH-1:0] stage_6_out;
                        wire [N_INPUTS*INDEX_WIDTH-1:0] stage_7_index;
                        generate // can merge the below two for loops but separated for clarity
                            for (i=1; i<=2; i=i+1) begin  //CAE BLOCKS                                
                                CAS_index#(.DATA_WIDTH(DATA_WIDTH),.N_INPUTS(N_INPUTS))
                                CAS_STAGE6
                                (.i1(stage_5_out[DATA_WIDTH*(i+2) -1 : DATA_WIDTH*(i+1)]),
                                .i2(stage_5_out[DATA_WIDTH*(i+4) -1 : DATA_WIDTH*(i+3)]),
                                .id1(stage_6_index[INDEX_WIDTH*(i+2) -1 : INDEX_WIDTH*(i+1)]),
                                .id2(stage_6_index[INDEX_WIDTH*(i+4) -1 : INDEX_WIDTH*(i+3)]),
                                .dir(direction),
                                .clk(clk),
                                .rst(rst),
                                .en(en),
//                                .o1(stage_6_out[DATA_WIDTH*(i+2) -1 : DATA_WIDTH*(i+1)]),
//                                .o2(stage_6_out[DATA_WIDTH*(i+4) -1 : DATA_WIDTH*(i+3)])
                                .od1(stage_7_index[INDEX_WIDTH*(i+2) -1 : INDEX_WIDTH*(i+1)]),
                                .od2(stage_7_index[INDEX_WIDTH*(i+4) -1 : INDEX_WIDTH*(i+3)])
                                );
                                
                                //recovery cas
                             assign stage_6_out[DATA_WIDTH*(i+2) -1 : DATA_WIDTH*(i+1)]=stat_buff_wire[stage_7_index[INDEX_WIDTH*(i+2) -1 : INDEX_WIDTH*(i+1)]];
                             assign stage_6_out[DATA_WIDTH*(i+4) -1 : DATA_WIDTH*(i+3)]=stat_buff_wire[stage_7_index[INDEX_WIDTH*(i+4) -1 : INDEX_WIDTH*(i+3)]];

                            end
                        endgenerate
                            
                        generate
                        for (i=1; i<=2; i=i+1) 
                        begin //only for i=1 direct connections
                            assign stage_6_out[DATA_WIDTH*(i) -1 : DATA_WIDTH*(i-1)] 
                            = stat_buff_wire[stage_7_index[INDEX_WIDTH*(i) -1 : INDEX_WIDTH*(i-1)]];
                            assign stage_6_out[DATA_WIDTH*(i+6) -1 : DATA_WIDTH*(i+6-1)] 
                            = stat_buff_wire[stage_7_index[INDEX_WIDTH*(i+6) -1 : INDEX_WIDTH*(i+6-1)]];
                            
                            //recovery direct
                            assign stage_7_index[INDEX_WIDTH*(i) -1 : INDEX_WIDTH*(i-1)] =stage_6_index[INDEX_WIDTH*(i) -1 : INDEX_WIDTH*(i-1)];
                            assign stage_7_index[INDEX_WIDTH*(i+6) -1 : INDEX_WIDTH*(i+6-1)] =stage_6_index[INDEX_WIDTH*(i+6) -1 : INDEX_WIDTH*(i+6-1)];
                            
                         end
                         
                         endgenerate     
                      
                        
                            
                        //stage 7
                        wire[N_INPUTS* DATA_WIDTH-1:0] stage_7_out;
                        wire [N_INPUTS*INDEX_WIDTH-1:0] stage_8_index;
                        generate // can merge the below two for loops but separated for clarity
                            for (i=1; i<=3; i=i+1) begin  //CAE BLOCKS                                
                                CAS_index#(.DATA_WIDTH(DATA_WIDTH),.N_INPUTS(N_INPUTS))
                                CAS_STAGE7
                                (.i1(stage_6_out[DATA_WIDTH*(2*i) -1 : DATA_WIDTH*(2*i-1)]),
                                .i2(stage_6_out[DATA_WIDTH*(2*i+1) -1 : DATA_WIDTH*(2*i)]),
                                .id1(stage_7_index[INDEX_WIDTH*(2*i) -1 : INDEX_WIDTH*(2*i-1)]),
                                .id2(stage_7_index[INDEX_WIDTH*(2*i+1) -1 : INDEX_WIDTH*(2*i)]),
                                .dir(direction),
                                .clk(clk),
                                .rst(rst),
                                .en(en),
//                                .o1(stage_7_out[DATA_WIDTH*(2*i) -1 : DATA_WIDTH*(2*i-1)]),
//                                .o2(stage_7_out[DATA_WIDTH*(2*i+1) -1 : DATA_WIDTH*(2*i)])
                                .od1(stage_8_index[INDEX_WIDTH*(2*i) -1 : INDEX_WIDTH*(2*i-1)]),
                                .od2(stage_8_index[INDEX_WIDTH*(2*i+1) -1 : INDEX_WIDTH*(2*i)])
                                );
                                //recovery cas
                             assign stage_7_out[DATA_WIDTH*(2*i) -1 : DATA_WIDTH*(2*i-1)]
                             =stat_buff_wire[stage_8_index[INDEX_WIDTH*(2*i) -1 : INDEX_WIDTH*(2*i-1)]];
                             assign stage_7_out[DATA_WIDTH*(2*i+1) -1 : DATA_WIDTH*(2*i)]
                             =stat_buff_wire[stage_8_index[INDEX_WIDTH*(2*i+1) -1 : INDEX_WIDTH*(2*i)]];
                            end
                        endgenerate
                        
                        
                        generate
                        for (i=1; i<=2; i=i+1) //direct connections
                        begin 
                            assign stage_7_out[DATA_WIDTH*(i*i*i) -1 : DATA_WIDTH*(i*i*i-1)] 
                            = stat_buff_wire[stage_8_index[INDEX_WIDTH*(i*i*i) -1 : INDEX_WIDTH*(i*i*i-1)]];
                       
                         
                         //recovery direct
                            assign stage_8_index[INDEX_WIDTH*(i*i*i) -1 : INDEX_WIDTH*(i*i*i-1)] =
                            stage_7_index[INDEX_WIDTH*(i*i*i) -1 : INDEX_WIDTH*(i*i*i-1)];
                            end
                         endgenerate  
           
                        
                        //stage 8
                        
                        wire[N_INPUTS* DATA_WIDTH-1:0] stage_8_out;
                        wire [N_INPUTS*INDEX_WIDTH-1:0] stage_9_index;
                        generate // can merge the below two for loops but separated for clarity
                            for (i=1; i<=2; i=i+1) begin  //CAE BLOCKS                                
                                CAS_index#(.DATA_WIDTH(DATA_WIDTH),.N_INPUTS(N_INPUTS))
                                CAS_STAGE8
                                (.i1(stage_7_out[DATA_WIDTH*(2*i+1) -1 : DATA_WIDTH*(2*i)]),
                                .i2(stage_7_out[DATA_WIDTH*(2*i+2) -1 : DATA_WIDTH*(2*i+1)]),
                                .id1(stage_8_index[INDEX_WIDTH*(2*i+1) -1 : INDEX_WIDTH*(2*i)]),
                                .id2(stage_8_index[INDEX_WIDTH*(2*i+2) -1 : INDEX_WIDTH*(2*i+1)]),
                                .dir(direction),
                                .clk(clk),
                                .rst(rst),
                                .en(en),
//                                .o1(stage_8_out[DATA_WIDTH*(2*i+1) -1 : DATA_WIDTH*(2*i)]),
//                                .o2(stage_8_out[DATA_WIDTH*(2*i+2) -1 : DATA_WIDTH*(2*i+1)])
                                .od1(stage_9_index[INDEX_WIDTH*(2*i+1) -1 : INDEX_WIDTH*(2*i)]),
                                .od2(stage_9_index[INDEX_WIDTH*(2*i+2) -1 : INDEX_WIDTH*(2*i+1)])
                                );
                                
                                //recovery cas
                                assign stage_8_out[DATA_WIDTH*(2*i+1) -1 : DATA_WIDTH*(2*i)]
                             =stat_buff_wire[stage_9_index[INDEX_WIDTH*(2*i+1) -1 : INDEX_WIDTH*(2*i)]];
                                assign stage_8_out[DATA_WIDTH*(2*i+2) -1 : DATA_WIDTH*(2*i+1)]
                             =stat_buff_wire[stage_9_index[INDEX_WIDTH*(2*i+2) -1 : INDEX_WIDTH*(2*i+1)]];
                            end
                        endgenerate
                        
                        generate
                        for (i=1; i<=2; i=i+1) 
                        begin // direct connections
                            assign stage_8_out[DATA_WIDTH*(i) -1 : DATA_WIDTH*(i-1)] 
                            = stat_buff_wire[stage_9_index[INDEX_WIDTH*(i) -1 : INDEX_WIDTH*(i-1)]];
                            assign stage_8_out[DATA_WIDTH*(i+6) -1 : DATA_WIDTH*(i+6-1)] 
                            = stat_buff_wire[stage_9_index[INDEX_WIDTH*(i+6) -1 : INDEX_WIDTH*(i+6-1)]];
                            
                         
                         //recovery direct
                            assign stage_9_index[INDEX_WIDTH*(i) -1 : INDEX_WIDTH*(i-1)] =
                            stage_8_index[INDEX_WIDTH*(i) -1 : INDEX_WIDTH*(i-1)];
                            assign stage_9_index[INDEX_WIDTH*(i+6) -1 : INDEX_WIDTH*(i+6-1)] =
                            stage_8_index[INDEX_WIDTH*(i+6) -1 : INDEX_WIDTH*(i+6-1)];
                            
                            
                            end                         
                         endgenerate  
                        
                        
                        //stage 9
                        
                        wire[N_INPUTS* DATA_WIDTH-1:0] stage_9_out;
                        wire [N_INPUTS*INDEX_WIDTH-1:0] stage_10_index;

                                CAS_index#(.DATA_WIDTH(DATA_WIDTH),.N_INPUTS(N_INPUTS))
                                CAS_STAGE9
                                (.i1(stage_8_out[DATA_WIDTH*(4) -1 : DATA_WIDTH*(4-1)]),
                                .i2(stage_8_out[DATA_WIDTH*(5) -1 : DATA_WIDTH*(5-1)]),
                                .id1(stage_9_index[INDEX_WIDTH*(4) -1 : INDEX_WIDTH*(4-1)]),
                                .id2(stage_9_index[INDEX_WIDTH*(5) -1 : INDEX_WIDTH*(5-1)]),
                                .dir(direction),
                                .clk(clk),
                                .rst(rst),
                                .en(en),

                                .od1(stage_10_index[INDEX_WIDTH*(4) -1 : INDEX_WIDTH*(4-1)]),
                                .od2(stage_10_index[INDEX_WIDTH*(5) -1 : INDEX_WIDTH*(5-1)])
                                );
                                
                                //recovery cas
                             assign stage_9_out[DATA_WIDTH*(4) -1 : DATA_WIDTH*(4-1)]
                             =stat_buff_wire[stage_10_index[INDEX_WIDTH*(4) -1 : INDEX_WIDTH*(4-1)]];
                             assign stage_9_out[DATA_WIDTH*(5) -1 : DATA_WIDTH*(5-1)]
                             =stat_buff_wire[stage_10_index[INDEX_WIDTH*(5) -1 : INDEX_WIDTH*(5-1)]];
                             
                                
                        generate
                        for (i=1; i<=3; i=i+1) 
                        begin // direct connections

                            //recovery direct
                            assign stage_10_index[INDEX_WIDTH*(i) -1 : INDEX_WIDTH*(i-1)] =
                            stage_9_index[INDEX_WIDTH*(i) -1 : INDEX_WIDTH*(i-1)];
                            assign stage_10_index[INDEX_WIDTH*(i+5) -1 : INDEX_WIDTH*(i+5-1)] =
                            stage_9_index[INDEX_WIDTH*(i+5) -1 : INDEX_WIDTH*(i+5-1)];  
                            
           
                         end
                         endgenerate  
                         
                         generate 
                         for(i=1;i<=3;i=i+1) begin
                             assign stage_9_out[DATA_WIDTH*(i) -1 : DATA_WIDTH*(i-1)]
                             =stat_buff_wire[stage_10_index[INDEX_WIDTH*(i) -1 : INDEX_WIDTH*(i-1)]];
                             assign stage_9_out[DATA_WIDTH*(i+5) -1 : DATA_WIDTH*(i+5-1)]
                             =stat_buff_wire[stage_10_index[INDEX_WIDTH*(i+5) -1 : INDEX_WIDTH*(i+5-1)]];   
                         end
                         endgenerate
                        ////////////////////////////
 
                        
                        //data_out assignment 
                        assign data_out= stage_9_out;
                        
                                       
                        
endmodule
