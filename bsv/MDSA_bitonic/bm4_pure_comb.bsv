package bm4;

import cae :: *;

interface Ifc_bm4;
    method Action ma_get_inputs (int in1, int in2, int in3, int in4);
    method ActionValue#(Tuple4#(int, int, int, int)) mav_return_output (); 
endinterface

module mk_bm4(Ifc_bm4);

    Ifc_cae cae1 <- mk_cae();
    Ifc_cae cae2 <- mk_cae();
    Ifc_cae cae3 <- mk_cae();
    Ifc_cae cae4 <- mk_cae();
    Ifc_cae cae5 <- mk_cae();
    Ifc_cae cae6 <- mk_cae();

    Reg#(Bool) rg_sorted <- mkReg(False);

    Reg#(int) rg_out1 <- mkReg(0);
    Reg#(int) rg_out2 <- mkReg(0);
    Reg#(int) rg_out3 <- mkReg(0);
    Reg#(int) rg_out4 <- mkReg(0);

    method Action ma_get_inputs (int in1, int in2, int in3, int in4) if (!rg_sorted);
        let lv_get_sort_1 = cae1.mv_get_sort(in1, in2);
        let lv_get_sort_2 = cae2.mv_get_sort(in3, in4);    
        let lv_get_sort_3 = cae3.mv_get_sort(tpl_1(lv_get_sort_1), tpl_2(lv_get_sort_2));
        let lv_get_sort_4 = cae4.mv_get_sort(tpl_2(lv_get_sort_1), tpl_1(lv_get_sort_2));          
        let lv_get_sort_5 = cae5.mv_get_sort(tpl_1(lv_get_sort_3), tpl_1(lv_get_sort_4));
        let lv_get_sort_6 = cae6.mv_get_sort(tpl_2(lv_get_sort_4), tpl_2(lv_get_sort_3));
        rg_out1 <= tpl_1(lv_get_sort_5);
        rg_out2 <= tpl_2(lv_get_sort_5);
        rg_out3 <= tpl_1(lv_get_sort_6);
        rg_out4 <= tpl_2(lv_get_sort_6);
        rg_sorted <= True;
    endmethod

    method ActionValue#(Tuple4#(int, int, int, int)) mav_return_output () if (rg_sorted); 
        rg_sorted <= False;
        return (tuple4(rg_out1, rg_out2, rg_out3, rg_out4));
    endmethod

endmodule
endpackage