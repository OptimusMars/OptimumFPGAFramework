// Earle-latch
module earlel(
  input         d,
  input         enal,
  input         enah,
  output logic  q
);

logic p0, p1, p2;

assign p0 = !(enah && d);
assign p1 = !(d && q);
assign p2 = !(enal && q);
assign q = !(p0 && p1 && p2);
  
endmodule : earlel
