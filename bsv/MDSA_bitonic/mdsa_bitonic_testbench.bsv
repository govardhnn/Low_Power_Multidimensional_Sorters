package mdsa_bitonic_testbench;

import mdsa_bitonic     ::  *;
import mdsa_types     ::  *;
import Vector         ::  *;

typedef enum {
    IDLE
    , WAIT_FOR_OUTPUT
} MDSA_TB_STAGE deriving(Bits, Eq, FShow);

(*synthesize*)
module mk_mdsa_bitonic_testbench(Empty);

    Reg#(MDSA_TB_STAGE) rg_mdsa_tb_stage <- mkReg(IDLE);

    Ifc_mdsa_bitonic mdsa_bitonic <- mk_mdsa_bitonic();
    MDSA_64 initial_vector = unpack(0);

    // Vector#(64, Bit#(WordLength)) lv_test_vector = map(fromInteger, reverse(genVector));
    // initial_vector = unpack(lv_test_vector);

    for(Integer i = 0; i < 8; i = i + 1) begin
        for (Integer j = 0; j < 8; j = j + 1) begin
            initial_vector[i][j] = (8*(8-fromInteger(i)) - fromInteger(j));
        end
    end
    Reg#(MDSA_64) v_mdsa_input_tb <- mkReg(initial_vector);

    rule rl_start(rg_mdsa_tb_stage == IDLE);
        mdsa_bitonic.ma_start();
        mdsa_bitonic.ma_input_mdsa(v_mdsa_input_tb);
        rg_mdsa_tb_stage <= WAIT_FOR_OUTPUT;
    endrule

    rule rl_display_final_mdsa_output(rg_mdsa_tb_stage == WAIT_FOR_OUTPUT);
        let lv_mdsa_output <- mdsa_bitonic.mav_return_outputs();
        $display("Final MDSA output: %h", fshow(lv_mdsa_output));
        $finish;
    endrule
endmodule
endpackage