`timescale 1ns/1ns
module otp_ip(
  input   wire                  CLK        ,
  input   wire                  RST        ,
  input   wire                  VPP        ,  
  input   wire                  CS         ,
  input   wire                  PROG       ,
  input   wire                  READ       ,
  input   wire  [6:0]           ADR        ,
  input   wire  [7:0]           DIN        ,
  output  wire  [7:0]           DO       
);

localparam    otp_idle0     = 4'h0;
localparam    otp_start     = 4'h1;
localparam    otp_prog      = 4'h2;
localparam    otp_end       = 4'hf;
localparam    otp_read      = 4'h3;

//-------------------------------CS/vpp 跳变沿检测 -----------------------------

localparam    delay_2        = 16'h0064;
localparam    delay_1        = 16'h0032;
localparam    delay_6        = 16'h012c;
localparam    delay_200      = 16'h2710;
localparam    delay_400      = 16'h4e20;
localparam    delay_end      = 16'hdddd;

reg [15:0]count2  ;
reg       wrong ;

reg [1:0] cs_chreg   ;
reg [1:0] prog_chreg ;
reg [1:0] read_chreg ;
reg [1:0] wrong_chreg;

wire cs_pos   ;
wire prog_pos ;
wire cs_neg   ;
wire prog_neg ;
wire read_pos ;
wire read_neg ;
wire wrong_pos;

always
@(negedge RST or posedge CLK)
begin
  if(~RST)
  begin
    cs_chreg   <=  2'b00;
    prog_chreg <=  2'b00;
    read_chreg <=  2'b00;
    wrong_chreg<=  2'b00;    
  end
  else 
  begin
    cs_chreg[0]   <=CS   ;      cs_chreg[1]   <=cs_chreg[0]   ;
    prog_chreg[0] <=PROG ;      prog_chreg[1] <=prog_chreg[0] ;
    read_chreg[0] <=READ ;      read_chreg[1] <=read_chreg[0] ;
    wrong_chreg[0]<=wrong;      wrong_chreg[1]<=wrong_chreg[0];
  end
end
assign  cs_pos     = ~cs_chreg[1]   & cs_chreg[0]    ;
assign  cs_neg     = ~cs_chreg[0]   & cs_chreg[1]    ;
assign  prog_pos   = ~prog_chreg[1] & prog_chreg[0]  ;
assign  prog_neg   = ~prog_chreg[0] & prog_chreg[1]  ;
assign  read_pos   = ~read_chreg[1] & read_chreg[0]   ; 
assign  read_neg   = ~read_chreg[0] & read_chreg[1]  ; 
assign  wrong_pos  = ~wrong_chreg[1]& wrong_chreg[0] ;
reg [13:0] adr_chreg ;
wire       adr_change;

always
@(negedge RST or posedge CLK)
begin
  if(~RST)
    adr_chreg<=14'h0;
  else
  begin
    if(CS)begin adr_chreg[6:0]<=ADR; adr_chreg[13:7]<=adr_chreg[6:0]; end
  end
end

assign adr_change = (adr_chreg[6:0]!=adr_chreg[13:7]);
//-------------------------计数器（检测到跳变沿复位）---------------
always
@(negedge RST or posedge  CLK )
begin
  if(~RST)
    count2 <= 16'h0;
  else if( cs_pos | prog_pos | prog_neg | read_pos | read_neg | adr_change | cs_neg )
    count2 <= 16'h0;
  else 
    count2 <= count2+1'b1;
end

//-------------------------状态机-----------------------------------
//   功能：根据跳变沿进行延时状态检测，延时不够直接回到初始状态！！
//   同时产生一个错误信号，从而对ram的读取造成影响。
//------------------------------------------------------------------
reg [3:0] pstate;
reg [3:0] nstate;

wire rst1;
assign rst1 = RST & ~(count2==delay_end) & ~wrong_pos;

always
@(negedge rst1 or posedge CLK)
begin  
  if(~rst1)
    pstate <= 4'h0;
  else
    pstate <=nstate;
end

always@(*)
begin
   nstate = pstate;
   casex(pstate)
   otp_idle0: 
     begin
       case({VPP,cs_pos,wrong })
       3'b110: nstate = otp_start;
       default:;
       endcase
     end
   otp_start:if(wrong)            nstate=otp_end ;
             else if(prog_pos)    nstate=otp_prog;
             else if(read_pos)    nstate=otp_read;
   otp_prog: if(wrong || cs_neg)  nstate=otp_end ;
   otp_read: if(wrong || cs_neg)  nstate=otp_end ;
   default:;
   endcase
end

always
@(negedge rst1 or posedge CLK)
begin
  if(~rst1)
    wrong <= 1'b0;
  else
  begin
    if(adr_change & CS)     wrong <= ~(count2>=delay_1);
    else if(cs_neg)         wrong <= ~(count2>=delay_1);
    case (pstate)
    otp_start: 
        if(prog_pos || read_pos)        wrong <= ~(count2>=delay_6);     
    otp_prog:  
        if(prog_pos)        wrong <= ~(count2>=delay_1);
        else if(prog_neg)   wrong <= ~((delay_400>= count2)&&(count2>=delay_200)); 
    otp_read:   
        if(read_pos)        wrong <= ~(count2>=delay_1);
        else if(read_neg)   wrong <= ~(count2>=delay_2);    
    default: ;
    endcase
  end
end

//-------------------------------------------
otp_ram u_ram(
  .wrong    (wrong),
  .pclk     (PROG ),
  .rclk     (READ ),
  .cs_en    (CS   ),
  .addr     (ADR  ),
  .din      (DIN  ),
  .dout     (DO   )
);
//-------------------------------------------
endmodule
