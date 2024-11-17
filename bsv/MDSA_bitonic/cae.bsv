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
package cae;

import mdsa_types       ::*;
import Vector           ::*;
import BuildVector      ::*;

// This function performs the CAE dual sort operation
function ActionValue#(CAE_inputs) fn_cae_dual_sort(
   Ifc_cae cae
   , Bit#(WordLength) cae_input_1
   , Bit#(WordLength) cae_input_2);
   
   actionvalue
      // invoke the CAE sorting operation
      let lv_get_sort <- cae.mav_get_sort(vec(cae_input_1, cae_input_2));
      return lv_get_sort;
   endactionvalue

endfunction

// The Interface for the CAE block
interface Ifc_cae;
   // Receive and send back cae inputs (which are two numbers) -- in ascending order
   method ActionValue#(CAE_inputs) mav_get_sort (CAE_inputs cae);
endinterface

(* synthesize *)
module mk_cae(Ifc_cae);
   // Here sort the inputs to ascending order
   // checks if the first element is greater than the second element
   method ActionValue#(CAE_inputs) mav_get_sort (CAE_inputs cae);

      if(cae[0] > cae[1]) begin
         // Vectors has a simple function called reverse - 
         // which does exactly what you think it does! - reverse elements of the vector :)
         cae = reverse(cae);
      end
      // If the numbers are already in ascending order, return the same vector
      
      return (cae);
   endmethod

endmodule

endpackage