package bm4_testbench;

`define COUNTER_LIM 2

import bm4 :: *;

(*synthesize*)
module mk_bm4_testbench(Empty);

    Reg#(int) rg_in_1 <- mkReg(4);
    Reg#(int) rg_in_2 <- mkReg(3);
    Reg#(int) rg_in_3 <- mkReg(2);
    Reg#(int) rg_in_4 <- mkReg(1);

    Reg#(Bool) rg_sent_data <- mkReg(False);

    Ifc_bm4 bm4 <- mk_bm4; 

    Reg#(int) rg_counter <- mkReg(0);

    rule rl_send_data(rg_counter < `COUNTER_LIM && !rg_sent_data);
        $display(" -- TB -- Sending data: %0d %0d %0d %0d", rg_in_1, rg_in_2, rg_in_3, rg_in_4);
        bm4.ma_get_inputs(rg_in_1, rg_in_2, rg_in_3, rg_in_4);
        rg_counter <= rg_counter + 1;
        rg_sent_data <= True;
        if (rg_counter == `COUNTER_LIM - 1) $finish;
    endrule

    rule rl_get_result(rg_counter < `COUNTER_LIM && rg_sent_data);
        let lv_out <- bm4.mav_return_output();
        $display(" -- TB -- Output is %0d %0d %0d %0d", tpl_1(lv_out), tpl_2(lv_out), tpl_3(lv_out), tpl_4(lv_out));
        rg_sent_data <= False;
        if (rg_counter == `COUNTER_LIM - 1) $finish;
    endrule

endmodule

endpackage