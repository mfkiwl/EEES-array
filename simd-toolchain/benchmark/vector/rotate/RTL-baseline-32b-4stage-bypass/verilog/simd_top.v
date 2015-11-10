///:SYNTH: -asic
////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//    Module Name :  simd_top                                                 //
//    Description :  Template for the top module of the the SIMD processor.   //
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


module simd_top (
  iClk,                             // system clock, positive-edge trigger
  iReset,                           // global synchronous reset signal, Active high

  oIF_ID_PC,                        // current PC for debug
  oTask_Finished,                   // indicate the end of the program

  // Instruction Memory
  iBus_CP_IMEM_Valid,               // cp ins. memory access valid
  iBus_CP_IMEM_Address,             // cp ins. memory access address
  iBus_CP_IMEM_Write_Data,          // cp ins. memory write data
  iBus_CP_IMEM_Write_Enable,        // cp ins. memory write enable
  oBus_CP_IMEM_Read_Data,           // cp ins. memory read data

  iBus_PE_IMEM_Valid,               // pe ins. memory access valid
  iBus_PE_IMEM_Address,             // pe ins. memory access address
  iBus_PE_IMEM_Write_Data,          // pe ins. memory write data
  iBus_PE_IMEM_Write_Enable,        // pe ins. memory write enable
  oBus_PE_IMEM_Read_Data,           // pe ins. memory read data

  // Data Memory
  iBus_CP_DMEM_Valid,               // cp data memory access valid
  iBus_CP_DMEM_Address,             // cp data memory access address
  iBus_CP_DMEM_Write_Data,          // cp data memory write data
  iBus_CP_DMEM_Write_Enable,        // cp data memory write enable
  oBus_CP_DMEM_Read_Data,           // cp data memory read data

  iBus_PE_DMEM_Valid,               // pe data memory access valid
  iBus_PE_DMEM_Address,             // pe data memory access address
  iBus_PE_DMEM_Write_Data,          // pe data memory write data
  iBus_PE_DMEM_Write_Enable,        // pe data memory write enable
  oBus_PE_DMEM_Read_Data            // pe data memory read data
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
  output                                  oTask_Finished;                 // indicate the end of the program

  // Instruction Memory
  input                                   iBus_CP_IMEM_Valid;             // cp ins. memory access valid
  input  [(`DEF_CP_I_MEM_ADDR_WIDTH-3):0] iBus_CP_IMEM_Address;           // cp ins. memory access address
  input  [(`DEF_CP_INS_WIDTH+3):0]        iBus_CP_IMEM_Write_Data;        // cp ins. memory write data
  input                                   iBus_CP_IMEM_Write_Enable;      // cp ins. memory write enable
  output [(`DEF_CP_INS_WIDTH+3):0]        oBus_CP_IMEM_Read_Data;         // cp ins. memory read data

  input                                   iBus_PE_IMEM_Valid;             // pe ins. memory access valid
  input  [(`DEF_PE_I_MEM_ADDR_WIDTH-3):0] iBus_PE_IMEM_Address;           // pe ins. memory access address
  input  [(`DEF_PE_INS_WIDTH+4):0]        iBus_PE_IMEM_Write_Data;        // pe ins. memory write data
  input                                   iBus_PE_IMEM_Write_Enable;      // pe ins. memory write enable
  output [(`DEF_PE_INS_WIDTH+4):0]        oBus_PE_IMEM_Read_Data;         // pe ins. memory read data

  // Data Memory
  input                                   iBus_CP_DMEM_Valid;             // cp data memory access valid
  input  [(`DEF_CP_D_MEM_ADDR_WIDTH-1):0] iBus_CP_DMEM_Address;           // cp data memory access address
  input  [(`DEF_CP_DATA_WIDTH-1):0]       iBus_CP_DMEM_Write_Data;        // cp data memory write data
  input                                   iBus_CP_DMEM_Write_Enable;      // cp data memory write enable
  output [(`DEF_CP_DATA_WIDTH-1):0]       oBus_CP_DMEM_Read_Data;         // cp data memory read data

  input  [(`DEF_PE_NUM-1):0]                          iBus_PE_DMEM_Valid;        // pe data memory access valid
  input  [(`DEF_PE_D_MEM_ADDR_WIDTH*`DEF_PE_NUM-1):0] iBus_PE_DMEM_Address;      // pe data memory access address
  input  [(`DEF_PE_DATA_WIDTH*`DEF_PE_NUM-1):0]       iBus_PE_DMEM_Write_Data;   // pe data memory write data
  input  [(`DEF_PE_NUM-1):0]                          iBus_PE_DMEM_Write_Enable; // pe data memory write enable
  output [(`DEF_PE_DATA_WIDTH*`DEF_PE_NUM-1):0]       oBus_PE_DMEM_Read_Data;    // pe data memory read data


//******************************
//  Local Wire/Reg Declaration
//******************************

  // CP path
  wire [(`DEF_CP_I_MEM_ADDR_WIDTH-3):0]   wIF_IMEM_Address;               // PE instruciton memory address
  wire [(`DEF_CP_INS_WIDTH+3):0]          wIMEM_CP_Instruction;           // DEF_CP_INS_WIDTH + 2 bits communication + 2-bit predication

  wire                                    wCP_DMEM_Valid;                  
  wire                                    wCP_AGU_DMEM_Write_Enable;      // LSU stage data-memory write enable
  wire                                    wCP_AGU_DMEM_Read_Enable;       // LSU stage data-memory read enable
  wire [(`DEF_CP_DATA_WIDTH/8-1):0]       wCP_AGU_DMEM_Byte_Select;
  wire [(`DEF_CP_RAM_ADDR_BITS-1):0]      wCP_AGU_DMEM_Address;           // Address to DMEM
  wire [(`DEF_CP_DATA_WIDTH-1):0]         wCP_AGU_DMEM_Write_Data;        // Store data to EX stage (for store instruction only)
  wire [(`DEF_CP_DATA_WIDTH-1):0]         wCP_DMEM_EX_Data;               // data loaded from data memory

  // PE path
  wire [(`DEF_PE_INS_WIDTH+4):0]          wIMEM_PE_Instruction;           // instruction fetched from PE instruction memory
  
  // PE0
  wire                                    wPE0_DMEM_Valid;
  wire                                    wPE0_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE0_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE0_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE0_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE0_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE0_DMEM_EX_Data;          // data loaded from data memory
  
  // PE1
  wire                                    wPE1_DMEM_Valid;
  wire                                    wPE1_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE1_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE1_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE1_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE1_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE1_DMEM_EX_Data;          // data loaded from data memory
  
  // PE2
  wire                                    wPE2_DMEM_Valid;
  wire                                    wPE2_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE2_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE2_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE2_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE2_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE2_DMEM_EX_Data;          // data loaded from data memory
  
  // PE3
  wire                                    wPE3_DMEM_Valid;
  wire                                    wPE3_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE3_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE3_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE3_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE3_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE3_DMEM_EX_Data;          // data loaded from data memory
  
  // PE4
  wire                                    wPE4_DMEM_Valid;
  wire                                    wPE4_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE4_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE4_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE4_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE4_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE4_DMEM_EX_Data;          // data loaded from data memory
  
  // PE5
  wire                                    wPE5_DMEM_Valid;
  wire                                    wPE5_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE5_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE5_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE5_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE5_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE5_DMEM_EX_Data;          // data loaded from data memory
  
  // PE6
  wire                                    wPE6_DMEM_Valid;
  wire                                    wPE6_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE6_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE6_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE6_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE6_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE6_DMEM_EX_Data;          // data loaded from data memory
  
  // PE7
  wire                                    wPE7_DMEM_Valid;
  wire                                    wPE7_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE7_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE7_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE7_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE7_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE7_DMEM_EX_Data;          // data loaded from data memory
  
  // PE8
  wire                                    wPE8_DMEM_Valid;
  wire                                    wPE8_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE8_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE8_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE8_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE8_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE8_DMEM_EX_Data;          // data loaded from data memory
  
  // PE9
  wire                                    wPE9_DMEM_Valid;
  wire                                    wPE9_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE9_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE9_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE9_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE9_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE9_DMEM_EX_Data;          // data loaded from data memory
  
  // PE10
  wire                                    wPE10_DMEM_Valid;
  wire                                    wPE10_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE10_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE10_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE10_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE10_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE10_DMEM_EX_Data;          // data loaded from data memory
  
  // PE11
  wire                                    wPE11_DMEM_Valid;
  wire                                    wPE11_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE11_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE11_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE11_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE11_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE11_DMEM_EX_Data;          // data loaded from data memory
  
  // PE12
  wire                                    wPE12_DMEM_Valid;
  wire                                    wPE12_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE12_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE12_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE12_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE12_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE12_DMEM_EX_Data;          // data loaded from data memory
  
  // PE13
  wire                                    wPE13_DMEM_Valid;
  wire                                    wPE13_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE13_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE13_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE13_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE13_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE13_DMEM_EX_Data;          // data loaded from data memory
  
  // PE14
  wire                                    wPE14_DMEM_Valid;
  wire                                    wPE14_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE14_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE14_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE14_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE14_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE14_DMEM_EX_Data;          // data loaded from data memory
  
  // PE15
  wire                                    wPE15_DMEM_Valid;
  wire                                    wPE15_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE15_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE15_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE15_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE15_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE15_DMEM_EX_Data;          // data loaded from data memory
  
  // PE16
  wire                                    wPE16_DMEM_Valid;
  wire                                    wPE16_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE16_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE16_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE16_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE16_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE16_DMEM_EX_Data;          // data loaded from data memory
  
  // PE17
  wire                                    wPE17_DMEM_Valid;
  wire                                    wPE17_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE17_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE17_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE17_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE17_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE17_DMEM_EX_Data;          // data loaded from data memory
  
  // PE18
  wire                                    wPE18_DMEM_Valid;
  wire                                    wPE18_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE18_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE18_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE18_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE18_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE18_DMEM_EX_Data;          // data loaded from data memory
  
  // PE19
  wire                                    wPE19_DMEM_Valid;
  wire                                    wPE19_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE19_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE19_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE19_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE19_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE19_DMEM_EX_Data;          // data loaded from data memory
  
  // PE20
  wire                                    wPE20_DMEM_Valid;
  wire                                    wPE20_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE20_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE20_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE20_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE20_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE20_DMEM_EX_Data;          // data loaded from data memory
  
  // PE21
  wire                                    wPE21_DMEM_Valid;
  wire                                    wPE21_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE21_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE21_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE21_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE21_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE21_DMEM_EX_Data;          // data loaded from data memory
  
  // PE22
  wire                                    wPE22_DMEM_Valid;
  wire                                    wPE22_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE22_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE22_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE22_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE22_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE22_DMEM_EX_Data;          // data loaded from data memory
  
  // PE23
  wire                                    wPE23_DMEM_Valid;
  wire                                    wPE23_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE23_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE23_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE23_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE23_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE23_DMEM_EX_Data;          // data loaded from data memory
  
  // PE24
  wire                                    wPE24_DMEM_Valid;
  wire                                    wPE24_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE24_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE24_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE24_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE24_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE24_DMEM_EX_Data;          // data loaded from data memory
  
  // PE25
  wire                                    wPE25_DMEM_Valid;
  wire                                    wPE25_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE25_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE25_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE25_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE25_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE25_DMEM_EX_Data;          // data loaded from data memory
  
  // PE26
  wire                                    wPE26_DMEM_Valid;
  wire                                    wPE26_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE26_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE26_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE26_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE26_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE26_DMEM_EX_Data;          // data loaded from data memory
  
  // PE27
  wire                                    wPE27_DMEM_Valid;
  wire                                    wPE27_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE27_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE27_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE27_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE27_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE27_DMEM_EX_Data;          // data loaded from data memory
  
  // PE28
  wire                                    wPE28_DMEM_Valid;
  wire                                    wPE28_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE28_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE28_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE28_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE28_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE28_DMEM_EX_Data;          // data loaded from data memory
  
  // PE29
  wire                                    wPE29_DMEM_Valid;
  wire                                    wPE29_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE29_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE29_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE29_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE29_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE29_DMEM_EX_Data;          // data loaded from data memory
  
  // PE30
  wire                                    wPE30_DMEM_Valid;
  wire                                    wPE30_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE30_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE30_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE30_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE30_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE30_DMEM_EX_Data;          // data loaded from data memory
  
  // PE31
  wire                                    wPE31_DMEM_Valid;
  wire                                    wPE31_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE31_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE31_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE31_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE31_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE31_DMEM_EX_Data;          // data loaded from data memory
  
  // PE32
  wire                                    wPE32_DMEM_Valid;
  wire                                    wPE32_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE32_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE32_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE32_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE32_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE32_DMEM_EX_Data;          // data loaded from data memory
  
  // PE33
  wire                                    wPE33_DMEM_Valid;
  wire                                    wPE33_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE33_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE33_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE33_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE33_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE33_DMEM_EX_Data;          // data loaded from data memory
  
  // PE34
  wire                                    wPE34_DMEM_Valid;
  wire                                    wPE34_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE34_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE34_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE34_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE34_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE34_DMEM_EX_Data;          // data loaded from data memory
  
  // PE35
  wire                                    wPE35_DMEM_Valid;
  wire                                    wPE35_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE35_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE35_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE35_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE35_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE35_DMEM_EX_Data;          // data loaded from data memory
  
  // PE36
  wire                                    wPE36_DMEM_Valid;
  wire                                    wPE36_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE36_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE36_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE36_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE36_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE36_DMEM_EX_Data;          // data loaded from data memory
  
  // PE37
  wire                                    wPE37_DMEM_Valid;
  wire                                    wPE37_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE37_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE37_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE37_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE37_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE37_DMEM_EX_Data;          // data loaded from data memory
  
  // PE38
  wire                                    wPE38_DMEM_Valid;
  wire                                    wPE38_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE38_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE38_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE38_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE38_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE38_DMEM_EX_Data;          // data loaded from data memory
  
  // PE39
  wire                                    wPE39_DMEM_Valid;
  wire                                    wPE39_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE39_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE39_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE39_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE39_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE39_DMEM_EX_Data;          // data loaded from data memory
  
  // PE40
  wire                                    wPE40_DMEM_Valid;
  wire                                    wPE40_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE40_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE40_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE40_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE40_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE40_DMEM_EX_Data;          // data loaded from data memory
  
  // PE41
  wire                                    wPE41_DMEM_Valid;
  wire                                    wPE41_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE41_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE41_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE41_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE41_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE41_DMEM_EX_Data;          // data loaded from data memory
  
  // PE42
  wire                                    wPE42_DMEM_Valid;
  wire                                    wPE42_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE42_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE42_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE42_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE42_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE42_DMEM_EX_Data;          // data loaded from data memory
  
  // PE43
  wire                                    wPE43_DMEM_Valid;
  wire                                    wPE43_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE43_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE43_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE43_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE43_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE43_DMEM_EX_Data;          // data loaded from data memory
  
  // PE44
  wire                                    wPE44_DMEM_Valid;
  wire                                    wPE44_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE44_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE44_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE44_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE44_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE44_DMEM_EX_Data;          // data loaded from data memory
  
  // PE45
  wire                                    wPE45_DMEM_Valid;
  wire                                    wPE45_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE45_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE45_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE45_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE45_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE45_DMEM_EX_Data;          // data loaded from data memory
  
  // PE46
  wire                                    wPE46_DMEM_Valid;
  wire                                    wPE46_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE46_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE46_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE46_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE46_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE46_DMEM_EX_Data;          // data loaded from data memory
  
  // PE47
  wire                                    wPE47_DMEM_Valid;
  wire                                    wPE47_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE47_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE47_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE47_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE47_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE47_DMEM_EX_Data;          // data loaded from data memory
  
  // PE48
  wire                                    wPE48_DMEM_Valid;
  wire                                    wPE48_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE48_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE48_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE48_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE48_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE48_DMEM_EX_Data;          // data loaded from data memory
  
  // PE49
  wire                                    wPE49_DMEM_Valid;
  wire                                    wPE49_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE49_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE49_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE49_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE49_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE49_DMEM_EX_Data;          // data loaded from data memory
  
  // PE50
  wire                                    wPE50_DMEM_Valid;
  wire                                    wPE50_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE50_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE50_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE50_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE50_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE50_DMEM_EX_Data;          // data loaded from data memory
  
  // PE51
  wire                                    wPE51_DMEM_Valid;
  wire                                    wPE51_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE51_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE51_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE51_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE51_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE51_DMEM_EX_Data;          // data loaded from data memory
  
  // PE52
  wire                                    wPE52_DMEM_Valid;
  wire                                    wPE52_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE52_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE52_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE52_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE52_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE52_DMEM_EX_Data;          // data loaded from data memory
  
  // PE53
  wire                                    wPE53_DMEM_Valid;
  wire                                    wPE53_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE53_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE53_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE53_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE53_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE53_DMEM_EX_Data;          // data loaded from data memory
  
  // PE54
  wire                                    wPE54_DMEM_Valid;
  wire                                    wPE54_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE54_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE54_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE54_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE54_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE54_DMEM_EX_Data;          // data loaded from data memory
  
  // PE55
  wire                                    wPE55_DMEM_Valid;
  wire                                    wPE55_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE55_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE55_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE55_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE55_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE55_DMEM_EX_Data;          // data loaded from data memory
  
  // PE56
  wire                                    wPE56_DMEM_Valid;
  wire                                    wPE56_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE56_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE56_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE56_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE56_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE56_DMEM_EX_Data;          // data loaded from data memory
  
  // PE57
  wire                                    wPE57_DMEM_Valid;
  wire                                    wPE57_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE57_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE57_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE57_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE57_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE57_DMEM_EX_Data;          // data loaded from data memory
  
  // PE58
  wire                                    wPE58_DMEM_Valid;
  wire                                    wPE58_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE58_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE58_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE58_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE58_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE58_DMEM_EX_Data;          // data loaded from data memory
  
  // PE59
  wire                                    wPE59_DMEM_Valid;
  wire                                    wPE59_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE59_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE59_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE59_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE59_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE59_DMEM_EX_Data;          // data loaded from data memory
  
  // PE60
  wire                                    wPE60_DMEM_Valid;
  wire                                    wPE60_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE60_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE60_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE60_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE60_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE60_DMEM_EX_Data;          // data loaded from data memory
  
  // PE61
  wire                                    wPE61_DMEM_Valid;
  wire                                    wPE61_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE61_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE61_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE61_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE61_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE61_DMEM_EX_Data;          // data loaded from data memory
  
  // PE62
  wire                                    wPE62_DMEM_Valid;
  wire                                    wPE62_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE62_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE62_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE62_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE62_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE62_DMEM_EX_Data;          // data loaded from data memory
  
  // PE63
  wire                                    wPE63_DMEM_Valid;
  wire                                    wPE63_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE63_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE63_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE63_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE63_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE63_DMEM_EX_Data;          // data loaded from data memory
  
  // PE64
  wire                                    wPE64_DMEM_Valid;
  wire                                    wPE64_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE64_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE64_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE64_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE64_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE64_DMEM_EX_Data;          // data loaded from data memory
  
  // PE65
  wire                                    wPE65_DMEM_Valid;
  wire                                    wPE65_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE65_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE65_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE65_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE65_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE65_DMEM_EX_Data;          // data loaded from data memory
  
  // PE66
  wire                                    wPE66_DMEM_Valid;
  wire                                    wPE66_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE66_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE66_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE66_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE66_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE66_DMEM_EX_Data;          // data loaded from data memory
  
  // PE67
  wire                                    wPE67_DMEM_Valid;
  wire                                    wPE67_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE67_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE67_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE67_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE67_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE67_DMEM_EX_Data;          // data loaded from data memory
  
  // PE68
  wire                                    wPE68_DMEM_Valid;
  wire                                    wPE68_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE68_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE68_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE68_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE68_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE68_DMEM_EX_Data;          // data loaded from data memory
  
  // PE69
  wire                                    wPE69_DMEM_Valid;
  wire                                    wPE69_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE69_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE69_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE69_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE69_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE69_DMEM_EX_Data;          // data loaded from data memory
  
  // PE70
  wire                                    wPE70_DMEM_Valid;
  wire                                    wPE70_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE70_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE70_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE70_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE70_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE70_DMEM_EX_Data;          // data loaded from data memory
  
  // PE71
  wire                                    wPE71_DMEM_Valid;
  wire                                    wPE71_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE71_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE71_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE71_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE71_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE71_DMEM_EX_Data;          // data loaded from data memory
  
  // PE72
  wire                                    wPE72_DMEM_Valid;
  wire                                    wPE72_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE72_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE72_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE72_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE72_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE72_DMEM_EX_Data;          // data loaded from data memory
  
  // PE73
  wire                                    wPE73_DMEM_Valid;
  wire                                    wPE73_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE73_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE73_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE73_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE73_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE73_DMEM_EX_Data;          // data loaded from data memory
  
  // PE74
  wire                                    wPE74_DMEM_Valid;
  wire                                    wPE74_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE74_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE74_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE74_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE74_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE74_DMEM_EX_Data;          // data loaded from data memory
  
  // PE75
  wire                                    wPE75_DMEM_Valid;
  wire                                    wPE75_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE75_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE75_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE75_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE75_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE75_DMEM_EX_Data;          // data loaded from data memory
  
  // PE76
  wire                                    wPE76_DMEM_Valid;
  wire                                    wPE76_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE76_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE76_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE76_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE76_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE76_DMEM_EX_Data;          // data loaded from data memory
  
  // PE77
  wire                                    wPE77_DMEM_Valid;
  wire                                    wPE77_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE77_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE77_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE77_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE77_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE77_DMEM_EX_Data;          // data loaded from data memory
  
  // PE78
  wire                                    wPE78_DMEM_Valid;
  wire                                    wPE78_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE78_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE78_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE78_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE78_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE78_DMEM_EX_Data;          // data loaded from data memory
  
  // PE79
  wire                                    wPE79_DMEM_Valid;
  wire                                    wPE79_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE79_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE79_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE79_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE79_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE79_DMEM_EX_Data;          // data loaded from data memory
  
  // PE80
  wire                                    wPE80_DMEM_Valid;
  wire                                    wPE80_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE80_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE80_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE80_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE80_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE80_DMEM_EX_Data;          // data loaded from data memory
  
  // PE81
  wire                                    wPE81_DMEM_Valid;
  wire                                    wPE81_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE81_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE81_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE81_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE81_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE81_DMEM_EX_Data;          // data loaded from data memory
  
  // PE82
  wire                                    wPE82_DMEM_Valid;
  wire                                    wPE82_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE82_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE82_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE82_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE82_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE82_DMEM_EX_Data;          // data loaded from data memory
  
  // PE83
  wire                                    wPE83_DMEM_Valid;
  wire                                    wPE83_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE83_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE83_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE83_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE83_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE83_DMEM_EX_Data;          // data loaded from data memory
  
  // PE84
  wire                                    wPE84_DMEM_Valid;
  wire                                    wPE84_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE84_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE84_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE84_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE84_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE84_DMEM_EX_Data;          // data loaded from data memory
  
  // PE85
  wire                                    wPE85_DMEM_Valid;
  wire                                    wPE85_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE85_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE85_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE85_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE85_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE85_DMEM_EX_Data;          // data loaded from data memory
  
  // PE86
  wire                                    wPE86_DMEM_Valid;
  wire                                    wPE86_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE86_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE86_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE86_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE86_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE86_DMEM_EX_Data;          // data loaded from data memory
  
  // PE87
  wire                                    wPE87_DMEM_Valid;
  wire                                    wPE87_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE87_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE87_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE87_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE87_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE87_DMEM_EX_Data;          // data loaded from data memory
  
  // PE88
  wire                                    wPE88_DMEM_Valid;
  wire                                    wPE88_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE88_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE88_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE88_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE88_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE88_DMEM_EX_Data;          // data loaded from data memory
  
  // PE89
  wire                                    wPE89_DMEM_Valid;
  wire                                    wPE89_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE89_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE89_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE89_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE89_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE89_DMEM_EX_Data;          // data loaded from data memory
  
  // PE90
  wire                                    wPE90_DMEM_Valid;
  wire                                    wPE90_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE90_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE90_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE90_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE90_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE90_DMEM_EX_Data;          // data loaded from data memory
  
  // PE91
  wire                                    wPE91_DMEM_Valid;
  wire                                    wPE91_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE91_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE91_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE91_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE91_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE91_DMEM_EX_Data;          // data loaded from data memory
  
  // PE92
  wire                                    wPE92_DMEM_Valid;
  wire                                    wPE92_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE92_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE92_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE92_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE92_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE92_DMEM_EX_Data;          // data loaded from data memory
  
  // PE93
  wire                                    wPE93_DMEM_Valid;
  wire                                    wPE93_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE93_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE93_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE93_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE93_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE93_DMEM_EX_Data;          // data loaded from data memory
  
  // PE94
  wire                                    wPE94_DMEM_Valid;
  wire                                    wPE94_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE94_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE94_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE94_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE94_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE94_DMEM_EX_Data;          // data loaded from data memory
  
  // PE95
  wire                                    wPE95_DMEM_Valid;
  wire                                    wPE95_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE95_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE95_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE95_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE95_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE95_DMEM_EX_Data;          // data loaded from data memory
  
  // PE96
  wire                                    wPE96_DMEM_Valid;
  wire                                    wPE96_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE96_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE96_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE96_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE96_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE96_DMEM_EX_Data;          // data loaded from data memory
  
  // PE97
  wire                                    wPE97_DMEM_Valid;
  wire                                    wPE97_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE97_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE97_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE97_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE97_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE97_DMEM_EX_Data;          // data loaded from data memory
  
  // PE98
  wire                                    wPE98_DMEM_Valid;
  wire                                    wPE98_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE98_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE98_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE98_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE98_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE98_DMEM_EX_Data;          // data loaded from data memory
  
  // PE99
  wire                                    wPE99_DMEM_Valid;
  wire                                    wPE99_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE99_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE99_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE99_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE99_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE99_DMEM_EX_Data;          // data loaded from data memory
  
  // PE100
  wire                                    wPE100_DMEM_Valid;
  wire                                    wPE100_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE100_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE100_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE100_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE100_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE100_DMEM_EX_Data;          // data loaded from data memory
  
  // PE101
  wire                                    wPE101_DMEM_Valid;
  wire                                    wPE101_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE101_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE101_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE101_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE101_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE101_DMEM_EX_Data;          // data loaded from data memory
  
  // PE102
  wire                                    wPE102_DMEM_Valid;
  wire                                    wPE102_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE102_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE102_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE102_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE102_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE102_DMEM_EX_Data;          // data loaded from data memory
  
  // PE103
  wire                                    wPE103_DMEM_Valid;
  wire                                    wPE103_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE103_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE103_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE103_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE103_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE103_DMEM_EX_Data;          // data loaded from data memory
  
  // PE104
  wire                                    wPE104_DMEM_Valid;
  wire                                    wPE104_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE104_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE104_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE104_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE104_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE104_DMEM_EX_Data;          // data loaded from data memory
  
  // PE105
  wire                                    wPE105_DMEM_Valid;
  wire                                    wPE105_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE105_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE105_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE105_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE105_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE105_DMEM_EX_Data;          // data loaded from data memory
  
  // PE106
  wire                                    wPE106_DMEM_Valid;
  wire                                    wPE106_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE106_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE106_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE106_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE106_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE106_DMEM_EX_Data;          // data loaded from data memory
  
  // PE107
  wire                                    wPE107_DMEM_Valid;
  wire                                    wPE107_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE107_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE107_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE107_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE107_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE107_DMEM_EX_Data;          // data loaded from data memory
  
  // PE108
  wire                                    wPE108_DMEM_Valid;
  wire                                    wPE108_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE108_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE108_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE108_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE108_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE108_DMEM_EX_Data;          // data loaded from data memory
  
  // PE109
  wire                                    wPE109_DMEM_Valid;
  wire                                    wPE109_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE109_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE109_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE109_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE109_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE109_DMEM_EX_Data;          // data loaded from data memory
  
  // PE110
  wire                                    wPE110_DMEM_Valid;
  wire                                    wPE110_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE110_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE110_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE110_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE110_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE110_DMEM_EX_Data;          // data loaded from data memory
  
  // PE111
  wire                                    wPE111_DMEM_Valid;
  wire                                    wPE111_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE111_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE111_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE111_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE111_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE111_DMEM_EX_Data;          // data loaded from data memory
  
  // PE112
  wire                                    wPE112_DMEM_Valid;
  wire                                    wPE112_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE112_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE112_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE112_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE112_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE112_DMEM_EX_Data;          // data loaded from data memory
  
  // PE113
  wire                                    wPE113_DMEM_Valid;
  wire                                    wPE113_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE113_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE113_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE113_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE113_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE113_DMEM_EX_Data;          // data loaded from data memory
  
  // PE114
  wire                                    wPE114_DMEM_Valid;
  wire                                    wPE114_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE114_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE114_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE114_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE114_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE114_DMEM_EX_Data;          // data loaded from data memory
  
  // PE115
  wire                                    wPE115_DMEM_Valid;
  wire                                    wPE115_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE115_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE115_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE115_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE115_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE115_DMEM_EX_Data;          // data loaded from data memory
  
  // PE116
  wire                                    wPE116_DMEM_Valid;
  wire                                    wPE116_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE116_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE116_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE116_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE116_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE116_DMEM_EX_Data;          // data loaded from data memory
  
  // PE117
  wire                                    wPE117_DMEM_Valid;
  wire                                    wPE117_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE117_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE117_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE117_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE117_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE117_DMEM_EX_Data;          // data loaded from data memory
  
  // PE118
  wire                                    wPE118_DMEM_Valid;
  wire                                    wPE118_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE118_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE118_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE118_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE118_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE118_DMEM_EX_Data;          // data loaded from data memory
  
  // PE119
  wire                                    wPE119_DMEM_Valid;
  wire                                    wPE119_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE119_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE119_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE119_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE119_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE119_DMEM_EX_Data;          // data loaded from data memory
  
  // PE120
  wire                                    wPE120_DMEM_Valid;
  wire                                    wPE120_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE120_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE120_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE120_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE120_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE120_DMEM_EX_Data;          // data loaded from data memory
  
  // PE121
  wire                                    wPE121_DMEM_Valid;
  wire                                    wPE121_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE121_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE121_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE121_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE121_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE121_DMEM_EX_Data;          // data loaded from data memory
  
  // PE122
  wire                                    wPE122_DMEM_Valid;
  wire                                    wPE122_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE122_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE122_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE122_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE122_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE122_DMEM_EX_Data;          // data loaded from data memory
  
  // PE123
  wire                                    wPE123_DMEM_Valid;
  wire                                    wPE123_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE123_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE123_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE123_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE123_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE123_DMEM_EX_Data;          // data loaded from data memory
  
  // PE124
  wire                                    wPE124_DMEM_Valid;
  wire                                    wPE124_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE124_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE124_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE124_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE124_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE124_DMEM_EX_Data;          // data loaded from data memory
  
  // PE125
  wire                                    wPE125_DMEM_Valid;
  wire                                    wPE125_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE125_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE125_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE125_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE125_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE125_DMEM_EX_Data;          // data loaded from data memory
  
  // PE126
  wire                                    wPE126_DMEM_Valid;
  wire                                    wPE126_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE126_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE126_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE126_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE126_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE126_DMEM_EX_Data;          // data loaded from data memory
  
  // PE127
  wire                                    wPE127_DMEM_Valid;
  wire                                    wPE127_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE127_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE127_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE127_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE127_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE127_DMEM_EX_Data;          // data loaded from data memory
  
  
//******************************
//  Behavioral Description
//******************************
  // CP instruction memory: share the same address as the PE instruction memory
  cp_imem inst_cp_imem (
    .iClk                          ( iClk                     ),  // system clock, positive-edge trigger

    // port A: bus
    .iBus_Valid                    ( iBus_CP_IMEM_Valid       ),  // cp inst. memory access valid
    .iBus_Address                  ( iBus_CP_IMEM_Address     ),  // cp inst. memory access address
    .iBus_Write_Data               ( iBus_CP_IMEM_Write_Data  ),  // cp inst. memory write data
    .iBus_Write_Enable             ( iBus_CP_IMEM_Write_Enable),  // cp inst. memory write enable
    .oBus_Read_Data                ( oBus_CP_IMEM_Read_Data   ),  // cp inst. memory read data

    // port B: core
    .iIF_IMEM_Addr                 ( wIF_IMEM_Address         ),  // address to the insruction memory
    .oIMEM_IF_Instruction          ( wIMEM_CP_Instruction     )   // instruction fetched from instruction memory
  );


  cp_dmem inst_cp_dmem(
    .iClk                          ( iClk                     ),  // system clock, positive-edge trigger

    // port A: bus
    .iBus_Valid                    ( iBus_CP_DMEM_Valid       ),  // cp data memory access valid
    .iBus_Address                  ( iBus_CP_DMEM_Address     ),  // cp data memory access address
    .iBus_Write_Data               ( iBus_CP_DMEM_Write_Data  ),  // cp data memory write data
    .iBus_Write_Enable             ( iBus_CP_DMEM_Write_Enable),  // cp data memory write enable
    .oBus_Read_Data                ( oBus_CP_DMEM_Read_Data   ),  // cp data memory read data

    // port B: core
    .iCore_Valid                   ( wCP_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wCP_AGU_DMEM_Write_Enable ), // stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wCP_AGU_DMEM_Read_Enable  ), // stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wCP_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wCP_AGU_DMEM_Address      ),
    .iAGU_DMEM_Store_Data          ( wCP_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wCP_DMEM_EX_Data          )  // data loaded from data memory
  );


  // PE instruction memory: share the same address as the CP instruction memory
  pe_imem inst_pe_imem (
    .iClk                          ( iClk                     ),  // system clock, positive-edge trigger

    // port A: bus
    .iBus_Valid                    ( iBus_PE_IMEM_Valid       ),  // pe inst. memory access valid
    .iBus_Address                  ( iBus_PE_IMEM_Address     ),  // pe inst. memory access address
    .iBus_Write_Data               ( iBus_PE_IMEM_Write_Data  ),  // pe inst. memory write data
    .iBus_Write_Enable             ( iBus_PE_IMEM_Write_Enable),  // pe inst. memory write enable
    .oBus_Read_Data                ( oBus_PE_IMEM_Read_Data   ),  // pe inst. memory read data

    // port B: core
    .iIF_IMEM_Addr                 ( wIF_IMEM_Address         ),  // address to the PE insruction memory
    .oIMEM_IF_Instruction          ( wIMEM_PE_Instruction     )   // instruction fetched from PE instruction memory
  );
  
  
  pe_dmem inst_pe0_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[0]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*1-1):`DEF_PE_D_MEM_ADDR_WIDTH*0]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*1-1):`DEF_PE_DATA_WIDTH*0]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[0] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*1-1):`DEF_PE_DATA_WIDTH*0] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE0_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE0_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE0_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE0_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE0_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE0_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE0_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe1_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[1]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*2-1):`DEF_PE_D_MEM_ADDR_WIDTH*1]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*2-1):`DEF_PE_DATA_WIDTH*1]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[1] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*2-1):`DEF_PE_DATA_WIDTH*1] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE1_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE1_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE1_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE1_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE1_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE1_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE1_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe2_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[2]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*3-1):`DEF_PE_D_MEM_ADDR_WIDTH*2]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*3-1):`DEF_PE_DATA_WIDTH*2]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[2] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*3-1):`DEF_PE_DATA_WIDTH*2] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE2_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE2_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE2_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE2_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE2_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE2_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE2_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe3_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[3]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*4-1):`DEF_PE_D_MEM_ADDR_WIDTH*3]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*4-1):`DEF_PE_DATA_WIDTH*3]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[3] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*4-1):`DEF_PE_DATA_WIDTH*3] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE3_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE3_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE3_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE3_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE3_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE3_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE3_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe4_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[4]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*5-1):`DEF_PE_D_MEM_ADDR_WIDTH*4]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*5-1):`DEF_PE_DATA_WIDTH*4]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[4] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*5-1):`DEF_PE_DATA_WIDTH*4] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE4_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE4_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE4_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE4_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE4_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE4_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE4_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe5_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[5]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*6-1):`DEF_PE_D_MEM_ADDR_WIDTH*5]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*6-1):`DEF_PE_DATA_WIDTH*5]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[5] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*6-1):`DEF_PE_DATA_WIDTH*5] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE5_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE5_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE5_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE5_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE5_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE5_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE5_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe6_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[6]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*7-1):`DEF_PE_D_MEM_ADDR_WIDTH*6]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*7-1):`DEF_PE_DATA_WIDTH*6]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[6] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*7-1):`DEF_PE_DATA_WIDTH*6] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE6_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE6_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE6_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE6_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE6_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE6_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE6_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe7_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[7]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*8-1):`DEF_PE_D_MEM_ADDR_WIDTH*7]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*8-1):`DEF_PE_DATA_WIDTH*7]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[7] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*8-1):`DEF_PE_DATA_WIDTH*7] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE7_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE7_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE7_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE7_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE7_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE7_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE7_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe8_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[8]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*9-1):`DEF_PE_D_MEM_ADDR_WIDTH*8]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*9-1):`DEF_PE_DATA_WIDTH*8]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[8] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*9-1):`DEF_PE_DATA_WIDTH*8] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE8_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE8_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE8_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE8_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE8_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE8_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE8_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe9_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[9]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*10-1):`DEF_PE_D_MEM_ADDR_WIDTH*9]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*10-1):`DEF_PE_DATA_WIDTH*9]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[9] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*10-1):`DEF_PE_DATA_WIDTH*9] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE9_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE9_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE9_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE9_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE9_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE9_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE9_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe10_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[10]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*11-1):`DEF_PE_D_MEM_ADDR_WIDTH*10]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*11-1):`DEF_PE_DATA_WIDTH*10]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[10] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*11-1):`DEF_PE_DATA_WIDTH*10] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE10_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE10_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE10_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE10_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE10_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE10_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE10_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe11_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[11]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*12-1):`DEF_PE_D_MEM_ADDR_WIDTH*11]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*12-1):`DEF_PE_DATA_WIDTH*11]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[11] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*12-1):`DEF_PE_DATA_WIDTH*11] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE11_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE11_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE11_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE11_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE11_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE11_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE11_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe12_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[12]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*13-1):`DEF_PE_D_MEM_ADDR_WIDTH*12]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*13-1):`DEF_PE_DATA_WIDTH*12]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[12] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*13-1):`DEF_PE_DATA_WIDTH*12] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE12_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE12_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE12_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE12_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE12_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE12_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE12_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe13_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[13]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*14-1):`DEF_PE_D_MEM_ADDR_WIDTH*13]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*14-1):`DEF_PE_DATA_WIDTH*13]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[13] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*14-1):`DEF_PE_DATA_WIDTH*13] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE13_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE13_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE13_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE13_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE13_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE13_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE13_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe14_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[14]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*15-1):`DEF_PE_D_MEM_ADDR_WIDTH*14]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*15-1):`DEF_PE_DATA_WIDTH*14]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[14] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*15-1):`DEF_PE_DATA_WIDTH*14] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE14_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE14_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE14_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE14_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE14_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE14_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE14_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe15_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[15]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*16-1):`DEF_PE_D_MEM_ADDR_WIDTH*15]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*16-1):`DEF_PE_DATA_WIDTH*15]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[15] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*16-1):`DEF_PE_DATA_WIDTH*15] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE15_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE15_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE15_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE15_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE15_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE15_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE15_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe16_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[16]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*17-1):`DEF_PE_D_MEM_ADDR_WIDTH*16]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*17-1):`DEF_PE_DATA_WIDTH*16]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[16] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*17-1):`DEF_PE_DATA_WIDTH*16] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE16_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE16_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE16_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE16_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE16_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE16_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE16_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe17_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[17]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*18-1):`DEF_PE_D_MEM_ADDR_WIDTH*17]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*18-1):`DEF_PE_DATA_WIDTH*17]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[17] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*18-1):`DEF_PE_DATA_WIDTH*17] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE17_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE17_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE17_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE17_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE17_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE17_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE17_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe18_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[18]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*19-1):`DEF_PE_D_MEM_ADDR_WIDTH*18]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*19-1):`DEF_PE_DATA_WIDTH*18]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[18] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*19-1):`DEF_PE_DATA_WIDTH*18] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE18_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE18_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE18_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE18_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE18_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE18_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE18_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe19_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[19]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*20-1):`DEF_PE_D_MEM_ADDR_WIDTH*19]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*20-1):`DEF_PE_DATA_WIDTH*19]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[19] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*20-1):`DEF_PE_DATA_WIDTH*19] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE19_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE19_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE19_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE19_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE19_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE19_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE19_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe20_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[20]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*21-1):`DEF_PE_D_MEM_ADDR_WIDTH*20]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*21-1):`DEF_PE_DATA_WIDTH*20]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[20] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*21-1):`DEF_PE_DATA_WIDTH*20] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE20_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE20_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE20_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE20_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE20_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE20_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE20_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe21_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[21]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*22-1):`DEF_PE_D_MEM_ADDR_WIDTH*21]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*22-1):`DEF_PE_DATA_WIDTH*21]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[21] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*22-1):`DEF_PE_DATA_WIDTH*21] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE21_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE21_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE21_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE21_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE21_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE21_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE21_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe22_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[22]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*23-1):`DEF_PE_D_MEM_ADDR_WIDTH*22]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*23-1):`DEF_PE_DATA_WIDTH*22]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[22] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*23-1):`DEF_PE_DATA_WIDTH*22] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE22_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE22_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE22_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE22_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE22_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE22_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE22_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe23_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[23]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*24-1):`DEF_PE_D_MEM_ADDR_WIDTH*23]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*24-1):`DEF_PE_DATA_WIDTH*23]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[23] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*24-1):`DEF_PE_DATA_WIDTH*23] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE23_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE23_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE23_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE23_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE23_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE23_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE23_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe24_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[24]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*25-1):`DEF_PE_D_MEM_ADDR_WIDTH*24]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*25-1):`DEF_PE_DATA_WIDTH*24]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[24] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*25-1):`DEF_PE_DATA_WIDTH*24] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE24_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE24_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE24_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE24_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE24_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE24_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE24_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe25_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[25]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*26-1):`DEF_PE_D_MEM_ADDR_WIDTH*25]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*26-1):`DEF_PE_DATA_WIDTH*25]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[25] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*26-1):`DEF_PE_DATA_WIDTH*25] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE25_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE25_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE25_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE25_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE25_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE25_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE25_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe26_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[26]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*27-1):`DEF_PE_D_MEM_ADDR_WIDTH*26]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*27-1):`DEF_PE_DATA_WIDTH*26]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[26] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*27-1):`DEF_PE_DATA_WIDTH*26] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE26_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE26_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE26_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE26_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE26_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE26_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE26_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe27_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[27]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*28-1):`DEF_PE_D_MEM_ADDR_WIDTH*27]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*28-1):`DEF_PE_DATA_WIDTH*27]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[27] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*28-1):`DEF_PE_DATA_WIDTH*27] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE27_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE27_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE27_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE27_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE27_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE27_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE27_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe28_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[28]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*29-1):`DEF_PE_D_MEM_ADDR_WIDTH*28]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*29-1):`DEF_PE_DATA_WIDTH*28]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[28] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*29-1):`DEF_PE_DATA_WIDTH*28] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE28_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE28_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE28_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE28_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE28_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE28_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE28_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe29_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[29]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*30-1):`DEF_PE_D_MEM_ADDR_WIDTH*29]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*30-1):`DEF_PE_DATA_WIDTH*29]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[29] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*30-1):`DEF_PE_DATA_WIDTH*29] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE29_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE29_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE29_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE29_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE29_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE29_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE29_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe30_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[30]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*31-1):`DEF_PE_D_MEM_ADDR_WIDTH*30]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*31-1):`DEF_PE_DATA_WIDTH*30]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[30] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*31-1):`DEF_PE_DATA_WIDTH*30] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE30_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE30_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE30_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE30_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE30_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE30_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE30_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe31_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[31]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*32-1):`DEF_PE_D_MEM_ADDR_WIDTH*31]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*32-1):`DEF_PE_DATA_WIDTH*31]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[31] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*32-1):`DEF_PE_DATA_WIDTH*31] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE31_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE31_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE31_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE31_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE31_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE31_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE31_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe32_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[32]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*33-1):`DEF_PE_D_MEM_ADDR_WIDTH*32]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*33-1):`DEF_PE_DATA_WIDTH*32]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[32] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*33-1):`DEF_PE_DATA_WIDTH*32] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE32_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE32_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE32_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE32_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE32_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE32_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE32_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe33_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[33]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*34-1):`DEF_PE_D_MEM_ADDR_WIDTH*33]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*34-1):`DEF_PE_DATA_WIDTH*33]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[33] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*34-1):`DEF_PE_DATA_WIDTH*33] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE33_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE33_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE33_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE33_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE33_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE33_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE33_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe34_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[34]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*35-1):`DEF_PE_D_MEM_ADDR_WIDTH*34]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*35-1):`DEF_PE_DATA_WIDTH*34]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[34] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*35-1):`DEF_PE_DATA_WIDTH*34] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE34_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE34_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE34_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE34_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE34_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE34_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE34_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe35_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[35]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*36-1):`DEF_PE_D_MEM_ADDR_WIDTH*35]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*36-1):`DEF_PE_DATA_WIDTH*35]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[35] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*36-1):`DEF_PE_DATA_WIDTH*35] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE35_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE35_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE35_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE35_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE35_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE35_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE35_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe36_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[36]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*37-1):`DEF_PE_D_MEM_ADDR_WIDTH*36]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*37-1):`DEF_PE_DATA_WIDTH*36]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[36] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*37-1):`DEF_PE_DATA_WIDTH*36] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE36_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE36_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE36_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE36_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE36_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE36_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE36_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe37_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[37]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*38-1):`DEF_PE_D_MEM_ADDR_WIDTH*37]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*38-1):`DEF_PE_DATA_WIDTH*37]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[37] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*38-1):`DEF_PE_DATA_WIDTH*37] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE37_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE37_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE37_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE37_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE37_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE37_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE37_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe38_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[38]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*39-1):`DEF_PE_D_MEM_ADDR_WIDTH*38]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*39-1):`DEF_PE_DATA_WIDTH*38]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[38] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*39-1):`DEF_PE_DATA_WIDTH*38] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE38_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE38_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE38_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE38_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE38_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE38_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE38_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe39_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[39]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*40-1):`DEF_PE_D_MEM_ADDR_WIDTH*39]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*40-1):`DEF_PE_DATA_WIDTH*39]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[39] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*40-1):`DEF_PE_DATA_WIDTH*39] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE39_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE39_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE39_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE39_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE39_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE39_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE39_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe40_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[40]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*41-1):`DEF_PE_D_MEM_ADDR_WIDTH*40]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*41-1):`DEF_PE_DATA_WIDTH*40]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[40] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*41-1):`DEF_PE_DATA_WIDTH*40] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE40_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE40_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE40_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE40_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE40_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE40_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE40_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe41_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[41]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*42-1):`DEF_PE_D_MEM_ADDR_WIDTH*41]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*42-1):`DEF_PE_DATA_WIDTH*41]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[41] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*42-1):`DEF_PE_DATA_WIDTH*41] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE41_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE41_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE41_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE41_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE41_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE41_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE41_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe42_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[42]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*43-1):`DEF_PE_D_MEM_ADDR_WIDTH*42]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*43-1):`DEF_PE_DATA_WIDTH*42]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[42] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*43-1):`DEF_PE_DATA_WIDTH*42] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE42_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE42_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE42_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE42_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE42_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE42_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE42_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe43_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[43]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*44-1):`DEF_PE_D_MEM_ADDR_WIDTH*43]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*44-1):`DEF_PE_DATA_WIDTH*43]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[43] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*44-1):`DEF_PE_DATA_WIDTH*43] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE43_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE43_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE43_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE43_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE43_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE43_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE43_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe44_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[44]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*45-1):`DEF_PE_D_MEM_ADDR_WIDTH*44]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*45-1):`DEF_PE_DATA_WIDTH*44]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[44] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*45-1):`DEF_PE_DATA_WIDTH*44] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE44_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE44_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE44_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE44_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE44_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE44_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE44_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe45_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[45]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*46-1):`DEF_PE_D_MEM_ADDR_WIDTH*45]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*46-1):`DEF_PE_DATA_WIDTH*45]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[45] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*46-1):`DEF_PE_DATA_WIDTH*45] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE45_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE45_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE45_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE45_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE45_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE45_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE45_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe46_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[46]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*47-1):`DEF_PE_D_MEM_ADDR_WIDTH*46]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*47-1):`DEF_PE_DATA_WIDTH*46]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[46] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*47-1):`DEF_PE_DATA_WIDTH*46] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE46_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE46_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE46_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE46_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE46_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE46_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE46_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe47_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[47]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*48-1):`DEF_PE_D_MEM_ADDR_WIDTH*47]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*48-1):`DEF_PE_DATA_WIDTH*47]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[47] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*48-1):`DEF_PE_DATA_WIDTH*47] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE47_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE47_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE47_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE47_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE47_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE47_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE47_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe48_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[48]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*49-1):`DEF_PE_D_MEM_ADDR_WIDTH*48]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*49-1):`DEF_PE_DATA_WIDTH*48]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[48] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*49-1):`DEF_PE_DATA_WIDTH*48] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE48_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE48_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE48_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE48_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE48_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE48_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE48_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe49_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[49]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*50-1):`DEF_PE_D_MEM_ADDR_WIDTH*49]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*50-1):`DEF_PE_DATA_WIDTH*49]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[49] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*50-1):`DEF_PE_DATA_WIDTH*49] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE49_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE49_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE49_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE49_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE49_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE49_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE49_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe50_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[50]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*51-1):`DEF_PE_D_MEM_ADDR_WIDTH*50]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*51-1):`DEF_PE_DATA_WIDTH*50]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[50] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*51-1):`DEF_PE_DATA_WIDTH*50] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE50_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE50_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE50_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE50_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE50_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE50_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE50_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe51_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[51]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*52-1):`DEF_PE_D_MEM_ADDR_WIDTH*51]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*52-1):`DEF_PE_DATA_WIDTH*51]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[51] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*52-1):`DEF_PE_DATA_WIDTH*51] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE51_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE51_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE51_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE51_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE51_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE51_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE51_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe52_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[52]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*53-1):`DEF_PE_D_MEM_ADDR_WIDTH*52]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*53-1):`DEF_PE_DATA_WIDTH*52]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[52] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*53-1):`DEF_PE_DATA_WIDTH*52] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE52_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE52_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE52_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE52_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE52_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE52_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE52_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe53_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[53]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*54-1):`DEF_PE_D_MEM_ADDR_WIDTH*53]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*54-1):`DEF_PE_DATA_WIDTH*53]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[53] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*54-1):`DEF_PE_DATA_WIDTH*53] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE53_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE53_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE53_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE53_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE53_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE53_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE53_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe54_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[54]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*55-1):`DEF_PE_D_MEM_ADDR_WIDTH*54]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*55-1):`DEF_PE_DATA_WIDTH*54]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[54] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*55-1):`DEF_PE_DATA_WIDTH*54] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE54_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE54_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE54_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE54_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE54_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE54_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE54_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe55_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[55]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*56-1):`DEF_PE_D_MEM_ADDR_WIDTH*55]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*56-1):`DEF_PE_DATA_WIDTH*55]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[55] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*56-1):`DEF_PE_DATA_WIDTH*55] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE55_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE55_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE55_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE55_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE55_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE55_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE55_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe56_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[56]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*57-1):`DEF_PE_D_MEM_ADDR_WIDTH*56]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*57-1):`DEF_PE_DATA_WIDTH*56]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[56] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*57-1):`DEF_PE_DATA_WIDTH*56] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE56_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE56_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE56_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE56_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE56_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE56_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE56_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe57_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[57]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*58-1):`DEF_PE_D_MEM_ADDR_WIDTH*57]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*58-1):`DEF_PE_DATA_WIDTH*57]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[57] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*58-1):`DEF_PE_DATA_WIDTH*57] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE57_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE57_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE57_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE57_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE57_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE57_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE57_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe58_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[58]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*59-1):`DEF_PE_D_MEM_ADDR_WIDTH*58]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*59-1):`DEF_PE_DATA_WIDTH*58]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[58] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*59-1):`DEF_PE_DATA_WIDTH*58] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE58_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE58_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE58_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE58_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE58_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE58_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE58_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe59_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[59]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*60-1):`DEF_PE_D_MEM_ADDR_WIDTH*59]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*60-1):`DEF_PE_DATA_WIDTH*59]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[59] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*60-1):`DEF_PE_DATA_WIDTH*59] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE59_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE59_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE59_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE59_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE59_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE59_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE59_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe60_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[60]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*61-1):`DEF_PE_D_MEM_ADDR_WIDTH*60]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*61-1):`DEF_PE_DATA_WIDTH*60]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[60] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*61-1):`DEF_PE_DATA_WIDTH*60] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE60_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE60_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE60_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE60_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE60_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE60_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE60_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe61_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[61]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*62-1):`DEF_PE_D_MEM_ADDR_WIDTH*61]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*62-1):`DEF_PE_DATA_WIDTH*61]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[61] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*62-1):`DEF_PE_DATA_WIDTH*61] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE61_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE61_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE61_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE61_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE61_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE61_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE61_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe62_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[62]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*63-1):`DEF_PE_D_MEM_ADDR_WIDTH*62]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*63-1):`DEF_PE_DATA_WIDTH*62]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[62] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*63-1):`DEF_PE_DATA_WIDTH*62] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE62_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE62_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE62_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE62_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE62_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE62_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE62_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe63_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[63]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*64-1):`DEF_PE_D_MEM_ADDR_WIDTH*63]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*64-1):`DEF_PE_DATA_WIDTH*63]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[63] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*64-1):`DEF_PE_DATA_WIDTH*63] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE63_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE63_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE63_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE63_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE63_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE63_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE63_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe64_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[64]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*65-1):`DEF_PE_D_MEM_ADDR_WIDTH*64]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*65-1):`DEF_PE_DATA_WIDTH*64]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[64] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*65-1):`DEF_PE_DATA_WIDTH*64] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE64_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE64_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE64_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE64_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE64_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE64_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE64_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe65_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[65]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*66-1):`DEF_PE_D_MEM_ADDR_WIDTH*65]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*66-1):`DEF_PE_DATA_WIDTH*65]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[65] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*66-1):`DEF_PE_DATA_WIDTH*65] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE65_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE65_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE65_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE65_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE65_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE65_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE65_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe66_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[66]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*67-1):`DEF_PE_D_MEM_ADDR_WIDTH*66]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*67-1):`DEF_PE_DATA_WIDTH*66]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[66] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*67-1):`DEF_PE_DATA_WIDTH*66] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE66_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE66_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE66_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE66_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE66_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE66_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE66_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe67_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[67]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*68-1):`DEF_PE_D_MEM_ADDR_WIDTH*67]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*68-1):`DEF_PE_DATA_WIDTH*67]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[67] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*68-1):`DEF_PE_DATA_WIDTH*67] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE67_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE67_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE67_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE67_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE67_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE67_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE67_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe68_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[68]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*69-1):`DEF_PE_D_MEM_ADDR_WIDTH*68]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*69-1):`DEF_PE_DATA_WIDTH*68]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[68] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*69-1):`DEF_PE_DATA_WIDTH*68] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE68_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE68_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE68_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE68_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE68_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE68_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE68_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe69_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[69]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*70-1):`DEF_PE_D_MEM_ADDR_WIDTH*69]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*70-1):`DEF_PE_DATA_WIDTH*69]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[69] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*70-1):`DEF_PE_DATA_WIDTH*69] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE69_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE69_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE69_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE69_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE69_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE69_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE69_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe70_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[70]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*71-1):`DEF_PE_D_MEM_ADDR_WIDTH*70]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*71-1):`DEF_PE_DATA_WIDTH*70]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[70] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*71-1):`DEF_PE_DATA_WIDTH*70] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE70_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE70_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE70_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE70_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE70_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE70_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE70_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe71_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[71]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*72-1):`DEF_PE_D_MEM_ADDR_WIDTH*71]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*72-1):`DEF_PE_DATA_WIDTH*71]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[71] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*72-1):`DEF_PE_DATA_WIDTH*71] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE71_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE71_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE71_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE71_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE71_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE71_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE71_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe72_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[72]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*73-1):`DEF_PE_D_MEM_ADDR_WIDTH*72]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*73-1):`DEF_PE_DATA_WIDTH*72]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[72] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*73-1):`DEF_PE_DATA_WIDTH*72] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE72_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE72_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE72_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE72_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE72_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE72_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE72_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe73_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[73]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*74-1):`DEF_PE_D_MEM_ADDR_WIDTH*73]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*74-1):`DEF_PE_DATA_WIDTH*73]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[73] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*74-1):`DEF_PE_DATA_WIDTH*73] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE73_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE73_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE73_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE73_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE73_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE73_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE73_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe74_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[74]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*75-1):`DEF_PE_D_MEM_ADDR_WIDTH*74]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*75-1):`DEF_PE_DATA_WIDTH*74]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[74] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*75-1):`DEF_PE_DATA_WIDTH*74] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE74_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE74_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE74_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE74_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE74_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE74_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE74_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe75_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[75]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*76-1):`DEF_PE_D_MEM_ADDR_WIDTH*75]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*76-1):`DEF_PE_DATA_WIDTH*75]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[75] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*76-1):`DEF_PE_DATA_WIDTH*75] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE75_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE75_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE75_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE75_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE75_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE75_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE75_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe76_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[76]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*77-1):`DEF_PE_D_MEM_ADDR_WIDTH*76]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*77-1):`DEF_PE_DATA_WIDTH*76]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[76] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*77-1):`DEF_PE_DATA_WIDTH*76] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE76_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE76_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE76_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE76_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE76_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE76_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE76_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe77_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[77]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*78-1):`DEF_PE_D_MEM_ADDR_WIDTH*77]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*78-1):`DEF_PE_DATA_WIDTH*77]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[77] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*78-1):`DEF_PE_DATA_WIDTH*77] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE77_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE77_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE77_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE77_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE77_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE77_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE77_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe78_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[78]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*79-1):`DEF_PE_D_MEM_ADDR_WIDTH*78]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*79-1):`DEF_PE_DATA_WIDTH*78]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[78] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*79-1):`DEF_PE_DATA_WIDTH*78] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE78_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE78_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE78_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE78_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE78_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE78_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE78_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe79_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[79]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*80-1):`DEF_PE_D_MEM_ADDR_WIDTH*79]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*80-1):`DEF_PE_DATA_WIDTH*79]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[79] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*80-1):`DEF_PE_DATA_WIDTH*79] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE79_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE79_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE79_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE79_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE79_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE79_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE79_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe80_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[80]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*81-1):`DEF_PE_D_MEM_ADDR_WIDTH*80]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*81-1):`DEF_PE_DATA_WIDTH*80]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[80] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*81-1):`DEF_PE_DATA_WIDTH*80] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE80_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE80_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE80_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE80_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE80_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE80_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE80_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe81_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[81]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*82-1):`DEF_PE_D_MEM_ADDR_WIDTH*81]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*82-1):`DEF_PE_DATA_WIDTH*81]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[81] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*82-1):`DEF_PE_DATA_WIDTH*81] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE81_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE81_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE81_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE81_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE81_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE81_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE81_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe82_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[82]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*83-1):`DEF_PE_D_MEM_ADDR_WIDTH*82]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*83-1):`DEF_PE_DATA_WIDTH*82]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[82] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*83-1):`DEF_PE_DATA_WIDTH*82] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE82_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE82_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE82_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE82_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE82_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE82_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE82_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe83_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[83]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*84-1):`DEF_PE_D_MEM_ADDR_WIDTH*83]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*84-1):`DEF_PE_DATA_WIDTH*83]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[83] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*84-1):`DEF_PE_DATA_WIDTH*83] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE83_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE83_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE83_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE83_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE83_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE83_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE83_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe84_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[84]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*85-1):`DEF_PE_D_MEM_ADDR_WIDTH*84]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*85-1):`DEF_PE_DATA_WIDTH*84]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[84] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*85-1):`DEF_PE_DATA_WIDTH*84] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE84_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE84_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE84_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE84_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE84_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE84_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE84_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe85_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[85]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*86-1):`DEF_PE_D_MEM_ADDR_WIDTH*85]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*86-1):`DEF_PE_DATA_WIDTH*85]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[85] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*86-1):`DEF_PE_DATA_WIDTH*85] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE85_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE85_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE85_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE85_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE85_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE85_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE85_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe86_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[86]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*87-1):`DEF_PE_D_MEM_ADDR_WIDTH*86]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*87-1):`DEF_PE_DATA_WIDTH*86]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[86] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*87-1):`DEF_PE_DATA_WIDTH*86] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE86_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE86_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE86_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE86_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE86_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE86_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE86_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe87_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[87]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*88-1):`DEF_PE_D_MEM_ADDR_WIDTH*87]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*88-1):`DEF_PE_DATA_WIDTH*87]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[87] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*88-1):`DEF_PE_DATA_WIDTH*87] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE87_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE87_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE87_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE87_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE87_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE87_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE87_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe88_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[88]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*89-1):`DEF_PE_D_MEM_ADDR_WIDTH*88]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*89-1):`DEF_PE_DATA_WIDTH*88]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[88] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*89-1):`DEF_PE_DATA_WIDTH*88] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE88_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE88_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE88_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE88_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE88_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE88_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE88_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe89_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[89]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*90-1):`DEF_PE_D_MEM_ADDR_WIDTH*89]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*90-1):`DEF_PE_DATA_WIDTH*89]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[89] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*90-1):`DEF_PE_DATA_WIDTH*89] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE89_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE89_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE89_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE89_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE89_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE89_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE89_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe90_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[90]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*91-1):`DEF_PE_D_MEM_ADDR_WIDTH*90]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*91-1):`DEF_PE_DATA_WIDTH*90]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[90] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*91-1):`DEF_PE_DATA_WIDTH*90] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE90_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE90_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE90_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE90_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE90_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE90_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE90_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe91_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[91]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*92-1):`DEF_PE_D_MEM_ADDR_WIDTH*91]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*92-1):`DEF_PE_DATA_WIDTH*91]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[91] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*92-1):`DEF_PE_DATA_WIDTH*91] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE91_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE91_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE91_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE91_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE91_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE91_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE91_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe92_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[92]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*93-1):`DEF_PE_D_MEM_ADDR_WIDTH*92]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*93-1):`DEF_PE_DATA_WIDTH*92]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[92] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*93-1):`DEF_PE_DATA_WIDTH*92] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE92_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE92_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE92_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE92_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE92_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE92_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE92_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe93_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[93]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*94-1):`DEF_PE_D_MEM_ADDR_WIDTH*93]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*94-1):`DEF_PE_DATA_WIDTH*93]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[93] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*94-1):`DEF_PE_DATA_WIDTH*93] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE93_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE93_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE93_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE93_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE93_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE93_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE93_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe94_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[94]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*95-1):`DEF_PE_D_MEM_ADDR_WIDTH*94]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*95-1):`DEF_PE_DATA_WIDTH*94]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[94] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*95-1):`DEF_PE_DATA_WIDTH*94] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE94_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE94_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE94_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE94_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE94_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE94_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE94_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe95_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[95]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*96-1):`DEF_PE_D_MEM_ADDR_WIDTH*95]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*96-1):`DEF_PE_DATA_WIDTH*95]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[95] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*96-1):`DEF_PE_DATA_WIDTH*95] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE95_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE95_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE95_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE95_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE95_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE95_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE95_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe96_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[96]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*97-1):`DEF_PE_D_MEM_ADDR_WIDTH*96]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*97-1):`DEF_PE_DATA_WIDTH*96]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[96] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*97-1):`DEF_PE_DATA_WIDTH*96] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE96_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE96_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE96_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE96_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE96_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE96_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE96_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe97_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[97]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*98-1):`DEF_PE_D_MEM_ADDR_WIDTH*97]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*98-1):`DEF_PE_DATA_WIDTH*97]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[97] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*98-1):`DEF_PE_DATA_WIDTH*97] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE97_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE97_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE97_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE97_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE97_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE97_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE97_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe98_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[98]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*99-1):`DEF_PE_D_MEM_ADDR_WIDTH*98]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*99-1):`DEF_PE_DATA_WIDTH*98]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[98] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*99-1):`DEF_PE_DATA_WIDTH*98] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE98_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE98_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE98_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE98_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE98_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE98_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE98_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe99_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[99]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*100-1):`DEF_PE_D_MEM_ADDR_WIDTH*99]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*100-1):`DEF_PE_DATA_WIDTH*99]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[99] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*100-1):`DEF_PE_DATA_WIDTH*99] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE99_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE99_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE99_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE99_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE99_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE99_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE99_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe100_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[100]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*101-1):`DEF_PE_D_MEM_ADDR_WIDTH*100]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*101-1):`DEF_PE_DATA_WIDTH*100]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[100] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*101-1):`DEF_PE_DATA_WIDTH*100] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE100_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE100_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE100_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE100_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE100_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE100_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE100_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe101_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[101]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*102-1):`DEF_PE_D_MEM_ADDR_WIDTH*101]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*102-1):`DEF_PE_DATA_WIDTH*101]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[101] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*102-1):`DEF_PE_DATA_WIDTH*101] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE101_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE101_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE101_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE101_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE101_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE101_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE101_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe102_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[102]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*103-1):`DEF_PE_D_MEM_ADDR_WIDTH*102]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*103-1):`DEF_PE_DATA_WIDTH*102]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[102] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*103-1):`DEF_PE_DATA_WIDTH*102] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE102_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE102_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE102_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE102_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE102_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE102_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE102_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe103_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[103]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*104-1):`DEF_PE_D_MEM_ADDR_WIDTH*103]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*104-1):`DEF_PE_DATA_WIDTH*103]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[103] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*104-1):`DEF_PE_DATA_WIDTH*103] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE103_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE103_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE103_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE103_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE103_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE103_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE103_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe104_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[104]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*105-1):`DEF_PE_D_MEM_ADDR_WIDTH*104]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*105-1):`DEF_PE_DATA_WIDTH*104]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[104] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*105-1):`DEF_PE_DATA_WIDTH*104] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE104_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE104_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE104_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE104_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE104_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE104_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE104_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe105_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[105]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*106-1):`DEF_PE_D_MEM_ADDR_WIDTH*105]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*106-1):`DEF_PE_DATA_WIDTH*105]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[105] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*106-1):`DEF_PE_DATA_WIDTH*105] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE105_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE105_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE105_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE105_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE105_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE105_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE105_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe106_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[106]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*107-1):`DEF_PE_D_MEM_ADDR_WIDTH*106]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*107-1):`DEF_PE_DATA_WIDTH*106]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[106] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*107-1):`DEF_PE_DATA_WIDTH*106] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE106_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE106_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE106_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE106_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE106_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE106_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE106_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe107_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[107]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*108-1):`DEF_PE_D_MEM_ADDR_WIDTH*107]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*108-1):`DEF_PE_DATA_WIDTH*107]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[107] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*108-1):`DEF_PE_DATA_WIDTH*107] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE107_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE107_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE107_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE107_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE107_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE107_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE107_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe108_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[108]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*109-1):`DEF_PE_D_MEM_ADDR_WIDTH*108]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*109-1):`DEF_PE_DATA_WIDTH*108]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[108] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*109-1):`DEF_PE_DATA_WIDTH*108] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE108_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE108_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE108_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE108_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE108_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE108_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE108_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe109_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[109]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*110-1):`DEF_PE_D_MEM_ADDR_WIDTH*109]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*110-1):`DEF_PE_DATA_WIDTH*109]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[109] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*110-1):`DEF_PE_DATA_WIDTH*109] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE109_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE109_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE109_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE109_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE109_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE109_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE109_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe110_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[110]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*111-1):`DEF_PE_D_MEM_ADDR_WIDTH*110]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*111-1):`DEF_PE_DATA_WIDTH*110]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[110] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*111-1):`DEF_PE_DATA_WIDTH*110] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE110_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE110_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE110_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE110_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE110_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE110_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE110_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe111_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[111]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*112-1):`DEF_PE_D_MEM_ADDR_WIDTH*111]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*112-1):`DEF_PE_DATA_WIDTH*111]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[111] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*112-1):`DEF_PE_DATA_WIDTH*111] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE111_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE111_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE111_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE111_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE111_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE111_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE111_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe112_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[112]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*113-1):`DEF_PE_D_MEM_ADDR_WIDTH*112]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*113-1):`DEF_PE_DATA_WIDTH*112]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[112] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*113-1):`DEF_PE_DATA_WIDTH*112] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE112_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE112_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE112_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE112_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE112_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE112_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE112_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe113_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[113]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*114-1):`DEF_PE_D_MEM_ADDR_WIDTH*113]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*114-1):`DEF_PE_DATA_WIDTH*113]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[113] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*114-1):`DEF_PE_DATA_WIDTH*113] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE113_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE113_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE113_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE113_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE113_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE113_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE113_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe114_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[114]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*115-1):`DEF_PE_D_MEM_ADDR_WIDTH*114]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*115-1):`DEF_PE_DATA_WIDTH*114]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[114] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*115-1):`DEF_PE_DATA_WIDTH*114] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE114_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE114_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE114_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE114_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE114_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE114_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE114_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe115_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[115]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*116-1):`DEF_PE_D_MEM_ADDR_WIDTH*115]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*116-1):`DEF_PE_DATA_WIDTH*115]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[115] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*116-1):`DEF_PE_DATA_WIDTH*115] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE115_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE115_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE115_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE115_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE115_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE115_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE115_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe116_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[116]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*117-1):`DEF_PE_D_MEM_ADDR_WIDTH*116]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*117-1):`DEF_PE_DATA_WIDTH*116]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[116] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*117-1):`DEF_PE_DATA_WIDTH*116] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE116_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE116_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE116_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE116_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE116_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE116_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE116_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe117_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[117]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*118-1):`DEF_PE_D_MEM_ADDR_WIDTH*117]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*118-1):`DEF_PE_DATA_WIDTH*117]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[117] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*118-1):`DEF_PE_DATA_WIDTH*117] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE117_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE117_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE117_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE117_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE117_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE117_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE117_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe118_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[118]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*119-1):`DEF_PE_D_MEM_ADDR_WIDTH*118]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*119-1):`DEF_PE_DATA_WIDTH*118]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[118] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*119-1):`DEF_PE_DATA_WIDTH*118] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE118_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE118_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE118_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE118_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE118_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE118_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE118_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe119_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[119]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*120-1):`DEF_PE_D_MEM_ADDR_WIDTH*119]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*120-1):`DEF_PE_DATA_WIDTH*119]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[119] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*120-1):`DEF_PE_DATA_WIDTH*119] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE119_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE119_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE119_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE119_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE119_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE119_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE119_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe120_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[120]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*121-1):`DEF_PE_D_MEM_ADDR_WIDTH*120]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*121-1):`DEF_PE_DATA_WIDTH*120]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[120] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*121-1):`DEF_PE_DATA_WIDTH*120] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE120_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE120_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE120_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE120_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE120_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE120_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE120_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe121_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[121]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*122-1):`DEF_PE_D_MEM_ADDR_WIDTH*121]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*122-1):`DEF_PE_DATA_WIDTH*121]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[121] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*122-1):`DEF_PE_DATA_WIDTH*121] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE121_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE121_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE121_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE121_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE121_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE121_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE121_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe122_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[122]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*123-1):`DEF_PE_D_MEM_ADDR_WIDTH*122]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*123-1):`DEF_PE_DATA_WIDTH*122]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[122] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*123-1):`DEF_PE_DATA_WIDTH*122] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE122_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE122_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE122_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE122_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE122_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE122_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE122_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe123_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[123]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*124-1):`DEF_PE_D_MEM_ADDR_WIDTH*123]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*124-1):`DEF_PE_DATA_WIDTH*123]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[123] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*124-1):`DEF_PE_DATA_WIDTH*123] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE123_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE123_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE123_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE123_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE123_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE123_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE123_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe124_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[124]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*125-1):`DEF_PE_D_MEM_ADDR_WIDTH*124]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*125-1):`DEF_PE_DATA_WIDTH*124]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[124] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*125-1):`DEF_PE_DATA_WIDTH*124] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE124_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE124_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE124_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE124_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE124_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE124_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE124_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe125_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[125]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*126-1):`DEF_PE_D_MEM_ADDR_WIDTH*125]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*126-1):`DEF_PE_DATA_WIDTH*125]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[125] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*126-1):`DEF_PE_DATA_WIDTH*125] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE125_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE125_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE125_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE125_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE125_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE125_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE125_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe126_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[126]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*127-1):`DEF_PE_D_MEM_ADDR_WIDTH*126]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*127-1):`DEF_PE_DATA_WIDTH*126]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[126] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*127-1):`DEF_PE_DATA_WIDTH*126] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE126_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE126_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE126_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE126_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE126_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE126_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE126_DMEM_EX_Data          )  // data loaded from data memory
  );
  
  pe_dmem inst_pe127_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[127]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*128-1):`DEF_PE_D_MEM_ADDR_WIDTH*127]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*128-1):`DEF_PE_DATA_WIDTH*127]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[127] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*128-1):`DEF_PE_DATA_WIDTH*127] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE127_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE127_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE127_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE127_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE127_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE127_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE127_DMEM_EX_Data          )  // data loaded from data memory
  );
  

  // core top module
  core_top inst_core_top(
    .iClk                          ( iClk                      ),  // system clock, positive-edge trigger
    .iReset                        ( iReset                    ),  // global synchronous reset signal, Active high

    .oIF_ID_PC                     ( oIF_ID_PC                 ),  // current PC for debug
    .oTask_Finished                ( oTask_Finished            ),  // indicate the end of the program

    // -----
    //  CP
    // -----
    .oIF_IMEM_Address              ( wIF_IMEM_Address          ),  // instruciton memory address
    .iIMEM_CP_Instruction          ( wIMEM_CP_Instruction      ),  // DEF_CP_INS_WIDTH + 2 bits communication + 2-bit predication

    .oCP_DMEM_Valid                ( wCP_DMEM_Valid            ),  // memory access valid
    .oCP_AGU_DMEM_Write_Enable     ( wCP_AGU_DMEM_Write_Enable ),  // stage data-memory write enable
    .oCP_AGU_DMEM_Read_Enable      ( wCP_AGU_DMEM_Read_Enable  ),  // stage data-memory read enable
    .oCP_AGU_DMEM_Byte_Select      ( wCP_AGU_DMEM_Byte_Select  ),  // memory byte selection
    .oCP_AGU_DMEM_Address          ( wCP_AGU_DMEM_Address      ),
    .oCP_AGU_DMEM_Write_Data       ( wCP_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iCP_DMEM_EX_Data              ( wCP_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE0
    .oPE0_DMEM_Valid            ( wPE0_DMEM_Valid           ),
    .oPE0_AGU_DMEM_Write_Enable ( wPE0_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE0_AGU_DMEM_Read_Enable  ( wPE0_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE0_AGU_DMEM_Byte_Select  ( wPE0_AGU_DMEM_Byte_Select ),
    .oPE0_AGU_DMEM_Address      ( wPE0_AGU_DMEM_Address     ),  // data memory address
    .oPE0_AGU_DMEM_Write_Data   ( wPE0_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE0_DMEM_EX_Data          ( wPE0_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE1
    .oPE1_DMEM_Valid            ( wPE1_DMEM_Valid           ),
    .oPE1_AGU_DMEM_Write_Enable ( wPE1_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE1_AGU_DMEM_Read_Enable  ( wPE1_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE1_AGU_DMEM_Byte_Select  ( wPE1_AGU_DMEM_Byte_Select ),
    .oPE1_AGU_DMEM_Address      ( wPE1_AGU_DMEM_Address     ),  // data memory address
    .oPE1_AGU_DMEM_Write_Data   ( wPE1_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE1_DMEM_EX_Data          ( wPE1_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE2
    .oPE2_DMEM_Valid            ( wPE2_DMEM_Valid           ),
    .oPE2_AGU_DMEM_Write_Enable ( wPE2_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE2_AGU_DMEM_Read_Enable  ( wPE2_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE2_AGU_DMEM_Byte_Select  ( wPE2_AGU_DMEM_Byte_Select ),
    .oPE2_AGU_DMEM_Address      ( wPE2_AGU_DMEM_Address     ),  // data memory address
    .oPE2_AGU_DMEM_Write_Data   ( wPE2_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE2_DMEM_EX_Data          ( wPE2_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE3
    .oPE3_DMEM_Valid            ( wPE3_DMEM_Valid           ),
    .oPE3_AGU_DMEM_Write_Enable ( wPE3_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE3_AGU_DMEM_Read_Enable  ( wPE3_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE3_AGU_DMEM_Byte_Select  ( wPE3_AGU_DMEM_Byte_Select ),
    .oPE3_AGU_DMEM_Address      ( wPE3_AGU_DMEM_Address     ),  // data memory address
    .oPE3_AGU_DMEM_Write_Data   ( wPE3_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE3_DMEM_EX_Data          ( wPE3_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE4
    .oPE4_DMEM_Valid            ( wPE4_DMEM_Valid           ),
    .oPE4_AGU_DMEM_Write_Enable ( wPE4_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE4_AGU_DMEM_Read_Enable  ( wPE4_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE4_AGU_DMEM_Byte_Select  ( wPE4_AGU_DMEM_Byte_Select ),
    .oPE4_AGU_DMEM_Address      ( wPE4_AGU_DMEM_Address     ),  // data memory address
    .oPE4_AGU_DMEM_Write_Data   ( wPE4_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE4_DMEM_EX_Data          ( wPE4_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE5
    .oPE5_DMEM_Valid            ( wPE5_DMEM_Valid           ),
    .oPE5_AGU_DMEM_Write_Enable ( wPE5_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE5_AGU_DMEM_Read_Enable  ( wPE5_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE5_AGU_DMEM_Byte_Select  ( wPE5_AGU_DMEM_Byte_Select ),
    .oPE5_AGU_DMEM_Address      ( wPE5_AGU_DMEM_Address     ),  // data memory address
    .oPE5_AGU_DMEM_Write_Data   ( wPE5_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE5_DMEM_EX_Data          ( wPE5_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE6
    .oPE6_DMEM_Valid            ( wPE6_DMEM_Valid           ),
    .oPE6_AGU_DMEM_Write_Enable ( wPE6_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE6_AGU_DMEM_Read_Enable  ( wPE6_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE6_AGU_DMEM_Byte_Select  ( wPE6_AGU_DMEM_Byte_Select ),
    .oPE6_AGU_DMEM_Address      ( wPE6_AGU_DMEM_Address     ),  // data memory address
    .oPE6_AGU_DMEM_Write_Data   ( wPE6_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE6_DMEM_EX_Data          ( wPE6_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE7
    .oPE7_DMEM_Valid            ( wPE7_DMEM_Valid           ),
    .oPE7_AGU_DMEM_Write_Enable ( wPE7_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE7_AGU_DMEM_Read_Enable  ( wPE7_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE7_AGU_DMEM_Byte_Select  ( wPE7_AGU_DMEM_Byte_Select ),
    .oPE7_AGU_DMEM_Address      ( wPE7_AGU_DMEM_Address     ),  // data memory address
    .oPE7_AGU_DMEM_Write_Data   ( wPE7_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE7_DMEM_EX_Data          ( wPE7_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE8
    .oPE8_DMEM_Valid            ( wPE8_DMEM_Valid           ),
    .oPE8_AGU_DMEM_Write_Enable ( wPE8_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE8_AGU_DMEM_Read_Enable  ( wPE8_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE8_AGU_DMEM_Byte_Select  ( wPE8_AGU_DMEM_Byte_Select ),
    .oPE8_AGU_DMEM_Address      ( wPE8_AGU_DMEM_Address     ),  // data memory address
    .oPE8_AGU_DMEM_Write_Data   ( wPE8_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE8_DMEM_EX_Data          ( wPE8_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE9
    .oPE9_DMEM_Valid            ( wPE9_DMEM_Valid           ),
    .oPE9_AGU_DMEM_Write_Enable ( wPE9_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE9_AGU_DMEM_Read_Enable  ( wPE9_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE9_AGU_DMEM_Byte_Select  ( wPE9_AGU_DMEM_Byte_Select ),
    .oPE9_AGU_DMEM_Address      ( wPE9_AGU_DMEM_Address     ),  // data memory address
    .oPE9_AGU_DMEM_Write_Data   ( wPE9_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE9_DMEM_EX_Data          ( wPE9_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE10
    .oPE10_DMEM_Valid            ( wPE10_DMEM_Valid           ),
    .oPE10_AGU_DMEM_Write_Enable ( wPE10_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE10_AGU_DMEM_Read_Enable  ( wPE10_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE10_AGU_DMEM_Byte_Select  ( wPE10_AGU_DMEM_Byte_Select ),
    .oPE10_AGU_DMEM_Address      ( wPE10_AGU_DMEM_Address     ),  // data memory address
    .oPE10_AGU_DMEM_Write_Data   ( wPE10_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE10_DMEM_EX_Data          ( wPE10_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE11
    .oPE11_DMEM_Valid            ( wPE11_DMEM_Valid           ),
    .oPE11_AGU_DMEM_Write_Enable ( wPE11_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE11_AGU_DMEM_Read_Enable  ( wPE11_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE11_AGU_DMEM_Byte_Select  ( wPE11_AGU_DMEM_Byte_Select ),
    .oPE11_AGU_DMEM_Address      ( wPE11_AGU_DMEM_Address     ),  // data memory address
    .oPE11_AGU_DMEM_Write_Data   ( wPE11_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE11_DMEM_EX_Data          ( wPE11_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE12
    .oPE12_DMEM_Valid            ( wPE12_DMEM_Valid           ),
    .oPE12_AGU_DMEM_Write_Enable ( wPE12_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE12_AGU_DMEM_Read_Enable  ( wPE12_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE12_AGU_DMEM_Byte_Select  ( wPE12_AGU_DMEM_Byte_Select ),
    .oPE12_AGU_DMEM_Address      ( wPE12_AGU_DMEM_Address     ),  // data memory address
    .oPE12_AGU_DMEM_Write_Data   ( wPE12_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE12_DMEM_EX_Data          ( wPE12_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE13
    .oPE13_DMEM_Valid            ( wPE13_DMEM_Valid           ),
    .oPE13_AGU_DMEM_Write_Enable ( wPE13_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE13_AGU_DMEM_Read_Enable  ( wPE13_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE13_AGU_DMEM_Byte_Select  ( wPE13_AGU_DMEM_Byte_Select ),
    .oPE13_AGU_DMEM_Address      ( wPE13_AGU_DMEM_Address     ),  // data memory address
    .oPE13_AGU_DMEM_Write_Data   ( wPE13_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE13_DMEM_EX_Data          ( wPE13_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE14
    .oPE14_DMEM_Valid            ( wPE14_DMEM_Valid           ),
    .oPE14_AGU_DMEM_Write_Enable ( wPE14_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE14_AGU_DMEM_Read_Enable  ( wPE14_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE14_AGU_DMEM_Byte_Select  ( wPE14_AGU_DMEM_Byte_Select ),
    .oPE14_AGU_DMEM_Address      ( wPE14_AGU_DMEM_Address     ),  // data memory address
    .oPE14_AGU_DMEM_Write_Data   ( wPE14_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE14_DMEM_EX_Data          ( wPE14_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE15
    .oPE15_DMEM_Valid            ( wPE15_DMEM_Valid           ),
    .oPE15_AGU_DMEM_Write_Enable ( wPE15_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE15_AGU_DMEM_Read_Enable  ( wPE15_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE15_AGU_DMEM_Byte_Select  ( wPE15_AGU_DMEM_Byte_Select ),
    .oPE15_AGU_DMEM_Address      ( wPE15_AGU_DMEM_Address     ),  // data memory address
    .oPE15_AGU_DMEM_Write_Data   ( wPE15_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE15_DMEM_EX_Data          ( wPE15_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE16
    .oPE16_DMEM_Valid            ( wPE16_DMEM_Valid           ),
    .oPE16_AGU_DMEM_Write_Enable ( wPE16_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE16_AGU_DMEM_Read_Enable  ( wPE16_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE16_AGU_DMEM_Byte_Select  ( wPE16_AGU_DMEM_Byte_Select ),
    .oPE16_AGU_DMEM_Address      ( wPE16_AGU_DMEM_Address     ),  // data memory address
    .oPE16_AGU_DMEM_Write_Data   ( wPE16_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE16_DMEM_EX_Data          ( wPE16_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE17
    .oPE17_DMEM_Valid            ( wPE17_DMEM_Valid           ),
    .oPE17_AGU_DMEM_Write_Enable ( wPE17_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE17_AGU_DMEM_Read_Enable  ( wPE17_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE17_AGU_DMEM_Byte_Select  ( wPE17_AGU_DMEM_Byte_Select ),
    .oPE17_AGU_DMEM_Address      ( wPE17_AGU_DMEM_Address     ),  // data memory address
    .oPE17_AGU_DMEM_Write_Data   ( wPE17_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE17_DMEM_EX_Data          ( wPE17_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE18
    .oPE18_DMEM_Valid            ( wPE18_DMEM_Valid           ),
    .oPE18_AGU_DMEM_Write_Enable ( wPE18_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE18_AGU_DMEM_Read_Enable  ( wPE18_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE18_AGU_DMEM_Byte_Select  ( wPE18_AGU_DMEM_Byte_Select ),
    .oPE18_AGU_DMEM_Address      ( wPE18_AGU_DMEM_Address     ),  // data memory address
    .oPE18_AGU_DMEM_Write_Data   ( wPE18_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE18_DMEM_EX_Data          ( wPE18_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE19
    .oPE19_DMEM_Valid            ( wPE19_DMEM_Valid           ),
    .oPE19_AGU_DMEM_Write_Enable ( wPE19_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE19_AGU_DMEM_Read_Enable  ( wPE19_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE19_AGU_DMEM_Byte_Select  ( wPE19_AGU_DMEM_Byte_Select ),
    .oPE19_AGU_DMEM_Address      ( wPE19_AGU_DMEM_Address     ),  // data memory address
    .oPE19_AGU_DMEM_Write_Data   ( wPE19_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE19_DMEM_EX_Data          ( wPE19_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE20
    .oPE20_DMEM_Valid            ( wPE20_DMEM_Valid           ),
    .oPE20_AGU_DMEM_Write_Enable ( wPE20_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE20_AGU_DMEM_Read_Enable  ( wPE20_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE20_AGU_DMEM_Byte_Select  ( wPE20_AGU_DMEM_Byte_Select ),
    .oPE20_AGU_DMEM_Address      ( wPE20_AGU_DMEM_Address     ),  // data memory address
    .oPE20_AGU_DMEM_Write_Data   ( wPE20_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE20_DMEM_EX_Data          ( wPE20_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE21
    .oPE21_DMEM_Valid            ( wPE21_DMEM_Valid           ),
    .oPE21_AGU_DMEM_Write_Enable ( wPE21_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE21_AGU_DMEM_Read_Enable  ( wPE21_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE21_AGU_DMEM_Byte_Select  ( wPE21_AGU_DMEM_Byte_Select ),
    .oPE21_AGU_DMEM_Address      ( wPE21_AGU_DMEM_Address     ),  // data memory address
    .oPE21_AGU_DMEM_Write_Data   ( wPE21_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE21_DMEM_EX_Data          ( wPE21_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE22
    .oPE22_DMEM_Valid            ( wPE22_DMEM_Valid           ),
    .oPE22_AGU_DMEM_Write_Enable ( wPE22_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE22_AGU_DMEM_Read_Enable  ( wPE22_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE22_AGU_DMEM_Byte_Select  ( wPE22_AGU_DMEM_Byte_Select ),
    .oPE22_AGU_DMEM_Address      ( wPE22_AGU_DMEM_Address     ),  // data memory address
    .oPE22_AGU_DMEM_Write_Data   ( wPE22_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE22_DMEM_EX_Data          ( wPE22_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE23
    .oPE23_DMEM_Valid            ( wPE23_DMEM_Valid           ),
    .oPE23_AGU_DMEM_Write_Enable ( wPE23_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE23_AGU_DMEM_Read_Enable  ( wPE23_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE23_AGU_DMEM_Byte_Select  ( wPE23_AGU_DMEM_Byte_Select ),
    .oPE23_AGU_DMEM_Address      ( wPE23_AGU_DMEM_Address     ),  // data memory address
    .oPE23_AGU_DMEM_Write_Data   ( wPE23_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE23_DMEM_EX_Data          ( wPE23_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE24
    .oPE24_DMEM_Valid            ( wPE24_DMEM_Valid           ),
    .oPE24_AGU_DMEM_Write_Enable ( wPE24_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE24_AGU_DMEM_Read_Enable  ( wPE24_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE24_AGU_DMEM_Byte_Select  ( wPE24_AGU_DMEM_Byte_Select ),
    .oPE24_AGU_DMEM_Address      ( wPE24_AGU_DMEM_Address     ),  // data memory address
    .oPE24_AGU_DMEM_Write_Data   ( wPE24_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE24_DMEM_EX_Data          ( wPE24_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE25
    .oPE25_DMEM_Valid            ( wPE25_DMEM_Valid           ),
    .oPE25_AGU_DMEM_Write_Enable ( wPE25_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE25_AGU_DMEM_Read_Enable  ( wPE25_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE25_AGU_DMEM_Byte_Select  ( wPE25_AGU_DMEM_Byte_Select ),
    .oPE25_AGU_DMEM_Address      ( wPE25_AGU_DMEM_Address     ),  // data memory address
    .oPE25_AGU_DMEM_Write_Data   ( wPE25_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE25_DMEM_EX_Data          ( wPE25_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE26
    .oPE26_DMEM_Valid            ( wPE26_DMEM_Valid           ),
    .oPE26_AGU_DMEM_Write_Enable ( wPE26_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE26_AGU_DMEM_Read_Enable  ( wPE26_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE26_AGU_DMEM_Byte_Select  ( wPE26_AGU_DMEM_Byte_Select ),
    .oPE26_AGU_DMEM_Address      ( wPE26_AGU_DMEM_Address     ),  // data memory address
    .oPE26_AGU_DMEM_Write_Data   ( wPE26_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE26_DMEM_EX_Data          ( wPE26_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE27
    .oPE27_DMEM_Valid            ( wPE27_DMEM_Valid           ),
    .oPE27_AGU_DMEM_Write_Enable ( wPE27_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE27_AGU_DMEM_Read_Enable  ( wPE27_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE27_AGU_DMEM_Byte_Select  ( wPE27_AGU_DMEM_Byte_Select ),
    .oPE27_AGU_DMEM_Address      ( wPE27_AGU_DMEM_Address     ),  // data memory address
    .oPE27_AGU_DMEM_Write_Data   ( wPE27_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE27_DMEM_EX_Data          ( wPE27_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE28
    .oPE28_DMEM_Valid            ( wPE28_DMEM_Valid           ),
    .oPE28_AGU_DMEM_Write_Enable ( wPE28_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE28_AGU_DMEM_Read_Enable  ( wPE28_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE28_AGU_DMEM_Byte_Select  ( wPE28_AGU_DMEM_Byte_Select ),
    .oPE28_AGU_DMEM_Address      ( wPE28_AGU_DMEM_Address     ),  // data memory address
    .oPE28_AGU_DMEM_Write_Data   ( wPE28_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE28_DMEM_EX_Data          ( wPE28_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE29
    .oPE29_DMEM_Valid            ( wPE29_DMEM_Valid           ),
    .oPE29_AGU_DMEM_Write_Enable ( wPE29_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE29_AGU_DMEM_Read_Enable  ( wPE29_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE29_AGU_DMEM_Byte_Select  ( wPE29_AGU_DMEM_Byte_Select ),
    .oPE29_AGU_DMEM_Address      ( wPE29_AGU_DMEM_Address     ),  // data memory address
    .oPE29_AGU_DMEM_Write_Data   ( wPE29_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE29_DMEM_EX_Data          ( wPE29_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE30
    .oPE30_DMEM_Valid            ( wPE30_DMEM_Valid           ),
    .oPE30_AGU_DMEM_Write_Enable ( wPE30_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE30_AGU_DMEM_Read_Enable  ( wPE30_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE30_AGU_DMEM_Byte_Select  ( wPE30_AGU_DMEM_Byte_Select ),
    .oPE30_AGU_DMEM_Address      ( wPE30_AGU_DMEM_Address     ),  // data memory address
    .oPE30_AGU_DMEM_Write_Data   ( wPE30_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE30_DMEM_EX_Data          ( wPE30_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE31
    .oPE31_DMEM_Valid            ( wPE31_DMEM_Valid           ),
    .oPE31_AGU_DMEM_Write_Enable ( wPE31_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE31_AGU_DMEM_Read_Enable  ( wPE31_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE31_AGU_DMEM_Byte_Select  ( wPE31_AGU_DMEM_Byte_Select ),
    .oPE31_AGU_DMEM_Address      ( wPE31_AGU_DMEM_Address     ),  // data memory address
    .oPE31_AGU_DMEM_Write_Data   ( wPE31_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE31_DMEM_EX_Data          ( wPE31_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE32
    .oPE32_DMEM_Valid            ( wPE32_DMEM_Valid           ),
    .oPE32_AGU_DMEM_Write_Enable ( wPE32_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE32_AGU_DMEM_Read_Enable  ( wPE32_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE32_AGU_DMEM_Byte_Select  ( wPE32_AGU_DMEM_Byte_Select ),
    .oPE32_AGU_DMEM_Address      ( wPE32_AGU_DMEM_Address     ),  // data memory address
    .oPE32_AGU_DMEM_Write_Data   ( wPE32_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE32_DMEM_EX_Data          ( wPE32_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE33
    .oPE33_DMEM_Valid            ( wPE33_DMEM_Valid           ),
    .oPE33_AGU_DMEM_Write_Enable ( wPE33_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE33_AGU_DMEM_Read_Enable  ( wPE33_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE33_AGU_DMEM_Byte_Select  ( wPE33_AGU_DMEM_Byte_Select ),
    .oPE33_AGU_DMEM_Address      ( wPE33_AGU_DMEM_Address     ),  // data memory address
    .oPE33_AGU_DMEM_Write_Data   ( wPE33_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE33_DMEM_EX_Data          ( wPE33_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE34
    .oPE34_DMEM_Valid            ( wPE34_DMEM_Valid           ),
    .oPE34_AGU_DMEM_Write_Enable ( wPE34_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE34_AGU_DMEM_Read_Enable  ( wPE34_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE34_AGU_DMEM_Byte_Select  ( wPE34_AGU_DMEM_Byte_Select ),
    .oPE34_AGU_DMEM_Address      ( wPE34_AGU_DMEM_Address     ),  // data memory address
    .oPE34_AGU_DMEM_Write_Data   ( wPE34_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE34_DMEM_EX_Data          ( wPE34_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE35
    .oPE35_DMEM_Valid            ( wPE35_DMEM_Valid           ),
    .oPE35_AGU_DMEM_Write_Enable ( wPE35_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE35_AGU_DMEM_Read_Enable  ( wPE35_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE35_AGU_DMEM_Byte_Select  ( wPE35_AGU_DMEM_Byte_Select ),
    .oPE35_AGU_DMEM_Address      ( wPE35_AGU_DMEM_Address     ),  // data memory address
    .oPE35_AGU_DMEM_Write_Data   ( wPE35_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE35_DMEM_EX_Data          ( wPE35_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE36
    .oPE36_DMEM_Valid            ( wPE36_DMEM_Valid           ),
    .oPE36_AGU_DMEM_Write_Enable ( wPE36_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE36_AGU_DMEM_Read_Enable  ( wPE36_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE36_AGU_DMEM_Byte_Select  ( wPE36_AGU_DMEM_Byte_Select ),
    .oPE36_AGU_DMEM_Address      ( wPE36_AGU_DMEM_Address     ),  // data memory address
    .oPE36_AGU_DMEM_Write_Data   ( wPE36_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE36_DMEM_EX_Data          ( wPE36_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE37
    .oPE37_DMEM_Valid            ( wPE37_DMEM_Valid           ),
    .oPE37_AGU_DMEM_Write_Enable ( wPE37_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE37_AGU_DMEM_Read_Enable  ( wPE37_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE37_AGU_DMEM_Byte_Select  ( wPE37_AGU_DMEM_Byte_Select ),
    .oPE37_AGU_DMEM_Address      ( wPE37_AGU_DMEM_Address     ),  // data memory address
    .oPE37_AGU_DMEM_Write_Data   ( wPE37_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE37_DMEM_EX_Data          ( wPE37_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE38
    .oPE38_DMEM_Valid            ( wPE38_DMEM_Valid           ),
    .oPE38_AGU_DMEM_Write_Enable ( wPE38_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE38_AGU_DMEM_Read_Enable  ( wPE38_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE38_AGU_DMEM_Byte_Select  ( wPE38_AGU_DMEM_Byte_Select ),
    .oPE38_AGU_DMEM_Address      ( wPE38_AGU_DMEM_Address     ),  // data memory address
    .oPE38_AGU_DMEM_Write_Data   ( wPE38_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE38_DMEM_EX_Data          ( wPE38_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE39
    .oPE39_DMEM_Valid            ( wPE39_DMEM_Valid           ),
    .oPE39_AGU_DMEM_Write_Enable ( wPE39_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE39_AGU_DMEM_Read_Enable  ( wPE39_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE39_AGU_DMEM_Byte_Select  ( wPE39_AGU_DMEM_Byte_Select ),
    .oPE39_AGU_DMEM_Address      ( wPE39_AGU_DMEM_Address     ),  // data memory address
    .oPE39_AGU_DMEM_Write_Data   ( wPE39_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE39_DMEM_EX_Data          ( wPE39_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE40
    .oPE40_DMEM_Valid            ( wPE40_DMEM_Valid           ),
    .oPE40_AGU_DMEM_Write_Enable ( wPE40_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE40_AGU_DMEM_Read_Enable  ( wPE40_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE40_AGU_DMEM_Byte_Select  ( wPE40_AGU_DMEM_Byte_Select ),
    .oPE40_AGU_DMEM_Address      ( wPE40_AGU_DMEM_Address     ),  // data memory address
    .oPE40_AGU_DMEM_Write_Data   ( wPE40_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE40_DMEM_EX_Data          ( wPE40_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE41
    .oPE41_DMEM_Valid            ( wPE41_DMEM_Valid           ),
    .oPE41_AGU_DMEM_Write_Enable ( wPE41_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE41_AGU_DMEM_Read_Enable  ( wPE41_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE41_AGU_DMEM_Byte_Select  ( wPE41_AGU_DMEM_Byte_Select ),
    .oPE41_AGU_DMEM_Address      ( wPE41_AGU_DMEM_Address     ),  // data memory address
    .oPE41_AGU_DMEM_Write_Data   ( wPE41_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE41_DMEM_EX_Data          ( wPE41_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE42
    .oPE42_DMEM_Valid            ( wPE42_DMEM_Valid           ),
    .oPE42_AGU_DMEM_Write_Enable ( wPE42_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE42_AGU_DMEM_Read_Enable  ( wPE42_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE42_AGU_DMEM_Byte_Select  ( wPE42_AGU_DMEM_Byte_Select ),
    .oPE42_AGU_DMEM_Address      ( wPE42_AGU_DMEM_Address     ),  // data memory address
    .oPE42_AGU_DMEM_Write_Data   ( wPE42_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE42_DMEM_EX_Data          ( wPE42_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE43
    .oPE43_DMEM_Valid            ( wPE43_DMEM_Valid           ),
    .oPE43_AGU_DMEM_Write_Enable ( wPE43_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE43_AGU_DMEM_Read_Enable  ( wPE43_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE43_AGU_DMEM_Byte_Select  ( wPE43_AGU_DMEM_Byte_Select ),
    .oPE43_AGU_DMEM_Address      ( wPE43_AGU_DMEM_Address     ),  // data memory address
    .oPE43_AGU_DMEM_Write_Data   ( wPE43_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE43_DMEM_EX_Data          ( wPE43_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE44
    .oPE44_DMEM_Valid            ( wPE44_DMEM_Valid           ),
    .oPE44_AGU_DMEM_Write_Enable ( wPE44_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE44_AGU_DMEM_Read_Enable  ( wPE44_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE44_AGU_DMEM_Byte_Select  ( wPE44_AGU_DMEM_Byte_Select ),
    .oPE44_AGU_DMEM_Address      ( wPE44_AGU_DMEM_Address     ),  // data memory address
    .oPE44_AGU_DMEM_Write_Data   ( wPE44_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE44_DMEM_EX_Data          ( wPE44_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE45
    .oPE45_DMEM_Valid            ( wPE45_DMEM_Valid           ),
    .oPE45_AGU_DMEM_Write_Enable ( wPE45_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE45_AGU_DMEM_Read_Enable  ( wPE45_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE45_AGU_DMEM_Byte_Select  ( wPE45_AGU_DMEM_Byte_Select ),
    .oPE45_AGU_DMEM_Address      ( wPE45_AGU_DMEM_Address     ),  // data memory address
    .oPE45_AGU_DMEM_Write_Data   ( wPE45_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE45_DMEM_EX_Data          ( wPE45_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE46
    .oPE46_DMEM_Valid            ( wPE46_DMEM_Valid           ),
    .oPE46_AGU_DMEM_Write_Enable ( wPE46_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE46_AGU_DMEM_Read_Enable  ( wPE46_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE46_AGU_DMEM_Byte_Select  ( wPE46_AGU_DMEM_Byte_Select ),
    .oPE46_AGU_DMEM_Address      ( wPE46_AGU_DMEM_Address     ),  // data memory address
    .oPE46_AGU_DMEM_Write_Data   ( wPE46_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE46_DMEM_EX_Data          ( wPE46_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE47
    .oPE47_DMEM_Valid            ( wPE47_DMEM_Valid           ),
    .oPE47_AGU_DMEM_Write_Enable ( wPE47_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE47_AGU_DMEM_Read_Enable  ( wPE47_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE47_AGU_DMEM_Byte_Select  ( wPE47_AGU_DMEM_Byte_Select ),
    .oPE47_AGU_DMEM_Address      ( wPE47_AGU_DMEM_Address     ),  // data memory address
    .oPE47_AGU_DMEM_Write_Data   ( wPE47_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE47_DMEM_EX_Data          ( wPE47_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE48
    .oPE48_DMEM_Valid            ( wPE48_DMEM_Valid           ),
    .oPE48_AGU_DMEM_Write_Enable ( wPE48_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE48_AGU_DMEM_Read_Enable  ( wPE48_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE48_AGU_DMEM_Byte_Select  ( wPE48_AGU_DMEM_Byte_Select ),
    .oPE48_AGU_DMEM_Address      ( wPE48_AGU_DMEM_Address     ),  // data memory address
    .oPE48_AGU_DMEM_Write_Data   ( wPE48_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE48_DMEM_EX_Data          ( wPE48_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE49
    .oPE49_DMEM_Valid            ( wPE49_DMEM_Valid           ),
    .oPE49_AGU_DMEM_Write_Enable ( wPE49_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE49_AGU_DMEM_Read_Enable  ( wPE49_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE49_AGU_DMEM_Byte_Select  ( wPE49_AGU_DMEM_Byte_Select ),
    .oPE49_AGU_DMEM_Address      ( wPE49_AGU_DMEM_Address     ),  // data memory address
    .oPE49_AGU_DMEM_Write_Data   ( wPE49_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE49_DMEM_EX_Data          ( wPE49_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE50
    .oPE50_DMEM_Valid            ( wPE50_DMEM_Valid           ),
    .oPE50_AGU_DMEM_Write_Enable ( wPE50_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE50_AGU_DMEM_Read_Enable  ( wPE50_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE50_AGU_DMEM_Byte_Select  ( wPE50_AGU_DMEM_Byte_Select ),
    .oPE50_AGU_DMEM_Address      ( wPE50_AGU_DMEM_Address     ),  // data memory address
    .oPE50_AGU_DMEM_Write_Data   ( wPE50_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE50_DMEM_EX_Data          ( wPE50_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE51
    .oPE51_DMEM_Valid            ( wPE51_DMEM_Valid           ),
    .oPE51_AGU_DMEM_Write_Enable ( wPE51_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE51_AGU_DMEM_Read_Enable  ( wPE51_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE51_AGU_DMEM_Byte_Select  ( wPE51_AGU_DMEM_Byte_Select ),
    .oPE51_AGU_DMEM_Address      ( wPE51_AGU_DMEM_Address     ),  // data memory address
    .oPE51_AGU_DMEM_Write_Data   ( wPE51_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE51_DMEM_EX_Data          ( wPE51_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE52
    .oPE52_DMEM_Valid            ( wPE52_DMEM_Valid           ),
    .oPE52_AGU_DMEM_Write_Enable ( wPE52_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE52_AGU_DMEM_Read_Enable  ( wPE52_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE52_AGU_DMEM_Byte_Select  ( wPE52_AGU_DMEM_Byte_Select ),
    .oPE52_AGU_DMEM_Address      ( wPE52_AGU_DMEM_Address     ),  // data memory address
    .oPE52_AGU_DMEM_Write_Data   ( wPE52_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE52_DMEM_EX_Data          ( wPE52_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE53
    .oPE53_DMEM_Valid            ( wPE53_DMEM_Valid           ),
    .oPE53_AGU_DMEM_Write_Enable ( wPE53_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE53_AGU_DMEM_Read_Enable  ( wPE53_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE53_AGU_DMEM_Byte_Select  ( wPE53_AGU_DMEM_Byte_Select ),
    .oPE53_AGU_DMEM_Address      ( wPE53_AGU_DMEM_Address     ),  // data memory address
    .oPE53_AGU_DMEM_Write_Data   ( wPE53_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE53_DMEM_EX_Data          ( wPE53_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE54
    .oPE54_DMEM_Valid            ( wPE54_DMEM_Valid           ),
    .oPE54_AGU_DMEM_Write_Enable ( wPE54_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE54_AGU_DMEM_Read_Enable  ( wPE54_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE54_AGU_DMEM_Byte_Select  ( wPE54_AGU_DMEM_Byte_Select ),
    .oPE54_AGU_DMEM_Address      ( wPE54_AGU_DMEM_Address     ),  // data memory address
    .oPE54_AGU_DMEM_Write_Data   ( wPE54_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE54_DMEM_EX_Data          ( wPE54_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE55
    .oPE55_DMEM_Valid            ( wPE55_DMEM_Valid           ),
    .oPE55_AGU_DMEM_Write_Enable ( wPE55_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE55_AGU_DMEM_Read_Enable  ( wPE55_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE55_AGU_DMEM_Byte_Select  ( wPE55_AGU_DMEM_Byte_Select ),
    .oPE55_AGU_DMEM_Address      ( wPE55_AGU_DMEM_Address     ),  // data memory address
    .oPE55_AGU_DMEM_Write_Data   ( wPE55_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE55_DMEM_EX_Data          ( wPE55_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE56
    .oPE56_DMEM_Valid            ( wPE56_DMEM_Valid           ),
    .oPE56_AGU_DMEM_Write_Enable ( wPE56_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE56_AGU_DMEM_Read_Enable  ( wPE56_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE56_AGU_DMEM_Byte_Select  ( wPE56_AGU_DMEM_Byte_Select ),
    .oPE56_AGU_DMEM_Address      ( wPE56_AGU_DMEM_Address     ),  // data memory address
    .oPE56_AGU_DMEM_Write_Data   ( wPE56_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE56_DMEM_EX_Data          ( wPE56_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE57
    .oPE57_DMEM_Valid            ( wPE57_DMEM_Valid           ),
    .oPE57_AGU_DMEM_Write_Enable ( wPE57_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE57_AGU_DMEM_Read_Enable  ( wPE57_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE57_AGU_DMEM_Byte_Select  ( wPE57_AGU_DMEM_Byte_Select ),
    .oPE57_AGU_DMEM_Address      ( wPE57_AGU_DMEM_Address     ),  // data memory address
    .oPE57_AGU_DMEM_Write_Data   ( wPE57_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE57_DMEM_EX_Data          ( wPE57_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE58
    .oPE58_DMEM_Valid            ( wPE58_DMEM_Valid           ),
    .oPE58_AGU_DMEM_Write_Enable ( wPE58_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE58_AGU_DMEM_Read_Enable  ( wPE58_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE58_AGU_DMEM_Byte_Select  ( wPE58_AGU_DMEM_Byte_Select ),
    .oPE58_AGU_DMEM_Address      ( wPE58_AGU_DMEM_Address     ),  // data memory address
    .oPE58_AGU_DMEM_Write_Data   ( wPE58_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE58_DMEM_EX_Data          ( wPE58_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE59
    .oPE59_DMEM_Valid            ( wPE59_DMEM_Valid           ),
    .oPE59_AGU_DMEM_Write_Enable ( wPE59_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE59_AGU_DMEM_Read_Enable  ( wPE59_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE59_AGU_DMEM_Byte_Select  ( wPE59_AGU_DMEM_Byte_Select ),
    .oPE59_AGU_DMEM_Address      ( wPE59_AGU_DMEM_Address     ),  // data memory address
    .oPE59_AGU_DMEM_Write_Data   ( wPE59_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE59_DMEM_EX_Data          ( wPE59_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE60
    .oPE60_DMEM_Valid            ( wPE60_DMEM_Valid           ),
    .oPE60_AGU_DMEM_Write_Enable ( wPE60_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE60_AGU_DMEM_Read_Enable  ( wPE60_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE60_AGU_DMEM_Byte_Select  ( wPE60_AGU_DMEM_Byte_Select ),
    .oPE60_AGU_DMEM_Address      ( wPE60_AGU_DMEM_Address     ),  // data memory address
    .oPE60_AGU_DMEM_Write_Data   ( wPE60_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE60_DMEM_EX_Data          ( wPE60_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE61
    .oPE61_DMEM_Valid            ( wPE61_DMEM_Valid           ),
    .oPE61_AGU_DMEM_Write_Enable ( wPE61_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE61_AGU_DMEM_Read_Enable  ( wPE61_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE61_AGU_DMEM_Byte_Select  ( wPE61_AGU_DMEM_Byte_Select ),
    .oPE61_AGU_DMEM_Address      ( wPE61_AGU_DMEM_Address     ),  // data memory address
    .oPE61_AGU_DMEM_Write_Data   ( wPE61_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE61_DMEM_EX_Data          ( wPE61_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE62
    .oPE62_DMEM_Valid            ( wPE62_DMEM_Valid           ),
    .oPE62_AGU_DMEM_Write_Enable ( wPE62_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE62_AGU_DMEM_Read_Enable  ( wPE62_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE62_AGU_DMEM_Byte_Select  ( wPE62_AGU_DMEM_Byte_Select ),
    .oPE62_AGU_DMEM_Address      ( wPE62_AGU_DMEM_Address     ),  // data memory address
    .oPE62_AGU_DMEM_Write_Data   ( wPE62_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE62_DMEM_EX_Data          ( wPE62_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE63
    .oPE63_DMEM_Valid            ( wPE63_DMEM_Valid           ),
    .oPE63_AGU_DMEM_Write_Enable ( wPE63_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE63_AGU_DMEM_Read_Enable  ( wPE63_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE63_AGU_DMEM_Byte_Select  ( wPE63_AGU_DMEM_Byte_Select ),
    .oPE63_AGU_DMEM_Address      ( wPE63_AGU_DMEM_Address     ),  // data memory address
    .oPE63_AGU_DMEM_Write_Data   ( wPE63_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE63_DMEM_EX_Data          ( wPE63_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE64
    .oPE64_DMEM_Valid            ( wPE64_DMEM_Valid           ),
    .oPE64_AGU_DMEM_Write_Enable ( wPE64_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE64_AGU_DMEM_Read_Enable  ( wPE64_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE64_AGU_DMEM_Byte_Select  ( wPE64_AGU_DMEM_Byte_Select ),
    .oPE64_AGU_DMEM_Address      ( wPE64_AGU_DMEM_Address     ),  // data memory address
    .oPE64_AGU_DMEM_Write_Data   ( wPE64_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE64_DMEM_EX_Data          ( wPE64_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE65
    .oPE65_DMEM_Valid            ( wPE65_DMEM_Valid           ),
    .oPE65_AGU_DMEM_Write_Enable ( wPE65_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE65_AGU_DMEM_Read_Enable  ( wPE65_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE65_AGU_DMEM_Byte_Select  ( wPE65_AGU_DMEM_Byte_Select ),
    .oPE65_AGU_DMEM_Address      ( wPE65_AGU_DMEM_Address     ),  // data memory address
    .oPE65_AGU_DMEM_Write_Data   ( wPE65_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE65_DMEM_EX_Data          ( wPE65_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE66
    .oPE66_DMEM_Valid            ( wPE66_DMEM_Valid           ),
    .oPE66_AGU_DMEM_Write_Enable ( wPE66_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE66_AGU_DMEM_Read_Enable  ( wPE66_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE66_AGU_DMEM_Byte_Select  ( wPE66_AGU_DMEM_Byte_Select ),
    .oPE66_AGU_DMEM_Address      ( wPE66_AGU_DMEM_Address     ),  // data memory address
    .oPE66_AGU_DMEM_Write_Data   ( wPE66_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE66_DMEM_EX_Data          ( wPE66_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE67
    .oPE67_DMEM_Valid            ( wPE67_DMEM_Valid           ),
    .oPE67_AGU_DMEM_Write_Enable ( wPE67_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE67_AGU_DMEM_Read_Enable  ( wPE67_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE67_AGU_DMEM_Byte_Select  ( wPE67_AGU_DMEM_Byte_Select ),
    .oPE67_AGU_DMEM_Address      ( wPE67_AGU_DMEM_Address     ),  // data memory address
    .oPE67_AGU_DMEM_Write_Data   ( wPE67_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE67_DMEM_EX_Data          ( wPE67_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE68
    .oPE68_DMEM_Valid            ( wPE68_DMEM_Valid           ),
    .oPE68_AGU_DMEM_Write_Enable ( wPE68_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE68_AGU_DMEM_Read_Enable  ( wPE68_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE68_AGU_DMEM_Byte_Select  ( wPE68_AGU_DMEM_Byte_Select ),
    .oPE68_AGU_DMEM_Address      ( wPE68_AGU_DMEM_Address     ),  // data memory address
    .oPE68_AGU_DMEM_Write_Data   ( wPE68_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE68_DMEM_EX_Data          ( wPE68_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE69
    .oPE69_DMEM_Valid            ( wPE69_DMEM_Valid           ),
    .oPE69_AGU_DMEM_Write_Enable ( wPE69_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE69_AGU_DMEM_Read_Enable  ( wPE69_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE69_AGU_DMEM_Byte_Select  ( wPE69_AGU_DMEM_Byte_Select ),
    .oPE69_AGU_DMEM_Address      ( wPE69_AGU_DMEM_Address     ),  // data memory address
    .oPE69_AGU_DMEM_Write_Data   ( wPE69_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE69_DMEM_EX_Data          ( wPE69_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE70
    .oPE70_DMEM_Valid            ( wPE70_DMEM_Valid           ),
    .oPE70_AGU_DMEM_Write_Enable ( wPE70_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE70_AGU_DMEM_Read_Enable  ( wPE70_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE70_AGU_DMEM_Byte_Select  ( wPE70_AGU_DMEM_Byte_Select ),
    .oPE70_AGU_DMEM_Address      ( wPE70_AGU_DMEM_Address     ),  // data memory address
    .oPE70_AGU_DMEM_Write_Data   ( wPE70_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE70_DMEM_EX_Data          ( wPE70_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE71
    .oPE71_DMEM_Valid            ( wPE71_DMEM_Valid           ),
    .oPE71_AGU_DMEM_Write_Enable ( wPE71_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE71_AGU_DMEM_Read_Enable  ( wPE71_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE71_AGU_DMEM_Byte_Select  ( wPE71_AGU_DMEM_Byte_Select ),
    .oPE71_AGU_DMEM_Address      ( wPE71_AGU_DMEM_Address     ),  // data memory address
    .oPE71_AGU_DMEM_Write_Data   ( wPE71_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE71_DMEM_EX_Data          ( wPE71_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE72
    .oPE72_DMEM_Valid            ( wPE72_DMEM_Valid           ),
    .oPE72_AGU_DMEM_Write_Enable ( wPE72_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE72_AGU_DMEM_Read_Enable  ( wPE72_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE72_AGU_DMEM_Byte_Select  ( wPE72_AGU_DMEM_Byte_Select ),
    .oPE72_AGU_DMEM_Address      ( wPE72_AGU_DMEM_Address     ),  // data memory address
    .oPE72_AGU_DMEM_Write_Data   ( wPE72_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE72_DMEM_EX_Data          ( wPE72_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE73
    .oPE73_DMEM_Valid            ( wPE73_DMEM_Valid           ),
    .oPE73_AGU_DMEM_Write_Enable ( wPE73_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE73_AGU_DMEM_Read_Enable  ( wPE73_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE73_AGU_DMEM_Byte_Select  ( wPE73_AGU_DMEM_Byte_Select ),
    .oPE73_AGU_DMEM_Address      ( wPE73_AGU_DMEM_Address     ),  // data memory address
    .oPE73_AGU_DMEM_Write_Data   ( wPE73_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE73_DMEM_EX_Data          ( wPE73_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE74
    .oPE74_DMEM_Valid            ( wPE74_DMEM_Valid           ),
    .oPE74_AGU_DMEM_Write_Enable ( wPE74_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE74_AGU_DMEM_Read_Enable  ( wPE74_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE74_AGU_DMEM_Byte_Select  ( wPE74_AGU_DMEM_Byte_Select ),
    .oPE74_AGU_DMEM_Address      ( wPE74_AGU_DMEM_Address     ),  // data memory address
    .oPE74_AGU_DMEM_Write_Data   ( wPE74_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE74_DMEM_EX_Data          ( wPE74_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE75
    .oPE75_DMEM_Valid            ( wPE75_DMEM_Valid           ),
    .oPE75_AGU_DMEM_Write_Enable ( wPE75_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE75_AGU_DMEM_Read_Enable  ( wPE75_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE75_AGU_DMEM_Byte_Select  ( wPE75_AGU_DMEM_Byte_Select ),
    .oPE75_AGU_DMEM_Address      ( wPE75_AGU_DMEM_Address     ),  // data memory address
    .oPE75_AGU_DMEM_Write_Data   ( wPE75_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE75_DMEM_EX_Data          ( wPE75_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE76
    .oPE76_DMEM_Valid            ( wPE76_DMEM_Valid           ),
    .oPE76_AGU_DMEM_Write_Enable ( wPE76_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE76_AGU_DMEM_Read_Enable  ( wPE76_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE76_AGU_DMEM_Byte_Select  ( wPE76_AGU_DMEM_Byte_Select ),
    .oPE76_AGU_DMEM_Address      ( wPE76_AGU_DMEM_Address     ),  // data memory address
    .oPE76_AGU_DMEM_Write_Data   ( wPE76_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE76_DMEM_EX_Data          ( wPE76_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE77
    .oPE77_DMEM_Valid            ( wPE77_DMEM_Valid           ),
    .oPE77_AGU_DMEM_Write_Enable ( wPE77_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE77_AGU_DMEM_Read_Enable  ( wPE77_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE77_AGU_DMEM_Byte_Select  ( wPE77_AGU_DMEM_Byte_Select ),
    .oPE77_AGU_DMEM_Address      ( wPE77_AGU_DMEM_Address     ),  // data memory address
    .oPE77_AGU_DMEM_Write_Data   ( wPE77_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE77_DMEM_EX_Data          ( wPE77_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE78
    .oPE78_DMEM_Valid            ( wPE78_DMEM_Valid           ),
    .oPE78_AGU_DMEM_Write_Enable ( wPE78_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE78_AGU_DMEM_Read_Enable  ( wPE78_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE78_AGU_DMEM_Byte_Select  ( wPE78_AGU_DMEM_Byte_Select ),
    .oPE78_AGU_DMEM_Address      ( wPE78_AGU_DMEM_Address     ),  // data memory address
    .oPE78_AGU_DMEM_Write_Data   ( wPE78_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE78_DMEM_EX_Data          ( wPE78_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE79
    .oPE79_DMEM_Valid            ( wPE79_DMEM_Valid           ),
    .oPE79_AGU_DMEM_Write_Enable ( wPE79_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE79_AGU_DMEM_Read_Enable  ( wPE79_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE79_AGU_DMEM_Byte_Select  ( wPE79_AGU_DMEM_Byte_Select ),
    .oPE79_AGU_DMEM_Address      ( wPE79_AGU_DMEM_Address     ),  // data memory address
    .oPE79_AGU_DMEM_Write_Data   ( wPE79_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE79_DMEM_EX_Data          ( wPE79_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE80
    .oPE80_DMEM_Valid            ( wPE80_DMEM_Valid           ),
    .oPE80_AGU_DMEM_Write_Enable ( wPE80_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE80_AGU_DMEM_Read_Enable  ( wPE80_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE80_AGU_DMEM_Byte_Select  ( wPE80_AGU_DMEM_Byte_Select ),
    .oPE80_AGU_DMEM_Address      ( wPE80_AGU_DMEM_Address     ),  // data memory address
    .oPE80_AGU_DMEM_Write_Data   ( wPE80_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE80_DMEM_EX_Data          ( wPE80_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE81
    .oPE81_DMEM_Valid            ( wPE81_DMEM_Valid           ),
    .oPE81_AGU_DMEM_Write_Enable ( wPE81_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE81_AGU_DMEM_Read_Enable  ( wPE81_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE81_AGU_DMEM_Byte_Select  ( wPE81_AGU_DMEM_Byte_Select ),
    .oPE81_AGU_DMEM_Address      ( wPE81_AGU_DMEM_Address     ),  // data memory address
    .oPE81_AGU_DMEM_Write_Data   ( wPE81_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE81_DMEM_EX_Data          ( wPE81_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE82
    .oPE82_DMEM_Valid            ( wPE82_DMEM_Valid           ),
    .oPE82_AGU_DMEM_Write_Enable ( wPE82_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE82_AGU_DMEM_Read_Enable  ( wPE82_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE82_AGU_DMEM_Byte_Select  ( wPE82_AGU_DMEM_Byte_Select ),
    .oPE82_AGU_DMEM_Address      ( wPE82_AGU_DMEM_Address     ),  // data memory address
    .oPE82_AGU_DMEM_Write_Data   ( wPE82_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE82_DMEM_EX_Data          ( wPE82_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE83
    .oPE83_DMEM_Valid            ( wPE83_DMEM_Valid           ),
    .oPE83_AGU_DMEM_Write_Enable ( wPE83_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE83_AGU_DMEM_Read_Enable  ( wPE83_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE83_AGU_DMEM_Byte_Select  ( wPE83_AGU_DMEM_Byte_Select ),
    .oPE83_AGU_DMEM_Address      ( wPE83_AGU_DMEM_Address     ),  // data memory address
    .oPE83_AGU_DMEM_Write_Data   ( wPE83_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE83_DMEM_EX_Data          ( wPE83_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE84
    .oPE84_DMEM_Valid            ( wPE84_DMEM_Valid           ),
    .oPE84_AGU_DMEM_Write_Enable ( wPE84_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE84_AGU_DMEM_Read_Enable  ( wPE84_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE84_AGU_DMEM_Byte_Select  ( wPE84_AGU_DMEM_Byte_Select ),
    .oPE84_AGU_DMEM_Address      ( wPE84_AGU_DMEM_Address     ),  // data memory address
    .oPE84_AGU_DMEM_Write_Data   ( wPE84_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE84_DMEM_EX_Data          ( wPE84_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE85
    .oPE85_DMEM_Valid            ( wPE85_DMEM_Valid           ),
    .oPE85_AGU_DMEM_Write_Enable ( wPE85_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE85_AGU_DMEM_Read_Enable  ( wPE85_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE85_AGU_DMEM_Byte_Select  ( wPE85_AGU_DMEM_Byte_Select ),
    .oPE85_AGU_DMEM_Address      ( wPE85_AGU_DMEM_Address     ),  // data memory address
    .oPE85_AGU_DMEM_Write_Data   ( wPE85_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE85_DMEM_EX_Data          ( wPE85_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE86
    .oPE86_DMEM_Valid            ( wPE86_DMEM_Valid           ),
    .oPE86_AGU_DMEM_Write_Enable ( wPE86_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE86_AGU_DMEM_Read_Enable  ( wPE86_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE86_AGU_DMEM_Byte_Select  ( wPE86_AGU_DMEM_Byte_Select ),
    .oPE86_AGU_DMEM_Address      ( wPE86_AGU_DMEM_Address     ),  // data memory address
    .oPE86_AGU_DMEM_Write_Data   ( wPE86_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE86_DMEM_EX_Data          ( wPE86_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE87
    .oPE87_DMEM_Valid            ( wPE87_DMEM_Valid           ),
    .oPE87_AGU_DMEM_Write_Enable ( wPE87_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE87_AGU_DMEM_Read_Enable  ( wPE87_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE87_AGU_DMEM_Byte_Select  ( wPE87_AGU_DMEM_Byte_Select ),
    .oPE87_AGU_DMEM_Address      ( wPE87_AGU_DMEM_Address     ),  // data memory address
    .oPE87_AGU_DMEM_Write_Data   ( wPE87_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE87_DMEM_EX_Data          ( wPE87_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE88
    .oPE88_DMEM_Valid            ( wPE88_DMEM_Valid           ),
    .oPE88_AGU_DMEM_Write_Enable ( wPE88_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE88_AGU_DMEM_Read_Enable  ( wPE88_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE88_AGU_DMEM_Byte_Select  ( wPE88_AGU_DMEM_Byte_Select ),
    .oPE88_AGU_DMEM_Address      ( wPE88_AGU_DMEM_Address     ),  // data memory address
    .oPE88_AGU_DMEM_Write_Data   ( wPE88_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE88_DMEM_EX_Data          ( wPE88_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE89
    .oPE89_DMEM_Valid            ( wPE89_DMEM_Valid           ),
    .oPE89_AGU_DMEM_Write_Enable ( wPE89_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE89_AGU_DMEM_Read_Enable  ( wPE89_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE89_AGU_DMEM_Byte_Select  ( wPE89_AGU_DMEM_Byte_Select ),
    .oPE89_AGU_DMEM_Address      ( wPE89_AGU_DMEM_Address     ),  // data memory address
    .oPE89_AGU_DMEM_Write_Data   ( wPE89_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE89_DMEM_EX_Data          ( wPE89_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE90
    .oPE90_DMEM_Valid            ( wPE90_DMEM_Valid           ),
    .oPE90_AGU_DMEM_Write_Enable ( wPE90_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE90_AGU_DMEM_Read_Enable  ( wPE90_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE90_AGU_DMEM_Byte_Select  ( wPE90_AGU_DMEM_Byte_Select ),
    .oPE90_AGU_DMEM_Address      ( wPE90_AGU_DMEM_Address     ),  // data memory address
    .oPE90_AGU_DMEM_Write_Data   ( wPE90_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE90_DMEM_EX_Data          ( wPE90_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE91
    .oPE91_DMEM_Valid            ( wPE91_DMEM_Valid           ),
    .oPE91_AGU_DMEM_Write_Enable ( wPE91_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE91_AGU_DMEM_Read_Enable  ( wPE91_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE91_AGU_DMEM_Byte_Select  ( wPE91_AGU_DMEM_Byte_Select ),
    .oPE91_AGU_DMEM_Address      ( wPE91_AGU_DMEM_Address     ),  // data memory address
    .oPE91_AGU_DMEM_Write_Data   ( wPE91_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE91_DMEM_EX_Data          ( wPE91_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE92
    .oPE92_DMEM_Valid            ( wPE92_DMEM_Valid           ),
    .oPE92_AGU_DMEM_Write_Enable ( wPE92_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE92_AGU_DMEM_Read_Enable  ( wPE92_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE92_AGU_DMEM_Byte_Select  ( wPE92_AGU_DMEM_Byte_Select ),
    .oPE92_AGU_DMEM_Address      ( wPE92_AGU_DMEM_Address     ),  // data memory address
    .oPE92_AGU_DMEM_Write_Data   ( wPE92_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE92_DMEM_EX_Data          ( wPE92_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE93
    .oPE93_DMEM_Valid            ( wPE93_DMEM_Valid           ),
    .oPE93_AGU_DMEM_Write_Enable ( wPE93_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE93_AGU_DMEM_Read_Enable  ( wPE93_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE93_AGU_DMEM_Byte_Select  ( wPE93_AGU_DMEM_Byte_Select ),
    .oPE93_AGU_DMEM_Address      ( wPE93_AGU_DMEM_Address     ),  // data memory address
    .oPE93_AGU_DMEM_Write_Data   ( wPE93_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE93_DMEM_EX_Data          ( wPE93_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE94
    .oPE94_DMEM_Valid            ( wPE94_DMEM_Valid           ),
    .oPE94_AGU_DMEM_Write_Enable ( wPE94_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE94_AGU_DMEM_Read_Enable  ( wPE94_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE94_AGU_DMEM_Byte_Select  ( wPE94_AGU_DMEM_Byte_Select ),
    .oPE94_AGU_DMEM_Address      ( wPE94_AGU_DMEM_Address     ),  // data memory address
    .oPE94_AGU_DMEM_Write_Data   ( wPE94_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE94_DMEM_EX_Data          ( wPE94_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE95
    .oPE95_DMEM_Valid            ( wPE95_DMEM_Valid           ),
    .oPE95_AGU_DMEM_Write_Enable ( wPE95_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE95_AGU_DMEM_Read_Enable  ( wPE95_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE95_AGU_DMEM_Byte_Select  ( wPE95_AGU_DMEM_Byte_Select ),
    .oPE95_AGU_DMEM_Address      ( wPE95_AGU_DMEM_Address     ),  // data memory address
    .oPE95_AGU_DMEM_Write_Data   ( wPE95_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE95_DMEM_EX_Data          ( wPE95_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE96
    .oPE96_DMEM_Valid            ( wPE96_DMEM_Valid           ),
    .oPE96_AGU_DMEM_Write_Enable ( wPE96_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE96_AGU_DMEM_Read_Enable  ( wPE96_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE96_AGU_DMEM_Byte_Select  ( wPE96_AGU_DMEM_Byte_Select ),
    .oPE96_AGU_DMEM_Address      ( wPE96_AGU_DMEM_Address     ),  // data memory address
    .oPE96_AGU_DMEM_Write_Data   ( wPE96_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE96_DMEM_EX_Data          ( wPE96_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE97
    .oPE97_DMEM_Valid            ( wPE97_DMEM_Valid           ),
    .oPE97_AGU_DMEM_Write_Enable ( wPE97_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE97_AGU_DMEM_Read_Enable  ( wPE97_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE97_AGU_DMEM_Byte_Select  ( wPE97_AGU_DMEM_Byte_Select ),
    .oPE97_AGU_DMEM_Address      ( wPE97_AGU_DMEM_Address     ),  // data memory address
    .oPE97_AGU_DMEM_Write_Data   ( wPE97_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE97_DMEM_EX_Data          ( wPE97_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE98
    .oPE98_DMEM_Valid            ( wPE98_DMEM_Valid           ),
    .oPE98_AGU_DMEM_Write_Enable ( wPE98_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE98_AGU_DMEM_Read_Enable  ( wPE98_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE98_AGU_DMEM_Byte_Select  ( wPE98_AGU_DMEM_Byte_Select ),
    .oPE98_AGU_DMEM_Address      ( wPE98_AGU_DMEM_Address     ),  // data memory address
    .oPE98_AGU_DMEM_Write_Data   ( wPE98_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE98_DMEM_EX_Data          ( wPE98_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE99
    .oPE99_DMEM_Valid            ( wPE99_DMEM_Valid           ),
    .oPE99_AGU_DMEM_Write_Enable ( wPE99_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE99_AGU_DMEM_Read_Enable  ( wPE99_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE99_AGU_DMEM_Byte_Select  ( wPE99_AGU_DMEM_Byte_Select ),
    .oPE99_AGU_DMEM_Address      ( wPE99_AGU_DMEM_Address     ),  // data memory address
    .oPE99_AGU_DMEM_Write_Data   ( wPE99_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE99_DMEM_EX_Data          ( wPE99_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE100
    .oPE100_DMEM_Valid            ( wPE100_DMEM_Valid           ),
    .oPE100_AGU_DMEM_Write_Enable ( wPE100_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE100_AGU_DMEM_Read_Enable  ( wPE100_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE100_AGU_DMEM_Byte_Select  ( wPE100_AGU_DMEM_Byte_Select ),
    .oPE100_AGU_DMEM_Address      ( wPE100_AGU_DMEM_Address     ),  // data memory address
    .oPE100_AGU_DMEM_Write_Data   ( wPE100_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE100_DMEM_EX_Data          ( wPE100_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE101
    .oPE101_DMEM_Valid            ( wPE101_DMEM_Valid           ),
    .oPE101_AGU_DMEM_Write_Enable ( wPE101_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE101_AGU_DMEM_Read_Enable  ( wPE101_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE101_AGU_DMEM_Byte_Select  ( wPE101_AGU_DMEM_Byte_Select ),
    .oPE101_AGU_DMEM_Address      ( wPE101_AGU_DMEM_Address     ),  // data memory address
    .oPE101_AGU_DMEM_Write_Data   ( wPE101_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE101_DMEM_EX_Data          ( wPE101_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE102
    .oPE102_DMEM_Valid            ( wPE102_DMEM_Valid           ),
    .oPE102_AGU_DMEM_Write_Enable ( wPE102_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE102_AGU_DMEM_Read_Enable  ( wPE102_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE102_AGU_DMEM_Byte_Select  ( wPE102_AGU_DMEM_Byte_Select ),
    .oPE102_AGU_DMEM_Address      ( wPE102_AGU_DMEM_Address     ),  // data memory address
    .oPE102_AGU_DMEM_Write_Data   ( wPE102_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE102_DMEM_EX_Data          ( wPE102_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE103
    .oPE103_DMEM_Valid            ( wPE103_DMEM_Valid           ),
    .oPE103_AGU_DMEM_Write_Enable ( wPE103_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE103_AGU_DMEM_Read_Enable  ( wPE103_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE103_AGU_DMEM_Byte_Select  ( wPE103_AGU_DMEM_Byte_Select ),
    .oPE103_AGU_DMEM_Address      ( wPE103_AGU_DMEM_Address     ),  // data memory address
    .oPE103_AGU_DMEM_Write_Data   ( wPE103_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE103_DMEM_EX_Data          ( wPE103_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE104
    .oPE104_DMEM_Valid            ( wPE104_DMEM_Valid           ),
    .oPE104_AGU_DMEM_Write_Enable ( wPE104_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE104_AGU_DMEM_Read_Enable  ( wPE104_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE104_AGU_DMEM_Byte_Select  ( wPE104_AGU_DMEM_Byte_Select ),
    .oPE104_AGU_DMEM_Address      ( wPE104_AGU_DMEM_Address     ),  // data memory address
    .oPE104_AGU_DMEM_Write_Data   ( wPE104_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE104_DMEM_EX_Data          ( wPE104_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE105
    .oPE105_DMEM_Valid            ( wPE105_DMEM_Valid           ),
    .oPE105_AGU_DMEM_Write_Enable ( wPE105_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE105_AGU_DMEM_Read_Enable  ( wPE105_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE105_AGU_DMEM_Byte_Select  ( wPE105_AGU_DMEM_Byte_Select ),
    .oPE105_AGU_DMEM_Address      ( wPE105_AGU_DMEM_Address     ),  // data memory address
    .oPE105_AGU_DMEM_Write_Data   ( wPE105_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE105_DMEM_EX_Data          ( wPE105_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE106
    .oPE106_DMEM_Valid            ( wPE106_DMEM_Valid           ),
    .oPE106_AGU_DMEM_Write_Enable ( wPE106_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE106_AGU_DMEM_Read_Enable  ( wPE106_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE106_AGU_DMEM_Byte_Select  ( wPE106_AGU_DMEM_Byte_Select ),
    .oPE106_AGU_DMEM_Address      ( wPE106_AGU_DMEM_Address     ),  // data memory address
    .oPE106_AGU_DMEM_Write_Data   ( wPE106_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE106_DMEM_EX_Data          ( wPE106_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE107
    .oPE107_DMEM_Valid            ( wPE107_DMEM_Valid           ),
    .oPE107_AGU_DMEM_Write_Enable ( wPE107_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE107_AGU_DMEM_Read_Enable  ( wPE107_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE107_AGU_DMEM_Byte_Select  ( wPE107_AGU_DMEM_Byte_Select ),
    .oPE107_AGU_DMEM_Address      ( wPE107_AGU_DMEM_Address     ),  // data memory address
    .oPE107_AGU_DMEM_Write_Data   ( wPE107_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE107_DMEM_EX_Data          ( wPE107_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE108
    .oPE108_DMEM_Valid            ( wPE108_DMEM_Valid           ),
    .oPE108_AGU_DMEM_Write_Enable ( wPE108_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE108_AGU_DMEM_Read_Enable  ( wPE108_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE108_AGU_DMEM_Byte_Select  ( wPE108_AGU_DMEM_Byte_Select ),
    .oPE108_AGU_DMEM_Address      ( wPE108_AGU_DMEM_Address     ),  // data memory address
    .oPE108_AGU_DMEM_Write_Data   ( wPE108_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE108_DMEM_EX_Data          ( wPE108_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE109
    .oPE109_DMEM_Valid            ( wPE109_DMEM_Valid           ),
    .oPE109_AGU_DMEM_Write_Enable ( wPE109_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE109_AGU_DMEM_Read_Enable  ( wPE109_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE109_AGU_DMEM_Byte_Select  ( wPE109_AGU_DMEM_Byte_Select ),
    .oPE109_AGU_DMEM_Address      ( wPE109_AGU_DMEM_Address     ),  // data memory address
    .oPE109_AGU_DMEM_Write_Data   ( wPE109_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE109_DMEM_EX_Data          ( wPE109_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE110
    .oPE110_DMEM_Valid            ( wPE110_DMEM_Valid           ),
    .oPE110_AGU_DMEM_Write_Enable ( wPE110_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE110_AGU_DMEM_Read_Enable  ( wPE110_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE110_AGU_DMEM_Byte_Select  ( wPE110_AGU_DMEM_Byte_Select ),
    .oPE110_AGU_DMEM_Address      ( wPE110_AGU_DMEM_Address     ),  // data memory address
    .oPE110_AGU_DMEM_Write_Data   ( wPE110_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE110_DMEM_EX_Data          ( wPE110_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE111
    .oPE111_DMEM_Valid            ( wPE111_DMEM_Valid           ),
    .oPE111_AGU_DMEM_Write_Enable ( wPE111_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE111_AGU_DMEM_Read_Enable  ( wPE111_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE111_AGU_DMEM_Byte_Select  ( wPE111_AGU_DMEM_Byte_Select ),
    .oPE111_AGU_DMEM_Address      ( wPE111_AGU_DMEM_Address     ),  // data memory address
    .oPE111_AGU_DMEM_Write_Data   ( wPE111_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE111_DMEM_EX_Data          ( wPE111_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE112
    .oPE112_DMEM_Valid            ( wPE112_DMEM_Valid           ),
    .oPE112_AGU_DMEM_Write_Enable ( wPE112_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE112_AGU_DMEM_Read_Enable  ( wPE112_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE112_AGU_DMEM_Byte_Select  ( wPE112_AGU_DMEM_Byte_Select ),
    .oPE112_AGU_DMEM_Address      ( wPE112_AGU_DMEM_Address     ),  // data memory address
    .oPE112_AGU_DMEM_Write_Data   ( wPE112_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE112_DMEM_EX_Data          ( wPE112_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE113
    .oPE113_DMEM_Valid            ( wPE113_DMEM_Valid           ),
    .oPE113_AGU_DMEM_Write_Enable ( wPE113_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE113_AGU_DMEM_Read_Enable  ( wPE113_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE113_AGU_DMEM_Byte_Select  ( wPE113_AGU_DMEM_Byte_Select ),
    .oPE113_AGU_DMEM_Address      ( wPE113_AGU_DMEM_Address     ),  // data memory address
    .oPE113_AGU_DMEM_Write_Data   ( wPE113_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE113_DMEM_EX_Data          ( wPE113_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE114
    .oPE114_DMEM_Valid            ( wPE114_DMEM_Valid           ),
    .oPE114_AGU_DMEM_Write_Enable ( wPE114_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE114_AGU_DMEM_Read_Enable  ( wPE114_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE114_AGU_DMEM_Byte_Select  ( wPE114_AGU_DMEM_Byte_Select ),
    .oPE114_AGU_DMEM_Address      ( wPE114_AGU_DMEM_Address     ),  // data memory address
    .oPE114_AGU_DMEM_Write_Data   ( wPE114_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE114_DMEM_EX_Data          ( wPE114_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE115
    .oPE115_DMEM_Valid            ( wPE115_DMEM_Valid           ),
    .oPE115_AGU_DMEM_Write_Enable ( wPE115_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE115_AGU_DMEM_Read_Enable  ( wPE115_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE115_AGU_DMEM_Byte_Select  ( wPE115_AGU_DMEM_Byte_Select ),
    .oPE115_AGU_DMEM_Address      ( wPE115_AGU_DMEM_Address     ),  // data memory address
    .oPE115_AGU_DMEM_Write_Data   ( wPE115_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE115_DMEM_EX_Data          ( wPE115_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE116
    .oPE116_DMEM_Valid            ( wPE116_DMEM_Valid           ),
    .oPE116_AGU_DMEM_Write_Enable ( wPE116_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE116_AGU_DMEM_Read_Enable  ( wPE116_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE116_AGU_DMEM_Byte_Select  ( wPE116_AGU_DMEM_Byte_Select ),
    .oPE116_AGU_DMEM_Address      ( wPE116_AGU_DMEM_Address     ),  // data memory address
    .oPE116_AGU_DMEM_Write_Data   ( wPE116_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE116_DMEM_EX_Data          ( wPE116_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE117
    .oPE117_DMEM_Valid            ( wPE117_DMEM_Valid           ),
    .oPE117_AGU_DMEM_Write_Enable ( wPE117_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE117_AGU_DMEM_Read_Enable  ( wPE117_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE117_AGU_DMEM_Byte_Select  ( wPE117_AGU_DMEM_Byte_Select ),
    .oPE117_AGU_DMEM_Address      ( wPE117_AGU_DMEM_Address     ),  // data memory address
    .oPE117_AGU_DMEM_Write_Data   ( wPE117_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE117_DMEM_EX_Data          ( wPE117_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE118
    .oPE118_DMEM_Valid            ( wPE118_DMEM_Valid           ),
    .oPE118_AGU_DMEM_Write_Enable ( wPE118_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE118_AGU_DMEM_Read_Enable  ( wPE118_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE118_AGU_DMEM_Byte_Select  ( wPE118_AGU_DMEM_Byte_Select ),
    .oPE118_AGU_DMEM_Address      ( wPE118_AGU_DMEM_Address     ),  // data memory address
    .oPE118_AGU_DMEM_Write_Data   ( wPE118_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE118_DMEM_EX_Data          ( wPE118_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE119
    .oPE119_DMEM_Valid            ( wPE119_DMEM_Valid           ),
    .oPE119_AGU_DMEM_Write_Enable ( wPE119_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE119_AGU_DMEM_Read_Enable  ( wPE119_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE119_AGU_DMEM_Byte_Select  ( wPE119_AGU_DMEM_Byte_Select ),
    .oPE119_AGU_DMEM_Address      ( wPE119_AGU_DMEM_Address     ),  // data memory address
    .oPE119_AGU_DMEM_Write_Data   ( wPE119_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE119_DMEM_EX_Data          ( wPE119_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE120
    .oPE120_DMEM_Valid            ( wPE120_DMEM_Valid           ),
    .oPE120_AGU_DMEM_Write_Enable ( wPE120_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE120_AGU_DMEM_Read_Enable  ( wPE120_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE120_AGU_DMEM_Byte_Select  ( wPE120_AGU_DMEM_Byte_Select ),
    .oPE120_AGU_DMEM_Address      ( wPE120_AGU_DMEM_Address     ),  // data memory address
    .oPE120_AGU_DMEM_Write_Data   ( wPE120_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE120_DMEM_EX_Data          ( wPE120_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE121
    .oPE121_DMEM_Valid            ( wPE121_DMEM_Valid           ),
    .oPE121_AGU_DMEM_Write_Enable ( wPE121_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE121_AGU_DMEM_Read_Enable  ( wPE121_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE121_AGU_DMEM_Byte_Select  ( wPE121_AGU_DMEM_Byte_Select ),
    .oPE121_AGU_DMEM_Address      ( wPE121_AGU_DMEM_Address     ),  // data memory address
    .oPE121_AGU_DMEM_Write_Data   ( wPE121_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE121_DMEM_EX_Data          ( wPE121_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE122
    .oPE122_DMEM_Valid            ( wPE122_DMEM_Valid           ),
    .oPE122_AGU_DMEM_Write_Enable ( wPE122_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE122_AGU_DMEM_Read_Enable  ( wPE122_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE122_AGU_DMEM_Byte_Select  ( wPE122_AGU_DMEM_Byte_Select ),
    .oPE122_AGU_DMEM_Address      ( wPE122_AGU_DMEM_Address     ),  // data memory address
    .oPE122_AGU_DMEM_Write_Data   ( wPE122_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE122_DMEM_EX_Data          ( wPE122_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE123
    .oPE123_DMEM_Valid            ( wPE123_DMEM_Valid           ),
    .oPE123_AGU_DMEM_Write_Enable ( wPE123_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE123_AGU_DMEM_Read_Enable  ( wPE123_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE123_AGU_DMEM_Byte_Select  ( wPE123_AGU_DMEM_Byte_Select ),
    .oPE123_AGU_DMEM_Address      ( wPE123_AGU_DMEM_Address     ),  // data memory address
    .oPE123_AGU_DMEM_Write_Data   ( wPE123_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE123_DMEM_EX_Data          ( wPE123_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE124
    .oPE124_DMEM_Valid            ( wPE124_DMEM_Valid           ),
    .oPE124_AGU_DMEM_Write_Enable ( wPE124_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE124_AGU_DMEM_Read_Enable  ( wPE124_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE124_AGU_DMEM_Byte_Select  ( wPE124_AGU_DMEM_Byte_Select ),
    .oPE124_AGU_DMEM_Address      ( wPE124_AGU_DMEM_Address     ),  // data memory address
    .oPE124_AGU_DMEM_Write_Data   ( wPE124_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE124_DMEM_EX_Data          ( wPE124_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE125
    .oPE125_DMEM_Valid            ( wPE125_DMEM_Valid           ),
    .oPE125_AGU_DMEM_Write_Enable ( wPE125_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE125_AGU_DMEM_Read_Enable  ( wPE125_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE125_AGU_DMEM_Byte_Select  ( wPE125_AGU_DMEM_Byte_Select ),
    .oPE125_AGU_DMEM_Address      ( wPE125_AGU_DMEM_Address     ),  // data memory address
    .oPE125_AGU_DMEM_Write_Data   ( wPE125_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE125_DMEM_EX_Data          ( wPE125_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE126
    .oPE126_DMEM_Valid            ( wPE126_DMEM_Valid           ),
    .oPE126_AGU_DMEM_Write_Enable ( wPE126_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE126_AGU_DMEM_Read_Enable  ( wPE126_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE126_AGU_DMEM_Byte_Select  ( wPE126_AGU_DMEM_Byte_Select ),
    .oPE126_AGU_DMEM_Address      ( wPE126_AGU_DMEM_Address     ),  // data memory address
    .oPE126_AGU_DMEM_Write_Data   ( wPE126_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE126_DMEM_EX_Data          ( wPE126_DMEM_EX_Data         ),  // data loaded from data memory
    
    // PE127
    .oPE127_DMEM_Valid            ( wPE127_DMEM_Valid           ),
    .oPE127_AGU_DMEM_Write_Enable ( wPE127_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE127_AGU_DMEM_Read_Enable  ( wPE127_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE127_AGU_DMEM_Byte_Select  ( wPE127_AGU_DMEM_Byte_Select ),
    .oPE127_AGU_DMEM_Address      ( wPE127_AGU_DMEM_Address     ),  // data memory address
    .oPE127_AGU_DMEM_Write_Data   ( wPE127_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE127_DMEM_EX_Data          ( wPE127_DMEM_EX_Data         ),  // data loaded from data memory
    
    // -----
    //  PE
    // -----
    .iIMEM_PE_Instruction          ( wIMEM_PE_Instruction      )  // instruction fetched from PE instruction memory
  );


//*********************
//  Output Assignment
//*********************


endmodule