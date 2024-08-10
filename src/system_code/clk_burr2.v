`timescale 1ns/1ns

module clk_burr2(
  rst,
  clk0,
  clk1,
  clk_sel,
  clk_out
);
input rst,clk0,clk1,clk_sel;
output clk_out;

wire rst,clk0,clk1,clk_sel;
wire clk_out;
//----------------------------------------
wire  sel00,  sel10;
reg   sel01,  sel11;
wire  clk_0,  clk_1;

assign sel00=~clk_sel && ~sel11;
assign sel10= clk_sel && ~sel01;
always
@(negedge rst or negedge clk0)
begin
  if(~rst)
    sel01<=1'b1;
  else
    sel01<=sel00;
end
always
@(negedge rst or negedge clk1)
begin
  if(~rst)
    sel11<=1'b0;
  else
    sel11<=sel10;
end
assign clk_0=clk0 && sel01;
assign clk_1=clk1 && sel11;
assign clk_out=clk_0 || clk_1;

endmodule
