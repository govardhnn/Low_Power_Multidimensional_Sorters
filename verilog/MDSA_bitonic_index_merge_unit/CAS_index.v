`timescale 10ns / 1ps

module CAS_index#(parameter DATA_WIDTH=32,N_INPUTS=8,INDEX_WIDTH= $clog2(N_INPUTS))(
    input wire [DATA_WIDTH-1:0] i1,
    input wire [DATA_WIDTH-1:0] i2,
    input wire [INDEX_WIDTH-1:0] id1,
    input wire [INDEX_WIDTH-1:0] id2,
    input wire dir,
    input wire clk,
    input wire rst,
    input wire en,
    output reg[INDEX_WIDTH-1:0] od1,
    output reg[INDEX_WIDTH-1:0] od2
    );
    reg[INDEX_WIDTH-1:0] o1_temp,o2_temp;
    always@*
      begin
      
     if(en) begin 
      if(dir)begin // dir =1 here is ascending
        if(i1>i2) begin 
          o2_temp=id1;
          o1_temp=id2;
        end
        else begin 
          o1_temp=id1;
          o2_temp=id2;
        end
      end
      
      else begin // dir =0 here is descending 
      if(i1>i2) begin 
          o2_temp=id2;
          o1_temp=id1;
      end
        else begin 
          o1_temp=id2;
          o2_temp=id1;
         end
      end
     end
      else begin 
	o1_temp=od1;
	o2_temp=od2;
      end
     end
     
     //Registered output easy to use for pipeline 
    always @(posedge clk or posedge rst)
      begin
	  if(rst) begin 
	  od1<='b0;
	  od2<='b0;
          end
	  else begin
          od1<=o1_temp;
          od2<=o2_temp;
	  end
      end

endmodule

