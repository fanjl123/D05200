`timescale 1ns/1ns

module d05200_asic_top(
  AVDD,
  AGND,
  VPP,
  OUT,
  SW,
  SEL,
  TSO
);
inout   AVDD;         wire    AVDD;
inout   AGND;         wire    AGND;
inout   VPP ;         wire    VPP ;
inout   OUT ;         wire    OUT ;
inout   SW  ;         wire    SW  ;
inout   SEL ;         wire    SEL ;
inout   TSO ;         wire    TSO ;
//------------------------------------
wire          RESET     ;
wire          RESET_EN  ;

wire          LCLK      ;
wire  [7:0]   LCFR      ;

wire          HCLK      ;
wire          HRDY      ;
wire          HENB      ;
wire  [7:0]   HCFR      ;

wire          SMOKE_CLK ;

wire          HL_SEL    ;

wire          TS_IE     ;
wire          TS_DO     ;
wire          TS_POE    ;
wire          TS_NOE    ;
wire          TS_PU     ;
wire          TS_PD     ;

wire          OWL_DI    ;
wire          OWL_IE    ;
wire          OWL_DO    ;
wire          OWL_POE   ;
wire          OWL_NOE   ;
wire          OWL_PU    ;
wire          OWL_PD    ;

wire          VCC       ;
//------------------------------------
wire          OTP_CS    ;
wire          OTP_READ  ;
wire          OTP_PROG  ;
wire  [6:0]   OTP_ADDR  ;
wire  [7:0]   OTP_DATI  ;
wire  [7:0]   OTP_DATO  ;

d05200_dc_top u_dc_top(
  .RESET      (RESET      ),
  .RESET_EN   (RESET_EN   ),

  .LCLK       (LCLK       ),
  .LCFR       (LCFR       ),

  .HCLK       (HCLK       ),
  .HRDY       (HRDY       ),
  .HENB       (HENB       ),
  .HCFR       (HCFR       ),

  .SMOKE_CLK  (SMOKE_CLK  ),

  .OTP_CS     (OTP_CS     ),
  .OTP_READ   (OTP_READ   ),
  .OTP_PROG   (OTP_PROG   ),
  .OTP_ADDR   (OTP_ADDR   ),
  .OTP_DATI   (OTP_DATI   ),
  .OTP_DATO   (OTP_DATO   ),

  .HL_SEL     (HL_SEL     ),

  .TS_IE      (TS_IE      ),
  .TS_DO      (TS_DO      ),
  .TS_POE     (TS_POE     ),
  .TS_NOE     (TS_NOE     ),
  .TS_PU      (TS_PU      ),
  .TS_PD      (TS_PD      ),

  .OWL_DI     (OWL_DI     ),
  .OWL_IE     (OWL_IE     ),
  .OWL_DO     (OWL_DO     ),
  .OWL_POE    (OWL_POE    ),
  .OWL_NOE    (OWL_NOE    ),
  .OWL_PU     (OWL_PU     ),
  .OWL_PD     (OWL_PD     )
);
//------------------------------------
POTP_HB180ELL_128X8_NISO_TKM3  u_otp(
  .VPP        (VPP        ),
  .CS         (OTP_CS     ),
  .READ       (OTP_READ   ),
  .PROG       (OTP_PROG   ),
  .ADR        (OTP_ADDR   ),
  .DIN        (OTP_DATI   ),
  .DO         (OTP_DATO   )
);

//otp_ip  u_otp(
//  .CLK        (clk50m     ),
//  .RST        (~RESET     ),
//  .VPP        (VPP        ),
//  .CS         (OTP_CS     ),
//  .READ       (OTP_READ   ),
//  .PROG       (OTP_PROG   ),
//  .ADR        (OTP_ADDR   ),
//  .DIN        (OTP_DATI   ),
//  .DO         (OTP_DATO   )
//);

//------------------------------------
ANALOG_TOP  u_analog_top(
  .AGND       (AGND       ),
  .AVDD       (AVDD       ),
  .HCFR       (HCFR       ),
  .HCLK       (HCLK       ),
  .HENB       (HENB       ),
  .HRDY       (HRDY       ),
  .LCFR       (LCFR       ),
  .LCLK       (LCLK       ),
  .OUT        (OUT        ),
  .OWLI       (OWL_DI     ),
  .OWLO       (OWL_DO     ),
  .OWL_IE     (OWL_IE     ),
  .OWL_NOE    (OWL_NOE    ),
  .OWL_PD     (OWL_PD     ),
  .OWL_POE    (OWL_POE    ),
  .OWL_PU     (OWL_PU     ),
  .RESET      (RESET      ),
  .RESET_EN   (RESET_EN   ),
  .SMOKE_CLK  (SMOKE_CLK  ),
  .SW         (SW         ),
  .SEL        (SEL        ),
  .HL_SEL     (HL_SEL     ),
  .TSO        (TSO        ),
  .TS_IE      (TS_IE      ),
  .TS_NOE     (TS_NOE     ),
  .TS_OUT     (TS_DO      ),
  .TS_PD      (TS_PD      ),
  .TS_POE     (TS_POE     ),
  .TS_PU      (TS_PU      ),
  .VCC        (VCC        ),
  .VPP        (VPP        )
);

//------------------------------------
endmodule