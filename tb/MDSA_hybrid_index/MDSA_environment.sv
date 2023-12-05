/*
MIT License

Copyright (c) 2023 Samahith S A and Sai Govardhan

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
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
