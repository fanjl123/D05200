`timescale 1ns/1ns

module tim1ms(
  input   wire      rst,
  input   wire      lclk,
  input   wire      clk,
  output  wire      tclk32ms,
  output  wire      tclk32ms_neg,
  output  wire      tclk1ms_h,
  output  wire      tclk1ms_pos
);
//----------------------------
reg   [4:0]   count1ms;
reg   [4:0]   count32ms;
reg           tclk1ms_r0;
reg           tclk1ms_r1;
reg           tclk32ms_r0;
reg           tclk32ms_r1;
wire          tclk1ms;

always
@(negedge rst or posedge lclk)
begin
  if(~rst)
    count1ms<=5'h0;
  else
    count1ms<=count1ms+1'b1;
end

assign  tclk1ms_h= count1ms[4];
assign  tclk1ms  = & count1ms;

always
@(negedge rst or posedge lclk)
begin
  if(~rst)
    count32ms<=5'h0;
  else if(tclk1ms)
    count32ms<=count32ms+1'b1;
end

assign  tclk32ms      = & count32ms;
//----------------------------
always
@(negedge rst or posedge clk)
begin
  if(~rst)
  begin
    tclk1ms_r0 <=  1'b0;
    tclk1ms_r1 <=  1'b0;
    tclk32ms_r0<=  1'b0;
    tclk32ms_r1<=  1'b0;

  end
  else
  begin
    tclk1ms_r0 <=  tclk1ms;
    tclk1ms_r1 <=  tclk1ms_r0;
    tclk32ms_r0<=  tclk32ms;
    tclk32ms_r1<=  tclk32ms_r0;
  end
end

assign  tclk1ms_pos  =  tclk1ms_r0  & ~tclk1ms_r1;
assign  tclk32ms_neg  = ~tclk32ms_r0 & tclk32ms_r1;
//----------------------------
endmodule
