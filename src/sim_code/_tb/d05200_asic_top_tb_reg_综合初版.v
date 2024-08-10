`timescale 1ns/1ns

module _tb;
reg          rst       ;
reg          rst1      ;
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
reg [7:0]   count1_large    ;
reg [11:0]  count3_large    ;
reg [15:0]  count4_large    ;
reg        count134_en_large;

reg [7:0]   count1_small    ;
reg [11:0]  count3_small    ;
reg [15:0]  count4_small    ;
reg        count134_en_small;             

initial
begin
                   rst <=  1'b1;
                   rst1<=  1'b1;
  #4001            rst <=  1'b0;
                   rst1<=  1'b0;
  #1001            rst <=  1'b1;
                   rst1<=  1'b1;
  #800_800_000     rst <=  1'b0;
  #1001            rst <=  1'b1;
end

//----------------   owl主模块频率切换(暂且不用)  ----------------
     
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
//-----------------------电容增大型smoke_clk的频率变化--------------------------------
reg sclk_large;
initial   sclk_large <=  1'b1;
always #500  sclk_large <= ~sclk_large;

always@
(negedge rst or posedge sclk_large)
begin
  if(~rst)
    count1_large <= 8'h00;
  else if(count1_large==count3_large)
    count1_large <= 8'h00;
  else if(count134_en_large)
    count1_large <= count1_large+1'b1;
end

always@
(negedge rst or posedge sclk_large)
begin
  if(~rst)
    count3_large<=12'h00f;
  else if(count3_large>=12'h021)
    count3_large<=12'h00f;
  else if(count4_large==16'h9999)
    count3_large<=count3_large+3'h2;
end

always@
(negedge rst or posedge sclk_large)
begin
  if(~rst)
    count4_large<=16'h0000;
  else if(count4_large==16'h9999)
    count4_large<=16'h0000;
  else if(count134_en_large)
    count4_large<=count4_large+1'b1;
end
//-----------------------电容减小型smoke_clk的频率变化--------------------------------
reg sclk_small;
initial   sclk_small <=  1'b1;
always #100  sclk_small <= ~sclk_small;

always@
(negedge rst or posedge sclk_small)
begin
  if(~rst)
    count1_small <= 8'h00;
  else if(count1_small==count3_small)
    count1_small <= 8'h00;
  else if(count134_en_small)
    count1_small <= count1_small+1'b1;
end

always@
(negedge rst or posedge sclk_small)
begin
  if(~rst)
    count3_small<=12'h05e;
  else if(count3_small<=12'h055)
    count3_small<=12'h05e;
  else if(count4_small==19'h30000)
    count3_small<=count3_small-1'b1;
end

always@
(negedge rst or posedge sclk_small)
begin
  if(~rst)
    count4_small<=19'h00000;
  else if(count4_small==19'h30000)
    count4_small<=19'h00000;
  else if(count134_en_small)
    count4_small<=count4_small+1'b1;
end

//--------------------------------smoke_clk频率切换----------------------------
assign smoke_clk =(_tb.u_asic_top.u_dc_top.u_main_ctrl.mic_mode)?(count1_small==count3_small):(count1_large==count3_large);

//---------------------------------   测试逻辑   -----------------------------------------
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

reg [15:0] cn1t      ;
reg [15:0] smoke_fs  ;
reg [3:0]  test_item ;
always
@(negedge rst or posedge tclk)
begin
  if(~rst)
    cn1t<=16'h0000;
  else if(cn1t==smoke_fs)
  cn1t<=16'h0000;
  else
    cn1t<=cn1t+1'b1;
end

initial
begin
                smoke_fs  = 16'h0821;
  #801_000_000  smoke_fs  = 16'h0821;
  #801_000_000  smoke_fs  = 16'h0140;
  #100_000_000  smoke_fs  = 16'h0150;
  #100_000_000  smoke_fs  = 16'h0160;
  #100_000_000  smoke_fs  = 16'h0170;
  #100_000_000  smoke_fs  = 16'h0180;
  #100_000_000  smoke_fs  = 16'h0190; 
end
wire  test_item_en;
assign test_item_en = (cn1t==smoke_fs);

always
@(negedge rst1 or posedge tclk)          //4'h0:5点标定电容增大型
begin                                    //4'h1:5点标定电容减小型
  if(~rst1)                              //
    test_item <= 4'h0;//测试项目切换点   //
  else if(test_item_en)                  //
    test_item <= test_item +1'b1;        //
end 

//------------------测试激励-------------------------
always
@(*)
begin
  case(test_item)
    4'h0://5点标定电容增大型
      case(cn1t)      
//-------------------------------------------------------------------------------------------------------------------------------------------------------//
        8'h01:  begin  sfr_wdata=8'hb2;sfr_num=8'h00;sfr_addrs=7'h21;sfr_wen= 1'b1;sfr_cmd=1'b1;end //设置为5点标定                                                             
        8'h03:  if(_tb.u_asic_top.u_dc_top.u_main_ctrl.point_md  !=3'h2)begin                                                                                     
                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point_md  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.u_main_ctrl.point_md); end
                                                                                                                                                               
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
//-----------------------------------------------------------------------------------------------------------------------------------               
        8'h2f:   begin  sfr_wdata=8'h0a;sfr_num=8'h00;sfr_addrs=7'h23;sfr_wen= 1'b1;sfr_cmd=1'b1;end //调整PWM_PRC的数值
        8'h31:  if(_tb.u_asic_top.u_dc_top.u_main_ctrl.pwm_prc  !=4'ha)begin
               tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 pwm_prc  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.u_main_ctrl.pwm_prc); end
               
        8'h4e:   begin count134_en_large= 1'b1;                                                                                                    end 
        
   
        default:begin                                                sfr_wen= 1'b0;             end
      endcase
    4'h1://5点标定电容减小型
      case(cn1t)
//-------------------------------------------------------------------------------------------------------------------------------------------------------//
        8'h01:  begin  sfr_wdata=8'h09;sfr_num=8'h00;sfr_addrs=7'h04;sfr_wen= 1'b1;sfr_cmd=1'b1;end//设置为电容减小型                                                              
        8'h03:  if(_tb.u_asic_top.u_dc_top.u_main_ctrl.mic_mode  !=1'b1)begin                                                                                     
                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 mic_mode  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.u_main_ctrl.mic_mode); end               

        8'h07:  begin  sfr_wdata=8'h10;sfr_num=8'h00;sfr_addrs=7'h26;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        8'h09:  if(_tb.u_asic_top.u_dc_top.point00l  !=8'h10)begin
                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point00l  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point00l); end               
        8'h0b:  begin  sfr_wdata=8'h00;sfr_num=8'h00;sfr_addrs=7'h27;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        8'h0d:  if(_tb.u_asic_top.u_dc_top.point00h  !=8'h00)begin
                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point00h  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point00h); end

        8'h0f:  begin  sfr_wdata=8'h5b;sfr_num=8'h00;sfr_addrs=7'h28;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        8'h11:  if(_tb.u_asic_top.u_dc_top.point01l  !=8'h5b)begin
                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point01l  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point01l); end                
        8'h13:  begin  sfr_wdata=8'h00;sfr_num=8'h00;sfr_addrs=7'h29;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        8'h15:  if(_tb.u_asic_top.u_dc_top.point01h  !=8'h00)begin
                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point01h  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point01h); end

        8'h17:  begin  sfr_wdata=8'h75;sfr_num=8'h00;sfr_addrs=7'h2a;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        8'h19:  if(_tb.u_asic_top.u_dc_top.point02l  !=8'h75)begin
                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point02l  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point02l); end                
        8'h1b:  begin  sfr_wdata=8'h00;sfr_num=8'h00;sfr_addrs=7'h2b;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        8'h1d:  if(_tb.u_asic_top.u_dc_top.point02h  !=8'h00)begin
                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point02h  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point02h); end

        8'h1f:  begin  sfr_wdata=8'h7f;sfr_num=8'h00;sfr_addrs=7'h2c;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        8'h21:  if(_tb.u_asic_top.u_dc_top.point03l  !=8'h7f)begin 
                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point03l  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point03l); end
        8'h23:  begin  sfr_wdata=8'h00;sfr_num=8'h00;sfr_addrs=7'h2d;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        8'h25:  if(_tb.u_asic_top.u_dc_top.point03h  !=8'h00)begin 
                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point03h  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point03h); end

        8'h27:  begin  sfr_wdata=8'h89;sfr_num=8'h00;sfr_addrs=7'h2e;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        8'h29:  if(_tb.u_asic_top.u_dc_top.point04l  !=8'h89)begin
                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point04l  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point04l); end
        8'h2b:  begin  sfr_wdata=8'h00;sfr_num=8'h00;sfr_addrs=7'h2f;sfr_wen= 1'b1;sfr_cmd=1'b1;end
        8'h2d:  if(_tb.u_asic_top.u_dc_top.point04h  !=8'h00)begin
                tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point04h  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.point04h); end
//-----------------------------------------------------------------------------------------------------------------------------------               
        8'h2f:   begin  sfr_wdata=8'h08;sfr_num=8'h00;sfr_addrs=7'h23;sfr_wen= 1'b1;sfr_cmd=1'b1;end //调整PWM_PRC的数值
        8'h31:  if(_tb.u_asic_top.u_dc_top.u_main_ctrl.pwm_prc  !=4'h8)begin
               tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 pwm_prc  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.u_main_ctrl.pwm_prc); end
        8'h33:  begin  sfr_wdata=8'hb2;sfr_num=8'h00;sfr_addrs=7'h21;sfr_wen= 1'b1;sfr_cmd=1'b1;end// 设置为5点标定
        8'h35:  if(_tb.u_asic_top.u_dc_top.u_main_ctrl.point_md  !=4'h2)begin
               tb_error =1'b1; $write("test_item=%h, cn1t=%h:  ERR: 6005 point_md  = %h \n",  test_item, cn1t, _tb.u_asic_top.u_dc_top.u_main_ctrl.point_md); end
         
        8'h4e:   begin count134_en_small= 1'b1;                                                                                                    end         
        default:begin                                                sfr_wen= 1'b0;             end
      endcase
    4'h2:
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
