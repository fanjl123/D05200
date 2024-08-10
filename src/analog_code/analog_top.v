`timescale 1ns/100ps

module  ANALOG_TOP (
  AGND          ,
  AVDD          ,
  HCFR          ,
  HCLK          ,
  HENB          ,
  HRDY          ,
  LCFR          ,
  LCLK          ,
  OUT           ,
  OWLI          ,
  OWLO          ,
  OWL_IE        ,
  OWL_NOE       ,
  OWL_PD        ,
  OWL_POE       ,
  OWL_PU        ,
  RESET         ,
  RESET_EN      ,
  SMOKE_CLK     ,
  SW            ,
  TSO           ,
  TS_IE         ,
  TS_NOE        ,
  TS_OUT        ,
  TS_PD         ,
  TS_POE        ,
  TS_PU         ,
  VPP   
);

inout           AGND          ;   wire    AGND          ;
inout           AVDD          ;   wire    AVDD          ;
inout           OUT           ;   wire    OUT           ;
inout           VPP           ;   wire    VPP           ;
inout           SW            ;   wire    SW            ;
inout           TSO           ;   wire    TSO           ;

input [7:0]     HCFR          ;   wire  [7:0]  HCFR          ;
input [3:0]     LCFR          ;   wire  [3:0]  LCFR          ;

input           HENB          ;   wire    HENB          ;

input           OWLO          ;   wire    OWLO          ;
input           OWL_IE        ;   wire    OWL_IE        ;
input           OWL_NOE       ;   wire    OWL_NOE       ;
input           OWL_PD        ;   wire    OWL_PD        ;
input           OWL_POE       ;   wire    OWL_POE       ;
input           OWL_PU        ;   wire    OWL_PU        ;
input           RESET_EN      ;   wire    RESET_EN      ;
input           TS_IE         ;   wire    TS_IE         ;
input           TS_NOE        ;   wire    TS_NOE        ;
input           TS_OUT        ;   wire    TS_OUT        ;
input           TS_PD         ;   wire    TS_PD         ;
input           TS_POE        ;   wire    TS_POE        ;
input           TS_PU         ;   wire    TS_PU         ;
  
output          HCLK          ;   wire    HCLK          ;
output          HRDY          ;   wire    HRDY          ;
output          LCLK          ;   wire    LCLK          ;
output          OWLI          ;   wire    OWLI          ;  
output          RESET         ;   wire    RESET         ; 
output          SMOKE_CLK     ;   wire    SMOKE_CLK     ;
  
//-------------------por--------------------
reg   rst;

initial
begin
                   rst <=  1'b1;
  #100001          rst <=  1'b0;
  #100001          rst <=  1'b1;
end

assign  RESET = ~rst;
//---------------------losc------------------
reg   losc_clk;

initial losc_clk<=1'b1;
always
begin
  #100      losc_clk  <=  1'b0;
  #31150    losc_clk  <=  1'b1;
end

assign  LCLK = losc_clk;

//-------------------hosc--------------------
reg   hosc_clk;
reg   hready;

initial     hosc_clk  <=  1'b1;

always  #16 hosc_clk  <=  ~hosc_clk;

initial hready  <=  1'b0;
always
@(*)
begin
  if(HENB)  #10000 hready<=  1'b1;
  else      hready  <=  1'b0;
end

assign  HCLK  = (HENB)? hosc_clk:1'b0;
assign  HRDY  = hready;
//---------------------mic--------------------

assign  SMOKE_CLK = SW;
//---------------------OUT--------------------
wire    pad_up;
wire    pad_down;

assign  OWLI  = (OWL_IE)?OUT:1'b0;
assign  OUT = (OWL_POE & OWLO)?1'b1:1'bz;
assign  OUT = (OWL_NOE & ~OWLO)?1'b0:1'bz;
assign  OUT = (OWL_PU)?pad_up:1'bz;
assign  OUT = (OWL_PD)?pad_down:1'bz;



//---------------------TSO--------------------

assign  TSO = (TS_POE & TS_OUT)?1'b1:1'bz;
assign  TSO = (TS_NOE & ~TS_OUT)?1'b0:1'bz;
assign  TSO = (TS_PU)?pad_up:1'bz;
assign  TSO = (TS_PD)?pad_down:1'bz;

pullup  (pad_up);
pulldown(pad_down);
  
endmodule