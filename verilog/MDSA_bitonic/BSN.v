
`timescale 1ns / 1ps
//`include "CAS_dual.v"

module BSN#(parameter DATA_WIDTH=32,N_INPUTS=8)(
						input wire [N_INPUTS*DATA_WIDTH-1:0]  data_in,
						input wire 			      clk,
						input wire 			      rst,
						input wire 			      en,
						input wire 			      direction,
						output wire [N_INPUTS*DATA_WIDTH-1:0] data_out);
   
   //Stage 1
   wire [N_INPUTS*DATA_WIDTH-1:0] 						      stage_1_out;
   genvar 									      i;
   generate 
      for(i=1;i<=4;i=i+1) begin 
         CAS_dual
	    #(.DATA_WIDTH(DATA_WIDTH)) 
	 CAS_stage_1 
	    (.i1(data_in[DATA_WIDTH*i + DATA_WIDTH*(i-1) -1 : DATA_WIDTH*i + DATA_WIDTH*(i-1) - DATA_WIDTH]),
	     .i2(data_in[DATA_WIDTH*i + DATA_WIDTH*(i-1) + DATA_WIDTH -1 : DATA_WIDTH*i + DATA_WIDTH*(i-1)]),
	     .dir(direction),
	     .clk(clk),
	     .rst(rst),
	     .en(en),
	     .o1(stage_1_out[DATA_WIDTH*i + DATA_WIDTH*(i-1) -1 : DATA_WIDTH*i + DATA_WIDTH*(i-1) - DATA_WIDTH]),
	     .o2(stage_1_out[DATA_WIDTH*i + DATA_WIDTH*(i-1) -1 + DATA_WIDTH : DATA_WIDTH*i + DATA_WIDTH*(i-1)]));
      end
   endgenerate
   
   //Stage 2
   wire [N_INPUTS*DATA_WIDTH -1:0] stage_2_out;
   genvar 			   j;
   generate 
      for(j=1;j<=2;j=j+1) begin 
         CAS_dual
	    #(.DATA_WIDTH(DATA_WIDTH)) 
	 CAS_stage_2_1 
	    (.i1(stage_1_out[DATA_WIDTH -1 + (j-1)*DATA_WIDTH*4 : (j-1)*DATA_WIDTH*4]),
	     .i2( stage_1_out[ j*DATA_WIDTH*4 -1 : j*DATA_WIDTH*4 - DATA_WIDTH ]),
	     .dir(direction),
	     .clk(clk),
	     .rst(rst),
	     .en(en),
	     .o1(stage_2_out[DATA_WIDTH -1 + (j-1)*DATA_WIDTH*4 : (j-1)*DATA_WIDTH*4]),
	     .o2( stage_2_out[ j*DATA_WIDTH*4 -1 : j*DATA_WIDTH*4 - DATA_WIDTH ]));
      end
   endgenerate 
   
   genvar k;
   generate 
      for(k=1;k<=2;k=k+1) begin 
         CAS_dual
	    #(.DATA_WIDTH(DATA_WIDTH)) 
	 CAS_stage_2_2
	    (.i1(stage_1_out[2*DATA_WIDTH -1 +(k-1)*DATA_WIDTH*4: DATA_WIDTH +(k-1)*DATA_WIDTH*4]),
	     .i2(stage_1_out[3*DATA_WIDTH -1 + (k-1)*DATA_WIDTH*4: 2*DATA_WIDTH +(k-1)*DATA_WIDTH*4]),
	     .dir(direction),
	     .clk(clk),
	     .rst(rst),
	     .en(en),
	     .o1(stage_2_out[2*DATA_WIDTH -1 +(k-1)*DATA_WIDTH*4: DATA_WIDTH +(k-1)*DATA_WIDTH*4]),
	     .o2(stage_2_out[3*DATA_WIDTH -1 + (k-1)*DATA_WIDTH*4: 2*DATA_WIDTH +(k-1)*DATA_WIDTH*4]));
      end
   endgenerate
   
   //Stage 3
   wire [N_INPUTS*DATA_WIDTH -1:0] stage_3_out;
   genvar 			   l;
   generate 
      for(l=1;l<=4;l=l+1) begin 
         CAS_dual
	    #(.DATA_WIDTH(DATA_WIDTH)) 
	 CAS_stage_3 
	    (.i1(stage_2_out[DATA_WIDTH*l + DATA_WIDTH*(l-1) -1 : DATA_WIDTH*l + DATA_WIDTH*(l-1) - DATA_WIDTH]),
	     .i2(stage_2_out[DATA_WIDTH*l + DATA_WIDTH*(l-1) -1 + DATA_WIDTH : DATA_WIDTH*l + DATA_WIDTH*(l-1)]),
	     .dir(direction),
	     .clk(clk),
	     .rst(rst),
	     .en(en),
	     .o1(stage_3_out[DATA_WIDTH*l + DATA_WIDTH*(l-1) -1 : DATA_WIDTH*l + DATA_WIDTH*(l-1) - DATA_WIDTH]),
	     .o2(stage_3_out[DATA_WIDTH*l + DATA_WIDTH*(l-1) -1 + DATA_WIDTH : DATA_WIDTH*l + DATA_WIDTH*(l-1)]));
      end
   endgenerate
   
   //Stage 4
   wire [N_INPUTS*DATA_WIDTH -1:0] stage_4_out;
   genvar 			   m;
   generate 
      for(m=1;m<=4;m=m+1) begin 
         CAS_dual
	    #(.DATA_WIDTH(DATA_WIDTH)) 
	 CAS_stage_4
	    (.i1(stage_3_out[DATA_WIDTH*m -1:DATA_WIDTH*(m-1)]),
	     .i2(stage_3_out[DATA_WIDTH*(N_INPUTS+1-m)-1:DATA_WIDTH*(N_INPUTS-m)]),
	     .dir(direction),
	     .clk(clk),
	     .rst(rst),
	     .en(en),
	     .o1(stage_4_out[DATA_WIDTH*m -1:DATA_WIDTH*(m-1)]),
	     .o2(stage_4_out[DATA_WIDTH*(N_INPUTS+1-m)-1:DATA_WIDTH*(N_INPUTS-m)]));
      end
   endgenerate
   
   //Stage 5 
   wire [N_INPUTS*DATA_WIDTH -1:0] stage_5_out;
   genvar 			   n;
   generate
      for(n=1;n<=2;n=n+1) begin 
         CAS_dual
	    #(.DATA_WIDTH(DATA_WIDTH)) 
	 CAS_stage_5
	    (.i1(stage_4_out[n*DATA_WIDTH -1 : DATA_WIDTH*(n-1)]),
	     .i2(stage_4_out[ (n+2)*DATA_WIDTH -1 : DATA_WIDTH*(n+1)]),
	     .dir(direction),
	     .clk(clk),
	     .rst(rst),
	     .en(en),
	     .o1(stage_5_out[n*DATA_WIDTH -1 : DATA_WIDTH*(n-1)]),
	     .o2(stage_5_out[(n+2)*DATA_WIDTH -1 : DATA_WIDTH*(n+1)]));
      end
   endgenerate
   
   genvar o;
   generate
      for(o=1;o<=2;o=o+1) begin 
         CAS_dual
	    #(.DATA_WIDTH(DATA_WIDTH)) 
	 CAS_stage_5
	    (.i1(stage_4_out[(DATA_WIDTH*4) + o*DATA_WIDTH -1 : (DATA_WIDTH*4) + DATA_WIDTH*(o-1)]),
	     .i2(stage_4_out[(DATA_WIDTH*4) + (o+2)*DATA_WIDTH -1 : (DATA_WIDTH*4) + DATA_WIDTH*(o+1)]),
	     .dir(direction),
	     .clk(clk),
	     .rst(rst),
	     .en(en),
	     .o1(stage_5_out[(DATA_WIDTH*4) + o*DATA_WIDTH -1 : (DATA_WIDTH*4) + DATA_WIDTH*(o-1)]),
	     .o2(stage_5_out[(DATA_WIDTH*4) + (o+2)*DATA_WIDTH -1 : (DATA_WIDTH*4) + DATA_WIDTH*(o+1)]));
      end
   endgenerate
   
   //Stage 6
   wire [N_INPUTS*DATA_WIDTH -1:0] stage_6_out;
   genvar 			   p;
   generate 
      for(p=1;p<=4;p=p+1) begin 
         CAS_dual
	    #(.DATA_WIDTH(DATA_WIDTH)) 
	 CAS_stage_6 
	    (.i1(stage_5_out[DATA_WIDTH*p + DATA_WIDTH*(p-1) -1 : DATA_WIDTH*p + DATA_WIDTH*(p-1) - DATA_WIDTH]),
	     .i2(stage_5_out[DATA_WIDTH*p + DATA_WIDTH*(p-1) -1 + DATA_WIDTH : DATA_WIDTH*p + DATA_WIDTH*(p-1)]),
	     .dir(direction),
	     .clk(clk),
	     .rst(rst),
	     .en(en),
	     .o1(stage_6_out[DATA_WIDTH*p + DATA_WIDTH*(p-1) -1 : DATA_WIDTH*p + DATA_WIDTH*(p-1) - DATA_WIDTH]),
	     .o2(stage_6_out[DATA_WIDTH*p + DATA_WIDTH*(p-1) -1 + DATA_WIDTH : DATA_WIDTH*p + DATA_WIDTH*(p-1)]));
      end
   endgenerate 
   
   assign data_out = stage_6_out;
endmodule

   
