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

package bm4_testbench;

`define COUNTER_LIM 2

import bm4 :: *;
import mdsa_types :: *;
import Vector :: *;
import List :: *;

(*synthesize*)
module mk_bm4_testbench(Empty);
    
    Reg#(Bool) rg_sent_data <- mkReg(False);

    Ifc_bm4 bm4 <- mk_bm4; 

    Reg#(Bool) rg_sent_bm4_test <- mkReg(False);

    BM4 initialVector = map(fromInteger, reverse(genVector));

    Reg#(BM4) rg_bm4_input <- mkReg(initialVector);

    rule rl_send_data(!rg_sent_bm4_test);
        $display(" -- TB -- Sending data: ", fshow(rg_bm4_input));

        bm4.ma_get_inputs(rg_bm4_input);

        rg_sent_bm4_test <= True;
    endrule

    rule rl_get_result(rg_sent_bm4_test);
        let lv_out <- bm4.mav_return_output();
        $display(" -- TB -- Output is", fshow(lv_out));
        $finish;
    endrule

endmodule

endpackage