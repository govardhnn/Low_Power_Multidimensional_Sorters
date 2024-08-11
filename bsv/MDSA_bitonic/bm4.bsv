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
package bm4;

import cae :: *;
import Vector :: *;

typedef enum {INIT, STAGE_1, STAGE_2} RG_STAGE deriving (Bits, Eq);

typedef struct {Vector#(4, Reg#(int)) v_rg;} PIPE;

interface Ifc_bm4;
   method Action ma_get_inputs (int in1, int in2, int in3, int in4);
   method ActionValue#(Tuple4#(int, int, int, int)) mav_return_output (); 
endinterface

(*synthesize*)
module mk_bm4(Ifc_bm4);

   Ifc_cae cae[6];
   for (Integer lp_i = 0; lp_i < 6; lp_i = lp_i + 1) begin
      cae[lp_i] <- mk_cae();
   end
   
   Reg#(RG_STAGE) rg_stage <- mkReg(INIT);
   
   PIPE pipe[2];

   for (Integer lp_i = 0; lp_i < 2; lp_i = lp_i + 1) begin
   pipe[lp_i].v_rg <- replicateM(mkReg(0));
   end
 
   rule rl_stage_1(rg_stage == STAGE_1);
      let lv_get_sort_3 = cae[2].mv_get_sort(pipe[0].v_rg[0], pipe[0].v_rg[3]);
      let lv_get_sort_4 = cae[3].mv_get_sort(pipe[0].v_rg[1], pipe[0].v_rg[2]); 
      pipe[1].v_rg[0] <= tpl_1(lv_get_sort_3);
      pipe[1].v_rg[1]<= tpl_1(lv_get_sort_4);
      pipe[1].v_rg[2] <= tpl_2(lv_get_sort_4);
      pipe[1].v_rg[3] <= tpl_2(lv_get_sort_3);
      // $display("     BM4 Stage 1 outputs / STAGE 2 inputs: %0d, %0d, %0d, %0d", pipe[1].v_rg[0], pipe[1].v_rg[1], pipe[1].v_rg[2], pipe[1].v_rg[3]);
      rg_stage <= STAGE_2;
   endrule

   method Action ma_get_inputs (int in1, int in2, int in3, int in4) if (rg_stage == INIT);
      $display("     BM4 Stage 1 Inputs: Get inputs: %0d, %0d, %0d, %0d", in1, in2, in3, in4);
      let lv_get_sort_1 = cae[0].mv_get_sort(in1, in2);
      let lv_get_sort_2 = cae[1].mv_get_sort(in3, in4);    
      pipe[0].v_rg[0] <= tpl_1(lv_get_sort_1);
      pipe[0].v_rg[1] <= tpl_2(lv_get_sort_1);
      pipe[0].v_rg[2] <= tpl_1(lv_get_sort_2);
      pipe[0].v_rg[3] <= tpl_2(lv_get_sort_2);
      rg_stage <= STAGE_1;
   endmethod

   method ActionValue#(Tuple4#(int, int, int, int)) mav_return_output () if (rg_stage == STAGE_2); 
      $display("     BM4 Stage 2 Outputs: %0d, %0d, %0d, %0d", pipe[1].v_rg[0], pipe[1].v_rg[1], pipe[1].v_rg[2], pipe[1].v_rg[3]);
      
      let lv_get_sort_5 = cae[4].mv_get_sort(pipe[1].v_rg[0], pipe[1].v_rg[1]);

      let lv_get_sort_6 = cae[5].mv_get_sort(pipe[1].v_rg[2], pipe[1].v_rg[3]);
      
      rg_stage <= INIT;
      return (tuple4(tpl_1(lv_get_sort_5), tpl_2(lv_get_sort_5), tpl_1(lv_get_sort_6), tpl_2(lv_get_sort_6)));
   endmethod

endmodule
endpackage
