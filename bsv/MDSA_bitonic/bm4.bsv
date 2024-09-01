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
import mdsa_types :: *;
import List :: *;


function BM4_inputs fn_cae_to_bm4(CAE_inputs bm4_input_1, CAE_inputs bm4_input_2);
   BM4_inputs lv_merge;
   lv_merge[0] = bm4_input_1[0];
   lv_merge[1] = bm4_input_1[1];
   lv_merge[2] = bm4_input_2[0];
   lv_merge[3] = bm4_input_2[1];
   return (lv_merge);
endfunction

function BM8_inputs fn_cae_to_bm8(BM4_inputs bm8_input_1, BM4_inputs bm8_input_2);
   BM8_inputs lv_merge;
   lv_merge[0] = bm8_input_1[0];
   lv_merge[1] = bm8_input_1[1];
   lv_merge[2] = bm8_input_2[0];
   lv_merge[3] = bm8_input_2[1];
   return (lv_merge);
endfunction

interface Ifc_bm4;
   method Action ma_get_inputs (BM4_inputs inputs);
   method ActionValue#(BM4_inputs) mav_return_output;
endinterface

// function ActionValue#(BM4_inputs) fn_bm4_sort(Ifc_bm4 bm4, BM4_inputs bm4_input_1, BM4_inputs bm4_input_2);
//    actionvalue
//       let lv_get_sort <- bm4.ma_get_inputs(fn_cae_to_bm4(bm4_input_1, bm4_input_2));
//       return lv_get_sort;
//    endactionvalue
// endfunction

(*synthesize*)
module mk_bm4(Ifc_bm4);
   
   Vector#(2, Ifc_cae) cae <- replicateM(mk_cae());
   Vector#(2, Reg#(PIPE_BM4)) pipe <- replicateM(mkReg(unpack(0)));

   Reg#(RG_STAGE) rg_stage <- mkReg(INIT);

   method Action ma_get_inputs (BM4_inputs bm4) if (rg_stage == INIT);
      $display("     BM4 Stage 1 Inputs: Get inputs:", fshow(bm4));
      let lv_get_sort_1 <- fn_cae_dual_sort(cae[0], bm4[0], bm4[3]);
      let lv_get_sort_2 <- fn_cae_dual_sort(cae[1], bm4[1], bm4[2]);    
      pipe[0] <= cons(lv_get_sort_1[0], cons(lv_get_sort_2[0], cons(lv_get_sort_2[1], cons(lv_get_sort_1[1], nil))));
      rg_stage <= STAGE_1;
   endmethod

   method ActionValue#(BM4_inputs) mav_return_output() if (rg_stage == STAGE_1); 
      $display("     BM4 Stage 2 Outputs: %0d, %0d, %0d, %0d", pipe[0][0], pipe[0][1], pipe[0][2], pipe[0][3]);
      let lv_get_sort_3 <- fn_cae_dual_sort(cae[0], pipe[0][0], pipe[0][1]);
      let lv_get_sort_4 <- fn_cae_dual_sort(cae[1], pipe[0][2], pipe[0][3]);      
      rg_stage <= INIT;
      return fn_cae_to_bm4(lv_get_sort_3, lv_get_sort_4);
   endmethod
endmodule

endpackage
