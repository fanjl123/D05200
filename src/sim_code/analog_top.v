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
  SEL           ,
  HL_SEL        ,
  TSO           ,
  TS_IE         ,
  TS_NOE        ,
  TS_OUT        ,
  TS_PD         ,
  TS_POE        ,
  TS_PU         ,
  VCC           ,
  VPP
);

inout           AGND          ;   wire    AGND          ;
inout           AVDD          ;   wire    AVDD          ;
inout           OUT           ;   wire    OUT           ;
inout           VCC           ;   wire    VCC           ;
inout           VPP           ;   wire    VPP           ;
inout           SW            ;   wire    SW            ;
inout           SEL           ;   wire    SEL           ;
inout           TSO           ;   wire    TSO           ;

input [7:3]     HCFR          ;   wire  [7:3]  HCFR     ;
input [7:4]     LCFR          ;   wire  [7:4]  LCFR     ;

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

output          HL_SEL        ;   wire    HL_SEL        ;
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
//  #42100    losc_clk  <=  1'b1; //跑数模混合仿真用
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
  if(~HENB)  #10000 hready<=  1'b1;
  else      hready  <=  1'b0;
end

assign  HCLK  = (~HENB)? hosc_clk:1'b0;
assign  HRDY  = hready;
//---------------------mic--------------------

assign  SMOKE_CLK = SW;
//---------------------SEL--------------------
assign  HL_SEL    = SEL;
pullup  (HL_SEL);
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

//-------sdt cell-----------------------------
`celldefine
module BUFX1( Y, A);
input A;
output Y;

   `ifdef FUNCTIONAL  //  functional //

	BUFX1_func BUFX1_behav_inst(.A(A),.Y(Y));

   `else

	BUFX1_func BUFX1_inst(.A(A),.Y(Y));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin

	// comb arc A --> Y
	 (A => Y) = (1.0,1.0);

	// specify_block_end

   endspecify

   `endif

endmodule
`endcelldefine

`celldefine
module BUFX1_func( Y, A );
input A;
output Y;

	buf MGM_BG_0( Y, A );

endmodule
`endcelldefine


`celldefine
module OR2X1( Y, A, B);
input A, B;
output Y;

   `ifdef FUNCTIONAL  //  functional //

	OR2X1_func OR2X1_behav_inst(.A(A),.B(B),.Y(Y));

   `else

	OR2X1_func OR2X1_inst(.A(A),.B(B),.Y(Y));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin

	// comb arc A --> Y
	 (A => Y) = (1.0,1.0);

	// comb arc B --> Y
	 (B => Y) = (1.0,1.0);

	// specify_block_end

   endspecify

   `endif

endmodule
`endcelldefine

`celldefine
module OR2X1_func( Y, A, B );
input A, B;
output Y;

	or MGM_BG_0( Y, A, B );

endmodule
`endcelldefine
