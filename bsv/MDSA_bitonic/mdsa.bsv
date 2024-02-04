package mdsa;

import bm8 :: *;
import Vector :: *;

typedef enum {WAIT, PHASE_1, PHASE_2, PHASE_3, PHASE_4, PHASE_5, PHASE_6, DONE} RG_FSM_STAGE deriving (Bits, Eq);

typedef struct {Vector#(8, Vector#(8, Reg#(int))) v_rg_bank;} BANK;

interface Ifc_mdsa;
    method Action ma_send_inputs(Vector#(8, Vector#(8, int)) reg_bank_input);
    method Bool mb_done;
endinterface

(*synthesize*)

module mk_mdsa(Ifc_mdsa);

    Reg#(RG_FSM_STAGE) rg_fsm_stage <- mkReg(WAIT);
    Reg#(Bit#(8)) rg_direction <- mkReg(0);

    Reg#(BANK) rg_bank;
    for (Integer lp_i = 0; lp_i < 8; lp_i = lp_i + 1) begin
        for (Integer lp_j = 0; lp_j < 8; lp_j = lp_j + 1) begin
            rg_bank[lp_i].v_rg_bank <- replicateM(mkReg(0));
        end
    end
    
    method Action ma_send_inputs(Vector#(8, Vector#(8, int)) reg_bank_input) if (rg_fsm_stage == WAIT);
        // rg_bank <= reg_bank_input;
        // $display("reg_bank_input = %0d", reg_bank_input);
        rg_fsm_stage <= DONE;
    endmethod   
        
    method Bool mb_done if (rg_fsm_stage == DONE);
    return(True);
    endmethod


endmodule


endpackage