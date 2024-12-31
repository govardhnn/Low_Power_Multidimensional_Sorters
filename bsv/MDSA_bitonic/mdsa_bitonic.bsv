package mdsa_bitonic;

import Vector :: *;
import mdsa_types :: *;
import bm8 :: *;

interface Ifc_mdsa_bitonic;
    method Action ma_input_mdsa (MDSA_64 mdsa);
    method ActionValue#(MDSA_64) mav_return_outputs;

endinterface

(*synthesize*)
module mk_mdsa_bitonic(Ifc_mdsa_bitonic);

    function fn_input_sorting_network(Vector#(8, Ifc_bm8) bm8
                                        , MDSA_64 mdsa_in);
        action
            bm8[0].ma_get_inputs(mdsa_in[0]);
            bm8[1].ma_get_inputs(mdsa_in[1]);
            bm8[2].ma_get_inputs(mdsa_in[2]);
            bm8[3].ma_get_inputs(mdsa_in[3]);
            bm8[4].ma_get_inputs(mdsa_in[4]);
            bm8[5].ma_get_inputs(mdsa_in[5]);
            bm8[6].ma_get_inputs(mdsa_in[6]);
            bm8[7].ma_get_inputs(mdsa_in[7]);
        endaction
    endfunction


    Reg#(MDSA_FSM) rg_mdsa_fsm <- mkReg(IDLE);

    // This 64 Entry Buffer divides the data into 8 blocks of 8 input vectors
    // and is reused after each "phase" of sorting
    Reg#(MDSA_64) v_rg_mdsa_in <- mkReg(unpack(0));

    // Vector of 8 interfaces to the BM8 units
    Vector#(8, Ifc_bm8) bm8 <- replicateM(mk_bm8());

    /*------------------ STAGE 1 ----------------*/
    rule rl_mdsa_send_inputs_to_stage_1(rg_mdsa_fsm == STAGE_1_IN);
        // Column Sorting Phase
        fn_display($format("[MDSA] STARTING MDSA STAGE 1"));
        fn_display($format("[MDSA]: STAGE 1 INPUTS:", fshow(v_rg_mdsa_in)));   
        fn_input_sorting_network(bm8, v_rg_mdsa_in);
        rg_mdsa_fsm <= STAGE_1_OUT;
    endrule

    rule rl_collect_outputs_from_stage_1(rg_mdsa_fsm == STAGE_1_OUT);

        MDSA_64 lv_s1_output = newVector();
        // Ascending (0,1,2,3,4,5,6,7)
        lv_s1_output[0] <- bm8[0].mav_return_outputs();
        lv_s1_output[1] <- bm8[1].mav_return_outputs();
        lv_s1_output[2] <- bm8[2].mav_return_outputs();
        lv_s1_output[3] <- bm8[3].mav_return_outputs();
        lv_s1_output[4] <- bm8[4].mav_return_outputs();
        lv_s1_output[5] <- bm8[5].mav_return_outputs();
        lv_s1_output[6] <- bm8[6].mav_return_outputs();
        lv_s1_output[7] <- bm8[7].mav_return_outputs();
        
        // Transpose from Column Sorting to Row Sorting
        v_rg_mdsa_in <= transpose(lv_s1_output);
        
        rg_mdsa_fsm <= STAGE_2_IN;
        fn_display($format("[MDSA]: STAGE 1 DONE"));
        fn_display($format("[MDSA]: STAGE 1 OUTPUTS:", fshow(lv_s1_output)));
    endrule

    /*------------------ STAGE 2 ----------------*/
    
    rule rl_mdsa_send_inputs_to_stage_2(rg_mdsa_fsm == STAGE_2_IN);
        // Row Sorting Phase
        fn_display($format("[MDSA] STARTING MDSA STAGE 2"));
        fn_display($format("[MDSA]: STAGE 2 INPUTS:", fshow(v_rg_mdsa_in)));   
        fn_input_sorting_network(bm8, v_rg_mdsa_in);
        rg_mdsa_fsm <= STAGE_2_OUT;
    endrule

    rule rl_collect_outputs_from_stage_2(rg_mdsa_fsm == STAGE_2_OUT);
        // Ascending(0,2,4,6)
        // Descending (1,3,5,7)
        MDSA_64 lv_s2_output = newVector();
        
        lv_s2_output[0] <- bm8[0].mav_return_outputs();
        lv_s2_output[1] <- bm8[1].mav_return_outputs();
        lv_s2_output[1] = reverse(lv_s2_output[1]);
        lv_s2_output[2] <- bm8[2].mav_return_outputs();
        lv_s2_output[3] <- bm8[3].mav_return_outputs();
        lv_s2_output[3] = reverse(lv_s2_output[3]);
        lv_s2_output[4] <- bm8[4].mav_return_outputs();
        lv_s2_output[5] <- bm8[5].mav_return_outputs();
        lv_s2_output[5] = reverse(lv_s2_output[5]);
        lv_s2_output[6] <- bm8[6].mav_return_outputs();
        lv_s2_output[7] <- bm8[7].mav_return_outputs();
        lv_s2_output[7] = reverse(lv_s2_output[7]);

        // Transpose from Row Sorting to Column Sorting
        v_rg_mdsa_in <= transpose(lv_s2_output);
        
        rg_mdsa_fsm <= STAGE_3_IN;
        fn_display($format("[MDSA]: STAGE 2 DONE"));
        fn_display($format("[MDSA]: STAGE 2 OUTPUTS:", fshow(lv_s2_output)));
    endrule

    /*------------------ STAGE 3 ----------------*/

    rule rl_mdsa_send_inputs_to_stage_3(rg_mdsa_fsm == STAGE_3_IN);

        // Column Sorting Phase
        fn_display($format("[MDSA] STARTING MDSA STAGE 3"));
        fn_display($format("[MDSA]: STAGE 3 INPUTS:", fshow(v_rg_mdsa_in)));   
        fn_input_sorting_network(bm8, v_rg_mdsa_in);
        rg_mdsa_fsm <= STAGE_3_OUT;

    endrule

    rule rl_collect_outputs_from_stage_3(rg_mdsa_fsm == STAGE_3_OUT);
        MDSA_64 lv_s3_output = newVector();
        // Ascending (0,1,2,3,4,5,6,7)
        lv_s3_output[0] <- bm8[0].mav_return_outputs();
        lv_s3_output[1] <- bm8[1].mav_return_outputs();
        lv_s3_output[2] <- bm8[2].mav_return_outputs();
        lv_s3_output[3] <- bm8[3].mav_return_outputs();
        lv_s3_output[4] <- bm8[4].mav_return_outputs();
        lv_s3_output[5] <- bm8[5].mav_return_outputs();
        lv_s3_output[6] <- bm8[6].mav_return_outputs();
        lv_s3_output[7] <- bm8[7].mav_return_outputs();

        // Transpose from Column Sorting to Row Sorting
        v_rg_mdsa_in <= transpose(lv_s3_output);
        
        rg_mdsa_fsm <= STAGE_4_IN;
        fn_display($format("[MDSA]: STAGE 3 DONE"));
        fn_display($format("[MDSA]: STAGE 3 OUTPUTS:", fshow(lv_s3_output)));

    endrule

    /*------------------ STAGE 4 ----------------*/

    rule rl_mdsa_send_inputs_to_stage_4(rg_mdsa_fsm == STAGE_4_IN);
        // Row Sorting Phase
        fn_display($format("[MDSA] STARTING MDSA STAGE 4"));
        fn_display($format("[MDSA]: STAGE 4 INPUTS:", fshow(v_rg_mdsa_in)));   
        fn_input_sorting_network(bm8, v_rg_mdsa_in);

        rg_mdsa_fsm <= STAGE_4_OUT;
    endrule

    rule rl_collect_outputs_from_stage_4(rg_mdsa_fsm == STAGE_4_OUT);
        // Descending(0,2,4,6)
        // Ascending(1,3,5,7)
        MDSA_64 lv_s4_output = newVector();
        
        lv_s4_output[0] <- bm8[0].mav_return_outputs();
        lv_s4_output[0] = reverse(lv_s4_output[0]);
        lv_s4_output[1] <- bm8[1].mav_return_outputs();
        lv_s4_output[2] <- bm8[2].mav_return_outputs();
        lv_s4_output[2] = reverse(lv_s4_output[2]); 
        lv_s4_output[3] <- bm8[3].mav_return_outputs();
        lv_s4_output[4] <- bm8[4].mav_return_outputs();
        lv_s4_output[4] = reverse(lv_s4_output[4]);
        lv_s4_output[5] <- bm8[5].mav_return_outputs();
        lv_s4_output[6] <- bm8[6].mav_return_outputs();
        lv_s4_output[6] = reverse(lv_s4_output[6]);
        lv_s4_output[7] <- bm8[7].mav_return_outputs();

        // Transpose from Row Sorting to Column Sorting
        v_rg_mdsa_in <= transpose(lv_s4_output);
        
        rg_mdsa_fsm <= STAGE_5_IN;
        fn_display($format("[MDSA]: STAGE 4 DONE"));
        fn_display($format("[MDSA]: STAGE 4 OUTPUTS:", fshow(lv_s4_output)));
    endrule

    rule rl_mdsa_send_inputs_to_stage_5(rg_mdsa_fsm == STAGE_5_IN);
        // Column Sorting Phase
        fn_display($format("[MDSA] STARTING MDSA STAGE 5"));
        fn_display($format("[MDSA]: STAGE 5 INPUTS:", fshow(v_rg_mdsa_in)));   
        fn_input_sorting_network(bm8, v_rg_mdsa_in);

        rg_mdsa_fsm <= STAGE_5_OUT;
    endrule

    rule rl_collect_outputs_from_stage_5(rg_mdsa_fsm == STAGE_5_OUT);
        MDSA_64 lv_s5_output = newVector();
        // Ascending (0,1,2,3,4,5,6,7)
        lv_s5_output[0] <- bm8[0].mav_return_outputs();
        lv_s5_output[1] <- bm8[1].mav_return_outputs();
        lv_s5_output[2] <- bm8[2].mav_return_outputs();
        lv_s5_output[3] <- bm8[3].mav_return_outputs();
        lv_s5_output[4] <- bm8[4].mav_return_outputs();
        lv_s5_output[5] <- bm8[5].mav_return_outputs();
        lv_s5_output[6] <- bm8[6].mav_return_outputs(); 
        lv_s5_output[7] <- bm8[7].mav_return_outputs();

        // Transpose from Column Sorting to Row Sorting
        v_rg_mdsa_in <= transpose(lv_s5_output);
        
        rg_mdsa_fsm <= STAGE_6_IN;
        fn_display($format("[MDSA]: STAGE 5 DONE"));
        fn_display($format("[MDSA]: STAGE 5 OUTPUTS:", fshow(lv_s5_output)));
    endrule

    rule rl_mdsa_send_inputs_to_stage_6(rg_mdsa_fsm == STAGE_6_IN);
        // Row Sorting Phase
        fn_display($format("[MDSA] STARTING MDSA STAGE 6"));
        fn_display($format("[MDSA]: STAGE 6 INPUTS:", fshow(v_rg_mdsa_in)));   
        fn_input_sorting_network(bm8, v_rg_mdsa_in);

        rg_mdsa_fsm <= STAGE_6_OUT;
    endrule

    rule rl_collect_outputs_from_stage_6(rg_mdsa_fsm == STAGE_6_OUT);
        // Ascending (0,1,2,3,4,5,6,7)
        MDSA_64 lv_s6_output = newVector();
        lv_s6_output[0] <- bm8[0].mav_return_outputs();
        lv_s6_output[1] <- bm8[1].mav_return_outputs();
        lv_s6_output[2] <- bm8[2].mav_return_outputs();
        lv_s6_output[3] <- bm8[3].mav_return_outputs();
        lv_s6_output[4] <- bm8[4].mav_return_outputs();
        lv_s6_output[5] <- bm8[5].mav_return_outputs();
        lv_s6_output[6] <- bm8[6].mav_return_outputs();
        lv_s6_output[7] <- bm8[7].mav_return_outputs();

        // Final Output from the sorter 
        v_rg_mdsa_in <= lv_s6_output;
        
        rg_mdsa_fsm <= MDSA_DONE;

        fn_display($format("[MDSA]: STAGE 6 DONE"));
        fn_display($format("[MDSA]: STAGE 6 OUTPUTS:", fshow(lv_s6_output)));
    endrule
    method Action ma_input_mdsa (MDSA_64 mdsa_in);
        v_rg_mdsa_in <= mdsa_in;
        rg_mdsa_fsm <= STAGE_1_IN;
    endmethod

    method ActionValue#(MDSA_64) mav_return_outputs if (rg_mdsa_fsm == MDSA_DONE);
        rg_mdsa_fsm <= IDLE;
        fn_display($format("[MDSA] DONE. Returning outputs:", fshow(v_rg_mdsa_in)));
        return(v_rg_mdsa_in);
    endmethod
endmodule


endpackage