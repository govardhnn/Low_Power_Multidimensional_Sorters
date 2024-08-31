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

package bm8;

import bm4 :: *;
import cae :: *;
import Vector :: *;
import mdsa_types :: *;

typedef struct {Vector#(8, Reg#(int)) v_rg;} PIPE;

interface Ifc_bm8;
    method Action ma_get_inputs (BM8 bm8_in);
    method ActionValue#(BM8) mav_return_outputs;
endinterface

(*synthesize*)
module mk_bm8(Ifc_bm8);

Reg#(RG_STAGE) rg_stage <- mkReg(INIT);

    // BM4 Stage contains the first three stages of the six stages of Bitonic Sort

    // Ifc_bm4 bm4[2];
    // for (Integer lp_i = 0; lp_i < 2; lp_i = lp_i + 1) begin
    //     bm4[lp_i] <- mk_bm4();
    // end

    Vector#(4, Ifc_cae) cae_stage_1 <- replicateM(mk_cae());

    Vector#(2, Ifc_bm4) bm4_stage_2_3 <- replicateM(mk_bm4());

    Vector#(4, Ifc_cae) cae_stage_4 <- replicateM(mk_cae());

    Vector#(4, Ifc_cae) cae_stage_5 <- replicateM(mk_cae());

    Vector#(4, Ifc_cae) cae_stage_6 <- replicateM(mk_cae());

    Vector#(6, Reg#(PIPE)) pipe <- replicateM(mkReg(replicate(0)));


rule rl_get_outputs_from_bm4 if (rg_stage == BM4_INPUT);

    let lv_get_bm4_sort_1 <- bm4[0].mav_return_output();
    let lv_get_bm4_sort_2 <- bm4[1].mav_return_output();

    pipe[0].v_rg[0] <= tpl_1(lv_get_bm4_sort_1);
    pipe[0].v_rg[1] <= tpl_2(lv_get_bm4_sort_1);
    pipe[0].v_rg[2] <= tpl_3(lv_get_bm4_sort_1);
    pipe[0].v_rg[3] <= tpl_4(lv_get_bm4_sort_1);

    pipe[0].v_rg[4] <= tpl_1(lv_get_bm4_sort_2);
    pipe[0].v_rg[5] <= tpl_2(lv_get_bm4_sort_2);
    pipe[0].v_rg[6] <= tpl_3(lv_get_bm4_sort_2);
    pipe[0].v_rg[7] <= tpl_4(lv_get_bm4_sort_2);

    rg_stage <= BM4_DONE;
 endrule

 rule rl_bm8_stage_4 if (rg_stage == BM4_DONE);
    $display("BM8 Stage 4 got inputs: %0d %0d %0d %0d %0d %0d %0d %0d", pipe[0].v_rg[0], pipe[0].v_rg[1], pipe[0].v_rg[2], pipe[0].v_rg[3], pipe[0].v_rg[4], pipe[0].v_rg[5], pipe[0].v_rg[6], pipe[0].v_rg[7]);

    pipe[1].v_rg[0] <= tpl_1(cae_stage_4[0].mv_get_sort(pipe[0].v_rg[0], pipe[0].v_rg[7]));
    pipe[1].v_rg[7] <= tpl_2(cae_stage_4[0].mv_get_sort(pipe[0].v_rg[0], pipe[0].v_rg[7]));

    pipe[1].v_rg[1] <= tpl_1(cae_stage_4[1].mv_get_sort(pipe[0].v_rg[1], pipe[0].v_rg[6]));
    pipe[1].v_rg[6] <= tpl_2(cae_stage_4[1].mv_get_sort(pipe[0].v_rg[1], pipe[0].v_rg[6]));

    pipe[1].v_rg[2] <= tpl_1(cae_stage_4[2].mv_get_sort(pipe[0].v_rg[2], pipe[0].v_rg[5]));
    pipe[1].v_rg[5] <= tpl_2(cae_stage_4[2].mv_get_sort(pipe[0].v_rg[2], pipe[0].v_rg[5]));

    pipe[1].v_rg[3] <= tpl_1(cae_stage_4[3].mv_get_sort(pipe[0].v_rg[3], pipe[0].v_rg[4]));
    pipe[1].v_rg[4] <= tpl_2(cae_stage_4[3].mv_get_sort(pipe[0].v_rg[3], pipe[0].v_rg[4]));

    rg_stage <= BM8_STAGE_4_DONE;
 endrule

 rule rl_bm8_stage_5 if (rg_stage == BM8_STAGE_4_DONE);
    
    $display("BM8 Stage 5 got inputs: %0d %0d %0d %0d %0d %0d %0d %0d", pipe[1].v_rg[0], pipe[1].v_rg[1], pipe[1].v_rg[2], pipe[1].v_rg[3], pipe[1].v_rg[4], pipe[1].v_rg[5], pipe[1].v_rg[6], pipe[1].v_rg[7]);

    pipe[2].v_rg[0] <= tpl_1(cae_stage_5[0].mv_get_sort(pipe[1].v_rg[0], pipe[1].v_rg[2]));
    pipe[2].v_rg[2] <= tpl_2(cae_stage_5[0].mv_get_sort(pipe[1].v_rg[0], pipe[1].v_rg[2]));

    pipe[2].v_rg[1] <= tpl_1(cae_stage_5[1].mv_get_sort(pipe[1].v_rg[1], pipe[1].v_rg[3]));
    pipe[2].v_rg[3] <= tpl_2(cae_stage_5[1].mv_get_sort(pipe[1].v_rg[1], pipe[1].v_rg[3]));

    pipe[2].v_rg[4] <= tpl_1(cae_stage_5[2].mv_get_sort(pipe[1].v_rg[4], pipe[1].v_rg[6]));
    pipe[2].v_rg[6] <= tpl_2(cae_stage_5[2].mv_get_sort(pipe[1].v_rg[4], pipe[1].v_rg[6]));

    pipe[2].v_rg[5] <= tpl_1(cae_stage_5[3].mv_get_sort(pipe[1].v_rg[5], pipe[1].v_rg[7]));
    pipe[2].v_rg[7] <= tpl_2(cae_stage_5[3].mv_get_sort(pipe[1].v_rg[5], pipe[1].v_rg[7]));

    rg_stage <= BM8_STAGE_5_DONE;

 endrule

 rule rl_bm8_stage_6 if (rg_stage == BM8_STAGE_5_DONE);
    
    $display("BM8 Stage 6 got inputs: %0d %0d %0d %0d %0d %0d %0d %0d", pipe[2].v_rg[0], pipe[2].v_rg[1], pipe[2].v_rg[2], pipe[2].v_rg[3], pipe[2].v_rg[4], pipe[2].v_rg[5], pipe[2].v_rg[6], pipe[2].v_rg[7]);

    pipe[3].v_rg[0] <= tpl_1(cae_stage_6[0].mv_get_sort(pipe[2].v_rg[0], pipe[2].v_rg[1]));
    pipe[3].v_rg[1] <= tpl_2(cae_stage_6[0].mv_get_sort(pipe[2].v_rg[0], pipe[2].v_rg[1]));

    pipe[3].v_rg[2] <= tpl_1(cae_stage_6[1].mv_get_sort(pipe[2].v_rg[2], pipe[2].v_rg[3]));
    pipe[3].v_rg[3] <= tpl_2(cae_stage_6[1].mv_get_sort(pipe[2].v_rg[2], pipe[2].v_rg[3]));

    pipe[3].v_rg[4] <= tpl_1(cae_stage_6[2].mv_get_sort(pipe[2].v_rg[4], pipe[2].v_rg[5]));
    pipe[3].v_rg[5] <= tpl_2(cae_stage_6[2].mv_get_sort(pipe[2].v_rg[4], pipe[2].v_rg[5]));

    pipe[3].v_rg[6] <= tpl_1(cae_stage_6[3].mv_get_sort(pipe[2].v_rg[6], pipe[2].v_rg[7]));
    pipe[3].v_rg[7] <= tpl_2(cae_stage_6[3].mv_get_sort(pipe[2].v_rg[6], pipe[2].v_rg[7]));

    rg_stage <= BM8_STAGE_6_DONE;

 endrule

method Action ma_get_inputs (BM8 bm8_in) if (rg_stage == INIT);
    
    bm4[0].ma_get_inputs((bm8_in.in[0]), bm8_in.in[1], bm8_in.in[2], bm8_in.in[3]);
    bm4[1].ma_get_inputs(bm8_in.in[4], bm8_in.in[5], bm8_in.in[6], bm8_in.in[7]);
    rg_stage <= BM4_INPUT;

endmethod

method ActionValue#(Tuple8#(int, int, int, int, int, int, int, int)) mav_return_outputs if (rg_stage == BM8_STAGE_6_DONE);
    rg_stage <= INIT;
    return(tuple8(pipe[3].v_rg[0], pipe[3].v_rg[1], pipe[3].v_rg[2], pipe[3].v_rg[3], pipe[3].v_rg[4], pipe[3].v_rg[5], pipe[3].v_rg[6], pipe[3].v_rg[7]));
endmethod

endmodule

endpackage