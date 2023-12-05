`timescale 1ns / 1ps
//`include "MDSA_reference_model.sv"
class MDSA_scoreboard;
  int x=0;
  int o=1;
    mailbox mon2scb;
    
    function new(mailbox mon2scb);
        this.mon2scb=mon2scb;
    endfunction 
    
//     function int reset_test(input logic rst,input logic [2047:0]data_out);
//         if(rst) begin
//             if(data_out=='b0) begin 
//                     reset_test=1'b1;
//                 end
//             end
//     endfunction    
    
  task main(input int n);
    repeat(n) 
    	begin
    	MDSA_packet pkt;
      	#1600; // time needed to sort if reset is 0 and enable is 1             
                mon2scb.get(pkt);
//                 if(reset_test(pkt.rst,pkt.data_out)) begin 
//                     $display("reset tested succesfully");
//                 end
//                 else 
//                     $display("failed");
//           pkt.display("Scoreboard",x++);
//                #490; // time needed to sort if reset is 0 and enable is 1
            end
    endtask
endclass
