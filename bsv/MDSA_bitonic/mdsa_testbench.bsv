package mdsa_testbench;

import mdsa :: *;
import Vector :: *;

(*synthesize*)
module mk_mdsa_testbench();

    Ifc_mdsa mdsa <- mk_mdsa;

    Vector#(8, Vector#(8, int)) bank_test;
    Reg#(bank_test) rg_bank_test;
    for (Integer lp_i = 0; lp_i < 8; lp_i = lp_i + 1) begin
        for (Integer lp_j = 0; lp_j < 8; lp_j = lp_j + 1) begin
            rg_bank_test[lp_i][lp_j] <- mkReg(0);
        end
    end

    // rg_bank_test[0] <= {63, 62, 61, 60, 59, 58, 57, 56};
    // rg_bank_test[1] <= {55, 54, 53, 52, 51, 50, 49, 48};
    // rg_bank_test[2] <= {47, 46, 45, 44, 43, 42, 41, 40};
    // rg_bank_test[3] <= {39, 38, 37, 36, 35, 34, 33, 32};
    // rg_bank_test[4] <= {31, 30, 29, 28, 27, 26, 25, 24};
    // rg_bank_test[5] <= {23, 22, 21, 20, 19, 18, 17, 16};
    // rg_bank_test[6] <= {15, 14, 13, 12, 11, 10, 9, 8};
    // rg_bank_test[7] <= {7, 6, 5, 4, 3, 2, 1, 0};

rule rl_send_inputs;
    $display(" -- TB -- Sending: %0d ", rg_bank_test);
    mdsa.ma_send_inputs(rg_bank_test);
endrule

rule rl_get_done;
    $display("DONE? : ", mdsa.mb_done);
    $finish;
endrule

endmodule

endpackage