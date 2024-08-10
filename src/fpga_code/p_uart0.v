////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

module uart0
(
  input   wire            rst,
  input   wire            clk,

  output  wire  [7:0]     scon,       input   wire  scon_wctrl,
  output  wire  [7:0]     smd0,       input   wire  smd0_wctrl,
  output  wire  [7:0]     smd1,       input   wire  smd1_wctrl,
  output  wire  [7:0]     spls,       input   wire  spls_wctrl,
  output  wire  [7:0]     sccl,       input   wire  sccl_wctrl,
  output  wire  [7:0]     sbuf,       input   wire  sbuf_wctrl,   input   wire    sbuf_rctrl,

  input   wire    [7:0]   sfr_wdata,

  output  wire            txd,
  input   wire            rxd
);
//--------------------------------------
//reg   [3:0]   stpoe;
//reg   [3:0]   stpen;

//wire          uart_int;



reg         rxen;
reg         chkerr;
reg         txbit8;
reg         rxbit8;
reg         txflag;
reg         rxflag;
reg         txbempty;
reg         rxbfull;

//reg         bit_mode;
reg         stopsel;
reg         chken;
reg         chksel;
reg         tx_vsel;
reg         rx_vsel;
reg         idle_vsel;
reg         uarten;

//reg         pwmen;     //？
reg         txf_ie;
reg         rxf_ie;
reg         txbe_ie;
reg         rxbf_ie;

//reg   [1:0] txpctrl;
//reg   [1:0] rxpctrl;
reg   [3:0] tcs;

reg         tim_clk;

reg   [7:0] sccl_reg; //？
reg   [7:0] tclk_cnt;
reg   [7:0] spls_reg; //？

wire        tx_start;
wire        rx_start;
reg         tx_clk;
reg         rx_clk;

reg         txd_reg;
reg         rxd_reg;
wire        rxd_neg;
wire        rxd_pos;
wire        rxd_wire;
reg   [7:0] sbuf_rd_reg;
reg   [7:0] sbuf_wr_reg;
reg   [8:0] tx_shift;
reg   [8:0] rx_shift;
reg   [4:0] tx_pstate,tx_nstate;
reg   [4:0] rx_pstate,rx_nstate;
wire        tx_chkbit;
wire        rx_chkbit;


assign  scon={rxen,chkerr,txbit8,rxbit8,txflag,rxflag,txbempty,rxbfull};
assign  smd0={stopsel,chken,chksel,tx_vsel,rx_vsel,idle_vsel,uarten};
assign  smd1={txf_ie,rxf_ie,txbe_ie,rxbf_ie,tcs};
assign  spls=spls_reg;
assign  sccl=sccl_reg;
assign  sbuf=sbuf_rd_reg;

assign  txd    = (uarten)?txd_reg:rxd_reg;
//assign  uart_int= (txf_ie & txflag) | (rxf_ie & rxflag) | (txbe_ie & txbempty) | (rxbf_ie & rxbfull);


//----------------------------------------tclkdiv---------------------------------------------------
wire  [14:0] tclk;
reg	  [14:0] tclk_reg0;
reg	  [14:0] tclk_reg1;

always
@(negedge rst or posedge clk)
begin
	if(~rst)
	begin
		tclk_reg0<=15'h0;
		tclk_reg1<=15'h0;
  end
	else if(uarten)
	begin
		tclk_reg0<=tclk_reg0+1'b1;
		tclk_reg1<=tclk_reg0;
  end
end

assign tclk = tclk_reg0 & ~tclk_reg1;


//---------------------------------------------------------------------------------------------------
//port control
always
@(negedge rst or posedge clk)
begin
  if(~rst)
    rxd_reg<=1'h1;
  else if(uarten)
    rxd_reg<=rxd;
end

assign rxd_neg=~rxd &  rxd_reg;
assign rxd_pos= rxd & ~rxd_reg;

/*
always
@(*)
begin
  rxd=1'b1;
  stpto=4'b0;
  stpoe=4'b0;
  stpen=4'h0;
  if(uarten)    //UART
  begin
    casex({txpctrl,rxpctrl})
    4'h0:  begin rxd=tx_start | stpti[0];   stpto[0]=txd; stpen[0]=1'b1; stpen[0]=1'b1;  stpoe[0]=tx_start; end    //UART半双工    TXD:STPTO[0]    RXD:STPTI[0]
    4'h1:  begin rxd=stpti[1];              stpto[0]=txd; stpen[1]=1'b1; stpen[0]=1'b1;  stpoe[0]=1'b1;     end    //UART全双工    TXD:STPTO[0]    RXD:STPTI[1]
    4'h2:  begin rxd=stpti[2];              stpto[0]=txd; stpen[2]=1'b1; stpen[0]=1'b1;  stpoe[0]=1'b1;     end    //UART全双工    TXD:STPTO[0]    RXD:STPTI[2]
    4'h3:  begin rxd=stpti[3];              stpto[0]=txd; stpen[3]=1'b1; stpen[0]=1'b1;  stpoe[0]=1'b1;     end    //UART全双工    TXD:STPTO[0]    RXD:STPTI[3]
    4'h4:  begin rxd=stpti[0];              stpto[1]=txd; stpen[0]=1'b1; stpen[1]=1'b1;  stpoe[1]=1'b1;     end    //UART全双工    TXD:STPTO[1]    RXD:STPTI[0]
    4'h5:  begin rxd=tx_start | stpti[1];   stpto[1]=txd; stpen[1]=1'b1; stpen[1]=1'b1;  stpoe[1]=tx_start; end    //UART半双工    TXD:STPTO[1]    RXD:STPTI[1]
    4'h6:  begin rxd=stpti[2];              stpto[1]=txd; stpen[2]=1'b1; stpen[1]=1'b1;  stpoe[1]=1'b1;     end    //UART全双工    TXD:STPTO[1]    RXD:STPTI[2]
    4'h7:  begin rxd=stpti[3];              stpto[1]=txd; stpen[3]=1'b1; stpen[1]=1'b1;  stpoe[1]=1'b1;     end    //UART全双工    TXD:STPTO[1]    RXD:STPTI[3]
    4'h8:  begin rxd=stpti[0];              stpto[2]=txd; stpen[0]=1'b1; stpen[2]=1'b1;  stpoe[2]=1'b1;     end    //UART全双工    TXD:STPTO[2]    RXD:STPTI[0]
    4'h9:  begin rxd=stpti[1];              stpto[2]=txd; stpen[1]=1'b1; stpen[2]=1'b1;  stpoe[2]=1'b1;     end    //UART全双工    TXD:STPTO[2]    RXD:STPTI[1]
    4'ha:  begin rxd=tx_start | stpti[2];   stpto[2]=txd; stpen[2]=1'b1; stpen[2]=1'b1;  stpoe[2]=tx_start; end    //UART半双工    TXD:STPTO[2]    RXD:STPTI[2]
    4'hb:  begin rxd=stpti[3];              stpto[2]=txd; stpen[3]=1'b1; stpen[2]=1'b1;  stpoe[2]=1'b1;     end    //UART全双工    TXD:STPTO[2]    RXD:STPTI[3]
    4'hc:  begin rxd=stpti[0];              stpto[3]=txd; stpen[0]=1'b1; stpen[3]=1'b1;  stpoe[3]=1'b1;     end    //UART全双工    TXD:STPTO[3]    RXD:STPTI[0]
    4'hd:  begin rxd=stpti[1];              stpto[3]=txd; stpen[1]=1'b1; stpen[3]=1'b1;  stpoe[3]=1'b1;     end    //UART全双工    TXD:STPTO[3]    RXD:STPTI[1]
    4'he:  begin rxd=stpti[2];              stpto[3]=txd; stpen[2]=1'b1; stpen[3]=1'b1;  stpoe[3]=1'b1;     end    //UART全双工    TXD:STPTO[3]    RXD:STPTI[2]
    4'hf:  begin rxd=tx_start | stpti[3];   stpto[3]=txd; stpen[3]=1'b1; stpen[3]=1'b1;  stpoe[3]=tx_start; end    //UART半双工    TXD:STPTO[3]    RXD:STPTI[3]
    endcase
  end
  else if(pwmen)    //pwm
  begin
    if(rxpctrl[0])  begin stpto[0]=txd; stpen[0]=1'b1;  stpoe[0]=1'b1;  end
    if(rxpctrl[1])  begin stpto[1]=txd; stpen[1]=1'b1;  stpoe[1]=1'b1;  end
    if(txpctrl[0])  begin stpto[2]=txd; stpen[2]=1'b1;  stpoe[2]=1'b1;  end
    if(txpctrl[1])  begin stpto[3]=txd; stpen[3]=1'b1;  stpoe[3]=1'b1;  end
  end
end
*/

//-----------------------------------------
//tx
always
@(negedge rst or posedge clk)
begin
  if(~rst)
    tx_pstate<=5'h0;
  else if(~uarten)
    tx_pstate<=5'h0;
  else
    tx_pstate<=tx_nstate;
end
always
@(*)
begin
  case(tx_pstate)
  5'h00:  if(~txflag)
            tx_nstate=tx_pstate+1'b1;
          else
            tx_nstate=tx_pstate;
  5'h01:  tx_nstate=tx_pstate+1'b1;

  5'h15:  if(tx_clk)
          begin
            if(~stopsel)
              tx_nstate=5'h00;
            else
              tx_nstate=tx_pstate+1'b1;
          end
          else
            tx_nstate=tx_pstate;
  5'h17:  if(tx_clk)
            tx_nstate=5'h00;
          else
            tx_nstate=tx_pstate;

  default:if(tx_clk)
            tx_nstate=tx_pstate+1'b1;
          else
            tx_nstate=tx_pstate;
  endcase
end

always
@(*)
begin
  if(tx_pstate[4:1]==4'h0)
    txd_reg=~idle_vsel;
  else if(tx_pstate[4:1]==4'h1)
    txd_reg=idle_vsel;
  else if(tx_pstate[4:1]==4'ha)
  begin
    txd_reg=~idle_vsel;
  end
  else if(tx_pstate[4:1]==4'hb)
    txd_reg=~idle_vsel;
  else
    txd_reg=tx_vsel ^ tx_shift[0];
end

assign  tx_start  = (tx_pstate!=5'h00);
//always
//@(negedge rst or posedge clk)
//begin
//  if(~rst)
//    tx_start<=1'b0;
//  else if(tx_nstate==5'h00)
//    tx_start<=1'b0;
//  else
//    tx_start<=1'b1;
//end

always
@(negedge rst or posedge clk)
begin
  if(~rst)
    tx_shift<=9'h0;
  else if(~uarten)
    tx_shift<=9'h0;
  else if(tx_nstate==5'h01)
  begin
    if(chken)                                    //校验使能
    begin
      if(chksel)
        tx_shift<={~tx_chkbit,sbuf_wr_reg};      //奇校验
      else
        tx_shift<={tx_chkbit,sbuf_wr_reg};      //偶校验
    end
    else
      tx_shift<={1'b0,sbuf_wr_reg};
  end
  else if(tx_nstate[4:1]>=4'h3 && tx_nstate[0]==1'b0 && tx_clk)
  begin
    tx_shift[7:0]<=tx_shift[8:1];
    tx_shift[8]<=1'b0;
  end
end

assign  tx_chkbit=^ sbuf_wr_reg;
//-----------------------------------------
//rx
always
@(negedge rst or posedge clk)
begin
  if(~rst)
    rx_pstate<=5'h0;
  else if(~uarten | ~rxen)
    rx_pstate<=5'h0;
  else
    rx_pstate<=rx_nstate;
end

always
@(*)
begin
  case(rx_pstate)
  5'h00:  if((~idle_vsel & rxd_neg) | (idle_vsel & rxd_pos))
            rx_nstate=rx_pstate+1'b1;
          else
            rx_nstate=rx_pstate;
  5'h13:  if(rx_clk)
            rx_nstate=5'h00;
          else
            rx_nstate=rx_pstate;
  5'h15:  if(rx_clk)
            rx_nstate=5'h00;
          else
            rx_nstate=rx_pstate;

  default:if(rx_clk)
            rx_nstate=rx_pstate+1'b1;
          else
            rx_nstate=rx_pstate;
  endcase
end

assign  rx_start  = (rx_pstate!=5'h0);
//always
//@(negedge rst or posedge clk)
//begin
//  if(~rst)
//    rx_start<=1'b0;
//  else if(rx_nstate==5'h00)
//    rx_start<=1'b0;
//  else
//    rx_start<=1'b1;
//end

always
@(negedge rst or posedge clk)
begin
  if(~rst)
    rx_shift<=9'h0;
  else if(~uarten | ~rxen)
    rx_shift<=9'h0;
  else if(rx_clk && rx_nstate[0]==1'b0 && rx_nstate!=5'h00)
  begin
    rx_shift[7:0]<=rx_shift[8:1];
    rx_shift[8]<=rxd_wire;
  end
end

assign rxd_wire=rx_vsel ^ rxd;

//-----------------------------------------
//sfr bus
always
@(negedge rst or posedge clk)
begin
  if(~rst)
  begin
    {rxen,chkerr,txbit8,rxbit8,txflag,rxflag,txbempty,rxbfull}<=8'h00;
    {stopsel,chken,chksel,tx_vsel,rx_vsel,idle_vsel,uarten}<=7'h0;
    {txf_ie,rxf_ie,txbe_ie,rxbf_ie,tcs} <=5'h0;
    sbuf_wr_reg <=8'h0;
    sbuf_rd_reg <=8'h0;
  end
  else
  begin
    if(tx_pstate==5'h00 && tx_nstate==5'h01)  txbempty<=1'b1;

		if(scon_wctrl) {rxen,chkerr,txbit8,rxbit8,txflag,rxflag,txbempty,rxbfull}<=sfr_wdata;
    if(smd0_wctrl) {stopsel,chken,chksel,tx_vsel,rx_vsel,idle_vsel,uarten}<=sfr_wdata[6:0];
    if(smd1_wctrl) {txf_ie,rxf_ie,txbe_ie,rxbf_ie,tcs}<=sfr_wdata;


    if(sbuf_rctrl) rxbfull<=1'b0;
    if(rx_pstate!=5'h00 && rx_nstate==5'h00)  rxbfull<=1'b1;

    if(rx_pstate==5'h00 && rx_nstate!=5'h00)  rxflag<=1'b1;
    if(tx_pstate!=5'h00 && tx_nstate==5'h00 & txbempty)  txflag<=1'b1;

    if(sbuf_wctrl)
    begin
      sbuf_wr_reg<=sfr_wdata;
      txbempty<=1'b0;
      txflag<=1'b0;
    end

//    if((~rxbfull || sbuf_rctrl) && rx_pstate!=5'h00 && rx_nstate==5'h00)
    if(rx_pstate!=5'h00 && rx_nstate==5'h00)
    begin
      sbuf_rd_reg<=rx_shift[8:1];

      if( chken)
      begin
        if(chksel)
          chkerr<=~rx_chkbit;
        else
          chkerr<=rx_chkbit;
      end
      else
        chkerr<=1'b0;
    end
  end
end

assign rx_chkbit=^ rx_shift;

//-----------------------------------------

//clk generate
always
@(negedge rst or posedge clk)
begin
  if(~rst)
  begin
    spls_reg    <=8'h0;
    sccl_reg    <=8'h0;
    tclk_cnt    <=8'h0;
  end
  else
  begin
    if(spls_wctrl)  spls_reg  <=sfr_wdata;
    if(sccl_wctrl)  sccl_reg  <=sfr_wdata;

//bit clk generate
    if(uarten)
    begin
      if(~tx_start)
        tclk_cnt<=sccl_reg;
      else if(tim_clk)
      begin
        if(tclk_cnt==8'hff)      // 102400-4000
          tclk_cnt<=sccl_reg;
        else
          tclk_cnt<=tclk_cnt+1'b1;
      end

      if(~rx_start)
        spls_reg<=sccl_reg;
      else if(tim_clk)
      begin
        if(spls_reg==8'hff)
          spls_reg<=sccl_reg;
        else
          spls_reg<=spls_reg+1'b1;
      end
    end
  end
end

always
@(*)
begin
  tx_clk  = 1'b0;
  rx_clk  = 1'b0;
  if(uarten)
  begin
    if(tx_start & tim_clk & tclk_cnt==8'hff) tx_clk=1'b1;
    if(rx_start & tim_clk & spls_reg==8'hff) rx_clk=1'b1;
  end
end

always
@(*)
begin
  case(tcs)
  4'h0: tim_clk=1'b1;
  4'h1: tim_clk=tclk[0];
  4'h2: tim_clk=tclk[1];
  4'h3: tim_clk=tclk[2];
  4'h4: tim_clk=tclk[3];
  4'h5: tim_clk=tclk[4];
  4'h6: tim_clk=tclk[5];
  4'h7: tim_clk=tclk[6];
  4'h8: tim_clk=tclk[7];
  4'h9: tim_clk=tclk[8];
  4'ha: tim_clk=tclk[9];
  4'hb: tim_clk=tclk[10];
  4'hc: tim_clk=tclk[11];
  4'hd: tim_clk=tclk[12];
  4'he: tim_clk=tclk[13];
  4'hf: tim_clk=tclk[14];
  endcase
end
//----------------------------------------

endmodule