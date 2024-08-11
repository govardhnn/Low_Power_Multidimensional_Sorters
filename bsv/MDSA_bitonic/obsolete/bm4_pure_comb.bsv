/*
MIT License Copyright (c) 2023 - 2024 Sai Govardhan

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
``Software''), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ``AS IS'', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
*/
// Obsolete: This package is no longer used. Kept here for reference purpouse sonly.

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