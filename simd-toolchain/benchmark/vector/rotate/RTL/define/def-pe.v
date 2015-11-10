////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//    Description :  Template for the PE gloable define                       //
//                                                                            //
//    Author(s)   :  Yifan He                                                 //
//                   Dongrui She                                              //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
`ifndef _DEF_PE_
`define _DEF_PE_

`define DEF_PE_NUM                128

// bit width of instruction-memory address, 2^(N-2) entries, N>16!!!
`define DEF_PE_I_MEM_ADDR_WIDTH   19
// bit width of data-memory address: N>16
`define DEF_PE_D_MEM_ADDR_WIDTH   18
// address width of data-memory
`define DEF_PE_RAM_ADDR_BITS      11
// data width
`define DEF_PE_DATA_WIDTH         32
// instruction width
`define DEF_PE_INS_WIDTH          24

`define DEF_PE_IMEM_SIZE          2048

`define DEF_PE_DMEM_SIZE          2048

// bit width of offset immediate in branch/jump instructions
`define DEF_BRANCH_OFFSET_WIDTH   16

// bit width of immediate in the instruction
`define DEF_INS_IMM_WIDTH          8

// bit width of long immediate in the SIMM/ZIMM instruction
`define DEF_INS_LONGIMM_WIDTH     18

`define DEF_INS_IMM_START_BIT      0
`define DEF_INS_IMM_END_BIT        7
`define DEF_INS_SRC2_START_BIT     3
`define DEF_INS_SRC2_END_BIT       7
`define DEF_INS_SRC1_START_BIT     8
`define DEF_INS_SRC1_END_BIT      12
`define DEF_INS_DES_START_BIT     13
`define DEF_INS_DES_END_BIT       17
`define DEF_INS_OPCODE_START_BIT  18
`define DEF_INS_OPCODE_END_BIT    22
`define DEF_INS_LONGIMM_START_BIT  0
`define DEF_INS_LONGIMM_END_BIT   17

// the bit which inidiates I-type or R-type,  '1': I-type, '0': R-type
`define DEF_INS_TYPE_BIT         23
`define DEF_INS_IS_I_TYPE      1'b1
`define DEF_INS_IS_R_TYPE      1'b0

`define DEF_RF_INDEX_WIDTH     5
`define DEF_RF_DEPTH           32

// ==================================
//   Register File initial value
// ==================================
`define  DEF_LINK_REGISTER_INDEX  5'd9


// special register memory mapping
`define DEF_BOUNDARY_MODE_ZERO        2'b00
`define DEF_BOUNDARY_MODE_SCALAR      2'b01
`define DEF_BOUNDARY_MODE_WRAP        2'b10
`define DEF_BOUNDARY_MODE_SELF        2'b11


// ========================
//  Branch Operation Types
// ========================
`define RISC24_BRANCHOP_WIDTH   3
`define RISC24_BRANCHOP_NOP     3'd0
`define RISC24_BRANCHOP_SYS     3'd1
`define RISC24_BRANCHOP_BF      3'd2
`define RISC24_BRANCHOP_BNF     3'd3
`define RISC24_BRANCHOP_J       3'd4
`define RISC24_BRANCHOP_JAL     3'd5
`define RISC24_BRANCHOP_JR      3'd6
`define RISC24_BRANCHOP_JALR    3'd7

// ==================================
// Instruction opcode groups (basic)
// ==================================
// SIMM
`define RISC24_OP_NOP1            5'd0
// ZIMM
`define RISC24_OP_NOP2            5'd1

`define RISC24_OP_ADD             5'd2
`define RISC24_OP_SUB             5'd3

`define RISC24_OP_MUL             5'd4
`define RISC24_OP_MULU            5'd5

`define RISC24_OP_OR              5'd6
`define RISC24_OP_AND             5'd7
`define RISC24_OP_XOR             5'd8

`define RISC24_OP_CMOV            5'd9

`define RISC24_OP_EQ              5'd10
`define RISC24_OP_NE              5'd11
`define RISC24_OP_LE              5'd12
`define RISC24_OP_LT              5'd13
`define RISC24_OP_GE              5'd14
`define RISC24_OP_GT              5'd15
`define RISC24_OP_LEU             5'd16
`define RISC24_OP_LTU             5'd17
`define RISC24_OP_GEU             5'd18
`define RISC24_OP_GTU             5'd19

`define RISC24_OP_SLL             5'd20
`define RISC24_OP_SRA             5'd21
`define RISC24_OP_SRL             5'd22
`define RISC24_OP_ROR             5'd23

`define RISC24_OP_CUM1            5'd24
`define RISC24_OP_CUM2            5'd25
/* */
`define RISC24_OP_LBZ             5'd26
`define RISC24_OP_SB              5'd27

`define RISC24_OP_LHZ             5'd28
`define RISC24_OP_SH              5'd29

`define RISC24_OP_LWZ             5'd30
`define RISC24_OP_SW              5'd31

// ===================================
//   Register File Write-Back OPs
//
//  Bit 0: register file write enable
//  Bit 1: ALU or LR (Link Register)
//  Bit 2: EX or LSU
// ===================================
`define RISC24_RFWBOP_WIDTH     3
//[2:1]: result selection, [0]: write-back or not
`define RISC24_RFWBOP_NOP         3'b000
`define RISC24_RFWBOP_ALU         2'b00
`define RISC24_RFWBOP_LR          2'b01
`define RISC24_RFWBOP_LSU         2'b10
`define RISC24_RFWBOP_MUL         2'b11
// ======================
//  Bypass Source Coding
// ======================
`define RISC24_BYPASS_SRC_LSU     2'b00
`define RISC24_BYPASS_SRC_MUL     2'b01
`define RISC24_BYPASS_SRC_ALU     2'b10
`define RISC24_BYPASS_SRC_SHADOW  2'b11
// ================
//  ALU Operations
// ================
  // =========================
  // FU 1: ALU1 (ADD/SUB/CMP)
  // =========================
  `define RISC24_ALU_OP_WIDTH  4

  `define RISC24_ALU_OP_ADD    4'd0
  `define RISC24_ALU_OP_SUB    4'd1
  `define RISC24_ALU_OP_EQ     4'd2
  `define RISC24_ALU_OP_NEQ    4'd3

  `define RISC24_ALU_OP_LE     4'd4
  `define RISC24_ALU_OP_LT     4'd5
  `define RISC24_ALU_OP_GE     4'd6
  `define RISC24_ALU_OP_GT     4'd7

  `define RISC24_ALU_OP_CMOV   4'd8
  //`define RISC24_ALU_OP_     4'd9
  //`define RISC24_ALU_OP_     4'd10
  //`define RISC24_ALU_OP_     4'd11

  `define RISC24_ALU_OP_LEU    4'd12
  `define RISC24_ALU_OP_LTU    4'd13
  `define RISC24_ALU_OP_GEU    4'd14
  `define RISC24_ALU_OP_GTU    4'd15

  `define RISC24_ALU_OP_NOP    4'd0
  // ============================
  // FU 2: ALU2 (MUL/LOGIC/SHIFT)
  // ============================
  `define RISC24_MULSHLOG_OP_WIDTH 3
  // MUL ops
  `define RISC24_MULSHLOG_OP_MUL   3'd0
  // Logic ops
  `define RISC24_MULSHLOG_OP_OR    3'd1
  `define RISC24_MULSHLOG_OP_AND   3'd2
  `define RISC24_MULSHLOG_OP_XOR   3'd3
  // Shift/rotate ops
  `define RISC24_MULSHLOG_OP_SLL   3'd4
  `define RISC24_MULSHLOG_OP_SRA   3'd5
  `define RISC24_MULSHLOG_OP_SRL   3'd6
  `define RISC24_MULSHLOG_OP_ROR   3'd7

  `define RISC24_MULSHLOG_OP_NOP   3'd2
  // ==========
  // FU 3: LSU
  // ==========
  `define RISC24_PE_LSU_OP_WIDTH   2
  // MUL ops
  `define RISC24_LSU_OP_WORD       2'd0
  `define RISC24_LSU_OP_HALF_WORD  2'd1
  `define RISC24_LSU_OP_BYTE       2'd2
  `define RISC24_LSU_OP_NOP        2'd3
`endif