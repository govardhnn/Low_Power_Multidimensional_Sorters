package bm8_testbench;

import bm8 :: *;

(*synthesize*)
module mk_bm8_testbench(Empty);

    Reg#(int) rg_in_1 <- mkReg(7);
    Reg#(int) rg_in_2 <- mkReg(6);
    Reg#(int) rg_in_3 <- mkReg(5);
    Reg#(int) rg_in_4 <- mkReg(4);
    Reg#(int) rg_in_5 <- mkReg(3);
    Reg#(int) rg_in_6 <- mkReg(2);
    Reg#(int) rg_in_7 <- mkReg(1);
    Reg#(int) rg_in_8 <- mkReg(0);

    Ifc_bm8 bm8 <- mk_bm8;

    rule rl_send_data;
        $display(" -- TB -- Sending data: %0d %0d %0d %0d %0d %0d %0d %0d", rg_in_1, rg_in_2, rg_in_3, rg_in_4, rg_in_5, rg_in_6, rg_in_7, rg_in_8);
        bm8.ma_get_inputs(rg_in_1, rg_in_2, rg_in_3, rg_in_4, rg_in_5, rg_in_6, rg_in_7, rg_in_8);
    endrule

    rule rl_get_result;
             
        let lv_out <- bm8.mav_return_outputs();

        $display(" -- TB - Got data: %0d %0d %0d %0d %0d %0d %0d %0d", tpl_1(lv_out), tpl_2(lv_out), tpl_3(lv_out), tpl_4(lv_out), tpl_5(lv_out), tpl_6(lv_out), tpl_7(lv_out), tpl_8(lv_out));
        $finish;
    endrule

endmodule

endpackage