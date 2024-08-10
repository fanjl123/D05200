`timescale  1ns/1ns

module  psfrm (
  input   wire          rst           ,
  input   wire          clk           ,
//  input   wire          run_ctrl      ,

  input   wire  [7:0]   gctrl         ,   output  reg   gctrl_wctrl     ,
  input   wire  [7:0]   gmode         ,   //output  reg   gmode_wctrl     ,
  input   wire  [7:0]   losc_cfr      ,   output  reg   losc_cfr_wctrl  ,
  input   wire  [7:0]   hosc_cfr      ,   output  reg   hosc_cfr_wctrl  ,
  input   wire  [7:0]   pwm_base      ,   output  reg   pwm_base_wctrl  ,
  input   wire  [7:0]   pwm_step      ,   output  reg   pwm_step_wctrl  ,

  input   wire  [7:0]   otp_cn        ,   output  reg   otp_cn_wctrl    ,
  input   wire  [7:0]   otp_dt        ,   output  reg   otp_dt_wctrl    ,
  input   wire  [7:0]   otp_ad        ,   output  reg   otp_ad_wctrl    ,
  input   wire  [7:0]   test_cn       ,   output  reg   test_cn_wctrl   ,

  input   wire  [7:0]   chk_ptcn      ,   output  reg   chk_ptcn_wctrl  ,
  input   wire  [7:0]   chk_cnt0      ,
  input   wire  [7:0]   chk_cnt1      ,
  input   wire  [7:0]   chk_bas0      ,
  input   wire  [7:0]   chk_bas1      ,
  input   wire  [7:0]   chk_sub0      ,
  input   wire  [7:0]   chk_sub1      ,
  input   wire  [7:0]   chk_sector    ,
  input   wire  [7:0]   chk_ptsub     ,
  input   wire  [7:0]   chk_slope     ,
  input   wire  [7:0]   chk_sctsub    ,
  input   wire  [7:0]   chk_ratio     ,
  input   wire  [7:0]   pwm_reg       ,
  input   wire  [7:0]   pwm_width     ,

  input   wire  [7:0]   chk_cn0       ,   output  reg   chk_cn0_wctrl   ,
  input   wire  [7:0]   chk_md0       ,   output  reg   chk_md0_wctrl   ,
  input   wire  [7:0]   chk_md1       ,   output  reg   chk_md1_wctrl   ,
  input   wire  [7:0]   chk_md2       ,   output  reg   chk_md2_wctrl   ,
  input   wire  [7:0]   chk_dbd0      ,   output  reg   chk_dbd0_wctrl  ,
  input   wire  [7:0]   chk_dbd1      ,   output  reg   chk_dbd1_wctrl  ,
  input   wire  [7:0]   point00l      ,   output  reg   point00l_wctrl  ,
  input   wire  [7:0]   point00h      ,   output  reg   point00h_wctrl  ,
  input   wire  [7:0]   point01l      ,   output  reg   point01l_wctrl  ,
  input   wire  [7:0]   point01h      ,   output  reg   point01h_wctrl  ,
  input   wire  [7:0]   point02l      ,   output  reg   point02l_wctrl  ,
  input   wire  [7:0]   point02h      ,   output  reg   point02h_wctrl  ,
  input   wire  [7:0]   point03l      ,   output  reg   point03l_wctrl  ,
  input   wire  [7:0]   point03h      ,   output  reg   point03h_wctrl  ,
  input   wire  [7:0]   point04l      ,   output  reg   point04l_wctrl  ,
  input   wire  [7:0]   point04h      ,   output  reg   point04h_wctrl  ,
  input   wire  [7:0]   point05l      ,   output  reg   point05l_wctrl  ,
  input   wire  [7:0]   point05h      ,   output  reg   point05h_wctrl  ,
  input   wire  [7:0]   point06l      ,   output  reg   point06l_wctrl  ,
  input   wire  [7:0]   point06h      ,   output  reg   point06h_wctrl  ,
  input   wire  [7:0]   point07l      ,   output  reg   point07l_wctrl  ,
  input   wire  [7:0]   point07h      ,   output  reg   point07h_wctrl  ,
  input   wire  [7:0]   point08l      ,   output  reg   point08l_wctrl  ,
  input   wire  [7:0]   point08h      ,   output  reg   point08h_wctrl  ,
  input   wire  [7:0]   point09l      ,   output  reg   point09l_wctrl  ,
  input   wire  [7:0]   point09h      ,   output  reg   point09h_wctrl  ,

  output  reg   [7:0]   sfr_rdata     ,
  input   wire  [5:0]   sfr_addrs     ,
  input   wire          sfr_rctrl     ,
  input   wire          sfr_wctrl
);
//--------------------------------------
reg   sfr_wctrl_r0;
reg   sfr_wctrl_r1;
wire  sfr_wctrl_pos;

always
@(negedge rst or posedge clk)
begin
  if(~rst)
  begin
    sfr_wctrl_r0  <=  1'b0;
    sfr_wctrl_r1  <=  1'b0;
  end
  else //if(run_ctrl)
  begin
    sfr_wctrl_r0  <=  sfr_wctrl;
    sfr_wctrl_r1  <=  sfr_wctrl_r0;
  end
end

assign  sfr_wctrl_pos = sfr_wctrl_r0 & ~sfr_wctrl_r1;
//--------------------------------------
always
@(*)
begin
  gctrl_wctrl     = 1'b0;
//  gmode_wctrl     = 1'b0;
  losc_cfr_wctrl  = 1'b0;
  hosc_cfr_wctrl  = 1'b0;
  pwm_base_wctrl  = 1'b0;
  pwm_step_wctrl  = 1'b0;
  otp_cn_wctrl    = 1'b0;
  otp_dt_wctrl    = 1'b0;
  otp_ad_wctrl    = 1'b0;
  test_cn_wctrl   = 1'b0;

  chk_ptcn_wctrl  = 1'b0;

  chk_cn0_wctrl   = 1'b0;
  chk_md0_wctrl   = 1'b0;
  chk_md1_wctrl   = 1'b0;
  chk_md2_wctrl   = 1'b0;
  chk_dbd0_wctrl  = 1'b0;
  chk_dbd1_wctrl  = 1'b0;
  point00l_wctrl  = 1'b0;
  point00h_wctrl  = 1'b0;
  point01l_wctrl  = 1'b0;
  point01h_wctrl  = 1'b0;
  point02l_wctrl  = 1'b0;
  point02h_wctrl  = 1'b0;
  point03l_wctrl  = 1'b0;
  point03h_wctrl  = 1'b0;
  point04l_wctrl  = 1'b0;
  point04h_wctrl  = 1'b0;
  point05l_wctrl  = 1'b0;
  point05h_wctrl  = 1'b0;
  point06l_wctrl  = 1'b0;
  point06h_wctrl  = 1'b0;
  point07l_wctrl  = 1'b0;
  point07h_wctrl  = 1'b0;
  point08l_wctrl  = 1'b0;
  point08h_wctrl  = 1'b0;
  point09l_wctrl  = 1'b0;
  point09h_wctrl  = 1'b0;

  case(sfr_addrs)
    6'h00:  begin sfr_rdata = 8'hd0     ;                                       end
    6'h01:  begin sfr_rdata = 8'h52     ;                                       end
    6'h02:  begin sfr_rdata = 8'h00     ;                                       end
    6'h03:  begin sfr_rdata = 8'h00     ;                                       end

    6'h04:  begin sfr_rdata = gctrl     ;   gctrl_wctrl       = sfr_wctrl_pos;  end
    6'h05:  begin sfr_rdata = gmode     ;   end//gmode_wctrl       = sfr_wctrl_pos;  end
    6'h06:  begin sfr_rdata = losc_cfr  ;   losc_cfr_wctrl    = sfr_wctrl_pos;  end
    6'h07:  begin sfr_rdata = hosc_cfr  ;   hosc_cfr_wctrl    = sfr_wctrl_pos;  end
    6'h08:  begin sfr_rdata = pwm_base  ;   pwm_base_wctrl    = sfr_wctrl_pos;  end
    6'h09:  begin sfr_rdata = pwm_step  ;   pwm_step_wctrl    = sfr_wctrl_pos;  end

    6'h0c:  begin sfr_rdata = otp_cn    ;   otp_cn_wctrl      = sfr_wctrl_pos;  end
    6'h0d:  begin sfr_rdata = otp_dt    ;   otp_dt_wctrl      = sfr_wctrl_pos;  end
    6'h0e:  begin sfr_rdata = otp_ad    ;   otp_ad_wctrl      = sfr_wctrl_pos;  end
    6'h0f:  begin sfr_rdata = test_cn   ;   test_cn_wctrl     = sfr_wctrl_pos;  end

    6'h10:  begin sfr_rdata = chk_ptcn  ;   chk_ptcn_wctrl    = sfr_wctrl_pos;  end
    6'h12:  begin sfr_rdata = chk_cnt0  ;                                       end
    6'h13:  begin sfr_rdata = chk_cnt1  ;                                       end
    6'h14:  begin sfr_rdata = chk_bas0  ;                                       end
    6'h15:  begin sfr_rdata = chk_bas1  ;                                       end
    6'h16:  begin sfr_rdata = chk_sub0  ;                                       end
    6'h17:  begin sfr_rdata = chk_sub1  ;                                       end
    6'h18:  begin sfr_rdata = chk_sector;                                       end
    6'h19:  begin sfr_rdata = chk_ptsub ;                                       end
    6'h1a:  begin sfr_rdata = chk_slope ;                                       end
    6'h1b:  begin sfr_rdata = chk_sctsub;                                       end
    6'h1c:  begin sfr_rdata = chk_ratio ;                                       end
    6'h1e:  begin sfr_rdata = pwm_reg   ;                                       end
    6'h1f:  begin sfr_rdata = pwm_width ;                                       end

    6'h20:  begin sfr_rdata = chk_cn0   ;   chk_cn0_wctrl     = sfr_wctrl_pos;  end
    6'h21:  begin sfr_rdata = chk_md0   ;   chk_md0_wctrl     = sfr_wctrl_pos;  end
    6'h22:  begin sfr_rdata = chk_md1   ;   chk_md1_wctrl     = sfr_wctrl_pos;  end
    6'h23:  begin sfr_rdata = chk_md2   ;   chk_md2_wctrl     = sfr_wctrl_pos;  end
    6'h24:  begin sfr_rdata = chk_dbd0  ;   chk_dbd0_wctrl    = sfr_wctrl_pos;  end
    6'h25:  begin sfr_rdata = chk_dbd1  ;   chk_dbd1_wctrl    = sfr_wctrl_pos;  end
    6'h26:  begin sfr_rdata = point00l  ;   point00l_wctrl    = sfr_wctrl_pos;  end
    6'h27:  begin sfr_rdata = point00h  ;   point00h_wctrl    = sfr_wctrl_pos;  end
    6'h28:  begin sfr_rdata = point01l  ;   point01l_wctrl    = sfr_wctrl_pos;  end
    6'h29:  begin sfr_rdata = point01h  ;   point01h_wctrl    = sfr_wctrl_pos;  end
    6'h2a:  begin sfr_rdata = point02l  ;   point02l_wctrl    = sfr_wctrl_pos;  end
    6'h2b:  begin sfr_rdata = point02h  ;   point02h_wctrl    = sfr_wctrl_pos;  end
    6'h2c:  begin sfr_rdata = point03l  ;   point03l_wctrl    = sfr_wctrl_pos;  end
    6'h2d:  begin sfr_rdata = point03h  ;   point03h_wctrl    = sfr_wctrl_pos;  end
    6'h2e:  begin sfr_rdata = point04l  ;   point04l_wctrl    = sfr_wctrl_pos;  end
    6'h2f:  begin sfr_rdata = point04h  ;   point04h_wctrl    = sfr_wctrl_pos;  end
    6'h30:  begin sfr_rdata = point05l  ;   point05l_wctrl    = sfr_wctrl_pos;  end
    6'h31:  begin sfr_rdata = point05h  ;   point05h_wctrl    = sfr_wctrl_pos;  end
    6'h32:  begin sfr_rdata = point06l  ;   point06l_wctrl    = sfr_wctrl_pos;  end
    6'h33:  begin sfr_rdata = point06h  ;   point06h_wctrl    = sfr_wctrl_pos;  end
    6'h34:  begin sfr_rdata = point07l  ;   point07l_wctrl    = sfr_wctrl_pos;  end
    6'h35:  begin sfr_rdata = point07h  ;   point07h_wctrl    = sfr_wctrl_pos;  end
    6'h36:  begin sfr_rdata = point08l  ;   point08l_wctrl    = sfr_wctrl_pos;  end
    6'h37:  begin sfr_rdata = point08h  ;   point08h_wctrl    = sfr_wctrl_pos;  end
    6'h38:  begin sfr_rdata = point09l  ;   point09l_wctrl    = sfr_wctrl_pos;  end
    6'h39:  begin sfr_rdata = point09h  ;   point09h_wctrl    = sfr_wctrl_pos;  end
    default:begin sfr_rdata = 8'h0;                                             end
  endcase
end
//--------------------------------------
endmodule
