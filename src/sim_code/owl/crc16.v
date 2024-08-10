module  crc16(
  input   wire          rst,
  input   wire          clk,

  input   wire          crc_en,
  input   wire          crc_clr,
  input   wire          crc_typ,
  input   wire          crc_calcu,
  input   wire  [7:0]   crc_din,
  output  wire  [15:0]  crc_dout,
  output  wire          crc_rlt
);
//////////////////////////////////////////////////////////////////////////
reg           crc_calcu_r;
reg   [15:0]  crcdata;
wire  [7:0]   ch;
//////////////////////////////////////////////////////////////////////////
always
@(negedge rst or posedge clk)
begin
  if(~rst)
  begin
    crc_calcu_r<=1'b0;
    crcdata <= 16'hffff;
  end
  else
  begin
    crc_calcu_r <=  crc_calcu;
    if(~crc_en | crc_clr) crcdata <=  16'hffff;
    if(crc_en & crc_calcu & ~crc_calcu_r)
    begin
      crcdata <= {ch,crcdata[15:8]}^{5'h0,ch,3'h0}^{12'h0,ch[7:4]};
    end
  end
end

assign ch = (crc_din[7:0]^crcdata[7:0])^{crc_din[3:0]^crcdata[3:0],4'h0};
assign crc_dout = (crc_typ)?crcdata:~crcdata;//tpa:tpb
assign crc_rlt=(crc_dout==16'h0)?1'b1:1'b0;

//////////////////////////////////////////////////////////////////////////
endmodule
