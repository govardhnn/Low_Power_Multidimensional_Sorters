package mdsa_types;

import Vector :: *;

// `define WordLength 32
typedef 32 WordLength;

// typedef of CAE inputs
typedef struct {
    Vector#(2, Bit#(WordLength)) inputs;
} CAE deriving (Bits, Eq, FShow);

// typedef of BM4 inputs
typedef struct {
    Vector#(4, Bit#(WordLength)) inputs;
} BM4 deriving (Bits, Eq, FShow);


typedef enum {
    INIT
    , BM4_INPUT
    , BM4_DONE
    , BM8_STAGE_4_DONE
    , BM8_STAGE_5_DONE
    , BM8_STAGE_6_DONE
    } RG_STAGE deriving (Bits, Eq, FShow);

typedef struct {
    Vector#(8, int) in; 
} BM8 deriving (Bits, Eq, FShow);


endpackage