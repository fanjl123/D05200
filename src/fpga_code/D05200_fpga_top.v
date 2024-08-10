`timescale 1ns/1ns

module FPGA_TOP
(
  input   wire          POR,
  input   wire          CLK,
  input   wire          SMOKE_CLK,
  output  wire          PWM,
  output  wire          TXD,
  input   wire          RXD,
  output  wire          TSO
);
//----------------------------------
wire  RESET_EN;

mic_dc_top  u_dc_top(
.RESET     (RESET    ),
.RESET_EN  (RESET_EN ),
.LCLK      (LCLK     ),
.LCFR      (LCFR     ),
.HCLK      (HCLK     ),
.HRDY      (HRDY     ),
.HCEN      (HCEN     ),
.HCFR      (HCFR     ),
.SMOKE_CLK (SMOKE_CLK),
.OTP_CS    (OTP_CS   ),
.OTP_READ  (OTP_READ ),
.OTP_PROG  (OTP_PROG ),
.OTP_ADDR  (OTP_ADDR ),
.OTP_DATI  (OTP_DATI ),
.OTP_DATO  (OTP_DATO ),
.TS_IE     (TS_IE    ),
.TS_DO     (TS_DO    ),
.TS_POE    (TS_POE   ),
.TS_NOE    (TS_NOE   ),
.TS_PU     (TS_PU    ),
.TS_PD     (TS_PD    ),
.OWL_DI    (OWL_DI   ),
.OWL_IE    (OWL_IE   ),
.OWL_DO    (OWL_DO   ),
.OWL_POE   (OWL_POE  ),
.OWL_NOE   (OWL_NOE  ),
.OWL_PU    (OWL_PU   ),
.OWL_PD    (OWL_PD   )
);


div_clk  u_div(
.rst (RST ),
.clk (CLK ),
.hclk(HCLK),
.lclk(LCLK)
);

por u_por(
.rst  (RST  ),
.reset(RESET)
);


//----------------------------------
endmodule
