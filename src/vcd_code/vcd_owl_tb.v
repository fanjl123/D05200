`timescale 1ns/1ns

module _tb;
reg          rst       ;
wire         clk       ;
reg          smoke_clk ;
reg          tb_error  ;

reg   [6:0]  sfr_addrs ;
reg          sfr_cmd   ;
reg   [7:0]  sfr_num   ;
reg   [7:0]  sfr_wdata ;
reg          sfr_wen   ;


wire    owl_inout;


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

initial
begin
  #300000000   
  #500000000   $finish(1);
end


//---------------------------------------------测试项目切换（二线模式在数模混合仿真的时候进行）--------------------------------------------------------------------
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
localparam    test00 = 8'h00;//一些临时测试
localparam    test01 = 8'h01;//吸烟保护时长测试/仿真时长：14s
localparam    test02 = 8'h02;//频率差值大于0.75%到3%且维持1后强制更新基准值测试/仿真时长：3s
localparam    test03 = 8'h03;//otp测试仿真(包含软件复位、otp扇区切换)
localparam    test04 = 8'h04;//通过OWL进行高低频转换
localparam    test05 = 8'h05;//owl接口上下行数据访问寄存器
localparam    test06 = 8'h06;//基准值16s强制更新测试/--/初始化(三线模式初始化)/仿真时间：17s
localparam    test0c = 8'h0c;//两线模式初始化、MOD管脚为高电平、外接管脚为OWL和GND信号、MOD_R=1'b1、P管打开
localparam    test0d = 8'h0d;//两线模式初始化、MOD管脚为低电平、外接管脚为OWL和VDD信号、MOD_R=1'b0、N管打开
localparam    test07 = 8'h07;//死区标定

localparam    test08 = 8'h08;//三线无强度50%PWM输出、电容增大型
localparam    test0e = 8'h0e;//三线无强度电平输出、电容减小型
localparam    test0f = 8'h0f;//两线无强度50%PWM输出、电容减小型、外接管脚为OWL和GND信号、MOD_R=1'b1、P管打开
localparam    test10 = 8'h10;//两线无强度50%PWM输出、电容减小型、外接管脚为OWL和VDD信号、MOD_R=1'b0、N管打开
localparam    test09 = 8'h09;//测试口切换

localparam    test0a = 8'h0a;//低速、三线、电容减小型、4点标定、pwm输出模式
localparam    test0b = 8'h0b;//低速、三线、电容增大型、6点标定、pwm输出模式
localparam    test11 = 8'h11;//低速、三线、电容增大型、6点标定、FM输出模式
localparam    test15 = 8'h15;//低速、三线、电容增大型、6点标定、owl被动输出模式、
localparam    test16 = 8'h16;//低速、三线、电容增大型、6点标定、owl被动输出带中断模式
localparam    test12 = 8'h12;//低速、二线、电容减小型、6点标定、FM输出模式、外接管脚为OWL和VDD信号、MOD_R=1'b0、N管打开
localparam    test13 = 8'h13;//低速、二线、电容增大型、6点标定、owl被动输出模式、外接管脚为OWL和VDD信号、MOD_R=1'b0、N管打开、owl通信在低频模式下
localparam    test14 = 8'h14;//低速、二线、电容减小型、6点标定、owl被动输出带中断模式、外接管脚为OWL和GND信号、MOD_R=1'b1、P管打开、owl通信在低频模式下
localparam    test17 = 8'h17;//低速、二线、电容减小型、不标定PWM输出模式、外接管脚为OWL和GND信号、MOD_R=1‘b1、P管打开、owl通信在低频模式下

//-----------高速模式--------------
localparam    test18 = 8'h18;//高速、三线、电容增大型、6点标定、owl被动输出模式
localparam    test19 = 8'h19;//高速、三线、电容减小型、6点标定、owl被动输出带中断模式
localparam    test1a = 8'h1a;//高速、二线、电容增大型、6点标定、owl被动输出模式 (可以用来仿真高速模式下的吸烟保护)
localparam    test1b = 8'h1b;//高速、二线、电容减小型、6点标定、owl被动输出带中断模式
//-----------vcd_owl---------------
localparam    test1c = 8'h1c;//低速、两线、标定模式、五点标定流程
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------------------------------------------------
reg   [3:0] test_owl_item ;

wire  [7:0] total_item;
assign total_item = test1c;

always@(*)
begin
  case(total_item)
//--测试项-------otp控制寄存器--------otp标定点寄存器------owl置数环节---------标定模式选择----外接MOD选择---------smoke_clk-----------------------//
    test00: begin  test_owl_item=4'h0;   end
    test01: begin  test_owl_item=4'h0;   end
    test02: begin  test_owl_item=4'h0;   end
    test03: begin  test_owl_item=4'h3;   end
    test04: begin  test_owl_item=4'h2;   end
    test05: begin  test_owl_item=4'h4;   end
    test06: begin  test_owl_item=4'h0;   end 
    test06: begin  test_owl_item=4'h0;   end 
    test07: begin  test_owl_item=4'h5;   end  
    test08: begin  test_owl_item=4'h0;   end 
    test09: begin  test_owl_item=4'h6;   end  
    test0a: begin  test_owl_item=4'h0;   end 
    test0b: begin  test_owl_item=4'h0;   end 
    test0c: begin  test_owl_item=4'h7;   end
    test0d: begin  test_owl_item=4'h7;   end
    test0e: begin  test_owl_item=4'h0;   end
    test0f: begin  test_owl_item=4'h0;   end 
    test10: begin  test_owl_item=4'h0;   end 
    test11: begin  test_owl_item=4'h0;   end
    test12: begin  test_owl_item=4'h0;   end
    test13: begin  test_owl_item=4'h8;   end
    test14: begin  test_owl_item=4'h8;   end
    test15: begin  test_owl_item=4'h8;   end  
    test16: begin  test_owl_item=4'h8;   end
    test17: begin  test_owl_item=4'h0;   end
    
    test18: begin  test_owl_item=4'h9;   end  
    test19: begin  test_owl_item=4'h9;   end 
    test1a: begin  test_owl_item=4'h9;   end 
    test1b: begin  test_owl_item=4'h9;   end 
    test1c: begin  test_owl_item=4'ha;   end     
  endcase
end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------------------------------------------------

//----------------   频率切换  ---------------------------------------
     
reg        h_en;                               
initial
begin
               h_en         <= 1'b0;
  #256312500   
               h_en         <= 1'b1;
  #25800000
               h_en         <= 1'b0;
end

reg lclk;
initial   lclk <=  1'b1;
always #15000  lclk <= ~lclk;

reg  hclk ;
initial   hclk <=  1'b1;
always #250      hclk <= ~hclk;

assign clk = h_en? hclk : lclk;

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
    cn1t<=12'h000;
  else if(cn1t==12'hfff)
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
    default:;
  endcase
end
initial
begin
  $dumpfile("G05200.vcd");
  $dumpvars(0,vcd_owl_tb);
end


endmodule