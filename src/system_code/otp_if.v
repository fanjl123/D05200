`timescale 1ns/1ns

module otp_if(
  input   wire          rst,
  input   wire          clk,          //type 32us
  input   wire          run_ctrl,
  output  reg           otp_cs,
  output  reg           otp_read,
  output  reg           otp_prog,
  output  wire  [6:0]   otp_addr,
  output  wire  [7:0]   otp_dati,
  input   wire  [7:0]   otp_dato,

  input   wire          rom_wctrl,
  input   wire          rom_rctrl,
  input   wire  [6:0]   rom_addrs,
  input   wire  [7:0]   rom_wdata,
  output  reg   [7:0]   rom_rdata,
  output  wire          rom_ready
);
//-----------------------------------
localparam    c_pgm_time        = 4'ha;

localparam    s_otp_standby     = 3'h0;
localparam    s_otp_css         = 3'h1;
localparam    s_otp_ad          = 3'h2;
localparam    s_otp_rd          = 3'h3;
localparam    s_otp_wr          = 3'h4;
localparam    s_otp_rdy         = 3'h5;
localparam    s_otp_csh         = 3'h6;

reg   [2:0]   pstate,nstate;
reg   [3:0]   clk_cnt;
//-----------------------------------
always
@(negedge rst or posedge clk)
begin
  if(~rst)
    pstate  <=  s_otp_standby;
  else if(run_ctrl)
    pstate  <=  nstate;
end

always
@(*)
begin
  nstate  = pstate;
  case(pstate)
    s_otp_standby:if(rom_rctrl | rom_wctrl) nstate  = s_otp_css;
    s_otp_css:    if(rom_rctrl | rom_wctrl) nstate  = s_otp_ad;
                  else                      nstate  = s_otp_csh;
    s_otp_ad:     if(rom_rctrl)             nstate  = s_otp_rd;
                  else if(rom_wctrl)        nstate  = s_otp_wr;
                  else                      nstate  = s_otp_csh;
    s_otp_rd:                               nstate  = s_otp_rdy;
    s_otp_wr:     if(clk_cnt==c_pgm_time)   nstate  = s_otp_rdy;
    s_otp_rdy:                              nstate  = s_otp_css;
    s_otp_csh:                              nstate  = s_otp_standby;
    default:  ;
  endcase
end

always
@(negedge rst or posedge clk)
begin
  if(~rst)
    clk_cnt <=  4'h0;
  else if(run_ctrl)
  begin
    if(pstate!=nstate)
      clk_cnt <=  4'h0;
    else
      clk_cnt <=  clk_cnt+1'b1;
  end
end

assign  otp_addr  = rom_addrs;
assign  otp_dati  = rom_wdata;
assign  rom_ready = (pstate==s_otp_rdy);

always
@(negedge rst or posedge clk)
begin
  if(~rst)
    rom_rdata <=  8'b0;
  else if(run_ctrl)
  begin
    if(pstate==s_otp_rd)
      rom_rdata <=  otp_dato;
  end
end

always
@(negedge rst or posedge clk)
begin
  if(~rst)
  begin
    otp_cs    <= 1'b0;
    otp_read  <= 1'b0;
    otp_prog  <= 1'b0;
  end
  else if(run_ctrl)
  begin
    otp_read  <= 1'b0;
    otp_prog  <= 1'b0;
    case(nstate)
      s_otp_standby:  otp_cs    <=  1'b0;
      s_otp_css:      otp_cs    <=  1'b1;
      s_otp_rd:       otp_read  <=  1'b1;
      s_otp_wr:       otp_prog  <=  1'b1;
      default:  ;
    endcase
  end
end
//-----------------------------------
endmodule
