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

function CAE fn_map_cae(Bit#(WordLength) cae_input_1, Bit#(WordLength) cae_input_2);
  
   CAE lv_merge;
   lv_merge.inputs[0] = cae_input_1;
   lv_merge.inputs[1] = cae_input_2;
   
   return (lv_merge);

endfunction

function BM4 fn_map_bm4(CAE bm4_input_1, CAE bm4_input_2);
  
   BM4 lv_merge;
   lv_merge.inputs[0] = bm4_input_1.inputs[0];
   lv_merge.inputs[1] = bm4_input_1.inputs[1];
   lv_merge.inputs[2] = bm4_input_2.inputs[0];
   lv_merge.inputs[3] = bm4_input_2.inputs[1];
   
   return (lv_merge);

endfunction

typedef enum {INIT, STAGE_1, STAGE_2} RG_STAGE deriving (Bits, Eq);

typedef struct {Vector#(4, Reg#(Bit#(WordLength))) v_rg;} PIPE;

interface Ifc_bm4;
   method Action ma_get_inputs (Vector#(4, Bit#(WordLength)) inputs);
   method ActionValue#(BM4) mav_return_output ();
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
   pipe[lp_i].v_rg <- replicateM(mkReg(unpack(0)));
   end
 
   rule rl_stage_1(rg_stage == STAGE_1);
      let lv_get_sort_3 = cae[2].mv_get_sort(fn_map_cae(pipe[0].v_rg[0], pipe[0].v_rg[3]));
      let lv_get_sort_4 = cae[3].mv_get_sort(fn_map_cae(pipe[0].v_rg[1], pipe[0].v_rg[2])); 
      pipe[1].v_rg[0] <= lv_get_sort_3.inputs[0];
      pipe[1].v_rg[1]<= lv_get_sort_3.inputs[1];
      pipe[1].v_rg[2] <= lv_get_sort_4.inputs[0];
      pipe[1].v_rg[3] <= lv_get_sort_4.inputs[1];
      // $display("     BM4 Stage 1 outputs / STAGE 2 inputs: %0d, %0d, %0d, %0d", pipe[1].v_rg[0], pipe[1].v_rg[1], pipe[1].v_rg[2], pipe[1].v_rg[3]);
      rg_stage <= STAGE_2;
   endrule

   method Action ma_get_inputs (inputs) if (rg_stage == INIT);
      $display("     BM4 Stage 1 Inputs: Get inputs:", fshow(inputs));
      let lv_get_sort_1 = cae[0].mv_get_sort(fn_map_cae(inputs[0], inputs[1]));
      let lv_get_sort_2 = cae[1].mv_get_sort(fn_map_cae(inputs[2], inputs[3]));    
      pipe[0].v_rg[0] <= lv_get_sort_1.inputs[0];
      pipe[0].v_rg[1] <= lv_get_sort_1.inputs[1];
      pipe[0].v_rg[2] <= lv_get_sort_2.inputs[0];
      pipe[0].v_rg[3] <= lv_get_sort_2.inputs[1];
      rg_stage <= STAGE_1;
   endmethod

   method ActionValue#(BM4) mav_return_output () if (rg_stage == STAGE_2); 
      $display("     BM4 Stage 2 Outputs: %0d, %0d, %0d, %0d", pipe[1].v_rg[0], pipe[1].v_rg[1], pipe[1].v_rg[2], pipe[1].v_rg[3]);
      
      let lv_get_sort_5 = cae[4].mv_get_sort(fn_map_cae(pipe[1].v_rg[0], pipe[1].v_rg[1]));

      let lv_get_sort_6 = cae[5].mv_get_sort(fn_map_cae(pipe[1].v_rg[2], pipe[1].v_rg[3]));
      
      rg_stage <= INIT;
      return(fn_map_bm4(lv_get_sort_5, lv_get_sort_6));
   endmethod

endmodule
endpackage
