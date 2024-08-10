`timescale 1ns/1ns

module owl_ctrl
//////////////////////////////////////////////////////////////////////////////
#(
  parameter   CNT_WIDTH     = 12     //计数器宽度，Fsys/Fbit_low，由系统时钟频率与最低通信速率比决定。
                                    //7   @ 2MHz sysclk， 10KHz bit clk,  200
                                    //8   @ 4MHz sysclk,  10KHz bit clk,  400
                                    //9   @ 8MHz sysclk,  10KHz bit clk,  800
                                    //10  @ 16MHz sysclk, 10KHz bit clk,  1600
                                    //11  @ 32MHz sysclk, 10KHz bit clk,  3200
                                    //12  @ 64MHz sysclk, 10KHz bit clk,  6400
)
//////////////////////////////////////////////////////////////////////////////
(
  input   wire          rst         ,
  input   wire          clk         ,
//  input   wire          run_ctrl    ,
  input   wire          clk_sel     ,

  input   wire          owl_di_w    ,
  output  wire          owl_do_w    ,
  output  wire          owl_oe_w    ,

//  output  reg           rxcrc_err   ,
//  output  reg           rxcmd_err   ,
//  output  reg           rxbit_err   ,
//  output  reg           rxovf_err   ,

  input   wire          sfr_ready   ,
  input   wire  [7:0]   sfr_rdata   ,
  output  reg   [7:0]   sfr_wdata   ,
  output  reg   [5:0]   sfr_addrs   ,
  output  reg           sfr_rctrl   ,
  output  reg           sfr_wctrl
);
//-----------------------------------------
localparam    s_owl_idle      = 4'h0;
localparam    s_owl_rx_cmd    = 4'h1;
localparam    s_owl_rx_size   = 4'h2;
localparam    s_owl_rx_data   = 4'h3;
//localparam    s_owl_rx_wait   = 4'h4;
localparam    s_owl_rx_crc1   = 4'h4;
localparam    s_owl_rx_crc0   = 4'h5;
localparam    s_owl_rx_eof    = 4'h6;
localparam    s_owl_rx2tx     = 4'h7;
localparam    s_owl_tx_start  = 4'h8;
localparam    s_owl_tx_fsyn   = 4'h9;
localparam    s_owl_tx_data   = 4'ha;
localparam    s_owl_tx_wait   = 4'hb;
localparam    s_owl_tx_crc1   = 4'hc;
localparam    s_owl_tx_crc0   = 4'hd;
localparam    s_owl_tx_eof    = 4'he;
localparam    s_owl_rx_ovf    = 4'hf;

reg   [3:0]           pstate,nstate;
reg   [CNT_WIDTH-1:0] clk_cnt   ;
reg                   cmd_reg   ;
reg   [5:0]           addr_reg  ;
reg   [5:0]           size_reg  ;
reg   [5:0]           byte_cnt  ;
reg   [7:0]           wdata_reg ;
//-----------------------------------------
wire  [CNT_WIDTH-1:0] rx_bps    ;
reg   [CNT_WIDTH-1:0] bps_set   ;
wire                  bsyn_en   ;
wire                  fsyn_en   ;
wire  [7:0]           fsyn_head ;
wire                  owl_rx_en ;
reg                   owl_wctrl ;
reg                   owl_rctrl ;
reg   [7:0]           owl_wdata ;
wire  [7:0]           owl_rdata ;
wire                  owl_wflag ;
wire                  owl_rflag ;
//wire                  owl_rtrun ;
wire                  owl_bterr ;
wire                  owl_rxsof ;
wire                  owl_rxeof ;

reg                   crc_clr   ;
reg                   crc_calcu ;
reg   [7:0]           crc_din   ;
wire  [15:0]          crc_dout  ;
wire                  crc_rlt   ;

reg                   rxcrc_err ;
reg                   rxcmd_err ;
reg                   rxbit_err ;
reg                   rxovf_err ;
//-----------------------------------------
always
@(negedge rst or posedge clk)
begin
  if(~rst)
    pstate<=s_owl_idle;
  else //if(run_ctrl)
    pstate<=nstate;
end

always
@(*)
begin
  nstate  = pstate;
  case(pstate)
    s_owl_idle:     if(owl_rxsof)             nstate  = s_owl_rx_cmd  ;
    s_owl_rx_cmd:   if(& clk_cnt)             nstate  = s_owl_rx_ovf  ;
                    else if(owl_rflag)        nstate  = s_owl_rx_size ;
    s_owl_rx_size:  if(& clk_cnt)             nstate  = s_owl_rx_ovf  ;
                    else if(owl_rflag)
                    begin
                      if(cmd_reg)             nstate  = s_owl_rx_data ;
                      else                    nstate  = s_owl_rx_crc1 ;
                    end
    s_owl_rx_data:  if(& clk_cnt)             nstate  = s_owl_rx_ovf  ;
                    else if(owl_rflag)        nstate  = s_owl_rx_crc1 ;
//    s_owl_rx_wait:  if(byte_cnt==size_reg)    nstate  = s_owl_rx_crc1 ;
//                    else                      nstate  = s_owl_rx_data ;
    s_owl_rx_crc1:  if(& clk_cnt)             nstate  = s_owl_rx_ovf  ;
                    else if(owl_rflag)        nstate  = s_owl_rx_crc0 ;
    s_owl_rx_crc0:  if(& clk_cnt)             nstate  = s_owl_rx_ovf  ;
                    else if(owl_rflag)        nstate  = s_owl_rx_eof  ;
    s_owl_rx_eof:   if(& clk_cnt)             nstate  = s_owl_rx_ovf  ;
                    else if(owl_rxeof)        nstate  = s_owl_rx2tx   ;
    s_owl_rx_ovf:   if(clk_cnt==rx_bps)       nstate  = s_owl_rx2tx   ;
    s_owl_rx2tx:    if(rxcrc_err | rxcmd_err | rxbit_err | rxovf_err)
                                              nstate  = s_owl_idle;
                    else if(clk_cnt==rx_bps)  nstate  = s_owl_tx_start;
    s_owl_tx_start: if(sfr_ready)             nstate  = s_owl_tx_fsyn ;
    s_owl_tx_fsyn:  if(~owl_wflag)
                    begin
                      if(cmd_reg)             nstate  = s_owl_tx_crc1 ;
                      else                    nstate  = s_owl_tx_data ;
                    end
    s_owl_tx_data:                            nstate  = s_owl_tx_wait ;
    s_owl_tx_wait:  if(~owl_wflag)
                    begin
                      if(byte_cnt==size_reg)  nstate  = s_owl_tx_crc1 ;
                      else                    nstate  = s_owl_tx_data ;
                    end
    s_owl_tx_crc1:  if(~owl_wflag)            nstate  = s_owl_tx_crc0 ;
    s_owl_tx_crc0:  if(~owl_wflag)            nstate  = s_owl_tx_eof  ;
    s_owl_tx_eof:   if(clk_cnt==12'h010)      nstate  = s_owl_idle    ;
  endcase
end

always
@(negedge rst or posedge clk)
begin
  if(~rst)
    clk_cnt<={CNT_WIDTH{1'b0}};
  else //if(run_ctrl)
  begin
    if(pstate!=nstate)
      clk_cnt<={CNT_WIDTH{1'b0}};
    else
      clk_cnt<=clk_cnt+1'b1;
  end
end

always
@(negedge rst or posedge clk)
begin
  if(~rst)
  begin
    rxcrc_err <=  1'b0;
    rxcmd_err <=  1'b0;
    rxbit_err <=  1'b0;
    rxovf_err <=  1'b0;
  end
  else //if(run_ctrl)
  begin
    if(pstate==s_owl_rx_eof & clk_cnt=={CNT_WIDTH{1'b0}}) rxcrc_err <=  ~crc_rlt;
    if(pstate==s_owl_rx_ovf)  rxovf_err <=  1'b1;
    if(owl_bterr)             rxbit_err <=  1'b1;

    if(pstate==s_owl_tx_eof | pstate==s_owl_idle)
    begin
      rxbit_err <=  1'b0;
      rxovf_err <=  1'b0;
      rxcrc_err <=  1'b0;
    end
  end
end
//-----------------------------------------
always
@(negedge rst or posedge clk)
begin
  if(~rst)
  begin
    cmd_reg     <=  1'b0;
    addr_reg    <=  6'h0;
    size_reg    <=  6'h0;
    byte_cnt    <=  6'h0;
    wdata_reg   <=  8'h0;
  end
  else //if(run_ctrl)
  begin
    if(pstate==s_owl_rx_cmd   & pstate!=nstate) {cmd_reg,addr_reg}  <=  {owl_rdata[7],owl_rdata[5:0]};
    if(pstate==s_owl_rx_size  & pstate!=nstate) size_reg            <=  owl_rdata[5:0];
    if(pstate==s_owl_rx_data  & pstate!=nstate) wdata_reg           <=  owl_rdata;
//    if(pstate==s_owl_rx_wait  & pstate!=nstate)
//    begin
//                                                byte_cnt            <=  byte_cnt+1'b1;
//                                                addr_reg            <=  addr_reg+1'b1;
//    end
    if(pstate==s_owl_rx_eof   & pstate!=nstate) byte_cnt            <=  6'h0;
    if(pstate==s_owl_tx_data  & pstate!=nstate)
    begin
                                                byte_cnt            <=  byte_cnt+1'b1;
                                                addr_reg            <=  addr_reg+1'b1;
    end
    if(pstate==s_owl_tx_eof   & pstate!=nstate)
    begin                                       cmd_reg             <=  1'b0;
                                                addr_reg            <=  6'h0;
                                                size_reg            <=  6'h0;
                                                byte_cnt            <=  6'h0;
    end
  end
end

always
@(*)
begin
  sfr_addrs = addr_reg;
  sfr_wdata = wdata_reg;
  sfr_wctrl = 1'b0;
  sfr_rctrl = ~cmd_reg;
  if(pstate==s_owl_rx_eof & ~(| clk_cnt))  sfr_wctrl = (crc_rlt & cmd_reg);

end
//---------------------------------
assign    bsyn_en   = 1'b1;
assign    fsyn_en   = 1'b1;
assign    fsyn_head = 8'h1d;
assign    owl_rx_en = 1'b1;

always
@(*)
begin
  bps_set   = rx_bps;
  if(clk_sel  & rx_bps<=12'h040)  bps_set = 12'h040;
end

always
@(*)
begin
  owl_wctrl = 1'b0;
  owl_wdata = 8'h0;
  owl_rctrl = 1'b0;
  case(nstate)
    s_owl_rx_size:  owl_rctrl = 1'b1;
    s_owl_rx_data:  owl_rctrl = 1'b1;
    s_owl_rx_crc1:  owl_rctrl = 1'b1;
    s_owl_rx_crc0:  owl_rctrl = 1'b1;
    s_owl_rx_eof:   owl_rctrl = 1'b1;
    s_owl_tx_fsyn:  if(pstate!=nstate) begin owl_wctrl = 1'b1; owl_wdata = {1'b1,rxovf_err,3'h0,rxcrc_err,rxcmd_err,rxbit_err};  end
    s_owl_tx_data:  if(pstate!=nstate) begin owl_wctrl = ~owl_wflag; owl_wdata = sfr_rdata;  end
    s_owl_tx_crc1:  if(pstate!=nstate) begin owl_wctrl = 1'b1; owl_wdata = crc_dout[7:0]; end
    s_owl_tx_crc0:  if(pstate!=nstate) begin owl_wctrl = 1'b1; owl_wdata = crc_dout[15:8];  end
    default:        ;
  endcase
end


//---------------------------------

owl_trcv
#(  .CNT_WIDTH(CNT_WIDTH) )
u_owl(
  .rst        (rst        ),
  .clk        (clk        ),
//  .run_ctrl   (run_ctrl   ),

  .owl_di     (owl_di_w   ),
  .owl_do     (owl_do_w   ),
  .owl_oe     (owl_oe_w   ),

  .rx_bps     (rx_bps     ),
  .bps_set    (bps_set    ),
  .bsyn_en    (bsyn_en    ),
  .fsyn_en    (fsyn_en    ),
  .fsyn_head  (fsyn_head  ),
  .owl_rx_en  (owl_rx_en  ),
  .owl_wctrl  (owl_wctrl  ),
  .owl_rctrl  (owl_rctrl  ),
  .owl_wdata  (owl_wdata  ),
  .owl_rdata  (owl_rdata  ),
  .owl_wflag  (owl_wflag  ),
  .owl_rflag  (owl_rflag  ),
//  .owl_rtrun  (owl_rtrun  ),
  .rxbit_err  (owl_bterr  ),
  .owl_rxsof  (owl_rxsof  ),
  .owl_rxeof  (owl_rxeof  )
);
//-----------------------------------------
always
@(*)
begin
  crc_clr   = 1'b0;
  crc_calcu = 1'b0;
  crc_din   = 8'h0;
  if(pstate!=nstate)
  begin
    case(pstate)
      s_owl_rx_cmd:   begin   crc_calcu = 1'b1; crc_din = owl_rdata;  end
      s_owl_rx_size:  begin   crc_calcu = 1'b1; crc_din = owl_rdata;  end
      s_owl_rx_data:  begin   crc_calcu = 1'b1; crc_din = owl_rdata;  end
      s_owl_rx_crc1:  begin   crc_calcu = 1'b1; crc_din = owl_rdata;  end
      s_owl_rx_crc0:  begin   crc_calcu = 1'b1; crc_din = owl_rdata;  end
      s_owl_rx_eof :  begin   crc_clr   = 1'b1;                       end
      s_owl_tx_start: begin   crc_calcu = 1'b1; crc_din = owl_wdata;  end
//      s_owl_tx_fsyn:  begin                                           end
      s_owl_tx_data:  begin   crc_calcu = 1'b1; crc_din = owl_wdata;  end
      s_owl_tx_eof:   begin   crc_clr   = 1'b1;                       end
    endcase
  end
end

crc16   u_crc(
  .rst        (rst        ),
  .clk        (clk        ),
//  .run_ctrl   (run_ctrl   ),
  .crc_en     (1'b1       ),
  .crc_clr    (crc_clr    ),
  .crc_typ    (1'b1       ),
  .crc_calcu  (crc_calcu  ),
  .crc_din    (crc_din    ),
  .crc_dout   (crc_dout   ),
  .crc_rlt    (crc_rlt    )
);
//-----------------------------------------
endmodule
