`timescale 1ns / 1ps
`include "MDSA_packet.sv"
`include "MDSA_gen.sv"
`include "MDSA_driver.sv"
`include "MDSA_monitor.sv"
`include "MDSA_scoreboard.sv"
//`include "MDSA_reference_model.sv"

class MDSA_environment;
  	int iter=100; //make it 100
    MDSA_gen gen;
    MDSA_driver drv;
    MDSA_monitor mon;
    MDSA_scoreboard scb;
    mailbox m1;
    mailbox m2;
    
    virtual MDSA_interface vif;
    function new(virtual MDSA_interface vif);
        this.vif=vif;
        m1=new();
        m2=new();
        gen=new(m1);
        drv=new(vif,m1);
        mon=new(vif,m2);
        scb=new(m2);
    endfunction
    
    task test();
        fork 
          gen.main(iter);
          drv.main(iter);
          mon.main(iter);
          scb.main(iter);
        join
    endtask
    
    task run();
        test();
        $finish;
    endtask
    
endclass
