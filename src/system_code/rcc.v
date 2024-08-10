`timescale 1ns/1ns

module  rcc (
  input   wire          rst       ,
  output  wire          sysclk    ,
  output  wire          runclk    ,
//  output  wire          runlclk   ,
//  output  wire          runhclk   ,
  input   wire          run_ctrl  ,
//  input   wire          speed_md  ,
  input   wire          clk_sel   ,
  input   wire          lclk      ,
  input   wire          hclk
);
//---------------------------------
wire  clk_out;
wire  clk_sel_w;
////---------------------------------
//always
//@(negedge rst or posedge lclk)
//begin
//  if(~rst)
//    lclk2 <=  1'b1;
//  else
//    lclk2 <=  ~lclk2;
//end
//---------------------------------
clk_burr2   u_clk_burr(
  .rst      (rst      ),
  .clk0     (lclk     ),
  .clk1     (hclk     ),
  .clk_sel  (clk_sel_w),
  .clk_out  (clk_out  )
);

BUFX1   u_buf0  ( .A(clk_sel),    .Y(clk_sel_w) );
BUFX1   u_buf1  ( .A(clk_out),    .Y(sysclk) );
OR2X1   u_or0   ( .A(~run_ctrl),  .B(clk_out), .Y(runclk));
//OR2X1   u_or1   ( .A(~run_ctrl),  .B(lclk),   .Y(runlclk));
//OR2X1   u_or2   ( .A(speed_md),   .B(hclk),   .Y(runhclk));

//assign  sysclk  = clk_out;
//assign  runclk  = ~run_ctrl | sysclk;
//assign  runlclk = ~run_ctrl | lclk;
//assign  runhclk = speed_md  | hclk;
//---------------------------------
endmodule
