////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//    Module Name :  core_top                                                 //
//    Description :  Template for the top module of the the SIMD core,        //
//                   including CP and PE array, but without all the memory    //
//                   modules.                                                 //
//                                                                            //
//    Author(s)   :  Yifan He                                                 //
//                   Dongrui She                                              //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

`include "def-cp.v"
`include "def-pe.v"

// synopsys translate_off
`timescale 1ns / 1ps
// synopsys translate_on


module core_top (
  iClk,                             // system clock, positive-edge trigger
  iReset,                           // global synchronous reset signal, Active high

  oIF_ID_PC,                        // current PC for debug
  oTask_Finished,                   // indicate the end of the program

  // -----
  //  CP
  // -----
  oIF_IMEM_Address,                // instruciton memory address
  iIMEM_CP_Instruction,            // DEF_CP_INS_WIDTH + 2 bits communication + 2-bit predication

  oCP_DMEM_Valid,                  // memory access valid
  oCP_AGU_DMEM_Write_Enable,       // LSU stage data-memory write enable
  oCP_AGU_DMEM_Read_Enable,        // LSU stage data-memory read enable
  oCP_AGU_DMEM_Byte_Select,        // byte selection signal
  oCP_AGU_DMEM_Address,
  oCP_AGU_DMEM_Write_Data,         // Store data to EX stage (for store instruction only)
  iCP_DMEM_EX_Data,                // data loaded from data memory
  
  // PE0
  oPE0_DMEM_Valid,
  oPE0_AGU_DMEM_Write_Enable, // data memory write enable
  oPE0_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE0_AGU_DMEM_Byte_Select,
  oPE0_AGU_DMEM_Address,      // address to DMEM
  oPE0_AGU_DMEM_Write_Data,   // data memory write data
  iPE0_DMEM_EX_Data,          // data loaded from data memory
  
  // PE1
  oPE1_DMEM_Valid,
  oPE1_AGU_DMEM_Write_Enable, // data memory write enable
  oPE1_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE1_AGU_DMEM_Byte_Select,
  oPE1_AGU_DMEM_Address,      // address to DMEM
  oPE1_AGU_DMEM_Write_Data,   // data memory write data
  iPE1_DMEM_EX_Data,          // data loaded from data memory
  
  // PE2
  oPE2_DMEM_Valid,
  oPE2_AGU_DMEM_Write_Enable, // data memory write enable
  oPE2_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE2_AGU_DMEM_Byte_Select,
  oPE2_AGU_DMEM_Address,      // address to DMEM
  oPE2_AGU_DMEM_Write_Data,   // data memory write data
  iPE2_DMEM_EX_Data,          // data loaded from data memory
  
  // PE3
  oPE3_DMEM_Valid,
  oPE3_AGU_DMEM_Write_Enable, // data memory write enable
  oPE3_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE3_AGU_DMEM_Byte_Select,
  oPE3_AGU_DMEM_Address,      // address to DMEM
  oPE3_AGU_DMEM_Write_Data,   // data memory write data
  iPE3_DMEM_EX_Data,          // data loaded from data memory
  
  // PE4
  oPE4_DMEM_Valid,
  oPE4_AGU_DMEM_Write_Enable, // data memory write enable
  oPE4_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE4_AGU_DMEM_Byte_Select,
  oPE4_AGU_DMEM_Address,      // address to DMEM
  oPE4_AGU_DMEM_Write_Data,   // data memory write data
  iPE4_DMEM_EX_Data,          // data loaded from data memory
  
  // PE5
  oPE5_DMEM_Valid,
  oPE5_AGU_DMEM_Write_Enable, // data memory write enable
  oPE5_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE5_AGU_DMEM_Byte_Select,
  oPE5_AGU_DMEM_Address,      // address to DMEM
  oPE5_AGU_DMEM_Write_Data,   // data memory write data
  iPE5_DMEM_EX_Data,          // data loaded from data memory
  
  // PE6
  oPE6_DMEM_Valid,
  oPE6_AGU_DMEM_Write_Enable, // data memory write enable
  oPE6_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE6_AGU_DMEM_Byte_Select,
  oPE6_AGU_DMEM_Address,      // address to DMEM
  oPE6_AGU_DMEM_Write_Data,   // data memory write data
  iPE6_DMEM_EX_Data,          // data loaded from data memory
  
  // PE7
  oPE7_DMEM_Valid,
  oPE7_AGU_DMEM_Write_Enable, // data memory write enable
  oPE7_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE7_AGU_DMEM_Byte_Select,
  oPE7_AGU_DMEM_Address,      // address to DMEM
  oPE7_AGU_DMEM_Write_Data,   // data memory write data
  iPE7_DMEM_EX_Data,          // data loaded from data memory
  
  // -----
  //  PE
  // -----
  iIMEM_PE_Instruction           // instruction fetched from PE instruction memory
);

//******************************
//  Local Parameter Definition
//******************************



//****************************
//  Input/Output Declaration
//****************************

  input                                   iClk;                           // system clock, positive-edge trigger
  input                                   iReset;                         // global synchronous reset signal, Active high

  output [(`DEF_CP_I_MEM_ADDR_WIDTH-3):0] oIF_ID_PC;                      // current PC for debug
  output                                  oTask_Finished;                 // indicate task finished

  // -----
  //  CP
  // -----
  output [(`DEF_CP_I_MEM_ADDR_WIDTH-3):0] oIF_IMEM_Address;               // instruciton memory address
  input  [(`DEF_CP_INS_WIDTH+3):0]        iIMEM_CP_Instruction;           // DEF_CP_INS_WIDTH + 2 bits communication + 2-bit predication

  output                                  oCP_DMEM_Valid;
  output                                  oCP_AGU_DMEM_Write_Enable;      // LSU stage data-memory write enable
  output                                  oCP_AGU_DMEM_Read_Enable;       // LSU stage data-memory read enable
  output [(`DEF_CP_DATA_WIDTH/8-1):0]     oCP_AGU_DMEM_Byte_Select;
  output [(`DEF_CP_RAM_ADDR_BITS-1):0]    oCP_AGU_DMEM_Address;           // Address to DMEM
  output [(`DEF_CP_DATA_WIDTH-1):0]       oCP_AGU_DMEM_Write_Data;        // Store data to EX stage (for store instruction only)
  input  [(`DEF_CP_DATA_WIDTH-1):0]       iCP_DMEM_EX_Data;               // data loaded from data memory

  // -----
  //  PE
  // -----
  input  [(`DEF_PE_INS_WIDTH+4):0]        iIMEM_PE_Instruction;           // instruction fetched from PE instruction memory
  
  // PE0
  output                                  oPE0_DMEM_Valid;
  output                                  oPE0_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE0_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE0_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE0_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE0_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE0_DMEM_EX_Data;          // data loaded from data memory
  
  // PE1
  output                                  oPE1_DMEM_Valid;
  output                                  oPE1_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE1_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE1_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE1_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE1_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE1_DMEM_EX_Data;          // data loaded from data memory
  
  // PE2
  output                                  oPE2_DMEM_Valid;
  output                                  oPE2_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE2_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE2_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE2_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE2_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE2_DMEM_EX_Data;          // data loaded from data memory
  
  // PE3
  output                                  oPE3_DMEM_Valid;
  output                                  oPE3_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE3_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE3_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE3_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE3_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE3_DMEM_EX_Data;          // data loaded from data memory
  
  // PE4
  output                                  oPE4_DMEM_Valid;
  output                                  oPE4_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE4_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE4_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE4_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE4_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE4_DMEM_EX_Data;          // data loaded from data memory
  
  // PE5
  output                                  oPE5_DMEM_Valid;
  output                                  oPE5_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE5_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE5_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE5_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE5_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE5_DMEM_EX_Data;          // data loaded from data memory
  
  // PE6
  output                                  oPE6_DMEM_Valid;
  output                                  oPE6_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE6_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE6_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE6_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE6_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE6_DMEM_EX_Data;          // data loaded from data memory
  
  // PE7
  output                                  oPE7_DMEM_Valid;
  output                                  oPE7_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE7_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE7_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE7_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE7_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE7_DMEM_EX_Data;          // data loaded from data memory
  

//******************************
//  Local Wire/Reg Declaration
//******************************
  // cp memory
  wire [(`RISC24_CP_LSU_OP_WIDTH-1):0]    wCP_AGU_DMEM_Opcode;
  wire [(`DEF_CP_DATA_WIDTH-1):0]         wCP_AGU_DMEM_Address;           // cp dmem (byte) address
  wire [(`DEF_CP_DATA_WIDTH-1):0]         wCP_DMEM_EX_Data;
  wire                                    wCP_AGU_Write_Enable;

  reg  [(`DEF_CP_DATA_WIDTH-1):0]         wCP_DMEM_Read_Data;
  reg                                     PR_Special_Reg_Access;          // pipeline reg
  reg  [(`RISC24_CP_LSU_OP_WIDTH-1):0]    PR_CP_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_CP_AGU_DMEM_Addr_Last_Two;
  
  // pe memory
  
  // PE 0
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE0_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE0_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE0_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE0_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE0_AGU_DMEM_Addr_Last_Two;  
  
  // PE 1
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE1_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE1_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE1_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE1_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE1_AGU_DMEM_Addr_Last_Two;  
  
  // PE 2
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE2_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE2_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE2_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE2_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE2_AGU_DMEM_Addr_Last_Two;  
  
  // PE 3
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE3_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE3_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE3_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE3_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE3_AGU_DMEM_Addr_Last_Two;  
  
  // PE 4
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE4_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE4_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE4_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE4_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE4_AGU_DMEM_Addr_Last_Two;  
  
  // PE 5
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE5_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE5_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE5_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE5_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE5_AGU_DMEM_Addr_Last_Two;  
  
  // PE 6
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE6_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE6_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE6_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE6_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE6_AGU_DMEM_Addr_Last_Two;  
  
  // PE 7
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE7_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE7_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE7_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE7_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE7_AGU_DMEM_Addr_Last_Two;  
  

  // PE/CP communication
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wCP_Port1_Data;                 // cp port 1 data to pe
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wFirst_PE_Port1_Data;           // data from PE0 RF port 1
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wLast_PE_Port1_Data;            // data from PE1 RF port 1

  // special register access
  reg  [1:0]                              rBoundary_Mode_First_PE;
  reg  [1:0]                              rBoundary_Mode_Last_PE;
  wire                                    wSpecial_Reg_Access;
  reg  [(`DEF_CP_DATA_WIDTH-1):0]         rSpecial_Reg_Read_Data;
  

//******************************
//  Behavioral Description
//******************************

  // ==============================
  // PE data memory access handler
  // ==============================
  
  // PE 0
  assign oPE0_DMEM_Valid       = oPE0_AGU_DMEM_Write_Enable || oPE0_AGU_DMEM_Read_Enable;
  assign oPE0_AGU_DMEM_Address = wPE0_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE0_AGU_DMEM_Opcode        <= 'b0;
        PR_PE0_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE0_AGU_DMEM_Read_Enable )
      begin
        PR_PE0_AGU_DMEM_Opcode        <= wPE0_AGU_DMEM_Opcode;
        PR_PE0_AGU_DMEM_Addr_Last_Two <= wPE0_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE0_AGU_DMEM_Opcode or PR_PE0_AGU_DMEM_Addr_Last_Two or iPE0_DMEM_EX_Data )
    case ( PR_PE0_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE0_DMEM_EX_Data = iPE0_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE0_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE0_DMEM_EX_Data = {16'b0, iPE0_DMEM_EX_Data[15:0]};
        else
          wPE0_DMEM_EX_Data = {16'b0, iPE0_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE0_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE0_DMEM_EX_Data = {24'b0, iPE0_DMEM_EX_Data[7 : 0]};
          2'b01: wPE0_DMEM_EX_Data = {24'b0, iPE0_DMEM_EX_Data[15: 8]};
          2'b10: wPE0_DMEM_EX_Data = {24'b0, iPE0_DMEM_EX_Data[23:16]};
          2'b11: wPE0_DMEM_EX_Data = {24'b0, iPE0_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE0_DMEM_EX_Data = iPE0_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 1
  assign oPE1_DMEM_Valid       = oPE1_AGU_DMEM_Write_Enable || oPE1_AGU_DMEM_Read_Enable;
  assign oPE1_AGU_DMEM_Address = wPE1_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE1_AGU_DMEM_Opcode        <= 'b0;
        PR_PE1_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE1_AGU_DMEM_Read_Enable )
      begin
        PR_PE1_AGU_DMEM_Opcode        <= wPE1_AGU_DMEM_Opcode;
        PR_PE1_AGU_DMEM_Addr_Last_Two <= wPE1_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE1_AGU_DMEM_Opcode or PR_PE1_AGU_DMEM_Addr_Last_Two or iPE1_DMEM_EX_Data )
    case ( PR_PE1_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE1_DMEM_EX_Data = iPE1_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE1_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE1_DMEM_EX_Data = {16'b0, iPE1_DMEM_EX_Data[15:0]};
        else
          wPE1_DMEM_EX_Data = {16'b0, iPE1_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE1_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE1_DMEM_EX_Data = {24'b0, iPE1_DMEM_EX_Data[7 : 0]};
          2'b01: wPE1_DMEM_EX_Data = {24'b0, iPE1_DMEM_EX_Data[15: 8]};
          2'b10: wPE1_DMEM_EX_Data = {24'b0, iPE1_DMEM_EX_Data[23:16]};
          2'b11: wPE1_DMEM_EX_Data = {24'b0, iPE1_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE1_DMEM_EX_Data = iPE1_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 2
  assign oPE2_DMEM_Valid       = oPE2_AGU_DMEM_Write_Enable || oPE2_AGU_DMEM_Read_Enable;
  assign oPE2_AGU_DMEM_Address = wPE2_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE2_AGU_DMEM_Opcode        <= 'b0;
        PR_PE2_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE2_AGU_DMEM_Read_Enable )
      begin
        PR_PE2_AGU_DMEM_Opcode        <= wPE2_AGU_DMEM_Opcode;
        PR_PE2_AGU_DMEM_Addr_Last_Two <= wPE2_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE2_AGU_DMEM_Opcode or PR_PE2_AGU_DMEM_Addr_Last_Two or iPE2_DMEM_EX_Data )
    case ( PR_PE2_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE2_DMEM_EX_Data = iPE2_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE2_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE2_DMEM_EX_Data = {16'b0, iPE2_DMEM_EX_Data[15:0]};
        else
          wPE2_DMEM_EX_Data = {16'b0, iPE2_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE2_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE2_DMEM_EX_Data = {24'b0, iPE2_DMEM_EX_Data[7 : 0]};
          2'b01: wPE2_DMEM_EX_Data = {24'b0, iPE2_DMEM_EX_Data[15: 8]};
          2'b10: wPE2_DMEM_EX_Data = {24'b0, iPE2_DMEM_EX_Data[23:16]};
          2'b11: wPE2_DMEM_EX_Data = {24'b0, iPE2_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE2_DMEM_EX_Data = iPE2_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 3
  assign oPE3_DMEM_Valid       = oPE3_AGU_DMEM_Write_Enable || oPE3_AGU_DMEM_Read_Enable;
  assign oPE3_AGU_DMEM_Address = wPE3_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE3_AGU_DMEM_Opcode        <= 'b0;
        PR_PE3_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE3_AGU_DMEM_Read_Enable )
      begin
        PR_PE3_AGU_DMEM_Opcode        <= wPE3_AGU_DMEM_Opcode;
        PR_PE3_AGU_DMEM_Addr_Last_Two <= wPE3_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE3_AGU_DMEM_Opcode or PR_PE3_AGU_DMEM_Addr_Last_Two or iPE3_DMEM_EX_Data )
    case ( PR_PE3_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE3_DMEM_EX_Data = iPE3_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE3_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE3_DMEM_EX_Data = {16'b0, iPE3_DMEM_EX_Data[15:0]};
        else
          wPE3_DMEM_EX_Data = {16'b0, iPE3_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE3_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE3_DMEM_EX_Data = {24'b0, iPE3_DMEM_EX_Data[7 : 0]};
          2'b01: wPE3_DMEM_EX_Data = {24'b0, iPE3_DMEM_EX_Data[15: 8]};
          2'b10: wPE3_DMEM_EX_Data = {24'b0, iPE3_DMEM_EX_Data[23:16]};
          2'b11: wPE3_DMEM_EX_Data = {24'b0, iPE3_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE3_DMEM_EX_Data = iPE3_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 4
  assign oPE4_DMEM_Valid       = oPE4_AGU_DMEM_Write_Enable || oPE4_AGU_DMEM_Read_Enable;
  assign oPE4_AGU_DMEM_Address = wPE4_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE4_AGU_DMEM_Opcode        <= 'b0;
        PR_PE4_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE4_AGU_DMEM_Read_Enable )
      begin
        PR_PE4_AGU_DMEM_Opcode        <= wPE4_AGU_DMEM_Opcode;
        PR_PE4_AGU_DMEM_Addr_Last_Two <= wPE4_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE4_AGU_DMEM_Opcode or PR_PE4_AGU_DMEM_Addr_Last_Two or iPE4_DMEM_EX_Data )
    case ( PR_PE4_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE4_DMEM_EX_Data = iPE4_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE4_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE4_DMEM_EX_Data = {16'b0, iPE4_DMEM_EX_Data[15:0]};
        else
          wPE4_DMEM_EX_Data = {16'b0, iPE4_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE4_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE4_DMEM_EX_Data = {24'b0, iPE4_DMEM_EX_Data[7 : 0]};
          2'b01: wPE4_DMEM_EX_Data = {24'b0, iPE4_DMEM_EX_Data[15: 8]};
          2'b10: wPE4_DMEM_EX_Data = {24'b0, iPE4_DMEM_EX_Data[23:16]};
          2'b11: wPE4_DMEM_EX_Data = {24'b0, iPE4_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE4_DMEM_EX_Data = iPE4_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 5
  assign oPE5_DMEM_Valid       = oPE5_AGU_DMEM_Write_Enable || oPE5_AGU_DMEM_Read_Enable;
  assign oPE5_AGU_DMEM_Address = wPE5_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE5_AGU_DMEM_Opcode        <= 'b0;
        PR_PE5_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE5_AGU_DMEM_Read_Enable )
      begin
        PR_PE5_AGU_DMEM_Opcode        <= wPE5_AGU_DMEM_Opcode;
        PR_PE5_AGU_DMEM_Addr_Last_Two <= wPE5_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE5_AGU_DMEM_Opcode or PR_PE5_AGU_DMEM_Addr_Last_Two or iPE5_DMEM_EX_Data )
    case ( PR_PE5_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE5_DMEM_EX_Data = iPE5_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE5_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE5_DMEM_EX_Data = {16'b0, iPE5_DMEM_EX_Data[15:0]};
        else
          wPE5_DMEM_EX_Data = {16'b0, iPE5_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE5_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE5_DMEM_EX_Data = {24'b0, iPE5_DMEM_EX_Data[7 : 0]};
          2'b01: wPE5_DMEM_EX_Data = {24'b0, iPE5_DMEM_EX_Data[15: 8]};
          2'b10: wPE5_DMEM_EX_Data = {24'b0, iPE5_DMEM_EX_Data[23:16]};
          2'b11: wPE5_DMEM_EX_Data = {24'b0, iPE5_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE5_DMEM_EX_Data = iPE5_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 6
  assign oPE6_DMEM_Valid       = oPE6_AGU_DMEM_Write_Enable || oPE6_AGU_DMEM_Read_Enable;
  assign oPE6_AGU_DMEM_Address = wPE6_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE6_AGU_DMEM_Opcode        <= 'b0;
        PR_PE6_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE6_AGU_DMEM_Read_Enable )
      begin
        PR_PE6_AGU_DMEM_Opcode        <= wPE6_AGU_DMEM_Opcode;
        PR_PE6_AGU_DMEM_Addr_Last_Two <= wPE6_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE6_AGU_DMEM_Opcode or PR_PE6_AGU_DMEM_Addr_Last_Two or iPE6_DMEM_EX_Data )
    case ( PR_PE6_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE6_DMEM_EX_Data = iPE6_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE6_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE6_DMEM_EX_Data = {16'b0, iPE6_DMEM_EX_Data[15:0]};
        else
          wPE6_DMEM_EX_Data = {16'b0, iPE6_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE6_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE6_DMEM_EX_Data = {24'b0, iPE6_DMEM_EX_Data[7 : 0]};
          2'b01: wPE6_DMEM_EX_Data = {24'b0, iPE6_DMEM_EX_Data[15: 8]};
          2'b10: wPE6_DMEM_EX_Data = {24'b0, iPE6_DMEM_EX_Data[23:16]};
          2'b11: wPE6_DMEM_EX_Data = {24'b0, iPE6_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE6_DMEM_EX_Data = iPE6_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 7
  assign oPE7_DMEM_Valid       = oPE7_AGU_DMEM_Write_Enable || oPE7_AGU_DMEM_Read_Enable;
  assign oPE7_AGU_DMEM_Address = wPE7_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE7_AGU_DMEM_Opcode        <= 'b0;
        PR_PE7_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE7_AGU_DMEM_Read_Enable )
      begin
        PR_PE7_AGU_DMEM_Opcode        <= wPE7_AGU_DMEM_Opcode;
        PR_PE7_AGU_DMEM_Addr_Last_Two <= wPE7_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE7_AGU_DMEM_Opcode or PR_PE7_AGU_DMEM_Addr_Last_Two or iPE7_DMEM_EX_Data )
    case ( PR_PE7_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE7_DMEM_EX_Data = iPE7_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE7_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE7_DMEM_EX_Data = {16'b0, iPE7_DMEM_EX_Data[15:0]};
        else
          wPE7_DMEM_EX_Data = {16'b0, iPE7_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE7_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE7_DMEM_EX_Data = {24'b0, iPE7_DMEM_EX_Data[7 : 0]};
          2'b01: wPE7_DMEM_EX_Data = {24'b0, iPE7_DMEM_EX_Data[15: 8]};
          2'b10: wPE7_DMEM_EX_Data = {24'b0, iPE7_DMEM_EX_Data[23:16]};
          2'b11: wPE7_DMEM_EX_Data = {24'b0, iPE7_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE7_DMEM_EX_Data = iPE7_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  
  
  // ==============================
  // CP data memory access handler
  // ==============================
  assign oCP_DMEM_Valid = oCP_AGU_DMEM_Write_Enable || oCP_AGU_DMEM_Read_Enable;

  assign oCP_AGU_DMEM_Address      = wCP_AGU_DMEM_Address[(`DEF_CP_RAM_ADDR_BITS+1):2];
  assign oCP_AGU_DMEM_Write_Enable = wCP_AGU_Write_Enable && (~wSpecial_Reg_Access); 
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_Special_Reg_Access        <= 'b0;
        PR_CP_AGU_DMEM_Opcode        <= 'b0;
        PR_CP_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oCP_AGU_DMEM_Read_Enable )
      begin
        PR_Special_Reg_Access        <= wSpecial_Reg_Access;
        PR_CP_AGU_DMEM_Opcode        <= wCP_AGU_DMEM_Opcode; 
        PR_CP_AGU_DMEM_Addr_Last_Two <= wCP_AGU_DMEM_Address[1:0];
      end
  // end of always
    
  
  // if cp-data-width = 32bit
  always @ ( PR_CP_AGU_DMEM_Opcode or PR_CP_AGU_DMEM_Addr_Last_Two or iCP_DMEM_EX_Data )
    case ( PR_CP_AGU_DMEM_Opcode )
      `RISC24_CP_LSU_OP_WORD: begin
        wCP_DMEM_Read_Data = iCP_DMEM_EX_Data;
      end
      
      `RISC24_CP_LSU_OP_HALF_WORD: begin
        if ( PR_CP_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wCP_DMEM_Read_Data = {16'b0, iCP_DMEM_EX_Data[15:0]};
        else
          wCP_DMEM_Read_Data = {16'b0, iCP_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_CP_LSU_OP_BYTE: begin
        case (PR_CP_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wCP_DMEM_Read_Data = {24'b0, iCP_DMEM_EX_Data[7 : 0]};
          2'b01: wCP_DMEM_Read_Data = {24'b0, iCP_DMEM_EX_Data[15: 8]};
          2'b10: wCP_DMEM_Read_Data = {24'b0, iCP_DMEM_EX_Data[23:16]};
          2'b11: wCP_DMEM_Read_Data = {24'b0, iCP_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wCP_DMEM_Read_Data = iCP_DMEM_EX_Data;
      end
    endcase
  // end of always
  

  assign wCP_DMEM_EX_Data = PR_Special_Reg_Access ? rSpecial_Reg_Read_Data : wCP_DMEM_Read_Data;
  

  // =====================
  //  special register(s)
  // =====================
  // speical register memory-mapped space: 0xFFFF_FF00 ~ 0xFFFF_FFFF
  assign wSpecial_Reg_Access = ( &wCP_AGU_DMEM_Address[(`DEF_CP_DATA_WIDTH-1):8] );
  
  // reg write
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        rBoundary_Mode_First_PE <= `DEF_BOUNDARY_MODE_ZERO;
        rBoundary_Mode_Last_PE  <= `DEF_BOUNDARY_MODE_ZERO;
      end
    else if ( wSpecial_Reg_Access && wCP_AGU_Write_Enable )
      begin
        if ( wCP_AGU_DMEM_Address[7:0] == `DEF_BOUNDARY_MODE_FIRST_ADDR )
          rBoundary_Mode_First_PE <= oCP_AGU_DMEM_Write_Data[1:0];
        
        if ( wCP_AGU_DMEM_Address[7:0] == `DEF_BOUNDARY_MODE_LAST_ADDR )
          rBoundary_Mode_Last_PE  <= oCP_AGU_DMEM_Write_Data[1:0];
      end
  // end of always
  
  // reg read
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      rSpecial_Reg_Read_Data <= 'b0;
    else if ( wSpecial_Reg_Access && oCP_AGU_DMEM_Read_Enable ) begin
      if ( wCP_AGU_DMEM_Address[7:0] == `DEF_BOUNDARY_MODE_FIRST_ADDR )
        rSpecial_Reg_Read_Data <= { {30{1'b0} }, rBoundary_Mode_First_PE};
      else //if ( wCP_AGU_DMEM_Address[7:0] == `DEF_BOUNDARY_MODE_LAST_ADDR )
        rSpecial_Reg_Read_Data <= { {30{1'b0} }, rBoundary_Mode_Last_PE};
    end
  // end of always    
    

  // ===============
  //  CP top module
  // ===============
  cp_top inst_cp_top(
    .iClk                          ( iClk                     ),  // system clock, positive-edge trigger
    .iReset                        ( iReset                   ),  // global synchronous reset signal, Active high

    .oIF_ID_PC                     ( oIF_ID_PC                ),  // current PC for debug
    .oTask_Finished                ( oTask_Finished           ),  // indicate the end of the program

    // to PE Instruciton memory
    .oIF_IMEM_Address              ( oIF_IMEM_Address         ),  // instruciton memory address
    .iIMEM_IF_Instruction          ( iIMEM_CP_Instruction[(`DEF_CP_INS_WIDTH-1):0] ),  // instruction fetched from instruction memory

    // from/to cp data memory
    .oAGU_DMEM_Write_Enable        ( wCP_AGU_Write_Enable     ),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oCP_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( wCP_AGU_DMEM_Address     ),  // cp-dmem byte address
    .oAGU_DMEM_Byte_Select         ( oCP_AGU_DMEM_Byte_Select ), 
    .oAGU_DMEM_Opcode              ( wCP_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oCP_AGU_DMEM_Write_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( wCP_DMEM_EX_Data         ),  // data loaded from data memory

    // predication
    .iPredication                  ( iIMEM_CP_Instruction[(`DEF_CP_INS_WIDTH+3):(`DEF_CP_INS_WIDTH+2)] ), // cp predication bits

    // CP-PE communication
    .oCP_Port1_Data                ( wCP_Port1_Data           ),  // cp port 1 data to pe
    .iFirst_PE_Port1_Data          ( wFirst_PE_Port1_Data     ),  // data from first PE RF port 1
    .iSelect_First_PE              ( iIMEM_CP_Instruction[`DEF_CP_INS_WIDTH+1] ),  // flag: select the data from first PE
    .iLast_PE_Port1_Data           ( wLast_PE_Port1_Data      ),  // data from last PE RF port 1
    .iSelect_Last_PE               ( iIMEM_CP_Instruction[`DEF_CP_INS_WIDTH] )   // flag: select the data from last PE
  );


  // ===============
  //  PE top module
  // ===============
  pe_array_top inst_pe_array_top (
    .iClk                          ( iClk                      ),  // system clock, positive-edge trigger
    .iReset                        ( iReset                    ),  // global synchronous reset signal, Active high

    // from instruction memory
    .iIMEM_IF_Instruction          ( iIMEM_PE_Instruction[(`DEF_PE_INS_WIDTH-1):0] ),

    // '00': select self; '01': select data from right PE; '10': select data from left PE; '11': select data from CP
    .iData_Selection               ( iIMEM_PE_Instruction[(`DEF_PE_INS_WIDTH+2):`DEF_PE_INS_WIDTH] ),

    // boundary mode  
    .iBoundary_Mode_First_PE       ( rBoundary_Mode_First_PE ),
    .iBoundary_Mode_Last_PE        ( rBoundary_Mode_Last_PE  ),

    // PE predication
    .iPredication                  ( iIMEM_PE_Instruction[(`DEF_PE_INS_WIDTH+4):`DEF_PE_INS_WIDTH+3] ), // pe predication bits
    
    // PE 0
    .oPE0_AGU_DMEM_Write_Enable ( oPE0_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE0_AGU_DMEM_Read_Enable  ( oPE0_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE0_AGU_DMEM_Address      ( wPE0_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE0_AGU_DMEM_Opcode       ( wPE0_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE0_AGU_DMEM_Byte_Select  ( oPE0_AGU_DMEM_Byte_Select  ),
    .oPE0_AGU_DMEM_Store_Data   ( oPE0_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE0_DMEM_EX_Data          ( wPE0_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 1
    .oPE1_AGU_DMEM_Write_Enable ( oPE1_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE1_AGU_DMEM_Read_Enable  ( oPE1_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE1_AGU_DMEM_Address      ( wPE1_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE1_AGU_DMEM_Opcode       ( wPE1_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE1_AGU_DMEM_Byte_Select  ( oPE1_AGU_DMEM_Byte_Select  ),
    .oPE1_AGU_DMEM_Store_Data   ( oPE1_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE1_DMEM_EX_Data          ( wPE1_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 2
    .oPE2_AGU_DMEM_Write_Enable ( oPE2_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE2_AGU_DMEM_Read_Enable  ( oPE2_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE2_AGU_DMEM_Address      ( wPE2_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE2_AGU_DMEM_Opcode       ( wPE2_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE2_AGU_DMEM_Byte_Select  ( oPE2_AGU_DMEM_Byte_Select  ),
    .oPE2_AGU_DMEM_Store_Data   ( oPE2_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE2_DMEM_EX_Data          ( wPE2_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 3
    .oPE3_AGU_DMEM_Write_Enable ( oPE3_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE3_AGU_DMEM_Read_Enable  ( oPE3_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE3_AGU_DMEM_Address      ( wPE3_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE3_AGU_DMEM_Opcode       ( wPE3_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE3_AGU_DMEM_Byte_Select  ( oPE3_AGU_DMEM_Byte_Select  ),
    .oPE3_AGU_DMEM_Store_Data   ( oPE3_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE3_DMEM_EX_Data          ( wPE3_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 4
    .oPE4_AGU_DMEM_Write_Enable ( oPE4_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE4_AGU_DMEM_Read_Enable  ( oPE4_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE4_AGU_DMEM_Address      ( wPE4_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE4_AGU_DMEM_Opcode       ( wPE4_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE4_AGU_DMEM_Byte_Select  ( oPE4_AGU_DMEM_Byte_Select  ),
    .oPE4_AGU_DMEM_Store_Data   ( oPE4_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE4_DMEM_EX_Data          ( wPE4_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 5
    .oPE5_AGU_DMEM_Write_Enable ( oPE5_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE5_AGU_DMEM_Read_Enable  ( oPE5_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE5_AGU_DMEM_Address      ( wPE5_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE5_AGU_DMEM_Opcode       ( wPE5_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE5_AGU_DMEM_Byte_Select  ( oPE5_AGU_DMEM_Byte_Select  ),
    .oPE5_AGU_DMEM_Store_Data   ( oPE5_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE5_DMEM_EX_Data          ( wPE5_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 6
    .oPE6_AGU_DMEM_Write_Enable ( oPE6_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE6_AGU_DMEM_Read_Enable  ( oPE6_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE6_AGU_DMEM_Address      ( wPE6_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE6_AGU_DMEM_Opcode       ( wPE6_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE6_AGU_DMEM_Byte_Select  ( oPE6_AGU_DMEM_Byte_Select  ),
    .oPE6_AGU_DMEM_Store_Data   ( oPE6_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE6_DMEM_EX_Data          ( wPE6_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 7
    .oPE7_AGU_DMEM_Write_Enable ( oPE7_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE7_AGU_DMEM_Read_Enable  ( oPE7_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE7_AGU_DMEM_Address      ( wPE7_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE7_AGU_DMEM_Opcode       ( wPE7_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE7_AGU_DMEM_Byte_Select  ( oPE7_AGU_DMEM_Byte_Select  ),
    .oPE7_AGU_DMEM_Store_Data   ( oPE7_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE7_DMEM_EX_Data          ( wPE7_DMEM_EX_Data          ),  // data loaded from data memory
    
    // from/to CP
    .iCP_Data                      ( wCP_Port1_Data            ),  // cp port 1 data to pe
    .oFirst_PE_Port1_Data          ( wFirst_PE_Port1_Data      ),  // data from first PE RF port 1
    .oLast_PE_Port1_Data           ( wLast_PE_Port1_Data       )   // data from last PE RF port 1
  );


endmodule