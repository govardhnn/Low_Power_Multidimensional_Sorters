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
    
// function Vector#(4, Bit#(WordLength)) createVector();
//     return(toVector(List(4, 3, 2, 1)));
// endfunction

(*synthesize*)
module mk_bm4_testbench(Empty);

    // Reg#(int) rg_in_1 <- mkReg(4);
    // Reg#(int) rg_in_2 <- mkReg(3);
    // Reg#(int) rg_in_3 <- mkReg(2);
    // Reg#(int) rg_in_4 <- mkReg(1);

    // Reg#(Vector#(4, Bit#(WordLength))) rg_bm4_input <- mkReg(unpack(0));

    // for (Bit#(WordLength) i = 0; i < 4; i = i + 1) begin
    //     rg_bm4_input[i] = 4-i;
    // end

    // function Vector#(4, Bit#(WordLength)) fn_write_bm4(Vector#(4, Bit#(WordLength)) inputs);
    //     inputs[0] = 4; 
    //     inputs[1] = 3;
    //     inputs[2] = 2;
    //     inputs[3] = 1;
    //     return inputs;
    // endfunction

    
    Reg#(Bool) rg_sent_data <- mkReg(False);

    Ifc_bm4 bm4 <- mk_bm4; 

    Reg#(int) rg_counter <- mkReg(0);

//     // Reg#(Vector#(4, Bit#(WordLength))) rg_bm4_input <- mkReg(unpack(0));
// Vector#(4, Bit#(WordLength)) initialVector = newVector;
// initialVector[0] = 4;
// initialVector[1] = 3;
// initialVector[2] = 2;
// initialVector[3] = 1;


// function Bit#(WordLength) reverseIndex(Integer i) = fromInteger(4 - i);
// Vector#(4, Bit#(WordLength)) initialVector = map(reverseIndex, genVector);

Vector#(4, Bit#(WordLength)) initialVector = map(fromInteger, reverse(genVector));

Reg#(Vector#(4, Bit#(WordLength))) rg_bm4_input <- mkReg(initialVector);

    rule rl_send_data(rg_counter < `COUNTER_LIM && !rg_sent_data);
        // let lv_bm4_input = BM4{inputs: rg_bm4_input};
        $display(" -- TB -- Sending data: ", rg_bm4_input);
        bm4.ma_get_inputs(rg_bm4_input);
        rg_counter <= rg_counter + 1;
        rg_sent_data <= True;
        if (rg_counter == `COUNTER_LIM - 1) $finish;
    endrule

    rule rl_get_result(rg_counter < `COUNTER_LIM && rg_sent_data);
        let lv_out <- bm4.mav_return_output();
        $display(" -- TB -- Output is", fshow(lv_out));
        rg_sent_data <= False;
        if (rg_counter == `COUNTER_LIM - 1) $finish;
    endrule

endmodule

endpackage