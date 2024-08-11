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

(* synthesize *)
module mk_cae_testbench (Empty);
   
   Ifc_cae cae_inst <- mk_cae();

   Reg#(CAE) rg_cae <- mkReg(unpack(0));
   Reg#(Bool) rg_initialized <- mkReg(False);

   rule rl_init (True);
      CAE init_cae = unpack(0);
      for (Bit#(32) i = 0; i < 2; i = i + 1) begin
         init_cae.inputs[i] = 2 - i;
      end
      rg_cae <= init_cae;
      rg_initialized <= True;
   endrule

   rule rl_tb_get_data(rg_initialized);
      $display("Sending data: ", fshow(rg_cae._read));

      let lv_numbers = cae_inst.mv_get_sort(rg_cae._read);
      $display("Received data: ", fshow(lv_numbers));   
      
      $finish;
   endrule

endmodule

endpackage