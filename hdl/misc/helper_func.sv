package helper_func;
  
function int ones_count(longint din, int width);
    int res = 0;
    longint mask = 1;   
    for (int i = 0; i < width; i++) begin 
        res = (mask & din) ? res + 1 : res;
    end
    return res;
endfunction

  
endpackage : helper_func