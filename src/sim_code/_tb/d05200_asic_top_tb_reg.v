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
wire          VDD=1'b1;
wire          GND=1'b0;
wire          VPP=1'b1;

d05200_asic_top u_asic_top(
  .VDD        (VDD        ),
  .GND        (GND        ),
  .VPP        (VPP        ),

  .OWL        (owl_inout  ),
  .MIC        (smoke_clk  ),
  .TSO        (TSO        )
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
reg [7:0]   count1    ;
reg [11:0]  count3    ;
reg [15:0]  count4    ;
reg        count134_en;
                        

initial
begin
                   rst <=  1'b1;
                   count134_en<= 1'b1;
  #4001            rst <=  1'b0;
  #1001            rst <=  1'b1;
  #2000000            count134_en<= 1'b1;
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
reg sclk;
initial   sclk <=  1'b1;
always #500  sclk <= ~sclk;

always@
(negedge rst or posedge sclk)
begin
  if(~rst)
    count1 <= 8'h00;
  else if(count1==count3)
    count1 <= 8'h00;
  else if(count134_en)
    count1 <= count1+1'b1;
end

always@
(negedge rst or posedge sclk)
begin
  if(~rst)
    count3<=12'h00f;
  else if(count3>=12'h021)
    count3<=12'h00f;
  else if(count4==16'h9999)
    count3<=count3+3'h2;
end

always@
(negedge rst or posedge sclk)
begin
  if(~rst)
    count4<=16'h0000;
  else if(count4==16'h9999)
    count4<=16'h0000;
  else if(count134_en)
    count4<=count4+1'b1;
end

assign smoke_clk =count134_en?(count1==count3):lclk;
//---------------------------------------------测试项目切换--------------------------------------------------------------------
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
localparam    test0 = 4'h0;//标定寄存器测试
localparam    test1 = 4'h1;//otp测试
localparam    test2 = 4'h2;//流程测试
wire  [3:0] test_item;
assign test_item = test0;
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

reg [7:0] cn1t;
always
@(negedge rst or posedge tclk)
begin
  if(~rst)
    cn1t<=8'h00;
  else if(cn1t==8'hff)
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
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////      
//----------------------------------------------初始化命令---------------------------------------------------------------------------------------------------------//
        8'h01:  begin  sfr_wdata=8'h08;sfr_num=8'h00;sfr_addrs=7'h04;sfr_wen= 1'b1;sfr_cmd=1'b1;end                                                              //
        8'h03:  if(_tb.u_asic_top.u_dc_top.u_main_ctrl.mic_mode  !=1'b0)begin                                                                                     //
                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 mic_mode  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.u_main_ctrl.mic_mode); end //
//                                                                                                                                                                 //
//        8'h05:  begin  sfr_wdata=8'h32;sfr_num=8'h00;sfr_addrs=7'h21;sfr_wen= 1'b1;sfr_cmd=1'b1;end                                                              //
//---------------------------------------------5点标定-------------------------------------------------------------------------------------------------------------// 
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        8'h07:  begin  sfr_wdata=8'h0d;sfr_num=8'h00;sfr_addrs=7'h26;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        8'h09:  if(_tb.u_asic_top.u_dc_top.point00l  !=8'h0d)begin
                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point00l  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point00l); end               
        8'h0b:  begin  sfr_wdata=8'h00;sfr_num=8'h00;sfr_addrs=7'h27;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        8'h0d:  if(_tb.u_asic_top.u_dc_top.point00h  !=8'h00)begin
                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point00h  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point00h); end

        8'h0f:  begin  sfr_wdata=8'h3b;sfr_num=8'h00;sfr_addrs=7'h28;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        8'h11:  if(_tb.u_asic_top.u_dc_top.point01l  !=8'h3b)begin
                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point01l  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point01l); end                
        8'h13:  begin  sfr_wdata=8'h01;sfr_num=8'h00;sfr_addrs=7'h29;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        8'h15:  if(_tb.u_asic_top.u_dc_top.point01h  !=8'h01)begin
                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point01h  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point01h); end

        8'h17:  begin  sfr_wdata=8'hb2;sfr_num=8'h00;sfr_addrs=7'h2a;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        8'h19:  if(_tb.u_asic_top.u_dc_top.point02l  !=8'hb2)begin
                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point02l  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point02l); end                
        8'h1b:  begin  sfr_wdata=8'h02;sfr_num=8'h00;sfr_addrs=7'h2b;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        8'h1d:  if(_tb.u_asic_top.u_dc_top.point02h  !=8'h02)begin
                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point02h  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point02h); end

        8'h1f:  begin  sfr_wdata=8'h58;sfr_num=8'h00;sfr_addrs=7'h2c;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        8'h21:  if(_tb.u_asic_top.u_dc_top.point03l  !=8'h58)begin 
                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point03l  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point03l); end
        8'h23:  begin  sfr_wdata=8'h03;sfr_num=8'h00;sfr_addrs=7'h2d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        8'h25:  if(_tb.u_asic_top.u_dc_top.point03h  !=8'h03)begin 
                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point03h  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point03h); end

        8'h27:  begin  sfr_wdata=8'hb2;sfr_num=8'h00;sfr_addrs=7'h2e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        8'h29:  if(_tb.u_asic_top.u_dc_top.point04l  !=8'hb2)begin
                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point04l  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point04l); end
        8'h2b:  begin  sfr_wdata=8'h03;sfr_num=8'h00;sfr_addrs=7'h2f;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        8'h2d:  if(_tb.u_asic_top.u_dc_top.point04h  !=8'h03)begin
                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point04h  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point04h); end
//---------------------------------------------------------十点标定的下半段--------------------------------------------------------------------------               
       8'h2f:   begin  sfr_wdata=8'h05;sfr_num=8'h03;sfr_addrs=7'h14;sfr_wen= 1'b1;sfr_cmd=1'b0;end 
//        8'h31:  if(_tb.u_asic_top.u_dc_top.point05l  !=8'h00)begin
//                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point04l  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point04l); end
//        8'h33:  begin  sfr_wdata=8'h0c;sfr_num=8'h00;sfr_addrs=7'h2f;sfr_wen= 1'b1;sfr_cmd=1'b1;end
//        8'h35:  if(_tb.u_asic_top.u_dc_top.point05h  !=8'h0c)begin
//                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point04h  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point04h); end
//                
//        8'h37:  begin  sfr_wdata=8'h00;sfr_num=8'h00;sfr_addrs=7'h2e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
//        8'h39:  if(_tb.u_asic_top.u_dc_top.point06l  !=8'h00)begin
//                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point04l  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point04l); end
//        8'h3b:  begin  sfr_wdata=8'h0c;sfr_num=8'h00;sfr_addrs=7'h2f;sfr_wen= 1'b1;sfr_cmd=1'b1;end
//        8'h3d:  if(_tb.u_asic_top.u_dc_top.point06h  !=8'h0c)begin
//                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point04h  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point04h); end
//                
//        8'h3f:  begin  sfr_wdata=8'h00;sfr_num=8'h00;sfr_addrs=7'h2e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
//        8'h41:  if(_tb.u_asic_top.u_dc_top.point07l  !=8'h00)begin
//                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point04l  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point04l); end
//        8'h43:  begin  sfr_wdata=8'h0c;sfr_num=8'h00;sfr_addrs=7'h2f;sfr_wen= 1'b1;sfr_cmd=1'b1;end
//        8'h45:  if(_tb.u_asic_top.u_dc_top.point07h  !=8'h0c)begin
//                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point04h  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point04h); end
//                
//        8'h47:  begin  sfr_wdata=8'h00;sfr_num=8'h00;sfr_addrs=7'h2e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
//        8'h49:  if(_tb.u_asic_top.u_dc_top.point08l  !=8'h00)begin
//                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point04l  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point04l); end
//        8'h4b:  begin  sfr_wdata=8'h0c;sfr_num=8'h00;sfr_addrs=7'h2f;sfr_wen= 1'b1;sfr_cmd=1'b1;end
//        8'h4d:  if(_tb.u_asic_top.u_dc_top.point08h  !=8'h0c)begin
//                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point04h  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point04h); end
//                
//        8'h4f:  begin  sfr_wdata=8'h00;sfr_num=8'h00;sfr_addrs=7'h2e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
//        8'h49 :  if(_tb.u_asic_top.u_dc_top.point08l  !=8'h00)begin
//                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point04l  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point04l); end
//        8'h4b:  begin  sfr_wdata=8'h0c;sfr_num=8'h00;sfr_addrs=7'h2f;sfr_wen= 1'b1;sfr_cmd=1'b1;end
//        8'h4d:  if(_tb.u_asic_top.u_dc_top.point08h  !=8'h0c)begin
//                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point04h  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point04h); end                
///////////////////////////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------------------------        
//        8'h31:  begin  sfr_wdata=8'h22;sfr_num=8'h00;sfr_addrs=7'h21;sfr_wen= 1'b1;sfr_cmd=1'b1;end
//        8'h33:  if(_tb.u_asic_top.u_dc_top.u_main_ctrl.out_mod  !=2'h2)begin 
//                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 out_mod  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.u_main_ctrl.out_mod); end
//        8'h35:  begin  sfr_wdata=8'h22;sfr_num=8'h11;sfr_addrs=7'h12;sfr_wen= 1'b1;sfr_cmd=1'b0;end
//-----------------------------------------------------------------------------------------------------
///////////////////////////////////////////////////////////////////////////////////////////////////////     
        default:begin                                                sfr_wen= 1'b0;             end
      endcase
    test1:
      case(cn1t)
        8'h01:  begin  sfr_wdata=8'h09;sfr_num=8'h00;sfr_addrs=7'h04;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        8'h03:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        8'h05:  begin  sfr_wdata=8'h80;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        8'h07:  begin  sfr_wdata=8'h80;sfr_num=8'h00;sfr_addrs=7'h07;sfr_wen= 1'b0;sfr_cmd=1'b1;end
        default:begin                                                sfr_wen= 1'b0;             end
      endcase
    test2:
      case(cn1t)
        8'h01:  begin  sfr_wdata=8'h92;sfr_num=8'h00;sfr_addrs=7'h09;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        8'h03:  if(_tb.u_asic_top.u_dc_top.u_main_ctrl.mic_mode  !=1'b1)begin                                                                                     
                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 mic_mode  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.u_main_ctrl.mic_mode); end
                
        8'h05:  begin  sfr_wdata=8'haa;sfr_num=8'h00;sfr_addrs=7'h08;sfr_wen= 1'b0;sfr_cmd=1'b1;end
        8'h07:  if(_tb.u_asic_top.u_dc_top.u_main_ctrl.lclk_cfr  !=4'ha)begin                                                                                     
                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 lclk_cfr  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.u_main_ctrl.lclk_cfr); end
        
        8'h09:  begin  sfr_wdata=8'haa;sfr_num=8'h00;sfr_addrs=7'h09;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        8'h0b:  if(_tb.u_asic_top.u_dc_top.u_main_ctrl.hclk_cfr  !=8'haa)begin                                                                                     
                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 hclk_cfr  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.u_main_ctrl.hclk_cfr); end
                
        8'h0d:  begin  sfr_wdata=8'h80;sfr_num=8'h00;sfr_addrs=7'h0b;sfr_wen= 1'b0;sfr_cmd=1'b1;end
        8'h0f:  if(_tb.u_asic_top.u_dc_top.u_main_ctrl.lclk_cfr  !=4'ha)begin                                                                                     
                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 lclk_cfr  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.u_main_ctrl.lclk_cfr); end
        
        8'h11:  begin  sfr_wdata=8'haa;sfr_num=8'h00;sfr_addrs=7'h05;sfr_wen= 1'b0;sfr_cmd=1'b1;end
        8'h13:  if(_tb.u_asic_top.u_dc_top.u_main_ctrl.lclk_cfr  !=4'ha)begin                                                                                     
                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 lclk_cfr  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.u_main_ctrl.lclk_cfr); end
        8'h15:  begin  sfr_wdata=8'haa;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        8'h17:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        8'h19:  begin  sfr_wdata=8'h80;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        8'h1b:  begin  sfr_wdata=8'h80;sfr_num=8'h00;sfr_addrs=7'h07;sfr_wen= 1'b0;sfr_cmd=1'b1;end
        8'h1d:  begin  sfr_wdata=8'h92;sfr_num=8'h00;sfr_addrs=7'h09;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        8'h1f:  begin  sfr_wdata=8'haa;sfr_num=8'h00;sfr_addrs=7'h05;sfr_wen= 1'b0;sfr_cmd=1'b1;end
        
        8'h21:  begin  sfr_wdata=8'h80;sfr_num=8'h00;sfr_addrs=7'h06;sfr_wen= 1'b0;sfr_cmd=1'b1;end
        8'h23:  begin  sfr_wdata=8'haa;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        8'h25:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        8'h27:  begin  sfr_wdata=8'h80;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        8'h29:  begin  sfr_wdata=8'h80;sfr_num=8'h00;sfr_addrs=7'h07;sfr_wen= 1'b0;sfr_cmd=1'b1;end
        8'h2b:  begin  sfr_wdata=8'h92;sfr_num=8'h00;sfr_addrs=7'h09;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        8'h2d:  begin  sfr_wdata=8'haa;sfr_num=8'h00;sfr_addrs=7'h05;sfr_wen= 1'b0;sfr_cmd=1'b1;end

        8'h31:  begin  sfr_wdata=8'h80;sfr_num=8'h00;sfr_addrs=7'h06;sfr_wen= 1'b0;sfr_cmd=1'b1;end
        8'h33:  begin  sfr_wdata=8'haa;sfr_num=8'h00;sfr_addrs=7'h0d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        8'h35:  begin  sfr_wdata=8'h40;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        8'h37:  begin  sfr_wdata=8'h80;sfr_num=8'h00;sfr_addrs=7'h0c;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        8'h39:  begin  sfr_wdata=8'h80;sfr_num=8'h00;sfr_addrs=7'h07;sfr_wen= 1'b0;sfr_cmd=1'b1;end
        8'h3b:  begin  sfr_wdata=8'h92;sfr_num=8'h00;sfr_addrs=7'h09;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        8'h3d:  begin  sfr_wdata=8'haa;sfr_num=8'h00;sfr_addrs=7'h05;sfr_wen= 1'b0;sfr_cmd=1'b1;end        
        default:begin                                                sfr_wen= 1'b0;             end
      endcase
    default:;
  endcase
end
endmodule
