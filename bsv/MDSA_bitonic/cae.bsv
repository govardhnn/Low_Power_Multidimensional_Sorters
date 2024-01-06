package cae;

interface Ifc_cae;
   method Tuple2#(int, int) mv_get_sort (int a, int b);
endinterface

(* synthesize *)
module mk_cae (Ifc_cae);

   method Tuple2#(int, int) mv_get_sort (int a, int b);
      if(a > b) return (tuple2(b,a));
      else return (tuple2(a,b));
   endmethod

endmodule

endpackage