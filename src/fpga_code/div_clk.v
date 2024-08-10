`timescale 1ns/100ps

module  div_clk (
  input   wire  rst,
  input   wire  clk,
  output  wire  hclk,
  output  wire  lclk
);

reg [11:0]count_l;
reg      hclk_r;
always@
(negedge rst or posedge clk)
begin
  if(~rst)
    hclk_r <= 1'b0;
  else 
    hclk_r <= ~hclk_r;  
end

always@
(negedge rst or posedge clk)
begin
  if(~rst)
    count_l <= 8'h00;
  else if(count_l==12'h61a)
  else 
    dount_l <= count_l+1'b1;  
end

assign lclk = (count_l<= 4'h5)? 1'b1: 1'b0;
assign hclk = hclk_r;
endmodule