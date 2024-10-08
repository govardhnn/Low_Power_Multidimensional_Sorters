package mdsa_types;

import Vector :: *;

// `define WordLength 32
typedef 32 WordLength;

// typedef of CAE inputs
typedef Vector#(2, Bit#(WordLength)) CAE_inputs;

// typedef of BM4 inputs
typedef Vector#(4, Bit#(WordLength)) BM4_inputs;

// typedef of BM8 inputs
typedef Vector#(8, Bit#(WordLength)) BM8_inputs;

typedef enum {
    INIT
    , STAGE_1
    , STAGE_2
    , BM4_INPUT
    , BM4_PROCESSING
    , BM4_DONE
    , BM8_STAGE_4_DONE
    , BM8_STAGE_5_DONE
    , BM8_STAGE_6_DONE
    } RG_STAGE deriving (Bits, Eq, FShow);

typedef struct {
    Vector#(8, Bit#(WordLength)) in; 
} BM8 deriving (Bits, Eq, FShow);


typedef BM4_inputs PIPE_BM4;
typedef BM8_inputs PIPE_BM8;


endpackage