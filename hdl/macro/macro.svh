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
function logic [width-1:0] reverse_vector_`post(input logic [width-1:0] din);  \
    logic [width-1:0] ret = '0;        \
    for (int i = 0; i < width; i++) begin  \
        ret[i] = din[width-1-i];   \   
    end \
    return ret; \
endfunction

`define MAX(FIRST, SECOND) (((FIRST) > (SECOND)) ? (FIRST) : (SECOND))
`define MIN(FIRST, SECOND) (((FIRST) > (SECOND)) ? (SECOND) : (FIRST))