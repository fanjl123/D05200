`timescale 1ns/1ns

module main_ctrl(
  input   wire          reset       ,
  output  reg           reset_en    ,
  output  wire          sysrst      ,
  input   wire          sysclk      ,
  input   wire          clk         ,
  output  wire          clk_sel     ,
  output  reg           run_ctrl    ,
  output  wire          speed_mode  ,
  input   wire          mic_clk     ,
  input   wire          mic_clk_pos ,

  input   wire          lclk        ,
  output  wire  [7:0]   lcfr        ,
  input   wire          hclk        ,
  input   wire          hrdy        ,
  output  wire          henb        ,
  output  wire  [7:0]   hcfr        ,

  input   wire          tclk1ms_h   ,
  input   wire          tclk1ms_pos ,
  input   wire          tclk32ms_neg,
  input   wire  [15:0]  mic_lct     ,
  input   wire  [15:0]  mic_hct     ,

  output  wire          pwm_oen     ,
  output  wire          pwm_mod     ,
  input   wire          pwm_out     ,

  output  wire          owl_di_w    ,
  input   wire          owl_do_w    ,
  input   wire          owl_oe_w    ,

  input   wire          owl_di      ,
  output  reg           owl_ie      ,
  output  reg           owl_do      ,
  output  reg           owl_poe     ,
  output  reg           owl_noe     ,
  output  reg           owl_pu      ,
  output  reg           owl_pd      ,

  input   wire          hl_sel      ,

  output  reg           ts_ie       ,
  output  reg           ts_do       ,
  output  reg           ts_poe      ,
  output  reg           ts_noe      ,
  output  reg           ts_pu       ,
  output  reg           ts_pd       ,

  output  reg           rom_wctrl   ,
  output  reg           rom_rctrl   ,
  output  reg   [6:0]   rom_addrs   ,
  output  reg   [7:0]   rom_wdata   ,
  input   wire  [7:0]   rom_rdata   ,
  input   wire          rom_ready   ,

  input   wire          muldiv_int  ,
                                        output  reg   muldiv_cn_wctrl ,
                                        output  reg   muldiv_ar_wctrl ,
  input   wire  [7:0]   muldiv_br   ,   output  reg   muldiv_br_wctrl ,
  input   wire  [7:0]   muldiv_hr   ,   output  reg   muldiv_hr_wctrl ,
  input   wire  [7:0]   muldiv_cr   ,   output  reg   muldiv_cr_wctrl ,
  output  reg   [7:0]   muldiv_dt   ,

  output  wire  [7:0]   gctrl       ,   input   wire  gctrl_wctrl     ,
  output  wire  [7:0]   gmode       ,   //input   wire  gmode_wctrl     ,
  output  wire  [7:0]   losc_cfr    ,   input   wire  losc_cfr_wctrl  ,
  output  wire  [7:0]   hosc_cfr    ,   input   wire  hosc_cfr_wctrl  ,
  output  reg   [7:0]   pwm_base    ,   input   wire  pwm_base_wctrl  ,
  output  reg   [7:0]   pwm_step    ,   input   wire  pwm_step_wctrl  ,

  output  wire  [7:0]   otp_cn      ,   input   wire  otp_cn_wctrl    ,
  output  wire  [7:0]   otp_dt      ,   input   wire  otp_dt_wctrl    ,
  output  wire  [7:0]   otp_ad      ,   input   wire  otp_ad_wctrl    ,
  output  wire  [7:0]   test_cn     ,   input   wire  test_cn_wctrl   ,

  output  wire  [7:0]   chk_ptcn    ,   input   wire  chk_ptcn_wctrl  ,
  output  wire  [7:0]   chk_cnt0    ,
  output  wire  [7:0]   chk_cnt1    ,
  output  wire  [7:0]   chk_bas0    ,
  output  wire  [7:0]   chk_bas1    ,
  output  wire  [7:0]   chk_sub0    ,
  output  wire  [7:0]   chk_sub1    ,
  output  wire  [7:0]   chk_sector  ,
  output  wire  [7:0]   chk_ptsub   ,
  output  wire  [7:0]   chk_slope   ,
  output  wire  [7:0]   chk_sctsub  ,
  output  reg   [7:0]   chk_ratio   ,
  output  reg   [7:0]   pwm_reg     ,
  output  wire  [7:0]   pwm_width   ,

  output  wire  [7:0]   chk_cn0     ,   input   wire  chk_cn0_wctrl   ,
  output  wire  [7:0]   chk_md0     ,   input   wire  chk_md0_wctrl   ,
  output  wire  [7:0]   chk_md1     ,   input   wire  chk_md1_wctrl   ,
  output  wire  [7:0]   chk_md2     ,   input   wire  chk_md2_wctrl   ,
  output  wire  [7:0]   chk_dbd0    ,   input   wire  chk_dbd0_wctrl  ,
  output  wire  [7:0]   chk_dbd1    ,   input   wire  chk_dbd1_wctrl  ,
  output  wire  [7:0]   point00l    ,   input   wire  point00l_wctrl  ,
  output  wire  [7:0]   point00h    ,   input   wire  point00h_wctrl  ,
  output  wire  [7:0]   point01l    ,   input   wire  point01l_wctrl  ,
  output  wire  [7:0]   point01h    ,   input   wire  point01h_wctrl  ,
  output  wire  [7:0]   point02l    ,   input   wire  point02l_wctrl  ,
  output  wire  [7:0]   point02h    ,   input   wire  point02h_wctrl  ,
  output  wire  [7:0]   point03l    ,   input   wire  point03l_wctrl  ,
  output  wire  [7:0]   point03h    ,   input   wire  point03h_wctrl  ,
  output  wire  [7:0]   point04l    ,   input   wire  point04l_wctrl  ,
  output  wire  [7:0]   point04h    ,   input   wire  point04h_wctrl  ,
  output  wire  [7:0]   point05l    ,   input   wire  point05l_wctrl  ,
  output  wire  [7:0]   point05h    ,   input   wire  point05h_wctrl  ,
  output  wire  [7:0]   point06l    ,   input   wire  point06l_wctrl  ,
  output  wire  [7:0]   point06h    ,   input   wire  point06h_wctrl  ,
  output  wire  [7:0]   point07l    ,   input   wire  point07l_wctrl  ,
  output  wire  [7:0]   point07h    ,   input   wire  point07h_wctrl  ,
  output  wire  [7:0]   point08l    ,   input   wire  point08l_wctrl  ,
  output  wire  [7:0]   point08h    ,   input   wire  point08h_wctrl  ,
  output  wire  [7:0]   point09l    ,   input   wire  point09l_wctrl  ,
  output  wire  [7:0]   point09h    ,   input   wire  point09h_wctrl  ,

  output  wire          sfr_ready   ,
  input   wire  [7:0]   sfr_wdata
);
//------------------------------------
reg           mic_mode    ;
reg           app_mode    ;

//reg   [7:0]   gmode_r     ;
reg   [7:0]   lclk_cfr    ;
reg   [7:0]   hclk_cfr    ;

reg           otp_rd      ;
reg           otp_wr      ;
reg   [5:0]   otp_sct     ;
reg   [6:0]   otp_ad_r    ;
reg   [7:0]   otp_dt_r    ;

reg           test_en     ;
reg           test_auto   ;
reg   [3:0]   test_sel    ;

reg           chk_rst     ;
reg           chk_wctrl   ;
reg   [3:0]   chk_point   ;

wire  [15:0]  chk_cnt_w   ;
reg   [15:0]  chk_bas_r   ;
reg   [15:0]  chk_sub_r   ;
reg   [15:0]  chk_sub_r1  ;

reg   [3:0]   chk_sector_r;
reg   [7:0]   chk_ptsub_r ;
reg   [7:0]   chk_slope_r ;
reg   [7:0]   chk_sctsub_r;
reg   [7:0]   pwm_width_r ;

reg           work_ctrl   ;
reg           out_enb     ;
reg           speed_md    ;
reg   [2:0]   out_mod     ;

reg           threshold_sel0;
reg   [1:0]   threshold_sel1;
reg           hosc_enb    ;
reg           clk_sel_b   ;
reg           clk_sel_r   ;


reg   [3:0]   sector_prc  ;
reg   [3:0]   slope_prc   ;
reg   [3:0]   pwm_prc     ;

reg   [7:0]   chk_dbd_r0  ;
reg   [7:0]   chk_dbd_r1  ;
reg   [15:0]  point00_r   ;
reg   [15:0]  point01_r   ;
reg   [15:0]  point02_r   ;
reg   [15:0]  point03_r   ;
reg   [15:0]  point04_r   ;
reg   [15:0]  point05_r   ;
reg   [15:0]  point06_r   ;
reg   [15:0]  point07_r   ;
reg   [15:0]  point08_r   ;
reg   [15:0]  point09_r   ;

//------------------------------------
wire    por;
reg     por_syn;
wire    rst;

assign  por = ~reset;

always
@(negedge por or posedge lclk)
begin
  if(~por)
    por_syn <=  1'b0;
  else
    por_syn <=  1'b1;
end
assign  rst     = por_syn & chk_rst;
assign  sysrst  = rst;

always
@(negedge por or posedge sysclk)
begin
  if(~por)
    chk_rst <=  1'b1;
  else if(chk_ptcn_wctrl)
    chk_rst <=  sfr_wdata[7];
  else
    chk_rst <=  1'b1;
end
//------------------------------------
localparam    s_por_delay0      = 4'h0;
localparam    s_por_delay1      = 4'h1;
localparam    s_initial0        = 4'h2;
localparam    s_initial1        = 4'h3;
localparam    s_initial2        = 4'h4;
localparam    s_base_lock       = 4'h5;
localparam    s_start_delay     = 4'h6;

localparam    s_idle            = 4'h8;
localparam    s_base_update     = 4'h9;
localparam    s_smoke_en        = 4'ha;
localparam    s_smoke_dis       = 4'hb;

reg   [3:0]   pstate,nstate;
reg   [7:0]   clk_cnt;
reg   [5:0]   ms_cnt0;
reg   [8:0]   ms_cnt1;
reg   [1:0]   key_reg;
reg           wakeup;
reg           wakeup_r;

reg           rom_ready_r0;
reg           rom_ready_r1;
wire          rom_ready_pos;

wire  [15:0]  holdvalue128;
wire  [15:0]  holdvalue064;
wire  [15:0]  holdvalue032;
wire          threshold_u0;
wire          threshold_u1;
wire          threshold_s1;
wire          threshold_s2;
wire          threshold_u2;
wire          threshold_u3;
wire          threshold_s3;
reg           smoke_trig;
reg           update_trig;
wire  [15:0]  chk_slope_w;
wire  [15:0]  chk_ratio_w;
wire  [7:0]   pwm_add;
reg   [7:0]   pwm_add_src0;
reg   [7:0]   pwm_add_src1;
wire          charge_md;

reg   [15:0]  sub_src0;
reg   [15:0]  sub_src1;
wire  [15:0]  sub_rslt;

assign  gctrl     = {reset_en,mic_mode,app_mode,5'h0};
assign  gmode     = 8'h0;
assign  losc_cfr  = lclk_cfr;
assign  lcfr      = lclk_cfr;
assign  hosc_cfr  = hclk_cfr;
assign  hcfr      = hclk_cfr;
assign  speed_mode= speed_md;

assign  otp_cn    = {otp_rd,otp_wr,otp_sct};
assign  otp_ad    = {1'b0,otp_ad_r};
assign  otp_dt    = otp_dt_r;
assign  test_cn   = {test_en,test_auto,2'h0,test_sel};

assign  chk_ptcn  = {1'b1,chk_wctrl,2'h0,chk_point};
assign  {chk_cnt1,chk_cnt0} = chk_cnt_w;
assign  {chk_bas1,chk_bas0} = chk_bas_r;
assign  {chk_sub1,chk_sub0} = chk_sub_r;
assign  chk_sector= {4'h0,chk_sector_r};
assign  chk_ptsub = chk_ptsub_r;
assign  chk_slope = chk_slope_r;
assign  chk_sctsub= chk_sctsub_r;
assign  pwm_width = pwm_width_r;

assign  chk_cn0   = {work_ctrl,out_enb,1'b0,speed_md,1'b0,out_mod};
assign  henb      = hosc_enb;
assign  clk_sel   = ~clk_sel_b;
assign  chk_md0   = {threshold_sel0,1'b0,threshold_sel1,hosc_enb,hrdy,1'h0,clk_sel_b};
assign  pwm_oen   = ~(pstate==s_smoke_en & ~out_enb);
assign  pwm_mod   = ~(out_mod==3'h2 | out_mod==3'h3);

assign  chk_md1   = {sector_prc,slope_prc};
assign  chk_md2   = {4'h0,pwm_prc};

assign  chk_dbd0            = chk_dbd_r0;
assign  chk_dbd1            = chk_dbd_r1;
assign  {point00h,point00l} = point00_r;
assign  {point01h,point01l} = point01_r;
assign  {point02h,point02l} = point02_r;
assign  {point03h,point03l} = point03_r;
assign  {point04h,point04l} = point04_r;
assign  {point05h,point05l} = point05_r;
assign  {point06h,point06l} = point06_r;
assign  {point07h,point07l} = point07_r;
assign  {point08h,point08l} = point08_r;
assign  {point09h,point09l} = point09_r;
//------------------------------------
always
@(negedge rst or posedge sysclk)
begin
  if(~rst)
    pstate  <=  s_por_delay0;
  else
    pstate  <=  nstate;
end

always
@(*)
begin
  nstate  =   pstate;
  case(pstate)
    s_por_delay0:     if(tclk32ms_neg)                          nstate  = s_por_delay1;
    s_por_delay1:     if(tclk32ms_neg)                          nstate  = s_initial0;
    s_initial0:       if(& otp_ad_r & rom_ready_pos)            nstate  = s_initial1;
    s_initial1:       if(& otp_ad_r[3:0] & rom_ready_pos)       nstate  = s_initial2;
    s_initial2:       if(& otp_ad_r[3:0] & rom_ready_pos)       nstate  = s_base_lock;
    s_base_lock:      if(tclk32ms_neg)                          nstate  = s_start_delay;
    s_start_delay:    if(ms_cnt1==9'h007 & tclk32ms_neg)        nstate  = s_idle;
    s_idle:           if(~work_ctrl & smoke_trig)               nstate  = s_smoke_en;
    s_smoke_en:       if(~smoke_trig)                           nstate  = s_idle;
                      else if(ms_cnt1==9'h158)                  nstate  = s_smoke_dis;
    s_smoke_dis:      if(~smoke_trig)                           nstate  = s_idle;
    default:                                                    nstate  = s_idle;
  endcase
end

always
@(negedge rst or posedge clk)
begin
  if(~rst)
    clk_cnt<=8'h0;
  else //if(run_ctrl)
  begin
    if(speed_md & tclk32ms_neg)
      clk_cnt<=8'h0;
    else if(~speed_md & mic_clk_pos)
      clk_cnt<=8'h0;
    else if(clk_cnt!=8'hff)
      clk_cnt<=clk_cnt+1'b1;
  end
end

always
@(negedge rst or posedge clk)
begin
  if(~rst)
    ms_cnt0<=6'h0;
  else //if(run_ctrl)
  begin
    if(pstate>=s_idle & pstate!=nstate)
      ms_cnt0<=6'h0;
    else if(tclk32ms_neg)
    begin
      if((update_trig & ms_cnt0==6'h3f) | ~update_trig)
        ms_cnt0<=6'h0;
      else
        ms_cnt0<=ms_cnt0+1'b1;
    end
  end
end


always
@(negedge rst or posedge clk)
begin
  if(~rst)
    ms_cnt1<=9'h0;
  else //if(run_ctrl)
  begin
    if(pstate==s_start_delay)
    begin
      if(pstate!=nstate)
        ms_cnt1<=9'h0;
      else if(tclk32ms_neg)
        ms_cnt1<=ms_cnt1+1'b1;
    end
    else if(pstate<s_idle & tclk32ms_neg)
      ms_cnt1<=ms_cnt1+1'b1;
    else if(pstate>=s_idle)
    begin
      if(~smoke_trig)
        ms_cnt1<=9'h0;
      else if(tclk32ms_neg & ms_cnt1!=9'h1ff)
        ms_cnt1<=ms_cnt1+1'b1;
    end
  end
end

always
@(negedge rst or posedge sysclk)
begin
  if(~rst)
  begin
    wakeup  <=  1'b0;
    wakeup_r<=  1'b0;
  end
  else
  begin
    if(pstate!=nstate)
    begin
      if(nstate==s_smoke_en)  begin wakeup  <=  1'b1; wakeup_r  <=  1'b1; end
      else                    begin wakeup  <=  1'b0; wakeup_r  <=  1'b0; end
    end
    else if(pstate==s_smoke_en & tclk1ms_pos)
    begin
      if(wakeup_r)  wakeup_r<=  1'b0;
      else          wakeup  <=  1'b0;
    end
  end
end

always
@(negedge rst or posedge sysclk)
begin
  if(~rst)
    run_ctrl<=1'h0;
  else if(pstate==s_por_delay1 & pstate!=nstate)
    run_ctrl<=1'h1;
  else if(pstate==s_idle & ~work_ctrl)
    run_ctrl<=update_trig;
end

always
@(negedge rst or posedge sysclk)
begin
  if(~rst)
  begin
    chk_sub_r <=  16'h0;
    chk_sub_r1<=  16'h0;
  end
  else
  begin
    if     ( speed_md &  mic_mode)begin if(chk_cnt_w>=chk_bas_r)chk_sub_r<=chk_cnt_w-chk_bas_r; else chk_sub_r<=16'h0;                end   //低速计算，防水  ->电容减小->频率增大->数值增大
    else if( speed_md & ~mic_mode)begin if(chk_cnt_w> chk_bas_r)chk_sub_r<=16'h0;               else chk_sub_r<=chk_bas_r-chk_cnt_w;  end   //低速计算，不防水->电容增大->频率减小->数值减小
    else if(~speed_md &  mic_mode)begin if(chk_cnt_w> chk_bas_r)chk_sub_r<=16'h0;               else chk_sub_r<=chk_bas_r-chk_cnt_w;  end   //高速计算，防水  ->电容减小->频率增大->数值减小
    else if(~speed_md & ~mic_mode)begin if(chk_cnt_w>=chk_bas_r)chk_sub_r<=chk_cnt_w-chk_bas_r; else chk_sub_r<=16'h0;                end   //高速计算，不防水->电容增大->频率减小->数值增大

    if     ( speed_md &  mic_mode)begin if(chk_cnt_w< chk_bas_r)chk_sub_r1<=chk_bas_r-chk_cnt_w;else chk_sub_r1<=16'h0;               end   //低速计算，防水  ->电容减小->频率增大->数值增大
    else if( speed_md & ~mic_mode)begin if(chk_cnt_w<=chk_bas_r)chk_sub_r1<=16'h0;              else chk_sub_r1<=chk_cnt_w-chk_bas_r; end   //低速计算，不防水->电容增大->频率减小->数值减小
    else if(~speed_md &  mic_mode)begin if(chk_cnt_w<=chk_bas_r)chk_sub_r1<=16'h0;              else chk_sub_r1<=chk_cnt_w-chk_bas_r; end   //高速计算，防水  ->电容减小->频率增大->数值减小
    else if(~speed_md & ~mic_mode)begin if(chk_cnt_w< chk_bas_r)chk_sub_r1<=chk_bas_r-chk_cnt_w;else chk_sub_r1<=16'h0;               end   //高速计算，不防水->电容增大->频率减小->数值增大
  end
end

assign  holdvalue128 = {7'h0,chk_bas_r[15:7]};
assign  holdvalue064 = {6'h0,chk_bas_r[15:6]};
assign  holdvalue032 = {5'h0,chk_bas_r[15:5]};
assign  threshold_u0  = (chk_sub_r  >=holdvalue128);
assign  threshold_u1 =  (chk_sub_r1 >=holdvalue128);
assign  threshold_u2  = (chk_sub_r  >={chk_dbd_r1,chk_dbd_r0});
assign  threshold_u3 =  (chk_sub_r1 >={chk_dbd_r1,chk_dbd_r0});
assign  threshold_s1  = (chk_sub_r  >=holdvalue064);
assign  threshold_s2  = (chk_sub_r  >=holdvalue032);
assign  threshold_s3  = (chk_sub_r  >=point00_r);

always
@(*)
begin
  if(threshold_sel0)  update_trig = threshold_u2 | threshold_u3;   //chk_dbd_r;
  else                update_trig = threshold_u0 | threshold_u1;   //0.75% chk_bas_r;
end

always
@(*)
begin
  case(threshold_sel1)
    2'h0:   smoke_trig  = threshold_s1;   //1.56%
    2'h1:   smoke_trig  = threshold_s2;   //3.1%
    default:smoke_trig  = threshold_s3;   //point0
  endcase
end

//------------------------------------
always
@(negedge rst or posedge clk)
begin
  if(~rst)
  begin
    reset_en    <=  1'b1;
    mic_mode    <=  1'b0;
    app_mode    <=  1'b0;

//    gmode_r     <=  8'h0;

    lclk_cfr    <=  8'h80;
    hclk_cfr    <=  8'h80;
    pwm_base    <=  8'h33;
    pwm_step    <=  8'h20;

    threshold_sel0  <=  1'b1;
    threshold_sel1  <=  2'h3;
    hosc_enb    <=  1'b1;
    clk_sel_b   <=  1'b1;
    clk_sel_r   <=  1'b1;

    test_en     <=  1'b1;
    test_auto   <=  1'b1;
    test_sel    <=  4'h0;

    otp_rd      <=  1'b0;
    otp_wr      <=  1'b0;
    otp_sct     <=  6'h3f;
    otp_ad_r    <=  7'h70;
    otp_dt_r    <=  8'h00;

//    chk_rst     <=  1'b1;
    chk_wctrl   <=  1'b0;
    chk_point   <=  4'h0;

    sector_prc  <=  4'h0;
    slope_prc   <=  4'h0;
    pwm_prc     <=  4'h0;

    chk_bas_r   <=  16'h0000;
    chk_dbd_r0  <=  8'h20;
    chk_dbd_r1  <=  8'h00;

    pwm_width_r <=  8'h33;


    work_ctrl   <=  1'b1;
    out_enb     <=  1'b1;
    speed_md    <=  1'b1;
    out_mod     <=  3'h0;

    point00_r   <=  16'hffff;
    point01_r   <=  16'hffff;
    point02_r   <=  16'hffff;
    point03_r   <=  16'hffff;
    point04_r   <=  16'hffff;
    point05_r   <=  16'hffff;
    point06_r   <=  16'hffff;
    point07_r   <=  16'hffff;
    point08_r   <=  16'hffff;
    point09_r   <=  16'hffff;
  end
  else //if(run_ctrl)
  begin
    if(gctrl_wctrl      ) {reset_en,mic_mode,app_mode}          <=  sfr_wdata[7:5];
//    if(gmode_wctrl      ) gmode_r                               <=  sfr_wdata;
    if(losc_cfr_wctrl   ) lclk_cfr                              <=  sfr_wdata;
    if(hosc_cfr_wctrl   ) hclk_cfr                              <=  sfr_wdata;
    if(pwm_base_wctrl   ) pwm_base                              <=  sfr_wdata;
    if(pwm_step_wctrl   ) pwm_step                              <=  sfr_wdata;

    if(otp_cn_wctrl     ) {otp_rd,otp_wr,otp_sct}               <=  {sfr_wdata[7],sfr_wdata[6],sfr_wdata[5:0]};
    if(otp_dt_wctrl     ) otp_dt_r                              <=  sfr_wdata;
    if(otp_ad_wctrl     ) otp_ad_r                              <=  sfr_wdata[6:0];
    if(test_cn_wctrl    ) {test_en,test_auto,test_sel}          <=  {sfr_wdata[7],sfr_wdata[6],sfr_wdata[3:0]};

//    if(chk_ptcn_wctrl   ) {chk_rst,chk_wctrl,chk_point}         <=  {sfr_wdata[7:6],sfr_wdata[3:0]};
    if(chk_ptcn_wctrl   ) {chk_wctrl,chk_point}                 <=  {sfr_wdata[6],sfr_wdata[3:0]};

    if(chk_cn0_wctrl    ) {work_ctrl,out_enb,speed_md,out_mod}  <=  {sfr_wdata[7:6],sfr_wdata[4],sfr_wdata[2:0]};
    if(chk_md0_wctrl    ) {threshold_sel0,threshold_sel1,hosc_enb,clk_sel_r}<=  {sfr_wdata[7],sfr_wdata[5:4],sfr_wdata[3],sfr_wdata[0]};
    if(chk_md1_wctrl    ) {sector_prc,slope_prc}                <=  {sfr_wdata[7:4],sfr_wdata[3:0]};
    if(chk_md2_wctrl    ) {pwm_prc}                             <=  {sfr_wdata[3:0]};
    if(chk_dbd0_wctrl   ) chk_dbd_r0                            <=  sfr_wdata;
    if(chk_dbd1_wctrl   ) chk_dbd_r1                            <=  sfr_wdata;
    if(point00l_wctrl   ) point00_r[7:0]                        <=  sfr_wdata;
    if(point00h_wctrl   ) point00_r[15:8]                       <=  sfr_wdata;
    if(point01l_wctrl   ) point01_r[7:0]                        <=  sfr_wdata;
    if(point01h_wctrl   ) point01_r[15:8]                       <=  sfr_wdata;
    if(point02l_wctrl   ) point02_r[7:0]                        <=  sfr_wdata;
    if(point02h_wctrl   ) point02_r[15:8]                       <=  sfr_wdata;
    if(point03l_wctrl   ) point03_r[7:0]                        <=  sfr_wdata;
    if(point03h_wctrl   ) point03_r[15:8]                       <=  sfr_wdata;
    if(point04l_wctrl   ) point04_r[7:0]                        <=  sfr_wdata;
    if(point04h_wctrl   ) point04_r[15:8]                       <=  sfr_wdata;
    if(point05l_wctrl   ) point05_r[7:0]                        <=  sfr_wdata;
    if(point05h_wctrl   ) point05_r[15:8]                       <=  sfr_wdata;
    if(point06l_wctrl   ) point06_r[7:0]                        <=  sfr_wdata;
    if(point06h_wctrl   ) point06_r[15:8]                       <=  sfr_wdata;
    if(point07l_wctrl   ) point07_r[7:0]                        <=  sfr_wdata;
    if(point07h_wctrl   ) point07_r[15:8]                       <=  sfr_wdata;
    if(point08l_wctrl   ) point08_r[7:0]                        <=  sfr_wdata;
    if(point08h_wctrl   ) point08_r[15:8]                       <=  sfr_wdata;
    if(point09l_wctrl   ) point09_r[7:0]                        <=  sfr_wdata;
    if(point09h_wctrl   ) point09_r[15:8]                       <=  sfr_wdata;

    if(test_en & test_auto & tclk1ms_pos)      //auto test io output ctrl
    begin
      if(test_sel==4'h5)  test_sel  <=  4'h0;
      else                test_sel  <=  test_sel  + 1'b1;
    end

    if(pstate==s_initial0 & rom_ready_pos)
    begin
      if(nstate==s_initial1)
      begin
        casex(otp_sct)
//          6'b11_1111: otp_ad_r  <=  7'h00;
          6'bxx_xxx0: otp_ad_r  <=  7'h60;
          6'bxx_xx0x: otp_ad_r  <=  7'h50;
          6'bxx_x0xx: otp_ad_r  <=  7'h40;
          6'bxx_0xxx: otp_ad_r  <=  7'h30;
          6'bx0_xxxx: otp_ad_r  <=  7'h20;
          6'b0x_xxxx: otp_ad_r  <=  7'h10;
          default:    otp_ad_r  <=  7'h00;
        endcase
      end
      else  otp_ad_r  <=  otp_ad_r+1'b1;

      if(& key_reg)
      begin
        case(otp_ad_r[3:0])
          4'h2: {test_en,test_auto,test_sel} <=  {rom_rdata[7],rom_rdata[6],rom_rdata[3:0]};
          4'h3: lclk_cfr                     <=  rom_rdata;
          4'h4: hclk_cfr                     <=  rom_rdata;
          4'h5: otp_sct                      <=  rom_rdata[5:0];

          4'hc: {reset_en,mic_mode,app_mode} <=  {rom_rdata[7:5]};
//          4'hd: gmode_r                      <=  rom_rdata;
          4'he: pwm_base                     <=  rom_rdata;
          4'hf: pwm_step                     <=  rom_rdata;
//          4'he: idle_tim                     <=  rom_rdata;
//          4'hf: charge_tim                   <=  rom_rdata;
          default:  ;
        endcase
      end
    end

    if(pstate==s_initial1 & rom_ready_pos)
    begin
      otp_ad_r  <=  otp_ad_r+1'b1;
      if(& key_reg)
      begin
        case(otp_ad_r[3:0])
          4'h0:   {work_ctrl,out_enb,speed_md,out_mod}  <=  {rom_rdata[7:6],rom_rdata[4],rom_rdata[2:0]};
          4'h1:   {threshold_sel0,threshold_sel1,hosc_enb,clk_sel_r}<=  {rom_rdata[7],rom_rdata[5:4],rom_rdata[3],rom_rdata[0]};
          4'h2:   {sector_prc,slope_prc}                <=  rom_rdata;
          4'h3:   {pwm_prc}                             <=  rom_rdata[3:0];
          4'h4:   chk_dbd_r0                            <=  rom_rdata;
          4'h5:   chk_dbd_r1                            <=  rom_rdata;
          4'h6:   point00_r[7:0]                        <=  rom_rdata;
          4'h7:   point00_r[15:8]                       <=  rom_rdata;
          4'h8:   point01_r[7:0]                        <=  rom_rdata;
          4'h9:   point01_r[15:8]                       <=  rom_rdata;
          4'ha:   point02_r[7:0]                        <=  rom_rdata;
          4'hb:   point02_r[15:8]                       <=  rom_rdata;
          4'hc:   point03_r[7:0]                        <=  rom_rdata;
          4'hd:   point03_r[15:8]                       <=  rom_rdata;
          4'he:   point04_r[7:0]                        <=  rom_rdata;
          4'hf:   point04_r[15:8]                       <=  rom_rdata;
        endcase
      end
    end

    if(pstate==s_initial2 & rom_ready_pos)
    begin
      otp_ad_r  <=  otp_ad_r+1'b1;
      if(& key_reg)
      begin
        case(otp_ad_r[3:0])
          4'h0:  point05_r[7:0]                        <=  rom_rdata;
          4'h1:  point05_r[15:8]                       <=  rom_rdata;
          4'h2:  point06_r[7:0]                        <=  rom_rdata;
          4'h3:  point06_r[15:8]                       <=  rom_rdata;
          4'h4:  point07_r[7:0]                        <=  rom_rdata;
          4'h5:  point07_r[15:8]                       <=  rom_rdata;
          4'h6:  point08_r[7:0]                        <=  rom_rdata;
          4'h7:  point08_r[15:8]                       <=  rom_rdata;
          4'h8:  point09_r[7:0]                        <=  rom_rdata;
          4'h9:  point09_r[15:8]                       <=  rom_rdata;
          default:  ;
        endcase
      end
    end

    if(pstate>=s_idle) clk_sel_b <=  clk_sel_r;
    if(pstate==s_initial2 & pstate!=nstate) clk_sel_b <=  clk_sel_r;

    if(~work_ctrl)
    begin
      if(pstate==s_base_lock & tclk32ms_neg)   chk_bas_r <=  chk_cnt_w;
      if(pstate==s_idle & update_trig & ms_cnt0==6'h1f  & tclk32ms_neg)  chk_bas_r <=  chk_cnt_w;
      if(pstate==s_smoke_dis & ms_cnt1==9'h1f4) chk_bas_r <=  chk_cnt_w;
    end

    if(rom_ready) {otp_rd,otp_wr} <=  2'h0;

    if(pstate==s_smoke_en | work_ctrl)
    begin
      if(clk_cnt==8'h2f)  pwm_width_r <=  pwm_reg;
    end
    else                  pwm_width_r <=  pwm_base;

    if(chk_wctrl) chk_wctrl <=  1'b0;
    if(chk_wctrl)
    begin
      case(chk_point)
        5'h00:  point00_r               <=  chk_sub_r;
        5'h01:  point01_r               <=  chk_sub_r;
        5'h02:  point02_r               <=  chk_sub_r;
        5'h03:  point03_r               <=  chk_sub_r;
        5'h04:  point04_r               <=  chk_sub_r;
        5'h05:  point05_r               <=  chk_sub_r;
        5'h06:  point06_r               <=  chk_sub_r;
        5'h07:  point07_r               <=  chk_sub_r;
        5'h08:  point08_r               <=  chk_sub_r;
        5'h09:  point09_r               <=  chk_sub_r;
        5'h0e:  {chk_dbd_r1,chk_dbd_r0} <=  chk_sub_r;
        5'h0f:  chk_bas_r               <=  chk_cnt_w;
        default:  ;
      endcase
    end
  end
end

assign  sfr_ready = 1'b1;

assign  chk_cnt_w =(speed_md)?mic_lct:mic_hct;
//------------------------------------
always
@(negedge rst or posedge clk)
begin
  if(~rst)
    key_reg <=  2'h0;
  else //if(run_ctrl)
  begin
    if(pstate==s_initial0 & rom_ready_pos)
    begin
      case(otp_ad_r[3:0])
        4'h0: if(rom_rdata==8'hd0)  key_reg[0]  <=  1'b1; else  key_reg[0]  <=  1'b0;
        4'h1: if(rom_rdata==8'h52)  key_reg[1]  <=  1'b1; else  key_reg[1]  <=  1'b0;
        4'ha: if(rom_rdata==8'hd0)  key_reg[0]  <=  1'b1; else  key_reg[0]  <=  1'b0;
        4'hb: if(rom_rdata==8'h52)  key_reg[1]  <=  1'b1; else  key_reg[1]  <=  1'b0;
        default:  ;
      endcase
    end
  end
end

always
@(negedge rst or posedge clk)
begin
  if(~rst)
  begin
    rom_ready_r0  <=  1'b0;
    rom_ready_r1  <=  1'b0;
  end
  else //if(run_ctrl)
  begin
    rom_ready_r0  <=  rom_ready;
    rom_ready_r1  <=  rom_ready_r0;
  end
end

assign  rom_ready_pos = rom_ready_r0  & ~rom_ready_r1;

always
@(negedge rst or posedge clk)
begin
  if(~rst)
  begin
    rom_wctrl   = 1'b0;
    rom_rctrl   = 1'b0;
  end
  else //if(run_ctrl)
  begin
    case(nstate)
      s_initial0:   //initial work mode
      begin
        rom_rctrl = 1'b1;
      end
      s_initial1:   //initial point
      begin
        rom_rctrl = 1'b1;
      end
      s_initial2:   //initial point
      begin
        rom_rctrl = 1'b1;
      end
      default:
      begin
        rom_wctrl = (rom_ready)?1'b0:otp_wr;
        rom_rctrl = (rom_ready)?1'b0:otp_rd;
      end
   endcase
  end
end

always
@(*)
begin
  rom_addrs   = otp_ad_r;
  rom_wdata   = otp_dt;
end

//------------------------------------
always
@(negedge rst or posedge clk)
begin
  if(~rst)
    chk_sector_r  <=  4'h0;
  else //if(run_ctrl)
  begin
    if((pstate==s_smoke_en | work_ctrl) & clk_cnt==8'h01)
    begin
      if      (chk_sub_r< point00_r)  chk_sector_r <=  4'h0;
      else if (chk_sub_r< point01_r)  chk_sector_r <=  4'h1;
      else if (chk_sub_r< point02_r)  chk_sector_r <=  4'h2;
      else if (chk_sub_r< point03_r)  chk_sector_r <=  4'h3;
      else if (chk_sub_r< point04_r)  chk_sector_r <=  4'h4;
      else if (chk_sub_r< point05_r)  chk_sector_r <=  4'h5;
      else if (chk_sub_r< point06_r)  chk_sector_r <=  4'h6;
      else if (chk_sub_r< point07_r)  chk_sector_r <=  4'h7;
      else if (chk_sub_r< point08_r)  chk_sector_r <=  4'h8;
      else if (chk_sub_r< point09_r)  chk_sector_r <=  4'h9;
      else                            chk_sector_r <=  4'ha;
    end
  end
end
//----------------------------------------------
//分段差计算
always
@(negedge rst or posedge clk)
begin
  if(~rst)
    chk_ptsub_r <= 8'h0;
  else //if(run_ctrl)
  begin
    if((pstate==s_smoke_en | work_ctrl) & clk_cnt==8'h02)
    begin
      case(sector_prc)
        4'h0:   chk_ptsub_r <=  sub_rslt[ 7:0];
        4'h1:   chk_ptsub_r <=  sub_rslt[ 8:1];
        4'h2:   chk_ptsub_r <=  sub_rslt[ 9:2];
        4'h3:   chk_ptsub_r <=  sub_rslt[10:3];
        4'h4:   chk_ptsub_r <=  sub_rslt[11:4];
        4'h5:   chk_ptsub_r <=  sub_rslt[12:5];
        4'h6:   chk_ptsub_r <=  sub_rslt[13:6];
        4'h7:   chk_ptsub_r <=  sub_rslt[14:7];
        default:chk_ptsub_r <=  sub_rslt[15:8];
      endcase
    end
  end
end
//-----------------------------------------
//段内差计算
always
@(negedge rst or posedge clk)
begin
  if(~rst)
    chk_sctsub_r <= 8'h0;
  else //if(run_ctrl)
  begin
    if((pstate==s_smoke_en | work_ctrl) & clk_cnt==8'h03)
    begin
      case(sector_prc)
        4'h0:   chk_sctsub_r <=  sub_rslt[ 7:0];
        4'h1:   chk_sctsub_r <=  sub_rslt[ 8:1];
        4'h2:   chk_sctsub_r <=  sub_rslt[ 9:2];
        4'h3:   chk_sctsub_r <=  sub_rslt[10:3];
        4'h4:   chk_sctsub_r <=  sub_rslt[11:4];
        4'h5:   chk_sctsub_r <=  sub_rslt[12:5];
        4'h6:   chk_sctsub_r <=  sub_rslt[13:6];
        4'h7:   chk_sctsub_r <=  sub_rslt[14:7];
        default:chk_sctsub_r <=  sub_rslt[15:8];
      endcase
    end
  end
end
//-----------------------------------------
//段斜率计算
always
@(negedge rst or posedge clk)
begin
  if(~rst)
    chk_slope_r    <=  8'h0;
  else //if(run_ctrl)
  begin
    if((pstate==s_smoke_en | work_ctrl) & clk_cnt==8'h15)
    begin
      if(muldiv_int)
      begin
        case(slope_prc)
          4'h0:   chk_slope_r <=  chk_slope_w[ 7:0];
          4'h1:   chk_slope_r <=  chk_slope_w[ 8:1];
          4'h2:   chk_slope_r <=  chk_slope_w[ 9:2];
          4'h3:   chk_slope_r <=  chk_slope_w[10:3];
          4'h4:   chk_slope_r <=  chk_slope_w[11:4];
          4'h5:   chk_slope_r <=  chk_slope_w[12:5];
          4'h6:   chk_slope_r <=  chk_slope_w[13:6];
          4'h7:   chk_slope_r <=  chk_slope_w[14:7];
          default:chk_slope_r <=  chk_slope_w[15:8];
        endcase
      end
    end
  end
end
assign  chk_slope_w =  {muldiv_hr,muldiv_br};
//-----------------------------------------
//段内比计算
always
@(negedge rst or posedge clk)
begin
  if(~rst)
    chk_ratio    <=  8'h0;
  else //if(run_ctrl)
  begin
    if((pstate==s_smoke_en | work_ctrl) & clk_cnt==8'h21)
    begin
      if(muldiv_int)
      begin
        case(pwm_prc)
          4'h0:   chk_ratio <=  chk_ratio_w[ 7:0];
          4'h1:   chk_ratio <=  chk_ratio_w[ 8:1];
          4'h2:   chk_ratio <=  chk_ratio_w[ 9:2];
          4'h3:   chk_ratio <=  chk_ratio_w[10:3];
          4'h4:   chk_ratio <=  chk_ratio_w[11:4];
          4'h5:   chk_ratio <=  chk_ratio_w[12:5];
          4'h6:   chk_ratio <=  chk_ratio_w[13:6];
          4'h7:   chk_ratio <=  chk_ratio_w[14:7];
          default:chk_ratio <=  chk_ratio_w[15:8];
        endcase
      end
    end
  end
end
assign  chk_ratio_w =  {muldiv_hr,muldiv_cr};
//-----------------------------------------
//PWM计算
always
@(negedge rst or posedge clk)
begin
  if(~rst)
    pwm_reg <=  8'h0;
  else //if(run_ctrl)
  begin
    if((pstate==s_smoke_en | work_ctrl))
    begin
      case(clk_cnt)
        8'h24:                          pwm_reg <=  pwm_add;
        8'h25:  if(chk_sector_r>=4'h2)  pwm_reg <=  pwm_add;
        8'h26:  if(chk_sector_r>=4'h3)  pwm_reg <=  pwm_add;
        8'h27:  if(chk_sector_r>=4'h4)  pwm_reg <=  pwm_add;
        8'h28:  if(chk_sector_r>=4'h5)  pwm_reg <=  pwm_add;
        8'h29:  if(chk_sector_r>=4'h6)  pwm_reg <=  pwm_add;
        8'h2a:  if(chk_sector_r>=4'h7)  pwm_reg <=  pwm_add;
        8'h2b:  if(chk_sector_r>=4'h8)  pwm_reg <=  pwm_add;
        8'h2c:  if(chk_sector_r>=4'h9)  pwm_reg <=  pwm_add;
        8'h2d:  if(chk_sector_r>=4'ha)  pwm_reg <=  pwm_add;
        8'h2e:  if(chk_sector_r!=4'h0 & chk_sector_r!=4'ha)
                                        pwm_reg <=  pwm_add;
        default:;
      endcase
    end
  end
end

always
@(*)
begin
  case(clk_cnt)
    8'h24:  begin pwm_add_src0  = pwm_base; pwm_add_src1  = 8'h0;   end
    8'h2e:  begin pwm_add_src0  = pwm_reg;  pwm_add_src1  = muldiv_hr;  end
    default:begin pwm_add_src0  = pwm_reg;  pwm_add_src1  = pwm_step;   end
  endcase
end

assign  pwm_add =  pwm_add_src0 + pwm_add_src1;
//------------------------------------
always
@(*)
begin
  sub_src0  = 16'h0;
  sub_src1  = 16'h0;
//  if(clk_cnt==8'h00)
//  begin
//    if     ( speed_md &  mic_mode)begin sub_src0= chk_cnt_w;  sub_src1= chk_bas_r;  end //低速计算，防水  ->电容减小->频率增大->数值增大
//    else if( speed_md & ~mic_mode)begin sub_src0= chk_bas_r;  sub_src1= chk_cnt_w;  end //低速计算，不防水->电容增大->频率减小->数值减小
//    else if(~speed_md &  mic_mode)begin sub_src0= chk_bas_r;  sub_src1= chk_cnt_w;  end //高速计算，防水  ->电容减小->频率增大->数值减小
//    else if(~speed_md & ~mic_mode)begin sub_src0= chk_cnt_w;  sub_src1= chk_bas_r;  end //高速计算，不防水->电容增大->频率减小->数值增大
//  end
//  else if(clk_cnt==8'h2f)
//  begin
//    if     ( speed_md &  mic_mode)begin sub_src0= chk_bas_r;  sub_src1= chk_cnt_w;  end //低速计算，防水  ->电容减小->频率增大->数值增大
//    else if( speed_md & ~mic_mode)begin sub_src0= chk_cnt_w;  sub_src1= chk_bas_r;  end //低速计算，不防水->电容增大->频率减小->数值减小
//    else if(~speed_md &  mic_mode)begin sub_src0= chk_cnt_w;  sub_src1= chk_bas_r;  end //高速计算，防水  ->电容减小->频率增大->数值减小
//    else if(~speed_md & ~mic_mode)begin sub_src0= chk_bas_r;  sub_src1= chk_cnt_w;  end //高速计算，不防水->电容增大->频率减小->数值增大
//  end
  if((pstate==s_smoke_en | work_ctrl) & clk_cnt==8'h02)
  begin
    case(chk_sector_r)
      4'h1:     begin sub_src0  = point01_r;  sub_src1  = point00_r;  end
      4'h2:     begin sub_src0  = point02_r;  sub_src1  = point01_r;  end
      4'h3:     begin sub_src0  = point03_r;  sub_src1  = point02_r;  end
      4'h4:     begin sub_src0  = point04_r;  sub_src1  = point03_r;  end
      4'h5:     begin sub_src0  = point05_r;  sub_src1  = point04_r;  end
      4'h6:     begin sub_src0  = point06_r;  sub_src1  = point05_r;  end
      4'h7:     begin sub_src0  = point07_r;  sub_src1  = point06_r;  end
      4'h8:     begin sub_src0  = point08_r;  sub_src1  = point07_r;  end
      4'h9:     begin sub_src0  = point09_r;  sub_src1  = point08_r;  end
      default:  begin sub_src0  = 16'h0;      sub_src1  = 16'h0;      end
    endcase
  end
  else if((pstate==s_smoke_en | work_ctrl) & clk_cnt==8'h03)
  begin
    case(chk_sector_r)
      4'h1:     begin sub_src0  = chk_sub_r;  sub_src1  = point00_r;  end
      4'h2:     begin sub_src0  = chk_sub_r;  sub_src1  = point01_r;  end
      4'h3:     begin sub_src0  = chk_sub_r;  sub_src1  = point02_r;  end
      4'h4:     begin sub_src0  = chk_sub_r;  sub_src1  = point03_r;  end
      4'h5:     begin sub_src0  = chk_sub_r;  sub_src1  = point04_r;  end
      4'h6:     begin sub_src0  = chk_sub_r;  sub_src1  = point05_r;  end
      4'h7:     begin sub_src0  = chk_sub_r;  sub_src1  = point06_r;  end
      4'h8:     begin sub_src0  = chk_sub_r;  sub_src1  = point07_r;  end
      4'h9:     begin sub_src0  = chk_sub_r;  sub_src1  = point08_r;  end
      default:  begin sub_src0  = 16'h0;      sub_src1  = 16'h0;      end
    endcase
  end
end

assign  sub_rslt  = sub_src0  - sub_src1  ;
//------------------------------------
//muldiv driver
always
@(*)
begin
  muldiv_cn_wctrl = 1'b0;
  muldiv_ar_wctrl = 1'b0;
  muldiv_br_wctrl = 1'b0;
  muldiv_hr_wctrl = 1'b0;
  muldiv_cr_wctrl = 1'b0;
  muldiv_dt       = 8'h00;
  if((pstate==s_smoke_en | work_ctrl))
  begin
    case(clk_cnt)
      8'h00:  begin muldiv_dt  = 8'h00;       muldiv_cn_wctrl = 1'b1; end
      8'h01:  begin muldiv_dt  = 8'hff;       muldiv_hr_wctrl = 1'b1; end
      8'h02:  begin muldiv_dt  = 8'hff;       muldiv_br_wctrl = 1'b1; end
      8'h03:  begin muldiv_dt  = chk_ptsub_r; muldiv_ar_wctrl = 1'b1; end
      8'h04:  begin muldiv_dt  = 8'h28;       muldiv_cn_wctrl = 1'b1; end

      8'h15:  begin muldiv_dt  = 8'h00;       muldiv_cn_wctrl = 1'b1; end
      8'h16:  begin muldiv_dt  = chk_sctsub_r;muldiv_br_wctrl = 1'b1; end
      8'h17:  begin muldiv_dt  = chk_slope_r; muldiv_ar_wctrl = 1'b1; end
      8'h18:  begin muldiv_dt  = 8'h20;       muldiv_cn_wctrl = 1'b1; end

      8'h21:  begin muldiv_dt  = 8'h00;       muldiv_cn_wctrl = 1'b1; end
      8'h22:  begin muldiv_dt  = pwm_step;    muldiv_br_wctrl = 1'b1; end
      8'h23:  begin muldiv_dt  = chk_ratio;   muldiv_ar_wctrl = 1'b1; end
      8'h24:  begin muldiv_dt  = 8'h20;       muldiv_cn_wctrl = 1'b1; end
    endcase
  end
end

//------------------------------------
assign  charge_md=hl_sel;
//assign  charge_en=(pstate==s_start_delay)?1'b0:(app_mode & ~work_ctrl);
//---------------------------------
assign  owl_di_w  = ~owl_di;

always
@(*)
begin
                    owl_ie=1'b1;    owl_do=~owl_do_w;   owl_poe=1'b0;         owl_noe=owl_oe_w;     owl_pu=charge_md;   owl_pd=~charge_md;        //owl被动
  if(pstate==s_por_delay0 | pstate==s_por_delay1 | pstate==s_initial0 | pstate==s_initial1 | pstate==s_initial2 | pstate==s_base_lock)
              begin owl_ie=1'b0;    owl_do=charge_md;   owl_poe=charge_md;    owl_noe=~charge_md;   owl_pu=1'b0;        owl_pd=1'b0;        end   //上电补电
  else if(pstate==s_start_delay)
              begin owl_ie=1'b1;    owl_do=~owl_do_w;   owl_poe=1'b0;         owl_noe=owl_oe_w;     owl_pu=charge_md;   owl_pd=~charge_md;  end   //owl介入时间窗口
  else if(pstate!=s_smoke_en)
  begin
    if(app_mode & ~work_ctrl)
              begin owl_ie=1'b0;    owl_do=charge_md;   owl_poe=charge_md;    owl_noe=~charge_md;   owl_pu=1'b0;        owl_pd=1'b0;        end   //不输出时，2线工作模式默认补电
    else      begin owl_ie=1'b1;    owl_do=~owl_do_w;   owl_poe=1'b0;         owl_noe=owl_oe_w;     owl_pu=charge_md;   owl_pd=~charge_md;  end   //不输出时，3线或2线标定模式可以OWL通信
  end
  else if(~app_mode)    //3线模式
  begin
    case(out_mod)
      3'h0:   begin owl_ie=1'b0;    owl_do=pwm_out;     owl_poe=1'b1;         owl_noe=1'b1;         owl_pu=1'b0;        owl_pd=1'b0;        end   //pwm正输出
      3'h1:   begin owl_ie=1'b0;    owl_do=~pwm_out;    owl_poe=1'b1;         owl_noe=1'b1;         owl_pu=1'b0;        owl_pd=1'b0;        end   //pwm反输出
      3'h2:   begin owl_ie=1'b0;    owl_do=pwm_out;     owl_poe=1'b1;         owl_noe=1'b1;         owl_pu=1'b0;        owl_pd=1'b0;        end   //fm输出
      3'h3:   begin owl_ie=1'b0;    owl_do=pwm_out;     owl_poe=1'b1;         owl_noe=1'b1;         owl_pu=1'b0;        owl_pd=1'b0;        end   //fm输出
      3'h4:   begin owl_ie=1'b1;    owl_do=~owl_do_w;   owl_poe=1'b0;         owl_noe=owl_oe_w;     owl_pu=charge_md;   owl_pd=~charge_md;  end   //owl被动
      3'h5:
      begin
        if(wakeup)
              begin owl_ie=1'b0;    owl_do=1'b0;        owl_poe=1'b0;         owl_noe=1'b0;         owl_pu=~charge_md;  owl_pd=charge_md;   end   //owl被动带唤醒，唤醒状态
        else
              begin owl_ie=1'b1;    owl_do=~owl_do_w;   owl_poe=1'b0;         owl_noe=owl_oe_w;     owl_pu=charge_md;   owl_pd=~charge_md;  end   //owl被动带唤醒，非唤醒状态
      end
      3'h6:   begin owl_ie=1'b0;    owl_do=tclk1ms_h;   owl_poe=1'b1;         owl_noe=1'b1;         owl_pu=1'b0;        owl_pd=1'b0;        end   //不标定PWM模式输出
      3'h7:   begin owl_ie=1'b0;    owl_do=~charge_md;  owl_poe=1'b1;         owl_noe=1'b1;         owl_pu=1'b0;        owl_pd=1'b0;        end   //不标定电平模式输出
    endcase
  end
  else                  //2线模式
  begin
    case(out_mod)
      3'h0:   begin owl_ie=1'b0;    owl_do=pwm_out;     owl_poe=charge_md;    owl_noe=~charge_md;   owl_pu=1'b0;        owl_pd=1'b0;        end   //pwm正输出
      3'h1:   begin owl_ie=1'b0;    owl_do=~pwm_out;    owl_poe=charge_md;    owl_noe=~charge_md;   owl_pu=1'b0;        owl_pd=1'b0;        end   //pwm反输出
      3'h2:   begin owl_ie=1'b0;    owl_do=pwm_out;     owl_poe=charge_md;    owl_noe=~charge_md;   owl_pu=1'b0;        owl_pd=1'b0;        end   //fm输出
      3'h3:   begin owl_ie=1'b0;    owl_do=pwm_out;     owl_poe=charge_md;    owl_noe=~charge_md;   owl_pu=1'b0;        owl_pd=1'b0;        end   //fm输出
      3'h4:   begin owl_ie=1'b1;    owl_do=~owl_do_w;   owl_poe=1'b0;         owl_noe=owl_oe_w;     owl_pu=charge_md;   owl_pd=~charge_md;  end   //owl被动
      3'h5:
      begin
        if(wakeup)
              begin owl_ie=1'b0;    owl_do=1'b0;        owl_poe=1'b0;         owl_noe=1'b0;         owl_pu=~charge_md;  owl_pd=charge_md;   end   //owl被动带唤醒，唤醒状态
        else
              begin owl_ie=1'b1;    owl_do=~owl_do_w;   owl_poe=1'b0;         owl_noe=owl_oe_w;     owl_pu=charge_md;   owl_pd=~charge_md;  end   //owl被动带唤醒，非唤醒状态
      end
      3'h6:   begin owl_ie=1'b0;    owl_do=tclk1ms_h;   owl_poe=charge_md;    owl_noe=~charge_md;   owl_pu=1'b0;        owl_pd=1'b0;        end   //不标定PWM模式输出
      3'h7:   begin owl_ie=1'b0;    owl_do=~charge_md;  owl_poe=charge_md;    owl_noe=~charge_md;   owl_pu=1'b0;        owl_pd=1'b0;        end   //不标定电平模式输出
    endcase
  end
end
//---------------------------------
always
@(*)
begin
                    ts_ie=1'b0;     ts_do=1'b0;         ts_poe=1'b0;          ts_noe=1'b0;          ts_pu=1'b0;         ts_pd=1'b0;               //high Z
  if(test_en)
  begin
    case(test_sel)
      4'h0:   begin ts_ie=1'b0;     ts_do=reset;        ts_poe=1'b1;          ts_noe=1'b1;          ts_pu=1'b0;         ts_pd=1'b0;         end   //push  reset
      4'h1:   begin ts_ie=1'b0;     ts_do=rst;          ts_poe=1'b1;          ts_noe=1'b1;          ts_pu=1'b0;         ts_pd=1'b0;         end   //push  por_syn
      4'h2:   begin ts_ie=1'b0;     ts_do=lclk;         ts_poe=1'b1;          ts_noe=1'b1;          ts_pu=1'b0;         ts_pd=1'b0;         end   //push  lclk
      4'h3:   begin ts_ie=1'b0;     ts_do=clk;          ts_poe=1'b1;          ts_noe=1'b1;          ts_pu=1'b0;         ts_pd=1'b0;         end   //push  sysclk
      4'h4:   begin ts_ie=1'b0;     ts_do=hclk;         ts_poe=1'b1;          ts_noe=1'b1;          ts_pu=1'b0;         ts_pd=1'b0;         end   //push  hclk
      4'h5:   begin ts_ie=1'b0;     ts_do=hrdy;         ts_poe=1'b1;          ts_noe=1'b1;          ts_pu=1'b0;         ts_pd=1'b0;         end   //push  hrdy
      4'h6:   begin ts_ie=1'b0;     ts_do=pwm_out;      ts_poe=1'b1;          ts_noe=1'b1;          ts_pu=1'b0;         ts_pd=1'b0;         end
      4'h7:   begin ts_ie=1'b0;     ts_do=pwm_out;      ts_poe=1'b1;          ts_noe=1'b1;          ts_pu=1'b0;         ts_pd=1'b0;         end
      4'h8:   begin ts_ie=1'b0;     ts_do=~owl_do_w;    ts_poe=1'b1;          ts_noe=1'b1;          ts_pu=1'b0;         ts_pd=1'b0;         end
      4'h9:   begin ts_ie=1'b0;     ts_do=owl_di;       ts_poe=1'b1;          ts_noe=1'b1;          ts_pu=1'b0;         ts_pd=1'b0;         end
      4'ha:   begin ts_ie=1'b0;     ts_do=mic_clk;      ts_poe=1'b1;          ts_noe=1'b1;          ts_pu=1'b0;         ts_pd=1'b0;         end
      4'hb:   begin ts_ie=1'b0;     ts_do=1'b0;         ts_poe=1'b1;          ts_noe=1'b1;          ts_pu=1'b0;         ts_pd=1'b0;         end
      4'hc:   begin ts_ie=1'b0;     ts_do=1'b0;         ts_poe=1'b1;          ts_noe=1'b1;          ts_pu=1'b0;         ts_pd=1'b0;         end   //push 0
      4'hd:   begin ts_ie=1'b0;     ts_do=1'b1;         ts_poe=1'b1;          ts_noe=1'b1;          ts_pu=1'b0;         ts_pd=1'b0;         end   //push 1
      4'he:   begin ts_ie=1'b0;     ts_do=1'b0;         ts_poe=1'b0;          ts_noe=1'b0;          ts_pu=1'b0;         ts_pd=1'b1;         end   //pull down 0
      4'hf:   begin ts_ie=1'b0;     ts_do=1'b0;         ts_poe=1'b0;          ts_noe=1'b0;          ts_pu=1'b1;         ts_pd=1'b0;         end   //pull up 1
    endcase
  end
end
//---------------------------------
endmodule
