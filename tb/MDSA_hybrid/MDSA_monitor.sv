`timescale 1ns / 1ps

class MDSA_monitor;
  int x=0;
    virtual MDSA_interface vif;
    mailbox mon2scb;
    
    function new(virtual MDSA_interface vif,mailbox mon2scb);
        this.vif=vif;
        this.mon2scb=mon2scb;
    endfunction 
    
  task main(input int n);
    repeat(n)
    		begin 
            MDSA_packet pkt;
          	#1600; // time needed to sort if reset is 0 and enable is 1
            pkt=new();
            pkt.data_in=vif.data_in;
           // pkt.rst=vif.rst;
            pkt.en=vif.en;
            //pkt.start=vif.start;
            pkt.data_out=vif.data_out;
            pkt.rdy=vif.rdy;
            pkt.output_enable=vif.output_enable;
            mon2scb.put(pkt);
              pkt.display("Monitor",x++);
//            #490; // time needed to sort if reset is 0 and enable is 1
        end
    endtask
endclass
