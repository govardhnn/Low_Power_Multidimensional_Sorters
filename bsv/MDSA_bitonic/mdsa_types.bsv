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

typedef Vector#(8, Vector#(8, Bit#(WordLength))) MDSA_64;

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

typedef enum {
    IDLE 
    , STAGE_1_IN
    , STAGE_1_OUT
    , STAGE_2_IN
    , STAGE_2_OUT
    , STAGE_3_IN
    , STAGE_3_OUT   
    , STAGE_4_IN
    , STAGE_4_OUT
    , STAGE_5_IN
    , STAGE_5_OUT
    , STAGE_6_IN
    , STAGE_6_OUT
    , MDSA_DONE
    } MDSA_FSM deriving (Bits, Eq, FShow);

typedef enum {
    IDLE
    , WAIT_FOR_OUTPUT
} MDSA_TB_STAGE;

typedef struct {
    Vector#(8, Bit#(WordLength)) in; 
} BM8 deriving (Bits, Eq, FShow);

typedef BM4_inputs PIPE_BM4;

typedef BM8_inputs PIPE_BM8;


endpackage