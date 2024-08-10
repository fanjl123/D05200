`timescale 1ns/1ns

module owl_tb
//////////////////////////////////////////////////////////////////////////////
#(
  parameter   CNT_WIDTH     = 8     //计数器宽度，Fsys/Fbit_low，由系统时钟频率与最低通信速率比决定。
                                    //7   @ 2MHz sysclk， 10KHz bit clk,  200
                                    //8   @ 4MHz sysclk,  10KHz bit clk,  400
                                    //9   @ 8MHz sysclk,  10KHz bit clk,  800
                                    //10  @ 16MHz sysclk, 10KHz bit clk,  1600
                                    //11  @ 32MHz sysclk, 10KHz bit clk,  3200
                                    //12  @ 64MHz sysclk, 10KHz bit clk,  6400
);
//////////////////////////////////////////////////////////////////////////////

  reg                     rst       ;
  reg                     clk       ;
  wire                    owl_di    ;
  wire                    owl_do    ;
  wire                    owl_oe    ;
  reg                     sfr_cmd   ;
  reg   [6:0]             sfr_addrs ;
  reg   [7:0]             sfr_num   ;
  reg   [7:0]             sfr_wdata2;
  reg   [7:0]             sfr_wdata1;
  reg   [7:0]             sfr_data  ;
  reg                     sfr_en    ;
  wire  [7:0]             sfr_rdata ;
  wire  [5:0]             sfr_addr1 ;
  wire                    sfr_wctrl ;
  wire                    sfr_rctrl ;
  wire                    sfr_wdata ;
  

owl_mctrl  u_master(
  .rst       (rst       ),
  .clk       (clk       ),
  .owl_di    (owl_di    ),
  .owl_do    (owl_do    ),
//  .owl_oe    (owl_oe    ),
  .sfr_cmd   (sfr_cmd   ),
  .sfr_addrs (sfr_addrs ),
  .sfr_num   (sfr_num   ),
  .sfr_wdata2(sfr_wdata2),
  .sfr_wdata1(sfr_wdata1),
  .sfr_wdata (sfr_data  ),
  .sfr_wctrl (sfr_en    )
);

owl_ctrl  u_slv(
  .rst       (rst      ),
  .clk       (clk      ),
  .owl_di    (owl_do   ),
  .owl_do    (owl_di   ),
  .owl_oe    (owl_oe   ),
  .sfr_wdata (sfr_wdata),
  .sfr_addrs (sfr_addr1),
  .sfr_rctrl (sfr_rctrl),
  .sfr_wctrl (sfr_wctrl)  
);

initial
begin
        rst <=  1'b1;
  #101  rst <=  1'b0;
  #101  rst <=  1'b1;
end


initial clk <=  1'b1;
always #10  clk <=  ~clk;

reg [3:0] count2;
always
@(negedge rst or posedge  clk )
begin
  if(~rst)
    count2 <= 16'h0;
  else if(count2 == 4'h6)
    count2 <= 16'h0;
  else 
    count2 <= count2+1'b1;
end

assign tclk = (count2==4'h6);

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
  case(cn1t)
    8'h10:  begin  sfr_data=8'ha5;sfr_wdata1=8'haa;sfr_wdata2=8'h5a;sfr_num=8'h02;sfr_addrs=7'h1a;sfr_en= 1'b1;sfr_cmd=1'b1;end
    8'h11:  begin  sfr_data=8'ha5;sfr_wdata1=8'haa;sfr_wdata2=8'h5a;sfr_num=8'h02;sfr_addrs=7'h1a;sfr_en= 1'b0;sfr_cmd=1'b1;end
    8'h12:  begin  sfr_data=8'ha5;sfr_wdata1=8'haa;sfr_wdata2=8'h5a;sfr_num=8'h02;sfr_addrs=7'h1a;sfr_en= 1'b0;sfr_cmd=1'b1;end
    8'h13:  begin  sfr_data=8'ha5;sfr_wdata1=8'haa;sfr_wdata2=8'h5a;sfr_num=8'h02;sfr_addrs=7'h1a;sfr_en= 1'b0;sfr_cmd=1'b1;end
    8'h14:  begin  sfr_data=8'ha5;sfr_wdata1=8'haa;sfr_wdata2=8'h5a;sfr_num=8'h02;sfr_addrs=7'h1a;sfr_en= 1'b0;sfr_cmd=1'b1;end
    8'h15:  begin  sfr_data=8'ha5;sfr_wdata1=8'haa;sfr_wdata2=8'h5a;sfr_num=8'h02;sfr_addrs=7'h1a;sfr_en= 1'b0;sfr_cmd=1'b1;end                                                      
    8'h16:  begin  sfr_data=8'ha5;sfr_wdata1=8'haa;sfr_wdata2=8'h5a;sfr_num=8'h02;sfr_addrs=7'h1a;sfr_en= 1'b0;sfr_cmd=1'b1;end
    8'h17:  begin  sfr_data=8'ha5;sfr_wdata1=8'haa;sfr_wdata2=8'h5a;sfr_num=8'h02;sfr_addrs=7'h1a;sfr_en= 1'b0;sfr_cmd=1'b1;end
    8'h18:  begin  sfr_data=8'ha5;sfr_wdata1=8'haa;sfr_wdata2=8'h5a;sfr_num=8'h02;sfr_addrs=7'h1a;sfr_en= 1'b0;sfr_cmd=1'b1;end       
    default:begin  sfr_data=8'ha5;sfr_wdata1=8'haa;sfr_wdata2=8'h5a;sfr_num=8'h02;sfr_addrs=7'h1a;sfr_en= 1'b0;sfr_cmd=1'b1;end
    endcase
end

endmodule