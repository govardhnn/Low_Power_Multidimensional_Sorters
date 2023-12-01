package bm4_testbench;

import bm4 :: *;

(*synthesize*)
module mk_bm4_testbench(Empty);

    Reg#(int) rg_in_1 <- mkReg(4);
    Reg#(int) rg_in_2 <- mkReg(3);
    Reg#(int) rg_in_3 <- mkReg(2);
    Reg#(int) rg_in_4 <- mkReg(1);

    Ifc_bm4 bm4 <- mk_bm4;

    rule rl_send_data;
        $display(" -- TB -- Sending data: %0d %0d %0d %0d", rg_in_1, rg_in_2, rg_in_3, rg_in_4);
        bm4.ma_get_inputs(rg_in_1, rg_in_2, rg_in_3, rg_in_4);
    endrule

    rule rl_get_result;
        let lv_out <- bm4.mav_return_output();
        $display(" -- TB -- Output is %0d %0d %0d %0d", tpl_1(lv_out), tpl_2(lv_out), tpl_3(lv_out), tpl_4(lv_out));
        $finish;
    endrule

endmodule

endpackage