////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//    Module Name :  pe_top                                                   //
//    Description :  This is the top module of the PE array of the SIMD       //
//                   processor.                                               //
//                                                                            //
//    Author(s)   :  Yifan He                                                 //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

`include "def-pe.v"

// synopsys translate_off
`timescale 1ns / 1ps
// synopsys translate_on


module pe_top #(
  parameter Para_PE_ID = 32'h0
  ) (
    iClk,                          // system clock, positive-edge trigger
    iReset,                        // global synchronous reset signal, Active high

    // neighbourhood communication
    iData_Selection,               // data selection bits

    iUpdate_Flag,                  // selection bits for updating flag/P0/P1

    iIF_ID_Predication,            // predication bits

    iLeft_PE_Port1_Data,           // data from left PE
    iRight_PE_Port1_Data,          // data from right PE
    iCP_Data,                      // data from cp
    oPE_Port1_Data,                // data to left/right PE

    // IF to RF read ports
    iIF_RF_Read_Addr_A,            // RF read port A address
    iIF_RF_Read_Addr_B,            // RF read port B address

    // IF to bypass network
    iIF_BP_Select_Imm,             // indicate that the second operand is from immediate value
    iIF_BP_Bypass_Read_A,          // flag that indicate RF read port A bypassed
    iIF_BP_Bypass_Read_B,          // flag that indicate RF read port B bypassed
    iIF_BP_Bypass_Sel_A,           // port A bypass source selection
    iIF_BP_Bypass_Sel_B,           // port B bypass source selection

    // ID-1 to ID-2
    // to RF write
    iID_ID_RF_Write_Addr,          // Register file write-back address
    iID_ID_RF_WriteBack,           // Register file write-back control.
                                   // Bit 0: register file write enable; Bit 1~2: ALU / LR (Link Register) / LSU / MUL

    // ALU
    iID_ID_ALU_Opcode,             // ALU operation decoding
    iID_ID_Is_ALU,                 // is ALU operation

    // LSU
    iID_ID_LSU_Write_Enable,       // LSU stage data-memory write enable
    iID_ID_LSU_Read_Enable,        // LSU stage data-memory read enable
    iID_ID_LSU_Opcode,             // LSU opcoce: word/half-word/byte

    // MUL/SHIFT/LOGIC
    iID_ID_MUL_SHIFT_LOGIC_Opcode, // mult/shift/logic operation opcode
    iID_ID_Is_MUL,                 // is multiplication operation
    iID_ID_Is_Shift,               // is shift operation
    iID_ID_Is_MUL_SHIFT_LOGIC,     // is mul/shift/logic operation

    // ID-1 to bypass network
    iID_BP_Immediate,              // sign-extended (to data-path width) immediate

    // from/to data memory
    oAGU_DMEM_Write_Enable,        // LSU stage data-memory write enable
    oAGU_DMEM_Read_Enable,         // LSU stage data-memory read enable
    oAGU_DMEM_Address,             // Address to DMEM
    oAGU_DMEM_Byte_Select,         // 
    oAGU_DMEM_Opcode,              //
    oAGU_DMEM_Store_Data,          // Store data to EX stage (for store instruction only)
    iDMEM_EX_Data                  // data loaded from data memory
);


//******************************
//  Local Parameter Definition
//******************************



//****************************
//  Input/Output Declaration
//****************************

  input                                   iClk;                            // system clock, positive-edge trigger
  input                                   iReset;                          // global synchronous reset signal, Active high

  // neighbourhood/cp communication
  input  [1:0]                            iData_Selection;                 // data selection bits

  input  [1:0]                            iUpdate_Flag;                      // selection bits for updating flag/P0/P1

  input  [1:0]                            iIF_ID_Predication;

  input  [(`DEF_PE_DATA_WIDTH-1):0]       iLeft_PE_Port1_Data;             // data from left PE
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iRight_PE_Port1_Data;            // data from right PE
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iCP_Data;                        // data from cp
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE_Port1_Data;                  // data to left/right PE

  // IF to RF read ports
  input  [(`DEF_RF_INDEX_WIDTH-1):0]      iIF_RF_Read_Addr_A;              // RF read port A address
  input  [(`DEF_RF_INDEX_WIDTH-1):0]      iIF_RF_Read_Addr_B;              // RF read port B address

  // IF to bypass network
  input                                   iIF_BP_Select_Imm;               // indicate that the second operand is from immediate value
  input                                   iIF_BP_Bypass_Read_A;            // flag that indicate RF read port A bypassed
  input                                   iIF_BP_Bypass_Read_B;            // flag that indicate RF read port B bypassed
  input  [1:0]                            iIF_BP_Bypass_Sel_A;             // port A bypass source selection
  input  [1:0]                            iIF_BP_Bypass_Sel_B;             // port B bypass source selection


  // ID-1 to ID-2
  // RF write-back
  input  [(`DEF_RF_INDEX_WIDTH-1):0]      iID_ID_RF_Write_Addr;            // Register file write-back address
  input  [(`RISC24_RFWBOP_WIDTH-1):0]     iID_ID_RF_WriteBack;             // Register file write-back control.
                                                                           // Bit 0: register file write enable; Bit 1~2: ALU / LR (Link Register) / LSU / MUL

  // ALU
  input  [(`RISC24_ALU_OP_WIDTH-1):0]     iID_ID_ALU_Opcode;               // ALU operation decoding
  input                                   iID_ID_Is_ALU;                   // is ALU operation

  // LSU
  input                                   iID_ID_LSU_Write_Enable;         // LSU stage data-memory write enable
  input                                   iID_ID_LSU_Read_Enable;          // LSU stage data-memory read enable
  input  [(`RISC24_PE_LSU_OP_WIDTH-1):0]  iID_ID_LSU_Opcode;               // LSU opcoce: word/half-word/byte

  // MUL/SHIFT/LOGIC
  input  [(`RISC24_MULSHLOG_OP_WIDTH-1):0] iID_ID_MUL_SHIFT_LOGIC_Opcode;  // mult/shift/logic operation opcode
  input                                   iID_ID_Is_MUL;                   // is multiplication operation
  input                                   iID_ID_Is_Shift;                 // is shift operation
  input                                   iID_ID_Is_MUL_SHIFT_LOGIC;       // is mul/shift/logic operation

  // ID-1 to bypass
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iID_BP_Immediate;                // sign-extended (to 32bit) immediate



  // from/to data memory
  output                                  oAGU_DMEM_Write_Enable;           // LSU stage data-memory write enable
  output                                  oAGU_DMEM_Read_Enable;            // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oAGU_DMEM_Address;               // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oAGU_DMEM_Byte_Select;         // 
  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oAGU_DMEM_Opcode;              // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH-1):0]       oAGU_DMEM_Store_Data;             // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iDMEM_EX_Data;                   // data loaded from data memory


//******************************
//  Local Wire/Reg Declaration
//******************************

  // ID-2 to EX: RF write-back
  wire [(`DEF_RF_INDEX_WIDTH-1):0]        wID_EX_RF_Write_Addr;            // Register file write-back address
  wire [(`RISC24_RFWBOP_WIDTH-1):0]       wID_EX_RF_WriteBack;             // Register file write-back control.
                                                                           // Bit 0: register file write enable; Bit 1~2: ALU / LR (Link Register) / LSU / MUL

  wire                                    wID_EX_Write_Shadow_Register;    // Write the shadow register (write R31)

  // ID-2 to EX: ALU
  wire [(`RISC24_ALU_OP_WIDTH-1):0]       wID_EX_ALU_Opcode;               // ALU operation decoding
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wID_EX_ALU_Operand_A;            // Operand A to the EX stage
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wID_EX_ALU_Operand_B;            // Operand B to the EX stage


  // ID-2 to EX: MUL/SHIFT/LOGIC
  wire [(`RISC24_MULSHLOG_OP_WIDTH-1):0]  wID_EX_MUL_SHIFT_LOGIC_Opcode; // mul/shift/rotate operation opcode
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wID_EX_MUL_SHIFT_LOGIC_Operand_A;// Operand A to the EX stage for multiplication only
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wID_EX_MUL_SHIFT_LOGIC_Operand_B;// Operand B to the EX stage for multiplication only

  // ID-2 to EX: selection & other
  wire                                    wID_EX_Is_Multiplication;
  wire                                    wID_EX_Is_Shift;
  wire                                    wID_EX_Update_Flag;              // if set condition met in compare ins. update flag
  wire                                    wID_EX_Update_P0;                // if set condition met in compare ins. update P0
  wire                                    wID_EX_Update_P1;                // if set condition met in compare ins. update P1

  // ID to bypass
  wire                                    wID_BP_Is_SUB;

  //ID to AGU
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wID_AGU_Memory_Store_Data;
  wire                                    wID_AGU_Write_Enable;
  wire                                    wID_AGU_Read_Enable;
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wID_AGU_LSU_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wID_AGU_Operand_A;               // Operand A to the EX stage for LSU only
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wID_AGU_Operand_B;               // Operand B to the EX stage for LSU only

  // EX to ID-2
  wire                                    wEX_ID_P0;                       // value of P0 register
  wire                                    wEX_ID_P1;                       // value of P1 register

  // RF to bypass
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wRF_BP_Read_Data_A;              // RF read data from port A
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wRF_BP_Read_Data_B;              // RF read data from port B

  // bypass to ID-2
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wBP_ID_Operand_A;                // operand A
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wBP_ID_Operand_B;                // operand B
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wBP_ID_LSU_Store_Data;           // store data (for store instruction only)

  // EX to bypass
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wEX_BP_ALU_Result;               // bypass src from ALU (and LR)
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wEX_BP_MUL_Result;               // bypass src from MUL
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wEX_BP_LSU_Result;               // bypass src from LSU
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wEX_BP_Shadow_Result;            // bypass src from shadow register (R31)

  // EX to write-back
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wEX_WB_Write_RF_Data;            // EX stage to WB stage data
  wire [(`DEF_RF_INDEX_WIDTH-1):0]        wEX_WB_Write_RF_Address;         // EX stage to WB stage RF index
  wire                                    wEX_WB_Write_RF_Enable;          // EX stage to WB stage RF write enable


  // WB to RF
  wire                                    wWB_RF_Writeback_Enable;         // WB-stage RF write back enable
  wire [(`DEF_RF_INDEX_WIDTH-1):0]        wWB_RF_Write_Addr;               // WB-stage RF write address
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wWB_RF_Write_Data;               // WB-stage RF write dat



//******************************
//  Behavioral Description
//******************************

// ==============
//  ID stage - 2
// ==============
  pe_id inst_pe_id (
    .iClk                          ( iClk                           ),  // system clock, positive-edge trigger
    .iReset                        ( iReset                         ),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( iUpdate_Flag                   ),  // selection bits for updating flag/P0/P1

    // predication
    .iIF_ID_Predication            ( iIF_ID_Predication             ),  // IF-ID predication bits

    // ID-2 to EX
    .iEX_ID_P0                     ( wEX_ID_P0                      ),  // value of P1 register
    .iEX_ID_P1                     ( wEX_ID_P1                      ),  // value of P2 register

    // ID-1 to ID-2
    // to RF write
    .iID_ID_RF_Write_Addr          ( iID_ID_RF_Write_Addr           ),  // Register file write-back address
    .iID_ID_RF_WriteBack           ( iID_ID_RF_WriteBack            ),  // Register file write-back control.
                                                                        // Bit 0: register file write enable; Bit 1~2: ALU / LR (Link Register) / LSU / MUL

    // ALU
    .iID_ID_ALU_Opcode             ( iID_ID_ALU_Opcode              ),  // ALU operation decoding
    .iID_ID_Is_ALU                 ( iID_ID_Is_ALU                  ),  // is ALU operation

    // LSU
    .iID_ID_LSU_Write_Enable       ( iID_ID_LSU_Write_Enable        ),  // LSU stage data-memory write enable
    .iID_ID_LSU_Read_Enable        ( iID_ID_LSU_Read_Enable         ),  // LSU stage data-memory read enable
    .iID_ID_LSU_Opcode             ( iID_ID_LSU_Opcode              ),  // LSU opcoce: word/half-word/byte

    // MUL/SHIFT/LOGIC
    .iID_ID_MUL_SHIFT_LOGIC_Opcode ( iID_ID_MUL_SHIFT_LOGIC_Opcode  ),  // mult/shift/logic operation opcode
    .iID_ID_Is_MUL                 ( iID_ID_Is_MUL                  ),  // is multiplication operation
    .iID_ID_Is_Shift               ( iID_ID_Is_Shift                ),  // is shift operation
    .iID_ID_Is_MUL_SHIFT_LOGIC     ( iID_ID_Is_MUL_SHIFT_LOGIC      ),  // is mul/shift/logic operation

    // EX to ID-2
    .oID_EX_Update_Flag            ( wID_EX_Update_Flag             ),  // if set condition met in compare ins. update flag
    .oID_EX_Update_P0              ( wID_EX_Update_P0               ),  // if set condition met in compare ins. update P0
    .oID_EX_Update_P1              ( wID_EX_Update_P1               ),  // if set condition met in compare ins. update P1

    // to RF write
    .oID_EX_RF_Write_Addr          ( wID_EX_RF_Write_Addr           ),  // Register file write-back address
    .oID_EX_RF_WriteBack           ( wID_EX_RF_WriteBack            ),  // Register file write-back control.
                                                                        // Bit 0: register file write enable; Bit 1~2: ALU / LR (Link Register) / LSU / MUL

    .oID_EX_Write_Shadow_Register  ( wID_EX_Write_Shadow_Register   ),  // Write the shadow register (write R31)

    // ALU
    .oID_EX_ALU_Opcode             ( wID_EX_ALU_Opcode              ),  // ALU operation decoding
    .oID_EX_ALU_Operand_A          ( wID_EX_ALU_Operand_A           ),  // Operand A to the EX stage,
    .oID_EX_ALU_Operand_B          ( wID_EX_ALU_Operand_B           ),  // Operand B to the EX stage,

    // LSU
    .oID_LSU_Memory_Write_Enable   ( wID_AGU_Write_Enable           ), // LSU stage data-memory write enable
    .oID_LSU_Memory_Read_Enable    ( wID_AGU_Read_Enable            ), // LSU stage data-memory read enable
    .oID_LSU_Operand_A             ( wID_AGU_Operand_A              ), // Operand A to the EX stage for LSU only
    .oID_LSU_Operand_B             ( wID_AGU_Operand_B              ), // Operand B to the EX stage for LSU only
    .oID_LSU_Opcode                ( wID_AGU_LSU_Opcode            ),  // LSU opcoce: word/half-word/byte               
    .oID_LSU_Store_Data            ( wID_AGU_Memory_Store_Data      ), // Store data to EX stage (for store instruction only)

    // MUL/SHIFT/LOGIC
    .oID_EX_MUL_SHIFT_LOGIC_Opcode    ( wID_EX_MUL_SHIFT_LOGIC_Opcode    ), // Shift and rotate operation opcode
    .oID_EX_MUL_SHIFT_LOGIC_Operand_A ( wID_EX_MUL_SHIFT_LOGIC_Operand_A ), // Operand A to the EX stage for multiplication only
    .oID_EX_MUL_SHIFT_LOGIC_Operand_B ( wID_EX_MUL_SHIFT_LOGIC_Operand_B ), // Operand B to the EX stage for multiplication only

    // Flag signals
    .oID_EX_Is_Multiplication      ( wID_EX_Is_Multiplication       ),
    .oID_EX_Is_Shift               ( wID_EX_Is_Shift                ),

    // from/to bypass network
    .iBP_ID_Operand_A              ( wBP_ID_Operand_A               ),  // operand A
    .iBP_ID_Operand_B              ( wBP_ID_Operand_B               ),  // operand B
    .iBP_ID_LSU_Store_Data         ( wBP_ID_LSU_Store_Data          ),  // store data (for store instruction only)
    .oID_BP_Is_SUB                 ( wID_BP_Is_SUB                  )   // current ins. is sub
  );

  //Address Generation Module
  pe_agu inst_pe_agu(
    .iClk                           ( iClk                          ),  // system clock, positive-edge trigger
    .iReset                         ( iReset                        ),  // global synchronous reset signal, Active high

    .iID_AGU_Operand_A              ( wID_AGU_Operand_A             ),  // Operand A to the EX stage for LSU only
    .iID_AGU_Operand_B              ( wID_AGU_Operand_B             ),  // Operand B to the EX stage for LSU only

    .iID_AGU_Memory_Write_Enable    ( wID_AGU_Write_Enable          ),
    .iID_AGU_Memory_Read_Enable     ( wID_AGU_Read_Enable           ),
    .iID_AGU_Memory_Opcode          ( wID_AGU_LSU_Opcode            ),  // LSU opcoce: word/half-word/byte
    .iID_AGU_Memory_Store_Data      ( wID_AGU_Memory_Store_Data     ),

    .oAGU_DMEM_Memory_Write_Enable  ( oAGU_DMEM_Write_Enable        ),  // Write enable to DMEM
    .oAGU_DMEM_Memory_Read_Enable   ( oAGU_DMEM_Read_Enable         ),  // Read enable to DMEM
    .oAGU_DMEM_Byte_Select          ( oAGU_DMEM_Byte_Select         ), 
    .oAGU_DMEM_Opcode               ( oAGU_DMEM_Opcode              ),
    .oAGU_DMEM_Memory_Store_Data    ( oAGU_DMEM_Store_Data          ),
    .oAGU_DMEM_Address              ( oAGU_DMEM_Address             )   // Address to DMEM
  );



  // RF module
  pe_rf #(
   .Para_PE_ID ( Para_PE_ID )
  ) inst_pe_rf (
    .iClk                          ( iClk                           ),  // system clock, positive-edge trigger
    //.iReset                      ( iReset                         ),  // global synchronous reset signal, Active high

    // from IF stage
    .iIF_RF_Read_Addr_A            ( iIF_RF_Read_Addr_A             ),  // RF read port A address
    .iIF_RF_Read_Addr_B            ( iIF_RF_Read_Addr_B             ),  // RF read port B address

    // to bypass
    .oRF_BP_Read_Data_A            ( wRF_BP_Read_Data_A             ),  // RF read data from port A
    .oRF_BP_Read_Data_B            ( wRF_BP_Read_Data_B             ),  // RF read data from port B

    // from WB stage
    .iWB_RF_Write_Addr             ( wWB_RF_Write_Addr              ),  // RF write address
    .iWB_RF_Write_Data             ( wWB_RF_Write_Data              ),  // RF write data
    .iWB_RF_Write_Enable           ( wWB_RF_Writeback_Enable        )   // RF write enable signal
  );


  // bypass module
  pe_bypass inst_pe_bypass(
    // from WB stage for RF internal bypass
    .iWB_RF_Write_Addr             ( wWB_RF_Write_Addr              ),  // RF write address
    .iWB_RF_Write_Data             ( wWB_RF_Write_Data              ),  // RF write data

    // from IF stage
    .iIF_RF_Read_Addr_A            ( iIF_RF_Read_Addr_A             ),  // RF read port A address
    .iIF_RF_Read_Addr_B            ( iIF_RF_Read_Addr_B             ),  // RF read port B address
    .iIF_BP_Select_Imm             ( iIF_BP_Select_Imm              ),  // indicate that the second operand is from immediate value
    .iIF_BP_Bypass_Read_A          ( iIF_BP_Bypass_Read_A           ),  // flag that indicate RF read port A bypassed
    .iIF_BP_Bypass_Read_B          ( iIF_BP_Bypass_Read_B           ),  // flag that indicate RF read port B bypassed
    .iIF_BP_Bypass_Sel_A           ( iIF_BP_Bypass_Sel_A            ),  // port A bypass source selection
    .iIF_BP_Bypass_Sel_B           ( iIF_BP_Bypass_Sel_B            ),  // port B bypass source selection

    // from/to ID stage
    .iID_BP_Immediate              ( iID_BP_Immediate               ),  // sign-extended (to data-path width) immediate
    .iID_BP_Is_SUB                 ( wID_BP_Is_SUB                  ),  // current ins. is SUB
    .oBP_ID_Operand_A              ( wBP_ID_Operand_A               ),  // operand A
    .oBP_ID_Operand_B              ( wBP_ID_Operand_B               ),  // operand B
    .oBP_ID_LSU_Store_Data         ( wBP_ID_LSU_Store_Data          ),  // store data (for store instruction only)

    // from Regiser File
    .iRF_BP_Read_Data_A            ( wRF_BP_Read_Data_A             ),  // RF read data from port A
    .iRF_BP_Read_Data_B            ( wRF_BP_Read_Data_B             ),  // RF read data from port B

    // from EX
    .iEX_BP_ALU_Result             ( wEX_BP_ALU_Result              ),  // bypass src from ALU (and LR)
    .iEX_BP_MUL_Result             ( wEX_BP_MUL_Result              ),  // bypass src from MUL
    .iEX_BP_LSU_Result             ( wEX_BP_LSU_Result              ),  // bypass src from LSU
    .iEX_BP_Shadow_Result          ( wEX_BP_Shadow_Result           ),  // bypass src from shadow register (R31)

    // from/to neighbourhood
    .iData_Selection               ( iData_Selection                ),  // data selection bits
    .iLeft_PE_Port1_Data           ( iLeft_PE_Port1_Data            ),  // data from left PE
    .iRight_PE_Port1_Data          ( iRight_PE_Port1_Data           ),  // data from right PE
    .iCP_Data                      ( iCP_Data                       ),  // data from cp
    .oPE_Port1_Data                ( oPE_Port1_Data                 )   // data to left/right PE
  );


// ===========
//  EX stage
// ===========
  pe_ex inst_pe_ex(
    .iClk                          ( iClk                           ),  // system clock, positive-edge trigger
    .iReset                        ( iReset                         ),  // global synchronous reset signal, Active high

    // to EX
    .oEX_ID_P0                     ( wEX_ID_P0                      ),  // value of P1 register
    .oEX_ID_P1                     ( wEX_ID_P1                      ),  // value of P2 register

    .iID_EX_Update_Flag            ( wID_EX_Update_Flag             ), // if set condition met in compare ins. update flag
    .iID_EX_Update_P0              ( wID_EX_Update_P0               ), // if set condition met in compare ins. update P0
    .iID_EX_Update_P1              ( wID_EX_Update_P1               ), // if set condition met in compare ins. update P1

    // from EX stage
    .iID_EX_RF_Write_Addr          ( wID_EX_RF_Write_Addr           ),  // Register file write-back address
    .iID_EX_RF_WriteBack           ( wID_EX_RF_WriteBack            ),  // Register file write-back control. Bit 0: register file write enable;
                                                                        // Bit 1~2: ALU / LR (Link Register) / LSU / MUL

    .iID_EX_Write_Shadow_Register  ( wID_EX_Write_Shadow_Register   ),  // Write the shadow register (write R31)

    // ALU
    .iID_EX_ALU_Opcode             ( wID_EX_ALU_Opcode              ),  // ALU operation decoding
    .iID_EX_ALU_Operand_A          ( wID_EX_ALU_Operand_A           ),  // Operand A to the EX stage
    .iID_EX_ALU_Operand_B          ( wID_EX_ALU_Operand_B           ),  // Operand B to the EX stage

    // MUL/SHIFT/LOGIC
    .iID_EX_MUL_SHIFT_LOGIC_Opcode    ( wID_EX_MUL_SHIFT_LOGIC_Opcode    ), // Shift and rotate operation opcode
    .iID_EX_MUL_SHIFT_LOGIC_Operand_A ( wID_EX_MUL_SHIFT_LOGIC_Operand_A ), // Operand A to the EX stage for mult/shift/logic
    .iID_EX_MUL_SHIFT_LOGIC_Operand_B ( wID_EX_MUL_SHIFT_LOGIC_Operand_B ), // Operand B to the EX stage for mult/shift/logic

    // Flag signals
    .iID_EX_Is_Multiplication      ( wID_EX_Is_Multiplication       ),
    .iID_EX_Is_Shift               ( wID_EX_Is_Shift                ),


    // to bypass
    .oEX_BP_ALU_Result             ( wEX_BP_ALU_Result              ),  // bypass src from ALU (and LR)
    .oEX_BP_MUL_Result             ( wEX_BP_MUL_Result              ),  // bypass src from MUL
    .oEX_BP_LSU_Result             ( wEX_BP_LSU_Result              ),  // bypass src from LSU
    .oEX_BP_Shadow_Result          ( wEX_BP_Shadow_Result           ),  // bypass src from shadow register (R31)

    // from/to data memory
    .iDMEM_EX_Data                 ( iDMEM_EX_Data                  ),  // data loaded from data memory

    // to WB stage
    .oEX_WB_Write_RF_Data          ( wEX_WB_Write_RF_Data           ),  // EX stage to WB stage data
    .oEX_WB_Write_RF_Address       ( wEX_WB_Write_RF_Address        ),  // EX stage to WB stage RF index
    .oEX_WB_Write_RF_Enable        ( wEX_WB_Write_RF_Enable         )   // EX stage to WB stage RF write enable
  );


// ================
//   WB stage
// ================
  pe_wb inst_pe_wb(
    .iClk                          ( iClk                           ),  // system clock, positive-edge trigger
    .iReset                        ( iReset                         ),  // global synchronous reset signal, Active high

    // from EX stage
    .iEX_WB_Write_RF_Data          ( wEX_WB_Write_RF_Data           ),  // EX stage to WB stage data
    .iEX_WB_Write_RF_Address       ( wEX_WB_Write_RF_Address        ),  // EX stage to WB stage RF index
    .iEX_WB_Write_RF_Enable        ( wEX_WB_Write_RF_Enable         ),  // EX stage to WB stage RF write enable

    // to RF
    .oWB_RF_Writeback_Enable       ( wWB_RF_Writeback_Enable        ),  // WB-stage RF write back enable
    .oWB_RF_Write_Addr             ( wWB_RF_Write_Addr              ),  // WB-stage RF write address
    .oWB_RF_Write_Data             ( wWB_RF_Write_Data              )   // WB-stage RF write data
  );


//*********************
//  Output Assignment
//*********************




endmodule