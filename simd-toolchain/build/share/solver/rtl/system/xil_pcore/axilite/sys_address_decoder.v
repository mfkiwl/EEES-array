`timescale 1ns / 1ps
`include "def-pe.v"

module sys_address_decoder
  (
   iClk,
   iRst,
   iCE,
   iAddr,
   oCtrlEn,
   oCtrlAddr,
   oCPIMemEn,
   oCPIMemAddr,
   oPEIMemEn,
   oPEIMemAddr,
   oCPDMemEn,
   oCPDMemAddr,
   oPEDMemEn,
   oPEDMemRowAddr);

  parameter C_AWIDTH        = 32;
  parameter C_EFF_AWIDTH    = {{eff_addr_width or 20}};

  parameter C_NUM_PE        = `DEF_PE_NUM;
  parameter C_PE_ID_WIDTH   = {{cfg.pe.pe_id_width()}};
  parameter C_PE_ID_HIGH    = C_PE_ID_WIDTH + 2 - 1;
  parameter C_PE_ID_LOW     = 2;

  parameter C_PE_RAWIDTH    = C_EFF_AWIDTH - C_PE_ID_WIDTH;
  parameter C_PE_RADDR_HIGH = C_EFF_AWIDTH - 1;
  

  input                  iClk;
  input                  iRst;
  input                  iCE;
  input [C_AWIDTH-1:0]   iAddr;

  output                 oCtrlEn;
  output [C_AWIDTH-1: 0] oCtrlAddr;
  output                 oCPIMemEn;
  output [C_AWIDTH-1: 0] oCPIMemAddr;
  output                 oPEIMemEn;
  output [C_AWIDTH-1: 0] oPEIMemAddr;
  output                 oCPDMemEn;
  output [C_AWIDTH-1: 0] oCPDMemAddr;
  output [C_NUM_PE-1:0]  oPEDMemEn;
  output [C_AWIDTH-1: 0] oPEDMemRowAddr;

  reg [C_NUM_PE-1:0]     rPEDMemEn;
  reg [C_PE_RAWIDTH-1:0] rPEDMemRowAddr;
  wire                   wPEDMem;
  wire                   wCtrlEn;
  wire                   wIMemEn;

  assign wPEDMem = iAddr[C_EFF_AWIDTH-1] | iAddr[C_EFF_AWIDTH-2];
  assign wCtrlEn = &iAddr[C_EFF_AWIDTH-3:10];
  assign wIMemEn = ~wPEDMem & ~wCtrlEn & ~iAddr[C_EFF_AWIDTH-3];

  // Decode PE id
  always @ (wPEDMem or iCE or iAddr[C_PE_ID_HIGH:C_PE_ID_LOW])
    begin
      rPEDMemEn = 0;
      if (iCE && wPEDMem) begin
        case (iAddr[C_PE_ID_HIGH:C_PE_ID_LOW])
          {%- for i in range(cfg.pe.size) %}
          {{"%d'h%x: rPEDMemEn = %d'h%x;"%
            (cfg.pe.pe_id_width(), i, cfg.pe.size, 2**i)}}
          {%- endfor %}
        endcase
      end
    end
  // PE row address
  always @(wPEDMem or iCE or iAddr[C_EFF_AWIDTH-1:C_PE_ID_HIGH+1] or iAddr[1:0])
    begin
      rPEDMemRowAddr = 0;
      if (iCE && wPEDMem) begin
        rPEDMemRowAddr[C_PE_RAWIDTH-1:C_PE_RAWIDTH-2]
          = iAddr[C_EFF_AWIDTH-1:C_EFF_AWIDTH-2] - 2'h1;
      end
      rPEDMemRowAddr[C_PE_RAWIDTH-3:2]
        = iAddr[C_EFF_AWIDTH-3:C_PE_ID_HIGH+1];
      rPEDMemRowAddr[1:0] = iAddr[1:0];
    end

  wire [C_EFF_AWIDTH-4:0] wIMemAddr;
  assign wIMemAddr = iAddr[C_EFF_AWIDTH-4:0];

  assign oCtrlEn        = iCE & ~wPEDMem & wCtrlEn;
  assign oCtrlAddr      = {22'h0, iAddr[9:0]};
  assign oCPIMemEn      = iCE & wIMemEn & ~iAddr[C_EFF_AWIDTH-4];
  assign oCPIMemAddr    = { {(C_AWIDTH-C_EFF_AWIDTH+4){1'b0} }, iAddr[C_EFF_AWIDTH-5:0]};
  assign oPEIMemEn      = iCE & wIMemEn & iAddr[C_EFF_AWIDTH-4];
  assign oPEIMemAddr    = { {(C_AWIDTH-C_EFF_AWIDTH+4){1'b0} }, iAddr[C_EFF_AWIDTH-5:0]};
  assign oCPDMemEn      = iCE & ~wPEDMem & ~wCtrlEn & ~wIMemEn;
  assign oCPDMemAddr    = { {(C_AWIDTH-C_EFF_AWIDTH+3){1'b0} }, iAddr[C_EFF_AWIDTH-4:0]};
  assign oPEDMemEn      = rPEDMemEn;
  assign oPEDMemRowAddr = { {(C_AWIDTH-C_PE_RAWIDTH){1'b0} }, rPEDMemRowAddr};

endmodule
