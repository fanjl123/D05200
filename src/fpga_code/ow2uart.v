`timescale 1ns/1ns

module uart_ctrl(
  input   wire          rst   ,
  input   wire          clk   ,
  input   wire   [7:0]  state ,  input   wire  state_rctrl ,
  input   wire   [7:0]  rdata1,  input   wire  rdata1_rctrl,
  input   wire   [7:0]  rdata2,  input   wire  rdata2_rctrl,
  
  output  reg           cmd   ,  output  reg   en ,   
  output  reg    [6:0]  adders,
  output  reg    [7:0]  num   ,
  output  reg    [7:0]  wdata ,
  
  input   wire          rxd,
  output  wire          txd  
);
//-----------------------------------------

reg  [3:0] pstate;
reg  [3:0] nstate;

localparam    s_uart_idle      = 4'h0;
localparam    s_uart_tx_start  = 4'h1;
localparam    s_uart_tx_addr   = 4'h2;
localparam    s_uart_tx_num    = 4'h3;
localparam    s_uart_ad_wait   = 4'h4;
localparam    s_uart_tx_data   = 4'h5;
localparam    s_uart_tx_wait   = 4'h6;
localparam    s_uart_tx_crc1   = 4'h7;
localparam    s_uart_tx_crc0   = 4'h8;
localparam    s_uart_tx_eof    = 4'h9;
localparam    s_uart_rx_state  = 4'ha;
localparam    s_uart_rx_data   = 4'hb;
localparam    s_uart_rx_crc1   = 4'hc;
localparam    s_uart_rx_crc0   = 4'hd;
localparam    s_uart_rx_eof    = 4'he;
localparam    s_uart_rx_wait   = 4'hf;

//---------------------------跳变沿检测电路----------------------
reg     uart_di_r0;
reg     uart_di_r1;
wire    uart_di_pos;
wire    uart_di_neg;
wire    uart_di_edge;


always
@(negedge rst or posedge clk)
begin
  if(~rst)
  begin
    uart_di_r0<=1'b0;
    uart_di_r1<=1'b0;
  end
  else
  begin
    uart_di_r0<=owl_di;
    uart_di_r1<=owl_di_r0;
  end
end

assign  uart_di_pos =  uart_di_r0  & ~uart_di_r1;
assign  uart_di_neg = ~uart_di_r0  &  uart_di_r1;
assign  uart_di_edge=  uart_di_pos |  uart_di_neg;

always@
(negedge rst or posedge clk)
begin
  if(~rst)
    pstate <= 4'h00;
  else
    pstate <= nstate;  
end

always@(*)
begin
  natste = pstate;
  case (patate)
    s_uart_idle : 
    
  default;
  endcase
end

reg [15:0]  count;


always@
(negedge rst or posedge clk)
begin
  if(~rst)
    count <= 16'h0000;
  else if(pstate!= nstate)
    count <= 16'h0000;
  else
    count <= count+1'b1;  
end


//-----------------------------------------
endmodule
