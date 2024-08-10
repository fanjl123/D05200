`timescale 1ns/1ns

module  mic_lclk_cnt(
  input   wire          rst,
  input   wire          mic_clk,
  input   wire          tclk,
  output  reg   [15:0]  mic_cnt
);
//-----------------------------
reg   [1:0]   tclk_r;
wire          tclk_pos;
//reg   [11:0]  neg_cnt;
reg   [15:0]  pos_cnt;
//-----------------------------
always
@(negedge rst or posedge mic_clk)
begin
  if(~rst)
    tclk_r<=2'b0;
  else
    tclk_r<={tclk_r[0],tclk};
end

assign  tclk_pos  = ~tclk_r[1] & tclk_r[0];

always
@(negedge rst or posedge mic_clk)
begin
  if(~rst)
    pos_cnt<=16'h0;
  else if(tclk_pos)
    pos_cnt<=16'h0;
  else
    pos_cnt<=pos_cnt+1'b1;
end

always
@(negedge rst or posedge mic_clk)
begin
  if(~rst)
    mic_cnt<=16'h0;
  else if(tclk_pos)
    mic_cnt<=pos_cnt;
end

endmodule
