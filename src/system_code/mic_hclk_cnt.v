`timescale 1ns/1ns

module  mic_hclk_cnt(
  input   wire          rst,
  input   wire          clk,
  input   wire          speed_md,
  input   wire          mic_clk,
  output  wire          mic_clk_pos,
  output  reg   [15:0]  mic_cnt
);
//-----------------------------
reg   [1:0]   mic_clk_r;
reg   [15:0]  cycle_cnt;
//-----------------------------
always
@(negedge rst or posedge clk)
begin
  if(~rst)
    mic_clk_r<=2'b0;
  else if(~speed_md)
    mic_clk_r<={mic_clk_r[0],mic_clk};
end

assign  mic_clk_pos  = ~mic_clk_r[1] & mic_clk_r[0];

always
@(negedge rst or posedge clk)
begin
  if(~rst)
    cycle_cnt<=16'h0;
  else if(~speed_md)
  begin
    if(mic_clk_pos)
      cycle_cnt<=16'h0;
    else
      cycle_cnt<=cycle_cnt+1'b1;
  end
end

always
@(negedge rst or posedge clk)
begin
  if(~rst)
    mic_cnt<=16'h0;
  else if(~speed_md)
  begin
    if(mic_clk_pos)
      mic_cnt<=cycle_cnt;
  end
end

endmodule
