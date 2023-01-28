`define reverse_vector_func(post, width) \
    function logic [width-1:0] reverse_vector_`post(input logic [width-1:0] din);  \
        logic [width-1:0] ret = '0;        \
        for (int i = 0; i < width; i++) begin  \
            ret[i] = din[width-1-i];   \   
        end \
        return ret; \
    endfunction \