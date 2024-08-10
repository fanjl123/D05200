/* ----------------------------------------------------------------------------
                                                                               
	Verilog Model file
     
	Module : POTP_HB180ELL_128X8_NISO_TKM3 
                      
	Revision : 2020.09.22 / Ver. 1.0.0 - Initial Release

	COPYRIGHT (C) SK hynix system ic Inc. ALL RIGHTS RESERVED
                 
----------------------------------------------------------------------------*/

`timescale 1 ns/1 ps
`celldefine
module POTP_HB180ELL_128X8_NISO_TKM3 (
       VPP,
       CS,
       READ,
       PROG,
       ADR,
       DIN,
       DO
       );

   parameter WORD_DEPTH = 128;
   parameter ADDR_WIDTH = 7;
   parameter IBITS = 8;
   parameter OBITS = 8;
   parameter WORDX = {OBITS{1'bx}};

   input VPP;
   input CS;
   input READ;
   input PROG;
   input [ADDR_WIDTH-1:0] ADR;
   input [IBITS-1:0] DIN;
   output [OBITS-1:0] DO;

   reg [OBITS-1:0] nvmCell [WORD_DEPTH-1:0];

   reg [OBITS-1:0] Qi;

   reg [ADDR_WIDTH-1:0] ai;

   reg not_Tpgm_min_PROGi;
   reg not_Tpgm_max_PROGi;
   reg not_Tcss_PROGi;
   reg not_Tcsh_PROGi;
   reg not_Tpgs_ADRi0;
   reg not_Tpgs_ADRi1;
   reg not_Tpgs_ADRi2;
   reg not_Tpgs_ADRi3;
   reg not_Tpgs_ADRi4;
   reg not_Tpgs_ADRi5;
   reg not_Tpgs_ADRi6;
   reg not_Tpgh_ADRi0;
   reg not_Tpgh_ADRi1;
   reg not_Tpgh_ADRi2;
   reg not_Tpgh_ADRi3;
   reg not_Tpgh_ADRi4;
   reg not_Tpgh_ADRi5;
   reg not_Tpgh_ADRi6;
   reg not_Tpgs_DINi0;
   reg not_Tpgs_DINi1;
   reg not_Tpgs_DINi2;
   reg not_Tpgs_DINi3;
   reg not_Tpgs_DINi4;
   reg not_Tpgs_DINi5;
   reg not_Tpgs_DINi6;
   reg not_Tpgs_DINi7;
   reg not_Tpgh_DINi0;
   reg not_Tpgh_DINi1;
   reg not_Tpgh_DINi2;
   reg not_Tpgh_DINi3;
   reg not_Tpgh_DINi4;
   reg not_Tpgh_DINi5;
   reg not_Tpgh_DINi6;
   reg not_Tpgh_DINi7;
   reg not_Trd_READi; 
   reg not_Tcss_READi;
   reg not_Tcsh_READi;
   reg not_Trds_ADRi0;
   reg not_Trds_ADRi1;
   reg not_Trds_ADRi2;
   reg not_Trds_ADRi3;
   reg not_Trds_ADRi4;
   reg not_Trds_ADRi5;
   reg not_Trds_ADRi6;
   reg not_Trdh_ADRi0;
   reg not_Trdh_ADRi1;
   reg not_Trdh_ADRi2;
   reg not_Trdh_ADRi3;
   reg not_Trdh_ADRi4;
   reg not_Trdh_ADRi5;
   reg not_Trdh_ADRi6;
   reg not_Tpbs_ADRi0;
   reg not_Tpbs_ADRi1;
   reg not_Tpbs_ADRi2;
   reg not_Tpbs_ADRi3;
   reg not_Tpbs_ADRi4;
   reg not_Tpbs_ADRi5;
   reg not_Tpbs_ADRi6;
   reg not_Tpbh_ADRi0;
   reg not_Tpbh_ADRi1;
   reg not_Tpbh_ADRi2;
   reg not_Tpbh_ADRi3;
   reg not_Tpbh_ADRi4;
   reg not_Tpbh_ADRi5;
   reg not_Tpbh_ADRi6;
   reg not_Tpbs_DINi0;
   reg not_Tpbs_DINi1;
   reg not_Tpbs_DINi2;
   reg not_Tpbs_DINi3;
   reg not_Tpbs_DINi4;
   reg not_Tpbs_DINi5;
   reg not_Tpbs_DINi6;
   reg not_Tpbs_DINi7;
   reg not_Tpbh_DINi0;
   reg not_Tpbh_DINi1;
   reg not_Tpbh_DINi2;
   reg not_Tpbh_DINi3;
   reg not_Tpbh_DINi4;
   reg not_Tpbh_DINi5;
   reg not_Tpbh_DINi6;
   reg not_Tpbh_DINi7;

   wire _CSi;
   wire _READi;
   wire _PROGi;
   wire [ADDR_WIDTH-1:0] _ADRi;
   wire [IBITS-1:0] _DINi;
   wire [OBITS-1:0] _DOi;
   wire re_prog_flag;
   wire re_read_flag;

   buf (_CSi, CS);
   buf (_READi, READ);
   buf (_PROGi, PROG);
   buf (_ADRi[0], ADR[0]);
   buf (_ADRi[1], ADR[1]);
   buf (_ADRi[2], ADR[2]);
   buf (_ADRi[3], ADR[3]);
   buf (_ADRi[4], ADR[4]);
   buf (_ADRi[5], ADR[5]);
   buf (_ADRi[6], ADR[6]);

   buf (_DINi[0], DIN[0]);
   buf (_DINi[1], DIN[1]);
   buf (_DINi[2], DIN[2]);
   buf (_DINi[3], DIN[3]);
   buf (_DINi[4], DIN[4]);
   buf (_DINi[5], DIN[5]);
   buf (_DINi[6], DIN[6]);
   buf (_DINi[7], DIN[7]);

   buf (DO[0], _DOi[0]);
   buf (DO[1], _DOi[1]);
   buf (DO[2], _DOi[2]);
   buf (DO[3], _DOi[3]);
   buf (DO[4], _DOi[4]);
   buf (DO[5], _DOi[5]);
   buf (DO[6], _DOi[6]);
   buf (DO[7], _DOi[7]);




   wire stanbyMode  = !_CSi && !_READi && !_PROGi; 
   always @(VPP) begin
      if ( stanbyMode !== 1'b1) begin
	 Error("VPP pin should follow standby mode condition.");
      end
   end

   integer i;
   initial begin
      for (i = 0; i <= WORD_DEPTH-1; i = i + 1) begin
 	 nvmCell[i] = {OBITS{1'b1}};
      end
   end

   always @ (_CSi or _PROGi or _READi) begin
      nvm_cycle;
   end

   always @ (_ADRi[ADDR_WIDTH-1:0]) begin
      if ({_CSi, _PROGi, _READi} == 3'b110) begin
         Error("!!! error (write) !!! : address can not be changed in writing mode.  ");
         x_nvm;
      end
   end

   always @ (_DINi[IBITS-1:0]) begin
      if ({_CSi, _PROGi, _READi} == 3'b110) begin
         Error("!!! error (write) !!! : data can not be changed in writing mode.  ");
         x_nvm;
      end
   end

   always @ (_ADRi[ADDR_WIDTH-1:0]) begin
      if ({_CSi, _PROGi, _READi} == 3'b101) begin
         Error("!!! error (read) !!! : address can not be changed in reading mode.  ");
         read_nvm_x;
      end
   end


   task nvm_cycle;
   begin
      casez({_CSi, _PROGi, _READi})
         3'b0??: ;                             // cs off-> no action
         3'b110: begin
                   update_logic;
                   write_nvm(VPP,ai,_DINi);   // normal write
                 end
         3'b101: begin
                   update_logic;
                   read_nvm(_READi,ai);       // normal read
                 end
         3'b1x0,                               // cs on, prog unknown, read off
         3'bx10,                               // cs unknown, prog on, read off
         3'bxx0: begin
                   update_logic;
                   write_nvm_x(VPP,ai);       // cs unknown, prog unknown, read off
                 end
         3'b10x,                               // cs on, prog off, read unknown
         3'bx01,                               // cs unknown, prog off, read on
         3'bx0x: begin
                   update_logic;
                   read_nvm_x;                   // cs unknown, prog off, read unknown
                 end
         3'bxxx,                               // cs unknown, prog unknown, read unknown
         3'b1xx: begin                         // cs on, prog unknown, read unknown
                   update_logic;
                   write_nvm_x(VPP,ai);
                   read_nvm_x;
                 end 
      endcase
   end
   endtask

   task update_logic;
   begin
      ai = _ADRi;
   end
   endtask

   task Error;
   input [608:1] msg;
      begin
         if ($realtime != 0) $display("Error!    Invalid function\n           -> %0s\n           %m, Time:%.3f",msg,$realtime);
      end
   endtask

   task warning;
   input [608:1] msg;
      begin
         if ($realtime != 0) $display("%.1f : %m : %0s",$realtime,msg);
      end
   endtask

   task x_nvm;
   integer n;
      begin
         for (n=0; n<WORD_DEPTH; n=n+1) nvmCell[n]=WORDX;
      end
   endtask

   task write_nvm;
   input v;
   input [ADDR_WIDTH-1:0] a;
   input [IBITS-1:0] d;
      begin
         casez({valid_address(a)})
            1'b0:
               begin
                  warning("!!! error (write) !!! : address(a) -> /out of range /unknown /violation");
                  $display("%d!!! a = 'h%x !!!", $time, a);
                  if (v) x_nvm;
               end
            1'b1:
               begin
                  if (v) nvmCell[a] <= d & nvmCell[a];
               end
         endcase
      end
   endtask

   task write_nvm_x;
   input v;
   input [ADDR_WIDTH-1:0] a;
      begin
         casez({valid_address(a)})
            1'b0:
               begin
                  warning("!!! error (write) !!! : address(a) -> /out of range /unknown /violation");
                  $display("%d!!! a = 'h%x !!!", $time, a);
                  if (v) x_nvm;
               end
            1'b1: if (v) nvmCell[a]<=WORDX;
         endcase
      end
   endtask

   task read_nvm;
   input read;
   input [ADDR_WIDTH-1:0] a;
      begin
         if (read) begin
            if (valid_address(a)) begin
               Qi = nvmCell[a];
            end else begin
               Qi<=WORDX;
            end
         end else begin
            Qi<='b0;
         end
      end
   endtask

   task read_nvm_x;
   begin
      Qi<=WORDX;
   end
   endtask

   function valid_address;
   input [ADDR_WIDTH-1:0] a;
      begin
         if (^(a) !== 1'bx) begin
            if (a < WORD_DEPTH) begin
               valid_address = 1;
            end else begin
               valid_address = 0;
            end
         end else begin
            valid_address = 0;
         end
      end
   endfunction


   task process_violations_whenWrite;
   begin
      x_nvm;
   end
   endtask

   task process_violations_whenRead;
   begin
      read_nvm_x;
   end
   endtask

  assign _DOi = ({_CSi, _PROGi, _READi} == 3'b101) ? Qi : 8'h0;
  assign re_prog_flag = VPP && _CSi && !_READi && (_PROGi !== 1'bx) ;
  assign re_read_flag = _CSi && (_READi !== 1'bx) && !_PROGi;

  always @(
         not_Tpgs_ADRi0 or
         not_Tpgs_ADRi1 or
         not_Tpgs_ADRi2 or
         not_Tpgs_ADRi3 or
         not_Tpgs_ADRi4 or
         not_Tpgs_ADRi5 or
         not_Tpgs_ADRi6 or
         not_Tpgh_ADRi0 or
         not_Tpgh_ADRi1 or
         not_Tpgh_ADRi2 or
         not_Tpgh_ADRi3 or
         not_Tpgh_ADRi4 or
         not_Tpgh_ADRi5 or
         not_Tpgh_ADRi6
         )
  begin
     process_violations_whenWrite;
  end

  always @(
         not_Tpgm_min_PROGi or
         not_Tpgm_max_PROGi or
         not_Tcss_PROGi or
         not_Tcsh_PROGi or
         not_Tpgs_DINi0 or
         not_Tpgs_DINi1 or
         not_Tpgs_DINi2 or
         not_Tpgs_DINi3 or
         not_Tpgs_DINi4 or
         not_Tpgs_DINi5 or
         not_Tpgs_DINi6 or
         not_Tpgs_DINi7 or
         not_Tpgh_DINi0 or
         not_Tpgh_DINi1 or
         not_Tpgh_DINi2 or
         not_Tpgh_DINi3 or
         not_Tpgh_DINi4 or
         not_Tpgh_DINi5 or
         not_Tpgh_DINi6 or
         not_Tpgh_DINi7
         )
  begin
     write_nvm_x(VPP,ai);
  end

  always @(
         not_Trd_READi or
         not_Tcss_READi or
         not_Tcsh_READi or
         not_Trds_ADRi0 or
         not_Trds_ADRi1 or
         not_Trds_ADRi2 or
         not_Trds_ADRi3 or
         not_Trds_ADRi4 or
         not_Trds_ADRi5 or
         not_Trds_ADRi6 or
         not_Trdh_ADRi0 or
         not_Trdh_ADRi1 or
         not_Trdh_ADRi2 or
         not_Trdh_ADRi3 or
         not_Trdh_ADRi4 or
         not_Trdh_ADRi5 or
         not_Trdh_ADRi6
         )
  begin
     process_violations_whenRead;
  end

  specify
     // Parameter from parameter.v
     specparam 
        Tvpps      = 1000000,
        Tvpph      = 1000000,
        Tvppr      = 1000000,
        Trd        = 2000,
        Tat        = 1000,
        Trds       = 1000,
        Trdh       = 1000,
        Tpgs       = 1000,
        Tpgh       = 1000,
        Tcss       = 6000,
        Tcsh       = 1000,
        Tpgm_max   = 400000,
        Tpgm_min   = 200000;

     // Min. & Max. Pulse Width check 
     $width(posedge PROG &&& re_prog_flag, Tpgm_min, 0, not_Tpgm_min_PROGi);
     $width(posedge READ &&& re_read_flag, Trd, 0, not_Trd_READi);
     $skew(posedge PROG &&& re_prog_flag, negedge PROG &&& re_prog_flag, Tpgm_max, not_Tpgm_max_PROGi);

     // Setup violation check
     $setup(posedge CS, posedge PROG &&& re_prog_flag, Tcss, not_Tcss_PROGi);
     $setup(posedge CS, posedge READ &&& re_read_flag, Tcss, not_Tcss_READi);
     $setup(posedge ADR[0], posedge PROG &&& re_prog_flag, Tpgs, not_Tpgs_ADRi0);
     $setup(negedge ADR[0], posedge PROG &&& re_prog_flag, Tpgs, not_Tpgs_ADRi0);
     $setup(posedge ADR[1], posedge PROG &&& re_prog_flag, Tpgs, not_Tpgs_ADRi1);
     $setup(negedge ADR[1], posedge PROG &&& re_prog_flag, Tpgs, not_Tpgs_ADRi1);
     $setup(posedge ADR[2], posedge PROG &&& re_prog_flag, Tpgs, not_Tpgs_ADRi2);
     $setup(negedge ADR[2], posedge PROG &&& re_prog_flag, Tpgs, not_Tpgs_ADRi2);
     $setup(posedge ADR[3], posedge PROG &&& re_prog_flag, Tpgs, not_Tpgs_ADRi3);
     $setup(negedge ADR[3], posedge PROG &&& re_prog_flag, Tpgs, not_Tpgs_ADRi3);
     $setup(posedge ADR[4], posedge PROG &&& re_prog_flag, Tpgs, not_Tpgs_ADRi4);
     $setup(negedge ADR[4], posedge PROG &&& re_prog_flag, Tpgs, not_Tpgs_ADRi4);
     $setup(posedge ADR[5], posedge PROG &&& re_prog_flag, Tpgs, not_Tpgs_ADRi5);
     $setup(negedge ADR[5], posedge PROG &&& re_prog_flag, Tpgs, not_Tpgs_ADRi5);
     $setup(posedge ADR[6], posedge PROG &&& re_prog_flag, Tpgs, not_Tpgs_ADRi6);
     $setup(negedge ADR[6], posedge PROG &&& re_prog_flag, Tpgs, not_Tpgs_ADRi6);
     $setup(posedge DIN[0], posedge PROG &&& re_prog_flag, Tpgs, not_Tpgs_DINi0);
     $setup(negedge DIN[0], posedge PROG &&& re_prog_flag, Tpgs, not_Tpgs_DINi0);
     $setup(posedge DIN[1], posedge PROG &&& re_prog_flag, Tpgs, not_Tpgs_DINi1);
     $setup(negedge DIN[1], posedge PROG &&& re_prog_flag, Tpgs, not_Tpgs_DINi1);
     $setup(posedge DIN[2], posedge PROG &&& re_prog_flag, Tpgs, not_Tpgs_DINi2);
     $setup(negedge DIN[2], posedge PROG &&& re_prog_flag, Tpgs, not_Tpgs_DINi2);
     $setup(posedge DIN[3], posedge PROG &&& re_prog_flag, Tpgs, not_Tpgs_DINi3);
     $setup(negedge DIN[3], posedge PROG &&& re_prog_flag, Tpgs, not_Tpgs_DINi3);
     $setup(posedge DIN[4], posedge PROG &&& re_prog_flag, Tpgs, not_Tpgs_DINi4);
     $setup(negedge DIN[4], posedge PROG &&& re_prog_flag, Tpgs, not_Tpgs_DINi4);
     $setup(posedge DIN[5], posedge PROG &&& re_prog_flag, Tpgs, not_Tpgs_DINi5);
     $setup(negedge DIN[5], posedge PROG &&& re_prog_flag, Tpgs, not_Tpgs_DINi5);
     $setup(posedge DIN[6], posedge PROG &&& re_prog_flag, Tpgs, not_Tpgs_DINi6);
     $setup(negedge DIN[6], posedge PROG &&& re_prog_flag, Tpgs, not_Tpgs_DINi6);
     $setup(posedge DIN[7], posedge PROG &&& re_prog_flag, Tpgs, not_Tpgs_DINi7);
     $setup(negedge DIN[7], posedge PROG &&& re_prog_flag, Tpgs, not_Tpgs_DINi7);
     $setup(posedge ADR[0], posedge READ &&& re_read_flag, Trds, not_Trds_ADRi0);
     $setup(negedge ADR[0], posedge READ &&& re_read_flag, Trds, not_Trds_ADRi0);
     $setup(posedge ADR[1], posedge READ &&& re_read_flag, Trds, not_Trds_ADRi1);
     $setup(negedge ADR[1], posedge READ &&& re_read_flag, Trds, not_Trds_ADRi1);
     $setup(posedge ADR[2], posedge READ &&& re_read_flag, Trds, not_Trds_ADRi2);
     $setup(negedge ADR[2], posedge READ &&& re_read_flag, Trds, not_Trds_ADRi2);
     $setup(posedge ADR[3], posedge READ &&& re_read_flag, Trds, not_Trds_ADRi3);
     $setup(negedge ADR[3], posedge READ &&& re_read_flag, Trds, not_Trds_ADRi3);
     $setup(posedge ADR[4], posedge READ &&& re_read_flag, Trds, not_Trds_ADRi4);
     $setup(negedge ADR[4], posedge READ &&& re_read_flag, Trds, not_Trds_ADRi4);
     $setup(posedge ADR[5], posedge READ &&& re_read_flag, Trds, not_Trds_ADRi5);
     $setup(negedge ADR[5], posedge READ &&& re_read_flag, Trds, not_Trds_ADRi5);
     $setup(posedge ADR[6], posedge READ &&& re_read_flag, Trds, not_Trds_ADRi6);
     $setup(negedge ADR[6], posedge READ &&& re_read_flag, Trds, not_Trds_ADRi6);

     // Hold violation check
     $hold(negedge PROG &&& re_prog_flag, negedge CS, Tcsh, not_Tcsh_PROGi);
     $hold(negedge READ &&& re_read_flag, negedge CS, Tcsh, not_Tcsh_READi);
     $hold(negedge PROG &&& re_prog_flag, posedge ADR[0], Tpgh, not_Tpgh_ADRi0);
     $hold(negedge PROG &&& re_prog_flag, negedge ADR[0], Tpgh, not_Tpgh_ADRi0);
     $hold(negedge PROG &&& re_prog_flag, posedge ADR[1], Tpgh, not_Tpgh_ADRi1);
     $hold(negedge PROG &&& re_prog_flag, negedge ADR[1], Tpgh, not_Tpgh_ADRi1);
     $hold(negedge PROG &&& re_prog_flag, posedge ADR[2], Tpgh, not_Tpgh_ADRi2);
     $hold(negedge PROG &&& re_prog_flag, negedge ADR[2], Tpgh, not_Tpgh_ADRi2);
     $hold(negedge PROG &&& re_prog_flag, posedge ADR[3], Tpgh, not_Tpgh_ADRi3);
     $hold(negedge PROG &&& re_prog_flag, negedge ADR[3], Tpgh, not_Tpgh_ADRi3);
     $hold(negedge PROG &&& re_prog_flag, posedge ADR[4], Tpgh, not_Tpgh_ADRi4);
     $hold(negedge PROG &&& re_prog_flag, negedge ADR[4], Tpgh, not_Tpgh_ADRi4);
     $hold(negedge PROG &&& re_prog_flag, posedge ADR[5], Tpgh, not_Tpgh_ADRi5);
     $hold(negedge PROG &&& re_prog_flag, negedge ADR[5], Tpgh, not_Tpgh_ADRi5);
     $hold(negedge PROG &&& re_prog_flag, posedge ADR[6], Tpgh, not_Tpgh_ADRi6);
     $hold(negedge PROG &&& re_prog_flag, negedge ADR[6], Tpgh, not_Tpgh_ADRi6);
     $hold(negedge PROG &&& re_prog_flag, posedge DIN[0], Tpgh, not_Tpgh_DINi0);
     $hold(negedge PROG &&& re_prog_flag, negedge DIN[0], Tpgh, not_Tpgh_DINi0);
     $hold(negedge PROG &&& re_prog_flag, posedge DIN[1], Tpgh, not_Tpgh_DINi1);
     $hold(negedge PROG &&& re_prog_flag, negedge DIN[1], Tpgh, not_Tpgh_DINi1);
     $hold(negedge PROG &&& re_prog_flag, posedge DIN[2], Tpgh, not_Tpgh_DINi2);
     $hold(negedge PROG &&& re_prog_flag, negedge DIN[2], Tpgh, not_Tpgh_DINi2);
     $hold(negedge PROG &&& re_prog_flag, posedge DIN[3], Tpgh, not_Tpgh_DINi3);
     $hold(negedge PROG &&& re_prog_flag, negedge DIN[3], Tpgh, not_Tpgh_DINi3);
     $hold(negedge PROG &&& re_prog_flag, posedge DIN[4], Tpgh, not_Tpgh_DINi4);
     $hold(negedge PROG &&& re_prog_flag, negedge DIN[4], Tpgh, not_Tpgh_DINi4);
     $hold(negedge PROG &&& re_prog_flag, posedge DIN[5], Tpgh, not_Tpgh_DINi5);
     $hold(negedge PROG &&& re_prog_flag, negedge DIN[5], Tpgh, not_Tpgh_DINi5);
     $hold(negedge PROG &&& re_prog_flag, posedge DIN[6], Tpgh, not_Tpgh_DINi6);
     $hold(negedge PROG &&& re_prog_flag, negedge DIN[6], Tpgh, not_Tpgh_DINi6);
     $hold(negedge PROG &&& re_prog_flag, posedge DIN[7], Tpgh, not_Tpgh_DINi7);
     $hold(negedge PROG &&& re_prog_flag, negedge DIN[7], Tpgh, not_Tpgh_DINi7);
     $hold(negedge READ &&& re_read_flag, posedge ADR[0], Trdh, not_Trdh_ADRi0);
     $hold(negedge READ &&& re_read_flag, negedge ADR[0], Trdh, not_Trdh_ADRi0);
     $hold(negedge READ &&& re_read_flag, posedge ADR[1], Trdh, not_Trdh_ADRi1);
     $hold(negedge READ &&& re_read_flag, negedge ADR[1], Trdh, not_Trdh_ADRi1);
     $hold(negedge READ &&& re_read_flag, posedge ADR[2], Trdh, not_Trdh_ADRi2);
     $hold(negedge READ &&& re_read_flag, negedge ADR[2], Trdh, not_Trdh_ADRi2);
     $hold(negedge READ &&& re_read_flag, posedge ADR[3], Trdh, not_Trdh_ADRi3);
     $hold(negedge READ &&& re_read_flag, negedge ADR[3], Trdh, not_Trdh_ADRi3);
     $hold(negedge READ &&& re_read_flag, posedge ADR[4], Trdh, not_Trdh_ADRi4);
     $hold(negedge READ &&& re_read_flag, negedge ADR[4], Trdh, not_Trdh_ADRi4);
     $hold(negedge READ &&& re_read_flag, posedge ADR[5], Trdh, not_Trdh_ADRi5);
     $hold(negedge READ &&& re_read_flag, negedge ADR[5], Trdh, not_Trdh_ADRi5);
     $hold(negedge READ &&& re_read_flag, posedge ADR[6], Trdh, not_Trdh_ADRi6);
     $hold(negedge READ &&& re_read_flag, negedge ADR[6], Trdh, not_Trdh_ADRi6);

     // Read Access Time 
     ( posedge READ => ( DO[0] +: _DOi[0] ) )=(Tat, Tat);
     ( posedge READ => ( DO[1] +: _DOi[1] ) )=(Tat, Tat);
     ( posedge READ => ( DO[2] +: _DOi[2] ) )=(Tat, Tat);
     ( posedge READ => ( DO[3] +: _DOi[3] ) )=(Tat, Tat);
     ( posedge READ => ( DO[4] +: _DOi[4] ) )=(Tat, Tat);
     ( posedge READ => ( DO[5] +: _DOi[5] ) )=(Tat, Tat);
     ( posedge READ => ( DO[6] +: _DOi[6] ) )=(Tat, Tat);
     ( posedge READ => ( DO[7] +: _DOi[7] ) )=(Tat, Tat);

  endspecify

endmodule     

`endcelldefine

