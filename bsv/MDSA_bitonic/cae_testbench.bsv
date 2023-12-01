package cae_testbench;

import cae :: *;

(* synthesize *)
module mk_cae_testbench (Empty);

   Ifc_cae cae_inst <- mk_cae();

   Reg#(int) reg_input_1 <- mkReg(9);
   Reg#(int) reg_input_2 <- mkReg(4);

   rule rl_tb_get_data;
      $display("Sending data: %0d %0d", reg_input_1, reg_input_2);
      let lv_numbers = cae_inst.mv_get_sort(reg_input_1, reg_input_2);
      $display("Received data: %0d %0d", tpl_1(lv_numbers), tpl_2(lv_numbers));   
      $finish;
   endrule


endmodule

endpackage