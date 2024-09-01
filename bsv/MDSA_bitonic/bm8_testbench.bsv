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
package bm8_testbench;

import bm8 :: *;
import mdsa_types :: *;
import Vector :: *;

(*synthesize*)
module mk_bm8_testbench(Empty);


    BM8_inputs initialVector = map(fromInteger, reverse(genVector));

    Reg#(BM8_inputs) rg_bm8_in <- mkReg(initialVector);

    Ifc_bm8 bm8 <- mk_bm8;

    rule rl_send_data;
        $display(" -- TB -- Sending data:", fshow(rg_bm8_in));
        bm8.ma_get_inputs(rg_bm8_in);
    endrule

    rule rl_get_result;
             
        let lv_out <- bm8.mav_return_outputs();

        $display(" -- TB - Got data:", fshow(lv_out));
        $finish;
    endrule

endmodule

endpackage