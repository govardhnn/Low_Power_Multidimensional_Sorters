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
