`timescale 1ns/1ns

module owl_mctrl
//////////////////////////////////////////////////////////////////////////////
#(
  parameter   CNT_WIDTH     = 8     //计数器宽度，Fsys/Fbit_low，由系统时钟频率与最低通信速率比决定。
                                    //7   @ 2MHz sysclk， 10KHz bit clk,  200
                                    //8   @ 4MHz sysclk,  10KHz bit clk,  400
                                    //9   @ 8MHz sysclk,  10KHz bit clk,  800
                                    //10  @ 16MHz sysclk, 10KHz bit clk,  1600
                                    //11  @ 32MHz sysclk, 10KHz bit clk,  3200
                                    //12  @ 64MHz sysclk, 10KHz bit clk,  6400
)
//////////////////////////////////////////////////////////////////////////////
(
  input   wire                    rst         ,
  input   wire                    clk         ,
  inout   wire                    owl_inout   ,  
  input   wire                    sfr_cmd_w   ,
  input   wire  [6:0]             sfr_addrs_w ,
  input   wire  [7:0]             sfr_num_w   ,
  input   wire  [7:0]             sfr_wdata_w ,
  input   wire                    sfr_wen 
);
//-----------------------------------------
localparam    s_owl_idle      = 4'h0;
localparam    s_owl_tx_start  = 4'h1;
localparam    s_owl_tx_addr   = 4'h2;
localparam    s_owl_tx_num    = 4'h3;
localparam    s_owl_ad_wait   = 4'h4;
localparam    s_owl_tx_data   = 4'h5;
localparam    s_owl_tx_wait   = 4'h6;
localparam    s_owl_tx_crc1   = 4'h7;
localparam    s_owl_tx_crc0   = 4'h8;
localparam    s_owl_tx_eof    = 4'h9;
localparam    s_owl_rx_state  = 4'ha;
localparam    s_owl_rx_data   = 4'hb;
localparam    s_owl_rx_crc1   = 4'hc;
localparam    s_owl_rx_crc0   = 4'hd;
localparam    s_owl_rx_eof    = 4'he;
localparam    s_owl_rx_wait   = 4'hf;

wire                    owl_di    ;
wire                    owl_do    ;
wire                    owl_oe    ;
assign owl_inout = (~owl_oe)?   1'bz   :owl_do;//0为数据输入，1为数据输出
assign owl_di    = (~owl_oe)? owl_inout:1'b1  ;    


reg   [3:0]           pstate,nstate;
reg   [CNT_WIDTH-1:0] clk_cnt   ;
reg                   cmd_reg   ;
reg   [7:0]           byte_cnt  ;
reg   [7:0]           state     ;
//-----------------------------------------
wire  [CNT_WIDTH-1:0] rx_bps    ;
wire  [CNT_WIDTH-1:0] bps_set   ;
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
wire                  owl_rxsof ;
wire                  owl_rxeof ;
reg                   crc_clr   ;
reg                   crc_calcu ;
reg   [7:0]           crc_din   ;
wire  [15:0]          crc_dout  ;
wire                  crc_rlt   ;

wire                  owl_di_w  ;
assign  owl_di_w  = ~owl_di;
//------------------------------------------
reg        sfr_cmd    ;
reg [6:0]  sfr_addrs  ;
reg [7:0]  sfr_num    ;
reg [7:0]  sfr_wdata  ;

always
@(negedge rst or posedge clk)
begin
  if(~rst)
    begin
      sfr_cmd   <= 1'b0   ;
      sfr_addrs <= 7'h0   ;
      sfr_num   <= 8'h0   ;
      sfr_wdata <= 8'h0   ;    
    end
  else if(sfr_wen)
    begin
      sfr_cmd   <= sfr_cmd_w   ;
      sfr_addrs <= sfr_addrs_w ;
      sfr_num   <= sfr_num_w   ;
      sfr_wdata <= sfr_wdata_w ;
    end
end
//-----------------------------------------
always
@(negedge rst or posedge clk)
begin
  if(~rst)
    pstate<=s_owl_idle;
  else
    pstate<=nstate;
end

always
@(*)
begin
  nstate  = pstate;
  case(pstate)
    s_owl_idle:     if(sfr_wen)               nstate  = s_owl_tx_start;
                    else if(owl_rxsof)        nstate  = s_owl_rx_state;
    s_owl_tx_start:                           nstate  = s_owl_tx_addr ;
    s_owl_tx_addr:  if(~owl_wflag)
                    begin
                                              nstate  = s_owl_tx_num ;
                    end
    s_owl_tx_num:   if(sfr_cmd)               nstate  = s_owl_ad_wait;
                    else                      nstate  = s_owl_tx_crc1;
    s_owl_ad_wait:  if(~owl_wflag)
                    begin
                                              nstate  = s_owl_tx_data ;
                    end                            
    s_owl_tx_data:                            nstate  = s_owl_tx_wait ;
    s_owl_tx_wait:  if(~owl_wflag)            nstate  = s_owl_tx_crc1 ;
    s_owl_tx_crc1:  if(~owl_wflag)            nstate  = s_owl_tx_crc0 ;
    s_owl_tx_crc0:  if(~owl_wflag)            nstate  = s_owl_tx_eof  ;
    s_owl_tx_eof:   if(owl_rxsof)             nstate  = s_owl_rx_state;
    s_owl_rx_state: if(owl_rflag)             
                    begin
                      if(~sfr_cmd)   nstate  = s_owl_rx_data ;
                      else           nstate  = s_owl_rx_crc1 ;
                    end
    s_owl_rx_data:                            nstate = s_owl_rx_wait;
    s_owl_rx_wait:
                   if(owl_rflag)
                    begin
                      if(byte_cnt==(sfr_num))   nstate  = s_owl_rx_crc1 ;
                      else                           nstate  = s_owl_rx_data ;
                    end
    s_owl_rx_crc1:  if(owl_rflag)            nstate  = s_owl_rx_crc0 ;
    s_owl_rx_crc0:  if(owl_rflag)            nstate  = s_owl_rx_eof  ;
    s_owl_rx_eof:   if(owl_rxeof)            nstate  = s_owl_idle    ;    
  endcase
end

always
@(negedge rst or posedge clk)
begin
  if(~rst)
    clk_cnt<={CNT_WIDTH{1'b0}};
  else if(pstate!=nstate)
    clk_cnt<={CNT_WIDTH{1'b0}};
  else
    clk_cnt<=clk_cnt+1'b1;
end
//-----------------------------------------
always
@(negedge rst or posedge clk)
begin
  if(~rst)
  begin
    cmd_reg     <=  1'b0;
    byte_cnt    <=  8'h0;
    state       <=  8'h0;
  end
  else
  begin
    if(pstate==s_owl_rx_state & pstate!=nstate) state  <= owl_rdata;
    if( pstate==s_owl_rx_data & pstate!=nstate) byte_cnt   <=  byte_cnt+1'b1;
    if( pstate==s_owl_rx_eof  & pstate!=nstate)  byte_cnt   <=  6'h0;
  end
end


assign    bps_set   = 8'h06;
assign    bsyn_en   = 1'b1;
assign    fsyn_en   = 1'b1;
assign    fsyn_head = 8'h1d;
assign    owl_rx_en = 1'b1;

always
@(*)
begin
  owl_wctrl = 1'b0;
  owl_wdata = 8'h0;
  owl_rctrl = 1'b0;
  case(pstate)
    s_owl_rx_state: owl_rctrl = 1'b1;
    s_owl_rx_wait:  owl_rctrl = 1'b1;
    s_owl_rx_crc1:  owl_rctrl = 1'b1;
    s_owl_rx_crc0:  owl_rctrl = 1'b1;
    s_owl_rx_eof:   owl_rctrl = 1'b1;
    s_owl_tx_start: begin owl_wctrl = 1'b1;  owl_wdata = {sfr_cmd,sfr_addrs};     end
    s_owl_tx_num:   begin owl_wctrl = 1'b1;  owl_wdata = sfr_num;                 end
    s_owl_tx_data:  begin owl_wctrl = 1'b1;  owl_wdata = sfr_wdata;               end
    s_owl_tx_crc1:  if(nstate!=s_owl_tx_crc1) begin owl_wctrl = 1'b1; owl_wdata = crc_dout[7:0]; end
    s_owl_tx_crc0:  if(nstate!=s_owl_tx_crc0) begin owl_wctrl = 1'b1; owl_wdata = crc_dout[15:8];  end
    default:        ;
  endcase
end

owl_mtrcv  u_owl(
  .rst        (rst        ),
  .clk        (clk        ),

  .owl_di     (owl_di_w   ),
  .owl_do     (owl_do     ),
  .owl_oe     (owl_oe     ),

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
      s_owl_rx_state:   begin   crc_calcu = 1'b1; crc_din = owl_rdata;  end
      s_owl_rx_wait:    begin   crc_calcu = 1'b1; crc_din = owl_rdata;  end
      s_owl_rx_crc1:    begin   crc_calcu = 1'b1; crc_din = owl_rdata;  end
      s_owl_rx_crc0:    begin   crc_calcu = 1'b1; crc_din = owl_rdata;  end
      s_owl_rx_eof:     begin   crc_clr   = 1'b1;                       end     
      s_owl_tx_start:   begin   crc_calcu = 1'b1; crc_din = owl_wdata;  end
      s_owl_tx_num:     begin   crc_calcu = 1'b1; crc_din = owl_wdata;  end
      s_owl_tx_data:    begin   crc_calcu = 1'b1; crc_din = owl_wdata;  end
      s_owl_tx_eof:     begin   crc_clr   = 1'b1;                       end
    endcase
  end
end

mcrc16   u_mcrc(
  .rst        (rst        ),
  .clk        (clk        ),
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
