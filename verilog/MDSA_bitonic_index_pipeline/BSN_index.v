`timescale 10ns / 1ps

module BSN_index#(parameter DATA_WIDTH=32,N_INPUTS=8,INDEX_WIDTH=$clog2(N_INPUTS))(
                        input wire [N_INPUTS*DATA_WIDTH-1:0] data_in,
                        input wire clk,
                        input wire rst,
                        input wire trans, // new addition to sample static_buffer
                        input wire en,
                        input wire dir,
                        output wire [N_INPUTS*DATA_WIDTH-1:0]data_out
                        //output wire [N_INPUTS*INDEX_WIDTH-1:0] test_out_index
                        );
                        
                        wire direction;
                        assign direction = dir;//switch between ascending and desecending for overall MDSA
                        
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
                        
                        //Stage 1
                        wire [N_INPUTS*INDEX_WIDTH-1:0] stage_1_index={3'd7,3'd6,3'd5,3'd4,3'd3,3'd2,3'd1,3'd0};
                        wire [N_INPUTS*INDEX_WIDTH-1:0] stage_2_index;
                        genvar a;
                        generate 
                            for(a=1;a<=4;a=a+1) begin 
                                CAS_index#(.DATA_WIDTH(DATA_WIDTH),.N_INPUTS(N_INPUTS)) CAS_stage_1 (.i1(data_in[DATA_WIDTH*a + DATA_WIDTH*(a-1) -1 : DATA_WIDTH*a + DATA_WIDTH*(a-1) - DATA_WIDTH]),.i2(data_in[DATA_WIDTH*a + DATA_WIDTH*(a-1) + DATA_WIDTH -1 : DATA_WIDTH*a + DATA_WIDTH*(a-1)]),.id1(stage_1_index[INDEX_WIDTH*a + INDEX_WIDTH*(a-1) -1 : INDEX_WIDTH*a + INDEX_WIDTH*(a-1) - INDEX_WIDTH]),.id2(stage_1_index[INDEX_WIDTH*a + INDEX_WIDTH*(a-1) + INDEX_WIDTH -1 : INDEX_WIDTH*a + INDEX_WIDTH*(a-1)]),.dir(direction),.clk(clk),.rst(rst),.en(en),.od1(stage_2_index[INDEX_WIDTH*a + INDEX_WIDTH*(a-1) -1 : INDEX_WIDTH*a + INDEX_WIDTH*(a-1) - INDEX_WIDTH]),.od2(stage_2_index[INDEX_WIDTH*a + INDEX_WIDTH*(a-1) + INDEX_WIDTH -1 : INDEX_WIDTH*a + INDEX_WIDTH*(a-1)]));
                            end                            
                        endgenerate
                        
                        //Recovery unit
                        wire [N_INPUTS*DATA_WIDTH-1:0] stage_2_in;
                        genvar y;
                        generate 
                        for(y=1;y<=8;y=y+1) begin
                            assign stage_2_in[DATA_WIDTH*y -1 : DATA_WIDTH*(y-1)]=stat_buff_wire[stage_2_index[INDEX_WIDTH*y -1 : INDEX_WIDTH*(y-1)]];
                            end
                        endgenerate 
                        
                        //Stage 2
                        wire [N_INPUTS*INDEX_WIDTH-1:0] stage_3_index;
                        genvar b;
                        generate 
                            for(b=1;b<=2;b=b+1) begin 
                                CAS_index#(.DATA_WIDTH(DATA_WIDTH),.N_INPUTS(N_INPUTS)) CAS_stage_2_1 (.i1(stage_2_in[DATA_WIDTH -1 + (b-1)*DATA_WIDTH*4 : (b-1)*DATA_WIDTH*4]),.i2( stage_2_in[ b*DATA_WIDTH*4 -1 : b*DATA_WIDTH*4 - DATA_WIDTH ]),.id1(stage_2_index[INDEX_WIDTH -1 + (b-1)*INDEX_WIDTH*4 : (b-1)*INDEX_WIDTH*4]),.id2(stage_2_index[b*INDEX_WIDTH*4 -1 : b*INDEX_WIDTH*4 - INDEX_WIDTH]),.dir(direction),.clk(clk),.rst(rst),.en(en),.od1(stage_3_index[INDEX_WIDTH -1 + (b-1)*INDEX_WIDTH*4 : (b-1)*INDEX_WIDTH*4]),.od2(stage_3_index[ b*INDEX_WIDTH*4 -1 : b*INDEX_WIDTH*4 - INDEX_WIDTH]));
                            end
                        endgenerate
                        
                         genvar c;
                         generate 
                            for(c=1;c<=2;c=c+1) begin 
                                CAS_index#(.DATA_WIDTH(DATA_WIDTH),.N_INPUTS(N_INPUTS)) CAS_stage_2_2(.i1(stage_2_in[2*DATA_WIDTH -1 +(c-1)*DATA_WIDTH*4: DATA_WIDTH +(c-1)*DATA_WIDTH*4]),.i2(stage_2_in[3*DATA_WIDTH -1 + (c-1)*DATA_WIDTH*4: 2*DATA_WIDTH +(c-1)*DATA_WIDTH*4]),.dir(direction),.id1(stage_2_index[2*INDEX_WIDTH -1 +(c-1)*INDEX_WIDTH*4: INDEX_WIDTH +(c-1)*INDEX_WIDTH*4]),.id2(stage_2_index[3*INDEX_WIDTH -1 + (c-1)*INDEX_WIDTH*4: 2*INDEX_WIDTH +(c-1)*INDEX_WIDTH*4]),.clk(clk),.rst(rst),.en(en),.od1(stage_3_index[2*INDEX_WIDTH -1 +(c-1)*INDEX_WIDTH*4: INDEX_WIDTH +(c-1)*INDEX_WIDTH*4]),.od2(stage_3_index[3*INDEX_WIDTH -1 + (c-1)*INDEX_WIDTH*4: 2*INDEX_WIDTH +(c-1)*INDEX_WIDTH*4]));
                            end
                         endgenerate
                         

                         //Recovery unit
                         wire [N_INPUTS*DATA_WIDTH-1:0] stage_3_in;
                           genvar x;
                           generate 
                                for(x=1;x<=8;x=x+1) begin
                                    assign stage_3_in[DATA_WIDTH*x -1 : DATA_WIDTH*(x-1)]=stat_buff_wire[stage_3_index[INDEX_WIDTH*x -1 : INDEX_WIDTH*(x-1)]];
                                end
                           endgenerate         
 
                        //Stage 3                          
                        wire [N_INPUTS*INDEX_WIDTH-1:0]stage_4_index;
                        genvar d;
                        generate 
                            for(d=1;d<=4;d=d+1) begin 
                                CAS_index#(.DATA_WIDTH(DATA_WIDTH),.N_INPUTS(N_INPUTS)) CAS_stage_3 (.i1(stage_3_in[DATA_WIDTH*d + DATA_WIDTH*(d-1) -1 : DATA_WIDTH*d + DATA_WIDTH*(d-1) - DATA_WIDTH]),.i2(stage_3_in[DATA_WIDTH*d + DATA_WIDTH*(d-1) + DATA_WIDTH -1 : DATA_WIDTH*d + DATA_WIDTH*(d-1)]),.id1(stage_3_index[INDEX_WIDTH*d + INDEX_WIDTH*(d-1) -1 : INDEX_WIDTH*d + INDEX_WIDTH*(d-1) - INDEX_WIDTH]),.id2(stage_3_index[INDEX_WIDTH*d + INDEX_WIDTH*(d-1) + INDEX_WIDTH -1 : INDEX_WIDTH*d + INDEX_WIDTH*(d-1)]),.dir(direction),.clk(clk),.rst(rst),.en(en),.od1(stage_4_index[INDEX_WIDTH*d + INDEX_WIDTH*(d-1) -1 : INDEX_WIDTH*d + INDEX_WIDTH*(d-1) - INDEX_WIDTH]),.od2(stage_4_index[INDEX_WIDTH*d + INDEX_WIDTH*(d-1) + INDEX_WIDTH -1 : INDEX_WIDTH*d + INDEX_WIDTH*(d-1)]));
                            end                            
                        endgenerate                           
                        
                        //Recovery unit               
                        wire [N_INPUTS*DATA_WIDTH-1:0]stage_4_in;
                        genvar w;
                        generate 
                             for(w=1;w<=8;w=w+1) begin
                                 assign stage_4_in[DATA_WIDTH*w -1 : DATA_WIDTH*(w-1)]=stat_buff_wire[stage_4_index[INDEX_WIDTH*w -1 : INDEX_WIDTH*(w-1)]];
                             end
                        endgenerate
                        
                        //Stage 4
                        wire [N_INPUTS*INDEX_WIDTH-1:0] stage_5_index;
                         genvar e;
                        generate 
                            for(e=1;e<=4;e=e+1) begin 
                                 CAS_index#(.DATA_WIDTH(DATA_WIDTH),.N_INPUTS(N_INPUTS)) CAS_stage_4(.i1(stage_4_in[DATA_WIDTH*e -1:DATA_WIDTH*(e-1)]),.i2(stage_4_in[DATA_WIDTH*(N_INPUTS+1-e)-1:DATA_WIDTH*(N_INPUTS-e)]),.id1(stage_4_index[INDEX_WIDTH*e -1:INDEX_WIDTH*(e-1)]),.id2(stage_4_index[INDEX_WIDTH*(N_INPUTS+1-e)-1:INDEX_WIDTH*(N_INPUTS-e)]),.dir(direction),.clk(clk),.rst(rst),.en(en),.od1(stage_5_index[INDEX_WIDTH*e -1:INDEX_WIDTH*(e-1)]),.od2(stage_5_index[INDEX_WIDTH*(N_INPUTS+1-e)-1:INDEX_WIDTH*(N_INPUTS-e)]));
                            end
                        endgenerate                  

                        //Recovery unit
                        wire [N_INPUTS*DATA_WIDTH-1:0]stage_5_in;
                        genvar v;
                        generate 
                             for(v=1;v<=8;v=v+1) begin
                                 assign stage_5_in[DATA_WIDTH*v -1 : DATA_WIDTH*(v-1)]=stat_buff_wire[stage_5_index[INDEX_WIDTH*v -1 : INDEX_WIDTH*(v-1)]];
                             end
                        endgenerate                        
                        
                        //Stage 5 
                        wire [N_INPUTS*INDEX_WIDTH -1:0] stage_6_index;
                        genvar f;
                        generate
                            for(f=1;f<=2;f=f+1) begin 
                                CAS_index#(.DATA_WIDTH(DATA_WIDTH),.N_INPUTS(N_INPUTS)) CAS_stage_5_1(.i1(stage_5_in[f*DATA_WIDTH -1 : DATA_WIDTH*(f-1)]),.i2(stage_5_in[ (f+2)*DATA_WIDTH -1 : DATA_WIDTH*(f+1)]),.id1(stage_5_index[f*INDEX_WIDTH -1 : INDEX_WIDTH*(f-1)]),.id2(stage_5_index[ (f+2)*INDEX_WIDTH -1 : INDEX_WIDTH*(f+1)]),.dir(direction),.clk(clk),.rst(rst),.en(en),.od1(stage_6_index[f*INDEX_WIDTH -1 : INDEX_WIDTH*(f-1)]),.od2(stage_6_index[(f+2)*INDEX_WIDTH -1 : INDEX_WIDTH*(f+1)]));
                            end
                        endgenerate
                        
                        genvar g;
                        generate
                            for(g=1;g<=2;g=g+1) begin 
                                CAS_index#(.DATA_WIDTH(DATA_WIDTH),.N_INPUTS(N_INPUTS)) CAS_stage_5_2(.i1(stage_5_in[(DATA_WIDTH*4) + g*DATA_WIDTH -1 : (DATA_WIDTH*4) + DATA_WIDTH*(g-1)]),.i2(stage_5_in[(DATA_WIDTH*4) + (g+2)*DATA_WIDTH -1 : (DATA_WIDTH*4) + DATA_WIDTH*(g+1)]),.id1(stage_5_index[(INDEX_WIDTH*4) + g*INDEX_WIDTH -1 : (INDEX_WIDTH*4) + INDEX_WIDTH*(g-1)]),.id2(stage_5_index[(INDEX_WIDTH*4) + (g+2)*INDEX_WIDTH -1 : (INDEX_WIDTH*4) + INDEX_WIDTH*(g+1)]),.dir(direction),.clk(clk),.rst(rst),.en(en),.od1(stage_6_index[(INDEX_WIDTH*4) + g*INDEX_WIDTH -1 : (INDEX_WIDTH*4) + INDEX_WIDTH*(g-1)]),.od2(stage_6_index[(INDEX_WIDTH*4) + (g+2)*INDEX_WIDTH -1 : (INDEX_WIDTH*4) + INDEX_WIDTH*(g+1)]));
                            end
                        endgenerate

                        //Recovery unit
                        wire [N_INPUTS*DATA_WIDTH-1:0]stage_6_in;
                        genvar u;
                        generate 
                             for(u=1;u<=8;u=u+1) begin
                                 assign stage_6_in[DATA_WIDTH*u -1 : DATA_WIDTH*(u-1)]=stat_buff_wire[stage_6_index[INDEX_WIDTH*u -1 : INDEX_WIDTH*(u-1)]];
                             end
                        endgenerate                        
                        
                        //Stage 6
                        wire [N_INPUTS*INDEX_WIDTH-1:0]out_index;
                        genvar h;
                        generate 
                            for(h=1;h<=4;h=h+1) begin 
                                CAS_index#(.DATA_WIDTH(DATA_WIDTH),.N_INPUTS(N_INPUTS)) CAS_stage_6 (.i1(stage_6_in[DATA_WIDTH*h + DATA_WIDTH*(h-1) -1 : DATA_WIDTH*h + DATA_WIDTH*(h-1) - DATA_WIDTH]),.i2(stage_6_in[DATA_WIDTH*h + DATA_WIDTH*(h-1) + DATA_WIDTH -1 : DATA_WIDTH*h + DATA_WIDTH*(h-1)]),.id1(stage_6_index[INDEX_WIDTH*h + INDEX_WIDTH*(h-1) -1 : INDEX_WIDTH*h + INDEX_WIDTH*(h-1) - INDEX_WIDTH]),.id2(stage_6_index[INDEX_WIDTH*h + INDEX_WIDTH*(h-1) + INDEX_WIDTH -1 : INDEX_WIDTH*h + INDEX_WIDTH*(h-1)]),.dir(direction),.clk(clk),.rst(rst),.en(en),.od1(out_index[INDEX_WIDTH*h + INDEX_WIDTH*(h-1) -1 : INDEX_WIDTH*h + INDEX_WIDTH*(h-1) - INDEX_WIDTH]),.od2(out_index[INDEX_WIDTH*h + INDEX_WIDTH*(h-1) + INDEX_WIDTH -1 : INDEX_WIDTH*h + INDEX_WIDTH*(h-1)]));
                            end                            
                        endgenerate 
                                                  
                        //Recovery unit
                        wire [N_INPUTS*DATA_WIDTH-1:0]out_data;
                        genvar t;
                        generate 
                             for(t=1;t<=8;t=t+1) begin
                                 assign out_data[DATA_WIDTH*t -1 : DATA_WIDTH*(t-1)]=stat_buff_wire[out_index[INDEX_WIDTH*t -1 : INDEX_WIDTH*(t-1)]];
                             end
                        endgenerate                        
                        
                        assign data_out=out_data;
                        
endmodule
