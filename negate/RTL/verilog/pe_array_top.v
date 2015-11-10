////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//    Module Name :  pe_array_top                                             //
//    Description :  Template for the top module of the PE array.             //
//                                                                            //
//    Author(s)   :  Yifan He                                                 //
//                   Dongrui She                                              //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

`include "def-pe.v"

// synopsys translate_off
`timescale 1ns / 1ps
// synopsys translate_on


module pe_array_top (
    iClk,                          // system clock, positive-edge trigger
    iReset,                        // global synchronous reset signal, Active high

    // from instruction memory
    iIMEM_IF_Instruction,          // instruction fetched from instruction memory

    // '00': select self; '01': select data from right PE; '10': select data from left PE; '11': select data from CP
    iData_Selection,               // data selection bits

    // boundary mode  
    iBoundary_Mode_First_PE,
    iBoundary_Mode_Last_PE,

    // predication
    iPredication,                  // cp predication bits: '00'-always; '01'-P0; '10'-P1; '11'-P0&P1
    
    // PE 0
    oPE0_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE0_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE0_AGU_DMEM_Address,         // Address to DMEM
    oPE0_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE0_AGU_DMEM_Byte_Select,
    oPE0_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE0_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 1
    oPE1_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE1_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE1_AGU_DMEM_Address,         // Address to DMEM
    oPE1_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE1_AGU_DMEM_Byte_Select,
    oPE1_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE1_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 2
    oPE2_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE2_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE2_AGU_DMEM_Address,         // Address to DMEM
    oPE2_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE2_AGU_DMEM_Byte_Select,
    oPE2_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE2_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 3
    oPE3_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE3_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE3_AGU_DMEM_Address,         // Address to DMEM
    oPE3_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE3_AGU_DMEM_Byte_Select,
    oPE3_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE3_DMEM_EX_Data,             // data loaded from data memory
    
    // from/to CP
    iCP_Data,                      // data from cp
    oFirst_PE_Port1_Data,          // data from PE0 RF port 1
    oLast_PE_Port1_Data            // data from PE1 RF port 1
);


//******************************
//  Local Parameter Definition
//******************************



//****************************
//  Input/Output Declaration
//****************************

  input                                   iClk;                            // system clock, positive-edge trigger
  input                                   iReset;                          // global synchronous reset signal, Active high

  // from instruction memory
  input  [(`DEF_PE_INS_WIDTH-1):0]        iIMEM_IF_Instruction;            // instruction fetched from instruction memory

  input  [2:0]                            iData_Selection;                 // data selection bits

  // boundary mode  
  input  [1:0]                            iBoundary_Mode_First_PE;
  input  [1:0]                            iBoundary_Mode_Last_PE;

  // predication
  input  [1:0]                            iPredication;

  // from/to CP
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iCP_Data;                        // data from cp
  output [(`DEF_PE_DATA_WIDTH-1):0]       oFirst_PE_Port1_Data;            // data from PE0 RF port 1
  output [(`DEF_PE_DATA_WIDTH-1):0]       oLast_PE_Port1_Data;             // data from PE1 RF port 1
  
  // PE 0
  output                                  oPE0_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE0_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE0_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE0_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE0_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE0_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE0_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 1
  output                                  oPE1_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE1_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE1_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE1_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE1_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE1_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE1_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 2
  output                                  oPE2_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE2_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE2_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE2_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE2_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE2_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE2_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 3
  output                                  oPE3_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE3_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE3_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE3_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE3_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE3_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE3_DMEM_EX_Data;               // data loaded from data memory
  


//******************************
//  Local Wire/Reg Declaration
//******************************

  // IF to ID
  wire [(`DEF_PE_INS_WIDTH-1):0]          wIF_ID_Instruction;              // IF stage to ID stage instruction
  wire [1:0]                              wIF_ID_Predication;


  // IF to RF
  wire [(`DEF_RF_INDEX_WIDTH-1):0]        wIF_RF_Read_Addr_A;              // RF read port A address
  wire [(`DEF_RF_INDEX_WIDTH-1):0]        wIF_RF_Read_Addr_B;              // RF read port B address

  // IF to bypass
  wire                                    wIF_BP_Select_Imm;               // indicate that the second operand is from immediate value
  wire                                    wIF_BP_Bypass_Read_A;            // flag that indicate RF read port A bypassed
  wire                                    wIF_BP_Bypass_Read_B;            // flag that indicate RF read port B bypassed
  wire [1:0]                              wIF_BP_Bypass_Sel_A;             // port A bypass source selection
  wire [1:0]                              wIF_BP_Bypass_Sel_B;             // port B bypass source selection
  wire [2:0]                              wIF_BP_Data_Selection;           // data selection bits

  // ID-1 to ID-2
  // RF write-back
  wire [(`DEF_RF_INDEX_WIDTH-1):0]        wID_ID_RF_Write_Addr;            // Register file write-back address
  wire [(`RISC24_RFWBOP_WIDTH-1):0]       wID_ID_RF_WriteBack;             // Register file write-back control.
                                                                           // Bit 0: register file write enable; Bit 1~2: ALU / LR (Link Register) / LSU / MUL

  wire [1:0]                              wUpdate_Flag;                    // selection bits for updating flag/P0/P1

  // ALU
  wire [(`RISC24_ALU_OP_WIDTH-1):0]       wID_ID_ALU_Opcode;               // ALU operation decoding
  wire                                    wID_ID_Is_ALU;                   // is ALU operation

  // LSU
  wire                                    wID_ID_LSU_Write_Enable;         // LSU stage data-memory write enable
  wire                                    wID_ID_LSU_Read_Enable;          // LSU stage data-memory read enable
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wID_ID_LSU_Opcode;               // LSU opcoce: word/half-word/byte

  // MUL/SHIFT/LOGIC
  wire [(`RISC24_MULSHLOG_OP_WIDTH-1):0]  wID_ID_MUL_SHIFT_LOGIC_Opcode;   // mult/shift/logic operation opcode
  wire                                    wID_ID_Is_MUL;                   // is multiplication operation
  wire                                    wID_ID_Is_Shift;                 // is shift operation
  wire                                    wID_ID_Is_MUL_SHIFT_LOGIC;       // is mul/shift/logic operation

  // ID-1 to bypass network
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wID_BP_Immediate;                // sign-extended (to 32bit) immediate


  // ================================
  // PE neighbourhood communication
  // ================================
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE0_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE1_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE2_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE3_Port1_Data;
  
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wFirst_PE_Input_Data;
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wLast_PE_Input_Data;
  
  
//******************************
//  Behavioral Description
//******************************

  // pe array boundary mode setting
  always @ ( iBoundary_Mode_First_PE or iCP_Data or oFirst_PE_Port1_Data or oLast_PE_Port1_Data)
    case ( iBoundary_Mode_First_PE )
      `DEF_BOUNDARY_MODE_ZERO:
        wFirst_PE_Input_Data = 'b0;
      `DEF_BOUNDARY_MODE_SCALAR:
        wFirst_PE_Input_Data = iCP_Data;
      `DEF_BOUNDARY_MODE_WRAP:
        wFirst_PE_Input_Data = oLast_PE_Port1_Data;
      `DEF_BOUNDARY_MODE_SELF:
        wFirst_PE_Input_Data = oFirst_PE_Port1_Data;
      default:
        wFirst_PE_Input_Data = 'b0;  
    endcase
  // end of always
  

  always @ ( iBoundary_Mode_Last_PE or iCP_Data or oFirst_PE_Port1_Data or oLast_PE_Port1_Data)
    case ( iBoundary_Mode_Last_PE )
      `DEF_BOUNDARY_MODE_ZERO:
        wLast_PE_Input_Data = 'b0;
      `DEF_BOUNDARY_MODE_SCALAR:
        wLast_PE_Input_Data = iCP_Data;
      `DEF_BOUNDARY_MODE_WRAP:
        wLast_PE_Input_Data = oFirst_PE_Port1_Data;
      `DEF_BOUNDARY_MODE_SELF:
        wLast_PE_Input_Data = oLast_PE_Port1_Data;
      default:
        wLast_PE_Input_Data = 'b0;  
    endcase
  // end of always

// ===========
//  IF stage
// ===========
  pe_array_if inst_pe_array_if(
    .iClk                          ( iClk                           ),  // system clock, positive-edge trigger
    .iReset                        ( iReset                         ),  // global synchronous reset signal, Active high

    // to ID stage
    .oIF_ID_Instruction            ( wIF_ID_Instruction             ),  // IF stage to ID stage instruction
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
    .oIF_BP_Data_Selection         ( wIF_BP_Data_Selection          ),  // data selection bits

    // predication
    .iPredication                  ( iPredication                   ),  // cp predication bits

    // from instruction memory
    .iData_Selection               ( iData_Selection                ),  // data selection bits
    .iIMEM_IF_Instruction          ( iIMEM_IF_Instruction           )   // instruction fetched from instruction memory
  );


// ==============
//  ID stage - 1
// ==============
  pe_array_id inst_pe_array_id (
    .iClk                          ( iClk                           ),  // system clock, positive-edge trigger
    .iReset                        ( iReset                         ),  // global synchronous reset signal, Active high

    // from IF stage
    .iIF_ID_Instruction            ( wIF_ID_Instruction             ),  // IF stage to ID stage instruction

    // to ID-2
    // to RF write
    .oID_ID_RF_WriteBack           ( wID_ID_RF_WriteBack            ),  // Register file write-back address
    .oID_ID_RF_Write_Addr          ( wID_ID_RF_Write_Addr           ),  // Register file write-back control.
                                                                        // Bit 0: register file write enable; Bit 1~2: ALU / LR (Link Register) / LSU / MUL

    .oUpdate_Flag                  ( wUpdate_Flag                   ),  // selection bits for updating flag/P0/P1

    // ALU
    .oID_ID_ALU_Opcode             ( wID_ID_ALU_Opcode              ),  // ALU operation decoding
    .oID_ID_Is_ALU                 ( wID_ID_Is_ALU                  ),  // is ALU operation

    // LSU
    .oID_ID_LSU_Write_Enable       ( wID_ID_LSU_Write_Enable        ),  // LSU stage data-memory write enable
    .oID_ID_LSU_Read_Enable        ( wID_ID_LSU_Read_Enable         ),  // LSU stage data-memory read enable
    .oID_ID_LSU_Opcode             ( wID_ID_LSU_Opcode              ),  // LSU opcoce: word/half-word/byte

    // MUL/SHIFT/LOGIC
    .oID_ID_MUL_SHIFT_LOGIC_Opcode ( wID_ID_MUL_SHIFT_LOGIC_Opcode  ),  // mult/shift/logic operation opcode
    .oID_ID_Is_MUL                 ( wID_ID_Is_MUL                  ),  // is multiplication operation
    .oID_ID_Is_Shift               ( wID_ID_Is_Shift                ),  // is shift operation
    .oID_ID_Is_MUL_SHIFT_LOGIC     ( wID_ID_Is_MUL_SHIFT_LOGIC      ),  // is mul/shift/logic operation

    // to bypass network
    .oID_BP_Immediate              ( wID_BP_Immediate               )   // sign-extended (to data-path width) immediate
  );


// ==============
//    PE Top
// ==============
  // PE to CP
  assign oFirst_PE_Port1_Data = wPE0_Port1_Data;                 // data from first PE RF port 1
  assign oLast_PE_Port1_Data  = wPE3_Port1_Data; // data from last  PE RF port 1
  
  pe_top #(
   .Para_PE_ID ( 32'd0 )   // use pe data width parameter later
  ) inst_pe_top_0 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wFirst_PE_Input_Data ),  // NOTE: for boundary PEs, we will support wrap-up/self/'0' later!
    .iLeft_PE_Port1_Minus4_Data    ( wPE{124}_Port1_Data  ),  // data from PE 124
    .iRight_PE_Port1_Data          ( wPE1_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE4_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE0_Port1_Data),  // data to left/right PE

    // IF to RF read ports
    .iIF_RF_Read_Addr_A            ( wIF_RF_Read_Addr_A),  // RF read port A address
    .iIF_RF_Read_Addr_B            ( wIF_RF_Read_Addr_B),  // RF read port B address

    // IF to bypass network
    .iIF_BP_Select_Imm             ( wIF_BP_Select_Imm   ),  // indicate that the second operand is from immediate value
    .iIF_BP_Bypass_Read_A          ( wIF_BP_Bypass_Read_A),  // flag that indicate RF read port A bypassed
    .iIF_BP_Bypass_Read_B          ( wIF_BP_Bypass_Read_B),  // flag that indicate RF read port B bypassed
    .iIF_BP_Bypass_Sel_A           ( wIF_BP_Bypass_Sel_A ),  // port A bypass source selection
    .iIF_BP_Bypass_Sel_B           ( wIF_BP_Bypass_Sel_B ),  // port B bypass source selection

    // ID-1 to ID-2
    // to RF write
    .iID_ID_RF_Write_Addr          ( wID_ID_RF_Write_Addr),  // Register file write-back address
    .iID_ID_RF_WriteBack           ( wID_ID_RF_WriteBack ),  // Register file write-back control
                                                             // Bit 0: register file write enable; Bit 1~2: ALU / LR (Link Register) / LSU / MUL

    // ALU
    .iID_ID_ALU_Opcode             ( wID_ID_ALU_Opcode),  // ALU operation decoding
    .iID_ID_Is_ALU                 ( wID_ID_Is_ALU    ),  // is ALU operation
    // LSU
    .iID_ID_LSU_Write_Enable       ( wID_ID_LSU_Write_Enable),  // LSU stage data-memory write enable
    .iID_ID_LSU_Read_Enable        ( wID_ID_LSU_Read_Enable ),  // LSU stage data-memory read enable
    .iID_ID_LSU_Opcode             ( wID_ID_LSU_Opcode      ),  // LSU opcoce: word/half-word/byte
    // MUL/SHIFT/LOGIC
    .iID_ID_MUL_SHIFT_LOGIC_Opcode ( wID_ID_MUL_SHIFT_LOGIC_Opcode),  // mult/shift/logic operation opcode
    .iID_ID_Is_MUL                 ( wID_ID_Is_MUL                ),  // is multiplication operation
    .iID_ID_Is_Shift               ( wID_ID_Is_Shift              ),  // is shift operation
    .iID_ID_Is_MUL_SHIFT_LOGIC     ( wID_ID_Is_MUL_SHIFT_LOGIC    ),  // is mul/shift/logic operation

    // ID-1 to bypass network
    .iID_BP_Immediate              ( wID_BP_Immediate),  // sign-extended (to data-path width) immediate

    // from/to data memory
    .oAGU_DMEM_Write_Enable        ( oPE0_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE0_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE0_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE0_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE0_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE0_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE0_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd1 )   // use pe data width parameter later
  ) inst_pe_top_1 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE0_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE125_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE2_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE5_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE1_Port1_Data),  // data to left/right PE

    // IF to RF read ports
    .iIF_RF_Read_Addr_A            ( wIF_RF_Read_Addr_A),  // RF read port A address
    .iIF_RF_Read_Addr_B            ( wIF_RF_Read_Addr_B),  // RF read port B address

    // IF to bypass network
    .iIF_BP_Select_Imm             ( wIF_BP_Select_Imm   ),  // indicate that the second operand is from immediate value
    .iIF_BP_Bypass_Read_A          ( wIF_BP_Bypass_Read_A),  // flag that indicate RF read port A bypassed
    .iIF_BP_Bypass_Read_B          ( wIF_BP_Bypass_Read_B),  // flag that indicate RF read port B bypassed
    .iIF_BP_Bypass_Sel_A           ( wIF_BP_Bypass_Sel_A ),  // port A bypass source selection
    .iIF_BP_Bypass_Sel_B           ( wIF_BP_Bypass_Sel_B ),  // port B bypass source selection

    // ID-1 to ID-2
    // to RF write
    .iID_ID_RF_Write_Addr          ( wID_ID_RF_Write_Addr),  // Register file write-back address
    .iID_ID_RF_WriteBack           ( wID_ID_RF_WriteBack ),  // Register file write-back control
                                                             // Bit 0: register file write enable; Bit 1~2: ALU / LR (Link Register) / LSU / MUL

    // ALU
    .iID_ID_ALU_Opcode             ( wID_ID_ALU_Opcode),  // ALU operation decoding
    .iID_ID_Is_ALU                 ( wID_ID_Is_ALU    ),  // is ALU operation
    // LSU
    .iID_ID_LSU_Write_Enable       ( wID_ID_LSU_Write_Enable),  // LSU stage data-memory write enable
    .iID_ID_LSU_Read_Enable        ( wID_ID_LSU_Read_Enable ),  // LSU stage data-memory read enable
    .iID_ID_LSU_Opcode             ( wID_ID_LSU_Opcode      ),  // LSU opcoce: word/half-word/byte
    // MUL/SHIFT/LOGIC
    .iID_ID_MUL_SHIFT_LOGIC_Opcode ( wID_ID_MUL_SHIFT_LOGIC_Opcode),  // mult/shift/logic operation opcode
    .iID_ID_Is_MUL                 ( wID_ID_Is_MUL                ),  // is multiplication operation
    .iID_ID_Is_Shift               ( wID_ID_Is_Shift              ),  // is shift operation
    .iID_ID_Is_MUL_SHIFT_LOGIC     ( wID_ID_Is_MUL_SHIFT_LOGIC    ),  // is mul/shift/logic operation

    // ID-1 to bypass network
    .iID_BP_Immediate              ( wID_BP_Immediate),  // sign-extended (to data-path width) immediate

    // from/to data memory
    .oAGU_DMEM_Write_Enable        ( oPE1_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE1_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE1_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE1_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE1_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE1_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE1_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd2 )   // use pe data width parameter later
  ) inst_pe_top_2 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE1_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE126_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE3_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE6_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE2_Port1_Data),  // data to left/right PE

    // IF to RF read ports
    .iIF_RF_Read_Addr_A            ( wIF_RF_Read_Addr_A),  // RF read port A address
    .iIF_RF_Read_Addr_B            ( wIF_RF_Read_Addr_B),  // RF read port B address

    // IF to bypass network
    .iIF_BP_Select_Imm             ( wIF_BP_Select_Imm   ),  // indicate that the second operand is from immediate value
    .iIF_BP_Bypass_Read_A          ( wIF_BP_Bypass_Read_A),  // flag that indicate RF read port A bypassed
    .iIF_BP_Bypass_Read_B          ( wIF_BP_Bypass_Read_B),  // flag that indicate RF read port B bypassed
    .iIF_BP_Bypass_Sel_A           ( wIF_BP_Bypass_Sel_A ),  // port A bypass source selection
    .iIF_BP_Bypass_Sel_B           ( wIF_BP_Bypass_Sel_B ),  // port B bypass source selection

    // ID-1 to ID-2
    // to RF write
    .iID_ID_RF_Write_Addr          ( wID_ID_RF_Write_Addr),  // Register file write-back address
    .iID_ID_RF_WriteBack           ( wID_ID_RF_WriteBack ),  // Register file write-back control
                                                             // Bit 0: register file write enable; Bit 1~2: ALU / LR (Link Register) / LSU / MUL

    // ALU
    .iID_ID_ALU_Opcode             ( wID_ID_ALU_Opcode),  // ALU operation decoding
    .iID_ID_Is_ALU                 ( wID_ID_Is_ALU    ),  // is ALU operation
    // LSU
    .iID_ID_LSU_Write_Enable       ( wID_ID_LSU_Write_Enable),  // LSU stage data-memory write enable
    .iID_ID_LSU_Read_Enable        ( wID_ID_LSU_Read_Enable ),  // LSU stage data-memory read enable
    .iID_ID_LSU_Opcode             ( wID_ID_LSU_Opcode      ),  // LSU opcoce: word/half-word/byte
    // MUL/SHIFT/LOGIC
    .iID_ID_MUL_SHIFT_LOGIC_Opcode ( wID_ID_MUL_SHIFT_LOGIC_Opcode),  // mult/shift/logic operation opcode
    .iID_ID_Is_MUL                 ( wID_ID_Is_MUL                ),  // is multiplication operation
    .iID_ID_Is_Shift               ( wID_ID_Is_Shift              ),  // is shift operation
    .iID_ID_Is_MUL_SHIFT_LOGIC     ( wID_ID_Is_MUL_SHIFT_LOGIC    ),  // is mul/shift/logic operation

    // ID-1 to bypass network
    .iID_BP_Immediate              ( wID_BP_Immediate),  // sign-extended (to data-path width) immediate

    // from/to data memory
    .oAGU_DMEM_Write_Enable        ( oPE2_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE2_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE2_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE2_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE2_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE2_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE2_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd3 )   // use pe data width parameter later
  ) inst_pe_top_3 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE2_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE127_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wLast_PE_Input_Data  ),  // NOTE: for boundary PEs, we will support wrap-up/self/'0' later!
    .iRight_PE_Port1_Plus4_Data    ( wPE{3}_Port1_Data    ),  // data from PE 3 
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE3_Port1_Data),  // data to left/right PE

    // IF to RF read ports
    .iIF_RF_Read_Addr_A            ( wIF_RF_Read_Addr_A),  // RF read port A address
    .iIF_RF_Read_Addr_B            ( wIF_RF_Read_Addr_B),  // RF read port B address

    // IF to bypass network
    .iIF_BP_Select_Imm             ( wIF_BP_Select_Imm   ),  // indicate that the second operand is from immediate value
    .iIF_BP_Bypass_Read_A          ( wIF_BP_Bypass_Read_A),  // flag that indicate RF read port A bypassed
    .iIF_BP_Bypass_Read_B          ( wIF_BP_Bypass_Read_B),  // flag that indicate RF read port B bypassed
    .iIF_BP_Bypass_Sel_A           ( wIF_BP_Bypass_Sel_A ),  // port A bypass source selection
    .iIF_BP_Bypass_Sel_B           ( wIF_BP_Bypass_Sel_B ),  // port B bypass source selection

    // ID-1 to ID-2
    // to RF write
    .iID_ID_RF_Write_Addr          ( wID_ID_RF_Write_Addr),  // Register file write-back address
    .iID_ID_RF_WriteBack           ( wID_ID_RF_WriteBack ),  // Register file write-back control
                                                             // Bit 0: register file write enable; Bit 1~2: ALU / LR (Link Register) / LSU / MUL

    // ALU
    .iID_ID_ALU_Opcode             ( wID_ID_ALU_Opcode),  // ALU operation decoding
    .iID_ID_Is_ALU                 ( wID_ID_Is_ALU    ),  // is ALU operation
    // LSU
    .iID_ID_LSU_Write_Enable       ( wID_ID_LSU_Write_Enable),  // LSU stage data-memory write enable
    .iID_ID_LSU_Read_Enable        ( wID_ID_LSU_Read_Enable ),  // LSU stage data-memory read enable
    .iID_ID_LSU_Opcode             ( wID_ID_LSU_Opcode      ),  // LSU opcoce: word/half-word/byte
    // MUL/SHIFT/LOGIC
    .iID_ID_MUL_SHIFT_LOGIC_Opcode ( wID_ID_MUL_SHIFT_LOGIC_Opcode),  // mult/shift/logic operation opcode
    .iID_ID_Is_MUL                 ( wID_ID_Is_MUL                ),  // is multiplication operation
    .iID_ID_Is_Shift               ( wID_ID_Is_Shift              ),  // is shift operation
    .iID_ID_Is_MUL_SHIFT_LOGIC     ( wID_ID_Is_MUL_SHIFT_LOGIC    ),  // is mul/shift/logic operation

    // ID-1 to bypass network
    .iID_BP_Immediate              ( wID_BP_Immediate),  // sign-extended (to data-path width) immediate

    // from/to data memory
    .oAGU_DMEM_Write_Enable        ( oPE3_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE3_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE3_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE3_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE3_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE3_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE3_DMEM_EX_Data         )   // data loaded from data memory
  );
  
//*********************
//  Output Assignment
//*********************
endmodule