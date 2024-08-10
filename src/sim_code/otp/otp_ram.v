`timescale 1ns/1ns
module otp_ram
(
  input   wire         wrong ,
  input   wire         pclk  ,
  input   wire         rclk  ,
  input   wire         cs_en ,
  input   wire  [6:0]  addr  ,
  input   wire  [7:0]  din   ,
  output  reg   [7:0]  dout
);
//-------------------------------------------
reg [7:0] mem [0:127];
reg [7:0] ram_dout;
//--------------------------------------------

always
@(rclk)
begin
   ram_dout <= 8'h00;
   casex({cs_en,wrong,rclk})
     3'b101: ram_dout <= mem[addr];
     3'b100: ram_dout <= 8'h00;
     3'b11x: ram_dout <= 8'hff;
   default:;
   endcase
end

always  @(ram_dout) begin  #10 dout<=ram_dout; end

always  @(posedge pclk)  if(cs_en && ~wrong) mem[addr]=din;
//-------------------------------------------
endmodule
