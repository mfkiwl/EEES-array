////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//    Module Name :  cp_id                                                    //
//    Description :  Instruction Decode stage of the 24-bit RISC processor.   //
//                                                                            //
//    Author(s)   :  Yifan He                                                 //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

`include "def-cp.v"

// synopsys translate_off
`timescale 1ns / 1ps
// synopsys translate_on


module cp_id (                                                            
  iClk,                              // system clock, positive-edge trigger
  iReset,                            // global synchronous reset signal, Active high
   
  // to system top
  oTask_Finished,                    // task ready
                                     
  // from/to IF stage
  oID_IF_Branch_Target_Addr,         // branch target address
  oID_IF_Branch_Taken_Flag,          // branch taken flag:  1 = taken, 0 = not taken
  
  iIF_ID_PC,                         // PC of the instruction at the current stage
  iIF_ID_Instruction,                // IF stage to ID stage instruction

  iIF_ID_Branch_Op,                  // branch operation types

  iIF_ID_Predication,                // predication bits
  
  // from/to EX stage
  iEX_ID_Flag_Register,              // value of the flag register (comparison result)  

  iEX_ID_P0,                         // value of P1 register
  iEX_ID_P1,                         // value of P2 register

  oID_EX_RF_Write_Addr,              // Register file write-back address
  oID_EX_RF_WriteBack,               // Register file write-back control. 
                                     // Bit 0: register file write enable; Bit 1~2: ALU / LR (Link Register) / LSU / MUL
  
  oID_EX_Write_Shadow_Register,      // Write the shadow register (write R31)
  
  // ALU  
  oID_EX_ALU_Opcode,                 // ALU operation decoding  
  oID_EX_ALU_Operand_A,              // Operand A to the EX stage
  oID_EX_ALU_Operand_B,              // Operand B to the EX stage  
  
  // LSU
  oID_EX_LSU_Memory_Write_Enable,    // LSU stage data-memory write enable
  oID_EX_LSU_Memory_Read_Enable,     // LSU stage data-memory read enable  
  oID_EX_LSU_Operand_A,              // Operand A to the EX stage for LSU only
  oID_EX_LSU_Operand_B,              // Operand B to the EX stage for LSU only  
  oID_EX_LSU_Opcode,                 // LSU opcoce: word/half-word/byte
  oID_EX_LSU_Store_Data,             // Store data to EX stage (for store instruction only)

  // MUL/SHIFT/LOGIC
  oID_EX_MUL_SHIFT_LOGIC_Opcode,     // mult/shift/logic operation opcode
  oID_EX_MUL_SHIFT_LOGIC_Operand_A,  // Operand A to the EX stage for mult/shift/logic
  oID_EX_MUL_SHIFT_LOGIC_Operand_B,  // Operand B to the EX stage for mult/shift/logic
  
  // Flag signals
  oID_EX_Is_Multiplication,
  oID_EX_Is_Shift,
  
  // flag/P0/P1
  oID_EX_Update_Flag,                // if set condition met in compare ins. update flag
  oID_EX_Update_P0,                  // if set condition met in compare ins. update P0  
  oID_EX_Update_P1,                  // if set condition met in compare ins. update P1  

  // pc
  oID_EX_PC,                         // PC followed to EX-stage

  iRF_BP_Read_Data_B,                // RF read data from port B
  
  // from/to bypass network
  iBP_ID_Operand_A,                  // operand A
  iBP_ID_Operand_B,                  // operand B  
  iBP_ID_LSU_Store_Data,             // store data (for store instruction only)
  oID_BP_Immediate,                  // sign-extended (to 32bit) immediate
  oID_BP_Is_Long_Immediate,          // Flag: indicate the previous ins. is a long-imm ins.
  oID_BP_Long_Immediate,             // long immdediate register
  oID_BP_Is_SUB                      // current ins. is SUB
  
  // from/to Freeze Logic
  //iID_Freeze,                      // pipeline stage freeze signal from freeze control logic
  //oEXStage_Is_Load                 // the instruction in the EX stage is a load instruction
);

//******************************
//  Local Parameter Definition
//******************************



//****************************
//  Input/Output Declaration
//****************************

  input                                     iClk;                              // system clock, positive-edge trigger
  input                                     iReset;                            // global synchronous reset signal, Active high

  // to system top
  output                                    oTask_Finished;                    // task ready
  
  // from/to IF stage                             
  output [(`DEF_CP_I_MEM_ADDR_WIDTH-3):0]   oID_IF_Branch_Target_Addr;         // branch target address
  output                                    oID_IF_Branch_Taken_Flag;          // branch taken flag:  1 = taken, 0 = not taken
  
  input  [(`DEF_CP_I_MEM_ADDR_WIDTH-3):0]   iIF_ID_PC;                         // PC of the instruction at the current stage
  input  [(`DEF_CP_INS_WIDTH-1):0]          iIF_ID_Instruction;                // IF stage to ID stage instruction  
 
  input  [(`RISC24_CP_BRANCHOP_WIDTH-1):0]  iIF_ID_Branch_Op;                  // branch operation types

  input  [1:0]                              iIF_ID_Predication;
  
  // from/to EX stage
  input                                     iEX_ID_Flag_Register;              // value of the flag register (comparison result)

  input                                     iEX_ID_P0;                         // value of P0 register
  input                                     iEX_ID_P1;                         // value of P1 register

  output [(`DEF_CP_RF_INDEX_WIDTH-1):0]     oID_EX_RF_Write_Addr;              // Register file write-back address
  output [(`RISC24_CP_RFWBOP_WIDTH-1):0]    oID_EX_RF_WriteBack;               // Register file write-back control. 
                                                                               // Bit 0: register file write enable; Bit 1~2: ALU / LR (Link Register) / LSU / MUL
  
  output                                    oID_EX_Write_Shadow_Register;      // Write the shadow register (write R31)
  
  // ALU
  output [(`RISC24_CP_ALU_OP_WIDTH-1):0]    oID_EX_ALU_Opcode;                 // ALU operation decoding  
  output [(`DEF_CP_DATA_WIDTH-1):0]         oID_EX_ALU_Operand_A;              // Operand A to the EX stage
  output [(`DEF_CP_DATA_WIDTH-1):0]         oID_EX_ALU_Operand_B;              // Operand B to the EX stage 
  
  // LSU
  output                                    oID_EX_LSU_Memory_Write_Enable;    // LSU stage data-memory write enable
  output                                    oID_EX_LSU_Memory_Read_Enable;     // LSU stage data-memory read enable
  output [(`DEF_CP_DATA_WIDTH-1):0]         oID_EX_LSU_Operand_A;              // Operand A to the EX stage for LSU only
  output [(`DEF_CP_DATA_WIDTH-1):0]         oID_EX_LSU_Operand_B;              // Operand B to the EX stage for LSU only
  output [(`RISC24_CP_LSU_OP_WIDTH-1):0]    oID_EX_LSU_Opcode;                 // LSU opcoce: word/half-word/byte
  output [(`DEF_CP_DATA_WIDTH-1):0]         oID_EX_LSU_Store_Data;             // Store data to EX stage (for store instruction only)
  
  // MUL/SHIFT/LOGIC
  output [(`RISC24_CP_MULSHLOG_OP_WIDTH-1):0] oID_EX_MUL_SHIFT_LOGIC_Opcode;   // mul/shift/rotate operation opcode
  output [(`DEF_CP_DATA_WIDTH-1):0]         oID_EX_MUL_SHIFT_LOGIC_Operand_A;  // Operand A to the EX stage for multiplication only
  output [(`DEF_CP_DATA_WIDTH-1):0]         oID_EX_MUL_SHIFT_LOGIC_Operand_B;  // Operand B to the EX stage for multiplication only  
  
  // flag signals
  output                                    oID_EX_Is_Multiplication;
  output                                    oID_EX_Is_Shift;

  // flag/P0/P1
  output                                    oID_EX_Update_Flag;                // if set condition met in compare ins. update flag
  output                                    oID_EX_Update_P0;                  // if set condition met in compare ins. update P0  
  output                                    oID_EX_Update_P1;                  // if set condition met in compare ins. update P1
  
  // pc
  output [(`DEF_CP_I_MEM_ADDR_WIDTH-3):0]   oID_EX_PC;                          // PC followed to EX-stage
  
  
  input  [(`DEF_CP_DATA_WIDTH-1):0]         iRF_BP_Read_Data_B;                 // RF read data from port B
  
  
  // from/to bypass network
  input  [(`DEF_CP_DATA_WIDTH-1):0]         iBP_ID_Operand_A;                   // operand A (after selection) to EX stage
  input  [(`DEF_CP_DATA_WIDTH-1):0]         iBP_ID_Operand_B;                   // operand B (after selection) to EX stage
  
  input  [(`DEF_CP_DATA_WIDTH-1):0]         iBP_ID_LSU_Store_Data;              // store data (for store instruction only)
  output [(`DEF_CP_DATA_WIDTH-1):0]         oID_BP_Immediate;                   // sign-extended (to 32bit) immediate

  output                                    oID_BP_Is_Long_Immediate;           // Flag: indicate the previous ins. is a long-imm ins.
  output [(`DEF_CP_DATA_WIDTH-`DEF_CP_INS_IMM_WIDTH-1):0] oID_BP_Long_Immediate; // long immdediate register
  output                                    oID_BP_Is_SUB;


//******************************
//  Local Wire/Reg Declaration
//******************************
  // predication 
  reg                                     wIns_Valid;                 // current instruction will be executed
  
  reg  [(`RISC24_CP_BRANCHOP_WIDTH-1):0]  wIF_ID_Branch_Op;
  reg  [(`DEF_CP_INS_WIDTH-1):0]          wIF_ID_Instruction;
   
  // to IF-stage  
  wire [(`DEF_CP_I_MEM_ADDR_WIDTH-3):0]   wID_Branch_Target_Addr;     // brach target address, calculated in the ID stage  
  reg                                     rID_Branch_Taken_Flag;      // branch taken flag, generated in the ID stage  
  
  // immediate value
  reg  [(`DEF_CP_DATA_WIDTH-1):0]         wID_Immediate;              // final sign/zero-extended (to data-path width) immediate
  wire [(`DEF_CP_DATA_WIDTH-1):0]         wImm_Zero_Extended;         // zero-extended immediate
  wire [(`DEF_CP_DATA_WIDTH-1):0]         wImm_Sign_Extended;         // sign-extended immediate
  wire [(`DEF_CP_DATA_WIDTH-1):0]         wImm_Default;               // default way to extend immediate
  
  
  // RF write back
  reg  [(`DEF_CP_RF_INDEX_WIDTH-1):0]     rPR_EX_RF_Write_Addr;       // Register file write-back address
  reg  [(`RISC24_CP_RFWBOP_WIDTH-1):0]    wEX_RF_WriteBack;
  reg  [(`RISC24_CP_RFWBOP_WIDTH-1):0]    rPR_EX_RF_WriteBack;        // Register file write-back control. 
                                                                      // Bit 0: register file write enable; Bit 1~2: ALU / LR (Link Register) / LSU / MUL

  wire                                    wWrite_RF_Bypassed;         // RF write is bypassed                 
  wire                                    wWrite_Shadow_Register;     // Write the shadow register (write R31)
  reg                                     rPR_EX_Write_Shadow_Register; // Pipeline register: Write the shadow register (write R31)
  
  wire                                    wNeed_Store_EX_Result;      // EX-stage result needs to be stored in R31 or RF
  wire                                    wWrite_RF_Enable;           // RF write is needed
     
  // LSU
  wire [(`DEF_CP_DATA_WIDTH-1):0]         wEX_LSU_Operand_A;          // Operand A to the EX stage for LSU only
  wire [(`DEF_CP_DATA_WIDTH-1):0]         wEX_LSU_Operand_B;          // Operand B to the EX stage for LSU only
  
  reg                                     wIs_LSU_Write;              // flag: indicate it is a LSU write operation
  reg                                     wIs_LSU_Read;               // flag: indicate it is a LSU read operation
  reg  [(`RISC24_CP_LSU_OP_WIDTH-1):0]    wLSU_Opcode;                // LSU opcoce: word/half-word/byte
  
  
  // MUL/LOGIC/SHIFT
  reg  [(`DEF_CP_DATA_WIDTH-1): 0]        rPR_EX_MUL_SHIFT_LOGIC_Operand_A; // Operand A to the EX stage for multiplication/shift/logic
  reg  [(`DEF_CP_DATA_WIDTH-1): 0]        rPR_EX_MUL_SHIFT_LOGIC_Operand_B; // Operand B to the EX stage for multiplication/shift/logic
  reg                                     wIs_MUL_SHIFT_LOGIC;              // flag: indicate it is a multiplication/shift/logic operation
  reg                                     wIs_Multiplication;
  reg                                     wIs_Shift;
  reg  [(`RISC24_CP_MULSHLOG_OP_WIDTH-1):0] wMUL_SHIFT_LOGIC_Opcode;        // multiplication/shift/logic operation opcode
  reg  [(`RISC24_CP_MULSHLOG_OP_WIDTH-1):0] rPR_EX_MUL_SHIFT_LOGIC_Opcode;  // pipeline register: multiplication/shift/logic operation opcode
  
  
  // ALU
  reg  [(`DEF_CP_DATA_WIDTH-1): 0]        rPR_EX_ALU_Operand_A;       // Operand A to the EX stage
  reg  [(`DEF_CP_DATA_WIDTH-1): 0]        rPR_EX_ALU_Operand_B;       // Operand B to the EX stage
  reg                                     wIs_ALU;                    // flag: indicate it is a ALU operation (not MUL/SHIFT/LOGIC/LSU)
  reg  [(`RISC24_CP_ALU_OP_WIDTH-1):0]    wALU_Opcode;                // ALU operation opcode
  reg  [(`RISC24_CP_ALU_OP_WIDTH-1):0]    rPR_EX_ALU_Opcode;          // pipeline register: ALU operation opcode
  
  
  // flag signals
  reg                                     rPR_EX_Is_Multiplication;
  reg                                     rPR_EX_Is_Shift;
  
  // flag/P0/P1
  reg                                     wID_EX_Update_Flag;         // if set condition met in compare ins. update flag
  reg                                     wID_EX_Update_P0;           // if set condition met in compare ins. update P0
  reg                                     wID_EX_Update_P1;           // if set condition met in compare ins. update P1
  
  reg                                     rPR_EX_Update_Flag;         // if set condition met in compare ins. update flag
  reg                                     rPR_EX_Update_P0;           // if set condition met in compare ins. update P0
  reg                                     rPR_EX_Update_P1;           // if set condition met in compare ins. update P1
  
  
  // pc
  reg  [(`DEF_CP_I_MEM_ADDR_WIDTH-3):0]   rPR_EX_PC;                  // PC followed to EX-stage
  
  
  // Special ins.: SIMM & ZIMM
  wire                                    wIs_SIMM;                   // is sign-extended long immediate
  wire                                    wIs_ZIMM;                   // is zero-extended long immediate
  reg                                     rIs_Long_Imm;               // Flag: indicate the previous ins. is a long-imm ins.
  reg  [(`DEF_CP_DATA_WIDTH-`DEF_CP_INS_IMM_WIDTH-1):0] rLong_Imm;    // long immdediate register
  
  reg                                     rIs_SUB;                    // Is sub inst.
  
  
//******************************
//  Behavioral Description
//******************************

  // Decode predication bits
  always @ ( iIF_ID_Predication or iEX_ID_P0 or iEX_ID_P1 )
    begin
      case ( iIF_ID_Predication )
        2'b00: wIns_Valid = 1'b1;
        2'b01: wIns_Valid = iEX_ID_P0;
        2'b10: wIns_Valid = iEX_ID_P1;
        2'b11: wIns_Valid = iEX_ID_P0 & iEX_ID_P1;
        default: wIns_Valid = 1'b1;
      endcase
    end
  // end of always
  
  // If the instruction is not executed, set it to NOP
  always @ ( wIns_Valid or iIF_ID_Branch_Op or iIF_ID_Instruction )
    begin
      if ( wIns_Valid )
        begin
          wIF_ID_Branch_Op   = iIF_ID_Branch_Op;
          wIF_ID_Instruction = iIF_ID_Instruction;
        end
      else
        begin
          wIF_ID_Branch_Op   = `RISC24_CP_BRANCHOP_NOP;
          wIF_ID_Instruction = 'b0; // if the ins is not executed, set it to NOP 
        end
    end 
  // end of always
  
  
  // if set condition met in compare ins.(checked in EX-stage), update flag/P0/P1
  always @ ( wIF_ID_Instruction[(`DEF_CP_INS_DES_START_BIT+1):`DEF_CP_INS_DES_START_BIT] or wIs_ALU )
    begin
      case ( wIF_ID_Instruction[(`DEF_CP_INS_DES_START_BIT+1):`DEF_CP_INS_DES_START_BIT] )
        2'b00: begin  // update flag register
          wID_EX_Update_Flag = 1'b1 && wIs_ALU;
          wID_EX_Update_P0   = 1'b0;
          wID_EX_Update_P1   = 1'b0;
        end
        2'b01: begin  // update P0 register
          wID_EX_Update_Flag = 1'b0;
          wID_EX_Update_P0   = 1'b1 && wIs_ALU;
          wID_EX_Update_P1   = 1'b0;
        end 
        2'b10: begin  // update P1 register
          wID_EX_Update_Flag = 1'b0;
          wID_EX_Update_P0   = 1'b0;
          wID_EX_Update_P1   = 1'b1 && wIs_ALU;
        end
        default: begin
          wID_EX_Update_Flag = 1'b1 && wIs_ALU;
          wID_EX_Update_P0   = 1'b0;
          wID_EX_Update_P1   = 1'b0;
        end 
      endcase
    end
  // end of always
  
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
          rPR_EX_Update_Flag <= 1'b0;
          rPR_EX_Update_P0   <= 1'b0;
          rPR_EX_Update_P1   <= 1'b0;
        end
    else
      begin
        rPR_EX_Update_Flag <= wID_EX_Update_Flag;
          rPR_EX_Update_P0   <= wID_EX_Update_P0;
          rPR_EX_Update_P1   <= wID_EX_Update_P1;
      end
  // end of always



// *********************
//  1. ID to IF Stage
// *********************
  // ====================================
  // J inst. with offset==0 (self-jump), 
  // indicates program ready! 
  // ====================================
  assign oTask_Finished = ( wIF_ID_Branch_Op == `RISC24_CP_BRANCHOP_J ) && ( wIF_ID_Instruction[(`DEF_CP_BRANCH_OFFSET_WIDTH-1):0] == 'b0 );
  

  // ====================================
  //  branch target address & taken flag
  // ====================================
  assign wID_Branch_Target_Addr = ( wIF_ID_Branch_Op == `RISC24_CP_BRANCHOP_JR ) || ( wIF_ID_Branch_Op == `RISC24_CP_BRANCHOP_JALR ) ? iBP_ID_Operand_B[(`DEF_CP_I_MEM_ADDR_WIDTH-1):2] : 
  { {(`DEF_CP_I_MEM_ADDR_WIDTH-2-`DEF_CP_BRANCH_OFFSET_WIDTH){wIF_ID_Instruction[`DEF_CP_BRANCH_OFFSET_WIDTH-1]} }, wIF_ID_Instruction[(`DEF_CP_BRANCH_OFFSET_WIDTH-1):0] } + iIF_ID_PC;

  always @( iEX_ID_Flag_Register or wIF_ID_Branch_Op ) 
    begin
        casex ( wIF_ID_Branch_Op )   
          `RISC24_CP_BRANCHOP_NOP:                        // NOP
             rID_Branch_Taken_Flag = 1'b0;
             
          `RISC24_CP_BRANCHOP_J, `RISC24_CP_BRANCHOP_JAL:    // J/JAL
             rID_Branch_Taken_Flag = 1'b1;
             
          `RISC24_CP_BRANCHOP_JR, `RISC24_CP_BRANCHOP_JALR:  // JR/JALR
             rID_Branch_Taken_Flag = 1'b1;
          
          `RISC24_CP_BRANCHOP_BF: begin                   // BF
            if ( iEX_ID_Flag_Register ) 
               rID_Branch_Taken_Flag = 1'b1;
            else
               rID_Branch_Taken_Flag = 1'b0;
          end
          
          `RISC24_CP_BRANCHOP_BNF: begin                  // BNF
            if ( iEX_ID_Flag_Register )
               rID_Branch_Taken_Flag = 1'b0;
            else
               rID_Branch_Taken_Flag = 1'b1;
          end

          default: 
            rID_Branch_Taken_Flag = 1'b0;
        endcase
    end
  // end of always
  
  
  
// ********************
//  2. ID to EX Stage
// ********************
  // ====================================
  //  Decode using a big "always block"
  // ====================================  
  assign wWrite_RF_Bypassed     = ~( |wIF_ID_Instruction[`DEF_CP_INS_DES_END_BIT:`DEF_CP_INS_DES_START_BIT] );  // write R0
  assign wWrite_Shadow_Register =  ( &wIF_ID_Instruction[`DEF_CP_INS_DES_END_BIT:`DEF_CP_INS_DES_START_BIT] );  // write R31
  
  assign wImm_Zero_Extended = { {(`DEF_CP_DATA_WIDTH-`DEF_CP_INS_IMM_WIDTH){1'b0} },                                     wIF_ID_Instruction[`DEF_CP_INS_IMM_END_BIT:`DEF_CP_INS_IMM_START_BIT]};
  assign wImm_Sign_Extended = { {(`DEF_CP_DATA_WIDTH-`DEF_CP_INS_IMM_WIDTH){wIF_ID_Instruction[`DEF_CP_INS_IMM_END_BIT]} }, wIF_ID_Instruction[`DEF_CP_INS_IMM_END_BIT:`DEF_CP_INS_IMM_START_BIT]};
  
  assign wImm_Default = wImm_Sign_Extended;
  
  
  always @ ( wIF_ID_Instruction or wImm_Zero_Extended or wImm_Sign_Extended or wImm_Default )
    begin
      rIs_SUB <= 1'b0;
      
      case ( wIF_ID_Instruction[`DEF_CP_INS_OPCODE_END_BIT:`DEF_CP_INS_OPCODE_START_BIT] ) 
        // J-type, SIMM, ZIMM
        `RISC24_CP_OP_NOP1, `RISC24_CP_OP_NOP2:
          begin
            // immediate selection
            wID_Immediate    = wImm_Default;
            
            // RF write-back control                                                                 // JAL/JALR: 3'b1?1
            wEX_RF_WriteBack = ( (wIF_ID_Instruction[`DEF_CP_INS_TYPE_BIT] == `DEF_CP_INS_IS_R_TYPE) && wIF_ID_Instruction[`DEF_CP_INS_WIDTH-6] && wIF_ID_Instruction[`DEF_CP_INS_WIDTH-8] ) ? 
                               {`RISC24_CP_RFWBOP_LR, 1'b1} : `RISC24_CP_RFWBOP_NOP;
            
            // ALU
            wIs_ALU     = 1'b0;
            wALU_Opcode = `RISC24_CP_ALU_OP_NOP;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b0;
            wIs_MUL_SHIFT_LOGIC     = 1'b0;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_CP_MULSHLOG_OP_NOP;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_CP_LSU_OP_NOP;
          end
        `RISC24_CP_OP_ADD:
          begin
            // immediate selection
            wID_Immediate    = wImm_Sign_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = {`RISC24_CP_RFWBOP_ALU, 1'b1};
            
            // ALU
            wIs_ALU     = 1'b1;
            wALU_Opcode = `RISC24_CP_ALU_OP_ADD;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b0;
            wIs_MUL_SHIFT_LOGIC     = 1'b0;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_CP_MULSHLOG_OP_NOP;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_CP_LSU_OP_NOP;
          end
        `RISC24_CP_OP_SUB:
          begin
            rIs_SUB <= 1'b1;
            
            // immediate selection
            wID_Immediate    = wImm_Sign_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = {`RISC24_CP_RFWBOP_ALU, 1'b1};
            
            // ALU
            wIs_ALU     = 1'b1;
            wALU_Opcode = `RISC24_CP_ALU_OP_SUB;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b0;
            wIs_MUL_SHIFT_LOGIC     = 1'b0;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_CP_MULSHLOG_OP_NOP;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_CP_LSU_OP_NOP;
          end  
        `RISC24_CP_OP_MUL:
          begin
            // immediate selection
            wID_Immediate    = wImm_Sign_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = {`RISC24_CP_RFWBOP_MUL, 1'b1};
            
            // ALU
            wIs_ALU     = 1'b0;
            wALU_Opcode = `RISC24_CP_ALU_OP_NOP;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b1;
            wIs_Shift               = 1'b0;
            wIs_MUL_SHIFT_LOGIC     = 1'b1;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_CP_MULSHLOG_OP_MUL;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_CP_LSU_OP_NOP;
          end  
        `RISC24_CP_OP_MULU:
          begin
            // immediate selection
            wID_Immediate    = wImm_Zero_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = {`RISC24_CP_RFWBOP_MUL, 1'b1};
            
            // ALU
            wIs_ALU     = 1'b0;
            wALU_Opcode = `RISC24_CP_ALU_OP_NOP;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b1;
            wIs_Shift               = 1'b0;
            wIs_MUL_SHIFT_LOGIC     = 1'b1;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_CP_MULSHLOG_OP_MUL;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_CP_LSU_OP_NOP;
          end  
        `RISC24_CP_OP_OR:
          begin
            // immediate selection
            wID_Immediate    = wImm_Zero_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = {`RISC24_CP_RFWBOP_MUL, 1'b1};
            
            // ALU
            wIs_ALU     = 1'b0;
            wALU_Opcode = `RISC24_CP_ALU_OP_NOP;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b0;
            wIs_MUL_SHIFT_LOGIC     = 1'b1;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_CP_MULSHLOG_OP_OR;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_CP_LSU_OP_NOP;
          end
        `RISC24_CP_OP_AND:
          begin
            // immediate selection
            wID_Immediate    = wImm_Zero_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = {`RISC24_CP_RFWBOP_MUL, 1'b1};
            
            // ALU
            wIs_ALU     = 1'b0;
            wALU_Opcode = `RISC24_CP_ALU_OP_NOP;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b0;
            wIs_MUL_SHIFT_LOGIC     = 1'b1;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_CP_MULSHLOG_OP_AND;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_CP_LSU_OP_NOP;
          end  
        `RISC24_CP_OP_XOR:
          begin
            // immediate selection
            wID_Immediate    = wImm_Sign_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = {`RISC24_CP_RFWBOP_MUL, 1'b1};
            
            // ALU
            wIs_ALU     = 1'b0;
            wALU_Opcode = `RISC24_CP_ALU_OP_NOP;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b0;
            wIs_MUL_SHIFT_LOGIC     = 1'b1;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_CP_MULSHLOG_OP_XOR;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_CP_LSU_OP_NOP;
          end  
        `RISC24_CP_OP_CMOV:
          begin
            // immediate selection
            wID_Immediate    = wImm_Sign_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = {`RISC24_CP_RFWBOP_ALU, 1'b1};
            
            // ALU
            wIs_ALU     = 1'b1;
            wALU_Opcode = `RISC24_CP_ALU_OP_CMOV;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b0;
            wIs_MUL_SHIFT_LOGIC     = 1'b0;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_CP_MULSHLOG_OP_NOP;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_CP_LSU_OP_NOP;
          end  
        `RISC24_CP_OP_EQ:
          begin
            // immediate selection
            wID_Immediate    = wImm_Sign_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = `RISC24_CP_RFWBOP_NOP;
            
            // ALU
            wIs_ALU     = 1'b1;
            wALU_Opcode = `RISC24_CP_ALU_OP_EQ;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b0;
            wIs_MUL_SHIFT_LOGIC     = 1'b0;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_CP_MULSHLOG_OP_NOP;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_CP_LSU_OP_NOP;
          end  
        `RISC24_CP_OP_NE:
          begin
            // immediate selection
            wID_Immediate    = wImm_Sign_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = `RISC24_CP_RFWBOP_NOP;
            
            // ALU
            wIs_ALU     = 1'b1;
            wALU_Opcode = `RISC24_CP_ALU_OP_NEQ;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b0;
            wIs_MUL_SHIFT_LOGIC     = 1'b0;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_CP_MULSHLOG_OP_NOP;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_CP_LSU_OP_NOP;
          end  
        `RISC24_CP_OP_LE:
          begin
            // immediate selection
            wID_Immediate    = wImm_Sign_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = `RISC24_CP_RFWBOP_NOP;
            
            // ALU
            wIs_ALU     = 1'b1;
            wALU_Opcode = `RISC24_CP_ALU_OP_LE;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b0;
            wIs_MUL_SHIFT_LOGIC     = 1'b0;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_CP_MULSHLOG_OP_NOP;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_CP_LSU_OP_NOP;
          end  
        `RISC24_CP_OP_LT:
          begin
            // immediate selection
            wID_Immediate    = wImm_Sign_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = `RISC24_CP_RFWBOP_NOP;
            
            // ALU
            wIs_ALU     = 1'b1;
            wALU_Opcode = `RISC24_CP_ALU_OP_LT;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b0;
            wIs_MUL_SHIFT_LOGIC     = 1'b0;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_CP_MULSHLOG_OP_NOP;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_CP_LSU_OP_NOP;
          end  
        `RISC24_CP_OP_GE:
          begin
            // immediate selection
            wID_Immediate    = wImm_Sign_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = `RISC24_CP_RFWBOP_NOP;
            
            // ALU
            wIs_ALU     = 1'b1;
            wALU_Opcode = `RISC24_CP_ALU_OP_GE;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b0;
            wIs_MUL_SHIFT_LOGIC     = 1'b0;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_CP_MULSHLOG_OP_NOP;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_CP_LSU_OP_NOP;
          end  
        `RISC24_CP_OP_GT:
          begin
            // immediate selection
            wID_Immediate    = wImm_Sign_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = `RISC24_CP_RFWBOP_NOP;
            
            // ALU
            wIs_ALU     = 1'b1;
            wALU_Opcode = `RISC24_CP_ALU_OP_GT;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b0;
            wIs_MUL_SHIFT_LOGIC     = 1'b0;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_CP_MULSHLOG_OP_NOP;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_CP_LSU_OP_NOP;
          end  
        `RISC24_CP_OP_LEU:
          begin
            // immediate selection
            wID_Immediate    = wImm_Sign_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = `RISC24_CP_RFWBOP_NOP;
            
            // ALU
            wIs_ALU     = 1'b1;
            wALU_Opcode = `RISC24_CP_ALU_OP_LEU;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b0;
            wIs_MUL_SHIFT_LOGIC     = 1'b0;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_CP_MULSHLOG_OP_NOP;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_CP_LSU_OP_NOP;
          end  
        `RISC24_CP_OP_LTU:
          begin
            // immediate selection
            wID_Immediate    = wImm_Sign_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = `RISC24_CP_RFWBOP_NOP;
            
            // ALU
            wIs_ALU     = 1'b1;
            wALU_Opcode = `RISC24_CP_ALU_OP_LTU;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b0;
            wIs_MUL_SHIFT_LOGIC     = 1'b0;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_CP_MULSHLOG_OP_NOP;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_CP_LSU_OP_NOP;
          end      
        `RISC24_CP_OP_GEU:
          begin
            // immediate selection
            wID_Immediate    = wImm_Sign_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = `RISC24_CP_RFWBOP_NOP;
            
            // ALU
            wIs_ALU     = 1'b1;
            wALU_Opcode = `RISC24_CP_ALU_OP_GEU;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b0;
            wIs_MUL_SHIFT_LOGIC     = 1'b0;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_CP_MULSHLOG_OP_NOP;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_CP_LSU_OP_NOP;
          end
        `RISC24_CP_OP_GTU:
          begin
            // immediate selection
            wID_Immediate    = wImm_Sign_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = `RISC24_CP_RFWBOP_NOP;
            
            // ALU
            wIs_ALU     = 1'b1;
            wALU_Opcode = `RISC24_CP_ALU_OP_GTU;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b0;
            wIs_MUL_SHIFT_LOGIC     = 1'b0;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_CP_MULSHLOG_OP_NOP;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_CP_LSU_OP_NOP;
          end
        `RISC24_CP_OP_SLL:
          begin
            // immediate selection
            wID_Immediate    = wImm_Sign_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = {`RISC24_CP_RFWBOP_MUL, 1'b1};
            
            // ALU
            wIs_ALU     = 1'b0;
            wALU_Opcode = `RISC24_CP_ALU_OP_NOP;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b1;
            wIs_MUL_SHIFT_LOGIC     = 1'b1;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_CP_MULSHLOG_OP_SLL;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_CP_LSU_OP_NOP;
          end
        `RISC24_CP_OP_SRA:
          begin
            // immediate selection
            wID_Immediate    = wImm_Sign_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = {`RISC24_CP_RFWBOP_MUL, 1'b1};
            
            // ALU
            wIs_ALU     = 1'b0;
            wALU_Opcode = `RISC24_CP_ALU_OP_NOP;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b1;
            wIs_MUL_SHIFT_LOGIC     = 1'b1;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_CP_MULSHLOG_OP_SRA;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_CP_LSU_OP_NOP;
          end
        `RISC24_CP_OP_SRL:
          begin
            // immediate selection
            wID_Immediate    = wImm_Sign_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = {`RISC24_CP_RFWBOP_MUL, 1'b1};
            
            // ALU
            wIs_ALU     = 1'b0;
            wALU_Opcode = `RISC24_CP_ALU_OP_NOP;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b1;
            wIs_MUL_SHIFT_LOGIC     = 1'b1;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_CP_MULSHLOG_OP_SRL;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_CP_LSU_OP_NOP;
          end
        `RISC24_CP_OP_ROR:
          begin
            // immediate selection
            wID_Immediate    = wImm_Sign_Extended;
            
            // RF write-back control
            wEX_RF_WriteBack = {`RISC24_CP_RFWBOP_MUL, 1'b1};
            
            // ALU
            wIs_ALU     = 1'b0;
            wALU_Opcode = `RISC24_CP_ALU_OP_NOP;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b1;
            wIs_MUL_SHIFT_LOGIC     = 1'b1;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_CP_MULSHLOG_OP_ROR;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_CP_LSU_OP_NOP;
          end
        `RISC24_CP_OP_LWZ:
          begin
            if ( wIF_ID_Instruction[`DEF_CP_INS_TYPE_BIT] == `DEF_CP_INS_IS_R_TYPE )
              begin
                // immediate selection
                wID_Immediate    = wImm_Default;
                
                // RF write-back control
                wEX_RF_WriteBack = `RISC24_CP_RFWBOP_NOP;
                
                // ALU
                wIs_ALU     = 1'b0;
                wALU_Opcode = `RISC24_CP_ALU_OP_NOP;
                
                // MUL/SHIFT/LOGIC
                wIs_Multiplication      = 1'b0;
                wIs_Shift               = 1'b0;
                wIs_MUL_SHIFT_LOGIC     = 1'b0;
                wMUL_SHIFT_LOGIC_Opcode = `RISC24_CP_MULSHLOG_OP_NOP;
                
                // LSU
                wIs_LSU_Read  = 1'b0;
                wIs_LSU_Write = 1'b0;
                wLSU_Opcode   = `RISC24_CP_LSU_OP_NOP;
              end
            else
              begin
                // immediate selection
                wID_Immediate    = { {(`DEF_CP_DATA_WIDTH-`DEF_CP_INS_IMM_WIDTH-2){wIF_ID_Instruction[`DEF_CP_INS_IMM_END_BIT]} }, wIF_ID_Instruction[`DEF_CP_INS_IMM_END_BIT:`DEF_CP_INS_IMM_START_BIT], 2'b00};
                
                // RF write-back control
                wEX_RF_WriteBack = {`RISC24_CP_RFWBOP_LSU, 1'b1};
                
                // ALU
                wIs_ALU     = 1'b0;
                wALU_Opcode = `RISC24_CP_ALU_OP_NOP;
                
                // MUL/SHIFT/LOGIC
                wIs_Multiplication      = 1'b0;
                wIs_Shift               = 1'b0;
                wIs_MUL_SHIFT_LOGIC     = 1'b0;
                wMUL_SHIFT_LOGIC_Opcode = `RISC24_CP_MULSHLOG_OP_NOP;
                
                // LSU
                wIs_LSU_Read  = 1'b1;
                wIs_LSU_Write = 1'b0;
                wLSU_Opcode   = `RISC24_CP_LSU_OP_WORD;
              end
          end
        `RISC24_CP_OP_LBZ:
          begin
            if ( wIF_ID_Instruction[`DEF_CP_INS_TYPE_BIT] == `DEF_CP_INS_IS_R_TYPE )
              begin
                // immediate selection
                wID_Immediate    = wImm_Default;
                
                // RF write-back control
                wEX_RF_WriteBack = `RISC24_CP_RFWBOP_NOP;
                
                // ALU
                wIs_ALU     = 1'b0;
                wALU_Opcode = `RISC24_CP_ALU_OP_NOP;
                
                // MUL/SHIFT/LOGIC
                wIs_Multiplication      = 1'b0;
                wIs_Shift               = 1'b0;
                wIs_MUL_SHIFT_LOGIC     = 1'b0;
                wMUL_SHIFT_LOGIC_Opcode = `RISC24_CP_MULSHLOG_OP_NOP;
                
                // LSU
                wIs_LSU_Read  = 1'b0;
                wIs_LSU_Write = 1'b0;
                wLSU_Opcode   = `RISC24_CP_LSU_OP_NOP;
              end
            else
              begin
                // immediate selection
                wID_Immediate    = { {(`DEF_CP_DATA_WIDTH-`DEF_CP_INS_IMM_WIDTH-0){wIF_ID_Instruction[`DEF_CP_INS_IMM_END_BIT]} }, wIF_ID_Instruction[`DEF_CP_INS_IMM_END_BIT:`DEF_CP_INS_IMM_START_BIT]};
                
                // RF write-back control
                wEX_RF_WriteBack = {`RISC24_CP_RFWBOP_LSU, 1'b1};
                
                // ALU
                wIs_ALU     = 1'b0;
                wALU_Opcode = `RISC24_CP_ALU_OP_NOP;
                
                // MUL/SHIFT/LOGIC
                wIs_Multiplication      = 1'b0;
                wIs_Shift               = 1'b0;
                wIs_MUL_SHIFT_LOGIC     = 1'b0;
                wMUL_SHIFT_LOGIC_Opcode = `RISC24_CP_MULSHLOG_OP_NOP;
                
                // LSU
                wIs_LSU_Read  = 1'b1;
                wIs_LSU_Write = 1'b0;
                wLSU_Opcode   = `RISC24_CP_LSU_OP_BYTE;
              end
          end
        `RISC24_CP_OP_LHZ:
          begin
            if ( wIF_ID_Instruction[`DEF_CP_INS_TYPE_BIT] == `DEF_CP_INS_IS_R_TYPE )
              begin
                // immediate selection
                wID_Immediate    = wImm_Default;
                
                // RF write-back control
                wEX_RF_WriteBack = `RISC24_CP_RFWBOP_NOP;
                
                // ALU
                wIs_ALU     = 1'b0;
                wALU_Opcode = `RISC24_CP_ALU_OP_NOP;
                
                // MUL/SHIFT/LOGIC
                wIs_Multiplication      = 1'b0;
                wIs_Shift               = 1'b0;
                wIs_MUL_SHIFT_LOGIC     = 1'b0;
                wMUL_SHIFT_LOGIC_Opcode = `RISC24_CP_MULSHLOG_OP_NOP;
                
                // LSU
                wIs_LSU_Read  = 1'b0;
                wIs_LSU_Write = 1'b0;
                wLSU_Opcode   = `RISC24_CP_LSU_OP_NOP;
              end
            else
              begin
                // immediate selection
                wID_Immediate    = { {(`DEF_CP_DATA_WIDTH-`DEF_CP_INS_IMM_WIDTH-1){wIF_ID_Instruction[`DEF_CP_INS_IMM_END_BIT]} }, wIF_ID_Instruction[`DEF_CP_INS_IMM_END_BIT:`DEF_CP_INS_IMM_START_BIT], 1'b0};
                
                // RF write-back control
                wEX_RF_WriteBack = {`RISC24_CP_RFWBOP_LSU, 1'b1};
                
                // ALU
                wIs_ALU     = 1'b0;
                wALU_Opcode = `RISC24_CP_ALU_OP_NOP;
                
                // MUL/SHIFT/LOGIC
                wIs_Multiplication      = 1'b0;
                wIs_Shift               = 1'b0;
                wIs_MUL_SHIFT_LOGIC     = 1'b0;
                wMUL_SHIFT_LOGIC_Opcode = `RISC24_CP_MULSHLOG_OP_NOP;
                
                // LSU
                wIs_LSU_Read  = 1'b1;
                wIs_LSU_Write = 1'b0;
                wLSU_Opcode   = `RISC24_CP_LSU_OP_HALF_WORD;
              end
          end
        `RISC24_CP_OP_SW:
          begin
            if ( wIF_ID_Instruction[`DEF_CP_INS_TYPE_BIT] == `DEF_CP_INS_IS_R_TYPE )
              begin
                // immediate selection
                wID_Immediate    = wImm_Default;
                
                // RF write-back control
                wEX_RF_WriteBack = `RISC24_CP_RFWBOP_NOP;
                
                // ALU
                wIs_ALU     = 1'b0;
                wALU_Opcode = `RISC24_CP_ALU_OP_NOP;
                
                // MUL/SHIFT/LOGIC
                wIs_Multiplication      = 1'b0;
                wIs_Shift               = 1'b0;
                wIs_MUL_SHIFT_LOGIC     = 1'b0;
                wMUL_SHIFT_LOGIC_Opcode = `RISC24_CP_MULSHLOG_OP_NOP;
                
                // LSU
                wIs_LSU_Read  = 1'b0;
                wIs_LSU_Write = 1'b0;
                wLSU_Opcode   = `RISC24_CP_LSU_OP_NOP;
              end
            else
              begin
                // immediate selection
                wID_Immediate    = { {(`DEF_CP_DATA_WIDTH-`DEF_CP_INS_IMM_WIDTH-2){wIF_ID_Instruction[`DEF_CP_INS_DES_END_BIT]} }, {wIF_ID_Instruction[`DEF_CP_INS_DES_END_BIT:`DEF_CP_INS_DES_START_BIT], wIF_ID_Instruction[(`DEF_CP_INS_SRC2_START_BIT-1):`DEF_CP_INS_IMM_START_BIT]}, 2'b00};
                
                // RF write-back control
                wEX_RF_WriteBack = `RISC24_CP_RFWBOP_NOP;
                
                // ALU
                wIs_ALU     = 1'b0;
                wALU_Opcode = `RISC24_CP_ALU_OP_NOP;
                
                // MUL/SHIFT/LOGIC
                wIs_Multiplication      = 1'b0;
                wIs_Shift               = 1'b0;
                wIs_MUL_SHIFT_LOGIC     = 1'b0;
                wMUL_SHIFT_LOGIC_Opcode = `RISC24_CP_MULSHLOG_OP_NOP;
                
                // LSU
                wIs_LSU_Read  = 1'b0;
                wIs_LSU_Write = 1'b1;
                wLSU_Opcode   = `RISC24_CP_LSU_OP_WORD;
              end
          end
        `RISC24_CP_OP_SB:
          begin
            if ( wIF_ID_Instruction[`DEF_CP_INS_TYPE_BIT] == `DEF_CP_INS_IS_R_TYPE )
              begin
                // immediate selection
                wID_Immediate    = wImm_Default;
                
                // RF write-back control
                wEX_RF_WriteBack = `RISC24_CP_RFWBOP_NOP;
                
                // ALU
                wIs_ALU     = 1'b0;
                wALU_Opcode = `RISC24_CP_ALU_OP_NOP;
                
                // MUL/SHIFT/LOGIC
                wIs_Multiplication      = 1'b0;
                wIs_Shift               = 1'b0;
                wIs_MUL_SHIFT_LOGIC     = 1'b0;
                wMUL_SHIFT_LOGIC_Opcode = `RISC24_CP_MULSHLOG_OP_NOP;
                
                // LSU
                wIs_LSU_Read  = 1'b0;
                wIs_LSU_Write = 1'b0;
                wLSU_Opcode   = `RISC24_CP_LSU_OP_NOP;
              end
            else
              begin
                // immediate selection
                wID_Immediate    = { {(`DEF_CP_DATA_WIDTH-`DEF_CP_INS_IMM_WIDTH-0){wIF_ID_Instruction[`DEF_CP_INS_DES_END_BIT]} }, {wIF_ID_Instruction[`DEF_CP_INS_DES_END_BIT:`DEF_CP_INS_DES_START_BIT], wIF_ID_Instruction[(`DEF_CP_INS_SRC2_START_BIT-1):`DEF_CP_INS_IMM_START_BIT]} };
                
                // RF write-back control
                wEX_RF_WriteBack = `RISC24_CP_RFWBOP_NOP;
                
                // ALU
                wIs_ALU     = 1'b0;
                wALU_Opcode = `RISC24_CP_ALU_OP_NOP;
                
                // MUL/SHIFT/LOGIC
                wIs_Multiplication      = 1'b0;
                wIs_Shift               = 1'b0;
                wIs_MUL_SHIFT_LOGIC     = 1'b0;
                wMUL_SHIFT_LOGIC_Opcode = `RISC24_CP_MULSHLOG_OP_NOP;
                
                // LSU
                wIs_LSU_Read  = 1'b0;
                wIs_LSU_Write = 1'b1;
                wLSU_Opcode   = `RISC24_CP_LSU_OP_BYTE;
              end
          end
        `RISC24_CP_OP_SH:
          begin
            if ( wIF_ID_Instruction[`DEF_CP_INS_TYPE_BIT] == `DEF_CP_INS_IS_R_TYPE )
              begin
                // immediate selection
                wID_Immediate    = wImm_Default;
                
                // RF write-back control
                wEX_RF_WriteBack = `RISC24_CP_RFWBOP_NOP;
                
                // ALU
                wIs_ALU     = 1'b0;
                wALU_Opcode = `RISC24_CP_ALU_OP_NOP;
                
                // MUL/SHIFT/LOGIC
                wIs_Multiplication      = 1'b0;
                wIs_Shift               = 1'b0;
                wIs_MUL_SHIFT_LOGIC     = 1'b0;
                wMUL_SHIFT_LOGIC_Opcode = `RISC24_CP_MULSHLOG_OP_NOP;
                
                // LSU
                wIs_LSU_Read  = 1'b0;
                wIs_LSU_Write = 1'b0;
                wLSU_Opcode   = `RISC24_CP_LSU_OP_NOP;
              end
            else
              begin
                // immediate selection
                wID_Immediate    = { {(`DEF_CP_DATA_WIDTH-`DEF_CP_INS_IMM_WIDTH-1){wIF_ID_Instruction[`DEF_CP_INS_DES_END_BIT]} }, {wIF_ID_Instruction[`DEF_CP_INS_DES_END_BIT:`DEF_CP_INS_DES_START_BIT], wIF_ID_Instruction[(`DEF_CP_INS_SRC2_START_BIT-1):`DEF_CP_INS_IMM_START_BIT]}, 1'b0};
                
                // RF write-back control
                wEX_RF_WriteBack = `RISC24_CP_RFWBOP_NOP;
                
                // ALU
                wIs_ALU     = 1'b0;
                wALU_Opcode = `RISC24_CP_ALU_OP_NOP;
                
                // MUL/SHIFT/LOGIC
                wIs_Multiplication      = 1'b0;
                wIs_Shift               = 1'b0;
                wIs_MUL_SHIFT_LOGIC     = 1'b0;
                wMUL_SHIFT_LOGIC_Opcode = `RISC24_CP_MULSHLOG_OP_NOP;
                
                // LSU
                wIs_LSU_Read  = 1'b0;
                wIs_LSU_Write = 1'b1;
                wLSU_Opcode   = `RISC24_CP_LSU_OP_HALF_WORD;
              end
          end  
          
      default:
          begin
              // immediate selection
            wID_Immediate    = wImm_Default;
            
            // RF write-back control
            wEX_RF_WriteBack = `RISC24_CP_RFWBOP_NOP;
            
            // ALU
            wIs_ALU     = 1'b0;
            wALU_Opcode = `RISC24_CP_ALU_OP_NOP;
            
            // MUL/SHIFT/LOGIC
            wIs_Multiplication      = 1'b0;
            wIs_Shift               = 1'b0;
            wIs_MUL_SHIFT_LOGIC     = 1'b0;
            wMUL_SHIFT_LOGIC_Opcode = `RISC24_CP_MULSHLOG_OP_NOP;
            
            // LSU
            wIs_LSU_Read  = 1'b0;
            wIs_LSU_Write = 1'b0;
            wLSU_Opcode   = `RISC24_CP_LSU_OP_NOP;
          end
      endcase
    end
  // end of always



  // Pipeline Registers: flag signals
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
          rPR_EX_Is_Multiplication  <= 'b0;
          rPR_EX_Is_Shift           <= 'b0;
          //rPR_EX_Is_MUL_SHIFT_LOGIC <= 'b0;
          //rPR_WX_Is_ALU             <= 'b0;
          //rPR_EX_Is_LSU             <= 'b0;
        end
    else if ( wIs_MUL_SHIFT_LOGIC )
      begin
          rPR_EX_Is_Multiplication  <= wIs_Multiplication;
          rPR_EX_Is_Shift           <= wIs_Shift;
          //rPR_EX_Is_MUL_SHIFT_LOGIC <= wIs_MUL_SHIFT_LOGIC;
          //rPR_WX_Is_ALU             <= wIs_ALU;
          //rPR_EX_Is_LSU             <= wSelect_LSU;
        end
  // end of always


  // =============================================
  //  Register file write address and enable
  //  (RF index here can be clock-gated)
  // =============================================
  // instruction with write RF enable, and not write R0 or R31
  assign wNeed_Store_EX_Result = wEX_RF_WriteBack[0]   && (~wWrite_RF_Bypassed); 
  assign wWrite_RF_Enable      = wNeed_Store_EX_Result && (~wWrite_Shadow_Register);
   
  
  // RF write address
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      rPR_EX_RF_Write_Addr <= 'b0;
    else
      begin
        if ( (wIF_ID_Branch_Op == `RISC24_CP_BRANCHOP_JAL) || (wIF_ID_Branch_Op == `RISC24_CP_BRANCHOP_JALR) ) // JAL/JALR
          rPR_EX_RF_Write_Addr <= `DEF_CP_LINK_REGISTER_INDEX; // link register r9
        else if ( wWrite_RF_Enable )  // other ins. with RF write-back 
          rPR_EX_RF_Write_Addr <= wIF_ID_Instruction[`DEF_CP_INS_DES_END_BIT:`DEF_CP_INS_DES_START_BIT];  // Rd
        end
  // end of always

  // RF write-back enable signal
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      rPR_EX_RF_WriteBack[0] <= 'b0;
    else
      rPR_EX_RF_WriteBack[0] <= wWrite_RF_Enable;
  // end of always

  // RF src-data selection
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      rPR_EX_RF_WriteBack[(`RISC24_CP_RFWBOP_WIDTH-1):1] <= 'b0;
    else if ( wNeed_Store_EX_Result ) // write RF enable, and NOT write R0
      rPR_EX_RF_WriteBack[(`RISC24_CP_RFWBOP_WIDTH-1):1] <= wEX_RF_WriteBack[(`RISC24_CP_RFWBOP_WIDTH-1):1];
  // end of always
  
  
  // Shadow register (R31) write enable signal
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
        rPR_EX_Write_Shadow_Register <= 'b0;
    else
      rPR_EX_Write_Shadow_Register <= wNeed_Store_EX_Result;
  // end of always
  
  
  // =============================
  //  FU1: Decode LSU Operations
  // =============================
  assign wEX_LSU_Operand_A = (wIs_LSU_Read || wIs_LSU_Write) ? iBP_ID_Operand_A : 'b0;
  assign wEX_LSU_Operand_B = (wIs_LSU_Read || wIs_LSU_Write) ? iBP_ID_Operand_B : 'b0;



  // ==============================
  //  FU2: Decode Operations
  // ==============================
  // MUL/SHIFT/LOGIC operands  
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
          rPR_EX_MUL_SHIFT_LOGIC_Operand_A <= 'b0;
          rPR_EX_MUL_SHIFT_LOGIC_Operand_B <= 'b0;
          rPR_EX_MUL_SHIFT_LOGIC_Opcode    <= `RISC24_CP_MULSHLOG_OP_NOP;
        end
    else if ( wIs_MUL_SHIFT_LOGIC )
      begin
        rPR_EX_MUL_SHIFT_LOGIC_Operand_A <= iBP_ID_Operand_A;
          rPR_EX_MUL_SHIFT_LOGIC_Operand_B <= iBP_ID_Operand_B;
          rPR_EX_MUL_SHIFT_LOGIC_Opcode    <= wMUL_SHIFT_LOGIC_Opcode;
      end
  // end of always


  // ============================
  //  FU3: ALU (add/sub/cmp)
  // ============================
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
          rPR_EX_ALU_Operand_A <= 'b0;
          rPR_EX_ALU_Operand_B <= 'b0;
          rPR_EX_ALU_Opcode    <= `RISC24_CP_ALU_OP_NOP;
        end
    else if ( wIs_ALU )
      begin
        rPR_EX_ALU_Operand_A <= iBP_ID_Operand_A;
          rPR_EX_ALU_Operand_B <= iBP_ID_Operand_B;
          rPR_EX_ALU_Opcode    <= wALU_Opcode;
      end
  // end of always
  
  

  // ============================
  //  PC to the EX stage
  // ============================
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )  
      rPR_EX_PC <= 'b0;
    else if ( wEX_RF_WriteBack[(`RISC24_CP_RFWBOP_WIDTH-1):1] == `RISC24_CP_RFWBOP_LR )   // update the link-register, only used when JAL/JALR
      rPR_EX_PC <= iIF_ID_PC;
  // end of always  
  


  // ====================================
  //  Handle the special "SIMM/ZIMM"
  // ==================================== 
  assign wIs_SIMM = ( (wIF_ID_Instruction[`DEF_CP_INS_TYPE_BIT] == `DEF_CP_INS_IS_I_TYPE) && (wIF_ID_Instruction[`DEF_CP_INS_OPCODE_END_BIT:`DEF_CP_INS_OPCODE_START_BIT] == `RISC24_CP_OP_NOP1) );
  assign wIs_ZIMM = ( (wIF_ID_Instruction[`DEF_CP_INS_TYPE_BIT] == `DEF_CP_INS_IS_I_TYPE) && (wIF_ID_Instruction[`DEF_CP_INS_OPCODE_END_BIT:`DEF_CP_INS_OPCODE_START_BIT] == `RISC24_CP_OP_NOP2) );
  
  
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )  
      rLong_Imm <= 'b0;
    else if ( wIs_SIMM )  // 32 - 18 - 8
      rLong_Imm <= { {(`DEF_CP_DATA_WIDTH-`DEF_CP_INS_LONGIMM_WIDTH-`DEF_CP_INS_IMM_WIDTH){wIF_ID_Instruction[`DEF_CP_INS_LONGIMM_END_BIT]} }, wIF_ID_Instruction[`DEF_CP_INS_LONGIMM_END_BIT:`DEF_CP_INS_LONGIMM_START_BIT]};
    else if ( wIs_ZIMM )
      rLong_Imm <= { {(`DEF_CP_DATA_WIDTH-`DEF_CP_INS_LONGIMM_WIDTH-`DEF_CP_INS_IMM_WIDTH){1'b0} }, wIF_ID_Instruction[`DEF_CP_INS_LONGIMM_END_BIT:`DEF_CP_INS_LONGIMM_START_BIT]};
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
  //  to IF stage
  // --------------
  assign oID_IF_Branch_Target_Addr      = wID_Branch_Target_Addr;
  assign oID_IF_Branch_Taken_Flag       = rID_Branch_Taken_Flag;
 
  // --------------
  //  to EX stage 
  // --------------
  // RF write-back
  assign oID_EX_RF_WriteBack            = rPR_EX_RF_WriteBack;      
  assign oID_EX_RF_Write_Addr           = rPR_EX_RF_Write_Addr;  
    
  assign oID_EX_Write_Shadow_Register   = rPR_EX_Write_Shadow_Register;
    
  
  // ALU
  assign oID_EX_ALU_Opcode              = rPR_EX_ALU_Opcode;   
  assign oID_EX_ALU_Operand_A           = rPR_EX_ALU_Operand_A;     
  assign oID_EX_ALU_Operand_B           = rPR_EX_ALU_Operand_B; 
  
  // LSU
  assign oID_EX_LSU_Memory_Write_Enable = wIs_LSU_Write;     
  assign oID_EX_LSU_Memory_Read_Enable  = wIs_LSU_Read;     
  assign oID_EX_LSU_Operand_A           = wEX_LSU_Operand_A;
  assign oID_EX_LSU_Operand_B           = wEX_LSU_Operand_B;
  assign oID_EX_LSU_Opcode              = wLSU_Opcode;
  assign oID_EX_LSU_Store_Data          = iBP_ID_LSU_Store_Data; 
  
  // MUL/SHIFT/LOGIC  
  assign oID_EX_MUL_SHIFT_LOGIC_Opcode    = rPR_EX_MUL_SHIFT_LOGIC_Opcode; 
  assign oID_EX_MUL_SHIFT_LOGIC_Operand_A = rPR_EX_MUL_SHIFT_LOGIC_Operand_A;     
  assign oID_EX_MUL_SHIFT_LOGIC_Operand_B = rPR_EX_MUL_SHIFT_LOGIC_Operand_B;  
 
 
  // flag signals
  assign oID_EX_Is_Multiplication    = rPR_EX_Is_Multiplication;
  assign oID_EX_Is_Shift             = rPR_EX_Is_Shift;
  //assign oID_EX_Is_MUL_SHIFT_LOGIC = rPR_EX_Is_MUL_SHIFT_LOGIC;
  //assign oID_EX_Is_ALU             = rPR_WX_Is_ALU;
  //assign oID_EX_Is_LSU             = rPR_EX_Is_LSU;
 
  // flag/P0/P1
  assign oID_EX_Update_Flag = rPR_EX_Update_Flag;
  assign oID_EX_Update_P0   = rPR_EX_Update_P0;
  assign oID_EX_Update_P1   = rPR_EX_Update_P1;
                    
  // pc
  assign oID_EX_PC          = rPR_EX_PC;  
 
  // ------------------
  // to bypass network
  // ------------------
  assign oID_BP_Immediate         = wID_Immediate;
  assign oID_BP_Is_Long_Immediate = rIs_Long_Imm;
  assign oID_BP_Long_Immediate    = rLong_Imm;
  assign oID_BP_Is_SUB            = rIs_SUB;
  


endmodule