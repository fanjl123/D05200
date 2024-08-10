`timescale 1ns/1ns

module d05200_dc_top(
  input   wire          RESET     ,
  output  wire          RESET_EN  ,

  input   wire          LCLK      ,     //32KHz
  output  wire  [7:0]   LCFR      ,

  input   wire          HCLK      ,     //28MHz
  input   wire          HRDY      ,
  output  wire          HENB      ,
  output  wire  [7:0]   HCFR      ,

  input   wire          SMOKE_CLK ,

  output  wire          OTP_CS    ,
  output  wire          OTP_READ  ,
  output  wire          OTP_PROG  ,
  output  wire  [6:0]   OTP_ADDR  ,
  output  wire  [7:0]   OTP_DATI  ,
  input   wire  [7:0]   OTP_DATO  ,

  input   wire          HL_SEL    ,

  output  wire          TS_IE     ,
  output  wire          TS_DO     ,
  output  wire          TS_POE    ,
  output  wire          TS_NOE    ,
  output  wire          TS_PU     ,
  output  wire          TS_PD     ,

  input   wire          OWL_DI    ,
  output  wire          OWL_IE    ,
  output  wire          OWL_DO    ,
  output  wire          OWL_POE   ,
  output  wire          OWL_NOE   ,
  output  wire          OWL_PU    ,
  output  wire          OWL_PD
);
//---------------------------------
wire          sysrst;
wire          sysclk;
wire          runclk;
//wire          runlclk;
//wire          runhclk;
wire          run_ctrl;
wire          speed_md;

wire          sfr_ready;
wire  [7:0]   sfr_rdata;
wire  [7:0]   sfr_wdata;
wire  [5:0]   sfr_addrs;
wire          sfr_rctrl;
wire          sfr_wctrl;
//---------------------------------
wire          clk_sel;

rcc u_rcc(
  .rst          (1'b1         ),
  .sysclk       (sysclk       ),
  .runclk       (runclk       ),
//  .runlclk      (runlclk      ),
//  .runhclk      (runhclk      ),
  .run_ctrl     (run_ctrl     ),
//  .speed_md     (speed_md     ),
  .clk_sel      (clk_sel      ),
  .lclk         (LCLK         ),
  .hclk         (HCLK         )
);
//---------------------------------
wire          owl_di_w  ;
wire          owl_do_w  ;
wire          owl_oe_w  ;

owl_ctrl  u_owl_ctrl(
  .rst          (sysrst       ),
  .clk          (runclk       ),
//  .run_ctrl     (run_ctrl     ),
  .clk_sel      (clk_sel      ),

  .owl_di_w     (owl_di_w     ),
  .owl_do_w     (owl_do_w     ),
  .owl_oe_w     (owl_oe_w     ),

  .sfr_ready    (sfr_ready    ),
  .sfr_rdata    (sfr_rdata    ),
  .sfr_wdata    (sfr_wdata    ),
  .sfr_addrs    (sfr_addrs    ),
  .sfr_rctrl    (sfr_rctrl    ),
  .sfr_wctrl    (sfr_wctrl    )
);
//---------------------------------
wire    tclk32ms    ;
wire    tclk32ms_neg;
wire    tclk1ms_h   ;
wire    tclk1ms_pos ;

tim1ms u_tim1ms(
  .rst          (sysrst       ),
  .clk          (sysclk       ),
  .lclk         (LCLK         ),
  .tclk32ms     (tclk32ms     ),
  .tclk32ms_neg (tclk32ms_neg ),
  .tclk1ms_h    (tclk1ms_h    ),
  .tclk1ms_pos  (tclk1ms_pos  )
);
//---------------------------------
wire  [15:0]  mic_lct;

mic_lclk_cnt  u_miclct(
  .rst          (sysrst       ),
  .mic_clk      (SMOKE_CLK    ),
  .tclk         (tclk32ms     ),
  .mic_cnt      (mic_lct      )
);
//---------------------------------
wire  [15:0]  mic_hct;
wire          mic_clk_pos;

mic_hclk_cnt  u_michct(
  .rst          (sysrst       ),
  .clk          (sysclk       ),
  .speed_md     (speed_md     ),
  .mic_clk      (SMOKE_CLK    ),
  .mic_clk_pos  (mic_clk_pos  ),
  .mic_cnt      (mic_hct      )
);
//---------------------------------
wire          pwm_oen   ;
wire          pwm_mod   ;
wire  [7:0]   pwm_width ;
wire          pwm_out   ;

pwm_gen u_pwm_gen(
  .rst          (sysrst       ),
  .clk          (LCLK         ),
  .run_ctrl     (run_ctrl     ),
  .pwm_oen      (pwm_oen      ),
  .pwm_mod      (pwm_mod      ),
  .pwm_width    (pwm_width    ),
  .pwm_out      (pwm_out      )
);
//---------------------------------
wire          rom_wctrl ;
wire          rom_rctrl ;
wire  [6:0]   rom_addrs ;
wire  [7:0]   rom_wdata ;
wire  [7:0]   rom_rdata ;
wire          rom_ready ;

otp_if  u_otp_if(
  .rst          (sysrst       ),
  .clk          (LCLK         ),
  .run_ctrl     (run_ctrl     ),

  .otp_cs       (OTP_CS       ),
  .otp_read     (OTP_READ     ),
  .otp_prog     (OTP_PROG     ),
  .otp_addr     (OTP_ADDR     ),
  .otp_dati     (OTP_DATI     ),
  .otp_dato     (OTP_DATO     ),

  .rom_wctrl    (rom_wctrl    ),
  .rom_rctrl    (rom_rctrl    ),
  .rom_addrs    (rom_addrs    ),
  .rom_wdata    (rom_wdata    ),
  .rom_rdata    (rom_rdata    ),
  .rom_ready    (rom_ready    )
);

//---------------------------------
wire          muldiv_int;
                                wire    muldiv_cn_wctrl ;
                                wire    muldiv_ar_wctrl ;
wire  [7:0]   muldiv_br ;       wire    muldiv_br_wctrl ;
wire  [7:0]   muldiv_hr ;       wire    muldiv_hr_wctrl ;
wire  [7:0]   muldiv_cr ;       wire    muldiv_cr_wctrl ;
wire  [7:0]   muldiv_dt ;

mul_divider u_mul_div(
  .rst          (sysrst       ),
  .clk          (runclk       ),
//  .run_ctrl     (run_ctrl     ),
  .muldiv_int   (muldiv_int   ),
//  .muldiv_cn    (             ),
                                    .muldiv_cn_wctrl(muldiv_cn_wctrl  ),
//  .muldiv_ar    (             ),
                                    .muldiv_ar_wctrl(muldiv_ar_wctrl  ),
  .muldiv_br    (muldiv_br    ),    .muldiv_br_wctrl(muldiv_br_wctrl  ),
  .muldiv_hr    (muldiv_hr    ),    .muldiv_hr_wctrl(muldiv_hr_wctrl  ),
  .muldiv_cr    (muldiv_cr    ),    .muldiv_cr_wctrl(muldiv_cr_wctrl  ),
  .dbus_wdata   (muldiv_dt    )
);
//---------------------------------

wire  [7:0]   gctrl       ;    wire  gctrl_wctrl      ;
wire  [7:0]   gmode       ;    //wire  gmode_wctrl      ;
wire  [7:0]   losc_cfr    ;    wire  losc_cfr_wctrl   ;
wire  [7:0]   hosc_cfr    ;    wire  hosc_cfr_wctrl   ;
wire  [7:0]   pwm_base    ;    wire  pwm_base_wctrl   ;
wire  [7:0]   pwm_step    ;    wire  pwm_step_wctrl   ;

wire  [7:0]   otp_cn      ;    wire  otp_cn_wctrl     ;
wire  [7:0]   otp_dt      ;    wire  otp_dt_wctrl     ;
wire  [7:0]   otp_ad      ;    wire  otp_ad_wctrl     ;
wire  [7:0]   test_cn     ;    wire  test_cn_wctrl    ;

wire  [7:0]   chk_ptcn    ;    wire  chk_ptcn_wctrl   ;
wire  [7:0]   chk_cnt0    ;
wire  [7:0]   chk_cnt1    ;
wire  [7:0]   chk_bas0    ;
wire  [7:0]   chk_bas1    ;
wire  [7:0]   chk_sub0    ;
wire  [7:0]   chk_sub1    ;
wire  [7:0]   chk_sector  ;
wire  [7:0]   chk_ptsub   ;
wire  [7:0]   chk_slope   ;
wire  [7:0]   chk_sctsub  ;
wire  [7:0]   chk_ratio   ;
wire  [7:0]   pwm_reg     ;
//wire  [7:0]   pwm_width   ;


wire  [7:0]   chk_cn0     ;    wire  chk_cn0_wctrl  ;
wire  [7:0]   chk_md0     ;    wire  chk_md0_wctrl  ;
wire  [7:0]   chk_md1     ;    wire  chk_md1_wctrl  ;
wire  [7:0]   chk_md2     ;    wire  chk_md2_wctrl  ;
wire  [7:0]   chk_dbd0    ;    wire  chk_dbd0_wctrl ;
wire  [7:0]   chk_dbd1    ;    wire  chk_dbd1_wctrl ;
wire  [7:0]   point00l    ;    wire  point00l_wctrl ;
wire  [7:0]   point00h    ;    wire  point00h_wctrl ;
wire  [7:0]   point01l    ;    wire  point01l_wctrl ;
wire  [7:0]   point01h    ;    wire  point01h_wctrl ;
wire  [7:0]   point02l    ;    wire  point02l_wctrl ;
wire  [7:0]   point02h    ;    wire  point02h_wctrl ;
wire  [7:0]   point03l    ;    wire  point03l_wctrl ;
wire  [7:0]   point03h    ;    wire  point03h_wctrl ;
wire  [7:0]   point04l    ;    wire  point04l_wctrl ;
wire  [7:0]   point04h    ;    wire  point04h_wctrl ;
wire  [7:0]   point05l    ;    wire  point05l_wctrl ;
wire  [7:0]   point05h    ;    wire  point05h_wctrl ;
wire  [7:0]   point06l    ;    wire  point06l_wctrl ;
wire  [7:0]   point06h    ;    wire  point06h_wctrl ;
wire  [7:0]   point07l    ;    wire  point07l_wctrl ;
wire  [7:0]   point07h    ;    wire  point07h_wctrl ;
wire  [7:0]   point08l    ;    wire  point08l_wctrl ;
wire  [7:0]   point08h    ;    wire  point08h_wctrl ;
wire  [7:0]   point09l    ;    wire  point09l_wctrl ;
wire  [7:0]   point09h    ;    wire  point09h_wctrl ;


main_ctrl u_main_ctrl(
  .reset        (RESET        ),
  .reset_en     (RESET_EN     ),
  .sysrst       (sysrst       ),
  .sysclk       (sysclk       ),
  .clk          (runclk       ),
  .clk_sel      (clk_sel      ),
  .run_ctrl     (run_ctrl     ),
  .speed_mode   (speed_md     ),
  .mic_clk      (SMOKE_CLK    ),
  .mic_clk_pos  (mic_clk_pos  ),

  .lclk         (LCLK         ),
  .lcfr         (LCFR         ),
  .hclk         (HCLK         ),
  .hrdy         (HRDY         ),
  .henb         (HENB         ),
  .hcfr         (HCFR         ),

  .tclk1ms_h    (tclk1ms_h    ),
  .tclk1ms_pos  (tclk1ms_pos  ),
  .tclk32ms_neg (tclk32ms_neg ),
  .mic_lct      (mic_lct      ),
  .mic_hct      (mic_hct      ),

  .pwm_oen      (pwm_oen      ),
  .pwm_mod      (pwm_mod      ),
  .pwm_out      (pwm_out      ),

  .owl_di_w     (owl_di_w     ),
  .owl_do_w     (owl_do_w     ),
  .owl_oe_w     (owl_oe_w     ),

  .owl_di       (OWL_DI       ),
  .owl_ie       (OWL_IE       ),
  .owl_do       (OWL_DO       ),
  .owl_poe      (OWL_POE      ),
  .owl_noe      (OWL_NOE      ),
  .owl_pu       (OWL_PU       ),
  .owl_pd       (OWL_PD       ),

  .hl_sel       (HL_SEL       ),

  .ts_ie        (TS_IE        ),
  .ts_do        (TS_DO        ),
  .ts_poe       (TS_POE       ),
  .ts_noe       (TS_NOE       ),
  .ts_pu        (TS_PU        ),
  .ts_pd        (TS_PD        ),

  .rom_wctrl    (rom_wctrl    ),
  .rom_rctrl    (rom_rctrl    ),
  .rom_addrs    (rom_addrs    ),
  .rom_wdata    (rom_wdata    ),
  .rom_rdata    (rom_rdata    ),
  .rom_ready    (rom_ready    ),

  .muldiv_int   (muldiv_int   ),
                                    .muldiv_cn_wctrl  (muldiv_cn_wctrl  ),
                                    .muldiv_ar_wctrl  (muldiv_ar_wctrl  ),
  .muldiv_br    (muldiv_br    ),    .muldiv_br_wctrl  (muldiv_br_wctrl  ),
  .muldiv_hr    (muldiv_hr    ),    .muldiv_hr_wctrl  (muldiv_hr_wctrl  ),
  .muldiv_cr    (muldiv_cr    ),    .muldiv_cr_wctrl  (muldiv_cr_wctrl  ),
  .muldiv_dt    (muldiv_dt    ),

  .gctrl        (gctrl        ),    .gctrl_wctrl      (gctrl_wctrl      ),
  .gmode        (gmode        ),    //.gmode_wctrl      (gmode_wctrl      ),
  .losc_cfr     (losc_cfr     ),    .losc_cfr_wctrl   (losc_cfr_wctrl   ),
  .hosc_cfr     (hosc_cfr     ),    .hosc_cfr_wctrl   (hosc_cfr_wctrl   ),
  .pwm_base     (pwm_base     ),    .pwm_base_wctrl   (pwm_base_wctrl   ),
  .pwm_step     (pwm_step     ),    .pwm_step_wctrl   (pwm_step_wctrl   ),

  .otp_cn       (otp_cn       ),    .otp_cn_wctrl     (otp_cn_wctrl     ),
  .otp_dt       (otp_dt       ),    .otp_dt_wctrl     (otp_dt_wctrl     ),
  .otp_ad       (otp_ad       ),    .otp_ad_wctrl     (otp_ad_wctrl     ),
  .test_cn      (test_cn      ),    .test_cn_wctrl    (test_cn_wctrl    ),

  .chk_ptcn     (chk_ptcn     ),    .chk_ptcn_wctrl   (chk_ptcn_wctrl   ),
  .chk_cnt0     (chk_cnt0     ),
  .chk_cnt1     (chk_cnt1     ),
  .chk_bas0     (chk_bas0     ),
  .chk_bas1     (chk_bas1     ),
  .chk_sub0     (chk_sub0     ),
  .chk_sub1     (chk_sub1     ),
  .chk_sector   (chk_sector   ),
  .chk_ptsub    (chk_ptsub    ),
  .chk_slope    (chk_slope    ),
  .chk_sctsub   (chk_sctsub   ),
  .chk_ratio    (chk_ratio    ),
  .pwm_reg      (pwm_reg      ),
  .pwm_width    (pwm_width    ),

  .chk_cn0      (chk_cn0      ),    .chk_cn0_wctrl    (chk_cn0_wctrl    ),
  .chk_md0      (chk_md0      ),    .chk_md0_wctrl    (chk_md0_wctrl    ),
  .chk_md1      (chk_md1      ),    .chk_md1_wctrl    (chk_md1_wctrl    ),
  .chk_md2      (chk_md2      ),    .chk_md2_wctrl    (chk_md2_wctrl    ),
  .chk_dbd0     (chk_dbd0     ),    .chk_dbd0_wctrl   (chk_dbd0_wctrl   ),
  .chk_dbd1     (chk_dbd1     ),    .chk_dbd1_wctrl   (chk_dbd1_wctrl   ),
  .point00l     (point00l     ),    .point00l_wctrl   (point00l_wctrl   ),
  .point00h     (point00h     ),    .point00h_wctrl   (point00h_wctrl   ),
  .point01l     (point01l     ),    .point01l_wctrl   (point01l_wctrl   ),
  .point01h     (point01h     ),    .point01h_wctrl   (point01h_wctrl   ),
  .point02l     (point02l     ),    .point02l_wctrl   (point02l_wctrl   ),
  .point02h     (point02h     ),    .point02h_wctrl   (point02h_wctrl   ),
  .point03l     (point03l     ),    .point03l_wctrl   (point03l_wctrl   ),
  .point03h     (point03h     ),    .point03h_wctrl   (point03h_wctrl   ),
  .point04l     (point04l     ),    .point04l_wctrl   (point04l_wctrl   ),
  .point04h     (point04h     ),    .point04h_wctrl   (point04h_wctrl   ),
  .point05l     (point05l     ),    .point05l_wctrl   (point05l_wctrl   ),
  .point05h     (point05h     ),    .point05h_wctrl   (point05h_wctrl   ),
  .point06l     (point06l     ),    .point06l_wctrl   (point06l_wctrl   ),
  .point06h     (point06h     ),    .point06h_wctrl   (point06h_wctrl   ),
  .point07l     (point07l     ),    .point07l_wctrl   (point07l_wctrl   ),
  .point07h     (point07h     ),    .point07h_wctrl   (point07h_wctrl   ),
  .point08l     (point08l     ),    .point08l_wctrl   (point08l_wctrl   ),
  .point08h     (point08h     ),    .point08h_wctrl   (point08h_wctrl   ),
  .point09l     (point09l     ),    .point09l_wctrl   (point09l_wctrl   ),
  .point09h     (point09h     ),    .point09h_wctrl   (point09h_wctrl   ),

  .sfr_ready    (sfr_ready    ),
  .sfr_wdata    (sfr_wdata    )
);
//---------------------------------
psfrm u_psfrm(
  .rst          (sysrst       ),
  .clk          (runclk       ),
//  .run_ctrl     (run_ctrl     ),

  .gctrl        (gctrl        ),    .gctrl_wctrl      (gctrl_wctrl      ),
  .gmode        (gmode        ),    //.gmode_wctrl      (gmode_wctrl      ),
  .losc_cfr     (losc_cfr     ),    .losc_cfr_wctrl   (losc_cfr_wctrl   ),
  .hosc_cfr     (hosc_cfr     ),    .hosc_cfr_wctrl   (hosc_cfr_wctrl   ),
  .pwm_base     (pwm_base     ),    .pwm_base_wctrl   (pwm_base_wctrl   ),
  .pwm_step     (pwm_step     ),    .pwm_step_wctrl   (pwm_step_wctrl   ),

  .otp_cn       (otp_cn       ),    .otp_cn_wctrl     (otp_cn_wctrl     ),
  .otp_dt       (otp_dt       ),    .otp_dt_wctrl     (otp_dt_wctrl     ),
  .otp_ad       (otp_ad       ),    .otp_ad_wctrl     (otp_ad_wctrl     ),
  .test_cn      (test_cn      ),    .test_cn_wctrl    (test_cn_wctrl    ),

  .chk_ptcn     (chk_ptcn     ),    .chk_ptcn_wctrl   (chk_ptcn_wctrl   ),
  .chk_cnt0     (chk_cnt0     ),
  .chk_cnt1     (chk_cnt1     ),
  .chk_bas0     (chk_bas0     ),
  .chk_bas1     (chk_bas1     ),
  .chk_sub0     (chk_sub0     ),
  .chk_sub1     (chk_sub1     ),
  .chk_sector   (chk_sector   ),
  .chk_ptsub    (chk_ptsub    ),
  .chk_slope    (chk_slope    ),
  .chk_sctsub   (chk_sctsub   ),
  .chk_ratio    (chk_ratio    ),
  .pwm_reg      (pwm_reg      ),
  .pwm_width    (pwm_width    ),

  .chk_cn0      (chk_cn0      ),    .chk_cn0_wctrl    (chk_cn0_wctrl    ),
  .chk_md0      (chk_md0      ),    .chk_md0_wctrl    (chk_md0_wctrl    ),
  .chk_md1      (chk_md1      ),    .chk_md1_wctrl    (chk_md1_wctrl    ),
  .chk_md2      (chk_md2      ),    .chk_md2_wctrl    (chk_md2_wctrl    ),
  .chk_dbd0     (chk_dbd0     ),    .chk_dbd0_wctrl   (chk_dbd0_wctrl   ),
  .chk_dbd1     (chk_dbd1     ),    .chk_dbd1_wctrl   (chk_dbd1_wctrl   ),
  .point00l     (point00l     ),    .point00l_wctrl   (point00l_wctrl   ),
  .point00h     (point00h     ),    .point00h_wctrl   (point00h_wctrl   ),
  .point01l     (point01l     ),    .point01l_wctrl   (point01l_wctrl   ),
  .point01h     (point01h     ),    .point01h_wctrl   (point01h_wctrl   ),
  .point02l     (point02l     ),    .point02l_wctrl   (point02l_wctrl   ),
  .point02h     (point02h     ),    .point02h_wctrl   (point02h_wctrl   ),
  .point03l     (point03l     ),    .point03l_wctrl   (point03l_wctrl   ),
  .point03h     (point03h     ),    .point03h_wctrl   (point03h_wctrl   ),
  .point04l     (point04l     ),    .point04l_wctrl   (point04l_wctrl   ),
  .point04h     (point04h     ),    .point04h_wctrl   (point04h_wctrl   ),
  .point05l     (point05l     ),    .point05l_wctrl   (point05l_wctrl   ),
  .point05h     (point05h     ),    .point05h_wctrl   (point05h_wctrl   ),
  .point06l     (point06l     ),    .point06l_wctrl   (point06l_wctrl   ),
  .point06h     (point06h     ),    .point06h_wctrl   (point06h_wctrl   ),
  .point07l     (point07l     ),    .point07l_wctrl   (point07l_wctrl   ),
  .point07h     (point07h     ),    .point07h_wctrl   (point07h_wctrl   ),
  .point08l     (point08l     ),    .point08l_wctrl   (point08l_wctrl   ),
  .point08h     (point08h     ),    .point08h_wctrl   (point08h_wctrl   ),
  .point09l     (point09l     ),    .point09l_wctrl   (point09l_wctrl   ),
  .point09h     (point09h     ),    .point09h_wctrl   (point09h_wctrl   ),

  .sfr_rdata    (sfr_rdata    ),
  .sfr_addrs    (sfr_addrs    ),
  .sfr_rctrl    (sfr_rctrl    ),
  .sfr_wctrl    (sfr_wctrl    )
);

//---------------------------------
endmodule
