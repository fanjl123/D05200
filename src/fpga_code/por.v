`timescale 1ns/100ps

module  por (
  input   wire  rst     , 
  output  wire  reset     
);

assign reset = ~rst;
endmodule