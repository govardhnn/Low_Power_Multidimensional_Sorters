`timescale 1ns / 1ps
//`include "MDSA_packet.sv"
class MDSA_gen;
  	int x=0;
    MDSA_packet pkt;
    mailbox gen2drv;
    
    function new(mailbox gen2drv);
        this.gen2drv=gen2drv;
    endfunction
    
  task main(input int n);
    repeat(n) 
            begin 
               pkt=new();
               pkt.randomize();
              pkt.display("Generator",x++);
               gen2drv.put(pkt);
               #1600; // time needed to sort if reset is 0 and enable is 1 
            end
    endtask
endclass
