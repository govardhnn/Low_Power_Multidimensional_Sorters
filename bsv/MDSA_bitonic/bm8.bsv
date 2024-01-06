package bm8;

import bm4 :: *;
import cae :: *;
import Vector :: *;

typedef enum {INIT, STAGE_1, STAGE_2, STAGE_3, STAGE_4, STAGE_5, STAGE_6} RG_STAGE deriving (Bits, Eq);

typedef struct {Vector#(8, Reg#(int)) v_rg;} PIPE;

interface Ifc_bm8;
    method Action ma_get_inputs (int in1, int in2, int in3, int in4, int in5, int in6, int in7, int in8);
    method ActionValue#(Tuple8#(int, int, int, int, int, int, int, int)) mav_return_outputs;
endinterface

(*synthesize*)
module mk_bm8(Ifc_bm8);

Reg#(RG_STAGE) rg_stage <- mkReg(INIT);

PIPE pipe[6];

for (Integer lp_i = 0; lp_i < 6; lp_i = lp_i + 1) begin
    pipe[lp_i].v_rg <- replicateM(mkReg(0));
    end
  
method Action ma_get_inputs (int in1, int in2, int in3, int in4, int in5, int in6, int in7, int in8) if (rg_stage == INIT);
    // temporarily write all the inputs to the PIPE 1
    pipe[0].v_rg[0] <= in1;
    pipe[0].v_rg[1] <= in2;
    pipe[0].v_rg[2] <= in3;
    pipe[0].v_rg[3] <= in4;
    pipe[0].v_rg[4] <= in5;
    pipe[0].v_rg[5] <= in6;
    pipe[0].v_rg[6] <= in7;
    pipe[0].v_rg[7] <= in8;
    rg_stage <= STAGE_1;
endmethod

method ActionValue#(Tuple8#(int, int, int, int, int, int, int, int)) mav_return_outputs if (rg_stage == STAGE_1);
    rg_stage <= INIT;
    return(tuple8(pipe[0].v_rg[0], pipe[0].v_rg[1], pipe[0].v_rg[2], pipe[0].v_rg[3], pipe[0].v_rg[4], pipe[0].v_rg[5], pipe[0].v_rg[6], pipe[0].v_rg[7]));
endmethod

endmodule

endpackage