package cic_pkg;
// Output width calculation
function int cic_output_width (int width_i, int stages, int decimation);
  int width_out;
  width_out = width_i + stages * $clog2(decimation);
  return width_out;
endfunction
  
endpackage : cic_pkg
