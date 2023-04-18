`ifndef __MACRO__
`define __MACRO__

`define GET_FIELD_OFFSET(struct_name, field_name, bit_offset)\
struct_name = '0;\
struct_name.field_name = '1;\
for (integer i = 0; i < $bits(struct_name); i=i+1) begin\
    if (struct_name[i] == 1) begin\
        $display("%s offset=%4d", `"field_name`", i);\
        bit_offset = i;\
        break;\
    end\
end

`define STRINGIFY(x) `"x`"

`define REVERSE_VECTOR_FUNC(post, width) \
function logic [width-1:0] reverse_vector_`post(logic [width-1:0] din);  \
    logic [width-1:0] ret = '0;        \
    for (int i = 0; i < width; i++) begin  \
        ret[i] = din[width-1-i];   \   
    end \
    return ret; \
endfunction

`define REVERSE_BYTES_FUNC(post, width) \
function logic [width-1:0] reverse_bytes_`post(logic [width-1:0] din);  \
    logic [width-1:0] ret = '0;        \
    int bytes = width/8;    \
    for (int i = 0; i < bytes; i++) begin  \
        ret[8*(bytes-i-1) +:8] = din[8*i +:8];   \   
    end \
    return ret; \
endfunction

`define MAX(FIRST, SECOND) (((FIRST) > (SECOND)) ? (FIRST) : (SECOND))
`define MIN(FIRST, SECOND) (((FIRST) > (SECOND)) ? (SECOND) : (FIRST))

`define ALIGNED(THIS, ALIGNEL_TO) ((((THIS) % (ALIGNEL_TO)) == 0) ? 1 : 0)

// In Range Strict, 
`define IN_RNG_SN(ITEM, LEFT, RIGHT) (((ITEM) > (LEFT)) && ((ITEM) <= (RIGHT)))
`define IN_RNG_SS(ITEM, LEFT, RIGHT) (((ITEM) > (LEFT)) && ((ITEM) < (RIGHT)))
`define IN_RNG_NS(ITEM, LEFT, RIGHT) (((ITEM) >= (LEFT)) && ((ITEM) < (RIGHT)))
`define IN_RNG_NN(ITEM, LEFT, RIGHT) (((ITEM) >= (LEFT)) && ((ITEM) <= (RIGHT)))

`define DECLARE_STATE_TRANS(TYPE, INPUTS) \
typedef struct packed { \
    logic        [INPUTS-1:0] sige; \
    byte         [INPUTS-1:0] prio; \
    TYPE         [INPUTS-1:0] next; \
} fsm_tr_`TYPE

`define CREATE_TBL(TYPE) fsm_tr_`TYPE tbl

`define DECLARE_TABLE(TYPE, STATES) \
typedef struct packed { \
    fsm_tr_`TYPE [STATES-1:0] trans; \
} state_table_t

`define FLOOR(x) ((rtoi(x) > x) ? rtoi(x) - 1 : rtoi(x))

`endif

