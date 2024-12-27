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
package cae_testbench;

import cae :: *;
import mdsa_types :: *;
import Vector :: *;

(* synthesize *)
module mk_cae_testbench (Empty);

   Ifc_cae cae_inst <- mk_cae();

   CAE v_cae_test_inputs = map(fromInteger, reverse(genVector));

   Reg#(CAE) rg_cae <- mkReg(v_cae_test_inputs);

   rule rl_tb_get_data(True);
      $display("Sending data: ", fshow(rg_cae));

      let lv_numbers <- cae_inst.mav_get_sort(rg_cae);
      $display("Received data: ", fshow(lv_numbers));   
      
      $finish;
   endrule

endmodule

endpackage