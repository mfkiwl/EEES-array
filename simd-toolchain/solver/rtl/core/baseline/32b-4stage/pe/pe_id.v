////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//    Module Name :  pe_id                                                    //
//    Description :  Instruction Decode stage (PE part) of the SIMD processor.//
//                                                                            //
//    Author(s)   :  Yifan He                                                 //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

`include "def-pe.v"

// synopsys translate_off
`timescale 1ns / 1ps
// synopsys translate_on


module pe_id (                                                            
  iClk,                              // system clock, positive-edge trigger
  iReset,                            // global synchronous reset signal, Active high

  iUpdate_Flag,                      // selection bits for updating flag/P0/P1
  
  // predication
  iIF_ID_Predication,                // predication bits
  
  // ID-2 to EX
  iEX_ID_P0,                         // value of P1 register
  iEX_ID_P1,                         // value of P2 register
  
  // ID-1 to ID-2
  // to RF write
  iID_ID_RF_Write_Addr,              // Register file write-back address                               
  iID_ID_RF_WriteBack,               // Register file write-back control. 
                                     // Bit 0: register file write enable; Bit 1~2: ALU / LR (Link Register) / LSU / MUL
                                     
  // ALU                             
  iID_ID_ALU_Opcode,                 // ALU operation decoding
  iID_ID_Is_ALU,                     // is ALU operation
                                     
  // LSU                             
  iID_ID_LSU_Write_Enable,           // LSU stage data-memory write enable
  iID_ID_LSU_Read_Enable,            // LSU stage data-memory read enable
  iID_ID_LSU_Opcode,                 // LSU opcoce: word/half-word/byte
                                     
  // MUL/SHIFT/LOGIC                 
  iID_ID_MUL_SHIFT_LOGIC_Opcode,     // mult/shift/logic operation opcode
  iID_ID_Is_MUL,                     // is multiplication operation
  iID_ID_Is_Shift,                   // is shift operation
  iID_ID_Is_MUL_SHIFT_LOGIC,         // is mul/shift/logic operation


  // ID-2 to EX stage
  // RF write
  oID_EX_RF_Write_Addr,              // Register file write-back address
  oID_EX_RF_WriteBack,               // Register file write-back control. 
                                     // Bit 0: register file write enable; Bit 1~2: ALU / LR (Link Register) / LSU / MUL
  
  // ALU  
  oID_EX_ALU_Opcode,                 // ALU operation decoding  
  oID_EX_ALU_Operand_A,              // Operand A to the EX stage
  oID_EX_ALU_Operand_B,              // Operand B to the EX stage  
  
  // LSU
  oID_LSU_Memory_Write_Enable,       // LSU stage data-memory write enable
  oID_LSU_Memory_Read_Enable,        // LSU stage data-memory read enable  
  oID_LSU_Operand_A,                 // Operand A to the EX stage for LSU only
  oID_LSU_Operand_B,                 // Operand B to the EX stage for LSU only  
  oID_LSU_Opcode,                  // LSU opcoce: word/half-word/byte
  oID_LSU_Store_Data,                // Store data to EX stage (for store instruction only)

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
  
  // from/to bypass network
  iBP_ID_Operand_A,                  // operand A
  iBP_ID_Operand_B,                  // operand B  
  iBP_ID_LSU_Store_Data,             // store data (for store instruction only)
  oID_BP_Is_SUB                      // current ins. is sub
);

//******************************
//  Local Parameter Definition
//******************************



//****************************
//  Input/Output Declaration
//****************************

  input                                   iClk;                              // system clock, positive-edge trigger
  input                                   iReset;                            // global synchronous reset signal, Active high

  input  [1:0]                            iUpdate_Flag;                      // selection bits for updating flag/P0/P1
  
  input  [1:0]                            iIF_ID_Predication;
  
  // ID-1 to ID-2
  // to RF write
  input  [(`DEF_RF_INDEX_WIDTH-1):0]      iID_ID_RF_Write_Addr;              // Register file write-back address                               
  input  [(`RISC24_RFWBOP_WIDTH-1):0]     iID_ID_RF_WriteBack;               // Register file write-back control. 
                                                                             // Bit 0: register file write enable; Bit 1~2: ALU / LR (Link Register) / LSU / MUL
                                     
  // ALU                             
  input  [(`RISC24_ALU_OP_WIDTH-1):0]     iID_ID_ALU_Opcode;                 // ALU operation decoding
  input                                   iID_ID_Is_ALU;                     // is ALU operation
                                     
  // LSU                             
  input                                   iID_ID_LSU_Write_Enable;           // LSU stage data-memory write enable
  input                                   iID_ID_LSU_Read_Enable;            // LSU stage data-memory read enable
  input  [(`RISC24_PE_LSU_OP_WIDTH-1):0]  iID_ID_LSU_Opcode;                 // LSU opcoce: word/half-word/byte
                                     
  // MUL/SHIFT/LOGIC                 
  input  [(`RISC24_MULSHLOG_OP_WIDTH-1):0] iID_ID_MUL_SHIFT_LOGIC_Opcode;    // mult/shift/logic operation opcode
  input                                   iID_ID_Is_MUL;                     // is multiplication operation
  input                                   iID_ID_Is_Shift;                   // is shift operation
  input                                   iID_ID_Is_MUL_SHIFT_LOGIC;         // is mul/shift/logic operation

  input                                   iEX_ID_P0;                         // value of P0 register
  input                                   iEX_ID_P1;                         // value of P1 register
  
  // EX to ID-2
  output                                  oID_EX_Update_Flag;                // if set condition met in compare ins. update flag
  output                                  oID_EX_Update_P0;                  // if set condition met in compare ins. update P0  
  output                                  oID_EX_Update_P1;                  // if set condition met in compare ins. update P1
  
  // RF write
  output [(`DEF_RF_INDEX_WIDTH-1):0]      oID_EX_RF_Write_Addr;              // Register file write-back address
  output [(`RISC24_RFWBOP_WIDTH-1):0]     oID_EX_RF_WriteBack;               // Register file write-back control. 
                                                                             // Bit 0: register file write enable; Bit 1~2: ALU / LR (Link Register) / LSU / MUL
  // ALU
  output [(`RISC24_ALU_OP_WIDTH-1):0]     oID_EX_ALU_Opcode;                 // ALU operation decoding  
  output [(`DEF_PE_DATA_WIDTH-1):0]       oID_EX_ALU_Operand_A;              // Operand A to the EX stage
  output [(`DEF_PE_DATA_WIDTH-1):0]       oID_EX_ALU_Operand_B;              // Operand B to the EX stage 
  
  // LSU
  output                                  oID_LSU_Memory_Write_Enable;       // LSU stage data-memory write enable
  output                                  oID_LSU_Memory_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oID_LSU_Operand_A;                 // Operand A to the EX stage for LSU only
  output [(`DEF_PE_DATA_WIDTH-1):0]       oID_LSU_Operand_B;                 // Operand B to the EX stage for LSU only
  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oID_LSU_Opcode;                    // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH-1):0]       oID_LSU_Store_Data;                // Store data to EX stage (for store instruction only)
  
  // MUL/SHIFT/LOGIC
  output [(`RISC24_MULSHLOG_OP_WIDTH-1):0] oID_EX_MUL_SHIFT_LOGIC_Opcode;    // mul/shift/rotate operation opcode
  output [(`DEF_PE_DATA_WIDTH-1):0]        oID_EX_MUL_SHIFT_LOGIC_Operand_A; // Operand A to the EX stage for multiplication only
  output [(`DEF_PE_DATA_WIDTH-1):0]        oID_EX_MUL_SHIFT_LOGIC_Operand_B; // Operand B to the EX stage for multiplication only  
  
  // flag signals
  output                                  oID_EX_Is_Multiplication;
  output                                  oID_EX_Is_Shift;
  
  // from bypass network
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iBP_ID_Operand_A;                 // operand A (after selection) to EX stage
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iBP_ID_Operand_B;                 // operand B (after selection) to EX stage
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iBP_ID_LSU_Store_Data;            // store data (for store instruction only)
  output                                  oID_BP_Is_SUB;


//******************************
//  Local Wire/Reg Declaration
//******************************
  // rf write 
  wire                                    wWrite_R0;                  // RF write index = 0
  wire                                    wWrite_RF_Enable;           // RF write is needed

  reg  [(`DEF_RF_INDEX_WIDTH-1):0]        rPR_EX_RF_Write_Addr;       // Register file write-back address
  reg  [(`RISC24_RFWBOP_WIDTH-1):0]       rPR_EX_RF_WriteBack;        // Register file write-back control. 
                                                                      // Bit 0: register file write enable; Bit 1~2: ALU / LR (Link Register) / LSU / MUL

  // predication 
  reg                                     wIns_Valid;                 // current instruction will be executed

  // LSU
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wEX_LSU_Operand_A;          // Operand A to the EX stage for LSU only
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wEX_LSU_Operand_B;          // Operand B to the EX stage for LSU only

  // MUL/LOGIC/SHIFT
  reg  [(`DEF_PE_DATA_WIDTH-1): 0]        rPR_EX_MUL_SHIFT_LOGIC_Operand_A; // Operand A to the EX stage for multiplication/shift/logic
  reg  [(`DEF_PE_DATA_WIDTH-1): 0]        rPR_EX_MUL_SHIFT_LOGIC_Operand_B; // Operand B to the EX stage for multiplication/shift/logic
  reg  [(`RISC24_MULSHLOG_OP_WIDTH-1):0]  rPR_EX_MUL_SHIFT_LOGIC_Opcode;    // pipeline register: multiplication/shift/logic operation opcode
  
  
  // ALU
  reg  [(`DEF_PE_DATA_WIDTH-1): 0]        rPR_EX_ALU_Operand_A;             // Operand A to the EX stage
  reg  [(`DEF_PE_DATA_WIDTH-1): 0]        rPR_EX_ALU_Operand_B;             // Operand B to the EX stage
  reg  [(`RISC24_ALU_OP_WIDTH-1):0]       rPR_EX_ALU_Opcode;                // pipeline register: ALU operation opcode
  
  
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
  
  
  // after checking the predication bits
  wire                                    wID_EX_RF_Write_Enable;
  wire  [(`RISC24_ALU_OP_WIDTH-1):0]      wID_EX_ALU_Opcode;
  wire                                    wID_EX_Is_ALU;
  wire                                    wID_EX_LSU_Write_Enable;
  wire                                    wID_EX_LSU_Read_Enable;
  wire  [(`RISC24_MULSHLOG_OP_WIDTH-1):0] wID_EX_MUL_SHIFT_LOGIC_Opcode;
  wire                                    wID_EX_Is_MUL;
  wire                                    wID_EX_Is_Shift;
  wire                                    wID_EX_Is_MUL_SHIFT_LOGIC;
  
  
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


  // =============================================
  //  Register file write address and enable
  //  (RF index here can be clock-gated)
  // =============================================
  assign wWrite_R0 = ~( |iID_ID_RF_Write_Addr );  // write R0
  assign wWrite_RF_Enable = iID_ID_RF_WriteBack[0] && (~wWrite_R0);
  
  
  assign wID_EX_RF_Write_Enable        = wIns_Valid ? wWrite_RF_Enable              : 1'b0;
  assign wID_EX_ALU_Opcode             = wIns_Valid ? iID_ID_ALU_Opcode             : `RISC24_ALU_OP_NOP;
  assign wID_EX_Is_ALU                 = wIns_Valid ? iID_ID_Is_ALU                 : 1'b0;
  assign wID_EX_LSU_Write_Enable       = wIns_Valid ? iID_ID_LSU_Write_Enable       : 1'b0;           
  assign wID_EX_LSU_Read_Enable        = wIns_Valid ? iID_ID_LSU_Read_Enable        : 1'b0;
  assign wID_EX_MUL_SHIFT_LOGIC_Opcode = wIns_Valid ? iID_ID_MUL_SHIFT_LOGIC_Opcode : `RISC24_MULSHLOG_OP_NOP;
  assign wID_EX_Is_MUL                 = wIns_Valid ? iID_ID_Is_MUL                 : 1'b0;           
  assign wID_EX_Is_Shift               = wIns_Valid ? iID_ID_Is_Shift               : 1'b0;
  assign wID_EX_Is_MUL_SHIFT_LOGIC     = wIns_Valid ? iID_ID_Is_MUL_SHIFT_LOGIC     : 1'b0;


  // RF write address
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      rPR_EX_RF_Write_Addr <= 'b0;
    else if ( wID_EX_RF_Write_Enable )  // other ins. with RF write-back 
      rPR_EX_RF_Write_Addr <= iID_ID_RF_Write_Addr;
  // end of always

  // RF write-back enable signal
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      rPR_EX_RF_WriteBack[0] <= 'b0;
    else
      rPR_EX_RF_WriteBack[0] <= wID_EX_RF_Write_Enable;
  // end of always

  // RF src-data selection
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      rPR_EX_RF_WriteBack[(`RISC24_RFWBOP_WIDTH-1):1] <= 'b0;
    else if ( wID_EX_RF_Write_Enable ) // write RF enable, and NOT write R0
      rPR_EX_RF_WriteBack[(`RISC24_RFWBOP_WIDTH-1):1] <= iID_ID_RF_WriteBack[(`RISC24_RFWBOP_WIDTH-1):1];
  // end of always

  
  always @ ( iUpdate_Flag or wID_EX_Is_ALU )
    begin
      case ( iUpdate_Flag )
        2'b00: begin  // update flag register
          wID_EX_Update_Flag = 1'b1 && wID_EX_Is_ALU;
          wID_EX_Update_P0   = 1'b0;
          wID_EX_Update_P1   = 1'b0;
        end
        2'b01: begin  // update P0 register
          wID_EX_Update_Flag = 1'b0;
          wID_EX_Update_P0   = 1'b1 && wID_EX_Is_ALU;
          wID_EX_Update_P1   = 1'b0;
        end 
        2'b10: begin  // update P1 register
          wID_EX_Update_Flag = 1'b0;
          wID_EX_Update_P0   = 1'b0;
          wID_EX_Update_P1   = 1'b1 && wID_EX_Is_ALU;
        end
        default: begin
          wID_EX_Update_Flag = 1'b1 && wID_EX_Is_ALU;
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
  
  // =============================
  //  FU1: Decode LSU Operations
  // =============================
  assign wEX_LSU_Operand_A = (wID_EX_LSU_Read_Enable || wID_EX_LSU_Write_Enable) ? iBP_ID_Operand_A : 'b0;
  assign wEX_LSU_Operand_B = (wID_EX_LSU_Read_Enable || wID_EX_LSU_Write_Enable) ? iBP_ID_Operand_B : 'b0;
  

  // ==============================
  //  FU2: Decode Operations
  // ==============================
  
  // Pipeline Registers: flag signals
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
          rPR_EX_Is_Multiplication  <= 'b0;
          rPR_EX_Is_Shift           <= 'b0;
        end
    else if ( wID_EX_Is_MUL_SHIFT_LOGIC )
      begin
          rPR_EX_Is_Multiplication  <= wID_EX_Is_MUL;
          rPR_EX_Is_Shift           <= wID_EX_Is_Shift;
        end
  // end of always
  
  // MUL/SHIFT/LOGIC operands  
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
          rPR_EX_MUL_SHIFT_LOGIC_Operand_A <= 'b0;
          rPR_EX_MUL_SHIFT_LOGIC_Operand_B <= 'b0;
          rPR_EX_MUL_SHIFT_LOGIC_Opcode    <= `RISC24_MULSHLOG_OP_NOP;
        end
    else if ( wID_EX_Is_MUL_SHIFT_LOGIC )
      begin
        rPR_EX_MUL_SHIFT_LOGIC_Operand_A <= iBP_ID_Operand_A;
          rPR_EX_MUL_SHIFT_LOGIC_Operand_B <= iBP_ID_Operand_B;
          rPR_EX_MUL_SHIFT_LOGIC_Opcode    <= wID_EX_MUL_SHIFT_LOGIC_Opcode;
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
        rPR_EX_ALU_Opcode    <= `RISC24_ALU_OP_NOP;
      end
    else if ( wID_EX_Is_ALU )
      begin
        rPR_EX_ALU_Operand_A <= iBP_ID_Operand_A;
        rPR_EX_ALU_Operand_B <= iBP_ID_Operand_B;
        rPR_EX_ALU_Opcode    <= wID_EX_ALU_Opcode;
      end
  // end of always
      
      
//*********************
//  Output Assignment
//*********************
  // to bypass
  assign oID_BP_Is_SUB = (wID_EX_ALU_Opcode == `RISC24_ALU_OP_SUB);
 
  // --------------
  //  to EX stage 
  // --------------
  // RF write-back
  assign oID_EX_RF_WriteBack            = rPR_EX_RF_WriteBack;      
  assign oID_EX_RF_Write_Addr           = rPR_EX_RF_Write_Addr;
  
  // ALU
  assign oID_EX_ALU_Opcode              = rPR_EX_ALU_Opcode;   
  assign oID_EX_ALU_Operand_A           = rPR_EX_ALU_Operand_A;     
  assign oID_EX_ALU_Operand_B           = rPR_EX_ALU_Operand_B; 
  
  // LSU
  assign oID_LSU_Memory_Write_Enable    = wID_EX_LSU_Write_Enable;     
  assign oID_LSU_Memory_Read_Enable     = wID_EX_LSU_Read_Enable;     
  assign oID_LSU_Operand_A              = wEX_LSU_Operand_A;
  assign oID_LSU_Operand_B              = wEX_LSU_Operand_B;
  assign oID_LSU_Opcode                 = iID_ID_LSU_Opcode;
  assign oID_LSU_Store_Data             = iBP_ID_LSU_Store_Data; 
  
  // MUL/SHIFT/LOGIC  
  assign oID_EX_MUL_SHIFT_LOGIC_Opcode    = rPR_EX_MUL_SHIFT_LOGIC_Opcode; 
  assign oID_EX_MUL_SHIFT_LOGIC_Operand_A = rPR_EX_MUL_SHIFT_LOGIC_Operand_A;     
  assign oID_EX_MUL_SHIFT_LOGIC_Operand_B = rPR_EX_MUL_SHIFT_LOGIC_Operand_B;  
 
 
  // flag signals
  assign oID_EX_Is_Multiplication       = rPR_EX_Is_Multiplication;
  assign oID_EX_Is_Shift                = rPR_EX_Is_Shift;
 
  // flag/P0/P1
  assign oID_EX_Update_Flag             = rPR_EX_Update_Flag;
  assign oID_EX_Update_P0               = rPR_EX_Update_P0;
  assign oID_EX_Update_P1               = rPR_EX_Update_P1;
  
endmodule
