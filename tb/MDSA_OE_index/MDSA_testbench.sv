`timescale 1ns / 1ps
`include "MDSA_environment.sv"
program automatic MDSA_testbench(MDSA_interface itf);
    MDSA_environment env;
    initial begin 
     env=new(itf);
     env.run();
    end
endprogram
