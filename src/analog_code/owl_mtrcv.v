`timescale 1ns/1ns

module owl_mtrcv
//////////////////////////////////////////////////////////////////////////////
#(
  parameter   CNT_WIDTH     = 8    //计数器宽度，Fsys/Fbit_low，由系统时钟频率与最低通信速率比决定。
                                    //7   @ 2MHz sysclk， 10KHz bit clk,  200
                                    //8   @ 4MHz sysclk,  10KHz bit clk,  400
                                    //9   @ 8MHz sysclk,  10KHz bit clk,  800
                                    //10  @ 16MHz sysclk, 10KHz bit clk,  1600
                                    //11  @ 32MHz sysclk, 10KHz bit clk,  3200
                                    //12  @ 64MHz sysclk, 10KHz bit clk,  6400
)
//////////////////////////////////////////////////////////////////////////////
(
  input   wire                    rst       ,
  input   wire                    clk       ,

  input   wire                    owl_di    ,
  output  reg                     owl_do    ,
  output  reg                     owl_oe    ,

  output  wire  [CNT_WIDTH-1:0]   rx_bps    ,
  input   wire  [CNT_WIDTH-1:0]   bps_set   ,
  input   wire                    bsyn_en   ,
  input   wire                    fsyn_en   ,
  input   wire  [7:0]             fsyn_head ,
  input   wire                    owl_rx_en ,
  input   wire                    owl_wctrl ,
  input   wire                    owl_rctrl ,
  input   wire  [7:0]             owl_wdata ,
  output  wire  [7:0]             owl_rdata ,
  output  reg                     owl_wflag ,
  output  reg                     owl_rflag ,
//  output  wire                    owl_rtrun ,
  output  wire                    owl_rxsof ,
  output  reg                     owl_rxeof
);
//////////////////////////////////////////////////////////////////////////////
reg     owl_di_r0;
reg     owl_di_r1;
wire    owl_di_pos;
wire    owl_di_neg;
wire    owl_di_edge;
//reg     owl_di_pos_r0;

always
@(negedge rst or posedge clk)
begin
  if(~rst)
  begin
    owl_di_r0<=1'b0;
    owl_di_r1<=1'b0;
  end
  else
  begin
    owl_di_r0<=owl_di;
    owl_di_r1<=owl_di_r0;
  end
end

assign  owl_di_pos =  owl_di_r0  & ~owl_di_r1;
assign  owl_di_neg = ~owl_di_r0  &  owl_di_r1;
assign  owl_di_edge=  owl_di_pos |  owl_di_neg;

//always
//@(negedge rst or posedge clk)
//begin
//  if(~rst)
//  begin
//    owl_di_pos_r0<=1'b0;
//  end
//  else
//  begin
//    owl_di_pos_r0<=owl_di_pos;
//  end
//end
//-----------------------------------------
reg   [2:0]   pstate,nstate;
localparam    s_owl_idle          = 3'h0;
localparam    s_owl_rx_fsyn       = 3'h1;
localparam    s_owl_rx_data       = 3'h2;
localparam    s_owl_tx_bsyn       = 3'h3;
localparam    s_owl_tx_fsyn       = 3'h4;
localparam    s_owl_tx_data       = 3'h5;
localparam    s_owl_tx_eof        = 3'h6;
localparam    s_owl_tx_stop       = 3'h7;

reg   [CNT_WIDTH-1:0]   clk_cnt;

`define   qbit_width            3
`define   tx_qbit1_ctrl       (qbit_cnt==3'h0)
`define   tx_qbit0_ctrl       (qbit_cnt<=3'h1)
`define   tx_qbit_bit_ctrl    (qbit_cnt==3'h2)
`define   rx_qbit_err_ctrl    (qbit_cnt==3'h4)
reg   [`qbit_width-1:0]       qbit_cnt;

reg   [2:0]             bit_cnt;
wire  [2:0]             bit_cnt_inc;
//reg   [2:0]             byte_cnt;
reg   [7:0]             shift_reg;
reg   [7:0]             owl_buff;
reg                     bit_stream;
reg                     bit_error;
reg   [CNT_WIDTH-1:0]   owl_high_width;
reg   [CNT_WIDTH-1:0]   rx_brate_width;

reg                     owl_oe_w;
reg                     owl_do_w;

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
    s_owl_idle:
      if(owl_di_edge & owl_rx_en)   nstate  = s_owl_rx_fsyn;
      else if(owl_wctrl)
      begin
        if(bsyn_en)                 nstate  = s_owl_tx_bsyn;
        else if(fsyn_en)            nstate  = s_owl_tx_fsyn;
        else                        nstate  = s_owl_tx_data;
      end
    s_owl_rx_fsyn:
      if(bit_error)                 nstate  = s_owl_idle;
      else if(shift_reg==fsyn_head & owl_di_pos)
                                    nstate  = s_owl_rx_data;
    s_owl_rx_data:
      if(bit_error)                 nstate  = s_owl_idle;
      else if(`rx_qbit_err_ctrl)    nstate  = s_owl_idle;

    s_owl_tx_bsyn:
//      if(byte_cnt==bsyn_num & bit_cnt==3'h7 & `tx_qbit_bit_ctrl & clk_cnt==bps_set)
      if(bit_cnt==3'h7 & `tx_qbit_bit_ctrl & clk_cnt==bps_set)
                                    nstate  = s_owl_tx_fsyn;
    s_owl_tx_fsyn:
      if(bit_cnt==3'h7 & `tx_qbit_bit_ctrl & clk_cnt==bps_set)
                                    nstate  = s_owl_tx_data;
    s_owl_tx_data:
      if(bit_cnt==3'h7 & `tx_qbit_bit_ctrl & clk_cnt==bps_set & ~owl_wflag)
                                    nstate  = s_owl_tx_eof;
    s_owl_tx_eof:
      if(bit_cnt==3'h1 & `tx_qbit_bit_ctrl & clk_cnt==bps_set)
                                    nstate  = s_owl_tx_stop;
    s_owl_tx_stop:                  nstate  = s_owl_idle;
//    s_owl_tx_stop:
//      if(bit_cnt==3'h3 & `tx_qbit_bit_ctrl & clk_cnt==bps_set)
//                                    nstate  = s_owl_idle;                                    
//    default:                        nstate  = s_owl_idle;
  endcase
end

always
@(negedge rst or posedge clk)
begin
  if(~rst)
    clk_cnt<={CNT_WIDTH{1'b0}};
  else if(pstate!=nstate)
    clk_cnt<={CNT_WIDTH{1'b0}};
  else if(pstate==s_owl_tx_bsyn | pstate==s_owl_tx_fsyn | pstate==s_owl_tx_data | pstate==s_owl_tx_eof | pstate==s_owl_tx_stop)
  begin
    if(clk_cnt==bps_set)  clk_cnt<={CNT_WIDTH{1'b0}};
    else                  clk_cnt<=clk_cnt+1'b1;
  end
  else if(pstate==s_owl_rx_fsyn)
  begin
    if(owl_di_pos | owl_di_neg)
      clk_cnt<={CNT_WIDTH{1'b0}};
    else if(clk_cnt==rx_brate_width)
      clk_cnt<={CNT_WIDTH{1'b0}};
    else
      clk_cnt<=clk_cnt+1'b1;
  end
  else if(pstate==s_owl_rx_data)
  begin
    if(owl_di_pos | owl_di_neg)
      clk_cnt<={CNT_WIDTH{1'b0}};
    else if(clk_cnt==(rx_brate_width+rx_bps))
      clk_cnt<={CNT_WIDTH{1'b0}};
    else
      clk_cnt<=clk_cnt+1'b1;
  end
end

always
@(negedge rst or posedge clk)
begin
  if(~rst)
    qbit_cnt<={(`qbit_width){1'b0}};
  else if(pstate!=nstate)
    qbit_cnt<={(`qbit_width){1'b0}};
  else if(pstate>=s_owl_rx_fsyn & pstate<s_owl_tx_bsyn)
  begin
    if(owl_di_pos) qbit_cnt<={(`qbit_width){1'b0}};
//    else if(owl_di_neg) qbit_cnt<=2'h1;
    else if(owl_di_neg) qbit_cnt<=qbit_cnt+1'b1;
    else if(clk_cnt>=(rx_brate_width+rx_bps))  qbit_cnt<=qbit_cnt+1'b1;
  end
  else if(pstate==s_owl_tx_bsyn | pstate==s_owl_tx_fsyn | pstate==s_owl_tx_data | pstate==s_owl_tx_eof | pstate==s_owl_tx_stop)
  begin
    if(clk_cnt==bps_set)
    begin
      if(`tx_qbit_bit_ctrl) qbit_cnt<={(`qbit_width){1'b0}};
      else                  qbit_cnt<=qbit_cnt+1'b1;
    end
  end
end


assign  bit_cnt_inc = bit_cnt+1'b1;
always
@(negedge rst or posedge clk)
begin
  if(~rst)
    bit_cnt<=3'h0;
  else if(pstate!=nstate)
    bit_cnt<=3'h0;
  else
  begin
    if(nstate==s_owl_rx_fsyn | nstate==s_owl_rx_data)
    begin
      if(owl_di_pos)  bit_cnt<=bit_cnt_inc;
    end
    else if(nstate==s_owl_tx_bsyn | nstate==s_owl_tx_fsyn | nstate==s_owl_tx_data | pstate==s_owl_tx_eof | pstate==s_owl_tx_stop)
    begin
      if(`tx_qbit_bit_ctrl & clk_cnt==bps_set) bit_cnt<=bit_cnt_inc;
    end
  end
end

//always
//@(negedge rst or posedge clk)
//begin
//  if(~rst)
//    byte_cnt<=3'h0;
//  else if(pstate==s_owl_rx_fsyn)
//    byte_cnt<=3'h0;
//  else if(pstate==s_owl_rx_data)
//  begin
//    if(bit_cnt==3'h7 & owl_di_pos_r0) byte_cnt<=byte_cnt+1'b1;
//  end
//  else if(pstate!=nstate)
//    byte_cnt<=3'h0;
//  else if(bit_cnt==3'h7 & `tx_qbit_bit_ctrl & clk_cnt==bps_set)
//    byte_cnt<=byte_cnt+1'b1;
//end

//assign  owl_rtrun = (pstate!=s_owl_idle);
assign  owl_rxsof = (pstate==s_owl_rx_fsyn & nstate==s_owl_rx_data);

always
@(negedge rst or posedge clk)
begin
  if(~rst)
    owl_rxeof <=  1'b0;
  else if(pstate==s_owl_rx_data & nstate!=pstate)
    owl_rxeof <=  1'b1;
  else
    owl_rxeof <=  1'b0;
end
//-----------------------------------------

always
@(negedge rst or posedge clk)
begin
  if(~rst)
    owl_high_width <={CNT_WIDTH{1'b0}};
  else if(owl_di_neg)
    owl_high_width <=clk_cnt;
end

always
@(*)
begin
  bit_error=1'b0;
  if(pstate==s_owl_rx_fsyn | pstate==s_owl_rx_data)
  begin
    if(owl_di_edge & (clk_cnt<={{(CNT_WIDTH-2){1'b0}},2'h0})) bit_error=1'b1;
    if(& clk_cnt) bit_error=1'b1;
  end
end

always
@(negedge rst or posedge clk)
begin
  if(~rst)
    bit_stream  <=  1'b0;
  else if(owl_di_pos)
  begin
    if     (owl_high_width<clk_cnt) bit_stream<=1'b1;
    else if(clk_cnt<owl_high_width) bit_stream<=1'b0;
  end
end

always
@(negedge rst or posedge clk)
begin
  if(~rst)
    rx_brate_width  <={CNT_WIDTH{1'b0}};
  else if(nstate==s_owl_rx_fsyn)
  begin
    if(owl_di_pos)  rx_brate_width <={CNT_WIDTH{1'b0}};
    else rx_brate_width<=rx_brate_width + 1'b1;
  end
end
//-----------------------------------------

always
@(negedge rst or posedge clk)
begin
  if(~rst)
    shift_reg<=8'hff;
  else
  begin
    case(nstate)
      s_owl_tx_fsyn:
        if(pstate!=s_owl_tx_fsyn)  shift_reg<=fsyn_head;
        else if(`tx_qbit_bit_ctrl & clk_cnt==bps_set)  shift_reg<={shift_reg[6:0],1'b0};
      s_owl_tx_data:
        if(`tx_qbit_bit_ctrl & clk_cnt==bps_set)
        begin
          if(bit_cnt==3'h7 & owl_wflag)
            shift_reg<=owl_buff;
          else
            shift_reg<={shift_reg[6:0],1'b0};
        end

      s_owl_rx_fsyn:
        if(owl_di_pos) shift_reg<={shift_reg[6:0],bit_stream};
      s_owl_rx_data:
        if(owl_di_pos) shift_reg<={shift_reg[6:0],bit_stream};

      default:  shift_reg<=8'h0;
    endcase
  end
end

always
@(negedge rst or posedge clk)
begin
  if(~rst)
    owl_buff<=8'hff;
  else if(nstate==s_owl_idle | nstate==s_owl_tx_bsyn | nstate==s_owl_tx_fsyn | nstate==s_owl_tx_data)
  begin
    if(owl_wctrl) owl_buff<=owl_wdata;
  end
  else if(nstate==s_owl_rx_fsyn | nstate==s_owl_rx_data)
  begin
    if(bit_cnt==3'h7 & ~(| clk_cnt)) owl_buff<=shift_reg;
  end
end

assign  owl_rdata=owl_buff;

always
@(negedge rst or posedge clk)
begin
  if(~rst)
  begin
    owl_rflag<=1'b0;
    owl_wflag<=1'b0;
  end
  else
  begin
    if(owl_rctrl) owl_rflag<=1'b0;

    if(nstate==s_owl_idle | nstate==s_owl_tx_bsyn | nstate==s_owl_tx_fsyn | nstate==s_owl_tx_data)
    begin
      if(nstate==s_owl_tx_data & bit_cnt==3'h7 & `tx_qbit_bit_ctrl & clk_cnt==bps_set) owl_wflag<=1'b0;
    end
    else if(nstate==s_owl_rx_data)
    begin
      if(bit_cnt==3'h7 & qbit_cnt=={(`qbit_width){1'b0}} & ~(| clk_cnt)) owl_rflag<=1'b1;
    end

    if(owl_wctrl) owl_wflag<=1'b1;
  end
end

always
@(*)
begin
  case(pstate)
    s_owl_tx_bsyn: begin owl_oe_w=1'b1;  owl_do_w=(`tx_qbit1_ctrl);end
    s_owl_tx_fsyn: begin owl_oe_w=1'b1;  owl_do_w=(shift_reg[7])?(`tx_qbit1_ctrl):(`tx_qbit0_ctrl);  end
    s_owl_tx_data: begin owl_oe_w=1'b1;  owl_do_w=(shift_reg[7])?(`tx_qbit1_ctrl):(`tx_qbit0_ctrl);  end
    s_owl_tx_eof:  begin owl_oe_w=1'b1;  owl_do_w=(`tx_qbit1_ctrl);end
    default:       begin owl_oe_w=1'b0;  owl_do_w=1'b0;            end
  endcase
end

always
@(negedge rst or posedge clk)
begin
  if(~rst)
  begin
    owl_oe  <=  1'b0;
    owl_do  <=  1'b1;
  end
  else
  begin
    owl_oe  <=  owl_oe_w;
    owl_do  <= ~owl_do_w;
  end
end

assign  rx_bps  = rx_brate_width[CNT_WIDTH-1:1]-rx_brate_width[CNT_WIDTH-1:2]+1'b1;
//-----------------------------------------
endmodule
