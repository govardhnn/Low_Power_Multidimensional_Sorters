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
import BuildVector :: *;

typedef BM8 PIPE;

interface Ifc_bm8;
    method Action ma_get_inputs (BM8 bm8_in);
    method ActionValue#(BM8) mav_return_outputs;
endinterface

(*synthesize*)
module mk_bm8(Ifc_bm8);

    Reg#(RG_STAGE) rg_stage <- mkReg(INIT);
    
    // The bitonic sort has 6 stages, and needs 5 intermediate register pipelines
    Vector#(5, Reg#(BM8)) pipe <- replicateM(mkReg(unpack(0)));

    Vector#(4, Ifc_cae) cae_stage_1 <- replicateM(mk_cae());
    Vector#(2, Ifc_bm4) bm4_stage_2_3 <- replicateM(mk_bm4());
    Vector#(4, Ifc_cae) cae_stage_4 <- replicateM(mk_cae());
    Vector#(4, Ifc_cae) cae_stage_5 <- replicateM(mk_cae());
    Vector#(4, Ifc_cae) cae_stage_6 <- replicateM(mk_cae());

rule rl_send_inputs_to_bm4 if (rg_stage == BM4_INPUT);
    $display("[BM8]:[PIPE] Stage 1:", fshow(pipe[0]));
    bm4_stage_2_3[0].ma_get_inputs(vec(pipe[0][0], pipe[0][1], pipe[0][2], pipe[0][3]));
    bm4_stage_2_3[1].ma_get_inputs(vec(pipe[0][4], pipe[0][5], pipe[0][6], pipe[0][7]));
    rg_stage <= BM4_PROCESSING;
endrule

rule rl_get_outputs_from_bm4 if (rg_stage == BM4_PROCESSING);
    BM4 lv_get_bm4_sort_1 <- bm4_stage_2_3[0].mav_return_output();
    BM4 lv_get_bm4_sort_2 <- bm4_stage_2_3[1].mav_return_output();

    pipe[1] <= vec(lv_get_bm4_sort_1[0]
                    , lv_get_bm4_sort_1[1]
                    , lv_get_bm4_sort_1[2]
                    , lv_get_bm4_sort_1[3]
                    , lv_get_bm4_sort_2[0]
                    , lv_get_bm4_sort_2[1]
                    , lv_get_bm4_sort_2[2]
                    , lv_get_bm4_sort_2[3]);

    rg_stage <= BM4_DONE;
endrule

rule rl_bm8_stage_4 if (rg_stage == BM4_DONE);
    $display("[BM8]:[PIPE] Stage 3:", fshow(pipe[1]));

    let lv_stage_4_sort_1 <- cae_stage_4[0].mav_get_sort(vec(pipe[1][0], pipe[1][7]));  
    let lv_stage_4_sort_2 <- cae_stage_4[1].mav_get_sort(vec(pipe[1][1], pipe[1][6]));
    let lv_stage_4_sort_3 <- cae_stage_4[2].mav_get_sort(vec(pipe[1][2], pipe[1][5]));
    let lv_stage_4_sort_4 <- cae_stage_4[3].mav_get_sort(vec(pipe[1][3], pipe[1][4]));

    pipe[2] <= vec(lv_stage_4_sort_1[0]
                    , lv_stage_4_sort_2[0]
                    , lv_stage_4_sort_3[0]
                    , lv_stage_4_sort_4[0]
                    , lv_stage_4_sort_4[1]
                    , lv_stage_4_sort_3[1]
                    , lv_stage_4_sort_2[1]
                    , lv_stage_4_sort_1[1]);
                    
    rg_stage <= BM8_STAGE_4_DONE;

endrule

rule rl_bm8_stage_5 if (rg_stage == BM8_STAGE_4_DONE);
    
    $display("[BM8]:[PIPE] Stage 4:", fshow(pipe[2]));

    let lv_stage_5_sort_1 <- cae_stage_5[0].mav_get_sort(vec(pipe[2][0], pipe[2][2]));
    let lv_stage_5_sort_2 <- cae_stage_5[1].mav_get_sort(vec(pipe[2][1], pipe[2][3]));
    let lv_stage_5_sort_3 <- cae_stage_5[2].mav_get_sort(vec(pipe[2][4], pipe[2][6]));
    let lv_stage_5_sort_4 <- cae_stage_5[3].mav_get_sort(vec(pipe[2][5], pipe[2][7]));

    pipe[3] <= vec(lv_stage_5_sort_1[0], lv_stage_5_sort_2[0], lv_stage_5_sort_1[1], lv_stage_5_sort_2[1], lv_stage_5_sort_3[0], lv_stage_5_sort_4[0], lv_stage_5_sort_3[1], lv_stage_5_sort_4[1]);
    rg_stage <= BM8_STAGE_5_DONE;

endrule

rule rl_bm8_stage_6 if (rg_stage == BM8_STAGE_5_DONE);
    
    $display("[BM8]:[PIPE] Stage 5:", fshow(pipe[3]));

    let lv_stage_6_sort_1 <- cae_stage_6[0].mav_get_sort(vec(pipe[3][0], pipe[3][1]));
    let lv_stage_6_sort_2 <- cae_stage_6[1].mav_get_sort(vec(pipe[3][2], pipe[3][3]));
    let lv_stage_6_sort_3 <- cae_stage_6[2].mav_get_sort(vec(pipe[3][4], pipe[3][5]));
    let lv_stage_6_sort_4 <- cae_stage_6[3].mav_get_sort(vec(pipe[3][6], pipe[3][7]));

    pipe[4] <= vec(lv_stage_6_sort_1[0], lv_stage_6_sort_1[1], lv_stage_6_sort_2[0], lv_stage_6_sort_2[1], lv_stage_6_sort_3[0], lv_stage_6_sort_3[1], lv_stage_6_sort_4[0], lv_stage_6_sort_4[1]);
    rg_stage <= BM8_STAGE_6_DONE;

endrule

method Action ma_get_inputs (BM8 bm8_in) if (rg_stage == INIT);
    
    let lv_cae_sort_1 <- cae_stage_1[0].mav_get_sort(vec(bm8_in[0], bm8_in[1]));
    let lv_cae_sort_2 <- cae_stage_1[1].mav_get_sort(vec(bm8_in[2], bm8_in[3]));
    let lv_cae_sort_3 <- cae_stage_1[2].mav_get_sort(vec(bm8_in[4], bm8_in[5]));
    let lv_cae_sort_4 <- cae_stage_1[3].mav_get_sort(vec(bm8_in[6], bm8_in[7]));

    pipe[0] <= vec(lv_cae_sort_1[0]
                    , lv_cae_sort_1[1]
                    , lv_cae_sort_2[0]
                    , lv_cae_sort_2[1]
                    , lv_cae_sort_3[0]
                    , lv_cae_sort_3[1]
                    , lv_cae_sort_4[0]
                    , lv_cae_sort_4[1]);

    rg_stage <= BM4_INPUT;

endmethod

method ActionValue#(BM8) mav_return_outputs if (rg_stage == BM8_STAGE_6_DONE);
    rg_stage <= INIT;
    BM8 lv_output_return;
    lv_output_return = vec(pipe[4][0], pipe[4][1], pipe[4][2], pipe[4][3], pipe[4][4], pipe[4][5], pipe[4][6], pipe[4][7]);
    return(lv_output_return);
endmethod

endmodule

endpackage