////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//    Module Name :  pe_array_id                                              //
//    Description :  Instruction Decode (ID) stage of the PE array.           //
//                                                                            //
//    Author(s)   :  Yifan He                                                 //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

`include "def-pe.v"

// synopsys translate_off
`timescale 1ns / 1ps
// synopsys translate_on

  
module pe_array_id (                                                            
  iClk,                              // system clock, positive-edge trigger
  iReset,                            // global synchronous reset signal, Active high
                                     
  // from IF stage
  iIF_ID_Instruction,                // IF stage to ID stage instruction


  // to ID-2
  // to RF write
  oID_ID_RF_Write_Addr,              // Register file write-back address
  oID_ID_RF_WriteBack,               // Register file write-back control. 
                                     // Bit 0: register file write enable; Bit 1~2: ALU / LR (Link Register) / LSU / MUL
  
  oUpdate_Flag,                      // selection bits for updating flag/P0/P1
  
  // ALU  
  oID_ID_ALU_Opcode,                 // ALU operation decoding  
  oID_ID_Is_ALU,                     // is ALU operation
  
  // LSU
  oID_ID_LSU_Write_Enable,           // LSU stage data-memory write enable
  oID_ID_LSU_Read_Enable,            // LSU stage data-memory read enable
  oID_ID_LSU_Opcode,                 // LSU opcoce: word/half-word/byte

  // MUL/SHIFT/LOGIC
  oID_ID_MUL_SHIFT_LOGIC_Opcode,     // mult/shift/logic operation opcode
  oID_ID_Is_MUL,                     // is multiplication operation
  oID_ID_Is_Shift,                   // is shift operation
  oID_ID_Is_MUL_SHIFT_LOGIC,         // is mul/shift/logic operation

  // to bypass network
  oID_BP_Immediate                   // sign-extended (to 32bit) immediate
);

//******************************
//  Local Parameter Definition
//******************************



//****************************
//  Input/Output Declaration
//****************************

  input                                  iClk;                              // system clock, positive-edge trigger
  input                                  iReset;                            // global synchronous reset signal, Active high

  // from IF stage
  input  [(`DEF_PE_INS_WIDTH-1):0]       iIF_ID_Instruction;                // IF stage to ID stage instruction

  // to ID-2
  // to RF write
  output [(`DEF_RF_INDEX_WIDTH-1):0]     oID_ID_RF_Write_Addr;              // Register file write-back address
  output [(`RISC24_RFWBOP_WIDTH-1):0]    oID_ID_RF_WriteBack;               // Register file write-back control. 
                                                                            // Bit 0: register file write enable; Bit 1~2: ALU / LR (Link Register) / LSU / MUL
  
  output [1:0]                           oUpdate_Flag;                      // selection bits for updating flag/P0/P1
  
  // ALU
  output [(`RISC24_ALU_OP_WIDTH-1):0]    oID_ID_ALU_Opcode;                 // ALU operation decoding  
  output                                 oID_ID_Is_ALU;                     // is ALU operation
  
  // LSU
  output                                 oID_ID_LSU_Write_Enable;           // LSU stage data-memory write enable
  output                                 oID_ID_LSU_Read_Enable;            // LSU stage data-memory read enable
  output [(`RISC24_PE_LSU_OP_WIDTH-1):0] oID_ID_LSU_Opcode;                 // LSU opcoce: word/half-word/byte
  
  // MUL/SHIFT/LOGIC
  output [(`RISC24_MULSHLOG_OP_WIDTH-1):0] oID_ID_MUL_SHIFT_LOGIC_Opcode;   // mul/shift/rotate operation opcode
  output                                 oID_ID_Is_MUL;                     // is multiplication operation
  output                                 oID_ID_Is_Shift;                   // is shift operation
  output                                 oID_ID_Is_MUL_SHIFT_LOGIC;         // is mul/shift/logic operation
  
  
  // to bypass network
  output [(`DEF_PE_DATA_WIDTH-1):0]      oID_BP_Immediate;                  // sign-extended (to 32bit) immediate


//******************************
//  Local Wire/Reg Declaration
//******************************
  
  // immediate value
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wID_Immediate;              // final sign/zero-extended (to data-path width) immediate
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wImm_Zero_Extended;         // zero-extended immediate
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wImm_Sign_Extended;         // sign-extended immediate
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wImm_Default;               // default way to extend immediate
  
  
  // RF write back
  reg  [(`RISC24_RFWBOP_WIDTH-1):0]       wEX_RF_WriteBack;
  
  // LSU
  reg                                     wIs_LSU_Write;              // flag: indicate it is a LSU write operation
  reg                                     wIs_LSU_Read;               // flag: indicate it is a LSU read operation
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wLSU_Opcode;                // LSU opcoce: word/half-word/byte
  
  
 // MUL/LOGIC/SHIFT
  reg                                     wIs_MUL_SHIFT_LOGIC;        // flag: indicate it is a multiplication/shift/logic operation
  reg                                     wIs_Multiplication;
  reg                                     wIs_Shift;
  reg  [(`RISC24_MULSHLOG_OP_WIDTH-1):0]  wMUL_SHIFT_LOGIC_Opcode;    // multiplication/shift/logic operation opcode
  
  
  // ALU
  reg                                     wIs_ALU;                    // flag: indicate it is a ALU operation (not MUL/SHIFT/LOGIC/LSU)
  reg  [(`RISC24_ALU_OP_WIDTH-1):0]       wALU_Opcode;                // ALU operation opcode
  
  
  // Special ins.: SIMM & ZIMM
  wire                                    wIs_SIMM;                   // is sign-extended long immediate
  wire                                    wIs_ZIMM;                   // is zero-extended long immediate
  reg                                     rIs_Long_Imm;               // Flag: indicate the previous ins. is a long-imm ins.
  reg  [(`DEF_PE_DATA_WIDTH-`DEF_INS_IMM_WIDTH-1):0] rLong_Imm;       // long immdediate register
  
  
//******************************
//  Behavioral Description
//******************************

// *********************
//  1. ID to IF Stage
// *********************

  
// ********************
//  2. ID to EX Stage
// ********************
  // ====================================
  //  Decode using a big "always block"
  // ====================================  
  assign wImm_Zero_Extended = { {(`DEF_PE_DATA_WIDTH-`DEF_INS_IMM_WIDTH){1'b0} },                                     iIF_ID_Instruction[`DEF_INS_IMM_END_BIT:`DEF_INS_IMM_START_BIT]};
  assign wImm_Sign_Extended = { {(`DEF_PE_DATA_WIDTH-`DEF_INS_IMM_WIDTH){iIF_ID_Instruction[`DEF_INS_IMM_END_BIT]} }, iIF_ID_Instruction[`DEF_INS_IMM_END_BIT:`DEF_INS_IMM_START_BIT]};
  
  assign wImm_Default = wImm_Sign_Extended;
  
  
  always @ ( iIF_ID_Instruction or wImm_Zero_Extended or wImm_Sign_Extended or wImm_Default )
    begin
      case ( iIF_ID_Instruction[`DEF_INS_OPCODE_END_BIT:`DEF_INS_OPCODE_START_BIT] ) 
        // J-type, SIMM, ZIMM
        `RISC24_OP_NOP1, `RISC24_OP_NOP2:
          begin
            // immediate selection
            wID_Immediate    = wImm_Default;
            
            // RF write-back control                                                                 // JAL/JALR: 3'b1?1
            wEX_RF_WriteBack = ( (iIF_ID_Instruction[`DEF_INS_TYPE_BIT] == `DEF_INS_IS_R_TYPE) && iIF_ID_Instruction[`DEF_PE_INS_WIDTH-6] && iIF_ID_Instruction[`DEF_PE_INS_WIDTH-8] ) ? 
                               {`RISC24_RFWBOP_LR, 1'b1} : `RISC24_RFWBOP_NOP;
            
            // ALU
            wIs_ALU     = 1'b0;
            wALU_Opcode = `RISC24_ALU_OP_NOP;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b0;
            wIs_MUL_SHIFT_LOGIC     = 1'b0;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_MULSHLOG_OP_NOP;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_LSU_OP_NOP;
          end
        `RISC24_OP_ADD:
          begin
            // immediate selection
            wID_Immediate    = wImm_Sign_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = {`RISC24_RFWBOP_ALU, 1'b1};
            
            // ALU
            wIs_ALU     = 1'b1;
            wALU_Opcode = `RISC24_ALU_OP_ADD;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b0;
            wIs_MUL_SHIFT_LOGIC     = 1'b0;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_MULSHLOG_OP_NOP;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_LSU_OP_NOP;
          end
        `RISC24_OP_SUB:
          begin
            // immediate selection
            wID_Immediate    = wImm_Sign_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = {`RISC24_RFWBOP_ALU, 1'b1};
            
            // ALU
            wIs_ALU     = 1'b1;
            wALU_Opcode = `RISC24_ALU_OP_SUB;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b0;
            wIs_MUL_SHIFT_LOGIC     = 1'b0;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_MULSHLOG_OP_NOP;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_LSU_OP_NOP;
          end  
        `RISC24_OP_MUL:
          begin
            // immediate selection
            wID_Immediate    = wImm_Sign_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = {`RISC24_RFWBOP_MUL, 1'b1};
            
            // ALU
            wIs_ALU     = 1'b0;
            wALU_Opcode = `RISC24_ALU_OP_NOP;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b1;
            wIs_Shift               = 1'b0;
            wIs_MUL_SHIFT_LOGIC     = 1'b1;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_MULSHLOG_OP_MUL;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_LSU_OP_NOP;
          end  
        `RISC24_OP_MULU:
          begin
            // immediate selection
            wID_Immediate    = wImm_Zero_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = {`RISC24_RFWBOP_MUL, 1'b1};
            
            // ALU
            wIs_ALU     = 1'b0;
            wALU_Opcode = `RISC24_ALU_OP_NOP;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b1;
            wIs_Shift               = 1'b0;
            wIs_MUL_SHIFT_LOGIC     = 1'b1;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_MULSHLOG_OP_MUL;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_LSU_OP_NOP;
          end  
        `RISC24_OP_OR:
          begin
            // immediate selection
            wID_Immediate    = wImm_Zero_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = {`RISC24_RFWBOP_MUL, 1'b1};
            
            // ALU
            wIs_ALU     = 1'b0;
            wALU_Opcode = `RISC24_ALU_OP_NOP;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b0;
            wIs_MUL_SHIFT_LOGIC     = 1'b1;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_MULSHLOG_OP_OR;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_LSU_OP_NOP;
          end
        `RISC24_OP_AND:
          begin
            // immediate selection
            wID_Immediate    = wImm_Zero_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = {`RISC24_RFWBOP_MUL, 1'b1};
            
            // ALU
            wIs_ALU     = 1'b0;
            wALU_Opcode = `RISC24_ALU_OP_NOP;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b0;
            wIs_MUL_SHIFT_LOGIC     = 1'b1;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_MULSHLOG_OP_AND;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_LSU_OP_NOP;
          end  
        `RISC24_OP_XOR:
          begin
            // immediate selection
            wID_Immediate    = wImm_Sign_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = {`RISC24_RFWBOP_MUL, 1'b1};
            
            // ALU
            wIs_ALU     = 1'b0;
            wALU_Opcode = `RISC24_ALU_OP_NOP;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b0;
            wIs_MUL_SHIFT_LOGIC     = 1'b1;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_MULSHLOG_OP_XOR;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_LSU_OP_NOP;
          end  
        `RISC24_OP_CMOV:
          begin
            // immediate selection
            wID_Immediate    = wImm_Sign_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = {`RISC24_RFWBOP_ALU, 1'b1};
            
            // ALU
            wIs_ALU     = 1'b1;
            wALU_Opcode = `RISC24_ALU_OP_CMOV;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b0;
            wIs_MUL_SHIFT_LOGIC     = 1'b0;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_MULSHLOG_OP_NOP;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_LSU_OP_NOP;
          end  
        `RISC24_OP_EQ:
          begin
            // immediate selection
            wID_Immediate    = wImm_Sign_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = `RISC24_RFWBOP_NOP;
            
            // ALU
            wIs_ALU     = 1'b1;
            wALU_Opcode = `RISC24_ALU_OP_EQ;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b0;
            wIs_MUL_SHIFT_LOGIC     = 1'b0;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_MULSHLOG_OP_NOP;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_LSU_OP_NOP;
          end  
        `RISC24_OP_NE:
          begin
            // immediate selection
            wID_Immediate    = wImm_Sign_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = `RISC24_RFWBOP_NOP;
            
            // ALU
            wIs_ALU     = 1'b1;
            wALU_Opcode = `RISC24_ALU_OP_NEQ;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b0;
            wIs_MUL_SHIFT_LOGIC     = 1'b0;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_MULSHLOG_OP_NOP;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_LSU_OP_NOP;
          end  
        `RISC24_OP_LE:
          begin
            // immediate selection
            wID_Immediate    = wImm_Sign_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = `RISC24_RFWBOP_NOP;
            
            // ALU
            wIs_ALU     = 1'b1;
            wALU_Opcode = `RISC24_ALU_OP_LE;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b0;
            wIs_MUL_SHIFT_LOGIC     = 1'b0;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_MULSHLOG_OP_NOP;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_LSU_OP_NOP;
          end  
        `RISC24_OP_LT:
          begin
            // immediate selection
            wID_Immediate    = wImm_Sign_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = `RISC24_RFWBOP_NOP;
            
            // ALU
            wIs_ALU     = 1'b1;
            wALU_Opcode = `RISC24_ALU_OP_LT;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b0;
            wIs_MUL_SHIFT_LOGIC     = 1'b0;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_MULSHLOG_OP_NOP;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_LSU_OP_NOP;
          end  
        `RISC24_OP_GE:
          begin
            // immediate selection
            wID_Immediate    = wImm_Sign_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = `RISC24_RFWBOP_NOP;
            
            // ALU
            wIs_ALU     = 1'b1;
            wALU_Opcode = `RISC24_ALU_OP_GE;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b0;
            wIs_MUL_SHIFT_LOGIC     = 1'b0;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_MULSHLOG_OP_NOP;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_LSU_OP_NOP;
          end  
        `RISC24_OP_GT:
          begin
            // immediate selection
            wID_Immediate    = wImm_Sign_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = `RISC24_RFWBOP_NOP;
            
            // ALU
            wIs_ALU     = 1'b1;
            wALU_Opcode = `RISC24_ALU_OP_GT;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b0;
            wIs_MUL_SHIFT_LOGIC     = 1'b0;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_MULSHLOG_OP_NOP;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_LSU_OP_NOP;
          end  
        `RISC24_OP_LEU:
          begin
            // immediate selection
            wID_Immediate    = wImm_Sign_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = `RISC24_RFWBOP_NOP;
            
            // ALU
            wIs_ALU     = 1'b1;
            wALU_Opcode = `RISC24_ALU_OP_LEU;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b0;
            wIs_MUL_SHIFT_LOGIC     = 1'b0;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_MULSHLOG_OP_NOP;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_LSU_OP_NOP;
          end  
        `RISC24_OP_LTU:
          begin
            // immediate selection
            wID_Immediate    = wImm_Sign_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = `RISC24_RFWBOP_NOP;
            
            // ALU
            wIs_ALU     = 1'b1;
            wALU_Opcode = `RISC24_ALU_OP_LTU;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b0;
            wIs_MUL_SHIFT_LOGIC     = 1'b0;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_MULSHLOG_OP_NOP;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_LSU_OP_NOP;
          end      
        `RISC24_OP_GEU:
          begin
            // immediate selection
            wID_Immediate    = wImm_Sign_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = `RISC24_RFWBOP_NOP;
            
            // ALU
            wIs_ALU     = 1'b1;
            wALU_Opcode = `RISC24_ALU_OP_GEU;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b0;
            wIs_MUL_SHIFT_LOGIC     = 1'b0;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_MULSHLOG_OP_NOP;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_LSU_OP_NOP;
          end
        `RISC24_OP_GTU:
          begin
            // immediate selection
            wID_Immediate    = wImm_Sign_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = `RISC24_RFWBOP_NOP;
            
            // ALU
            wIs_ALU     = 1'b1;
            wALU_Opcode = `RISC24_ALU_OP_GTU;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b0;
            wIs_MUL_SHIFT_LOGIC     = 1'b0;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_MULSHLOG_OP_NOP;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_LSU_OP_NOP;
          end
        `RISC24_OP_SLL:
          begin
            // immediate selection
            wID_Immediate    = wImm_Sign_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = {`RISC24_RFWBOP_MUL, 1'b1};
            
            // ALU
            wIs_ALU     = 1'b0;
            wALU_Opcode = `RISC24_ALU_OP_NOP;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b1;
            wIs_MUL_SHIFT_LOGIC     = 1'b1;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_MULSHLOG_OP_SLL;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_LSU_OP_NOP;
          end
        `RISC24_OP_SRA:
          begin
            // immediate selection
            wID_Immediate    = wImm_Sign_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = {`RISC24_RFWBOP_MUL, 1'b1};
            
            // ALU
            wIs_ALU     = 1'b0;
            wALU_Opcode = `RISC24_ALU_OP_NOP;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b1;
            wIs_MUL_SHIFT_LOGIC     = 1'b1;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_MULSHLOG_OP_SRA;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_LSU_OP_NOP;
          end
        `RISC24_OP_SRL:
          begin
            // immediate selection
            wID_Immediate    = wImm_Sign_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = {`RISC24_RFWBOP_MUL, 1'b1};
            
            // ALU
            wIs_ALU     = 1'b0;
            wALU_Opcode = `RISC24_ALU_OP_NOP;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b1;
            wIs_MUL_SHIFT_LOGIC     = 1'b1;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_MULSHLOG_OP_SRL;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_LSU_OP_NOP;
          end
        `RISC24_OP_ROR:
          begin
            // immediate selection
            wID_Immediate    = wImm_Sign_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = {`RISC24_RFWBOP_MUL, 1'b1};
            
            // ALU
            wIs_ALU     = 1'b0;
            wALU_Opcode = `RISC24_ALU_OP_NOP;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b1;
            wIs_MUL_SHIFT_LOGIC     = 1'b1;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_MULSHLOG_OP_ROR;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_LSU_OP_NOP;
          end
        `RISC24_OP_LWZ:
          begin
            if ( iIF_ID_Instruction[`DEF_INS_TYPE_BIT] == `DEF_INS_IS_R_TYPE )
              begin
                // immediate selection
                wID_Immediate    = wImm_Default;
                
                // RF write-back control
                wEX_RF_WriteBack = `RISC24_RFWBOP_NOP;
                
                // ALU
                wIs_ALU     = 1'b0;
                wALU_Opcode = `RISC24_ALU_OP_NOP;
                
                // MUL/SHIFT/LOGIC
                wIs_Multiplication      = 1'b0;
                wIs_Shift               = 1'b0;
                wIs_MUL_SHIFT_LOGIC     = 1'b0;
                wMUL_SHIFT_LOGIC_Opcode = `RISC24_MULSHLOG_OP_NOP;
                
                // LSU
                wIs_LSU_Read  = 1'b0;
                wIs_LSU_Write = 1'b0;
                wLSU_Opcode   = `RISC24_LSU_OP_NOP;
              end
            else
              begin
                // immediate selection
                wID_Immediate    = { {(`DEF_PE_DATA_WIDTH-`DEF_INS_IMM_WIDTH-2){iIF_ID_Instruction[`DEF_INS_IMM_END_BIT]} }, iIF_ID_Instruction[`DEF_INS_IMM_END_BIT:`DEF_INS_IMM_START_BIT], 2'b00};
                
                // RF write-back control
                wEX_RF_WriteBack = {`RISC24_RFWBOP_LSU, 1'b1};
                
                // ALU
                wIs_ALU     = 1'b0;
                wALU_Opcode = `RISC24_ALU_OP_NOP;
                
                // MUL/SHIFT/LOGIC
                wIs_Multiplication      = 1'b0;
                wIs_Shift               = 1'b0;
                wIs_MUL_SHIFT_LOGIC     = 1'b0;
                wMUL_SHIFT_LOGIC_Opcode = `RISC24_MULSHLOG_OP_NOP;
                
                // LSU
                wIs_LSU_Read  = 1'b1;
                wIs_LSU_Write = 1'b0;
                wLSU_Opcode   = `RISC24_LSU_OP_WORD;
              end
          end
        `RISC24_OP_LBZ:
          begin
            if ( iIF_ID_Instruction[`DEF_INS_TYPE_BIT] == `DEF_INS_IS_R_TYPE )
              begin
                // immediate selection
                wID_Immediate    = wImm_Default;
                
                // RF write-back control
                wEX_RF_WriteBack = `RISC24_RFWBOP_NOP;
                
                // ALU
                wIs_ALU     = 1'b0;
                wALU_Opcode = `RISC24_ALU_OP_NOP;
                
                // MUL/SHIFT/LOGIC
                wIs_Multiplication      = 1'b0;
                wIs_Shift               = 1'b0;
                wIs_MUL_SHIFT_LOGIC     = 1'b0;
                wMUL_SHIFT_LOGIC_Opcode = `RISC24_MULSHLOG_OP_NOP;
                
                // LSU
                wIs_LSU_Read  = 1'b0;
                wIs_LSU_Write = 1'b0;
                wLSU_Opcode   = `RISC24_LSU_OP_NOP;
              end
            else
              begin
                // immediate selection
                wID_Immediate    = { {(`DEF_PE_DATA_WIDTH-`DEF_INS_IMM_WIDTH-0){iIF_ID_Instruction[`DEF_INS_IMM_END_BIT]} }, iIF_ID_Instruction[`DEF_INS_IMM_END_BIT:`DEF_INS_IMM_START_BIT]};
                
                // RF write-back control
                wEX_RF_WriteBack = {`RISC24_RFWBOP_LSU, 1'b1};
                
                // ALU
                wIs_ALU     = 1'b0;
                wALU_Opcode = `RISC24_ALU_OP_NOP;
                
                // MUL/SHIFT/LOGIC
                wIs_Multiplication      = 1'b0;
                wIs_Shift               = 1'b0;
                wIs_MUL_SHIFT_LOGIC     = 1'b0;
                wMUL_SHIFT_LOGIC_Opcode = `RISC24_MULSHLOG_OP_NOP;
                
                // LSU
                wIs_LSU_Read  = 1'b1;
                wIs_LSU_Write = 1'b0;
                wLSU_Opcode   = `RISC24_LSU_OP_BYTE;
              end
          end
        `RISC24_OP_LHZ:
          begin
            if ( iIF_ID_Instruction[`DEF_INS_TYPE_BIT] == `DEF_INS_IS_R_TYPE )
              begin
                // immediate selection
                wID_Immediate    = wImm_Default;
                
                // RF write-back control
                wEX_RF_WriteBack = `RISC24_RFWBOP_NOP;
                
                // ALU
                wIs_ALU     = 1'b0;
                wALU_Opcode = `RISC24_ALU_OP_NOP;
                
                // MUL/SHIFT/LOGIC
                wIs_Multiplication      = 1'b0;
                wIs_Shift               = 1'b0;
                wIs_MUL_SHIFT_LOGIC     = 1'b0;
                wMUL_SHIFT_LOGIC_Opcode = `RISC24_MULSHLOG_OP_NOP;
                
                // LSU
                wIs_LSU_Read  = 1'b0;
                wIs_LSU_Write = 1'b0;
                wLSU_Opcode   = `RISC24_LSU_OP_NOP;
              end
            else
              begin
                // immediate selection
                wID_Immediate    = { {(`DEF_PE_DATA_WIDTH-`DEF_INS_IMM_WIDTH-1){iIF_ID_Instruction[`DEF_INS_IMM_END_BIT]} }, iIF_ID_Instruction[`DEF_INS_IMM_END_BIT:`DEF_INS_IMM_START_BIT], 1'b0};
                
                // RF write-back control
                wEX_RF_WriteBack = {`RISC24_RFWBOP_LSU, 1'b1};
                
                // ALU
                wIs_ALU     = 1'b0;
                wALU_Opcode = `RISC24_ALU_OP_NOP;
                
                // MUL/SHIFT/LOGIC
                wIs_Multiplication      = 1'b0;
                wIs_Shift               = 1'b0;
                wIs_MUL_SHIFT_LOGIC     = 1'b0;
                wMUL_SHIFT_LOGIC_Opcode = `RISC24_MULSHLOG_OP_NOP;
                
                // LSU
                wIs_LSU_Read  = 1'b1;
                wIs_LSU_Write = 1'b0;
                wLSU_Opcode   = `RISC24_LSU_OP_HALF_WORD;
              end
          end
        `RISC24_OP_SW:
          begin
            if ( iIF_ID_Instruction[`DEF_INS_TYPE_BIT] == `DEF_INS_IS_R_TYPE )
              begin
                // immediate selection
                wID_Immediate    = wImm_Default;
                
                // RF write-back control
                wEX_RF_WriteBack = `RISC24_RFWBOP_NOP;
                
                // ALU
                wIs_ALU     = 1'b0;
                wALU_Opcode = `RISC24_ALU_OP_NOP;
                
                // MUL/SHIFT/LOGIC
                wIs_Multiplication      = 1'b0;
                wIs_Shift               = 1'b0;
                wIs_MUL_SHIFT_LOGIC     = 1'b0;
                wMUL_SHIFT_LOGIC_Opcode = `RISC24_MULSHLOG_OP_NOP;
                
                // LSU
                wIs_LSU_Read  = 1'b0;
                wIs_LSU_Write = 1'b0;
                wLSU_Opcode   = `RISC24_LSU_OP_NOP;
              end
            else
              begin
                // immediate selection
                wID_Immediate    = { {(`DEF_PE_DATA_WIDTH-`DEF_INS_IMM_WIDTH-2){iIF_ID_Instruction[`DEF_INS_DES_END_BIT]} }, {iIF_ID_Instruction[`DEF_INS_DES_END_BIT:`DEF_INS_DES_START_BIT], iIF_ID_Instruction[(`DEF_INS_SRC2_START_BIT-1):`DEF_INS_IMM_START_BIT]}, 2'b00};
                
                // RF write-back control
                wEX_RF_WriteBack = `RISC24_RFWBOP_NOP;
                
                // ALU
                wIs_ALU     = 1'b0;
                wALU_Opcode = `RISC24_ALU_OP_NOP;
                
                // MUL/SHIFT/LOGIC
                wIs_Multiplication      = 1'b0;
                wIs_Shift               = 1'b0;
                wIs_MUL_SHIFT_LOGIC     = 1'b0;
                wMUL_SHIFT_LOGIC_Opcode = `RISC24_MULSHLOG_OP_NOP;
                
                // LSU
                wIs_LSU_Read  = 1'b0;
                wIs_LSU_Write = 1'b1;
                wLSU_Opcode   = `RISC24_LSU_OP_WORD;
              end
          end
        `RISC24_OP_SB:
          begin
            if ( iIF_ID_Instruction[`DEF_INS_TYPE_BIT] == `DEF_INS_IS_R_TYPE )
              begin
                // immediate selection
                wID_Immediate    = wImm_Default;
                
                // RF write-back control
                wEX_RF_WriteBack = `RISC24_RFWBOP_NOP;
                
                // ALU
                wIs_ALU     = 1'b0;
                wALU_Opcode = `RISC24_ALU_OP_NOP;
                
                // MUL/SHIFT/LOGIC
                wIs_Multiplication      = 1'b0;
                wIs_Shift               = 1'b0;
                wIs_MUL_SHIFT_LOGIC     = 1'b0;
                wMUL_SHIFT_LOGIC_Opcode = `RISC24_MULSHLOG_OP_NOP;
                
                // LSU
                wIs_LSU_Read  = 1'b0;
                wIs_LSU_Write = 1'b0;
                wLSU_Opcode   = `RISC24_LSU_OP_NOP;
              end
            else
              begin
                // immediate selection
                wID_Immediate    = { {(`DEF_PE_DATA_WIDTH-`DEF_INS_IMM_WIDTH-0){iIF_ID_Instruction[`DEF_INS_DES_END_BIT]} }, {iIF_ID_Instruction[`DEF_INS_DES_END_BIT:`DEF_INS_DES_START_BIT], iIF_ID_Instruction[(`DEF_INS_SRC2_START_BIT-1):`DEF_INS_IMM_START_BIT]} };
                
                // RF write-back control
                wEX_RF_WriteBack = `RISC24_RFWBOP_NOP;
                
                // ALU
                wIs_ALU     = 1'b0;
                wALU_Opcode = `RISC24_ALU_OP_NOP;
                
                // MUL/SHIFT/LOGIC
                wIs_Multiplication      = 1'b0;
                wIs_Shift               = 1'b0;
                wIs_MUL_SHIFT_LOGIC     = 1'b0;
                wMUL_SHIFT_LOGIC_Opcode = `RISC24_MULSHLOG_OP_NOP;
                
                // LSU
                wIs_LSU_Read  = 1'b0;
                wIs_LSU_Write = 1'b1;
                wLSU_Opcode   = `RISC24_LSU_OP_BYTE;
              end
          end
        `RISC24_OP_SH:
          begin
            if ( iIF_ID_Instruction[`DEF_INS_TYPE_BIT] == `DEF_INS_IS_R_TYPE )
              begin
                // immediate selection
                wID_Immediate    = wImm_Default;
                
                // RF write-back control
                wEX_RF_WriteBack = `RISC24_RFWBOP_NOP;
                
                // ALU
                wIs_ALU     = 1'b0;
                wALU_Opcode = `RISC24_ALU_OP_NOP;
                
                // MUL/SHIFT/LOGIC
                wIs_Multiplication      = 1'b0;
                wIs_Shift               = 1'b0;
                wIs_MUL_SHIFT_LOGIC     = 1'b0;
                wMUL_SHIFT_LOGIC_Opcode = `RISC24_MULSHLOG_OP_NOP;
                
                // LSU
                wIs_LSU_Read  = 1'b0;
                wIs_LSU_Write = 1'b0;
                wLSU_Opcode   = `RISC24_LSU_OP_NOP;
              end
            else
              begin
                // immediate selection
                wID_Immediate    = { {(`DEF_PE_DATA_WIDTH-`DEF_INS_IMM_WIDTH-1){iIF_ID_Instruction[`DEF_INS_DES_END_BIT]} }, {iIF_ID_Instruction[`DEF_INS_DES_END_BIT:`DEF_INS_DES_START_BIT], iIF_ID_Instruction[(`DEF_INS_SRC2_START_BIT-1):`DEF_INS_IMM_START_BIT]}, 1'b0};
                
                // RF write-back control
                wEX_RF_WriteBack = `RISC24_RFWBOP_NOP;
                
                // ALU
                wIs_ALU     = 1'b0;
                wALU_Opcode = `RISC24_ALU_OP_NOP;
                
                // MUL/SHIFT/LOGIC
                wIs_Multiplication      = 1'b0;
                wIs_Shift               = 1'b0;
                wIs_MUL_SHIFT_LOGIC     = 1'b0;
                wMUL_SHIFT_LOGIC_Opcode = `RISC24_MULSHLOG_OP_NOP;
                
                // LSU
                wIs_LSU_Read  = 1'b0;
                wIs_LSU_Write = 1'b1;
                wLSU_Opcode   = `RISC24_LSU_OP_HALF_WORD;
              end
          end  
          
      default:
          begin
              // immediate selection
            wID_Immediate    = wImm_Default;
            
            // RF write-back control
            wEX_RF_WriteBack = `RISC24_RFWBOP_NOP;
            
            // ALU
            wIs_ALU     = 1'b0;
            wALU_Opcode = `RISC24_ALU_OP_NOP;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b0;
            wIs_MUL_SHIFT_LOGIC     = 1'b0;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_MULSHLOG_OP_NOP;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_LSU_OP_NOP;
          end
      endcase
    end
  // end of always
  
      
  // ====================================
  //  Handle the special "SIMM/ZIMM"
  // ==================================== 
  assign wIs_SIMM = ( (iIF_ID_Instruction[`DEF_INS_TYPE_BIT] == `DEF_INS_IS_I_TYPE) && (iIF_ID_Instruction[`DEF_INS_OPCODE_END_BIT:`DEF_INS_OPCODE_START_BIT] == `RISC24_OP_NOP1) );
  assign wIs_ZIMM = ( (iIF_ID_Instruction[`DEF_INS_TYPE_BIT] == `DEF_INS_IS_I_TYPE) && (iIF_ID_Instruction[`DEF_INS_OPCODE_END_BIT:`DEF_INS_OPCODE_START_BIT] == `RISC24_OP_NOP2) );
  
  
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )  
      rLong_Imm <= 'b0;
    else if ( wIs_SIMM )  // 32 - 18 - 8
      rLong_Imm <= { {(`DEF_PE_DATA_WIDTH-`DEF_INS_LONGIMM_WIDTH-`DEF_INS_IMM_WIDTH){iIF_ID_Instruction[`DEF_INS_LONGIMM_END_BIT]} }, iIF_ID_Instruction[`DEF_INS_LONGIMM_END_BIT:`DEF_INS_LONGIMM_START_BIT]};
    else if ( wIs_ZIMM )
      rLong_Imm <= { {(`DEF_PE_DATA_WIDTH-`DEF_INS_LONGIMM_WIDTH-`DEF_INS_IMM_WIDTH){1'b0} }, iIF_ID_Instruction[`DEF_INS_LONGIMM_END_BIT:`DEF_INS_LONGIMM_START_BIT]};
  // end of always  
    
      
  always @ ( posedge iClk )
    if ( iReset == 1'b1 ) 
      rIs_Long_Imm <= 'b0;
    else 
      rIs_Long_Imm <= (wIs_SIMM || wIs_ZIMM);
  // end of always  
  
       
//*********************
//  Output Assignment
//*********************
  // --------------
  //  to EX stage 
  // --------------
  // RF write-back
  assign oID_ID_RF_WriteBack  = wEX_RF_WriteBack; 
  assign oID_ID_RF_Write_Addr = iIF_ID_Instruction[`DEF_INS_DES_END_BIT:`DEF_INS_DES_START_BIT];
    
  assign oUpdate_Flag         = iIF_ID_Instruction[(`DEF_INS_DES_START_BIT+1):`DEF_INS_DES_START_BIT];
  
  // ALU
  assign oID_ID_ALU_Opcode = wALU_Opcode;   
  assign oID_ID_Is_ALU     = wIs_ALU;
  
  // LSU
  assign oID_ID_LSU_Write_Enable = wIs_LSU_Write;
  assign oID_ID_LSU_Read_Enable  = wIs_LSU_Read; 
  assign oID_ID_LSU_Opcode       = wLSU_Opcode; 
  
  // MUL/SHIFT/LOGIC  
  assign oID_ID_MUL_SHIFT_LOGIC_Opcode = wMUL_SHIFT_LOGIC_Opcode;
  assign oID_ID_Is_MUL                 = wIs_Multiplication;
  assign oID_ID_Is_Shift               = wIs_Shift;
  assign oID_ID_Is_MUL_SHIFT_LOGIC     = wIs_MUL_SHIFT_LOGIC;
 
  // ------------------
  // to bypass network
  // ------------------
  assign oID_BP_Immediate = rIs_Long_Imm ? {rLong_Imm, wID_Immediate[`DEF_INS_IMM_END_BIT:`DEF_INS_IMM_START_BIT]} : wID_Immediate;
  
  // to freeze module
  //assign oEXStage_Is_Load = rPR_EX_LSU_Read_Enable;


endmodule
