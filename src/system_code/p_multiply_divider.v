////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

//8bit*8bit=16bit
//16bit/8bit=16bit

module mul_divider
(
    input   wire    rst,
    input   wire    clk,
//    input   wire    run_ctrl,

    output  wire    muldiv_int,

//    output  wire  [7:0] muldiv_cn,
                                        input   wire    muldiv_cn_wctrl,
//    output  wire  [7:0] muldiv_ar,
                                        input   wire    muldiv_ar_wctrl,
    output  wire  [7:0] muldiv_br,      input   wire    muldiv_br_wctrl,
    output  wire  [7:0] muldiv_hr,      input   wire    muldiv_hr_wctrl,
    output  wire  [7:0] muldiv_cr,      input   wire    muldiv_cr_wctrl,

    input   wire  [7:0] dbus_wdata
  );
//----------------------------------------
reg           muldiv_run;     //0:  idle          1:  run
reg           muldiv_f;
reg           muldiv_md;      //0:  multiplier    1:  divider
reg   [1:0]   muldiv_sm;      //start mode;   0:  set muldiv_run start
                              //              1:  set muldiv_run start or write bl start
                              //              2:  set muldiv_run start or write al start
                              //              3:  set muldiv_run start or write ah start

reg   [7:0]   ar_reg;
reg   [7:0]   br_reg;
reg   [7:0]   hr_reg;
reg   [7:0]   cr_reg;

reg   [3:0]   cnt_reg;

//wire  [7:0] muldiv_cn;
//wire  [7:0] muldiv_ar;

//assign  muldiv_cn   ={1'b0,muldiv_f,muldiv_run,1'b0,muldiv_md,1'b0,muldiv_sm};
//assign  muldiv_ar   =ar_reg;
assign  muldiv_br   =br_reg;
assign  muldiv_hr   =hr_reg;
assign  muldiv_cr   =cr_reg;

assign  muldiv_int  = muldiv_f;
//-----------------------------------------
wire  [8:0] cr_div={cr_reg,hr_reg[7]}-{1'b0,ar_reg};

always
@(negedge rst or posedge clk)
begin
  if(~rst)
  begin
    {muldiv_f,muldiv_run,muldiv_md,muldiv_sm}<=5'h0;
    ar_reg <=8'h0;
    br_reg <=8'h0;
    hr_reg <=8'h0;
    cr_reg <=8'h0;
    cnt_reg <=4'h0;
  end
  else //if(run_ctrl)
  begin
    if(muldiv_run)
    begin
      if(~muldiv_md)  //multiplier
      begin
        cnt_reg<=cnt_reg+1'b1;
        if(cnt_reg==4'h7) begin muldiv_run<=1'b0; muldiv_f<=1'b1; end
        if(ar_reg[7]) {hr_reg,cr_reg}<={hr_reg[6:0],cr_reg,1'b0}+br_reg;
        else          {hr_reg,cr_reg}<={hr_reg[6:0],cr_reg,1'b0};
        ar_reg<={ar_reg[6:0],ar_reg[7]};
      end
      else            //divider
      begin
        cnt_reg<=cnt_reg+1'b1;
        if({cr_reg,hr_reg[7]}>={1'b0,ar_reg})
        begin
//          cr_reg<={cr_reg,hr_reg[7]}-ar_reg;
          cr_reg<=cr_div[7:0];
          {hr_reg,br_reg}<={hr_reg[6:0],br_reg,1'b1};
        end
        else
        begin
          cr_reg<={cr_reg[6:0],hr_reg[7]};
          {hr_reg,br_reg}<={hr_reg[6:0],br_reg,1'b0};
        end
        if(cnt_reg==4'hf) begin muldiv_run<=1'b0; muldiv_f<=1'b1; end
      end
    end
    else  cnt_reg<=4'h0;

    if(muldiv_cn_wctrl) begin {muldiv_f,muldiv_run,muldiv_md,muldiv_sm}<={dbus_wdata[6:5],dbus_wdata[3],dbus_wdata[1:0]};if(dbus_wdata[5]) cr_reg<=8'h0; end
    if(muldiv_ar_wctrl) begin ar_reg<=dbus_wdata; if(muldiv_sm==2'h1) begin muldiv_f<=1'b0; muldiv_run<=1'b1;   cr_reg<=8'h0;  end  end
    if(muldiv_br_wctrl) begin br_reg<=dbus_wdata; if(muldiv_sm==2'h2) begin muldiv_f<=1'b0; muldiv_run<=1'b1;   cr_reg<=8'h0;  end  end
    if(muldiv_hr_wctrl) begin hr_reg<=dbus_wdata; if(muldiv_sm==2'h3) begin muldiv_f<=1'b0; muldiv_run<=1'b1;   cr_reg<=8'h0;  end  end
    if(muldiv_cr_wctrl)       cr_reg<=dbus_wdata;

  end
end

//----------------------------------------
endmodule