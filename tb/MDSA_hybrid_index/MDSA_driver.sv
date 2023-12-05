`timescale 1ns / 1ps

class MDSA_driver;
  int x=0;
    virtual MDSA_interface vif;
    mailbox gen2drv;
    
    function new(virtual MDSA_interface vif, mailbox gen2drv);
        this.vif=vif;
        this.gen2drv=gen2drv;
    endfunction 
    
  task main(input int n);
    repeat(n) 
        begin 
            MDSA_packet pkt;
            
            gen2drv.get(pkt);
            
            vif.data_in<=pkt.data_in;
            //vif.rst<=pkt.rst;
            vif.en<=pkt.en;
            //vif.start<=pkt.start;
            
            pkt.data_out=vif.data_out;
            pkt.rdy=vif.rdy;
            pkt.output_enable=vif.output_enable;
            
          pkt.display("Driver",x++);
            #1600; // time needed to sort if reset is 0 and enable is 1
        end
    endtask
endclass
