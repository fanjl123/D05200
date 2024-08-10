`timescale 1ns/1ns

module _tb_fpga;

reg   rst;
reg   clk;

initial
begin
        rst <=  1'b1;
  #101  rst <=  1'b0;
  #101  rst <=  1'b1;
end

initial clk <=  1'b1;
always #10  clk <=  ~clk;
//------------------------------
reg   [15:0]  mic_width;
reg   [15:0]  mic_cnt;
wire          mic_hclk;
reg           mic_clk;

initial
begin                         
              mic_width <= 16'd562;
  #250000000  mic_width <= 16'd672;
  #250000000  mic_width <= 16'd782;
  #250000000  mic_width <= 16'd792;
  #250000000  mic_width <= 16'd802;
  #250000000  mic_width <= 16'd812;
  //#60000000  mic_width <= 16'd808;
  //#60000000  mic_width <= 16'd814;
  //#60000000  mic_width <= 16'd820;
  //#60000000  mic_width <= 16'd826;
  //#60000000  mic_width <= 16'd832;
  //#60000000  mic_width <= 16'd838;
  //#60000000  mic_width <= 16'd844;
  //#60000000  mic_width <= 16'd850;
  //#60000000  mic_width <= 16'd856;
end



always
@(negedge rst or posedge clk)
begin
  if(~rst)
    mic_cnt <=  16'h0;
  else if(mic_hclk)
    mic_cnt <=  16'h0;
  else
    mic_cnt <=  mic_cnt+1'b1;
end

assign  mic_hclk  = (mic_cnt==mic_width);

always
@(negedge rst or posedge clk)
begin
  if(~rst)
    mic_clk <=  1'b0;
  else if(mic_hclk)
    mic_clk <=  ~mic_clk;
end
//------------------------------
reg   [7:0]   clk_cnt0;
reg   [7:0]   clk_cnt1;
reg   [15:0]   frame_cnt;

always
@(negedge rst or posedge clk)
begin
  if(~rst)
  begin
    clk_cnt0  <=  8'h0;
    clk_cnt1  <=  8'h0;
    frame_cnt <=  16'h0;
  end
  else
  begin
    clk_cnt0  <=  clk_cnt0+1'b1;
    if(& clk_cnt0)  clk_cnt1<=  clk_cnt1+1'b1;
    if(& clk_cnt1 & & clk_cnt0) frame_cnt <=  frame_cnt+1'b1;
  end
end
//------------------------------
wire  [7:0]   scon;       reg   scon_wctrl;
wire  [7:0]   smd0;       reg   smd0_wctrl;
wire  [7:0]   smd1;       reg   smd1_wctrl;
wire  [7:0]   spls;       reg   spls_wctrl;
wire  [7:0]   sccl;       reg   sccl_wctrl;
wire  [7:0]   sbuf;       reg   sbuf_wctrl;   reg   sbuf_rctrl;
reg   [7:0]   sfr_wdata;

always
@(*)
begin
  smd0_wctrl<=1'b0;
  sbuf_wctrl<=1'b0;
  sccl_wctrl<=1'b0;
  scon_wctrl<=1'b0;
  spls_wctrl<=1'b0;
  sbuf_rctrl<=1'b0;
  smd1_wctrl<=1'b0;

  if(clk_cnt1==8'h0 & clk_cnt0==8'h0)
  begin
    case(frame_cnt)
    
      16'h01:  begin sfr_wdata<=8'h82; scon_wctrl<=1'b1; end
      16'h02:  begin sfr_wdata<=8'h09; smd1_wctrl<=1'b1; end
      16'h03:  begin sfr_wdata<=8'hfb; sccl_wctrl<=1'b1; end
      16'h04:  begin sfr_wdata<=8'h00; sbuf_wctrl<=1'b1; end
      16'h05:  begin sfr_wdata<=8'h01; smd0_wctrl<=1'b1; end
      16'h07:  begin sfr_wdata<=8'h01; sbuf_wctrl<=1'b1; end
      
      
      
     
      16'h08: begin sfr_wdata<=8'h82; sbuf_wctrl<=1'b1; end   
      16'h09: begin sfr_wdata<=8'h85; sbuf_wctrl<=1'b1; end
      16'h0a: begin sfr_wdata<=8'h83; sbuf_wctrl<=1'b1; end   
      16'h0b: begin sfr_wdata<=8'h03; sbuf_wctrl<=1'b1; end
      16'h0c: begin sfr_wdata<=8'h8a; sbuf_wctrl<=1'b1; end//pwm计算及输出
      16'h0d: begin sfr_wdata<=8'he0; sbuf_wctrl<=1'b1; end
      
      16'h10: begin sfr_wdata<=8'h86; sbuf_wctrl<=1'b1; end//基准大气压
      16'h11: begin sfr_wdata<=8'h96; sbuf_wctrl<=1'b1; end
      16'h12: begin sfr_wdata<=8'h87; sbuf_wctrl<=1'b1; end 
      16'h13: begin sfr_wdata<=8'h07; sbuf_wctrl<=1'b1; end
      
      16'h14: begin sfr_wdata<=8'h98; sbuf_wctrl<=1'b1; end //标定点0——4
      16'h15: begin sfr_wdata<=8'h00; sbuf_wctrl<=1'b1; end   
      16'h16: begin sfr_wdata<=8'h99; sbuf_wctrl<=1'b1; end
      16'h17: begin sfr_wdata<=8'h14; sbuf_wctrl<=1'b1; end 
      
      16'h18: begin sfr_wdata<=8'h9a; sbuf_wctrl<=1'b1; end     
      16'h19: begin sfr_wdata<=8'h01; sbuf_wctrl<=1'b1; end
      16'h1a: begin sfr_wdata<=8'h9b; sbuf_wctrl<=1'b1; end
      16'h1b: begin sfr_wdata<=8'h9e; sbuf_wctrl<=1'b1; end
      
      16'h1c: begin sfr_wdata<=8'h9c; sbuf_wctrl<=1'b1; end      
      16'h1d: begin sfr_wdata<=8'h03; sbuf_wctrl<=1'b1; end
      16'h1e: begin sfr_wdata<=8'h9d; sbuf_wctrl<=1'b1; end
      16'h1f: begin sfr_wdata<=8'h03; sbuf_wctrl<=1'b1; end
      
      16'h20: begin sfr_wdata<=8'h9e; sbuf_wctrl<=1'b1; end      
      16'h21: begin sfr_wdata<=8'h03; sbuf_wctrl<=1'b1; end
      16'h22: begin sfr_wdata<=8'h9f; sbuf_wctrl<=1'b1; end
      16'h23: begin sfr_wdata<=8'h84; sbuf_wctrl<=1'b1; end 
      
      16'h24: begin sfr_wdata<=8'ha0; sbuf_wctrl<=1'b1; end      
      16'h25: begin sfr_wdata<=8'h03; sbuf_wctrl<=1'b1; end
      16'h26: begin sfr_wdata<=8'ha1; sbuf_wctrl<=1'b1; end
      16'h27: begin sfr_wdata<=8'hca; sbuf_wctrl<=1'b1; end
      //16'h26:  begin sfr_wdata<=8'ha2; sbuf_wctrl<=1'b1; end
      //16'h27:  begin sfr_wdata<=8'h00; sbuf_wctrl<=1'b1; end
      //16'h28:  begin sfr_wdata<=8'ha3; sbuf_wctrl<=1'b1; end
      //16'h29:  begin sfr_wdata<=8'h30; sbuf_wctrl<=1'b1; end
      //             
      //16'h2a:  begin sfr_wdata<=8'ha4; sbuf_wctrl<=1'b1; end
      //16'h2b:  begin sfr_wdata<=8'h00; sbuf_wctrl<=1'b1; end
      //16'h2c:  begin sfr_wdata<=8'ha5; sbuf_wctrl<=1'b1; end
      //16'h2d:  begin sfr_wdata<=8'h3d; sbuf_wctrl<=1'b1; end
      //             
      //16'h2e:  begin sfr_wdata<=8'ha6; sbuf_wctrl<=1'b1; end
      //16'h2f:  begin sfr_wdata<=8'h00; sbuf_wctrl<=1'b1; end
      //16'h30:  begin sfr_wdata<=8'ha7; sbuf_wctrl<=1'b1; end
      //16'h31:  begin sfr_wdata<=8'h47; sbuf_wctrl<=1'b1; end
      //             
      //16'h32:  begin sfr_wdata<=8'ha8; sbuf_wctrl<=1'b1; end
      //16'h33:  begin sfr_wdata<=8'h00; sbuf_wctrl<=1'b1; end
      //16'h34:  begin sfr_wdata<=8'ha9; sbuf_wctrl<=1'b1; end
      //16'h35:  begin sfr_wdata<=8'h59; sbuf_wctrl<=1'b1; end
      //             
      //16'h36:  begin sfr_wdata<=8'haa; sbuf_wctrl<=1'b1; end
      //16'h37:  begin sfr_wdata<=8'h00; sbuf_wctrl<=1'b1; end
      //16'h38:  begin sfr_wdata<=8'hab; sbuf_wctrl<=1'b1; end
      //16'h39:  begin sfr_wdata<=8'h69; sbuf_wctrl<=1'b1; end
      //             
      //16'h3a:  begin sfr_wdata<=8'hac; sbuf_wctrl<=1'b1; end
      //16'h3b:  begin sfr_wdata<=8'h00; sbuf_wctrl<=1'b1; end
      //16'h3c:  begin sfr_wdata<=8'had; sbuf_wctrl<=1'b1; end
      //16'h3d:  begin sfr_wdata<=8'h7f; sbuf_wctrl<=1'b1; end
      //             
      //16'h3e:  begin sfr_wdata<=8'hae; sbuf_wctrl<=1'b1; end
      //16'h3f:  begin sfr_wdata<=8'h00; sbuf_wctrl<=1'b1; end
      //16'h40:  begin sfr_wdata<=8'haf; sbuf_wctrl<=1'b1; end
      //16'h41:  begin sfr_wdata<=8'h9b; sbuf_wctrl<=1'b1; end
      //            
      //16'h42:  begin sfr_wdata<=8'hb0; sbuf_wctrl<=1'b1; end
      //16'h43:  begin sfr_wdata<=8'h00; sbuf_wctrl<=1'b1; end
      //16'h44:  begin sfr_wdata<=8'hb1; sbuf_wctrl<=1'b1; end
      //16'h45:  begin sfr_wdata<=8'hb7; sbuf_wctrl<=1'b1; end
      //             
      //16'h46:  begin sfr_wdata<=8'hb2; sbuf_wctrl<=1'b1; end
      //16'h47:  begin sfr_wdata<=8'h00; sbuf_wctrl<=1'b1; end
      //16'h48:  begin sfr_wdata<=8'hb3; sbuf_wctrl<=1'b1; end
      //16'h49:  begin sfr_wdata<=8'hd3; sbuf_wctrl<=1'b1; end
      //            
      //16'h4a:  begin sfr_wdata<=8'hb4; sbuf_wctrl<=1'b1; end
      //16'h4b:  begin sfr_wdata<=8'h00; sbuf_wctrl<=1'b1; end
      //16'h4c:  begin sfr_wdata<=8'hb5; sbuf_wctrl<=1'b1; end
      //16'h4d:  begin sfr_wdata<=8'hea; sbuf_wctrl<=1'b1; end
      //             
      //16'h4e:  begin sfr_wdata<=8'hb6; sbuf_wctrl<=1'b1; end
      //16'h4f:  begin sfr_wdata<=8'h01; sbuf_wctrl<=1'b1; end
      //16'h52:  begin sfr_wdata<=8'hb7; sbuf_wctrl<=1'b1; end
      //16'h53:  begin sfr_wdata<=8'h02; sbuf_wctrl<=1'b1; end
      //             
      //16'h54:  begin sfr_wdata<=8'h82; sbuf_wctrl<=1'b1; end
      //16'h55:  begin sfr_wdata<=8'h80; sbuf_wctrl<=1'b1; end     
      
      default:  ;
    endcase
  end
end

//------------------------------
wire    rxd;
wire    txd;

uart0 u_uart_mst(
  .rst        (rst      ),
  .clk        (clk      ),
  .txd        (txd      ),
  .rxd        (rxd      ),
  .scon       (scon     ),   .scon_wctrl(scon_wctrl),
  .smd0       (smd0     ),   .smd0_wctrl(smd0_wctrl),
  .smd1       (smd1     ),   .smd1_wctrl(smd1_wctrl),
  .spls       (spls     ),   .spls_wctrl(spls_wctrl),
  .sccl       (sccl     ),   .sccl_wctrl(sccl_wctrl),
  .sbuf       (sbuf     ),   .sbuf_wctrl(sbuf_wctrl),   .sbuf_rctrl(sbuf_rctrl),
  .sfr_wdata  (sfr_wdata)
);
//------------------------------
wire          pwm_out;

wire          cs1   ;
wire          cs2   ;
wire          cs3   ;
wire          cs4   ;
wire          a1    ;
wire          b1    ;
wire          c1    ;
wire          d1    ;
wire          e1    ;
wire          f1    ;
wire          g1    ;
wire          dg1   ;
wire          a2    ;
wire          b2    ;
wire          c2    ;
wire          d2    ;
wire          e2    ;
wire          f2    ;
wire          g2    ;
wire          dg2   ;

mic_fpga_top  u_fpga_top(
  .rst            (rst            ),
  .clk            (clk            ),
  .mic_clk        (mic_clk        ),
  .pwm_out        (pwm_out        ),

  .cs1            (cs1            ),
  .cs2            (cs2            ),
  .cs3            (cs3            ),
  .cs4            (cs4            ),
  .a1             (a1             ),
  .b1             (b1             ),
  .c1             (c1             ),
  .d1             (d1             ),
  .e1             (e1             ),
  .f1             (f1             ),
  .g1             (g1             ),
  .dg1            (dg1            ),
  .a2             (a2             ),
  .b2             (b2             ),
  .c2             (c2             ),
  .d2             (d2             ),
  .e2             (e2             ),
  .f2             (f2             ),
  .g2             (g2             ),
  .dg2            (dg2            ),

  .rxd            (txd            ),
  .txd            (rxd            )
);
//------------------------------
endmodule
