`timescale 1ns/1ns

module _tb;
reg          rst       ;
wire         clk       ;//100kHz
wire         smoke_clk ;
reg          tb_error  ;

reg   [6:0]  sfr_addrs ;
reg          sfr_cmd   ;
reg   [7:0]  sfr_num   ;
reg   [7:0]  sfr_wdata ;
reg          sfr_wen   ;

wand            owl_inout ;
pullup         (owl_inout);

wire          TSO;
wire          VDD;
wire          GND;
wire          VPP;

d05200_asic_top u_asic_top(
  .VDD         (VDD        ),
  .GND         (GND        ),
  .VPP         (VPP        ),

  .OWL         (owl_inout  ),
  .MIC         (smoke_clk  ),
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
//---------------------------------------时钟以及复位、smoke_clk 等信号逻辑---------------------------------
//reg [7:0]   count1    ;
//reg [11:0]  count3    ;
//reg [15:0]  count4    ;
//reg        count134_en;


initial
begin
                   rst <=  1'b1;
  #4001            rst <=  1'b0;
  #1001            rst <=  1'b1;
  #500000000
  $finish(1);
end

//----------------   频率切换(暂且不用)  ----------------

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
//reg sclk;
//initial   sclk <=  1'b1;
//always #500  sclk <= ~sclk;
//
//always@
//(negedge rst or posedge sclk)
//begin
//  if(~rst)
//    count1 <= 8'h00;
//  else if(count1==count3)
//    count1 <= 8'h00;
//  else if(count134_en)
//    count1 <= count1+1'b1;
//end
//
//always@
//(negedge rst or posedge sclk)
//begin
//  if(~rst)
//    count3<=12'h00f;
//  else if(count3>=12'h021)
//    count3<=12'h00f;
//  else if(count4==16'h9999)
//    count3<=count3+1'b1;
//end
//
//always@
//(negedge rst or posedge sclk)
//begin
//  if(~rst)
//    count4<=16'h0000;
//  else if(count4==16'h9999)
//    count4<=16'h0000;
//  else if(count134_en)
//    count4<=count4+1'b1;
//end
//
//assign smoke_clk =count134_en?(count1==count3):lclk;
//---------------------------------------------测试项目切换--------------------------------------------------------------------
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
localparam    test0 = 4'h0;//电容增大型5点标定寄存器测试
localparam    test1 = 4'h1;//otp测试
localparam    test2 = 4'h2;//chk_ptcn 寄存器标定测试
wire  [3:0] test_item;
assign test_item = test1;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------------------------------------------------
reg [15:0] count2h;
reg [15:0] count2l;
always
@(negedge rst or posedge  hclk )
begin
  if(~rst)
    count2h <= 16'h0000;
  else if(count2h == 16'h0300)
    count2h <= 16'h0000;
  else
    count2h <= count2h+1'b1;
end
always
@(negedge rst or posedge  hclk )
begin
  if(~rst)
    count2l <= 16'h0000;
  else if(count2l == 16'hb000)
    count2l <= 16'h0000;
  else
    count2l <= count2l+1'b1;
end
wire  tclk;
assign tclk = h_en? (count2h==16'h0300):(count2l==16'hb000);

reg [11:0] cn1t;
always
@(negedge rst or posedge tclk)
begin
  if(~rst)
    cn1t<=11'h000;
  else if(cn1t==11'hfff)
  cn1t<=cn1t;
  else
    cn1t<=cn1t+1'b1;
end
//------------------测试激励-------------------------
always
@(*)
begin
  case(test_item)
    test0:
      case(cn1t)
//-------------------------------------------------------------------------------------------------------------------------------------------------------//
        12'h001:  begin  sfr_wdata=8'hb2;sfr_num=8'h00;sfr_addrs=7'h21;sfr_wen= 1'b1;sfr_cmd=1'b1;end //设置为5点标定
        12'h003:  if(_tb.u_asic_top.u_dc_top.u_main_ctrl.point_md  !=3'h2)begin
                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point_md  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.u_main_ctrl.point_md); end
//---------------------------------------------5点标定-------------------------------------------------------------------------------------------------------------//
        12'h007:  begin  sfr_wdata=8'h0d;sfr_num=8'h00;sfr_addrs=7'h26;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h009:  if(_tb.u_asic_top.u_dc_top.point00l  !=8'h0d)begin
                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point00l  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point00l); end
        12'h00b:  begin  sfr_wdata=8'h00;sfr_num=8'h00;sfr_addrs=7'h27;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h00d:  if(_tb.u_asic_top.u_dc_top.point00h  !=8'h00)begin
                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point00h  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point00h); end

        12'h00f:  begin  sfr_wdata=8'h3b;sfr_num=8'h00;sfr_addrs=7'h28;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h011:  if(_tb.u_asic_top.u_dc_top.point01l  !=8'h3b)begin
                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point01l  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point01l); end
        12'h013:  begin  sfr_wdata=8'h01;sfr_num=8'h00;sfr_addrs=7'h29;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h015:  if(_tb.u_asic_top.u_dc_top.point01h  !=8'h01)begin
                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point01h  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point01h); end

        12'h017:  begin  sfr_wdata=8'hb2;sfr_num=8'h00;sfr_addrs=7'h2a;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h019:  if(_tb.u_asic_top.u_dc_top.point02l  !=8'hb2)begin
                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point02l  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point02l); end
        12'h01b:  begin  sfr_wdata=8'h02;sfr_num=8'h00;sfr_addrs=7'h2b;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h01d:  if(_tb.u_asic_top.u_dc_top.point02h  !=8'h02)begin
                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point02h  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point02h); end

        12'h01f:  begin  sfr_wdata=8'h58;sfr_num=8'h00;sfr_addrs=7'h2c;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h021:  if(_tb.u_asic_top.u_dc_top.point03l  !=8'h58)begin
                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point03l  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point03l); end
        12'h023:  begin  sfr_wdata=8'h03;sfr_num=8'h00;sfr_addrs=7'h2d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h025:  if(_tb.u_asic_top.u_dc_top.point03h  !=8'h03)begin
                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point03h  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point03h); end

        12'h027:  begin  sfr_wdata=8'hb2;sfr_num=8'h00;sfr_addrs=7'h2e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h029:  if(_tb.u_asic_top.u_dc_top.point04l  !=8'hb2)begin
                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point04l  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point04l); end
        12'h02b:  begin  sfr_wdata=8'h03;sfr_num=8'h00;sfr_addrs=7'h2f;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h02d:  if(_tb.u_asic_top.u_dc_top.point04h  !=8'h03)begin
                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point04h  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point04h); end
//-----------------------------------------------------------------------------------------------------------------------------------
        12'h02f:   begin  sfr_wdata=8'h09;sfr_num=8'h00;sfr_addrs=7'h23;sfr_wen= 1'b1;sfr_cmd=1'b1;end //调整PWM_PRC的数值
        12'h031:  if(_tb.u_asic_top.u_dc_top.u_main_ctrl.pwm_prc  !=4'h9)begin
               tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 pwm_prc  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.u_main_ctrl.pwm_prc); end

        12'h033:  begin  sfr_wdata=8'h21;sfr_num=8'h00;sfr_addrs=7'h22;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h035:  begin
                  if(_tb.u_asic_top.u_dc_top.u_main_ctrl.sector_prc  !=4'h2)begin
                  tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 sector_prc  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.u_main_ctrl.sector_prc); end
                  if(_tb.u_asic_top.u_dc_top.u_main_ctrl.slope_prc  !=4'h1)begin
                  tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 slope_prc  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.u_main_ctrl.slope_prc); end
                end

        12'h0bb:  begin  sfr_wdata=8'hcf;sfr_num=8'h00;sfr_addrs=7'h10;sfr_wen= 1'b1;sfr_cmd=1'b1;end//标定基准差
        12'h0bd:  if(_tb.u_asic_top.u_dc_top.u_main_ctrl.chk_point  !=4'hf)begin
                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 chk_point  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.u_main_ctrl.chk_point); end



        default:begin                                                sfr_wen= 1'b0;             end
      endcase
    test1:
      case(cn1t)
        12'h031:  begin  sfr_wdata=8'hd0;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h035:  begin  sfr_wdata=8'h70;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h039:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h03c:  begin  sfr_wdata=8'h52;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h041:  begin  sfr_wdata=8'h71;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h045:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h049:  begin  sfr_wdata=8'h00;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h04c:  begin  sfr_wdata=8'h72;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h051:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h055:  begin  sfr_wdata=8'h00;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h059:  begin  sfr_wdata=8'h73;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h05c:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end//数据认证

        12'h061:  begin  sfr_wdata=8'h08;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h065:  begin  sfr_wdata=8'h74;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h069:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end//gctrl寄存器

        12'h06c:  begin  sfr_wdata=8'haa;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h071:  begin  sfr_wdata=8'h75;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h075:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end//gmode寄存器

        12'h079:  begin  sfr_wdata=8'haa;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h07c:  begin  sfr_wdata=8'h76;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h081:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h085:  begin  sfr_wdata=8'haa;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h089:  begin  sfr_wdata=8'h77;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h08c:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h091:  begin  sfr_wdata=8'haa;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h095:  begin  sfr_wdata=8'h78;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h099:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end//losc_cfr寄存器

        12'h09c:  begin  sfr_wdata=8'haa;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h0a1:  begin  sfr_wdata=8'h79;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h0a5:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end//hosc_cfr寄存器

        12'h0a9:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h0ac:  begin  sfr_wdata=8'h7a;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h0b1:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h0b5:  begin  sfr_wdata=8'hc3;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h0b9:  begin  sfr_wdata=8'h7b;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h0bc:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end//test_cn寄存器

        12'h0c1:  begin  sfr_wdata=8'h3f;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h0c5:  begin  sfr_wdata=8'h7c;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h0c9:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end//otp_sct寄存器

        12'h0cc:  begin  sfr_wdata=8'hd0;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h0d1:  begin  sfr_wdata=8'h7d;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h0d5:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h0d9:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h0dc:  begin  sfr_wdata=8'h7e;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h0e1:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h0e5:  begin  sfr_wdata=8'h70;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h0e9:  begin  sfr_wdata=8'h7f;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h0ec:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h0f1:  begin  sfr_wdata=8'hd1;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h0f5:  begin  sfr_wdata=8'h00;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h0f9:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end//频率切换

        12'h0fc:  begin  sfr_wdata=8'hd0;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h101:  begin  sfr_wdata=8'h01;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h105:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h109:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h10c:  begin  sfr_wdata=8'h02;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h111:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h115:  begin  sfr_wdata=8'h70;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h119:  begin  sfr_wdata=8'h03;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h11c:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h121:  begin  sfr_wdata=8'hd0;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h125:  begin  sfr_wdata=8'h04;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h129:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h12c:  begin  sfr_wdata=8'hd0;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h131:  begin  sfr_wdata=8'h05;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h135:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h139:  begin  sfr_wdata=8'h0d;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h13c:  begin  sfr_wdata=8'h06;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h141:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h145:  begin  sfr_wdata=8'h00;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h149:  begin  sfr_wdata=8'h07;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h14c:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h151:  begin  sfr_wdata=8'h3b;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h155:  begin  sfr_wdata=8'h08;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h159:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h15c:  begin  sfr_wdata=8'h01;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h161:  begin  sfr_wdata=8'h09;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h165:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h169:  begin  sfr_wdata=8'hb2;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h16c:  begin  sfr_wdata=8'h0a;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h171:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h175:  begin  sfr_wdata=8'h02;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h179:  begin  sfr_wdata=8'h0b;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h17c:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h181:  begin  sfr_wdata=8'h58;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h185:  begin  sfr_wdata=8'h0c;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h189:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h18c:  begin  sfr_wdata=8'h03;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h191:  begin  sfr_wdata=8'h0d;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h195:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h199:  begin  sfr_wdata=8'hb2;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h19c:  begin  sfr_wdata=8'h0e;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h1a1:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h1a5:  begin  sfr_wdata=8'h03;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h1a9:  begin  sfr_wdata=8'h0f;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h1ac:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h1b1:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h1b5:  begin  sfr_wdata=8'h10;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h1b9:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h1bc:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h1c1:  begin  sfr_wdata=8'h11;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h1c5:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h1c9:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h1cc:  begin  sfr_wdata=8'h12;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h1d1:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h1d5:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h1d9:  begin  sfr_wdata=8'h13;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h1dc:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h1e1:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h1e5:  begin  sfr_wdata=8'h14;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h1e9:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h1ec:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h1f1:  begin  sfr_wdata=8'h15;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h1f5:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h1f9:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h1fc:  begin  sfr_wdata=8'h16;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h201:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h205:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h209:  begin  sfr_wdata=8'h17;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h20c:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h211:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h215:  begin  sfr_wdata=8'h18;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h219:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h21c:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h221:  begin  sfr_wdata=8'h19;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h225:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h229:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h22c:  begin  sfr_wdata=8'h1a;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h231:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h235:  begin  sfr_wdata=8'h70;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h239:  begin  sfr_wdata=8'h1b;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h23c:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h241:  begin  sfr_wdata=8'h71;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h245:  begin  sfr_wdata=8'h1c;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h249:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h24c:  begin  sfr_wdata=8'h72;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h251:  begin  sfr_wdata=8'h1d;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h255:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h259:  begin  sfr_wdata=8'h73;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h25c:  begin  sfr_wdata=8'h1e;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h261:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h265:  begin  sfr_wdata=8'h74;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h269:  begin  sfr_wdata=8'h1f;sfr_num=8'h00;sfr_addrs=7'h0e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h26c:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end

        12'h271:  begin  sfr_wdata=8'h00;sfr_num=8'h00;sfr_addrs=7'h10;sfr_wen= 1'b1;sfr_cmd=1'b1;end  //软件复位

          12'h300:  begin//测试验证
                    if(_tb.u_asic_top.u_dc_top.point00l  !=8'h0d)begin
                    tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point00l  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point00l); end
                    if(_tb.u_asic_top.u_dc_top.point00h  !=8'h00)begin
                    tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point00h  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point00h); end
                    if(_tb.u_asic_top.u_dc_top.point01l  !=8'h3b)begin
                    tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point01l  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point01l); end
                    if(_tb.u_asic_top.u_dc_top.point01h  !=8'h01)begin
                    tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point01h  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point01h); end
                    if(_tb.u_asic_top.u_dc_top.point02l  !=8'hb2)begin
                    tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point02l  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point02l); end
                    if(_tb.u_asic_top.u_dc_top.point02h  !=8'h02)begin
                    tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point02h  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point02h); end
                    if(_tb.u_asic_top.u_dc_top.point03l  !=8'h58)begin
                    tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point03l  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point03l); end
                    if(_tb.u_asic_top.u_dc_top.point03h  !=8'h03)begin
                    tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point03h  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point03h); end
                    if(_tb.u_asic_top.u_dc_top.point04l  !=8'hb2)begin
                    tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point04l  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point04l); end
                    if(_tb.u_asic_top.u_dc_top.point04h  !=8'h03)begin
                    tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point04h  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point04h); end
                    end
        default:begin                                                sfr_wen= 1'b0;             end
      endcase
    test2:
      case(cn1t)
        12'h031:  begin  sfr_wdata=8'hc0;sfr_num=8'h00;sfr_addrs=7'h10;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        12'h035:  begin  sfr_wdata=8'h70;sfr_num=8'h02;sfr_addrs=7'h26;sfr_wen= 1'b1;sfr_cmd=1'b0;end
        default:begin                                                sfr_wen= 1'b0;             end
      endcase
    default:;
  endcase
end


//---------------DON'T MODIFY BLOW------------------
pow uvdd(
    .vdd(VDD),
    .vss(GND),
    .vda(vda)
    );

pow uvpp(
    .vdd(VPP),
    .vss(GND),
    .vda()
    );

cap ucap(
    .cp (smoke_clk),
    .cn (GND)
   );

initial
begin
 $vcdplusfile("d05200.vpd");
 $vcdpluson(0,_tb);
//   $vcdpluson;
end

//initial
//begin
//  $dumpfile(" d05200_asic_top.vcd");
//  $dumpvars(0,d05200_asic_top);
//end

//--------------------------------

endmodule
