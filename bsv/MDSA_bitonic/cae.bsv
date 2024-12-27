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

// The Interface for the CAE block
interface Ifc_cae;
   // Receive and return the ascending order of the two inputs
   method ActionValue#(CAE) mav_get_sort (CAE cae_in);
endinterface

(* synthesize *)
module mk_cae(Ifc_cae);
   // Sort the inputs to ascending order
   method ActionValue#(CAE) mav_get_sort (CAE cae_in);
      if(cae_in[0] > cae_in[1]) begin
         cae_in = reverse(cae_in);
      end      
      return(cae_in);
   endmethod

endmodule

endpackage