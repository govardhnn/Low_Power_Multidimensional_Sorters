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

// Import required packages
import cae :: *;
import Vector :: *;
import mdsa_types :: *;
import BuildVector   ::*; 

// Function to combine two BM4 inputs into a BM8 input
// This enables hierarchical construction of larger bitonic mergers
function BM8 fn_cae_to_bm8(BM4 bm8_input_1, BM4 bm8_input_2);
   BM8 lv_merge;
   lv_merge[0] = bm8_input_1[0];
   lv_merge[1] = bm8_input_1[1];
   lv_merge[2] = bm8_input_2[0];
   lv_merge[3] = bm8_input_2[1];
   return (lv_merge);
endfunction

// Interface for the 4-input Bitonic Merger
interface Ifc_bm4;
   // Method to input 4 values to be sorted
   method Action ma_get_inputs (BM4 inputs);
   // Method to get the sorted output
   method ActionValue#(BM4) mav_return_output;
endinterface

// Synthesizable module implementing a 4-input Bitonic Merge Unit
(*synthesize*)
module mk_bm4(Ifc_bm4);
   
   // Create 2 Compare-And-Exchange (CAE) units for parallel comparisons
   Vector#(2, Ifc_cae) cae <- replicateM(mk_cae());
   
   // Pipeline registers to store intermediate results
   Reg#(BM4) pipe <- mkReg(unpack(0));

   // Register to track the current stage of sorting
   Reg#(RG_STAGE) rg_stage <- mkReg(INIT);

   // Stage 1: Initial parallel comparisons
   method Action ma_get_inputs (BM4 bm4) if (rg_stage == INIT);
      fn_display($format("     BM4 Stage 1 Inputs: Get inputs:", fshow(bm4)));
      // Perform parallel CAE operations on input pairs (0,3) and (1,2)
      let lv_get_sort_1 <- cae[0].mav_get_sort(vec(bm4[0], bm4[3]));
      let lv_get_sort_2 <- cae[1].mav_get_sort(vec(bm4[1], bm4[2]));    
      // Store intermediate results in a pipeline 
      pipe <= vec(lv_get_sort_1[0], lv_get_sort_2[0], lv_get_sort_2[1], lv_get_sort_1[1]);
      rg_stage <= STAGE_1;
   endmethod

   // Stage 2: Final parallel comparisons
   method ActionValue#(BM4) mav_return_output() if (rg_stage == STAGE_1); 
      fn_display($format("     BM4 Stage 2 Outputs: %0d, %0d, %0d, %0d", pipe[0][0], pipe[0][1], pipe[0][2], pipe[0][3]));
      // Perform parallel CAE operations on adjacent pairs
      let lv_get_sort_3 <- cae[0].mav_get_sort(vec(pipe[0], pipe[1]));
      let lv_get_sort_4 <- cae[1].mav_get_sort(vec(pipe[2], pipe[3]));      
      rg_stage <= INIT;
      // Return the final sorted sequence
      return (vec(lv_get_sort_3[0], lv_get_sort_3[1], lv_get_sort_4[0], lv_get_sort_4[1]));
   endmethod
endmodule

endpackage
