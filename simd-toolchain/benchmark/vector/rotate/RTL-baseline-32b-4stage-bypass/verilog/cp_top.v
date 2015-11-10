////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//    Module Name :  cp_top                                                   //
//    Description :  This is the top module of the control processor (CP) of  //
//                   the SIMD processor.                                      //
//                                                                            //
//    Author(s)   :  Yifan He                                                 //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

`include "def-cp.v"

// synopsys translate_off
`timescale 1ns / 1ps
// synopsys translate_on


module cp_top (
  iClk,                                  // system clock, positive-edge trigger
  iReset,                                // global synchronous reset signal, Active high

  oIF_ID_PC,                             // current PC for debug
  oTask_Finished,                        // indicate the end of the program

  // to PE Instruciton memory
  oIF_IMEM_Address,                      // PE instruciton memory address
  iIMEM_IF_Instruction,                  // instruction fetched from instruction memory

  // from/to data memory
  oAGU_DMEM_Write_Enable,                // LSU stage data-memory write enable
  oAGU_DMEM_Read_Enable,                 // LSU stage data-memory read enable
  oAGU_DMEM_Address,
  oAGU_DMEM_Byte_Select,                 // 
  oAGU_DMEM_Opcode,                      // LSU opcoce: word/half-word/byte
  oAGU_DMEM_Store_Data,                  // Store data to EX stage (for store instruction only)
  iDMEM_EX_Data,                         // data loaded from data memory

  // predication
  iPredication,                          // cp predication bits: '00'-always; '01'-P0; '10'-P1; '11'-P0&P1

  // CP - PE communication
  oCP_Port1_Data,                        // cp port 1 data to pe
  iFirst_PE_Port1_Data,                  // data from first PE RF port 1
  iSelect_First_PE,                      // flag: select the data from first PE
  iLast_PE_Port1_Data,                   // data from last PE RF port 1
  iSelect_Last_PE                        // flag: select the data from last PE
);

//******************************
//  Local Parameter Definition
//******************************



//****************************
//  Input/Output Declaration
//****************************

  input                                   iClk;                          // system clock, positive-edge trigger
  input                                   iReset;                        // global synchronous reset signal, Active high

  output [(`DEF_CP_I_MEM_ADDR_WIDTH-3):0] oIF_ID_PC;                     // current PC for debug
  output                                  oTask_Finished;                // indicate the end of the program

  // to PE Instruciton memory
  output [(`DEF_CP_I_MEM_ADDR_WIDTH-3):0] oIF_IMEM_Address;              // PE instruciton memory address
  input  [(`DEF_CP_INS_WIDTH-1):0]        iIMEM_IF_Instruction;          // instruction fetched from instruction memory

  // from/to data memory
  output                                  oAGU_DMEM_Write_Enable;        // LSU stage data-memory write enable
  output                                  oAGU_DMEM_Read_Enable;         // LSU stage data-memory read enable
  output [(`DEF_CP_DATA_WIDTH-1):0]       oAGU_DMEM_Address;             // Address to DMEM
  output [(`DEF_CP_DATA_WIDTH/8-1):0]     oAGU_DMEM_Byte_Select;         // 
  output [(`RISC24_CP_LSU_OP_WIDTH-1):0]  oAGU_DMEM_Opcode;              // LSU opcoce: word/half-word/byte
  output [(`DEF_CP_DATA_WIDTH-1):0]       oAGU_DMEM_Store_Data;          // Store data to EX stage (for store instruction only)
  input  [(`DEF_CP_DATA_WIDTH-1):0]       iDMEM_EX_Data;                 // data loaded from data memory

  // predication
  input  [1:0]                            iPredication;

  // CP - PE communication
  output [(`DEF_CP_DATA_WIDTH-1):0]       oCP_Port1_Data;                // cp port 1 data to pe
  input  [(`DEF_CP_DATA_WIDTH-1):0]       iFirst_PE_Port1_Data;          // data from first PE RF port 1
  input                                   iSelect_First_PE;              // flag: select the data from first PE
  input  [(`DEF_CP_DATA_WIDTH-1):0]       iLast_PE_Port1_Data;           // data from last PE RF port 1
  input                                   iSelect_Last_PE;               // flag: select the data from last PE


//******************************
//  Local Wire/Reg Declaration
//******************************

  // IF to ID
  wire [(`DEF_CP_I_MEM_ADDR_WIDTH-3):0]   wIF_ID_PC;                       // PC of the instruction at the current stage
  wire [(`DEF_CP_INS_WIDTH-1):0]          wIF_ID_Instruction;              // IF stage to ID stage instruction
  wire [(`RISC24_CP_BRANCHOP_WIDTH-1):0]  wIF_ID_Branch_Op;                // branch operation types
  wire [1:0]                              wIF_ID_Predication;

  wire                                    wSelect_First_PE;                // flag: select the data from first PE
  wire                                    wSelect_Last_PE;                 // flag: select the data from last PE

  // IF to RF
  wire [(`DEF_CP_RF_INDEX_WIDTH-1):0]     wIF_RF_Read_Addr_A;              // RF read port A address
  wire [(`DEF_CP_RF_INDEX_WIDTH-1):0]     wIF_RF_Read_Addr_B;              // RF read port B address

  // IF to bypass
  wire                                    wIF_BP_Select_Imm;               // indicate that the second operand is from immediate value
  wire                                    wIF_BP_Bypass_Read_A;            // flag that indicate RF read port A bypassed
  wire                                    wIF_BP_Bypass_Read_B;            // flag that indicate RF read port B bypassed
  wire [1:0]                              wIF_BP_Bypass_Sel_A;             // port A bypass source selection
  wire [1:0]                              wIF_BP_Bypass_Sel_B;             // port B bypass source selection

  // ID to IF
  wire [(`DEF_CP_I_MEM_ADDR_WIDTH-3):0]   wID_IF_Branch_Target_Addr;       // branch target address
  wire                                    wID_IF_Branch_Taken_Flag;        // branch taken flag:  1 = taken, 0 = not taken


  // ID to EX: RF write-back
  wire [(`DEF_CP_RF_INDEX_WIDTH-1):0]     wID_EX_RF_Write_Addr;            // Register file write-back address
  wire [(`RISC24_CP_RFWBOP_WIDTH-1):0]    wID_EX_RF_WriteBack;             // Register file write-back control.
                                                                           // Bit 0: register file write enable; Bit 1~2: ALU / LR (Link Register) / LSU / MUL

  wire                                    wID_EX_Write_Shadow_Register;    // Write the shadow register (write R31)

  // ID to EX: ALU
  wire [(`RISC24_CP_ALU_OP_WIDTH-1):0]    wID_EX_ALU_Opcode;               // ALU operation decoding
  wire [(`DEF_CP_DATA_WIDTH-1):0]         wID_EX_ALU_Operand_A;            // Operand A to the EX stage
  wire [(`DEF_CP_DATA_WIDTH-1):0]         wID_EX_ALU_Operand_B;            // Operand B to the EX stage


  // ID to EX: MUL/SHIFT/LOGIC
  wire [(`RISC24_CP_MULSHLOG_OP_WIDTH-1):0] wID_EX_MUL_SHIFT_LOGIC_Opcode; // mul/shift/rotate operation opcode
  wire [(`DEF_CP_DATA_WIDTH-1):0]         wID_EX_MUL_SHIFT_LOGIC_Operand_A;// Operand A to the EX stage for multiplication only
  wire [(`DEF_CP_DATA_WIDTH-1):0]         wID_EX_MUL_SHIFT_LOGIC_Operand_B;// Operand B to the EX stage for multiplication only

  // ID to EX: selection & other
  wire                                    wID_EX_Is_Multiplication;
  wire                                    wID_EX_Is_Shift;

  wire [(`DEF_CP_I_MEM_ADDR_WIDTH-3):0]   wID_EX_PC;                       // PC passes to EX-stage

  // ID to bypass
  wire [(`DEF_CP_DATA_WIDTH-1):0]         wID_BP_Immediate;                // sign-extended (to 32bit) immediate
  wire                                    wID_BP_Is_Long_Immediate;        // Flag: indicate the previous ins. is a long-imm ins.
  wire [(`DEF_CP_DATA_WIDTH-`DEF_CP_INS_IMM_WIDTH-1):0] wID_BP_Long_Immediate; // long immdediate register
  wire                                    wID_BP_Is_SUB;

  //ID to AGU
  wire [(`DEF_CP_DATA_WIDTH-1):0]         wID_AGU_Memory_Store_Data;
  wire                                    wID_AGU_Write_Enable;
  wire                                    wID_AGU_Read_Enable;
  wire [(`RISC24_CP_LSU_OP_WIDTH-1):0]    wID_AGU_LSU_Opcode;
  wire [(`DEF_CP_DATA_WIDTH-1):0]         wID_AGU_Operand_A;               // Operand A to the EX stage for LSU only
  wire [(`DEF_CP_DATA_WIDTH-1):0]         wID_AGU_Operand_B;               // Operand B to the EX stage for LSU only

  // RF to bypass
  wire [(`DEF_CP_DATA_WIDTH-1):0]         wRF_BP_Read_Data_A;              // RF read data from port A
  wire [(`DEF_CP_DATA_WIDTH-1):0]         wRF_BP_Read_Data_B;              // RF read data from port B

  // bypass to ID
  wire [(`DEF_CP_DATA_WIDTH-1):0]         wBP_ID_Operand_A;                // operand A
  wire [(`DEF_CP_DATA_WIDTH-1):0]         wBP_ID_Operand_B;                // operand B
  wire [(`DEF_CP_DATA_WIDTH-1):0]         wBP_ID_LSU_Store_Data;           // store data (for store instruction only)


  // EX to ID
  wire                                    wEX_ID_Flag_Register;            // value of the flag register (comparison result)
  wire                                    wEX_ID_P0;                       // value of P0 register
  wire                                    wEX_ID_P1;                       // value of P1 register

  // flag/P0/P1
  wire                                    wID_EX_Update_Flag;              // if set condition met in compare ins. update flag
  wire                                    wID_EX_Update_P0;                // if set condition met in compare ins. update P0
  wire                                    wID_EX_Update_P1;                // if set condition met in compare ins. update P1


  // EX to bypass
  wire [(`DEF_CP_DATA_WIDTH-1):0]         wEX_BP_ALU_Result;               // bypass src from ALU (and LR)
  wire [(`DEF_CP_DATA_WIDTH-1):0]         wEX_BP_MUL_Result;               // bypass src from MUL
  wire [(`DEF_CP_DATA_WIDTH-1):0]         wEX_BP_LSU_Result;               // bypass src from LSU
  wire [(`DEF_CP_DATA_WIDTH-1):0]         wEX_BP_Shadow_Result;            // bypass src from shadow register (R31)



  // EX to write-back
  wire [(`DEF_CP_DATA_WIDTH-1):0]         wEX_WB_Write_RF_Data;            // EX stage to WB stage data
  wire [(`DEF_CP_RF_INDEX_WIDTH-1):0]     wEX_WB_Write_RF_Address;         // EX stage to WB stage RF index
  wire                                    wEX_WB_Write_RF_Enable;          // EX stage to WB stage RF write enable


  // WB to RF
  wire                                    wWB_RF_Writeback_Enable;         // WB-stage RF write back enable
  wire [(`DEF_CP_RF_INDEX_WIDTH-1):0]     wWB_RF_Write_Addr;               // WB-stage RF write address
  wire [(`DEF_CP_DATA_WIDTH-1):0]         wWB_RF_Write_Data;               // WB-stage RF write dat

  // to instruction memory
  wire [(`DEF_CP_I_MEM_ADDR_WIDTH-3):0]   wIF_IMEM_Addr;                   // PC address to the insruction memory


//******************************
//  Behavioral Description
//******************************

// ===========
//  IF stage
// ===========
  assign oIF_ID_PC = wIF_ID_PC;

  cp_if inst_cp_if(
    .iClk                          ( iClk                           ),  // system clock, positive-edge trigger
    .iReset                        ( iReset                         ),  // global synchronous reset signal, Active high

    // from/to ID stage
    .iID_IF_Branch_Target_Addr     ( wID_IF_Branch_Target_Addr      ),  // branch target address
    .iID_IF_Branch_Taken_Flag      ( wID_IF_Branch_Taken_Flag       ),  // branch taken flag:  1 = taken, 0 = not taken

    .oIF_ID_PC                     ( wIF_ID_PC                      ),  // PC of the instruction at the current stage
    .oIF_ID_Instruction            ( wIF_ID_Instruction             ),  // IF stage to ID stage instruction
    .oIF_ID_Branch_Op              ( wIF_ID_Branch_Op               ),  // branch operation types
    .oSelect_First_PE              ( wSelect_First_PE               ),  // flag: select the data from first PE
    .oSelect_Last_PE               ( wSelect_Last_PE                ),  // flag: select the data from last PE
    .oPredication                  ( wIF_ID_Predication             ),  // IF-ID predication bits


    // to RF read ports
    .oIF_RF_Read_Addr_A            ( wIF_RF_Read_Addr_A             ),  // RF read port A address
    .oIF_RF_Read_Addr_B            ( wIF_RF_Read_Addr_B             ),  // RF read port B address

    // to bypass
    .oIF_BP_Select_Imm             ( wIF_BP_Select_Imm              ),  // indicate that the second operand is from immediate value
    .oIF_BP_Bypass_Read_A          ( wIF_BP_Bypass_Read_A           ),  // flag that indicate RF read port A bypassed
    .oIF_BP_Bypass_Read_B          ( wIF_BP_Bypass_Read_B           ),  // flag that indicate RF read port B bypassed
    .oIF_BP_Bypass_Sel_A           ( wIF_BP_Bypass_Sel_A            ),  // port A bypass source selection
    .oIF_BP_Bypass_Sel_B           ( wIF_BP_Bypass_Sel_B            ),  // port B bypass source selection

    // predication
    .iPredication                  ( iPredication                   ),  // cp predication bits

    // from/to instruction memory
    .iSelect_First_PE              ( iSelect_First_PE               ),  // flag: select the data from first PE
    .iSelect_Last_PE               ( iSelect_Last_PE                ),  // flag: select the data from last PE
    .iIMEM_IF_Instruction          ( iIMEM_IF_Instruction           ),  // instruction fetched from instruction memory
    .oIF_IMEM_Addr                 ( wIF_IMEM_Addr                  )   // PC address to the insruction memory
  );


// ===========
//  ID stage
// ===========
  cp_id inst_cp_id(
    .iClk                          ( iClk                           ),  // system clock, positive-edge trigger
    .iReset                        ( iReset                         ),  // global synchronous reset signal, Active high

    // to system top
    .oTask_Finished                ( oTask_Finished                 ),  // task ready

    // from/to IF stage
    .oID_IF_Branch_Target_Addr     ( wID_IF_Branch_Target_Addr      ),  // branch target address
    .oID_IF_Branch_Taken_Flag      ( wID_IF_Branch_Taken_Flag       ),  // branch taken flag:  1 = taken, 0 = not taken

    .iIF_ID_PC                     ( wIF_ID_PC                      ),  // PC of the instruction at the current stage
    .iIF_ID_Instruction            ( wIF_ID_Instruction             ),  // IF stage to ID stage instruction

    .iIF_ID_Branch_Op              ( wIF_ID_Branch_Op               ),  // branch operation types

    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication             ),  // IF-ID predication bits

    // from/to EX stage
    .iEX_ID_Flag_Register          ( wEX_ID_Flag_Register           ),  // value of the flag register (comparison result)
    .iEX_ID_P0                     ( wEX_ID_P0                      ),  // value of P1 register
    .iEX_ID_P1                     ( wEX_ID_P1                      ),  // value of P2 register


    .oID_EX_RF_Write_Addr          ( wID_EX_RF_Write_Addr           ),  // Register file write-back address
    .oID_EX_RF_WriteBack           ( wID_EX_RF_WriteBack            ),  // Register file write-back control.
                                                                        // Bit 0: register file write enable; Bit 1~2: ALU / LR (Link Register) / LSU / MUL

    .oID_EX_Write_Shadow_Register  ( wID_EX_Write_Shadow_Register   ),  // Write the shadow register (write R31)

    // ALU
    .oID_EX_ALU_Opcode             ( wID_EX_ALU_Opcode              ),  // ALU operation decoding
    .oID_EX_ALU_Operand_A          ( wID_EX_ALU_Operand_A           ),  // Operand A to the EX stage,
    .oID_EX_ALU_Operand_B          ( wID_EX_ALU_Operand_B           ),  // Operand B to the EX stage,

    // LSU
    .oID_EX_LSU_Memory_Write_Enable ( wID_AGU_Write_Enable          ),  // LSU stage data-memory write enable
    .oID_EX_LSU_Memory_Read_Enable  ( wID_AGU_Read_Enable           ),  // LSU stage data-memory read enable
    .oID_EX_LSU_Operand_A           ( wID_AGU_Operand_A             ),  // Operand A to the EX stage for LSU only
    .oID_EX_LSU_Operand_B           ( wID_AGU_Operand_B             ),  // Operand B to the EX stage for LSU only
    .oID_EX_LSU_Opcode              ( wID_AGU_LSU_Opcode            ),  // LSU opcoce: word/half-word/byte
    .oID_EX_LSU_Store_Data          ( wID_AGU_Memory_Store_Data     ),  // Store data to EX stage (for store instruction only)

    // MUL/SHIFT/LOGIC
    .oID_EX_MUL_SHIFT_LOGIC_Opcode    ( wID_EX_MUL_SHIFT_LOGIC_Opcode    ), // Shift and rotate operation opcode
    .oID_EX_MUL_SHIFT_LOGIC_Operand_A ( wID_EX_MUL_SHIFT_LOGIC_Operand_A ), // Operand A to the EX stage for multiplication only
    .oID_EX_MUL_SHIFT_LOGIC_Operand_B ( wID_EX_MUL_SHIFT_LOGIC_Operand_B ), // Operand B to the EX stage for multiplication only

    // Flag signals
    .oID_EX_Is_Multiplication      ( wID_EX_Is_Multiplication       ),
    .oID_EX_Is_Shift               ( wID_EX_Is_Shift                ),

    // flag/P0/P1
    .oID_EX_Update_Flag            ( wID_EX_Update_Flag             ),  // if set condition met in compare ins. update flag
    .oID_EX_Update_P0              ( wID_EX_Update_P0               ),  // if set condition met in compare ins. update P0
    .oID_EX_Update_P1              ( wID_EX_Update_P1               ),  // if set condition met in compare ins. update P1

    // pc
    .oID_EX_PC                     ( wID_EX_PC                      ),  // PC followed to EX-stage

    .iRF_BP_Read_Data_B            ( wRF_BP_Read_Data_B             ),  // RF read data from port B

    // from/to bypass network
    .iBP_ID_Operand_A              ( wBP_ID_Operand_A               ),  // operand A
    .iBP_ID_Operand_B              ( wBP_ID_Operand_B               ),  // operand B
    .iBP_ID_LSU_Store_Data         ( wBP_ID_LSU_Store_Data          ),  // store data (for store instruction only)
    .oID_BP_Immediate              ( wID_BP_Immediate               ),  // sign-extended (to data-path width) immediate
    .oID_BP_Is_Long_Immediate      ( wID_BP_Is_Long_Immediate       ),  // Flag: indicate the previous ins. is a long-imm ins.
    .oID_BP_Long_Immediate         ( wID_BP_Long_Immediate          ),  // long immdediate register
    .oID_BP_Is_SUB                 ( wID_BP_Is_SUB                  )
  );

  cp_agu inst_cp_agu (
    .iClk                           ( iClk                           ), // system clock, positive-edge trigger
    .iReset                         ( iReset                         ), // global synchronous reset signal, Active high

    .iID_AGU_Operand_A              ( wID_AGU_Operand_A              ), // Operand A to the EX stage for LSU only
    .iID_AGU_Operand_B              ( wID_AGU_Operand_B              ), // Operand B to the EX stage for LSU only

    .iID_AGU_Memory_Write_Enable    ( wID_AGU_Write_Enable           ), // Write enable from ID
    .iID_AGU_Memory_Read_Enable     ( wID_AGU_Read_Enable            ), // Read enable from ID
    .iID_AGU_Memory_Opcode          ( wID_AGU_LSU_Opcode             ),  // LSU opcoce: word/half-word/byte
    .iID_AGU_Memory_Store_Data      ( wID_AGU_Memory_Store_Data      ),

    .oAGU_DMEM_Memory_Write_Enable  ( oAGU_DMEM_Write_Enable         ), // Write enable to DMEM
    .oAGU_DMEM_Memory_Read_Enable   ( oAGU_DMEM_Read_Enable          ), // Read enable to DMEM
    .oAGU_DMEM_Byte_Select          ( oAGU_DMEM_Byte_Select          ), 
    .oAGU_DMEM_Opcode               ( oAGU_DMEM_Opcode               ),
    .oAGU_DMEM_Memory_Store_Data    ( oAGU_DMEM_Store_Data           ),
    .oAGU_DMEM_Address              ( oAGU_DMEM_Address              )  // Address to DMEM
);


  // RF module
  cp_rf inst_cp_rf (
    .iClk                          ( iClk                           ),  // system clock, positive-edge trigger
    //.iReset                      ( iReset                         ),  // global synchronous reset signal, Active high

    // from IF stage
    .iIF_RF_Read_Addr_A            ( wIF_RF_Read_Addr_A             ),  // RF read port A address
    .iIF_RF_Read_Addr_B            ( wIF_RF_Read_Addr_B             ),  // RF read port B address

    // to bypass
    .oRF_BP_Read_Data_A            ( wRF_BP_Read_Data_A             ),  // RF read data from port A
    .oRF_BP_Read_Data_B            ( wRF_BP_Read_Data_B             ),  // RF read data from port B

    // from WB stage
    .iWB_RF_Write_Addr             ( wWB_RF_Write_Addr              ),  // RF write address
    .iWB_RF_Write_Data             ( wWB_RF_Write_Data              ),  // RF write data
    .iWB_RF_Write_Enable           ( wWB_RF_Writeback_Enable        )   // RF write enable signal
  );


  // bypass module
  cp_bypass inst_cp_bypass(
    // from WB stage for RF internal bypass
    .iWB_RF_Write_Addr             ( wWB_RF_Write_Addr              ),  // RF write address
    .iWB_RF_Write_Data             ( wWB_RF_Write_Data              ),  // RF write data

    // from IF stage
    .iIF_RF_Read_Addr_A            ( wIF_RF_Read_Addr_A             ),  // RF read port A address
    .iIF_RF_Read_Addr_B            ( wIF_RF_Read_Addr_B             ),  // RF read port B address
    .iIF_BP_Select_Imm             ( wIF_BP_Select_Imm              ),  // indicate that the second operand is from immediate value
    .iIF_BP_Bypass_Read_A          ( wIF_BP_Bypass_Read_A           ),  // flag that indicate RF read port A bypassed
    .iIF_BP_Bypass_Read_B          ( wIF_BP_Bypass_Read_B           ),  // flag that indicate RF read port B bypassed
    .iIF_BP_Bypass_Sel_A           ( wIF_BP_Bypass_Sel_A            ),  // port A bypass source selection
    .iIF_BP_Bypass_Sel_B           ( wIF_BP_Bypass_Sel_B            ),  // port B bypass source selection

    // from/to ID stage
    .iID_BP_Immediate              ( wID_BP_Immediate               ),  // sign-extended (to data-path width) immediate
    .iID_BP_Is_Long_Immediate      ( wID_BP_Is_Long_Immediate       ),  // Flag: indicate the previous ins. is a long-imm ins.
    .iID_BP_Long_Immediate         ( wID_BP_Long_Immediate          ),  // long immdediate register
    .iID_BP_Is_SUB                 ( wID_BP_Is_SUB                  ),  // current ins. is SUB
    .oBP_ID_Operand_A              ( wBP_ID_Operand_A               ),  // operand A
    .oBP_ID_Operand_B              ( wBP_ID_Operand_B               ),  // operand B
    .oBP_ID_LSU_Store_Data         ( wBP_ID_LSU_Store_Data          ),  // store data (for store instruction only)

    // from Regiser File
    .iRF_BP_Read_Data_A            ( wRF_BP_Read_Data_A             ),  // RF read data from port A
    .iRF_BP_Read_Data_B            ( wRF_BP_Read_Data_B             ),  // RF read data from port B

    // from first/last PE
    .iFirst_PE_Port1_Data          ( iFirst_PE_Port1_Data           ),  // data from first PE RF port 1
    .iSelect_First_PE              ( wSelect_First_PE               ),  // flag: select the data from first PE
    .iLast_PE_Port1_Data           ( iLast_PE_Port1_Data            ),  // data from last PE RF port 1
    .iSelect_Last_PE               ( wSelect_Last_PE                ),  // flag: select the data from last PE

    // to PEs
    .oCP_Port1_Data                ( oCP_Port1_Data                 ),  // cp port 1 data to pe

    // from EX
    .iEX_BP_ALU_Result             ( wEX_BP_ALU_Result              ),  // bypass src from ALU (and LR)
    .iEX_BP_MUL_Result             ( wEX_BP_MUL_Result              ),  // bypass src from MUL
    .iEX_BP_LSU_Result             ( wEX_BP_LSU_Result              ),  // bypass src from LSU
    .iEX_BP_Shadow_Result          ( wEX_BP_Shadow_Result           )   // bypass src from shadow register (R31)
  );


// ===========
//  EX stage
// ===========
  cp_ex inst_cp_ex(
    .iClk                          ( iClk                           ),  // system clock, positive-edge trigger
    .iReset                        ( iReset                         ),  // global synchronous reset signal, Active high

    // from/to EX stage
    .oEX_ID_Flag_Register          ( wEX_ID_Flag_Register           ),  // value of the flag register (comparison result)
    .oEX_ID_P0                     ( wEX_ID_P0                      ),  // value of P1 register
    .oEX_ID_P1                     ( wEX_ID_P1                      ),  // value of P2 register

    .iID_EX_Update_Flag            ( wID_EX_Update_Flag             ), // if set condition met in compare ins. update flag
    .iID_EX_Update_P0              ( wID_EX_Update_P0               ), // if set condition met in compare ins. update P0
    .iID_EX_Update_P1              ( wID_EX_Update_P1               ), // if set condition met in compare ins. update P1

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

    .iID_EX_PC                     ( wID_EX_PC                      ),  // PC followed to EX-stage

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
  cp_wb inst_cp_wb(
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

  assign oIF_IMEM_Address = wIF_IMEM_Addr;


endmodule