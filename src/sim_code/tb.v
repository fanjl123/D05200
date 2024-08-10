`timescale 1ns/1ns

module _tb;
reg          rst       ;
wire         clk       ;
wire         mic_clk   ;
reg          smoke_clk ;
reg          tb_error  ;

reg          MOD_R     ;
wire         SEL =MOD_R;
reg   [6:0]  sfr_addrs ;
reg          sfr_cmd   ;
reg   [7:0]  sfr_num   ;
reg   [7:0]  sfr_wdata ;
reg          sfr_wen   ;


wire    owl_inout;

wire          TSO;
wire          VDD;
wire          GND;
wire          VPP;

assign mic_clk = smoke_clk;
d05200_asic_top u_asic_top(
  .AVDD        (VDD        ),
  .AGND        (GND        ),
  .VPP         (VPP        ),

  .OUT         (owl_inout  ),
  .SW          (mic_clk    ),
  .SEL         (SEL        ),
  .TSO         (TSO        )
);

owl_mctrl  u_master(
  .rst         (rst       ),
  .clk         (clk       ),
  .owl_inout   (owl_inout ),
  .sfr_cmd_w   (sfr_cmd   ),
  .sfr_addrs_w (sfr_addrs ),
  .sfr_num_w   (sfr_num   ),
  .sfr_wdata_w (sfr_wdata ),
  .sfr_wen     (sfr_wen   )
);
//---------------------------------------时钟以及复位 等信号逻辑---------------------------------
initial
begin
                   rst <=  1'b1;
  #4001            rst <=  1'b0;
  #1001            rst <=  1'b1;
end

reg en0;
reg en1;
reg en2;
reg s0_clk;
reg s1_clk;
reg s2_clk;
reg s3_clk;
reg s4_clk;
reg count134_en;
reg [7:0]   count1    ;
reg [11:0]  count3    ;
reg [15:0]  count4    ;
reg [7:0]   count5    ;
reg [11:0]  count6    ;
reg [19:0]  count7    ;
reg [7:0]   count8    ;
reg [11:0]  count9    ;
reg [11:0]  counta    ;
reg [15:0]  countb    ;
initial
begin
               count134_en <= 1'b1;
               en0         <= 1'b0;
  #300000000   en0         <= 1'b0;
  #250000000   en0         <= 1'b1;
end

//---------------------------------------------测试项目切换（二线模式在数模混合仿真的时候进行）--------------------------------------------------------------------
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//-----------数模混合仿真----------
localparam    test1d = 8'h1d;//低速、三线、OWL时间介入窗口、工作模式下不输出、OWL被动输出带中断模式、MOD_R=1'b0、电容增大型、6点标定
localparam    test1e = 8'h1e;//低速、两线、OWL时间介入窗口、PWM正输出、MOD_R=1'b0、电容增大型、6点标定
localparam    test1f = 8'h1f;//低速、两线、工作模式下不输出、FM输出模式、MOD_R=1'b1
localparam    test20 = 8'h20;//上电复位测试、
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------------------------------------------------
wire  [7:0] total_item    ;
reg   [5:0] test_otp_item ;
reg   [3:0] test_otp_point;
reg   [1:0] point_sel     ;
reg   [3:0] test_owl_item ;

assign total_item = test20;

always@(*)
begin
  case(total_item)
//--测试项-------otp控制寄存器--------otp标定点寄存器------owl置数环节---------标定模式选择----外接MOD选择---------smoke_clk-----------------------//
    test1d: begin test_otp_item=6'h16; test_otp_point=4'h6; test_owl_item=4'h7; point_sel=2'h0;   MOD_R=1'b0; smoke_clk =en0?(count1==count3):s0_clk; end
    test1e: begin test_otp_item=6'h17; test_otp_point=4'h6; test_owl_item=4'hb; point_sel=2'h0;   MOD_R=1'b0; smoke_clk =en0?(count1==count3):s0_clk; end
    test1f: begin test_otp_item=6'h18; test_otp_point=4'h6; test_owl_item=4'hb; point_sel=2'h0;   MOD_R=1'b1; smoke_clk =en0?(count1==count3):s0_clk; end
    test20: begin test_otp_item=6'h19; test_otp_point=4'h6; test_owl_item=4'hd; point_sel=2'h0;   MOD_R=1'b1; smoke_clk =en0?(count1==count3):s0_clk; end
  endcase
end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//------------------------------------------------------------------------------------------------------------------------------
initial
begin
#20
  case(test_otp_item)
  6'h16://低速、三线、电容增大型、OWL时间介入窗口、工作模式下不输出、OWL被动输出带中断模式、MOD_R=1'b0
    begin
    _tb.u_asic_top.u_otp.nvmCell[112]<=16'hd0;//数据认证d00
    _tb.u_asic_top.u_otp.nvmCell[113]<=16'h52;//数据认证522
    _tb.u_asic_top.u_otp.nvmCell[114]<=16'h82;//test_cn寄存器
    _tb.u_asic_top.u_otp.nvmCell[115]<=16'h80;//低频矫正
    _tb.u_asic_top.u_otp.nvmCell[116]<=16'h80;//高频矫正
    _tb.u_asic_top.u_otp.nvmCell[117]<=16'hff;//OTP扇区选择
    _tb.u_asic_top.u_otp.nvmCell[118]<=16'haa;//
    _tb.u_asic_top.u_otp.nvmCell[119]<=16'haa;//
    _tb.u_asic_top.u_otp.nvmCell[120]<=16'hd0;//
    _tb.u_asic_top.u_otp.nvmCell[121]<=16'h52;//
    _tb.u_asic_top.u_otp.nvmCell[122]<=16'hd0;//数据认证d0
    _tb.u_asic_top.u_otp.nvmCell[123]<=16'h52;//数据认证52
    _tb.u_asic_top.u_otp.nvmCell[124]<=16'h80;//gctrl寄存器
    _tb.u_asic_top.u_otp.nvmCell[125]<=16'h00;//gmode寄存器
    _tb.u_asic_top.u_otp.nvmCell[126]<=16'h33;//pwm_base
    _tb.u_asic_top.u_otp.nvmCell[127]<=16'h26;//pwm_step
    _tb.u_asic_top.u_otp.nvmCell[0]  <=16'h15;//chk_cn0寄存器
    _tb.u_asic_top.u_otp.nvmCell[1]  <=16'hff;//chk_md0寄存器
    _tb.u_asic_top.u_otp.nvmCell[2]  <=16'h03;//chk_md1寄存器
    _tb.u_asic_top.u_otp.nvmCell[3]  <=16'h05;//chk_md2寄存器
    _tb.u_asic_top.u_otp.nvmCell[4]  <=16'h05;//死区气压值0
    _tb.u_asic_top.u_otp.nvmCell[5]  <=16'h00;//死区气压值1
    end
  6'h17://低速、两线、OWL时间介入窗口、PWM正输出、MOD_R=1'b0、电容增大型、6点标定
    begin
    _tb.u_asic_top.u_otp.nvmCell[112]<=16'hd0;//数据认证d00
    _tb.u_asic_top.u_otp.nvmCell[113]<=16'h52;//数据认证522
    _tb.u_asic_top.u_otp.nvmCell[114]<=16'h02;//test_cn寄存器
    _tb.u_asic_top.u_otp.nvmCell[115]<=16'h80;//低频矫正
    _tb.u_asic_top.u_otp.nvmCell[116]<=16'h80;//高频矫正
    _tb.u_asic_top.u_otp.nvmCell[117]<=16'hff;//OTP扇区选择
    _tb.u_asic_top.u_otp.nvmCell[118]<=16'haa;//
    _tb.u_asic_top.u_otp.nvmCell[119]<=16'haa;//
    _tb.u_asic_top.u_otp.nvmCell[120]<=16'hd0;//
    _tb.u_asic_top.u_otp.nvmCell[121]<=16'h52;//
    _tb.u_asic_top.u_otp.nvmCell[122]<=16'hd0;//数据认证d0
    _tb.u_asic_top.u_otp.nvmCell[123]<=16'h52;//数据认证52
    _tb.u_asic_top.u_otp.nvmCell[124]<=16'ha0;//gctrl寄存器
    _tb.u_asic_top.u_otp.nvmCell[125]<=16'h00;//gmode寄存器
    _tb.u_asic_top.u_otp.nvmCell[126]<=16'h33;//pwm_base
    _tb.u_asic_top.u_otp.nvmCell[127]<=16'h26;//pwm_step
    _tb.u_asic_top.u_otp.nvmCell[0]  <=16'h10;//chk_cn0寄存器
    _tb.u_asic_top.u_otp.nvmCell[1]  <=16'hff;//chk_md0寄存器
    _tb.u_asic_top.u_otp.nvmCell[2]  <=16'h03;//chk_md1寄存器
    _tb.u_asic_top.u_otp.nvmCell[3]  <=16'h05;//chk_md2寄存器
    _tb.u_asic_top.u_otp.nvmCell[4]  <=16'h05;//死区气压值0
    _tb.u_asic_top.u_otp.nvmCell[5]  <=16'h00;//死区气压值1
    end
  6'h18://低速、两线、OWL时间介入窗口、PWM正输出、MOD_R=1'b0、电容增大型、6点标定
    begin
    _tb.u_asic_top.u_otp.nvmCell[112]<=16'hd0;//数据认证d00
    _tb.u_asic_top.u_otp.nvmCell[113]<=16'h52;//数据认证522
    _tb.u_asic_top.u_otp.nvmCell[114]<=16'h00;//test_cn寄存器
    _tb.u_asic_top.u_otp.nvmCell[115]<=16'h00;//低频矫正
    _tb.u_asic_top.u_otp.nvmCell[116]<=16'h08;//高频矫正
    _tb.u_asic_top.u_otp.nvmCell[117]<=16'hff;//OTP扇区选择
    _tb.u_asic_top.u_otp.nvmCell[118]<=16'haa;//
    _tb.u_asic_top.u_otp.nvmCell[119]<=16'haa;//
    _tb.u_asic_top.u_otp.nvmCell[120]<=16'hd0;//
    _tb.u_asic_top.u_otp.nvmCell[121]<=16'h52;//
    _tb.u_asic_top.u_otp.nvmCell[122]<=16'hd0;//数据认证d0
    _tb.u_asic_top.u_otp.nvmCell[123]<=16'h52;//数据认证52
    _tb.u_asic_top.u_otp.nvmCell[124]<=16'ha0;//gctrl寄存器
    _tb.u_asic_top.u_otp.nvmCell[125]<=16'h00;//gmode寄存器
    _tb.u_asic_top.u_otp.nvmCell[126]<=16'h33;//pwm_base
    _tb.u_asic_top.u_otp.nvmCell[127]<=16'h26;//pwm_step
    _tb.u_asic_top.u_otp.nvmCell[0]  <=16'h10;//chk_cn0寄存器
    _tb.u_asic_top.u_otp.nvmCell[1]  <=16'hff;//chk_md0寄存器
    _tb.u_asic_top.u_otp.nvmCell[2]  <=16'h03;//chk_md1寄存器
    _tb.u_asic_top.u_otp.nvmCell[3]  <=16'h05;//chk_md2寄存器
    _tb.u_asic_top.u_otp.nvmCell[4]  <=16'h05;//死区气压值0
    _tb.u_asic_top.u_otp.nvmCell[5]  <=16'h00;//死区气压值1
    end
  6'h19://复位不使能
    begin
    _tb.u_asic_top.u_otp.nvmCell[112]<=16'hd0;//数据认证d00
    _tb.u_asic_top.u_otp.nvmCell[113]<=16'h52;//数据认证522
    _tb.u_asic_top.u_otp.nvmCell[114]<=16'h00;//test_cn寄存器
    _tb.u_asic_top.u_otp.nvmCell[115]<=16'h00;//低频矫正
    _tb.u_asic_top.u_otp.nvmCell[116]<=16'h08;//高频矫正
    _tb.u_asic_top.u_otp.nvmCell[117]<=16'hff;//OTP扇区选择
    _tb.u_asic_top.u_otp.nvmCell[118]<=16'haa;//
    _tb.u_asic_top.u_otp.nvmCell[119]<=16'haa;//
    _tb.u_asic_top.u_otp.nvmCell[120]<=16'hd0;//
    _tb.u_asic_top.u_otp.nvmCell[121]<=16'h52;//
    _tb.u_asic_top.u_otp.nvmCell[122]<=16'hd0;//数据认证d0
    _tb.u_asic_top.u_otp.nvmCell[123]<=16'h52;//数据认证52
    _tb.u_asic_top.u_otp.nvmCell[124]<=16'h00;//gctrl寄存器
    _tb.u_asic_top.u_otp.nvmCell[125]<=16'h00;//gmode寄存器
    _tb.u_asic_top.u_otp.nvmCell[126]<=16'h33;//pwm_base
    _tb.u_asic_top.u_otp.nvmCell[127]<=16'h26;//pwm_step
    _tb.u_asic_top.u_otp.nvmCell[0]  <=16'h10;//chk_cn0寄存器
    _tb.u_asic_top.u_otp.nvmCell[1]  <=16'hff;//chk_md0寄存器
    _tb.u_asic_top.u_otp.nvmCell[2]  <=16'h03;//chk_md1寄存器
    _tb.u_asic_top.u_otp.nvmCell[3]  <=16'h05;//chk_md2寄存器
    _tb.u_asic_top.u_otp.nvmCell[4]  <=16'h05;//死区气压值0
    _tb.u_asic_top.u_otp.nvmCell[5]  <=16'h00;//死区气压值1
    end
  endcase
end
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
initial
begin
#20
  case(test_otp_point)
  4'h2:
    begin
    _tb.u_asic_top.u_otp.nvmCell[6]  <=16'h07;//POINT00L
    _tb.u_asic_top.u_otp.nvmCell[7]  <=16'h00;//POINT00H
    _tb.u_asic_top.u_otp.nvmCell[8]  <=16'hdb;//POINT01L
    _tb.u_asic_top.u_otp.nvmCell[9]  <=16'h01;//POINT01H
    _tb.u_asic_top.u_otp.nvmCell[10] <=16'hff;//POINT02L
    _tb.u_asic_top.u_otp.nvmCell[11] <=16'hff;//POINT02H
    _tb.u_asic_top.u_otp.nvmCell[12] <=16'hff;//POINT03L
    _tb.u_asic_top.u_otp.nvmCell[13] <=16'hff;//POINT03H
    _tb.u_asic_top.u_otp.nvmCell[14] <=16'hff;//POINT04L
    _tb.u_asic_top.u_otp.nvmCell[15] <=16'hff;//POINT04H
    _tb.u_asic_top.u_otp.nvmCell[16] <=16'hff;//POINT05L
    _tb.u_asic_top.u_otp.nvmCell[17] <=16'hff;//POINT05H
    _tb.u_asic_top.u_otp.nvmCell[18] <=16'hff;//POINT06L
    _tb.u_asic_top.u_otp.nvmCell[19] <=16'hff;//POINT06H
    _tb.u_asic_top.u_otp.nvmCell[20] <=16'hff;//POINT07L
    _tb.u_asic_top.u_otp.nvmCell[21] <=16'hff;//POINT07H
    _tb.u_asic_top.u_otp.nvmCell[22] <=16'hff;//POINT08L
    _tb.u_asic_top.u_otp.nvmCell[23] <=16'hff;//POINT08H
    _tb.u_asic_top.u_otp.nvmCell[24] <=16'hff;//POINT09L
    _tb.u_asic_top.u_otp.nvmCell[25] <=16'hff;//POINT09H
    _tb.u_asic_top.u_otp.nvmCell[26] <=16'hff;//
    _tb.u_asic_top.u_otp.nvmCell[27] <=16'hff;//
    _tb.u_asic_top.u_otp.nvmCell[28] <=16'hff;//
    _tb.u_asic_top.u_otp.nvmCell[29] <=16'hff;//
    _tb.u_asic_top.u_otp.nvmCell[30] <=16'hff;//
    _tb.u_asic_top.u_otp.nvmCell[31] <=16'hff;//
    end
  4'h3:
    begin
    _tb.u_asic_top.u_otp.nvmCell[6]  <=16'h07;//POINT00L
    _tb.u_asic_top.u_otp.nvmCell[7]  <=16'h00;//POINT00H
    _tb.u_asic_top.u_otp.nvmCell[8]  <=16'h5a;//POINT01L
    _tb.u_asic_top.u_otp.nvmCell[9]  <=16'h01;//POINT01H
    _tb.u_asic_top.u_otp.nvmCell[10] <=16'hdd;//POINT02L
    _tb.u_asic_top.u_otp.nvmCell[11] <=16'h01;//POINT02H
    _tb.u_asic_top.u_otp.nvmCell[12] <=16'hff;//POINT03L
    _tb.u_asic_top.u_otp.nvmCell[13] <=16'hff;//POINT03H
    _tb.u_asic_top.u_otp.nvmCell[14] <=16'hff;//POINT04L
    _tb.u_asic_top.u_otp.nvmCell[15] <=16'hff;//POINT04H
    _tb.u_asic_top.u_otp.nvmCell[16] <=16'hff;//POINT05L
    _tb.u_asic_top.u_otp.nvmCell[17] <=16'hff;//POINT05H
    _tb.u_asic_top.u_otp.nvmCell[18] <=16'hff;//POINT06L
    _tb.u_asic_top.u_otp.nvmCell[19] <=16'hff;//POINT06H
    _tb.u_asic_top.u_otp.nvmCell[20] <=16'hff;//POINT07L
    _tb.u_asic_top.u_otp.nvmCell[21] <=16'hff;//POINT07H
    _tb.u_asic_top.u_otp.nvmCell[22] <=16'hff;//POINT08L
    _tb.u_asic_top.u_otp.nvmCell[23] <=16'hff;//POINT08H
    _tb.u_asic_top.u_otp.nvmCell[24] <=16'hff;//POINT09L
    _tb.u_asic_top.u_otp.nvmCell[25] <=16'hff;//POINT09H
    _tb.u_asic_top.u_otp.nvmCell[26] <=16'hff;//
    _tb.u_asic_top.u_otp.nvmCell[27] <=16'hff;//
    _tb.u_asic_top.u_otp.nvmCell[28] <=16'hff;//
    _tb.u_asic_top.u_otp.nvmCell[29] <=16'hff;//
    _tb.u_asic_top.u_otp.nvmCell[30] <=16'hff;//
    _tb.u_asic_top.u_otp.nvmCell[31] <=16'hff;//
    end
  4'h4:
    begin
      case(point_sel)
        2'h0:
          begin
          _tb.u_asic_top.u_otp.nvmCell[6]  <=16'h07;//POINT00L
          _tb.u_asic_top.u_otp.nvmCell[7]  <=16'h00;//POINT00H
          _tb.u_asic_top.u_otp.nvmCell[8]  <=16'h00;//POINT01L
          _tb.u_asic_top.u_otp.nvmCell[9]  <=16'h01;//POINT01H
          _tb.u_asic_top.u_otp.nvmCell[10] <=16'ha3;//POINT02L
          _tb.u_asic_top.u_otp.nvmCell[11] <=16'h01;//POINT02H
          _tb.u_asic_top.u_otp.nvmCell[12] <=16'he9;//POINT03L
          _tb.u_asic_top.u_otp.nvmCell[13] <=16'h01;//POINT03H
          _tb.u_asic_top.u_otp.nvmCell[14] <=16'hff;//POINT04L
          _tb.u_asic_top.u_otp.nvmCell[15] <=16'hff;//POINT04H
          _tb.u_asic_top.u_otp.nvmCell[16] <=16'hff;//POINT05L
          _tb.u_asic_top.u_otp.nvmCell[17] <=16'hff;//POINT05H
          _tb.u_asic_top.u_otp.nvmCell[18] <=16'hff;//POINT06L
          _tb.u_asic_top.u_otp.nvmCell[19] <=16'hff;//POINT06H
          _tb.u_asic_top.u_otp.nvmCell[20] <=16'hff;//POINT07L
          _tb.u_asic_top.u_otp.nvmCell[21] <=16'hff;//POINT07H
          _tb.u_asic_top.u_otp.nvmCell[22] <=16'hff;//POINT08L
          _tb.u_asic_top.u_otp.nvmCell[23] <=16'hff;//POINT08H
          _tb.u_asic_top.u_otp.nvmCell[24] <=16'hff;//POINT09L
          _tb.u_asic_top.u_otp.nvmCell[25] <=16'hff;//POINT09H
          _tb.u_asic_top.u_otp.nvmCell[26] <=16'hff;//
          _tb.u_asic_top.u_otp.nvmCell[27] <=16'hff;//
          _tb.u_asic_top.u_otp.nvmCell[28] <=16'hff;//
          _tb.u_asic_top.u_otp.nvmCell[29] <=16'hff;//
          _tb.u_asic_top.u_otp.nvmCell[30] <=16'hff;//
          _tb.u_asic_top.u_otp.nvmCell[31] <=16'hff;//
          end
        2'h1:
          begin
          _tb.u_asic_top.u_otp.nvmCell[6]  <=16'h08;//POINT00L
          _tb.u_asic_top.u_otp.nvmCell[7]  <=16'h00;//POINT00H
          _tb.u_asic_top.u_otp.nvmCell[8]  <=16'h37;//POINT01L
          _tb.u_asic_top.u_otp.nvmCell[9]  <=16'h00;//POINT01H
          _tb.u_asic_top.u_otp.nvmCell[10] <=16'h44;//POINT02L
          _tb.u_asic_top.u_otp.nvmCell[11] <=16'h00;//POINT02H
          _tb.u_asic_top.u_otp.nvmCell[12] <=16'h4b;//POINT03L
          _tb.u_asic_top.u_otp.nvmCell[13] <=16'h00;//POINT03H
          _tb.u_asic_top.u_otp.nvmCell[14] <=16'hff;//POINT04L
          _tb.u_asic_top.u_otp.nvmCell[15] <=16'hff;//POINT04H
          _tb.u_asic_top.u_otp.nvmCell[16] <=16'hff;//POINT05L
          _tb.u_asic_top.u_otp.nvmCell[17] <=16'hff;//POINT05H
          _tb.u_asic_top.u_otp.nvmCell[18] <=16'hff;//POINT06L
          _tb.u_asic_top.u_otp.nvmCell[19] <=16'hff;//POINT06H
          _tb.u_asic_top.u_otp.nvmCell[20] <=16'hff;//POINT07L
          _tb.u_asic_top.u_otp.nvmCell[21] <=16'hff;//POINT07H
          _tb.u_asic_top.u_otp.nvmCell[22] <=16'hff;//POINT08L
          _tb.u_asic_top.u_otp.nvmCell[23] <=16'hff;//POINT08H
          _tb.u_asic_top.u_otp.nvmCell[24] <=16'hff;//POINT09L
          _tb.u_asic_top.u_otp.nvmCell[25] <=16'hff;//POINT09H
          _tb.u_asic_top.u_otp.nvmCell[26] <=16'hff;//
          _tb.u_asic_top.u_otp.nvmCell[27] <=16'hff;//
          _tb.u_asic_top.u_otp.nvmCell[28] <=16'hff;//
          _tb.u_asic_top.u_otp.nvmCell[29] <=16'hff;//
          _tb.u_asic_top.u_otp.nvmCell[30] <=16'hff;//
          _tb.u_asic_top.u_otp.nvmCell[31] <=16'hff;//
          end
        default ;
      endcase
    end
  4'h5:
    begin
    _tb.u_asic_top.u_otp.nvmCell[6]  <=16'h07;//POINT00L
    _tb.u_asic_top.u_otp.nvmCell[7]  <=16'h00;//POINT00H
    _tb.u_asic_top.u_otp.nvmCell[8]  <=16'h9c;//POINT01L
    _tb.u_asic_top.u_otp.nvmCell[9]  <=16'h00;//POINT01H
    _tb.u_asic_top.u_otp.nvmCell[10] <=16'h5b;//POINT02L
    _tb.u_asic_top.u_otp.nvmCell[11] <=16'h01;//POINT02H
    _tb.u_asic_top.u_otp.nvmCell[12] <=16'hb0;//POINT03L
    _tb.u_asic_top.u_otp.nvmCell[13] <=16'h01;//POINT03H
    _tb.u_asic_top.u_otp.nvmCell[14] <=16'hdf;//POINT04L
    _tb.u_asic_top.u_otp.nvmCell[15] <=16'h01;//POINT04H
    _tb.u_asic_top.u_otp.nvmCell[16] <=16'hff;//POINT05L
    _tb.u_asic_top.u_otp.nvmCell[17] <=16'hff;//POINT05H
    _tb.u_asic_top.u_otp.nvmCell[18] <=16'hff;//POINT06L
    _tb.u_asic_top.u_otp.nvmCell[19] <=16'hff;//POINT06H
    _tb.u_asic_top.u_otp.nvmCell[20] <=16'hff;//POINT07L
    _tb.u_asic_top.u_otp.nvmCell[21] <=16'hff;//POINT07H
    _tb.u_asic_top.u_otp.nvmCell[22] <=16'hff;//POINT08L
    _tb.u_asic_top.u_otp.nvmCell[23] <=16'hff;//POINT08H
    _tb.u_asic_top.u_otp.nvmCell[24] <=16'hff;//POINT09L
    _tb.u_asic_top.u_otp.nvmCell[25] <=16'hff;//POINT09H
    _tb.u_asic_top.u_otp.nvmCell[26] <=16'hff;//
    _tb.u_asic_top.u_otp.nvmCell[27] <=16'hff;//
    _tb.u_asic_top.u_otp.nvmCell[28] <=16'hff;//
    _tb.u_asic_top.u_otp.nvmCell[29] <=16'hff;//
    _tb.u_asic_top.u_otp.nvmCell[30] <=16'hff;//
    _tb.u_asic_top.u_otp.nvmCell[31] <=16'hff;//
    end
  4'h6:
    begin
      case(point_sel)
        2'h0:
          begin
          _tb.u_asic_top.u_otp.nvmCell[6]  <=16'h07;//POINT00L
          _tb.u_asic_top.u_otp.nvmCell[7]  <=16'h00;//POINT00H
          _tb.u_asic_top.u_otp.nvmCell[8]  <=16'h67;//POINT01L
          _tb.u_asic_top.u_otp.nvmCell[9]  <=16'h00;//POINT01H
          _tb.u_asic_top.u_otp.nvmCell[10] <=16'h25;//POINT02L
          _tb.u_asic_top.u_otp.nvmCell[11] <=16'h01;//POINT02H
          _tb.u_asic_top.u_otp.nvmCell[12] <=16'h87;//POINT03L
          _tb.u_asic_top.u_otp.nvmCell[13] <=16'h01;//POINT03H
          _tb.u_asic_top.u_otp.nvmCell[14] <=16'hbd;//POINT04L
          _tb.u_asic_top.u_otp.nvmCell[15] <=16'h01;//POINT04H
          _tb.u_asic_top.u_otp.nvmCell[16] <=16'he0;//POINT05L
          _tb.u_asic_top.u_otp.nvmCell[17] <=16'h01;//POINT05H
          _tb.u_asic_top.u_otp.nvmCell[18] <=16'hff;//POINT06L
          _tb.u_asic_top.u_otp.nvmCell[19] <=16'hff;//POINT06H
          _tb.u_asic_top.u_otp.nvmCell[20] <=16'hff;//POINT07L
          _tb.u_asic_top.u_otp.nvmCell[21] <=16'hff;//POINT07H
          _tb.u_asic_top.u_otp.nvmCell[22] <=16'hff;//POINT08L
          _tb.u_asic_top.u_otp.nvmCell[23] <=16'hff;//POINT08H
          _tb.u_asic_top.u_otp.nvmCell[24] <=16'hff;//POINT09L
          _tb.u_asic_top.u_otp.nvmCell[25] <=16'hff;//POINT09H
          _tb.u_asic_top.u_otp.nvmCell[26] <=16'hff;//
          _tb.u_asic_top.u_otp.nvmCell[27] <=16'hff;//
          _tb.u_asic_top.u_otp.nvmCell[28] <=16'hff;//
          _tb.u_asic_top.u_otp.nvmCell[29] <=16'hff;//
          _tb.u_asic_top.u_otp.nvmCell[30] <=16'hff;//
          _tb.u_asic_top.u_otp.nvmCell[31] <=16'hff;//
          end
        2'h1:
          begin
          _tb.u_asic_top.u_otp.nvmCell[6]  <=16'h0a;//POINT00L
          _tb.u_asic_top.u_otp.nvmCell[7]  <=16'h00;//POINT00H
          _tb.u_asic_top.u_otp.nvmCell[8]  <=16'h2e;//POINT01L
          _tb.u_asic_top.u_otp.nvmCell[9]  <=16'h00;//POINT01H
          _tb.u_asic_top.u_otp.nvmCell[10] <=16'h3b;//POINT02L
          _tb.u_asic_top.u_otp.nvmCell[11] <=16'h00;//POINT02H
          _tb.u_asic_top.u_otp.nvmCell[12] <=16'h42;//POINT03L
          _tb.u_asic_top.u_otp.nvmCell[13] <=16'h00;//POINT03H
          _tb.u_asic_top.u_otp.nvmCell[14] <=16'h47;//POINT04L
          _tb.u_asic_top.u_otp.nvmCell[15] <=16'h00;//POINT04H
          _tb.u_asic_top.u_otp.nvmCell[16] <=16'h4b;//POINT05L
          _tb.u_asic_top.u_otp.nvmCell[17] <=16'h00;//POINT05H
          _tb.u_asic_top.u_otp.nvmCell[18] <=16'hff;//POINT06L
          _tb.u_asic_top.u_otp.nvmCell[19] <=16'hff;//POINT06H
          _tb.u_asic_top.u_otp.nvmCell[20] <=16'hff;//POINT07L
          _tb.u_asic_top.u_otp.nvmCell[21] <=16'hff;//POINT07H
          _tb.u_asic_top.u_otp.nvmCell[22] <=16'hff;//POINT08L
          _tb.u_asic_top.u_otp.nvmCell[23] <=16'hff;//POINT08H
          _tb.u_asic_top.u_otp.nvmCell[24] <=16'hff;//POINT09L
          _tb.u_asic_top.u_otp.nvmCell[25] <=16'hff;//POINT09H
          _tb.u_asic_top.u_otp.nvmCell[26] <=16'hff;//
          _tb.u_asic_top.u_otp.nvmCell[27] <=16'hff;//
          _tb.u_asic_top.u_otp.nvmCell[28] <=16'hff;//
          _tb.u_asic_top.u_otp.nvmCell[29] <=16'hff;//
          _tb.u_asic_top.u_otp.nvmCell[30] <=16'hff;//
          _tb.u_asic_top.u_otp.nvmCell[31] <=16'hff;//
          end
        2'h2://高速模式、电容增大型
          begin
          _tb.u_asic_top.u_otp.nvmCell[6]  <=16'h03;//POINT00L
          _tb.u_asic_top.u_otp.nvmCell[7]  <=16'h00;//POINT00H
          _tb.u_asic_top.u_otp.nvmCell[8]  <=16'h2e;//POINT01L
          _tb.u_asic_top.u_otp.nvmCell[9]  <=16'h00;//POINT01H
          _tb.u_asic_top.u_otp.nvmCell[10] <=16'h80;//POINT02L
          _tb.u_asic_top.u_otp.nvmCell[11] <=16'h00;//POINT02H
          _tb.u_asic_top.u_otp.nvmCell[12] <=16'h60;//POINT03L
          _tb.u_asic_top.u_otp.nvmCell[13] <=16'h00;//POINT03H
          _tb.u_asic_top.u_otp.nvmCell[14] <=16'h48;//POINT04L
          _tb.u_asic_top.u_otp.nvmCell[15] <=16'h00;//POINT04H
          _tb.u_asic_top.u_otp.nvmCell[16] <=16'h34;//POINT05L
          _tb.u_asic_top.u_otp.nvmCell[17] <=16'h00;//POINT05H
          _tb.u_asic_top.u_otp.nvmCell[18] <=16'hff;//POINT06L
          _tb.u_asic_top.u_otp.nvmCell[19] <=16'hff;//POINT06H
          _tb.u_asic_top.u_otp.nvmCell[20] <=16'hff;//POINT07L
          _tb.u_asic_top.u_otp.nvmCell[21] <=16'hff;//POINT07H
          _tb.u_asic_top.u_otp.nvmCell[22] <=16'hff;//POINT08L
          _tb.u_asic_top.u_otp.nvmCell[23] <=16'hff;//POINT08H
          _tb.u_asic_top.u_otp.nvmCell[24] <=16'hff;//POINT09L
          _tb.u_asic_top.u_otp.nvmCell[25] <=16'hff;//POINT09H
          _tb.u_asic_top.u_otp.nvmCell[26] <=16'hff;//
          _tb.u_asic_top.u_otp.nvmCell[27] <=16'hff;//
          _tb.u_asic_top.u_otp.nvmCell[28] <=16'hff;//
          _tb.u_asic_top.u_otp.nvmCell[29] <=16'hff;//
          _tb.u_asic_top.u_otp.nvmCell[30] <=16'hff;//
          _tb.u_asic_top.u_otp.nvmCell[31] <=16'hff;//
          end
        2'h3://高速模式电容减小型
          begin
          _tb.u_asic_top.u_otp.nvmCell[6]  <=16'h05;//POINT00L
          _tb.u_asic_top.u_otp.nvmCell[7]  <=16'h00;//POINT00H
          _tb.u_asic_top.u_otp.nvmCell[8]  <=16'h14;//POINT01L
          _tb.u_asic_top.u_otp.nvmCell[9]  <=16'h00;//POINT01H
          _tb.u_asic_top.u_otp.nvmCell[10] <=16'h06;//POINT02L
          _tb.u_asic_top.u_otp.nvmCell[11] <=16'h00;//POINT02H
          _tb.u_asic_top.u_otp.nvmCell[12] <=16'h04;//POINT03L
          _tb.u_asic_top.u_otp.nvmCell[13] <=16'h00;//POINT03H
          _tb.u_asic_top.u_otp.nvmCell[14] <=16'h02;//POINT04L
          _tb.u_asic_top.u_otp.nvmCell[15] <=16'h00;//POINT04H
          _tb.u_asic_top.u_otp.nvmCell[16] <=16'h02;//POINT05L
          _tb.u_asic_top.u_otp.nvmCell[17] <=16'h00;//POINT05H
          _tb.u_asic_top.u_otp.nvmCell[18] <=16'hff;//POINT06L
          _tb.u_asic_top.u_otp.nvmCell[19] <=16'hff;//POINT06H
          _tb.u_asic_top.u_otp.nvmCell[20] <=16'hff;//POINT07L
          _tb.u_asic_top.u_otp.nvmCell[21] <=16'hff;//POINT07H
          _tb.u_asic_top.u_otp.nvmCell[22] <=16'hff;//POINT08L
          _tb.u_asic_top.u_otp.nvmCell[23] <=16'hff;//POINT08H
          _tb.u_asic_top.u_otp.nvmCell[24] <=16'hff;//POINT09L
          _tb.u_asic_top.u_otp.nvmCell[25] <=16'hff;//POINT09H
          _tb.u_asic_top.u_otp.nvmCell[26] <=16'hff;//
          _tb.u_asic_top.u_otp.nvmCell[27] <=16'hff;//
          _tb.u_asic_top.u_otp.nvmCell[28] <=16'hff;//
          _tb.u_asic_top.u_otp.nvmCell[29] <=16'hff;//
          _tb.u_asic_top.u_otp.nvmCell[30] <=16'hff;//
          _tb.u_asic_top.u_otp.nvmCell[31] <=16'hff;//
          end
        default ;
      endcase
    end

  default: //所有标定值均为0
    begin
    _tb.u_asic_top.u_otp.nvmCell[6]  <=16'h00;//POINT00L
    _tb.u_asic_top.u_otp.nvmCell[7]  <=16'h00;//POINT00H
    _tb.u_asic_top.u_otp.nvmCell[8]  <=16'h00;//POINT01L
    _tb.u_asic_top.u_otp.nvmCell[9]  <=16'h00;//POINT01H
    _tb.u_asic_top.u_otp.nvmCell[10] <=16'h00;//POINT02L
    _tb.u_asic_top.u_otp.nvmCell[11] <=16'h00;//POINT02H
    _tb.u_asic_top.u_otp.nvmCell[12] <=16'h00;//POINT03L
    _tb.u_asic_top.u_otp.nvmCell[13] <=16'h00;//POINT03H
    _tb.u_asic_top.u_otp.nvmCell[14] <=16'h00;//POINT04L
    _tb.u_asic_top.u_otp.nvmCell[15] <=16'h00;//POINT04H
    _tb.u_asic_top.u_otp.nvmCell[16] <=16'h00;//POINT05L
    _tb.u_asic_top.u_otp.nvmCell[17] <=16'h00;//POINT05H
    _tb.u_asic_top.u_otp.nvmCell[18] <=16'h00;//POINT06L
    _tb.u_asic_top.u_otp.nvmCell[19] <=16'h00;//POINT06H
    _tb.u_asic_top.u_otp.nvmCell[20] <=16'h00;//POINT07L
    _tb.u_asic_top.u_otp.nvmCell[21] <=16'h00;//POINT07H
    _tb.u_asic_top.u_otp.nvmCell[22] <=16'h00;//POINT08L
    _tb.u_asic_top.u_otp.nvmCell[23] <=16'h00;//POINT08H
    _tb.u_asic_top.u_otp.nvmCell[24] <=16'h00;//POINT09L
    _tb.u_asic_top.u_otp.nvmCell[25] <=16'h00;//POINT09H
    _tb.u_asic_top.u_otp.nvmCell[26] <=16'h00;//
    _tb.u_asic_top.u_otp.nvmCell[27] <=16'h00;//
    _tb.u_asic_top.u_otp.nvmCell[28] <=16'h00;//
    _tb.u_asic_top.u_otp.nvmCell[29] <=16'h00;//
    _tb.u_asic_top.u_otp.nvmCell[30] <=16'h00;//
    _tb.u_asic_top.u_otp.nvmCell[31] <=16'h00;//
    end
  endcase
end
//----------------   频率切换  ---------------------------------------

reg        h_en;
always@(_tb.u_asic_top.u_dc_top.u_main_ctrl.clk_sel)
begin
  if(_tb.u_asic_top.u_dc_top.u_main_ctrl.clk_sel)
    h_en = 1'b1;
  else
    h_en = 1'b0;
end

reg lclk;
initial   lclk <=  1'b1;
always #15000  lclk <= ~lclk;

reg  hclk ;
initial   hclk <=  1'b1;
always #250      hclk <= ~hclk;

assign clk = h_en? hclk : lclk;
//-----------------------电容增大型--------------------------------
//-----低速----------
reg sclk_ice;
initial   sclk_ice <=  1'b1;
always #500  sclk_ice <= ~sclk_ice;

always@
(negedge rst or posedge sclk_ice)
begin
  if(~rst)
    count1 <= 8'h00;
  else if(count1==count3)
    count1 <= 8'h00;
  else if(count134_en)
    count1 <= count1+1'b1;
end

always@
(negedge rst or posedge sclk_ice)
begin
  if(~rst)
    count3<=12'h022;
  else if(count3>=12'h040)
    count3<=12'h022;
  else if(count4==16'h9999)
    count3<=count3+1'b1;
end
//--------高速-----------
always@
(negedge rst or posedge sclk_ice)
begin
  if(~rst)
    count8 <= 8'h00;
  else if(count8==count9)
    count8 <= 8'h00;
  else if(en0)
    count8 <= count8+1'b1;
end

always@
(negedge rst or posedge sclk_ice)
begin
  if(~rst)
    count9<=12'h010;
  else if(count9>=12'h020)
    count9<=12'h010;
  else if(count8==count9)
    count9<=count9+1'b1;
end
//--------------------------------------------------------
always@
(negedge rst or posedge sclk_ice)
begin
  if(~rst)
    count4<=16'h0000;
  else if(count4==16'h9999)
    count4<=16'h0000;
  else if(count134_en)
    count4<=count4+1'b1;
end
//---------------------电容减小型--------------------------
//------------低速---------------
reg sclk_rde;
initial   sclk_rde <=  1'b1;
always #100  sclk_rde <= ~sclk_rde;
always@
(negedge rst or posedge sclk_rde)
begin
  if(~rst)
    count5 <= 8'h00;
  else if(count5==count6)
    count5 <= 8'h00;
  else if(count134_en)
    count5 <= count5+1'b1;
end

always@
(negedge rst or posedge sclk_rde)
begin
  if(~rst)
    count6<=12'h0bd;
  else if(count6<=12'h0a8)
    count6<=12'h0bd;
  else if(count7==20'h27100)
    count6<=count6-1'b1;
end

//-------------高速----------------
always@
(negedge rst or posedge sclk_rde)
begin
  if(~rst)
    counta <= 8'h00;
  else if(counta==countb)
    counta <= 8'h00;
  else if(en0)
    counta <= counta+1'b1;
end

always@
(negedge rst or posedge sclk_rde)
begin
  if(~rst)
    countb<=12'h05f;
  else if(countb<=12'h057)
    countb<=12'h05f;
  else if(counta==countb)
    countb<=countb-1'b1;
end

always@
(negedge rst or posedge sclk_rde)
begin
  if(~rst)
    count7<=20'h00000;
  else if(count7==20'h27500)
    count7<=20'h00000;
  else if(count134_en)
    count7<=count7+1'b1;
end
/////////////////////smoke_clk/////////////////////////////
initial   s0_clk <=  1'b1;
always #16000  s0_clk <= ~s0_clk;
initial   s1_clk <=  1'b1;
always #16327  s1_clk <= ~s1_clk;
initial   s2_clk <=  1'b1;
always #19000  s2_clk <= ~s2_clk;
initial   s3_clk <=  1'b1;
always #8000  s3_clk <= ~s3_clk;
initial   s4_clk <=  1'b1;
always #9750  s4_clk <= ~s4_clk;
///////////////////////////////////////////////////////////
//------------------------cn1t的测试时钟分频--------------
reg [15:0] count2h;
reg [15:0] count2l;
always
@(negedge rst or posedge  hclk )
begin
  if(~rst)
    count2h <= 16'h0000;
  else if(count2h == 16'h0400)
    count2h <= 16'h0000;
  else
    count2h <= count2h+1'b1;
end
always
@(negedge rst or posedge  hclk )
begin
  if(~rst)
    count2l <= 16'h0000;
  else if(count2l == 16'hc000)
    count2l <= 16'h0000;
  else
    count2l <= count2l+1'b1;
end
wire  tclk;
assign tclk = h_en? (count2h==16'h0400):(count2l==16'hc000);

reg [11:0] cn1t;
always
@(negedge rst or posedge tclk)
begin
  if(~rst)
    cn1t<=11'h000;
  else if(cn1t==11'h7ff)
  cn1t<=cn1t;
  else
    cn1t<=cn1t+1'b1;
end

//------------------测试激励-------------------------
always
@(*)
begin
  case(test_owl_item)
    4'h1:
      case(cn1t)
        12'h014:  begin  sfr_wdata=8'h12;sfr_num=8'h06;sfr_addrs=7'h20;sfr_wen= 1'b1;sfr_cmd=1'b0;end//调频输出
//        12'h00e:  begin  sfr_wdata=8'hc0;sfr_num=8'h06;sfr_addrs=7'h12;sfr_wen= 1'b1;sfr_cmd=1'b0;end//标定基准值

        default:begin                                                  sfr_wen= 1'b0;             end
      endcase
    4'h2://高低频切换
      case(cn1t)
        12'h004:  begin  sfr_wdata=8'h00;sfr_num=8'h00;sfr_addrs=7'h21;sfr_wen= 1'b1;sfr_cmd=1'b1;end//转换为高频
        12'h013:  begin  sfr_wdata=8'h00;sfr_num=8'h00;sfr_addrs=7'h02;sfr_wen= 1'b1;sfr_cmd=1'b1;end//无关紧要的高频写值！
        12'h017:  begin  sfr_wdata=8'h01;sfr_num=8'h00;sfr_addrs=7'h21;sfr_wen= 1'b1;sfr_cmd=1'b1;end//转换为低频
        default:begin                                                  sfr_wen= 1'b0;             end
      endcase
    4'h3:
      case(cn1t)
        12'h004:  begin  sfr_wdata=8'h80;sfr_num=8'h00;sfr_addrs=7'h21;sfr_wen= 1'b1;sfr_cmd=1'b1;end//转换为高频

        12'h020:  begin  sfr_wdata=8'hd0;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end//数据认证d0
        12'h023:  begin  sfr_wdata=8'h70;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h026:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h029:  begin  sfr_wdata=8'h52;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end//数据认证52
        12'h02c:  begin  sfr_wdata=8'h71;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h02f:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h032:  begin  sfr_wdata=8'h86;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end//test_cn寄存器
        12'h035:  begin  sfr_wdata=8'h72;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h038:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h03b:  begin  sfr_wdata=8'h00;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end//低频矫正
        12'h03e:  begin  sfr_wdata=8'h73;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h041:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h044:  begin  sfr_wdata=8'h08;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end//高频矫正
        12'h047:  begin  sfr_wdata=8'h74;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h04a:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h04d:  begin  sfr_wdata=8'h01;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end//OTP扇区选择
        12'h050:  begin  sfr_wdata=8'h75;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h053:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h056:  begin  sfr_wdata=8'haa;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h059:  begin  sfr_wdata=8'h76;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h05c:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h05f:  begin  sfr_wdata=8'haa;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h062:  begin  sfr_wdata=8'h77;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h065:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h068:  begin  sfr_wdata=8'hd0;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h06b:  begin  sfr_wdata=8'h78;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h06e:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h071:  begin  sfr_wdata=8'h52;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h074:  begin  sfr_wdata=8'h79;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h077:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h07a:  begin  sfr_wdata=8'hd0;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end//数据认证d0
        12'h07d:  begin  sfr_wdata=8'h7a;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h080:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h083:  begin  sfr_wdata=8'h52;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end//数据认证52
        12'h086:  begin  sfr_wdata=8'h7b;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h089:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h08c:  begin  sfr_wdata=8'h80;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end//gctrl寄存器
        12'h08f:  begin  sfr_wdata=8'h7c;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h092:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h095:  begin  sfr_wdata=8'h15;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end//gmode寄存器
        12'h098:  begin  sfr_wdata=8'h7d;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h09b:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h09e:  begin  sfr_wdata=8'h33;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end//pwm_base
        12'h0a1:  begin  sfr_wdata=8'h7e;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h0a4:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h0a7:  begin  sfr_wdata=8'h26;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end//pwm_step
        12'h0aa:  begin  sfr_wdata=8'h7f;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h0ad:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h0b0:  begin  sfr_wdata=8'h00;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end//chk_cn0寄存器
        12'h0b3:  begin  sfr_wdata=8'h00;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h0b6:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h0b9:  begin  sfr_wdata=8'hf2;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end//chk_md0寄存器
        12'h0bc:  begin  sfr_wdata=8'h01;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h0bf:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h0c2:  begin  sfr_wdata=8'h03;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end//chk_md1寄存器
        12'h0c5:  begin  sfr_wdata=8'h02;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h0c8:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h0cb:  begin  sfr_wdata=8'h08;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end//chk_md2寄存器
        12'h0ce:  begin  sfr_wdata=8'h03;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h0d1:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h0d4:  begin  sfr_wdata=8'hc1;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end//死区气压值0
        12'h0d7:  begin  sfr_wdata=8'h04;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h0da:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h0dd:  begin  sfr_wdata=8'h03;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end//死区气压值1
        12'h0e0:  begin  sfr_wdata=8'h05;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h0e3:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h0e6:  begin  sfr_wdata=8'h07;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end//POINT00L
        12'h0e9:  begin  sfr_wdata=8'h06;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h0ec:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h0ef:  begin  sfr_wdata=8'h00;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end//POINT00H
        12'h0f2:  begin  sfr_wdata=8'h07;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h0f5:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h0f8:  begin  sfr_wdata=8'h9d;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end//POINT01L
        12'h0fb:  begin  sfr_wdata=8'h08;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h0fe:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h101:  begin  sfr_wdata=8'h00;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end//POINT01H
        12'h104:  begin  sfr_wdata=8'h09;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h107:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h10a:  begin  sfr_wdata=8'h58;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end//POINT02L
        12'h10d:  begin  sfr_wdata=8'h0a;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h110:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h113:  begin  sfr_wdata=8'h01;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end//POINT02H
        12'h116:  begin  sfr_wdata=8'h0b;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h119:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h11c:  begin  sfr_wdata=8'hac;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end//POINT03L
        12'h11f:  begin  sfr_wdata=8'h0c;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h122:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h125:  begin  sfr_wdata=8'h01;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end//POINT03H
        12'h128:  begin  sfr_wdata=8'h0d;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h12b:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h12e:  begin  sfr_wdata=8'hdb;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end//POINT04L
        12'h131:  begin  sfr_wdata=8'h0e;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h134:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h137:  begin  sfr_wdata=8'h01;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end//POINT04H
        12'h13a:  begin  sfr_wdata=8'h0f;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h13d:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h140:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end//POINT05L
        12'h143:  begin  sfr_wdata=8'h10;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h146:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h149:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end//POINT05H
        12'h14c:  begin  sfr_wdata=8'h11;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h14f:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h152:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end//POINT06L
        12'h155:  begin  sfr_wdata=8'h12;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h158:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h15b:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end//POINT06H
        12'h15e:  begin  sfr_wdata=8'h13;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h161:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h164:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end//POINT07L
        12'h167:  begin  sfr_wdata=8'h14;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h16a:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h16d:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end//POINT07H
        12'h170:  begin  sfr_wdata=8'h15;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h173:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h176:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end//POINT08L
        12'h179:  begin  sfr_wdata=8'h16;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h17c:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h17f:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end//POINT08H
        12'h182:  begin  sfr_wdata=8'h17;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h185:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h188:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end//POINT09L
        12'h18b:  begin  sfr_wdata=8'h18;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h18e:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h191:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end//POINT09H
        12'h194:  begin  sfr_wdata=8'h19;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h197:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h19a:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h19d:  begin  sfr_wdata=8'h1a;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h1a0:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h1a3:  begin  sfr_wdata=8'h70;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h1a6:  begin  sfr_wdata=8'h1b;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h1a9:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h1ac:  begin  sfr_wdata=8'h71;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h1af:  begin  sfr_wdata=8'h1c;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h1b2:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h1b5:  begin  sfr_wdata=8'h72;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h1b8:  begin  sfr_wdata=8'h1d;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h1bb:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h1be:  begin  sfr_wdata=8'h73;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h1c1:  begin  sfr_wdata=8'h1e;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h1c4:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h1c7:  begin  sfr_wdata=8'h74;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h1ca:  begin  sfr_wdata=8'h1f;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h1cd:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h1d0:  begin  sfr_wdata=8'h00;sfr_num=8'h00;sfr_addrs=7'h10;sfr_wen= 1'b1;sfr_cmd=1'b1;end//软件复位
        default:begin                                                  sfr_wen= 1'b0;             end
      endcase
    4'h4://owl接口上下行数据访问寄存器
      case(cn1t)
        12'h00d:  begin  sfr_wdata=8'h00;sfr_num=8'h08;sfr_addrs=7'h12;sfr_wen= 1'b1;sfr_cmd=1'b0;end//低频条件下读取数值
        12'h012:  begin  sfr_wdata=8'h80;sfr_num=8'h00;sfr_addrs=7'h21;sfr_wen= 1'b1;sfr_cmd=1'b1;end//转换为高频
        12'h016:  begin  sfr_wdata=8'haa;sfr_num=8'h00;sfr_addrs=7'h06;sfr_wen= 1'b1;sfr_cmd=1'b1;end//设置低频矫正
        12'h018:  begin  sfr_wdata=8'haa;sfr_num=8'h00;sfr_addrs=7'h07;sfr_wen= 1'b1;sfr_cmd=1'b1;end//设置高频矫正
        12'h019:  begin  //验证
                  sfr_wen= 1'b0;
                  if(_tb.u_asic_top.u_dc_top.LCFR  !=8'haa)begin
                  tb_error =1'b1; $write("test_owl_item=%h, cn1t=%h:  ERR: 6005 LCFR  = %h \n",  test_owl_item,  cn1t,  _tb.u_asic_top.u_dc_top.LCFR); end
                  end
        12'h01a:  begin  sfr_wdata=8'h60;sfr_num=8'h00;sfr_addrs=7'h04;sfr_wen= 1'b1;sfr_cmd=1'b1;end//GCTRL寄存器/--/复位禁止、电容减小、2线模式
                12'h019:  begin  //验证
                  sfr_wen= 1'b0;
                  if(_tb.u_asic_top.u_dc_top.HCFR  !=8'haa)begin
                  tb_error =1'b1; $write("test_owl_item=%h, cn1t=%h:  ERR: 6005 HCFR  = %h \n",  test_owl_item,  cn1t,  _tb.u_asic_top.u_dc_top.HCFR); end
                  end
        12'h01c:  begin  sfr_wdata=8'h00;sfr_num=8'h00;sfr_addrs=7'h0f;sfr_wen= 1'b1;sfr_cmd=1'b1;end//test_cn寄存器/--/高阻状态
        12'h01e:  begin  sfr_wdata=8'hce;sfr_num=8'h00;sfr_addrs=7'h10;sfr_wen= 1'b1;sfr_cmd=1'b1;end//chk_ptcn寄存器/--/死区标定一次
        12'h020:  begin  sfr_wdata=8'hc6;sfr_num=8'h00;sfr_addrs=7'h20;sfr_wen= 1'b1;sfr_cmd=1'b1;end//chk_cn0寄存器/--/高速模式、无强度50%PWM输出
        12'h022:  begin  sfr_wdata=8'h00;sfr_num=8'h00;sfr_addrs=7'h21;sfr_wen= 1'b1;sfr_cmd=1'b1;end//chk_md0寄存器/--/基准值0.78%、基准值3.1%、使能、hosc
        12'h024:  begin  sfr_wdata=8'h66;sfr_num=8'h00;sfr_addrs=7'h22;sfr_wen= 1'b1;sfr_cmd=1'b1;end//chk_md1寄存器/--/66
        12'h026:  begin  sfr_wdata=8'h06;sfr_num=8'h00;sfr_addrs=7'h23;sfr_wen= 1'b1;sfr_cmd=1'b1;end//chk_md2寄存器/--/06
        12'h028:  begin  sfr_wdata=8'h20;sfr_num=8'h00;sfr_addrs=7'h08;sfr_wen= 1'b1;sfr_cmd=1'b1;end//pwm_step寄存器/--/20
        12'h02a:  begin  sfr_wdata=8'h20;sfr_num=8'h00;sfr_addrs=7'h09;sfr_wen= 1'b1;sfr_cmd=1'b1;end//pwm_base寄存器/--/20
        12'h02c:  begin  sfr_wdata=8'h33;sfr_num=8'h00;sfr_addrs=7'h24;sfr_wen= 1'b1;sfr_cmd=1'b1;end//chk_dbd0寄存器/--/33
        12'h02e:  begin  sfr_wdata=8'h03;sfr_num=8'h00;sfr_addrs=7'h25;sfr_wen= 1'b1;sfr_cmd=1'b1;end//chk_dbd1寄存器/--/03
        12'h032:  begin  //验证
                  sfr_wen= 1'b0;
                  if(_tb.u_asic_top.u_dc_top.gctrl  !=8'h60)begin
                  tb_error =1'b1; $write("test_owl_item=%h, cn1t=%h:  ERR: 6005 gctrl  = %h \n",  test_owl_item,  cn1t,  _tb.u_asic_top.u_dc_top.gctrl); end
                  if(_tb.u_asic_top.u_dc_top.test_cn  !=8'h00)begin
                  tb_error =1'b1; $write("test_owl_item=%h, cn1t=%h:  ERR: 6005 test_cn  = %h \n",  test_owl_item,  cn1t,  _tb.u_asic_top.u_dc_top.test_cn); end
                  if(_tb.u_asic_top.u_dc_top.chk_ptcn  !=8'h8e)begin
                  tb_error =1'b1; $write("test_owl_item=%h, cn1t=%h:  ERR: 6005 chk_ptcn  = %h \n",  test_owl_item,  cn1t,  _tb.u_asic_top.u_dc_top.chk_ptcn); end
                  if(_tb.u_asic_top.u_dc_top.chk_cn0  !=8'hc6)begin
                  tb_error =1'b1; $write("test_owl_item=%h, cn1t=%h:  ERR: 6005 chk_cn0  = %h \n",  test_owl_item,  cn1t,  _tb.u_asic_top.u_dc_top.chk_cn0); end
                  if(_tb.u_asic_top.u_dc_top.chk_md0  !=8'h04)begin
                  tb_error =1'b1; $write("test_owl_item=%h, cn1t=%h:  ERR: 6005 chk_md0  = %h \n",  test_owl_item,  cn1t,  _tb.u_asic_top.u_dc_top.chk_md0); end
                  if(_tb.u_asic_top.u_dc_top.chk_md1  !=8'h66)begin
                  tb_error =1'b1; $write("test_owl_item=%h, cn1t=%h:  ERR: 6005 chk_md1  = %h \n",  test_owl_item,  cn1t,  _tb.u_asic_top.u_dc_top.chk_md1); end
                  if(_tb.u_asic_top.u_dc_top.chk_md2  !=8'h06)begin
                  tb_error =1'b1; $write("test_owl_item=%h, cn1t=%h:  ERR: 6005 chk_md2  = %h \n",  test_owl_item,  cn1t,  _tb.u_asic_top.u_dc_top.chk_md2); end
                  if(_tb.u_asic_top.u_dc_top.pwm_step  !=8'h20)begin
                  tb_error =1'b1; $write("test_owl_item=%h, cn1t=%h:  ERR: 6005 pwm_step  = %h \n",  test_owl_item,  cn1t,  _tb.u_asic_top.u_dc_top.pwm_step); end
                  if(_tb.u_asic_top.u_dc_top.pwm_base  !=8'h20)begin
                  tb_error =1'b1; $write("test_owl_item=%h, cn1t=%h:  ERR: 6005 pwm_base  = %h \n",  test_owl_item,  cn1t,  _tb.u_asic_top.u_dc_top.pwm_base); end
                  if(_tb.u_asic_top.u_dc_top.chk_dbd0  !=8'h33)begin
                  tb_error =1'b1; $write("test_owl_item=%h, cn1t=%h:  ERR: 6005 chk_dbd0  = %h \n",  test_owl_item,  cn1t,  _tb.u_asic_top.u_dc_top.chk_dbd0); end
                  if(_tb.u_asic_top.u_dc_top.chk_dbd1  !=8'h03)begin
                  tb_error =1'b1; $write("test_owl_item=%h, cn1t=%h:  ERR: 6005 chk_dbd1  = %h \n",  test_owl_item,  cn1t,  _tb.u_asic_top.u_dc_top.chk_dbd1); end
                  end
        12'h030:  begin  sfr_wdata=8'h03;sfr_num=8'h10;sfr_addrs=7'h00;sfr_wen= 1'b1;sfr_cmd=1'b0;end//读取0x00-0x0f所有寄存器的值
        12'h038:  begin  sfr_wdata=8'h03;sfr_num=8'h10;sfr_addrs=7'h10;sfr_wen= 1'b1;sfr_cmd=1'b0;end//读取0x10-0x1f所有寄存器的值
        12'h040:  begin  sfr_wdata=8'h03;sfr_num=8'h10;sfr_addrs=7'h20;sfr_wen= 1'b1;sfr_cmd=1'b0;end//读取0x20-0x2f所有寄存器的值
        12'h048:  begin  sfr_wdata=8'h03;sfr_num=8'h10;sfr_addrs=7'h30;sfr_wen= 1'b1;sfr_cmd=1'b0;end//读取0x30-0x39所有寄存器的值
        12'h050:  begin  sfr_wdata=8'h03;sfr_num=8'h10;sfr_addrs=7'h30;sfr_wen= 1'b1;sfr_cmd=1'b0;end//单字节读取0x23地址的寄存器
        default:begin                                                  sfr_wen= 1'b0;             end
      endcase
    4'h5://死区标定
      case(cn1t)
        12'h00f:  begin  sfr_wdata=8'hcf;sfr_num=8'h00;sfr_addrs=7'h10;sfr_wen= 1'b1;sfr_cmd=1'b1;end//基准值标定
        12'h121:  begin  sfr_wdata=8'hce;sfr_num=8'h00;sfr_addrs=7'h10;sfr_wen= 1'b1;sfr_cmd=1'b1;end//死区标定
        12'h130:  begin  sfr_wdata=8'h10;sfr_num=8'h00;sfr_addrs=7'h20;sfr_wen= 1'b1;sfr_cmd=1'b1;end//切换为工作模式
        default:begin                                                  sfr_wen= 1'b0;             end
      endcase
    4'h6://死区标定
      case(cn1t)
        12'h00f:  begin  sfr_wdata=8'h83;sfr_num=8'h00;sfr_addrs=7'h0f;sfr_wen= 1'b1;sfr_cmd=1'b1;end//测试口切换为sysclk输出
        12'h050:  begin  sfr_wdata=8'h87;sfr_num=8'h00;sfr_addrs=7'h0f;sfr_wen= 1'b1;sfr_cmd=1'b1;end//测试口切换为FM输出
        12'h0b0:  begin  sfr_wdata=8'h8a;sfr_num=8'h00;sfr_addrs=7'h0f;sfr_wen= 1'b1;sfr_cmd=1'b1;end//测试口切换为smoke_clk输出
        12'h131:  begin  sfr_wdata=8'h86;sfr_num=8'h00;sfr_addrs=7'h0f;sfr_wen= 1'b1;sfr_cmd=1'b1;end//测试口切换为pwm输出
        12'h150:  begin  sfr_wdata=8'h10;sfr_num=8'h00;sfr_addrs=7'h20;sfr_wen= 1'b1;sfr_cmd=1'b1;end//切换为工作模式
        default:begin                                                  sfr_wen= 1'b0;             end
      endcase
    4'h7://65ms~256ms数据下行测试
      case(cn1t)
        12'h006:  begin  sfr_wdata=8'hc9;sfr_num=8'h00;sfr_addrs=7'h10;sfr_wen= 1'b1;sfr_cmd=1'b1;end//point9标定
//        12'h010:  begin  sfr_wdata=8'hf0;sfr_num=8'h01;sfr_addrs=7'h1f;sfr_wen= 1'b1;sfr_cmd=1'b0;end//读取PWM宽度 
        12'h013:  begin  sfr_wdata=8'hcf;sfr_num=8'h01;sfr_addrs=7'h1f;sfr_wen= 1'b1;sfr_cmd=1'b0;end//读取PWM宽度
        12'h017:  begin  sfr_wdata=8'hcf;sfr_num=8'h01;sfr_addrs=7'h1f;sfr_wen= 1'b1;sfr_cmd=1'b0;end//读取PWM宽度
        12'h01a:  begin  sfr_wdata=8'hcf;sfr_num=8'h01;sfr_addrs=7'h1f;sfr_wen= 1'b1;sfr_cmd=1'b0;end//读取PWM宽度
        default:begin                                                  sfr_wen= 1'b0;             end
      endcase
    4'h8://256ms数据下行读取pwm_width测试
      case(cn1t)
        12'h00f:  begin  sfr_wdata=8'h00;sfr_num=8'h10;sfr_addrs=7'h12;sfr_wen= 1'b1;sfr_cmd=1'b0;end//低频条件下读取数值
        12'h016:  begin  sfr_wdata=8'h80;sfr_num=8'h00;sfr_addrs=7'h21;sfr_wen= 1'b1;sfr_cmd=1'b1;end//转换为高频
        12'h02d:  begin  sfr_wdata=8'h00;sfr_num=8'h10;sfr_addrs=7'h12;sfr_wen= 1'b1;sfr_cmd=1'b0;end//高频条件下读取数值
        default:begin                                                  sfr_wen= 1'b0;             end
      endcase
    4'h9://基准值标定、切换为工作模式
      case(cn1t)
//        12'h019:  begin  sfr_wdata=8'hcf;sfr_num=8'h00;sfr_addrs=7'h10;sfr_wen= 1'b1;sfr_cmd=1'b1;end//基准值标定
//        12'h020:  begin  sfr_wdata=8'h00;sfr_num=8'h10;sfr_addrs=7'h20;sfr_wen= 1'b1;sfr_cmd=1'b1;end//切换为工作模式
        12'h1d1:  begin  sfr_wdata=8'h00;sfr_num=8'h10;sfr_addrs=7'h12;sfr_wen= 1'b1;sfr_cmd=1'b0;end//高频条件下读取数值
        12'h1d5:  begin  sfr_wdata=8'h00;sfr_num=8'h10;sfr_addrs=7'h12;sfr_wen= 1'b1;sfr_cmd=1'b0;end//高频条件下读取数值
        12'h1d9:  begin  sfr_wdata=8'h00;sfr_num=8'h10;sfr_addrs=7'h12;sfr_wen= 1'b1;sfr_cmd=1'b0;end//高频条件下读取数值
        12'h1dd:  begin  sfr_wdata=8'h00;sfr_num=8'h10;sfr_addrs=7'h12;sfr_wen= 1'b1;sfr_cmd=1'b0;end//高频条件下读取数值
        12'h38e:  begin  sfr_wdata=8'h00;sfr_num=8'h10;sfr_addrs=7'h12;sfr_wen= 1'b1;sfr_cmd=1'b0;end//高频条件下读取数值、此时芯片进入爱豆状态
        default:begin                                                  sfr_wen= 1'b0;             end
      endcase
    4'ha://为拓尔提供owl的VCD激励文件
      case(cn1t)
        12'h005:  begin  sfr_wdata=8'hf0;sfr_num=8'h00;sfr_addrs=7'h21;sfr_wen= 1'b1;sfr_cmd=1'b1;end//转换为高频 并设置气压更新阈值为死区寄存器的值、吸烟阈值选择为标定零点气压差
        12'h010:  begin  sfr_wdata=8'hcf;sfr_num=8'h00;sfr_addrs=7'h10;sfr_wen= 1'b1;sfr_cmd=1'b1;end//标定基准值
        12'h01a:  begin  sfr_wdata=8'ha0;sfr_num=8'h00;sfr_addrs=7'h04;sfr_wen= 1'b1;sfr_cmd=1'b1;end//切换为两线模式
        12'h01c:  begin  sfr_wdata=8'h05;sfr_num=8'h00;sfr_addrs=7'h24;sfr_wen= 1'b1;sfr_cmd=1'b1;end//标定死区
        12'h01f:  begin  sfr_wdata=8'h00;sfr_num=8'h00;sfr_addrs=7'h25;sfr_wen= 1'b1;sfr_cmd=1'b1;end//标定死区
        12'h021:  begin  sfr_wdata=8'h07;sfr_num=8'h00;sfr_addrs=7'h26;sfr_wen= 1'b1;sfr_cmd=1'b1;end//标定point00L
        12'h023:  begin  sfr_wdata=8'h00;sfr_num=8'h00;sfr_addrs=7'h27;sfr_wen= 1'b1;sfr_cmd=1'b1;end//标定point00H
        12'h025:  begin  sfr_wdata=8'h9c;sfr_num=8'h00;sfr_addrs=7'h28;sfr_wen= 1'b1;sfr_cmd=1'b1;end//标定point01L
        12'h027:  begin  sfr_wdata=8'h00;sfr_num=8'h00;sfr_addrs=7'h29;sfr_wen= 1'b1;sfr_cmd=1'b1;end//标定point01H
        12'h029:  begin  sfr_wdata=8'h5b;sfr_num=8'h00;sfr_addrs=7'h2a;sfr_wen= 1'b1;sfr_cmd=1'b1;end//标定point02L
        12'h02b:  begin  sfr_wdata=8'h01;sfr_num=8'h00;sfr_addrs=7'h2b;sfr_wen= 1'b1;sfr_cmd=1'b1;end//标定point02H
        12'h02d:  begin  sfr_wdata=8'hb0;sfr_num=8'h00;sfr_addrs=7'h2c;sfr_wen= 1'b1;sfr_cmd=1'b1;end//标定point03L
        12'h02f:  begin  sfr_wdata=8'h01;sfr_num=8'h00;sfr_addrs=7'h2d;sfr_wen= 1'b1;sfr_cmd=1'b1;end//标定point03H
        12'h031:  begin  sfr_wdata=8'hdf;sfr_num=8'h00;sfr_addrs=7'h2e;sfr_wen= 1'b1;sfr_cmd=1'b1;end//标定point04L
        12'h033:  begin  sfr_wdata=8'h01;sfr_num=8'h00;sfr_addrs=7'h2f;sfr_wen= 1'b1;sfr_cmd=1'b1;end//标定point04H
        12'h035:  begin  sfr_wdata=8'h03;sfr_num=8'h00;sfr_addrs=7'h22;sfr_wen= 1'b1;sfr_cmd=1'b1;end//chk_md1
        12'h037:  begin  sfr_wdata=8'h05;sfr_num=8'h00;sfr_addrs=7'h23;sfr_wen= 1'b1;sfr_cmd=1'b1;end//chk_md2
        12'h039:  begin  sfr_wdata=8'h27;sfr_num=8'h00;sfr_addrs=7'h09;sfr_wen= 1'b1;sfr_cmd=1'b1;end//PWM_step
        12'h03b:  begin  sfr_wdata=8'h01;sfr_num=8'h00;sfr_addrs=7'h21;sfr_wen= 1'b1;sfr_cmd=1'b1;end//转换为低频
        12'h04d:  begin  sfr_wdata=8'h10;sfr_num=8'h00;sfr_addrs=7'h20;sfr_wen= 1'b1;sfr_cmd=1'b1;end//chk_cn0 切换为工作模式、输出使能、低速、气压强度PWM输出
        default:begin                                                  sfr_wen= 1'b0;             end
      endcase
    4'hb: //65ms~256ms数据下行测试
      case(cn1t)
        12'h006:  begin  sfr_wdata=8'hc0;sfr_num=8'h00;sfr_addrs=7'h0f;sfr_wen= 1'b1;sfr_cmd=1'b1;end//使能TEST_IO
        default:begin                                                  sfr_wen= 1'b0;             end
      endcase
    4'hd: //复位使能
      case(cn1t)
        12'h009:  begin  sfr_wdata=8'h80;sfr_num=8'h00;sfr_addrs=7'h04;sfr_wen= 1'b1;sfr_cmd=1'b1;end//复位使能
        default:begin                                                  sfr_wen= 1'b0;             end
      endcase
    default:;
  endcase
end

initial
begin
  #300000000   
  #400000000   $finish(1);
end

//---------------DON'T MODIFY BLOW------------------
//pow uvdd(
//    .vdd(VDD),
//    .vss(GND),
//    .vda(vda)
//    );
//
//pow uvpp(
//    .vdd(VPP),
//    .vss(GND),
//    .vda()
//    );
//
//cap ucap(
//    .cp (smoke_clk),
//    .cn (GND)
//   );
//
//initial
//begin
// $vcdplusfile("d05200.vpd");
// $vcdpluson(0,_tb);
////   $vcdpluson;
//end
//--------------------------------

endmodule
