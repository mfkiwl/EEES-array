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
  
  // PE8
  oPE8_DMEM_Valid,
  oPE8_AGU_DMEM_Write_Enable, // data memory write enable
  oPE8_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE8_AGU_DMEM_Byte_Select,
  oPE8_AGU_DMEM_Address,      // address to DMEM
  oPE8_AGU_DMEM_Write_Data,   // data memory write data
  iPE8_DMEM_EX_Data,          // data loaded from data memory
  
  // PE9
  oPE9_DMEM_Valid,
  oPE9_AGU_DMEM_Write_Enable, // data memory write enable
  oPE9_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE9_AGU_DMEM_Byte_Select,
  oPE9_AGU_DMEM_Address,      // address to DMEM
  oPE9_AGU_DMEM_Write_Data,   // data memory write data
  iPE9_DMEM_EX_Data,          // data loaded from data memory
  
  // PE10
  oPE10_DMEM_Valid,
  oPE10_AGU_DMEM_Write_Enable, // data memory write enable
  oPE10_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE10_AGU_DMEM_Byte_Select,
  oPE10_AGU_DMEM_Address,      // address to DMEM
  oPE10_AGU_DMEM_Write_Data,   // data memory write data
  iPE10_DMEM_EX_Data,          // data loaded from data memory
  
  // PE11
  oPE11_DMEM_Valid,
  oPE11_AGU_DMEM_Write_Enable, // data memory write enable
  oPE11_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE11_AGU_DMEM_Byte_Select,
  oPE11_AGU_DMEM_Address,      // address to DMEM
  oPE11_AGU_DMEM_Write_Data,   // data memory write data
  iPE11_DMEM_EX_Data,          // data loaded from data memory
  
  // PE12
  oPE12_DMEM_Valid,
  oPE12_AGU_DMEM_Write_Enable, // data memory write enable
  oPE12_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE12_AGU_DMEM_Byte_Select,
  oPE12_AGU_DMEM_Address,      // address to DMEM
  oPE12_AGU_DMEM_Write_Data,   // data memory write data
  iPE12_DMEM_EX_Data,          // data loaded from data memory
  
  // PE13
  oPE13_DMEM_Valid,
  oPE13_AGU_DMEM_Write_Enable, // data memory write enable
  oPE13_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE13_AGU_DMEM_Byte_Select,
  oPE13_AGU_DMEM_Address,      // address to DMEM
  oPE13_AGU_DMEM_Write_Data,   // data memory write data
  iPE13_DMEM_EX_Data,          // data loaded from data memory
  
  // PE14
  oPE14_DMEM_Valid,
  oPE14_AGU_DMEM_Write_Enable, // data memory write enable
  oPE14_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE14_AGU_DMEM_Byte_Select,
  oPE14_AGU_DMEM_Address,      // address to DMEM
  oPE14_AGU_DMEM_Write_Data,   // data memory write data
  iPE14_DMEM_EX_Data,          // data loaded from data memory
  
  // PE15
  oPE15_DMEM_Valid,
  oPE15_AGU_DMEM_Write_Enable, // data memory write enable
  oPE15_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE15_AGU_DMEM_Byte_Select,
  oPE15_AGU_DMEM_Address,      // address to DMEM
  oPE15_AGU_DMEM_Write_Data,   // data memory write data
  iPE15_DMEM_EX_Data,          // data loaded from data memory
  
  // PE16
  oPE16_DMEM_Valid,
  oPE16_AGU_DMEM_Write_Enable, // data memory write enable
  oPE16_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE16_AGU_DMEM_Byte_Select,
  oPE16_AGU_DMEM_Address,      // address to DMEM
  oPE16_AGU_DMEM_Write_Data,   // data memory write data
  iPE16_DMEM_EX_Data,          // data loaded from data memory
  
  // PE17
  oPE17_DMEM_Valid,
  oPE17_AGU_DMEM_Write_Enable, // data memory write enable
  oPE17_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE17_AGU_DMEM_Byte_Select,
  oPE17_AGU_DMEM_Address,      // address to DMEM
  oPE17_AGU_DMEM_Write_Data,   // data memory write data
  iPE17_DMEM_EX_Data,          // data loaded from data memory
  
  // PE18
  oPE18_DMEM_Valid,
  oPE18_AGU_DMEM_Write_Enable, // data memory write enable
  oPE18_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE18_AGU_DMEM_Byte_Select,
  oPE18_AGU_DMEM_Address,      // address to DMEM
  oPE18_AGU_DMEM_Write_Data,   // data memory write data
  iPE18_DMEM_EX_Data,          // data loaded from data memory
  
  // PE19
  oPE19_DMEM_Valid,
  oPE19_AGU_DMEM_Write_Enable, // data memory write enable
  oPE19_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE19_AGU_DMEM_Byte_Select,
  oPE19_AGU_DMEM_Address,      // address to DMEM
  oPE19_AGU_DMEM_Write_Data,   // data memory write data
  iPE19_DMEM_EX_Data,          // data loaded from data memory
  
  // PE20
  oPE20_DMEM_Valid,
  oPE20_AGU_DMEM_Write_Enable, // data memory write enable
  oPE20_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE20_AGU_DMEM_Byte_Select,
  oPE20_AGU_DMEM_Address,      // address to DMEM
  oPE20_AGU_DMEM_Write_Data,   // data memory write data
  iPE20_DMEM_EX_Data,          // data loaded from data memory
  
  // PE21
  oPE21_DMEM_Valid,
  oPE21_AGU_DMEM_Write_Enable, // data memory write enable
  oPE21_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE21_AGU_DMEM_Byte_Select,
  oPE21_AGU_DMEM_Address,      // address to DMEM
  oPE21_AGU_DMEM_Write_Data,   // data memory write data
  iPE21_DMEM_EX_Data,          // data loaded from data memory
  
  // PE22
  oPE22_DMEM_Valid,
  oPE22_AGU_DMEM_Write_Enable, // data memory write enable
  oPE22_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE22_AGU_DMEM_Byte_Select,
  oPE22_AGU_DMEM_Address,      // address to DMEM
  oPE22_AGU_DMEM_Write_Data,   // data memory write data
  iPE22_DMEM_EX_Data,          // data loaded from data memory
  
  // PE23
  oPE23_DMEM_Valid,
  oPE23_AGU_DMEM_Write_Enable, // data memory write enable
  oPE23_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE23_AGU_DMEM_Byte_Select,
  oPE23_AGU_DMEM_Address,      // address to DMEM
  oPE23_AGU_DMEM_Write_Data,   // data memory write data
  iPE23_DMEM_EX_Data,          // data loaded from data memory
  
  // PE24
  oPE24_DMEM_Valid,
  oPE24_AGU_DMEM_Write_Enable, // data memory write enable
  oPE24_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE24_AGU_DMEM_Byte_Select,
  oPE24_AGU_DMEM_Address,      // address to DMEM
  oPE24_AGU_DMEM_Write_Data,   // data memory write data
  iPE24_DMEM_EX_Data,          // data loaded from data memory
  
  // PE25
  oPE25_DMEM_Valid,
  oPE25_AGU_DMEM_Write_Enable, // data memory write enable
  oPE25_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE25_AGU_DMEM_Byte_Select,
  oPE25_AGU_DMEM_Address,      // address to DMEM
  oPE25_AGU_DMEM_Write_Data,   // data memory write data
  iPE25_DMEM_EX_Data,          // data loaded from data memory
  
  // PE26
  oPE26_DMEM_Valid,
  oPE26_AGU_DMEM_Write_Enable, // data memory write enable
  oPE26_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE26_AGU_DMEM_Byte_Select,
  oPE26_AGU_DMEM_Address,      // address to DMEM
  oPE26_AGU_DMEM_Write_Data,   // data memory write data
  iPE26_DMEM_EX_Data,          // data loaded from data memory
  
  // PE27
  oPE27_DMEM_Valid,
  oPE27_AGU_DMEM_Write_Enable, // data memory write enable
  oPE27_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE27_AGU_DMEM_Byte_Select,
  oPE27_AGU_DMEM_Address,      // address to DMEM
  oPE27_AGU_DMEM_Write_Data,   // data memory write data
  iPE27_DMEM_EX_Data,          // data loaded from data memory
  
  // PE28
  oPE28_DMEM_Valid,
  oPE28_AGU_DMEM_Write_Enable, // data memory write enable
  oPE28_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE28_AGU_DMEM_Byte_Select,
  oPE28_AGU_DMEM_Address,      // address to DMEM
  oPE28_AGU_DMEM_Write_Data,   // data memory write data
  iPE28_DMEM_EX_Data,          // data loaded from data memory
  
  // PE29
  oPE29_DMEM_Valid,
  oPE29_AGU_DMEM_Write_Enable, // data memory write enable
  oPE29_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE29_AGU_DMEM_Byte_Select,
  oPE29_AGU_DMEM_Address,      // address to DMEM
  oPE29_AGU_DMEM_Write_Data,   // data memory write data
  iPE29_DMEM_EX_Data,          // data loaded from data memory
  
  // PE30
  oPE30_DMEM_Valid,
  oPE30_AGU_DMEM_Write_Enable, // data memory write enable
  oPE30_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE30_AGU_DMEM_Byte_Select,
  oPE30_AGU_DMEM_Address,      // address to DMEM
  oPE30_AGU_DMEM_Write_Data,   // data memory write data
  iPE30_DMEM_EX_Data,          // data loaded from data memory
  
  // PE31
  oPE31_DMEM_Valid,
  oPE31_AGU_DMEM_Write_Enable, // data memory write enable
  oPE31_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE31_AGU_DMEM_Byte_Select,
  oPE31_AGU_DMEM_Address,      // address to DMEM
  oPE31_AGU_DMEM_Write_Data,   // data memory write data
  iPE31_DMEM_EX_Data,          // data loaded from data memory
  
  // PE32
  oPE32_DMEM_Valid,
  oPE32_AGU_DMEM_Write_Enable, // data memory write enable
  oPE32_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE32_AGU_DMEM_Byte_Select,
  oPE32_AGU_DMEM_Address,      // address to DMEM
  oPE32_AGU_DMEM_Write_Data,   // data memory write data
  iPE32_DMEM_EX_Data,          // data loaded from data memory
  
  // PE33
  oPE33_DMEM_Valid,
  oPE33_AGU_DMEM_Write_Enable, // data memory write enable
  oPE33_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE33_AGU_DMEM_Byte_Select,
  oPE33_AGU_DMEM_Address,      // address to DMEM
  oPE33_AGU_DMEM_Write_Data,   // data memory write data
  iPE33_DMEM_EX_Data,          // data loaded from data memory
  
  // PE34
  oPE34_DMEM_Valid,
  oPE34_AGU_DMEM_Write_Enable, // data memory write enable
  oPE34_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE34_AGU_DMEM_Byte_Select,
  oPE34_AGU_DMEM_Address,      // address to DMEM
  oPE34_AGU_DMEM_Write_Data,   // data memory write data
  iPE34_DMEM_EX_Data,          // data loaded from data memory
  
  // PE35
  oPE35_DMEM_Valid,
  oPE35_AGU_DMEM_Write_Enable, // data memory write enable
  oPE35_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE35_AGU_DMEM_Byte_Select,
  oPE35_AGU_DMEM_Address,      // address to DMEM
  oPE35_AGU_DMEM_Write_Data,   // data memory write data
  iPE35_DMEM_EX_Data,          // data loaded from data memory
  
  // PE36
  oPE36_DMEM_Valid,
  oPE36_AGU_DMEM_Write_Enable, // data memory write enable
  oPE36_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE36_AGU_DMEM_Byte_Select,
  oPE36_AGU_DMEM_Address,      // address to DMEM
  oPE36_AGU_DMEM_Write_Data,   // data memory write data
  iPE36_DMEM_EX_Data,          // data loaded from data memory
  
  // PE37
  oPE37_DMEM_Valid,
  oPE37_AGU_DMEM_Write_Enable, // data memory write enable
  oPE37_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE37_AGU_DMEM_Byte_Select,
  oPE37_AGU_DMEM_Address,      // address to DMEM
  oPE37_AGU_DMEM_Write_Data,   // data memory write data
  iPE37_DMEM_EX_Data,          // data loaded from data memory
  
  // PE38
  oPE38_DMEM_Valid,
  oPE38_AGU_DMEM_Write_Enable, // data memory write enable
  oPE38_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE38_AGU_DMEM_Byte_Select,
  oPE38_AGU_DMEM_Address,      // address to DMEM
  oPE38_AGU_DMEM_Write_Data,   // data memory write data
  iPE38_DMEM_EX_Data,          // data loaded from data memory
  
  // PE39
  oPE39_DMEM_Valid,
  oPE39_AGU_DMEM_Write_Enable, // data memory write enable
  oPE39_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE39_AGU_DMEM_Byte_Select,
  oPE39_AGU_DMEM_Address,      // address to DMEM
  oPE39_AGU_DMEM_Write_Data,   // data memory write data
  iPE39_DMEM_EX_Data,          // data loaded from data memory
  
  // PE40
  oPE40_DMEM_Valid,
  oPE40_AGU_DMEM_Write_Enable, // data memory write enable
  oPE40_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE40_AGU_DMEM_Byte_Select,
  oPE40_AGU_DMEM_Address,      // address to DMEM
  oPE40_AGU_DMEM_Write_Data,   // data memory write data
  iPE40_DMEM_EX_Data,          // data loaded from data memory
  
  // PE41
  oPE41_DMEM_Valid,
  oPE41_AGU_DMEM_Write_Enable, // data memory write enable
  oPE41_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE41_AGU_DMEM_Byte_Select,
  oPE41_AGU_DMEM_Address,      // address to DMEM
  oPE41_AGU_DMEM_Write_Data,   // data memory write data
  iPE41_DMEM_EX_Data,          // data loaded from data memory
  
  // PE42
  oPE42_DMEM_Valid,
  oPE42_AGU_DMEM_Write_Enable, // data memory write enable
  oPE42_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE42_AGU_DMEM_Byte_Select,
  oPE42_AGU_DMEM_Address,      // address to DMEM
  oPE42_AGU_DMEM_Write_Data,   // data memory write data
  iPE42_DMEM_EX_Data,          // data loaded from data memory
  
  // PE43
  oPE43_DMEM_Valid,
  oPE43_AGU_DMEM_Write_Enable, // data memory write enable
  oPE43_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE43_AGU_DMEM_Byte_Select,
  oPE43_AGU_DMEM_Address,      // address to DMEM
  oPE43_AGU_DMEM_Write_Data,   // data memory write data
  iPE43_DMEM_EX_Data,          // data loaded from data memory
  
  // PE44
  oPE44_DMEM_Valid,
  oPE44_AGU_DMEM_Write_Enable, // data memory write enable
  oPE44_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE44_AGU_DMEM_Byte_Select,
  oPE44_AGU_DMEM_Address,      // address to DMEM
  oPE44_AGU_DMEM_Write_Data,   // data memory write data
  iPE44_DMEM_EX_Data,          // data loaded from data memory
  
  // PE45
  oPE45_DMEM_Valid,
  oPE45_AGU_DMEM_Write_Enable, // data memory write enable
  oPE45_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE45_AGU_DMEM_Byte_Select,
  oPE45_AGU_DMEM_Address,      // address to DMEM
  oPE45_AGU_DMEM_Write_Data,   // data memory write data
  iPE45_DMEM_EX_Data,          // data loaded from data memory
  
  // PE46
  oPE46_DMEM_Valid,
  oPE46_AGU_DMEM_Write_Enable, // data memory write enable
  oPE46_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE46_AGU_DMEM_Byte_Select,
  oPE46_AGU_DMEM_Address,      // address to DMEM
  oPE46_AGU_DMEM_Write_Data,   // data memory write data
  iPE46_DMEM_EX_Data,          // data loaded from data memory
  
  // PE47
  oPE47_DMEM_Valid,
  oPE47_AGU_DMEM_Write_Enable, // data memory write enable
  oPE47_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE47_AGU_DMEM_Byte_Select,
  oPE47_AGU_DMEM_Address,      // address to DMEM
  oPE47_AGU_DMEM_Write_Data,   // data memory write data
  iPE47_DMEM_EX_Data,          // data loaded from data memory
  
  // PE48
  oPE48_DMEM_Valid,
  oPE48_AGU_DMEM_Write_Enable, // data memory write enable
  oPE48_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE48_AGU_DMEM_Byte_Select,
  oPE48_AGU_DMEM_Address,      // address to DMEM
  oPE48_AGU_DMEM_Write_Data,   // data memory write data
  iPE48_DMEM_EX_Data,          // data loaded from data memory
  
  // PE49
  oPE49_DMEM_Valid,
  oPE49_AGU_DMEM_Write_Enable, // data memory write enable
  oPE49_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE49_AGU_DMEM_Byte_Select,
  oPE49_AGU_DMEM_Address,      // address to DMEM
  oPE49_AGU_DMEM_Write_Data,   // data memory write data
  iPE49_DMEM_EX_Data,          // data loaded from data memory
  
  // PE50
  oPE50_DMEM_Valid,
  oPE50_AGU_DMEM_Write_Enable, // data memory write enable
  oPE50_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE50_AGU_DMEM_Byte_Select,
  oPE50_AGU_DMEM_Address,      // address to DMEM
  oPE50_AGU_DMEM_Write_Data,   // data memory write data
  iPE50_DMEM_EX_Data,          // data loaded from data memory
  
  // PE51
  oPE51_DMEM_Valid,
  oPE51_AGU_DMEM_Write_Enable, // data memory write enable
  oPE51_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE51_AGU_DMEM_Byte_Select,
  oPE51_AGU_DMEM_Address,      // address to DMEM
  oPE51_AGU_DMEM_Write_Data,   // data memory write data
  iPE51_DMEM_EX_Data,          // data loaded from data memory
  
  // PE52
  oPE52_DMEM_Valid,
  oPE52_AGU_DMEM_Write_Enable, // data memory write enable
  oPE52_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE52_AGU_DMEM_Byte_Select,
  oPE52_AGU_DMEM_Address,      // address to DMEM
  oPE52_AGU_DMEM_Write_Data,   // data memory write data
  iPE52_DMEM_EX_Data,          // data loaded from data memory
  
  // PE53
  oPE53_DMEM_Valid,
  oPE53_AGU_DMEM_Write_Enable, // data memory write enable
  oPE53_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE53_AGU_DMEM_Byte_Select,
  oPE53_AGU_DMEM_Address,      // address to DMEM
  oPE53_AGU_DMEM_Write_Data,   // data memory write data
  iPE53_DMEM_EX_Data,          // data loaded from data memory
  
  // PE54
  oPE54_DMEM_Valid,
  oPE54_AGU_DMEM_Write_Enable, // data memory write enable
  oPE54_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE54_AGU_DMEM_Byte_Select,
  oPE54_AGU_DMEM_Address,      // address to DMEM
  oPE54_AGU_DMEM_Write_Data,   // data memory write data
  iPE54_DMEM_EX_Data,          // data loaded from data memory
  
  // PE55
  oPE55_DMEM_Valid,
  oPE55_AGU_DMEM_Write_Enable, // data memory write enable
  oPE55_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE55_AGU_DMEM_Byte_Select,
  oPE55_AGU_DMEM_Address,      // address to DMEM
  oPE55_AGU_DMEM_Write_Data,   // data memory write data
  iPE55_DMEM_EX_Data,          // data loaded from data memory
  
  // PE56
  oPE56_DMEM_Valid,
  oPE56_AGU_DMEM_Write_Enable, // data memory write enable
  oPE56_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE56_AGU_DMEM_Byte_Select,
  oPE56_AGU_DMEM_Address,      // address to DMEM
  oPE56_AGU_DMEM_Write_Data,   // data memory write data
  iPE56_DMEM_EX_Data,          // data loaded from data memory
  
  // PE57
  oPE57_DMEM_Valid,
  oPE57_AGU_DMEM_Write_Enable, // data memory write enable
  oPE57_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE57_AGU_DMEM_Byte_Select,
  oPE57_AGU_DMEM_Address,      // address to DMEM
  oPE57_AGU_DMEM_Write_Data,   // data memory write data
  iPE57_DMEM_EX_Data,          // data loaded from data memory
  
  // PE58
  oPE58_DMEM_Valid,
  oPE58_AGU_DMEM_Write_Enable, // data memory write enable
  oPE58_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE58_AGU_DMEM_Byte_Select,
  oPE58_AGU_DMEM_Address,      // address to DMEM
  oPE58_AGU_DMEM_Write_Data,   // data memory write data
  iPE58_DMEM_EX_Data,          // data loaded from data memory
  
  // PE59
  oPE59_DMEM_Valid,
  oPE59_AGU_DMEM_Write_Enable, // data memory write enable
  oPE59_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE59_AGU_DMEM_Byte_Select,
  oPE59_AGU_DMEM_Address,      // address to DMEM
  oPE59_AGU_DMEM_Write_Data,   // data memory write data
  iPE59_DMEM_EX_Data,          // data loaded from data memory
  
  // PE60
  oPE60_DMEM_Valid,
  oPE60_AGU_DMEM_Write_Enable, // data memory write enable
  oPE60_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE60_AGU_DMEM_Byte_Select,
  oPE60_AGU_DMEM_Address,      // address to DMEM
  oPE60_AGU_DMEM_Write_Data,   // data memory write data
  iPE60_DMEM_EX_Data,          // data loaded from data memory
  
  // PE61
  oPE61_DMEM_Valid,
  oPE61_AGU_DMEM_Write_Enable, // data memory write enable
  oPE61_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE61_AGU_DMEM_Byte_Select,
  oPE61_AGU_DMEM_Address,      // address to DMEM
  oPE61_AGU_DMEM_Write_Data,   // data memory write data
  iPE61_DMEM_EX_Data,          // data loaded from data memory
  
  // PE62
  oPE62_DMEM_Valid,
  oPE62_AGU_DMEM_Write_Enable, // data memory write enable
  oPE62_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE62_AGU_DMEM_Byte_Select,
  oPE62_AGU_DMEM_Address,      // address to DMEM
  oPE62_AGU_DMEM_Write_Data,   // data memory write data
  iPE62_DMEM_EX_Data,          // data loaded from data memory
  
  // PE63
  oPE63_DMEM_Valid,
  oPE63_AGU_DMEM_Write_Enable, // data memory write enable
  oPE63_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE63_AGU_DMEM_Byte_Select,
  oPE63_AGU_DMEM_Address,      // address to DMEM
  oPE63_AGU_DMEM_Write_Data,   // data memory write data
  iPE63_DMEM_EX_Data,          // data loaded from data memory
  
  // PE64
  oPE64_DMEM_Valid,
  oPE64_AGU_DMEM_Write_Enable, // data memory write enable
  oPE64_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE64_AGU_DMEM_Byte_Select,
  oPE64_AGU_DMEM_Address,      // address to DMEM
  oPE64_AGU_DMEM_Write_Data,   // data memory write data
  iPE64_DMEM_EX_Data,          // data loaded from data memory
  
  // PE65
  oPE65_DMEM_Valid,
  oPE65_AGU_DMEM_Write_Enable, // data memory write enable
  oPE65_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE65_AGU_DMEM_Byte_Select,
  oPE65_AGU_DMEM_Address,      // address to DMEM
  oPE65_AGU_DMEM_Write_Data,   // data memory write data
  iPE65_DMEM_EX_Data,          // data loaded from data memory
  
  // PE66
  oPE66_DMEM_Valid,
  oPE66_AGU_DMEM_Write_Enable, // data memory write enable
  oPE66_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE66_AGU_DMEM_Byte_Select,
  oPE66_AGU_DMEM_Address,      // address to DMEM
  oPE66_AGU_DMEM_Write_Data,   // data memory write data
  iPE66_DMEM_EX_Data,          // data loaded from data memory
  
  // PE67
  oPE67_DMEM_Valid,
  oPE67_AGU_DMEM_Write_Enable, // data memory write enable
  oPE67_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE67_AGU_DMEM_Byte_Select,
  oPE67_AGU_DMEM_Address,      // address to DMEM
  oPE67_AGU_DMEM_Write_Data,   // data memory write data
  iPE67_DMEM_EX_Data,          // data loaded from data memory
  
  // PE68
  oPE68_DMEM_Valid,
  oPE68_AGU_DMEM_Write_Enable, // data memory write enable
  oPE68_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE68_AGU_DMEM_Byte_Select,
  oPE68_AGU_DMEM_Address,      // address to DMEM
  oPE68_AGU_DMEM_Write_Data,   // data memory write data
  iPE68_DMEM_EX_Data,          // data loaded from data memory
  
  // PE69
  oPE69_DMEM_Valid,
  oPE69_AGU_DMEM_Write_Enable, // data memory write enable
  oPE69_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE69_AGU_DMEM_Byte_Select,
  oPE69_AGU_DMEM_Address,      // address to DMEM
  oPE69_AGU_DMEM_Write_Data,   // data memory write data
  iPE69_DMEM_EX_Data,          // data loaded from data memory
  
  // PE70
  oPE70_DMEM_Valid,
  oPE70_AGU_DMEM_Write_Enable, // data memory write enable
  oPE70_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE70_AGU_DMEM_Byte_Select,
  oPE70_AGU_DMEM_Address,      // address to DMEM
  oPE70_AGU_DMEM_Write_Data,   // data memory write data
  iPE70_DMEM_EX_Data,          // data loaded from data memory
  
  // PE71
  oPE71_DMEM_Valid,
  oPE71_AGU_DMEM_Write_Enable, // data memory write enable
  oPE71_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE71_AGU_DMEM_Byte_Select,
  oPE71_AGU_DMEM_Address,      // address to DMEM
  oPE71_AGU_DMEM_Write_Data,   // data memory write data
  iPE71_DMEM_EX_Data,          // data loaded from data memory
  
  // PE72
  oPE72_DMEM_Valid,
  oPE72_AGU_DMEM_Write_Enable, // data memory write enable
  oPE72_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE72_AGU_DMEM_Byte_Select,
  oPE72_AGU_DMEM_Address,      // address to DMEM
  oPE72_AGU_DMEM_Write_Data,   // data memory write data
  iPE72_DMEM_EX_Data,          // data loaded from data memory
  
  // PE73
  oPE73_DMEM_Valid,
  oPE73_AGU_DMEM_Write_Enable, // data memory write enable
  oPE73_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE73_AGU_DMEM_Byte_Select,
  oPE73_AGU_DMEM_Address,      // address to DMEM
  oPE73_AGU_DMEM_Write_Data,   // data memory write data
  iPE73_DMEM_EX_Data,          // data loaded from data memory
  
  // PE74
  oPE74_DMEM_Valid,
  oPE74_AGU_DMEM_Write_Enable, // data memory write enable
  oPE74_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE74_AGU_DMEM_Byte_Select,
  oPE74_AGU_DMEM_Address,      // address to DMEM
  oPE74_AGU_DMEM_Write_Data,   // data memory write data
  iPE74_DMEM_EX_Data,          // data loaded from data memory
  
  // PE75
  oPE75_DMEM_Valid,
  oPE75_AGU_DMEM_Write_Enable, // data memory write enable
  oPE75_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE75_AGU_DMEM_Byte_Select,
  oPE75_AGU_DMEM_Address,      // address to DMEM
  oPE75_AGU_DMEM_Write_Data,   // data memory write data
  iPE75_DMEM_EX_Data,          // data loaded from data memory
  
  // PE76
  oPE76_DMEM_Valid,
  oPE76_AGU_DMEM_Write_Enable, // data memory write enable
  oPE76_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE76_AGU_DMEM_Byte_Select,
  oPE76_AGU_DMEM_Address,      // address to DMEM
  oPE76_AGU_DMEM_Write_Data,   // data memory write data
  iPE76_DMEM_EX_Data,          // data loaded from data memory
  
  // PE77
  oPE77_DMEM_Valid,
  oPE77_AGU_DMEM_Write_Enable, // data memory write enable
  oPE77_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE77_AGU_DMEM_Byte_Select,
  oPE77_AGU_DMEM_Address,      // address to DMEM
  oPE77_AGU_DMEM_Write_Data,   // data memory write data
  iPE77_DMEM_EX_Data,          // data loaded from data memory
  
  // PE78
  oPE78_DMEM_Valid,
  oPE78_AGU_DMEM_Write_Enable, // data memory write enable
  oPE78_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE78_AGU_DMEM_Byte_Select,
  oPE78_AGU_DMEM_Address,      // address to DMEM
  oPE78_AGU_DMEM_Write_Data,   // data memory write data
  iPE78_DMEM_EX_Data,          // data loaded from data memory
  
  // PE79
  oPE79_DMEM_Valid,
  oPE79_AGU_DMEM_Write_Enable, // data memory write enable
  oPE79_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE79_AGU_DMEM_Byte_Select,
  oPE79_AGU_DMEM_Address,      // address to DMEM
  oPE79_AGU_DMEM_Write_Data,   // data memory write data
  iPE79_DMEM_EX_Data,          // data loaded from data memory
  
  // PE80
  oPE80_DMEM_Valid,
  oPE80_AGU_DMEM_Write_Enable, // data memory write enable
  oPE80_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE80_AGU_DMEM_Byte_Select,
  oPE80_AGU_DMEM_Address,      // address to DMEM
  oPE80_AGU_DMEM_Write_Data,   // data memory write data
  iPE80_DMEM_EX_Data,          // data loaded from data memory
  
  // PE81
  oPE81_DMEM_Valid,
  oPE81_AGU_DMEM_Write_Enable, // data memory write enable
  oPE81_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE81_AGU_DMEM_Byte_Select,
  oPE81_AGU_DMEM_Address,      // address to DMEM
  oPE81_AGU_DMEM_Write_Data,   // data memory write data
  iPE81_DMEM_EX_Data,          // data loaded from data memory
  
  // PE82
  oPE82_DMEM_Valid,
  oPE82_AGU_DMEM_Write_Enable, // data memory write enable
  oPE82_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE82_AGU_DMEM_Byte_Select,
  oPE82_AGU_DMEM_Address,      // address to DMEM
  oPE82_AGU_DMEM_Write_Data,   // data memory write data
  iPE82_DMEM_EX_Data,          // data loaded from data memory
  
  // PE83
  oPE83_DMEM_Valid,
  oPE83_AGU_DMEM_Write_Enable, // data memory write enable
  oPE83_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE83_AGU_DMEM_Byte_Select,
  oPE83_AGU_DMEM_Address,      // address to DMEM
  oPE83_AGU_DMEM_Write_Data,   // data memory write data
  iPE83_DMEM_EX_Data,          // data loaded from data memory
  
  // PE84
  oPE84_DMEM_Valid,
  oPE84_AGU_DMEM_Write_Enable, // data memory write enable
  oPE84_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE84_AGU_DMEM_Byte_Select,
  oPE84_AGU_DMEM_Address,      // address to DMEM
  oPE84_AGU_DMEM_Write_Data,   // data memory write data
  iPE84_DMEM_EX_Data,          // data loaded from data memory
  
  // PE85
  oPE85_DMEM_Valid,
  oPE85_AGU_DMEM_Write_Enable, // data memory write enable
  oPE85_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE85_AGU_DMEM_Byte_Select,
  oPE85_AGU_DMEM_Address,      // address to DMEM
  oPE85_AGU_DMEM_Write_Data,   // data memory write data
  iPE85_DMEM_EX_Data,          // data loaded from data memory
  
  // PE86
  oPE86_DMEM_Valid,
  oPE86_AGU_DMEM_Write_Enable, // data memory write enable
  oPE86_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE86_AGU_DMEM_Byte_Select,
  oPE86_AGU_DMEM_Address,      // address to DMEM
  oPE86_AGU_DMEM_Write_Data,   // data memory write data
  iPE86_DMEM_EX_Data,          // data loaded from data memory
  
  // PE87
  oPE87_DMEM_Valid,
  oPE87_AGU_DMEM_Write_Enable, // data memory write enable
  oPE87_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE87_AGU_DMEM_Byte_Select,
  oPE87_AGU_DMEM_Address,      // address to DMEM
  oPE87_AGU_DMEM_Write_Data,   // data memory write data
  iPE87_DMEM_EX_Data,          // data loaded from data memory
  
  // PE88
  oPE88_DMEM_Valid,
  oPE88_AGU_DMEM_Write_Enable, // data memory write enable
  oPE88_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE88_AGU_DMEM_Byte_Select,
  oPE88_AGU_DMEM_Address,      // address to DMEM
  oPE88_AGU_DMEM_Write_Data,   // data memory write data
  iPE88_DMEM_EX_Data,          // data loaded from data memory
  
  // PE89
  oPE89_DMEM_Valid,
  oPE89_AGU_DMEM_Write_Enable, // data memory write enable
  oPE89_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE89_AGU_DMEM_Byte_Select,
  oPE89_AGU_DMEM_Address,      // address to DMEM
  oPE89_AGU_DMEM_Write_Data,   // data memory write data
  iPE89_DMEM_EX_Data,          // data loaded from data memory
  
  // PE90
  oPE90_DMEM_Valid,
  oPE90_AGU_DMEM_Write_Enable, // data memory write enable
  oPE90_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE90_AGU_DMEM_Byte_Select,
  oPE90_AGU_DMEM_Address,      // address to DMEM
  oPE90_AGU_DMEM_Write_Data,   // data memory write data
  iPE90_DMEM_EX_Data,          // data loaded from data memory
  
  // PE91
  oPE91_DMEM_Valid,
  oPE91_AGU_DMEM_Write_Enable, // data memory write enable
  oPE91_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE91_AGU_DMEM_Byte_Select,
  oPE91_AGU_DMEM_Address,      // address to DMEM
  oPE91_AGU_DMEM_Write_Data,   // data memory write data
  iPE91_DMEM_EX_Data,          // data loaded from data memory
  
  // PE92
  oPE92_DMEM_Valid,
  oPE92_AGU_DMEM_Write_Enable, // data memory write enable
  oPE92_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE92_AGU_DMEM_Byte_Select,
  oPE92_AGU_DMEM_Address,      // address to DMEM
  oPE92_AGU_DMEM_Write_Data,   // data memory write data
  iPE92_DMEM_EX_Data,          // data loaded from data memory
  
  // PE93
  oPE93_DMEM_Valid,
  oPE93_AGU_DMEM_Write_Enable, // data memory write enable
  oPE93_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE93_AGU_DMEM_Byte_Select,
  oPE93_AGU_DMEM_Address,      // address to DMEM
  oPE93_AGU_DMEM_Write_Data,   // data memory write data
  iPE93_DMEM_EX_Data,          // data loaded from data memory
  
  // PE94
  oPE94_DMEM_Valid,
  oPE94_AGU_DMEM_Write_Enable, // data memory write enable
  oPE94_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE94_AGU_DMEM_Byte_Select,
  oPE94_AGU_DMEM_Address,      // address to DMEM
  oPE94_AGU_DMEM_Write_Data,   // data memory write data
  iPE94_DMEM_EX_Data,          // data loaded from data memory
  
  // PE95
  oPE95_DMEM_Valid,
  oPE95_AGU_DMEM_Write_Enable, // data memory write enable
  oPE95_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE95_AGU_DMEM_Byte_Select,
  oPE95_AGU_DMEM_Address,      // address to DMEM
  oPE95_AGU_DMEM_Write_Data,   // data memory write data
  iPE95_DMEM_EX_Data,          // data loaded from data memory
  
  // PE96
  oPE96_DMEM_Valid,
  oPE96_AGU_DMEM_Write_Enable, // data memory write enable
  oPE96_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE96_AGU_DMEM_Byte_Select,
  oPE96_AGU_DMEM_Address,      // address to DMEM
  oPE96_AGU_DMEM_Write_Data,   // data memory write data
  iPE96_DMEM_EX_Data,          // data loaded from data memory
  
  // PE97
  oPE97_DMEM_Valid,
  oPE97_AGU_DMEM_Write_Enable, // data memory write enable
  oPE97_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE97_AGU_DMEM_Byte_Select,
  oPE97_AGU_DMEM_Address,      // address to DMEM
  oPE97_AGU_DMEM_Write_Data,   // data memory write data
  iPE97_DMEM_EX_Data,          // data loaded from data memory
  
  // PE98
  oPE98_DMEM_Valid,
  oPE98_AGU_DMEM_Write_Enable, // data memory write enable
  oPE98_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE98_AGU_DMEM_Byte_Select,
  oPE98_AGU_DMEM_Address,      // address to DMEM
  oPE98_AGU_DMEM_Write_Data,   // data memory write data
  iPE98_DMEM_EX_Data,          // data loaded from data memory
  
  // PE99
  oPE99_DMEM_Valid,
  oPE99_AGU_DMEM_Write_Enable, // data memory write enable
  oPE99_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE99_AGU_DMEM_Byte_Select,
  oPE99_AGU_DMEM_Address,      // address to DMEM
  oPE99_AGU_DMEM_Write_Data,   // data memory write data
  iPE99_DMEM_EX_Data,          // data loaded from data memory
  
  // PE100
  oPE100_DMEM_Valid,
  oPE100_AGU_DMEM_Write_Enable, // data memory write enable
  oPE100_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE100_AGU_DMEM_Byte_Select,
  oPE100_AGU_DMEM_Address,      // address to DMEM
  oPE100_AGU_DMEM_Write_Data,   // data memory write data
  iPE100_DMEM_EX_Data,          // data loaded from data memory
  
  // PE101
  oPE101_DMEM_Valid,
  oPE101_AGU_DMEM_Write_Enable, // data memory write enable
  oPE101_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE101_AGU_DMEM_Byte_Select,
  oPE101_AGU_DMEM_Address,      // address to DMEM
  oPE101_AGU_DMEM_Write_Data,   // data memory write data
  iPE101_DMEM_EX_Data,          // data loaded from data memory
  
  // PE102
  oPE102_DMEM_Valid,
  oPE102_AGU_DMEM_Write_Enable, // data memory write enable
  oPE102_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE102_AGU_DMEM_Byte_Select,
  oPE102_AGU_DMEM_Address,      // address to DMEM
  oPE102_AGU_DMEM_Write_Data,   // data memory write data
  iPE102_DMEM_EX_Data,          // data loaded from data memory
  
  // PE103
  oPE103_DMEM_Valid,
  oPE103_AGU_DMEM_Write_Enable, // data memory write enable
  oPE103_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE103_AGU_DMEM_Byte_Select,
  oPE103_AGU_DMEM_Address,      // address to DMEM
  oPE103_AGU_DMEM_Write_Data,   // data memory write data
  iPE103_DMEM_EX_Data,          // data loaded from data memory
  
  // PE104
  oPE104_DMEM_Valid,
  oPE104_AGU_DMEM_Write_Enable, // data memory write enable
  oPE104_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE104_AGU_DMEM_Byte_Select,
  oPE104_AGU_DMEM_Address,      // address to DMEM
  oPE104_AGU_DMEM_Write_Data,   // data memory write data
  iPE104_DMEM_EX_Data,          // data loaded from data memory
  
  // PE105
  oPE105_DMEM_Valid,
  oPE105_AGU_DMEM_Write_Enable, // data memory write enable
  oPE105_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE105_AGU_DMEM_Byte_Select,
  oPE105_AGU_DMEM_Address,      // address to DMEM
  oPE105_AGU_DMEM_Write_Data,   // data memory write data
  iPE105_DMEM_EX_Data,          // data loaded from data memory
  
  // PE106
  oPE106_DMEM_Valid,
  oPE106_AGU_DMEM_Write_Enable, // data memory write enable
  oPE106_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE106_AGU_DMEM_Byte_Select,
  oPE106_AGU_DMEM_Address,      // address to DMEM
  oPE106_AGU_DMEM_Write_Data,   // data memory write data
  iPE106_DMEM_EX_Data,          // data loaded from data memory
  
  // PE107
  oPE107_DMEM_Valid,
  oPE107_AGU_DMEM_Write_Enable, // data memory write enable
  oPE107_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE107_AGU_DMEM_Byte_Select,
  oPE107_AGU_DMEM_Address,      // address to DMEM
  oPE107_AGU_DMEM_Write_Data,   // data memory write data
  iPE107_DMEM_EX_Data,          // data loaded from data memory
  
  // PE108
  oPE108_DMEM_Valid,
  oPE108_AGU_DMEM_Write_Enable, // data memory write enable
  oPE108_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE108_AGU_DMEM_Byte_Select,
  oPE108_AGU_DMEM_Address,      // address to DMEM
  oPE108_AGU_DMEM_Write_Data,   // data memory write data
  iPE108_DMEM_EX_Data,          // data loaded from data memory
  
  // PE109
  oPE109_DMEM_Valid,
  oPE109_AGU_DMEM_Write_Enable, // data memory write enable
  oPE109_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE109_AGU_DMEM_Byte_Select,
  oPE109_AGU_DMEM_Address,      // address to DMEM
  oPE109_AGU_DMEM_Write_Data,   // data memory write data
  iPE109_DMEM_EX_Data,          // data loaded from data memory
  
  // PE110
  oPE110_DMEM_Valid,
  oPE110_AGU_DMEM_Write_Enable, // data memory write enable
  oPE110_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE110_AGU_DMEM_Byte_Select,
  oPE110_AGU_DMEM_Address,      // address to DMEM
  oPE110_AGU_DMEM_Write_Data,   // data memory write data
  iPE110_DMEM_EX_Data,          // data loaded from data memory
  
  // PE111
  oPE111_DMEM_Valid,
  oPE111_AGU_DMEM_Write_Enable, // data memory write enable
  oPE111_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE111_AGU_DMEM_Byte_Select,
  oPE111_AGU_DMEM_Address,      // address to DMEM
  oPE111_AGU_DMEM_Write_Data,   // data memory write data
  iPE111_DMEM_EX_Data,          // data loaded from data memory
  
  // PE112
  oPE112_DMEM_Valid,
  oPE112_AGU_DMEM_Write_Enable, // data memory write enable
  oPE112_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE112_AGU_DMEM_Byte_Select,
  oPE112_AGU_DMEM_Address,      // address to DMEM
  oPE112_AGU_DMEM_Write_Data,   // data memory write data
  iPE112_DMEM_EX_Data,          // data loaded from data memory
  
  // PE113
  oPE113_DMEM_Valid,
  oPE113_AGU_DMEM_Write_Enable, // data memory write enable
  oPE113_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE113_AGU_DMEM_Byte_Select,
  oPE113_AGU_DMEM_Address,      // address to DMEM
  oPE113_AGU_DMEM_Write_Data,   // data memory write data
  iPE113_DMEM_EX_Data,          // data loaded from data memory
  
  // PE114
  oPE114_DMEM_Valid,
  oPE114_AGU_DMEM_Write_Enable, // data memory write enable
  oPE114_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE114_AGU_DMEM_Byte_Select,
  oPE114_AGU_DMEM_Address,      // address to DMEM
  oPE114_AGU_DMEM_Write_Data,   // data memory write data
  iPE114_DMEM_EX_Data,          // data loaded from data memory
  
  // PE115
  oPE115_DMEM_Valid,
  oPE115_AGU_DMEM_Write_Enable, // data memory write enable
  oPE115_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE115_AGU_DMEM_Byte_Select,
  oPE115_AGU_DMEM_Address,      // address to DMEM
  oPE115_AGU_DMEM_Write_Data,   // data memory write data
  iPE115_DMEM_EX_Data,          // data loaded from data memory
  
  // PE116
  oPE116_DMEM_Valid,
  oPE116_AGU_DMEM_Write_Enable, // data memory write enable
  oPE116_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE116_AGU_DMEM_Byte_Select,
  oPE116_AGU_DMEM_Address,      // address to DMEM
  oPE116_AGU_DMEM_Write_Data,   // data memory write data
  iPE116_DMEM_EX_Data,          // data loaded from data memory
  
  // PE117
  oPE117_DMEM_Valid,
  oPE117_AGU_DMEM_Write_Enable, // data memory write enable
  oPE117_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE117_AGU_DMEM_Byte_Select,
  oPE117_AGU_DMEM_Address,      // address to DMEM
  oPE117_AGU_DMEM_Write_Data,   // data memory write data
  iPE117_DMEM_EX_Data,          // data loaded from data memory
  
  // PE118
  oPE118_DMEM_Valid,
  oPE118_AGU_DMEM_Write_Enable, // data memory write enable
  oPE118_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE118_AGU_DMEM_Byte_Select,
  oPE118_AGU_DMEM_Address,      // address to DMEM
  oPE118_AGU_DMEM_Write_Data,   // data memory write data
  iPE118_DMEM_EX_Data,          // data loaded from data memory
  
  // PE119
  oPE119_DMEM_Valid,
  oPE119_AGU_DMEM_Write_Enable, // data memory write enable
  oPE119_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE119_AGU_DMEM_Byte_Select,
  oPE119_AGU_DMEM_Address,      // address to DMEM
  oPE119_AGU_DMEM_Write_Data,   // data memory write data
  iPE119_DMEM_EX_Data,          // data loaded from data memory
  
  // PE120
  oPE120_DMEM_Valid,
  oPE120_AGU_DMEM_Write_Enable, // data memory write enable
  oPE120_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE120_AGU_DMEM_Byte_Select,
  oPE120_AGU_DMEM_Address,      // address to DMEM
  oPE120_AGU_DMEM_Write_Data,   // data memory write data
  iPE120_DMEM_EX_Data,          // data loaded from data memory
  
  // PE121
  oPE121_DMEM_Valid,
  oPE121_AGU_DMEM_Write_Enable, // data memory write enable
  oPE121_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE121_AGU_DMEM_Byte_Select,
  oPE121_AGU_DMEM_Address,      // address to DMEM
  oPE121_AGU_DMEM_Write_Data,   // data memory write data
  iPE121_DMEM_EX_Data,          // data loaded from data memory
  
  // PE122
  oPE122_DMEM_Valid,
  oPE122_AGU_DMEM_Write_Enable, // data memory write enable
  oPE122_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE122_AGU_DMEM_Byte_Select,
  oPE122_AGU_DMEM_Address,      // address to DMEM
  oPE122_AGU_DMEM_Write_Data,   // data memory write data
  iPE122_DMEM_EX_Data,          // data loaded from data memory
  
  // PE123
  oPE123_DMEM_Valid,
  oPE123_AGU_DMEM_Write_Enable, // data memory write enable
  oPE123_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE123_AGU_DMEM_Byte_Select,
  oPE123_AGU_DMEM_Address,      // address to DMEM
  oPE123_AGU_DMEM_Write_Data,   // data memory write data
  iPE123_DMEM_EX_Data,          // data loaded from data memory
  
  // PE124
  oPE124_DMEM_Valid,
  oPE124_AGU_DMEM_Write_Enable, // data memory write enable
  oPE124_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE124_AGU_DMEM_Byte_Select,
  oPE124_AGU_DMEM_Address,      // address to DMEM
  oPE124_AGU_DMEM_Write_Data,   // data memory write data
  iPE124_DMEM_EX_Data,          // data loaded from data memory
  
  // PE125
  oPE125_DMEM_Valid,
  oPE125_AGU_DMEM_Write_Enable, // data memory write enable
  oPE125_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE125_AGU_DMEM_Byte_Select,
  oPE125_AGU_DMEM_Address,      // address to DMEM
  oPE125_AGU_DMEM_Write_Data,   // data memory write data
  iPE125_DMEM_EX_Data,          // data loaded from data memory
  
  // PE126
  oPE126_DMEM_Valid,
  oPE126_AGU_DMEM_Write_Enable, // data memory write enable
  oPE126_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE126_AGU_DMEM_Byte_Select,
  oPE126_AGU_DMEM_Address,      // address to DMEM
  oPE126_AGU_DMEM_Write_Data,   // data memory write data
  iPE126_DMEM_EX_Data,          // data loaded from data memory
  
  // PE127
  oPE127_DMEM_Valid,
  oPE127_AGU_DMEM_Write_Enable, // data memory write enable
  oPE127_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE127_AGU_DMEM_Byte_Select,
  oPE127_AGU_DMEM_Address,      // address to DMEM
  oPE127_AGU_DMEM_Write_Data,   // data memory write data
  iPE127_DMEM_EX_Data,          // data loaded from data memory
  
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
  
  // PE8
  output                                  oPE8_DMEM_Valid;
  output                                  oPE8_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE8_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE8_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE8_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE8_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE8_DMEM_EX_Data;          // data loaded from data memory
  
  // PE9
  output                                  oPE9_DMEM_Valid;
  output                                  oPE9_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE9_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE9_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE9_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE9_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE9_DMEM_EX_Data;          // data loaded from data memory
  
  // PE10
  output                                  oPE10_DMEM_Valid;
  output                                  oPE10_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE10_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE10_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE10_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE10_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE10_DMEM_EX_Data;          // data loaded from data memory
  
  // PE11
  output                                  oPE11_DMEM_Valid;
  output                                  oPE11_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE11_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE11_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE11_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE11_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE11_DMEM_EX_Data;          // data loaded from data memory
  
  // PE12
  output                                  oPE12_DMEM_Valid;
  output                                  oPE12_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE12_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE12_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE12_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE12_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE12_DMEM_EX_Data;          // data loaded from data memory
  
  // PE13
  output                                  oPE13_DMEM_Valid;
  output                                  oPE13_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE13_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE13_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE13_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE13_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE13_DMEM_EX_Data;          // data loaded from data memory
  
  // PE14
  output                                  oPE14_DMEM_Valid;
  output                                  oPE14_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE14_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE14_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE14_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE14_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE14_DMEM_EX_Data;          // data loaded from data memory
  
  // PE15
  output                                  oPE15_DMEM_Valid;
  output                                  oPE15_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE15_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE15_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE15_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE15_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE15_DMEM_EX_Data;          // data loaded from data memory
  
  // PE16
  output                                  oPE16_DMEM_Valid;
  output                                  oPE16_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE16_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE16_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE16_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE16_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE16_DMEM_EX_Data;          // data loaded from data memory
  
  // PE17
  output                                  oPE17_DMEM_Valid;
  output                                  oPE17_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE17_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE17_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE17_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE17_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE17_DMEM_EX_Data;          // data loaded from data memory
  
  // PE18
  output                                  oPE18_DMEM_Valid;
  output                                  oPE18_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE18_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE18_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE18_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE18_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE18_DMEM_EX_Data;          // data loaded from data memory
  
  // PE19
  output                                  oPE19_DMEM_Valid;
  output                                  oPE19_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE19_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE19_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE19_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE19_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE19_DMEM_EX_Data;          // data loaded from data memory
  
  // PE20
  output                                  oPE20_DMEM_Valid;
  output                                  oPE20_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE20_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE20_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE20_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE20_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE20_DMEM_EX_Data;          // data loaded from data memory
  
  // PE21
  output                                  oPE21_DMEM_Valid;
  output                                  oPE21_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE21_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE21_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE21_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE21_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE21_DMEM_EX_Data;          // data loaded from data memory
  
  // PE22
  output                                  oPE22_DMEM_Valid;
  output                                  oPE22_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE22_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE22_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE22_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE22_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE22_DMEM_EX_Data;          // data loaded from data memory
  
  // PE23
  output                                  oPE23_DMEM_Valid;
  output                                  oPE23_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE23_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE23_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE23_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE23_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE23_DMEM_EX_Data;          // data loaded from data memory
  
  // PE24
  output                                  oPE24_DMEM_Valid;
  output                                  oPE24_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE24_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE24_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE24_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE24_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE24_DMEM_EX_Data;          // data loaded from data memory
  
  // PE25
  output                                  oPE25_DMEM_Valid;
  output                                  oPE25_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE25_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE25_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE25_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE25_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE25_DMEM_EX_Data;          // data loaded from data memory
  
  // PE26
  output                                  oPE26_DMEM_Valid;
  output                                  oPE26_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE26_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE26_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE26_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE26_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE26_DMEM_EX_Data;          // data loaded from data memory
  
  // PE27
  output                                  oPE27_DMEM_Valid;
  output                                  oPE27_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE27_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE27_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE27_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE27_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE27_DMEM_EX_Data;          // data loaded from data memory
  
  // PE28
  output                                  oPE28_DMEM_Valid;
  output                                  oPE28_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE28_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE28_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE28_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE28_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE28_DMEM_EX_Data;          // data loaded from data memory
  
  // PE29
  output                                  oPE29_DMEM_Valid;
  output                                  oPE29_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE29_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE29_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE29_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE29_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE29_DMEM_EX_Data;          // data loaded from data memory
  
  // PE30
  output                                  oPE30_DMEM_Valid;
  output                                  oPE30_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE30_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE30_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE30_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE30_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE30_DMEM_EX_Data;          // data loaded from data memory
  
  // PE31
  output                                  oPE31_DMEM_Valid;
  output                                  oPE31_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE31_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE31_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE31_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE31_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE31_DMEM_EX_Data;          // data loaded from data memory
  
  // PE32
  output                                  oPE32_DMEM_Valid;
  output                                  oPE32_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE32_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE32_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE32_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE32_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE32_DMEM_EX_Data;          // data loaded from data memory
  
  // PE33
  output                                  oPE33_DMEM_Valid;
  output                                  oPE33_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE33_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE33_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE33_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE33_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE33_DMEM_EX_Data;          // data loaded from data memory
  
  // PE34
  output                                  oPE34_DMEM_Valid;
  output                                  oPE34_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE34_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE34_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE34_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE34_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE34_DMEM_EX_Data;          // data loaded from data memory
  
  // PE35
  output                                  oPE35_DMEM_Valid;
  output                                  oPE35_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE35_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE35_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE35_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE35_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE35_DMEM_EX_Data;          // data loaded from data memory
  
  // PE36
  output                                  oPE36_DMEM_Valid;
  output                                  oPE36_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE36_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE36_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE36_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE36_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE36_DMEM_EX_Data;          // data loaded from data memory
  
  // PE37
  output                                  oPE37_DMEM_Valid;
  output                                  oPE37_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE37_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE37_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE37_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE37_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE37_DMEM_EX_Data;          // data loaded from data memory
  
  // PE38
  output                                  oPE38_DMEM_Valid;
  output                                  oPE38_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE38_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE38_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE38_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE38_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE38_DMEM_EX_Data;          // data loaded from data memory
  
  // PE39
  output                                  oPE39_DMEM_Valid;
  output                                  oPE39_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE39_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE39_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE39_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE39_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE39_DMEM_EX_Data;          // data loaded from data memory
  
  // PE40
  output                                  oPE40_DMEM_Valid;
  output                                  oPE40_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE40_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE40_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE40_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE40_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE40_DMEM_EX_Data;          // data loaded from data memory
  
  // PE41
  output                                  oPE41_DMEM_Valid;
  output                                  oPE41_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE41_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE41_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE41_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE41_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE41_DMEM_EX_Data;          // data loaded from data memory
  
  // PE42
  output                                  oPE42_DMEM_Valid;
  output                                  oPE42_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE42_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE42_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE42_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE42_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE42_DMEM_EX_Data;          // data loaded from data memory
  
  // PE43
  output                                  oPE43_DMEM_Valid;
  output                                  oPE43_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE43_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE43_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE43_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE43_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE43_DMEM_EX_Data;          // data loaded from data memory
  
  // PE44
  output                                  oPE44_DMEM_Valid;
  output                                  oPE44_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE44_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE44_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE44_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE44_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE44_DMEM_EX_Data;          // data loaded from data memory
  
  // PE45
  output                                  oPE45_DMEM_Valid;
  output                                  oPE45_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE45_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE45_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE45_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE45_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE45_DMEM_EX_Data;          // data loaded from data memory
  
  // PE46
  output                                  oPE46_DMEM_Valid;
  output                                  oPE46_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE46_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE46_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE46_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE46_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE46_DMEM_EX_Data;          // data loaded from data memory
  
  // PE47
  output                                  oPE47_DMEM_Valid;
  output                                  oPE47_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE47_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE47_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE47_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE47_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE47_DMEM_EX_Data;          // data loaded from data memory
  
  // PE48
  output                                  oPE48_DMEM_Valid;
  output                                  oPE48_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE48_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE48_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE48_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE48_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE48_DMEM_EX_Data;          // data loaded from data memory
  
  // PE49
  output                                  oPE49_DMEM_Valid;
  output                                  oPE49_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE49_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE49_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE49_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE49_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE49_DMEM_EX_Data;          // data loaded from data memory
  
  // PE50
  output                                  oPE50_DMEM_Valid;
  output                                  oPE50_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE50_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE50_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE50_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE50_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE50_DMEM_EX_Data;          // data loaded from data memory
  
  // PE51
  output                                  oPE51_DMEM_Valid;
  output                                  oPE51_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE51_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE51_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE51_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE51_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE51_DMEM_EX_Data;          // data loaded from data memory
  
  // PE52
  output                                  oPE52_DMEM_Valid;
  output                                  oPE52_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE52_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE52_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE52_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE52_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE52_DMEM_EX_Data;          // data loaded from data memory
  
  // PE53
  output                                  oPE53_DMEM_Valid;
  output                                  oPE53_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE53_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE53_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE53_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE53_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE53_DMEM_EX_Data;          // data loaded from data memory
  
  // PE54
  output                                  oPE54_DMEM_Valid;
  output                                  oPE54_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE54_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE54_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE54_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE54_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE54_DMEM_EX_Data;          // data loaded from data memory
  
  // PE55
  output                                  oPE55_DMEM_Valid;
  output                                  oPE55_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE55_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE55_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE55_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE55_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE55_DMEM_EX_Data;          // data loaded from data memory
  
  // PE56
  output                                  oPE56_DMEM_Valid;
  output                                  oPE56_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE56_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE56_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE56_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE56_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE56_DMEM_EX_Data;          // data loaded from data memory
  
  // PE57
  output                                  oPE57_DMEM_Valid;
  output                                  oPE57_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE57_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE57_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE57_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE57_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE57_DMEM_EX_Data;          // data loaded from data memory
  
  // PE58
  output                                  oPE58_DMEM_Valid;
  output                                  oPE58_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE58_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE58_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE58_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE58_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE58_DMEM_EX_Data;          // data loaded from data memory
  
  // PE59
  output                                  oPE59_DMEM_Valid;
  output                                  oPE59_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE59_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE59_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE59_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE59_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE59_DMEM_EX_Data;          // data loaded from data memory
  
  // PE60
  output                                  oPE60_DMEM_Valid;
  output                                  oPE60_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE60_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE60_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE60_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE60_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE60_DMEM_EX_Data;          // data loaded from data memory
  
  // PE61
  output                                  oPE61_DMEM_Valid;
  output                                  oPE61_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE61_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE61_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE61_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE61_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE61_DMEM_EX_Data;          // data loaded from data memory
  
  // PE62
  output                                  oPE62_DMEM_Valid;
  output                                  oPE62_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE62_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE62_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE62_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE62_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE62_DMEM_EX_Data;          // data loaded from data memory
  
  // PE63
  output                                  oPE63_DMEM_Valid;
  output                                  oPE63_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE63_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE63_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE63_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE63_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE63_DMEM_EX_Data;          // data loaded from data memory
  
  // PE64
  output                                  oPE64_DMEM_Valid;
  output                                  oPE64_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE64_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE64_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE64_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE64_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE64_DMEM_EX_Data;          // data loaded from data memory
  
  // PE65
  output                                  oPE65_DMEM_Valid;
  output                                  oPE65_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE65_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE65_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE65_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE65_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE65_DMEM_EX_Data;          // data loaded from data memory
  
  // PE66
  output                                  oPE66_DMEM_Valid;
  output                                  oPE66_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE66_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE66_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE66_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE66_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE66_DMEM_EX_Data;          // data loaded from data memory
  
  // PE67
  output                                  oPE67_DMEM_Valid;
  output                                  oPE67_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE67_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE67_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE67_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE67_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE67_DMEM_EX_Data;          // data loaded from data memory
  
  // PE68
  output                                  oPE68_DMEM_Valid;
  output                                  oPE68_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE68_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE68_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE68_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE68_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE68_DMEM_EX_Data;          // data loaded from data memory
  
  // PE69
  output                                  oPE69_DMEM_Valid;
  output                                  oPE69_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE69_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE69_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE69_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE69_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE69_DMEM_EX_Data;          // data loaded from data memory
  
  // PE70
  output                                  oPE70_DMEM_Valid;
  output                                  oPE70_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE70_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE70_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE70_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE70_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE70_DMEM_EX_Data;          // data loaded from data memory
  
  // PE71
  output                                  oPE71_DMEM_Valid;
  output                                  oPE71_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE71_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE71_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE71_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE71_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE71_DMEM_EX_Data;          // data loaded from data memory
  
  // PE72
  output                                  oPE72_DMEM_Valid;
  output                                  oPE72_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE72_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE72_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE72_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE72_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE72_DMEM_EX_Data;          // data loaded from data memory
  
  // PE73
  output                                  oPE73_DMEM_Valid;
  output                                  oPE73_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE73_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE73_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE73_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE73_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE73_DMEM_EX_Data;          // data loaded from data memory
  
  // PE74
  output                                  oPE74_DMEM_Valid;
  output                                  oPE74_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE74_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE74_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE74_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE74_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE74_DMEM_EX_Data;          // data loaded from data memory
  
  // PE75
  output                                  oPE75_DMEM_Valid;
  output                                  oPE75_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE75_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE75_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE75_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE75_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE75_DMEM_EX_Data;          // data loaded from data memory
  
  // PE76
  output                                  oPE76_DMEM_Valid;
  output                                  oPE76_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE76_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE76_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE76_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE76_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE76_DMEM_EX_Data;          // data loaded from data memory
  
  // PE77
  output                                  oPE77_DMEM_Valid;
  output                                  oPE77_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE77_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE77_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE77_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE77_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE77_DMEM_EX_Data;          // data loaded from data memory
  
  // PE78
  output                                  oPE78_DMEM_Valid;
  output                                  oPE78_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE78_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE78_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE78_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE78_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE78_DMEM_EX_Data;          // data loaded from data memory
  
  // PE79
  output                                  oPE79_DMEM_Valid;
  output                                  oPE79_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE79_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE79_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE79_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE79_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE79_DMEM_EX_Data;          // data loaded from data memory
  
  // PE80
  output                                  oPE80_DMEM_Valid;
  output                                  oPE80_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE80_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE80_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE80_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE80_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE80_DMEM_EX_Data;          // data loaded from data memory
  
  // PE81
  output                                  oPE81_DMEM_Valid;
  output                                  oPE81_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE81_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE81_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE81_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE81_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE81_DMEM_EX_Data;          // data loaded from data memory
  
  // PE82
  output                                  oPE82_DMEM_Valid;
  output                                  oPE82_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE82_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE82_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE82_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE82_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE82_DMEM_EX_Data;          // data loaded from data memory
  
  // PE83
  output                                  oPE83_DMEM_Valid;
  output                                  oPE83_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE83_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE83_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE83_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE83_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE83_DMEM_EX_Data;          // data loaded from data memory
  
  // PE84
  output                                  oPE84_DMEM_Valid;
  output                                  oPE84_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE84_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE84_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE84_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE84_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE84_DMEM_EX_Data;          // data loaded from data memory
  
  // PE85
  output                                  oPE85_DMEM_Valid;
  output                                  oPE85_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE85_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE85_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE85_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE85_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE85_DMEM_EX_Data;          // data loaded from data memory
  
  // PE86
  output                                  oPE86_DMEM_Valid;
  output                                  oPE86_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE86_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE86_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE86_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE86_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE86_DMEM_EX_Data;          // data loaded from data memory
  
  // PE87
  output                                  oPE87_DMEM_Valid;
  output                                  oPE87_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE87_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE87_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE87_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE87_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE87_DMEM_EX_Data;          // data loaded from data memory
  
  // PE88
  output                                  oPE88_DMEM_Valid;
  output                                  oPE88_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE88_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE88_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE88_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE88_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE88_DMEM_EX_Data;          // data loaded from data memory
  
  // PE89
  output                                  oPE89_DMEM_Valid;
  output                                  oPE89_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE89_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE89_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE89_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE89_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE89_DMEM_EX_Data;          // data loaded from data memory
  
  // PE90
  output                                  oPE90_DMEM_Valid;
  output                                  oPE90_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE90_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE90_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE90_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE90_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE90_DMEM_EX_Data;          // data loaded from data memory
  
  // PE91
  output                                  oPE91_DMEM_Valid;
  output                                  oPE91_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE91_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE91_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE91_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE91_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE91_DMEM_EX_Data;          // data loaded from data memory
  
  // PE92
  output                                  oPE92_DMEM_Valid;
  output                                  oPE92_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE92_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE92_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE92_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE92_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE92_DMEM_EX_Data;          // data loaded from data memory
  
  // PE93
  output                                  oPE93_DMEM_Valid;
  output                                  oPE93_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE93_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE93_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE93_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE93_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE93_DMEM_EX_Data;          // data loaded from data memory
  
  // PE94
  output                                  oPE94_DMEM_Valid;
  output                                  oPE94_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE94_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE94_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE94_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE94_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE94_DMEM_EX_Data;          // data loaded from data memory
  
  // PE95
  output                                  oPE95_DMEM_Valid;
  output                                  oPE95_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE95_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE95_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE95_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE95_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE95_DMEM_EX_Data;          // data loaded from data memory
  
  // PE96
  output                                  oPE96_DMEM_Valid;
  output                                  oPE96_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE96_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE96_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE96_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE96_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE96_DMEM_EX_Data;          // data loaded from data memory
  
  // PE97
  output                                  oPE97_DMEM_Valid;
  output                                  oPE97_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE97_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE97_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE97_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE97_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE97_DMEM_EX_Data;          // data loaded from data memory
  
  // PE98
  output                                  oPE98_DMEM_Valid;
  output                                  oPE98_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE98_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE98_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE98_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE98_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE98_DMEM_EX_Data;          // data loaded from data memory
  
  // PE99
  output                                  oPE99_DMEM_Valid;
  output                                  oPE99_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE99_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE99_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE99_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE99_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE99_DMEM_EX_Data;          // data loaded from data memory
  
  // PE100
  output                                  oPE100_DMEM_Valid;
  output                                  oPE100_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE100_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE100_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE100_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE100_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE100_DMEM_EX_Data;          // data loaded from data memory
  
  // PE101
  output                                  oPE101_DMEM_Valid;
  output                                  oPE101_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE101_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE101_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE101_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE101_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE101_DMEM_EX_Data;          // data loaded from data memory
  
  // PE102
  output                                  oPE102_DMEM_Valid;
  output                                  oPE102_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE102_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE102_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE102_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE102_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE102_DMEM_EX_Data;          // data loaded from data memory
  
  // PE103
  output                                  oPE103_DMEM_Valid;
  output                                  oPE103_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE103_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE103_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE103_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE103_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE103_DMEM_EX_Data;          // data loaded from data memory
  
  // PE104
  output                                  oPE104_DMEM_Valid;
  output                                  oPE104_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE104_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE104_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE104_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE104_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE104_DMEM_EX_Data;          // data loaded from data memory
  
  // PE105
  output                                  oPE105_DMEM_Valid;
  output                                  oPE105_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE105_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE105_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE105_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE105_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE105_DMEM_EX_Data;          // data loaded from data memory
  
  // PE106
  output                                  oPE106_DMEM_Valid;
  output                                  oPE106_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE106_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE106_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE106_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE106_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE106_DMEM_EX_Data;          // data loaded from data memory
  
  // PE107
  output                                  oPE107_DMEM_Valid;
  output                                  oPE107_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE107_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE107_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE107_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE107_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE107_DMEM_EX_Data;          // data loaded from data memory
  
  // PE108
  output                                  oPE108_DMEM_Valid;
  output                                  oPE108_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE108_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE108_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE108_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE108_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE108_DMEM_EX_Data;          // data loaded from data memory
  
  // PE109
  output                                  oPE109_DMEM_Valid;
  output                                  oPE109_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE109_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE109_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE109_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE109_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE109_DMEM_EX_Data;          // data loaded from data memory
  
  // PE110
  output                                  oPE110_DMEM_Valid;
  output                                  oPE110_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE110_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE110_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE110_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE110_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE110_DMEM_EX_Data;          // data loaded from data memory
  
  // PE111
  output                                  oPE111_DMEM_Valid;
  output                                  oPE111_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE111_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE111_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE111_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE111_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE111_DMEM_EX_Data;          // data loaded from data memory
  
  // PE112
  output                                  oPE112_DMEM_Valid;
  output                                  oPE112_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE112_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE112_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE112_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE112_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE112_DMEM_EX_Data;          // data loaded from data memory
  
  // PE113
  output                                  oPE113_DMEM_Valid;
  output                                  oPE113_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE113_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE113_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE113_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE113_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE113_DMEM_EX_Data;          // data loaded from data memory
  
  // PE114
  output                                  oPE114_DMEM_Valid;
  output                                  oPE114_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE114_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE114_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE114_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE114_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE114_DMEM_EX_Data;          // data loaded from data memory
  
  // PE115
  output                                  oPE115_DMEM_Valid;
  output                                  oPE115_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE115_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE115_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE115_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE115_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE115_DMEM_EX_Data;          // data loaded from data memory
  
  // PE116
  output                                  oPE116_DMEM_Valid;
  output                                  oPE116_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE116_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE116_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE116_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE116_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE116_DMEM_EX_Data;          // data loaded from data memory
  
  // PE117
  output                                  oPE117_DMEM_Valid;
  output                                  oPE117_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE117_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE117_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE117_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE117_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE117_DMEM_EX_Data;          // data loaded from data memory
  
  // PE118
  output                                  oPE118_DMEM_Valid;
  output                                  oPE118_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE118_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE118_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE118_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE118_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE118_DMEM_EX_Data;          // data loaded from data memory
  
  // PE119
  output                                  oPE119_DMEM_Valid;
  output                                  oPE119_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE119_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE119_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE119_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE119_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE119_DMEM_EX_Data;          // data loaded from data memory
  
  // PE120
  output                                  oPE120_DMEM_Valid;
  output                                  oPE120_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE120_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE120_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE120_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE120_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE120_DMEM_EX_Data;          // data loaded from data memory
  
  // PE121
  output                                  oPE121_DMEM_Valid;
  output                                  oPE121_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE121_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE121_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE121_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE121_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE121_DMEM_EX_Data;          // data loaded from data memory
  
  // PE122
  output                                  oPE122_DMEM_Valid;
  output                                  oPE122_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE122_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE122_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE122_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE122_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE122_DMEM_EX_Data;          // data loaded from data memory
  
  // PE123
  output                                  oPE123_DMEM_Valid;
  output                                  oPE123_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE123_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE123_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE123_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE123_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE123_DMEM_EX_Data;          // data loaded from data memory
  
  // PE124
  output                                  oPE124_DMEM_Valid;
  output                                  oPE124_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE124_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE124_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE124_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE124_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE124_DMEM_EX_Data;          // data loaded from data memory
  
  // PE125
  output                                  oPE125_DMEM_Valid;
  output                                  oPE125_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE125_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE125_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE125_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE125_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE125_DMEM_EX_Data;          // data loaded from data memory
  
  // PE126
  output                                  oPE126_DMEM_Valid;
  output                                  oPE126_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE126_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE126_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE126_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE126_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE126_DMEM_EX_Data;          // data loaded from data memory
  
  // PE127
  output                                  oPE127_DMEM_Valid;
  output                                  oPE127_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE127_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE127_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE127_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE127_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE127_DMEM_EX_Data;          // data loaded from data memory
  

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
  
  // PE 8
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE8_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE8_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE8_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE8_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE8_AGU_DMEM_Addr_Last_Two;  
  
  // PE 9
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE9_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE9_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE9_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE9_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE9_AGU_DMEM_Addr_Last_Two;  
  
  // PE 10
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE10_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE10_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE10_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE10_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE10_AGU_DMEM_Addr_Last_Two;  
  
  // PE 11
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE11_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE11_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE11_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE11_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE11_AGU_DMEM_Addr_Last_Two;  
  
  // PE 12
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE12_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE12_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE12_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE12_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE12_AGU_DMEM_Addr_Last_Two;  
  
  // PE 13
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE13_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE13_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE13_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE13_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE13_AGU_DMEM_Addr_Last_Two;  
  
  // PE 14
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE14_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE14_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE14_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE14_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE14_AGU_DMEM_Addr_Last_Two;  
  
  // PE 15
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE15_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE15_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE15_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE15_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE15_AGU_DMEM_Addr_Last_Two;  
  
  // PE 16
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE16_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE16_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE16_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE16_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE16_AGU_DMEM_Addr_Last_Two;  
  
  // PE 17
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE17_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE17_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE17_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE17_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE17_AGU_DMEM_Addr_Last_Two;  
  
  // PE 18
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE18_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE18_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE18_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE18_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE18_AGU_DMEM_Addr_Last_Two;  
  
  // PE 19
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE19_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE19_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE19_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE19_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE19_AGU_DMEM_Addr_Last_Two;  
  
  // PE 20
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE20_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE20_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE20_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE20_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE20_AGU_DMEM_Addr_Last_Two;  
  
  // PE 21
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE21_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE21_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE21_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE21_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE21_AGU_DMEM_Addr_Last_Two;  
  
  // PE 22
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE22_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE22_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE22_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE22_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE22_AGU_DMEM_Addr_Last_Two;  
  
  // PE 23
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE23_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE23_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE23_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE23_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE23_AGU_DMEM_Addr_Last_Two;  
  
  // PE 24
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE24_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE24_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE24_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE24_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE24_AGU_DMEM_Addr_Last_Two;  
  
  // PE 25
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE25_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE25_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE25_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE25_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE25_AGU_DMEM_Addr_Last_Two;  
  
  // PE 26
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE26_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE26_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE26_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE26_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE26_AGU_DMEM_Addr_Last_Two;  
  
  // PE 27
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE27_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE27_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE27_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE27_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE27_AGU_DMEM_Addr_Last_Two;  
  
  // PE 28
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE28_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE28_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE28_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE28_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE28_AGU_DMEM_Addr_Last_Two;  
  
  // PE 29
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE29_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE29_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE29_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE29_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE29_AGU_DMEM_Addr_Last_Two;  
  
  // PE 30
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE30_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE30_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE30_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE30_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE30_AGU_DMEM_Addr_Last_Two;  
  
  // PE 31
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE31_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE31_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE31_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE31_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE31_AGU_DMEM_Addr_Last_Two;  
  
  // PE 32
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE32_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE32_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE32_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE32_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE32_AGU_DMEM_Addr_Last_Two;  
  
  // PE 33
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE33_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE33_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE33_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE33_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE33_AGU_DMEM_Addr_Last_Two;  
  
  // PE 34
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE34_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE34_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE34_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE34_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE34_AGU_DMEM_Addr_Last_Two;  
  
  // PE 35
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE35_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE35_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE35_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE35_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE35_AGU_DMEM_Addr_Last_Two;  
  
  // PE 36
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE36_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE36_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE36_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE36_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE36_AGU_DMEM_Addr_Last_Two;  
  
  // PE 37
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE37_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE37_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE37_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE37_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE37_AGU_DMEM_Addr_Last_Two;  
  
  // PE 38
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE38_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE38_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE38_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE38_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE38_AGU_DMEM_Addr_Last_Two;  
  
  // PE 39
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE39_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE39_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE39_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE39_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE39_AGU_DMEM_Addr_Last_Two;  
  
  // PE 40
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE40_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE40_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE40_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE40_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE40_AGU_DMEM_Addr_Last_Two;  
  
  // PE 41
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE41_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE41_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE41_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE41_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE41_AGU_DMEM_Addr_Last_Two;  
  
  // PE 42
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE42_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE42_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE42_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE42_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE42_AGU_DMEM_Addr_Last_Two;  
  
  // PE 43
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE43_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE43_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE43_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE43_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE43_AGU_DMEM_Addr_Last_Two;  
  
  // PE 44
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE44_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE44_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE44_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE44_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE44_AGU_DMEM_Addr_Last_Two;  
  
  // PE 45
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE45_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE45_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE45_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE45_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE45_AGU_DMEM_Addr_Last_Two;  
  
  // PE 46
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE46_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE46_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE46_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE46_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE46_AGU_DMEM_Addr_Last_Two;  
  
  // PE 47
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE47_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE47_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE47_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE47_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE47_AGU_DMEM_Addr_Last_Two;  
  
  // PE 48
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE48_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE48_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE48_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE48_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE48_AGU_DMEM_Addr_Last_Two;  
  
  // PE 49
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE49_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE49_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE49_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE49_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE49_AGU_DMEM_Addr_Last_Two;  
  
  // PE 50
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE50_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE50_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE50_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE50_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE50_AGU_DMEM_Addr_Last_Two;  
  
  // PE 51
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE51_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE51_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE51_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE51_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE51_AGU_DMEM_Addr_Last_Two;  
  
  // PE 52
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE52_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE52_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE52_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE52_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE52_AGU_DMEM_Addr_Last_Two;  
  
  // PE 53
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE53_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE53_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE53_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE53_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE53_AGU_DMEM_Addr_Last_Two;  
  
  // PE 54
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE54_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE54_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE54_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE54_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE54_AGU_DMEM_Addr_Last_Two;  
  
  // PE 55
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE55_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE55_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE55_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE55_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE55_AGU_DMEM_Addr_Last_Two;  
  
  // PE 56
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE56_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE56_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE56_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE56_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE56_AGU_DMEM_Addr_Last_Two;  
  
  // PE 57
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE57_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE57_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE57_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE57_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE57_AGU_DMEM_Addr_Last_Two;  
  
  // PE 58
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE58_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE58_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE58_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE58_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE58_AGU_DMEM_Addr_Last_Two;  
  
  // PE 59
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE59_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE59_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE59_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE59_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE59_AGU_DMEM_Addr_Last_Two;  
  
  // PE 60
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE60_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE60_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE60_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE60_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE60_AGU_DMEM_Addr_Last_Two;  
  
  // PE 61
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE61_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE61_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE61_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE61_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE61_AGU_DMEM_Addr_Last_Two;  
  
  // PE 62
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE62_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE62_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE62_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE62_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE62_AGU_DMEM_Addr_Last_Two;  
  
  // PE 63
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE63_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE63_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE63_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE63_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE63_AGU_DMEM_Addr_Last_Two;  
  
  // PE 64
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE64_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE64_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE64_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE64_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE64_AGU_DMEM_Addr_Last_Two;  
  
  // PE 65
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE65_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE65_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE65_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE65_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE65_AGU_DMEM_Addr_Last_Two;  
  
  // PE 66
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE66_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE66_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE66_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE66_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE66_AGU_DMEM_Addr_Last_Two;  
  
  // PE 67
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE67_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE67_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE67_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE67_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE67_AGU_DMEM_Addr_Last_Two;  
  
  // PE 68
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE68_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE68_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE68_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE68_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE68_AGU_DMEM_Addr_Last_Two;  
  
  // PE 69
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE69_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE69_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE69_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE69_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE69_AGU_DMEM_Addr_Last_Two;  
  
  // PE 70
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE70_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE70_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE70_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE70_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE70_AGU_DMEM_Addr_Last_Two;  
  
  // PE 71
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE71_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE71_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE71_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE71_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE71_AGU_DMEM_Addr_Last_Two;  
  
  // PE 72
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE72_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE72_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE72_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE72_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE72_AGU_DMEM_Addr_Last_Two;  
  
  // PE 73
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE73_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE73_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE73_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE73_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE73_AGU_DMEM_Addr_Last_Two;  
  
  // PE 74
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE74_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE74_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE74_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE74_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE74_AGU_DMEM_Addr_Last_Two;  
  
  // PE 75
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE75_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE75_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE75_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE75_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE75_AGU_DMEM_Addr_Last_Two;  
  
  // PE 76
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE76_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE76_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE76_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE76_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE76_AGU_DMEM_Addr_Last_Two;  
  
  // PE 77
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE77_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE77_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE77_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE77_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE77_AGU_DMEM_Addr_Last_Two;  
  
  // PE 78
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE78_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE78_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE78_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE78_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE78_AGU_DMEM_Addr_Last_Two;  
  
  // PE 79
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE79_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE79_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE79_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE79_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE79_AGU_DMEM_Addr_Last_Two;  
  
  // PE 80
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE80_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE80_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE80_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE80_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE80_AGU_DMEM_Addr_Last_Two;  
  
  // PE 81
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE81_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE81_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE81_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE81_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE81_AGU_DMEM_Addr_Last_Two;  
  
  // PE 82
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE82_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE82_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE82_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE82_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE82_AGU_DMEM_Addr_Last_Two;  
  
  // PE 83
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE83_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE83_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE83_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE83_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE83_AGU_DMEM_Addr_Last_Two;  
  
  // PE 84
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE84_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE84_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE84_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE84_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE84_AGU_DMEM_Addr_Last_Two;  
  
  // PE 85
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE85_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE85_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE85_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE85_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE85_AGU_DMEM_Addr_Last_Two;  
  
  // PE 86
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE86_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE86_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE86_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE86_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE86_AGU_DMEM_Addr_Last_Two;  
  
  // PE 87
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE87_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE87_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE87_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE87_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE87_AGU_DMEM_Addr_Last_Two;  
  
  // PE 88
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE88_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE88_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE88_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE88_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE88_AGU_DMEM_Addr_Last_Two;  
  
  // PE 89
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE89_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE89_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE89_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE89_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE89_AGU_DMEM_Addr_Last_Two;  
  
  // PE 90
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE90_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE90_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE90_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE90_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE90_AGU_DMEM_Addr_Last_Two;  
  
  // PE 91
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE91_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE91_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE91_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE91_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE91_AGU_DMEM_Addr_Last_Two;  
  
  // PE 92
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE92_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE92_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE92_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE92_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE92_AGU_DMEM_Addr_Last_Two;  
  
  // PE 93
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE93_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE93_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE93_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE93_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE93_AGU_DMEM_Addr_Last_Two;  
  
  // PE 94
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE94_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE94_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE94_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE94_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE94_AGU_DMEM_Addr_Last_Two;  
  
  // PE 95
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE95_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE95_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE95_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE95_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE95_AGU_DMEM_Addr_Last_Two;  
  
  // PE 96
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE96_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE96_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE96_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE96_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE96_AGU_DMEM_Addr_Last_Two;  
  
  // PE 97
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE97_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE97_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE97_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE97_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE97_AGU_DMEM_Addr_Last_Two;  
  
  // PE 98
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE98_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE98_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE98_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE98_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE98_AGU_DMEM_Addr_Last_Two;  
  
  // PE 99
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE99_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE99_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE99_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE99_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE99_AGU_DMEM_Addr_Last_Two;  
  
  // PE 100
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE100_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE100_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE100_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE100_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE100_AGU_DMEM_Addr_Last_Two;  
  
  // PE 101
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE101_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE101_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE101_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE101_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE101_AGU_DMEM_Addr_Last_Two;  
  
  // PE 102
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE102_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE102_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE102_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE102_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE102_AGU_DMEM_Addr_Last_Two;  
  
  // PE 103
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE103_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE103_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE103_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE103_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE103_AGU_DMEM_Addr_Last_Two;  
  
  // PE 104
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE104_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE104_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE104_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE104_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE104_AGU_DMEM_Addr_Last_Two;  
  
  // PE 105
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE105_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE105_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE105_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE105_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE105_AGU_DMEM_Addr_Last_Two;  
  
  // PE 106
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE106_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE106_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE106_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE106_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE106_AGU_DMEM_Addr_Last_Two;  
  
  // PE 107
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE107_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE107_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE107_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE107_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE107_AGU_DMEM_Addr_Last_Two;  
  
  // PE 108
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE108_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE108_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE108_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE108_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE108_AGU_DMEM_Addr_Last_Two;  
  
  // PE 109
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE109_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE109_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE109_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE109_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE109_AGU_DMEM_Addr_Last_Two;  
  
  // PE 110
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE110_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE110_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE110_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE110_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE110_AGU_DMEM_Addr_Last_Two;  
  
  // PE 111
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE111_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE111_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE111_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE111_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE111_AGU_DMEM_Addr_Last_Two;  
  
  // PE 112
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE112_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE112_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE112_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE112_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE112_AGU_DMEM_Addr_Last_Two;  
  
  // PE 113
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE113_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE113_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE113_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE113_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE113_AGU_DMEM_Addr_Last_Two;  
  
  // PE 114
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE114_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE114_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE114_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE114_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE114_AGU_DMEM_Addr_Last_Two;  
  
  // PE 115
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE115_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE115_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE115_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE115_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE115_AGU_DMEM_Addr_Last_Two;  
  
  // PE 116
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE116_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE116_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE116_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE116_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE116_AGU_DMEM_Addr_Last_Two;  
  
  // PE 117
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE117_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE117_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE117_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE117_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE117_AGU_DMEM_Addr_Last_Two;  
  
  // PE 118
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE118_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE118_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE118_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE118_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE118_AGU_DMEM_Addr_Last_Two;  
  
  // PE 119
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE119_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE119_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE119_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE119_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE119_AGU_DMEM_Addr_Last_Two;  
  
  // PE 120
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE120_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE120_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE120_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE120_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE120_AGU_DMEM_Addr_Last_Two;  
  
  // PE 121
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE121_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE121_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE121_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE121_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE121_AGU_DMEM_Addr_Last_Two;  
  
  // PE 122
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE122_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE122_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE122_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE122_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE122_AGU_DMEM_Addr_Last_Two;  
  
  // PE 123
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE123_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE123_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE123_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE123_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE123_AGU_DMEM_Addr_Last_Two;  
  
  // PE 124
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE124_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE124_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE124_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE124_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE124_AGU_DMEM_Addr_Last_Two;  
  
  // PE 125
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE125_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE125_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE125_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE125_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE125_AGU_DMEM_Addr_Last_Two;  
  
  // PE 126
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE126_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE126_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE126_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE126_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE126_AGU_DMEM_Addr_Last_Two;  
  
  // PE 127
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE127_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE127_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE127_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE127_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE127_AGU_DMEM_Addr_Last_Two;  
  

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
  
  // PE 8
  assign oPE8_DMEM_Valid       = oPE8_AGU_DMEM_Write_Enable || oPE8_AGU_DMEM_Read_Enable;
  assign oPE8_AGU_DMEM_Address = wPE8_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE8_AGU_DMEM_Opcode        <= 'b0;
        PR_PE8_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE8_AGU_DMEM_Read_Enable )
      begin
        PR_PE8_AGU_DMEM_Opcode        <= wPE8_AGU_DMEM_Opcode;
        PR_PE8_AGU_DMEM_Addr_Last_Two <= wPE8_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE8_AGU_DMEM_Opcode or PR_PE8_AGU_DMEM_Addr_Last_Two or iPE8_DMEM_EX_Data )
    case ( PR_PE8_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE8_DMEM_EX_Data = iPE8_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE8_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE8_DMEM_EX_Data = {16'b0, iPE8_DMEM_EX_Data[15:0]};
        else
          wPE8_DMEM_EX_Data = {16'b0, iPE8_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE8_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE8_DMEM_EX_Data = {24'b0, iPE8_DMEM_EX_Data[7 : 0]};
          2'b01: wPE8_DMEM_EX_Data = {24'b0, iPE8_DMEM_EX_Data[15: 8]};
          2'b10: wPE8_DMEM_EX_Data = {24'b0, iPE8_DMEM_EX_Data[23:16]};
          2'b11: wPE8_DMEM_EX_Data = {24'b0, iPE8_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE8_DMEM_EX_Data = iPE8_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 9
  assign oPE9_DMEM_Valid       = oPE9_AGU_DMEM_Write_Enable || oPE9_AGU_DMEM_Read_Enable;
  assign oPE9_AGU_DMEM_Address = wPE9_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE9_AGU_DMEM_Opcode        <= 'b0;
        PR_PE9_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE9_AGU_DMEM_Read_Enable )
      begin
        PR_PE9_AGU_DMEM_Opcode        <= wPE9_AGU_DMEM_Opcode;
        PR_PE9_AGU_DMEM_Addr_Last_Two <= wPE9_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE9_AGU_DMEM_Opcode or PR_PE9_AGU_DMEM_Addr_Last_Two or iPE9_DMEM_EX_Data )
    case ( PR_PE9_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE9_DMEM_EX_Data = iPE9_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE9_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE9_DMEM_EX_Data = {16'b0, iPE9_DMEM_EX_Data[15:0]};
        else
          wPE9_DMEM_EX_Data = {16'b0, iPE9_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE9_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE9_DMEM_EX_Data = {24'b0, iPE9_DMEM_EX_Data[7 : 0]};
          2'b01: wPE9_DMEM_EX_Data = {24'b0, iPE9_DMEM_EX_Data[15: 8]};
          2'b10: wPE9_DMEM_EX_Data = {24'b0, iPE9_DMEM_EX_Data[23:16]};
          2'b11: wPE9_DMEM_EX_Data = {24'b0, iPE9_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE9_DMEM_EX_Data = iPE9_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 10
  assign oPE10_DMEM_Valid       = oPE10_AGU_DMEM_Write_Enable || oPE10_AGU_DMEM_Read_Enable;
  assign oPE10_AGU_DMEM_Address = wPE10_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE10_AGU_DMEM_Opcode        <= 'b0;
        PR_PE10_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE10_AGU_DMEM_Read_Enable )
      begin
        PR_PE10_AGU_DMEM_Opcode        <= wPE10_AGU_DMEM_Opcode;
        PR_PE10_AGU_DMEM_Addr_Last_Two <= wPE10_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE10_AGU_DMEM_Opcode or PR_PE10_AGU_DMEM_Addr_Last_Two or iPE10_DMEM_EX_Data )
    case ( PR_PE10_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE10_DMEM_EX_Data = iPE10_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE10_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE10_DMEM_EX_Data = {16'b0, iPE10_DMEM_EX_Data[15:0]};
        else
          wPE10_DMEM_EX_Data = {16'b0, iPE10_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE10_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE10_DMEM_EX_Data = {24'b0, iPE10_DMEM_EX_Data[7 : 0]};
          2'b01: wPE10_DMEM_EX_Data = {24'b0, iPE10_DMEM_EX_Data[15: 8]};
          2'b10: wPE10_DMEM_EX_Data = {24'b0, iPE10_DMEM_EX_Data[23:16]};
          2'b11: wPE10_DMEM_EX_Data = {24'b0, iPE10_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE10_DMEM_EX_Data = iPE10_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 11
  assign oPE11_DMEM_Valid       = oPE11_AGU_DMEM_Write_Enable || oPE11_AGU_DMEM_Read_Enable;
  assign oPE11_AGU_DMEM_Address = wPE11_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE11_AGU_DMEM_Opcode        <= 'b0;
        PR_PE11_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE11_AGU_DMEM_Read_Enable )
      begin
        PR_PE11_AGU_DMEM_Opcode        <= wPE11_AGU_DMEM_Opcode;
        PR_PE11_AGU_DMEM_Addr_Last_Two <= wPE11_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE11_AGU_DMEM_Opcode or PR_PE11_AGU_DMEM_Addr_Last_Two or iPE11_DMEM_EX_Data )
    case ( PR_PE11_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE11_DMEM_EX_Data = iPE11_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE11_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE11_DMEM_EX_Data = {16'b0, iPE11_DMEM_EX_Data[15:0]};
        else
          wPE11_DMEM_EX_Data = {16'b0, iPE11_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE11_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE11_DMEM_EX_Data = {24'b0, iPE11_DMEM_EX_Data[7 : 0]};
          2'b01: wPE11_DMEM_EX_Data = {24'b0, iPE11_DMEM_EX_Data[15: 8]};
          2'b10: wPE11_DMEM_EX_Data = {24'b0, iPE11_DMEM_EX_Data[23:16]};
          2'b11: wPE11_DMEM_EX_Data = {24'b0, iPE11_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE11_DMEM_EX_Data = iPE11_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 12
  assign oPE12_DMEM_Valid       = oPE12_AGU_DMEM_Write_Enable || oPE12_AGU_DMEM_Read_Enable;
  assign oPE12_AGU_DMEM_Address = wPE12_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE12_AGU_DMEM_Opcode        <= 'b0;
        PR_PE12_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE12_AGU_DMEM_Read_Enable )
      begin
        PR_PE12_AGU_DMEM_Opcode        <= wPE12_AGU_DMEM_Opcode;
        PR_PE12_AGU_DMEM_Addr_Last_Two <= wPE12_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE12_AGU_DMEM_Opcode or PR_PE12_AGU_DMEM_Addr_Last_Two or iPE12_DMEM_EX_Data )
    case ( PR_PE12_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE12_DMEM_EX_Data = iPE12_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE12_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE12_DMEM_EX_Data = {16'b0, iPE12_DMEM_EX_Data[15:0]};
        else
          wPE12_DMEM_EX_Data = {16'b0, iPE12_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE12_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE12_DMEM_EX_Data = {24'b0, iPE12_DMEM_EX_Data[7 : 0]};
          2'b01: wPE12_DMEM_EX_Data = {24'b0, iPE12_DMEM_EX_Data[15: 8]};
          2'b10: wPE12_DMEM_EX_Data = {24'b0, iPE12_DMEM_EX_Data[23:16]};
          2'b11: wPE12_DMEM_EX_Data = {24'b0, iPE12_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE12_DMEM_EX_Data = iPE12_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 13
  assign oPE13_DMEM_Valid       = oPE13_AGU_DMEM_Write_Enable || oPE13_AGU_DMEM_Read_Enable;
  assign oPE13_AGU_DMEM_Address = wPE13_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE13_AGU_DMEM_Opcode        <= 'b0;
        PR_PE13_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE13_AGU_DMEM_Read_Enable )
      begin
        PR_PE13_AGU_DMEM_Opcode        <= wPE13_AGU_DMEM_Opcode;
        PR_PE13_AGU_DMEM_Addr_Last_Two <= wPE13_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE13_AGU_DMEM_Opcode or PR_PE13_AGU_DMEM_Addr_Last_Two or iPE13_DMEM_EX_Data )
    case ( PR_PE13_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE13_DMEM_EX_Data = iPE13_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE13_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE13_DMEM_EX_Data = {16'b0, iPE13_DMEM_EX_Data[15:0]};
        else
          wPE13_DMEM_EX_Data = {16'b0, iPE13_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE13_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE13_DMEM_EX_Data = {24'b0, iPE13_DMEM_EX_Data[7 : 0]};
          2'b01: wPE13_DMEM_EX_Data = {24'b0, iPE13_DMEM_EX_Data[15: 8]};
          2'b10: wPE13_DMEM_EX_Data = {24'b0, iPE13_DMEM_EX_Data[23:16]};
          2'b11: wPE13_DMEM_EX_Data = {24'b0, iPE13_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE13_DMEM_EX_Data = iPE13_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 14
  assign oPE14_DMEM_Valid       = oPE14_AGU_DMEM_Write_Enable || oPE14_AGU_DMEM_Read_Enable;
  assign oPE14_AGU_DMEM_Address = wPE14_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE14_AGU_DMEM_Opcode        <= 'b0;
        PR_PE14_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE14_AGU_DMEM_Read_Enable )
      begin
        PR_PE14_AGU_DMEM_Opcode        <= wPE14_AGU_DMEM_Opcode;
        PR_PE14_AGU_DMEM_Addr_Last_Two <= wPE14_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE14_AGU_DMEM_Opcode or PR_PE14_AGU_DMEM_Addr_Last_Two or iPE14_DMEM_EX_Data )
    case ( PR_PE14_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE14_DMEM_EX_Data = iPE14_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE14_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE14_DMEM_EX_Data = {16'b0, iPE14_DMEM_EX_Data[15:0]};
        else
          wPE14_DMEM_EX_Data = {16'b0, iPE14_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE14_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE14_DMEM_EX_Data = {24'b0, iPE14_DMEM_EX_Data[7 : 0]};
          2'b01: wPE14_DMEM_EX_Data = {24'b0, iPE14_DMEM_EX_Data[15: 8]};
          2'b10: wPE14_DMEM_EX_Data = {24'b0, iPE14_DMEM_EX_Data[23:16]};
          2'b11: wPE14_DMEM_EX_Data = {24'b0, iPE14_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE14_DMEM_EX_Data = iPE14_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 15
  assign oPE15_DMEM_Valid       = oPE15_AGU_DMEM_Write_Enable || oPE15_AGU_DMEM_Read_Enable;
  assign oPE15_AGU_DMEM_Address = wPE15_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE15_AGU_DMEM_Opcode        <= 'b0;
        PR_PE15_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE15_AGU_DMEM_Read_Enable )
      begin
        PR_PE15_AGU_DMEM_Opcode        <= wPE15_AGU_DMEM_Opcode;
        PR_PE15_AGU_DMEM_Addr_Last_Two <= wPE15_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE15_AGU_DMEM_Opcode or PR_PE15_AGU_DMEM_Addr_Last_Two or iPE15_DMEM_EX_Data )
    case ( PR_PE15_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE15_DMEM_EX_Data = iPE15_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE15_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE15_DMEM_EX_Data = {16'b0, iPE15_DMEM_EX_Data[15:0]};
        else
          wPE15_DMEM_EX_Data = {16'b0, iPE15_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE15_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE15_DMEM_EX_Data = {24'b0, iPE15_DMEM_EX_Data[7 : 0]};
          2'b01: wPE15_DMEM_EX_Data = {24'b0, iPE15_DMEM_EX_Data[15: 8]};
          2'b10: wPE15_DMEM_EX_Data = {24'b0, iPE15_DMEM_EX_Data[23:16]};
          2'b11: wPE15_DMEM_EX_Data = {24'b0, iPE15_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE15_DMEM_EX_Data = iPE15_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 16
  assign oPE16_DMEM_Valid       = oPE16_AGU_DMEM_Write_Enable || oPE16_AGU_DMEM_Read_Enable;
  assign oPE16_AGU_DMEM_Address = wPE16_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE16_AGU_DMEM_Opcode        <= 'b0;
        PR_PE16_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE16_AGU_DMEM_Read_Enable )
      begin
        PR_PE16_AGU_DMEM_Opcode        <= wPE16_AGU_DMEM_Opcode;
        PR_PE16_AGU_DMEM_Addr_Last_Two <= wPE16_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE16_AGU_DMEM_Opcode or PR_PE16_AGU_DMEM_Addr_Last_Two or iPE16_DMEM_EX_Data )
    case ( PR_PE16_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE16_DMEM_EX_Data = iPE16_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE16_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE16_DMEM_EX_Data = {16'b0, iPE16_DMEM_EX_Data[15:0]};
        else
          wPE16_DMEM_EX_Data = {16'b0, iPE16_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE16_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE16_DMEM_EX_Data = {24'b0, iPE16_DMEM_EX_Data[7 : 0]};
          2'b01: wPE16_DMEM_EX_Data = {24'b0, iPE16_DMEM_EX_Data[15: 8]};
          2'b10: wPE16_DMEM_EX_Data = {24'b0, iPE16_DMEM_EX_Data[23:16]};
          2'b11: wPE16_DMEM_EX_Data = {24'b0, iPE16_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE16_DMEM_EX_Data = iPE16_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 17
  assign oPE17_DMEM_Valid       = oPE17_AGU_DMEM_Write_Enable || oPE17_AGU_DMEM_Read_Enable;
  assign oPE17_AGU_DMEM_Address = wPE17_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE17_AGU_DMEM_Opcode        <= 'b0;
        PR_PE17_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE17_AGU_DMEM_Read_Enable )
      begin
        PR_PE17_AGU_DMEM_Opcode        <= wPE17_AGU_DMEM_Opcode;
        PR_PE17_AGU_DMEM_Addr_Last_Two <= wPE17_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE17_AGU_DMEM_Opcode or PR_PE17_AGU_DMEM_Addr_Last_Two or iPE17_DMEM_EX_Data )
    case ( PR_PE17_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE17_DMEM_EX_Data = iPE17_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE17_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE17_DMEM_EX_Data = {16'b0, iPE17_DMEM_EX_Data[15:0]};
        else
          wPE17_DMEM_EX_Data = {16'b0, iPE17_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE17_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE17_DMEM_EX_Data = {24'b0, iPE17_DMEM_EX_Data[7 : 0]};
          2'b01: wPE17_DMEM_EX_Data = {24'b0, iPE17_DMEM_EX_Data[15: 8]};
          2'b10: wPE17_DMEM_EX_Data = {24'b0, iPE17_DMEM_EX_Data[23:16]};
          2'b11: wPE17_DMEM_EX_Data = {24'b0, iPE17_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE17_DMEM_EX_Data = iPE17_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 18
  assign oPE18_DMEM_Valid       = oPE18_AGU_DMEM_Write_Enable || oPE18_AGU_DMEM_Read_Enable;
  assign oPE18_AGU_DMEM_Address = wPE18_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE18_AGU_DMEM_Opcode        <= 'b0;
        PR_PE18_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE18_AGU_DMEM_Read_Enable )
      begin
        PR_PE18_AGU_DMEM_Opcode        <= wPE18_AGU_DMEM_Opcode;
        PR_PE18_AGU_DMEM_Addr_Last_Two <= wPE18_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE18_AGU_DMEM_Opcode or PR_PE18_AGU_DMEM_Addr_Last_Two or iPE18_DMEM_EX_Data )
    case ( PR_PE18_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE18_DMEM_EX_Data = iPE18_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE18_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE18_DMEM_EX_Data = {16'b0, iPE18_DMEM_EX_Data[15:0]};
        else
          wPE18_DMEM_EX_Data = {16'b0, iPE18_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE18_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE18_DMEM_EX_Data = {24'b0, iPE18_DMEM_EX_Data[7 : 0]};
          2'b01: wPE18_DMEM_EX_Data = {24'b0, iPE18_DMEM_EX_Data[15: 8]};
          2'b10: wPE18_DMEM_EX_Data = {24'b0, iPE18_DMEM_EX_Data[23:16]};
          2'b11: wPE18_DMEM_EX_Data = {24'b0, iPE18_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE18_DMEM_EX_Data = iPE18_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 19
  assign oPE19_DMEM_Valid       = oPE19_AGU_DMEM_Write_Enable || oPE19_AGU_DMEM_Read_Enable;
  assign oPE19_AGU_DMEM_Address = wPE19_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE19_AGU_DMEM_Opcode        <= 'b0;
        PR_PE19_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE19_AGU_DMEM_Read_Enable )
      begin
        PR_PE19_AGU_DMEM_Opcode        <= wPE19_AGU_DMEM_Opcode;
        PR_PE19_AGU_DMEM_Addr_Last_Two <= wPE19_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE19_AGU_DMEM_Opcode or PR_PE19_AGU_DMEM_Addr_Last_Two or iPE19_DMEM_EX_Data )
    case ( PR_PE19_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE19_DMEM_EX_Data = iPE19_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE19_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE19_DMEM_EX_Data = {16'b0, iPE19_DMEM_EX_Data[15:0]};
        else
          wPE19_DMEM_EX_Data = {16'b0, iPE19_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE19_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE19_DMEM_EX_Data = {24'b0, iPE19_DMEM_EX_Data[7 : 0]};
          2'b01: wPE19_DMEM_EX_Data = {24'b0, iPE19_DMEM_EX_Data[15: 8]};
          2'b10: wPE19_DMEM_EX_Data = {24'b0, iPE19_DMEM_EX_Data[23:16]};
          2'b11: wPE19_DMEM_EX_Data = {24'b0, iPE19_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE19_DMEM_EX_Data = iPE19_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 20
  assign oPE20_DMEM_Valid       = oPE20_AGU_DMEM_Write_Enable || oPE20_AGU_DMEM_Read_Enable;
  assign oPE20_AGU_DMEM_Address = wPE20_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE20_AGU_DMEM_Opcode        <= 'b0;
        PR_PE20_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE20_AGU_DMEM_Read_Enable )
      begin
        PR_PE20_AGU_DMEM_Opcode        <= wPE20_AGU_DMEM_Opcode;
        PR_PE20_AGU_DMEM_Addr_Last_Two <= wPE20_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE20_AGU_DMEM_Opcode or PR_PE20_AGU_DMEM_Addr_Last_Two or iPE20_DMEM_EX_Data )
    case ( PR_PE20_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE20_DMEM_EX_Data = iPE20_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE20_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE20_DMEM_EX_Data = {16'b0, iPE20_DMEM_EX_Data[15:0]};
        else
          wPE20_DMEM_EX_Data = {16'b0, iPE20_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE20_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE20_DMEM_EX_Data = {24'b0, iPE20_DMEM_EX_Data[7 : 0]};
          2'b01: wPE20_DMEM_EX_Data = {24'b0, iPE20_DMEM_EX_Data[15: 8]};
          2'b10: wPE20_DMEM_EX_Data = {24'b0, iPE20_DMEM_EX_Data[23:16]};
          2'b11: wPE20_DMEM_EX_Data = {24'b0, iPE20_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE20_DMEM_EX_Data = iPE20_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 21
  assign oPE21_DMEM_Valid       = oPE21_AGU_DMEM_Write_Enable || oPE21_AGU_DMEM_Read_Enable;
  assign oPE21_AGU_DMEM_Address = wPE21_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE21_AGU_DMEM_Opcode        <= 'b0;
        PR_PE21_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE21_AGU_DMEM_Read_Enable )
      begin
        PR_PE21_AGU_DMEM_Opcode        <= wPE21_AGU_DMEM_Opcode;
        PR_PE21_AGU_DMEM_Addr_Last_Two <= wPE21_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE21_AGU_DMEM_Opcode or PR_PE21_AGU_DMEM_Addr_Last_Two or iPE21_DMEM_EX_Data )
    case ( PR_PE21_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE21_DMEM_EX_Data = iPE21_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE21_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE21_DMEM_EX_Data = {16'b0, iPE21_DMEM_EX_Data[15:0]};
        else
          wPE21_DMEM_EX_Data = {16'b0, iPE21_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE21_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE21_DMEM_EX_Data = {24'b0, iPE21_DMEM_EX_Data[7 : 0]};
          2'b01: wPE21_DMEM_EX_Data = {24'b0, iPE21_DMEM_EX_Data[15: 8]};
          2'b10: wPE21_DMEM_EX_Data = {24'b0, iPE21_DMEM_EX_Data[23:16]};
          2'b11: wPE21_DMEM_EX_Data = {24'b0, iPE21_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE21_DMEM_EX_Data = iPE21_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 22
  assign oPE22_DMEM_Valid       = oPE22_AGU_DMEM_Write_Enable || oPE22_AGU_DMEM_Read_Enable;
  assign oPE22_AGU_DMEM_Address = wPE22_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE22_AGU_DMEM_Opcode        <= 'b0;
        PR_PE22_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE22_AGU_DMEM_Read_Enable )
      begin
        PR_PE22_AGU_DMEM_Opcode        <= wPE22_AGU_DMEM_Opcode;
        PR_PE22_AGU_DMEM_Addr_Last_Two <= wPE22_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE22_AGU_DMEM_Opcode or PR_PE22_AGU_DMEM_Addr_Last_Two or iPE22_DMEM_EX_Data )
    case ( PR_PE22_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE22_DMEM_EX_Data = iPE22_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE22_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE22_DMEM_EX_Data = {16'b0, iPE22_DMEM_EX_Data[15:0]};
        else
          wPE22_DMEM_EX_Data = {16'b0, iPE22_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE22_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE22_DMEM_EX_Data = {24'b0, iPE22_DMEM_EX_Data[7 : 0]};
          2'b01: wPE22_DMEM_EX_Data = {24'b0, iPE22_DMEM_EX_Data[15: 8]};
          2'b10: wPE22_DMEM_EX_Data = {24'b0, iPE22_DMEM_EX_Data[23:16]};
          2'b11: wPE22_DMEM_EX_Data = {24'b0, iPE22_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE22_DMEM_EX_Data = iPE22_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 23
  assign oPE23_DMEM_Valid       = oPE23_AGU_DMEM_Write_Enable || oPE23_AGU_DMEM_Read_Enable;
  assign oPE23_AGU_DMEM_Address = wPE23_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE23_AGU_DMEM_Opcode        <= 'b0;
        PR_PE23_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE23_AGU_DMEM_Read_Enable )
      begin
        PR_PE23_AGU_DMEM_Opcode        <= wPE23_AGU_DMEM_Opcode;
        PR_PE23_AGU_DMEM_Addr_Last_Two <= wPE23_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE23_AGU_DMEM_Opcode or PR_PE23_AGU_DMEM_Addr_Last_Two or iPE23_DMEM_EX_Data )
    case ( PR_PE23_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE23_DMEM_EX_Data = iPE23_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE23_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE23_DMEM_EX_Data = {16'b0, iPE23_DMEM_EX_Data[15:0]};
        else
          wPE23_DMEM_EX_Data = {16'b0, iPE23_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE23_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE23_DMEM_EX_Data = {24'b0, iPE23_DMEM_EX_Data[7 : 0]};
          2'b01: wPE23_DMEM_EX_Data = {24'b0, iPE23_DMEM_EX_Data[15: 8]};
          2'b10: wPE23_DMEM_EX_Data = {24'b0, iPE23_DMEM_EX_Data[23:16]};
          2'b11: wPE23_DMEM_EX_Data = {24'b0, iPE23_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE23_DMEM_EX_Data = iPE23_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 24
  assign oPE24_DMEM_Valid       = oPE24_AGU_DMEM_Write_Enable || oPE24_AGU_DMEM_Read_Enable;
  assign oPE24_AGU_DMEM_Address = wPE24_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE24_AGU_DMEM_Opcode        <= 'b0;
        PR_PE24_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE24_AGU_DMEM_Read_Enable )
      begin
        PR_PE24_AGU_DMEM_Opcode        <= wPE24_AGU_DMEM_Opcode;
        PR_PE24_AGU_DMEM_Addr_Last_Two <= wPE24_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE24_AGU_DMEM_Opcode or PR_PE24_AGU_DMEM_Addr_Last_Two or iPE24_DMEM_EX_Data )
    case ( PR_PE24_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE24_DMEM_EX_Data = iPE24_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE24_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE24_DMEM_EX_Data = {16'b0, iPE24_DMEM_EX_Data[15:0]};
        else
          wPE24_DMEM_EX_Data = {16'b0, iPE24_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE24_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE24_DMEM_EX_Data = {24'b0, iPE24_DMEM_EX_Data[7 : 0]};
          2'b01: wPE24_DMEM_EX_Data = {24'b0, iPE24_DMEM_EX_Data[15: 8]};
          2'b10: wPE24_DMEM_EX_Data = {24'b0, iPE24_DMEM_EX_Data[23:16]};
          2'b11: wPE24_DMEM_EX_Data = {24'b0, iPE24_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE24_DMEM_EX_Data = iPE24_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 25
  assign oPE25_DMEM_Valid       = oPE25_AGU_DMEM_Write_Enable || oPE25_AGU_DMEM_Read_Enable;
  assign oPE25_AGU_DMEM_Address = wPE25_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE25_AGU_DMEM_Opcode        <= 'b0;
        PR_PE25_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE25_AGU_DMEM_Read_Enable )
      begin
        PR_PE25_AGU_DMEM_Opcode        <= wPE25_AGU_DMEM_Opcode;
        PR_PE25_AGU_DMEM_Addr_Last_Two <= wPE25_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE25_AGU_DMEM_Opcode or PR_PE25_AGU_DMEM_Addr_Last_Two or iPE25_DMEM_EX_Data )
    case ( PR_PE25_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE25_DMEM_EX_Data = iPE25_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE25_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE25_DMEM_EX_Data = {16'b0, iPE25_DMEM_EX_Data[15:0]};
        else
          wPE25_DMEM_EX_Data = {16'b0, iPE25_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE25_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE25_DMEM_EX_Data = {24'b0, iPE25_DMEM_EX_Data[7 : 0]};
          2'b01: wPE25_DMEM_EX_Data = {24'b0, iPE25_DMEM_EX_Data[15: 8]};
          2'b10: wPE25_DMEM_EX_Data = {24'b0, iPE25_DMEM_EX_Data[23:16]};
          2'b11: wPE25_DMEM_EX_Data = {24'b0, iPE25_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE25_DMEM_EX_Data = iPE25_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 26
  assign oPE26_DMEM_Valid       = oPE26_AGU_DMEM_Write_Enable || oPE26_AGU_DMEM_Read_Enable;
  assign oPE26_AGU_DMEM_Address = wPE26_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE26_AGU_DMEM_Opcode        <= 'b0;
        PR_PE26_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE26_AGU_DMEM_Read_Enable )
      begin
        PR_PE26_AGU_DMEM_Opcode        <= wPE26_AGU_DMEM_Opcode;
        PR_PE26_AGU_DMEM_Addr_Last_Two <= wPE26_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE26_AGU_DMEM_Opcode or PR_PE26_AGU_DMEM_Addr_Last_Two or iPE26_DMEM_EX_Data )
    case ( PR_PE26_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE26_DMEM_EX_Data = iPE26_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE26_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE26_DMEM_EX_Data = {16'b0, iPE26_DMEM_EX_Data[15:0]};
        else
          wPE26_DMEM_EX_Data = {16'b0, iPE26_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE26_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE26_DMEM_EX_Data = {24'b0, iPE26_DMEM_EX_Data[7 : 0]};
          2'b01: wPE26_DMEM_EX_Data = {24'b0, iPE26_DMEM_EX_Data[15: 8]};
          2'b10: wPE26_DMEM_EX_Data = {24'b0, iPE26_DMEM_EX_Data[23:16]};
          2'b11: wPE26_DMEM_EX_Data = {24'b0, iPE26_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE26_DMEM_EX_Data = iPE26_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 27
  assign oPE27_DMEM_Valid       = oPE27_AGU_DMEM_Write_Enable || oPE27_AGU_DMEM_Read_Enable;
  assign oPE27_AGU_DMEM_Address = wPE27_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE27_AGU_DMEM_Opcode        <= 'b0;
        PR_PE27_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE27_AGU_DMEM_Read_Enable )
      begin
        PR_PE27_AGU_DMEM_Opcode        <= wPE27_AGU_DMEM_Opcode;
        PR_PE27_AGU_DMEM_Addr_Last_Two <= wPE27_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE27_AGU_DMEM_Opcode or PR_PE27_AGU_DMEM_Addr_Last_Two or iPE27_DMEM_EX_Data )
    case ( PR_PE27_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE27_DMEM_EX_Data = iPE27_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE27_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE27_DMEM_EX_Data = {16'b0, iPE27_DMEM_EX_Data[15:0]};
        else
          wPE27_DMEM_EX_Data = {16'b0, iPE27_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE27_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE27_DMEM_EX_Data = {24'b0, iPE27_DMEM_EX_Data[7 : 0]};
          2'b01: wPE27_DMEM_EX_Data = {24'b0, iPE27_DMEM_EX_Data[15: 8]};
          2'b10: wPE27_DMEM_EX_Data = {24'b0, iPE27_DMEM_EX_Data[23:16]};
          2'b11: wPE27_DMEM_EX_Data = {24'b0, iPE27_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE27_DMEM_EX_Data = iPE27_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 28
  assign oPE28_DMEM_Valid       = oPE28_AGU_DMEM_Write_Enable || oPE28_AGU_DMEM_Read_Enable;
  assign oPE28_AGU_DMEM_Address = wPE28_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE28_AGU_DMEM_Opcode        <= 'b0;
        PR_PE28_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE28_AGU_DMEM_Read_Enable )
      begin
        PR_PE28_AGU_DMEM_Opcode        <= wPE28_AGU_DMEM_Opcode;
        PR_PE28_AGU_DMEM_Addr_Last_Two <= wPE28_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE28_AGU_DMEM_Opcode or PR_PE28_AGU_DMEM_Addr_Last_Two or iPE28_DMEM_EX_Data )
    case ( PR_PE28_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE28_DMEM_EX_Data = iPE28_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE28_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE28_DMEM_EX_Data = {16'b0, iPE28_DMEM_EX_Data[15:0]};
        else
          wPE28_DMEM_EX_Data = {16'b0, iPE28_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE28_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE28_DMEM_EX_Data = {24'b0, iPE28_DMEM_EX_Data[7 : 0]};
          2'b01: wPE28_DMEM_EX_Data = {24'b0, iPE28_DMEM_EX_Data[15: 8]};
          2'b10: wPE28_DMEM_EX_Data = {24'b0, iPE28_DMEM_EX_Data[23:16]};
          2'b11: wPE28_DMEM_EX_Data = {24'b0, iPE28_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE28_DMEM_EX_Data = iPE28_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 29
  assign oPE29_DMEM_Valid       = oPE29_AGU_DMEM_Write_Enable || oPE29_AGU_DMEM_Read_Enable;
  assign oPE29_AGU_DMEM_Address = wPE29_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE29_AGU_DMEM_Opcode        <= 'b0;
        PR_PE29_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE29_AGU_DMEM_Read_Enable )
      begin
        PR_PE29_AGU_DMEM_Opcode        <= wPE29_AGU_DMEM_Opcode;
        PR_PE29_AGU_DMEM_Addr_Last_Two <= wPE29_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE29_AGU_DMEM_Opcode or PR_PE29_AGU_DMEM_Addr_Last_Two or iPE29_DMEM_EX_Data )
    case ( PR_PE29_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE29_DMEM_EX_Data = iPE29_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE29_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE29_DMEM_EX_Data = {16'b0, iPE29_DMEM_EX_Data[15:0]};
        else
          wPE29_DMEM_EX_Data = {16'b0, iPE29_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE29_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE29_DMEM_EX_Data = {24'b0, iPE29_DMEM_EX_Data[7 : 0]};
          2'b01: wPE29_DMEM_EX_Data = {24'b0, iPE29_DMEM_EX_Data[15: 8]};
          2'b10: wPE29_DMEM_EX_Data = {24'b0, iPE29_DMEM_EX_Data[23:16]};
          2'b11: wPE29_DMEM_EX_Data = {24'b0, iPE29_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE29_DMEM_EX_Data = iPE29_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 30
  assign oPE30_DMEM_Valid       = oPE30_AGU_DMEM_Write_Enable || oPE30_AGU_DMEM_Read_Enable;
  assign oPE30_AGU_DMEM_Address = wPE30_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE30_AGU_DMEM_Opcode        <= 'b0;
        PR_PE30_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE30_AGU_DMEM_Read_Enable )
      begin
        PR_PE30_AGU_DMEM_Opcode        <= wPE30_AGU_DMEM_Opcode;
        PR_PE30_AGU_DMEM_Addr_Last_Two <= wPE30_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE30_AGU_DMEM_Opcode or PR_PE30_AGU_DMEM_Addr_Last_Two or iPE30_DMEM_EX_Data )
    case ( PR_PE30_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE30_DMEM_EX_Data = iPE30_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE30_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE30_DMEM_EX_Data = {16'b0, iPE30_DMEM_EX_Data[15:0]};
        else
          wPE30_DMEM_EX_Data = {16'b0, iPE30_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE30_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE30_DMEM_EX_Data = {24'b0, iPE30_DMEM_EX_Data[7 : 0]};
          2'b01: wPE30_DMEM_EX_Data = {24'b0, iPE30_DMEM_EX_Data[15: 8]};
          2'b10: wPE30_DMEM_EX_Data = {24'b0, iPE30_DMEM_EX_Data[23:16]};
          2'b11: wPE30_DMEM_EX_Data = {24'b0, iPE30_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE30_DMEM_EX_Data = iPE30_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 31
  assign oPE31_DMEM_Valid       = oPE31_AGU_DMEM_Write_Enable || oPE31_AGU_DMEM_Read_Enable;
  assign oPE31_AGU_DMEM_Address = wPE31_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE31_AGU_DMEM_Opcode        <= 'b0;
        PR_PE31_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE31_AGU_DMEM_Read_Enable )
      begin
        PR_PE31_AGU_DMEM_Opcode        <= wPE31_AGU_DMEM_Opcode;
        PR_PE31_AGU_DMEM_Addr_Last_Two <= wPE31_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE31_AGU_DMEM_Opcode or PR_PE31_AGU_DMEM_Addr_Last_Two or iPE31_DMEM_EX_Data )
    case ( PR_PE31_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE31_DMEM_EX_Data = iPE31_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE31_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE31_DMEM_EX_Data = {16'b0, iPE31_DMEM_EX_Data[15:0]};
        else
          wPE31_DMEM_EX_Data = {16'b0, iPE31_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE31_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE31_DMEM_EX_Data = {24'b0, iPE31_DMEM_EX_Data[7 : 0]};
          2'b01: wPE31_DMEM_EX_Data = {24'b0, iPE31_DMEM_EX_Data[15: 8]};
          2'b10: wPE31_DMEM_EX_Data = {24'b0, iPE31_DMEM_EX_Data[23:16]};
          2'b11: wPE31_DMEM_EX_Data = {24'b0, iPE31_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE31_DMEM_EX_Data = iPE31_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 32
  assign oPE32_DMEM_Valid       = oPE32_AGU_DMEM_Write_Enable || oPE32_AGU_DMEM_Read_Enable;
  assign oPE32_AGU_DMEM_Address = wPE32_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE32_AGU_DMEM_Opcode        <= 'b0;
        PR_PE32_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE32_AGU_DMEM_Read_Enable )
      begin
        PR_PE32_AGU_DMEM_Opcode        <= wPE32_AGU_DMEM_Opcode;
        PR_PE32_AGU_DMEM_Addr_Last_Two <= wPE32_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE32_AGU_DMEM_Opcode or PR_PE32_AGU_DMEM_Addr_Last_Two or iPE32_DMEM_EX_Data )
    case ( PR_PE32_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE32_DMEM_EX_Data = iPE32_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE32_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE32_DMEM_EX_Data = {16'b0, iPE32_DMEM_EX_Data[15:0]};
        else
          wPE32_DMEM_EX_Data = {16'b0, iPE32_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE32_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE32_DMEM_EX_Data = {24'b0, iPE32_DMEM_EX_Data[7 : 0]};
          2'b01: wPE32_DMEM_EX_Data = {24'b0, iPE32_DMEM_EX_Data[15: 8]};
          2'b10: wPE32_DMEM_EX_Data = {24'b0, iPE32_DMEM_EX_Data[23:16]};
          2'b11: wPE32_DMEM_EX_Data = {24'b0, iPE32_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE32_DMEM_EX_Data = iPE32_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 33
  assign oPE33_DMEM_Valid       = oPE33_AGU_DMEM_Write_Enable || oPE33_AGU_DMEM_Read_Enable;
  assign oPE33_AGU_DMEM_Address = wPE33_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE33_AGU_DMEM_Opcode        <= 'b0;
        PR_PE33_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE33_AGU_DMEM_Read_Enable )
      begin
        PR_PE33_AGU_DMEM_Opcode        <= wPE33_AGU_DMEM_Opcode;
        PR_PE33_AGU_DMEM_Addr_Last_Two <= wPE33_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE33_AGU_DMEM_Opcode or PR_PE33_AGU_DMEM_Addr_Last_Two or iPE33_DMEM_EX_Data )
    case ( PR_PE33_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE33_DMEM_EX_Data = iPE33_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE33_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE33_DMEM_EX_Data = {16'b0, iPE33_DMEM_EX_Data[15:0]};
        else
          wPE33_DMEM_EX_Data = {16'b0, iPE33_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE33_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE33_DMEM_EX_Data = {24'b0, iPE33_DMEM_EX_Data[7 : 0]};
          2'b01: wPE33_DMEM_EX_Data = {24'b0, iPE33_DMEM_EX_Data[15: 8]};
          2'b10: wPE33_DMEM_EX_Data = {24'b0, iPE33_DMEM_EX_Data[23:16]};
          2'b11: wPE33_DMEM_EX_Data = {24'b0, iPE33_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE33_DMEM_EX_Data = iPE33_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 34
  assign oPE34_DMEM_Valid       = oPE34_AGU_DMEM_Write_Enable || oPE34_AGU_DMEM_Read_Enable;
  assign oPE34_AGU_DMEM_Address = wPE34_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE34_AGU_DMEM_Opcode        <= 'b0;
        PR_PE34_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE34_AGU_DMEM_Read_Enable )
      begin
        PR_PE34_AGU_DMEM_Opcode        <= wPE34_AGU_DMEM_Opcode;
        PR_PE34_AGU_DMEM_Addr_Last_Two <= wPE34_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE34_AGU_DMEM_Opcode or PR_PE34_AGU_DMEM_Addr_Last_Two or iPE34_DMEM_EX_Data )
    case ( PR_PE34_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE34_DMEM_EX_Data = iPE34_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE34_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE34_DMEM_EX_Data = {16'b0, iPE34_DMEM_EX_Data[15:0]};
        else
          wPE34_DMEM_EX_Data = {16'b0, iPE34_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE34_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE34_DMEM_EX_Data = {24'b0, iPE34_DMEM_EX_Data[7 : 0]};
          2'b01: wPE34_DMEM_EX_Data = {24'b0, iPE34_DMEM_EX_Data[15: 8]};
          2'b10: wPE34_DMEM_EX_Data = {24'b0, iPE34_DMEM_EX_Data[23:16]};
          2'b11: wPE34_DMEM_EX_Data = {24'b0, iPE34_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE34_DMEM_EX_Data = iPE34_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 35
  assign oPE35_DMEM_Valid       = oPE35_AGU_DMEM_Write_Enable || oPE35_AGU_DMEM_Read_Enable;
  assign oPE35_AGU_DMEM_Address = wPE35_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE35_AGU_DMEM_Opcode        <= 'b0;
        PR_PE35_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE35_AGU_DMEM_Read_Enable )
      begin
        PR_PE35_AGU_DMEM_Opcode        <= wPE35_AGU_DMEM_Opcode;
        PR_PE35_AGU_DMEM_Addr_Last_Two <= wPE35_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE35_AGU_DMEM_Opcode or PR_PE35_AGU_DMEM_Addr_Last_Two or iPE35_DMEM_EX_Data )
    case ( PR_PE35_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE35_DMEM_EX_Data = iPE35_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE35_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE35_DMEM_EX_Data = {16'b0, iPE35_DMEM_EX_Data[15:0]};
        else
          wPE35_DMEM_EX_Data = {16'b0, iPE35_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE35_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE35_DMEM_EX_Data = {24'b0, iPE35_DMEM_EX_Data[7 : 0]};
          2'b01: wPE35_DMEM_EX_Data = {24'b0, iPE35_DMEM_EX_Data[15: 8]};
          2'b10: wPE35_DMEM_EX_Data = {24'b0, iPE35_DMEM_EX_Data[23:16]};
          2'b11: wPE35_DMEM_EX_Data = {24'b0, iPE35_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE35_DMEM_EX_Data = iPE35_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 36
  assign oPE36_DMEM_Valid       = oPE36_AGU_DMEM_Write_Enable || oPE36_AGU_DMEM_Read_Enable;
  assign oPE36_AGU_DMEM_Address = wPE36_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE36_AGU_DMEM_Opcode        <= 'b0;
        PR_PE36_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE36_AGU_DMEM_Read_Enable )
      begin
        PR_PE36_AGU_DMEM_Opcode        <= wPE36_AGU_DMEM_Opcode;
        PR_PE36_AGU_DMEM_Addr_Last_Two <= wPE36_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE36_AGU_DMEM_Opcode or PR_PE36_AGU_DMEM_Addr_Last_Two or iPE36_DMEM_EX_Data )
    case ( PR_PE36_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE36_DMEM_EX_Data = iPE36_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE36_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE36_DMEM_EX_Data = {16'b0, iPE36_DMEM_EX_Data[15:0]};
        else
          wPE36_DMEM_EX_Data = {16'b0, iPE36_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE36_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE36_DMEM_EX_Data = {24'b0, iPE36_DMEM_EX_Data[7 : 0]};
          2'b01: wPE36_DMEM_EX_Data = {24'b0, iPE36_DMEM_EX_Data[15: 8]};
          2'b10: wPE36_DMEM_EX_Data = {24'b0, iPE36_DMEM_EX_Data[23:16]};
          2'b11: wPE36_DMEM_EX_Data = {24'b0, iPE36_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE36_DMEM_EX_Data = iPE36_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 37
  assign oPE37_DMEM_Valid       = oPE37_AGU_DMEM_Write_Enable || oPE37_AGU_DMEM_Read_Enable;
  assign oPE37_AGU_DMEM_Address = wPE37_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE37_AGU_DMEM_Opcode        <= 'b0;
        PR_PE37_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE37_AGU_DMEM_Read_Enable )
      begin
        PR_PE37_AGU_DMEM_Opcode        <= wPE37_AGU_DMEM_Opcode;
        PR_PE37_AGU_DMEM_Addr_Last_Two <= wPE37_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE37_AGU_DMEM_Opcode or PR_PE37_AGU_DMEM_Addr_Last_Two or iPE37_DMEM_EX_Data )
    case ( PR_PE37_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE37_DMEM_EX_Data = iPE37_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE37_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE37_DMEM_EX_Data = {16'b0, iPE37_DMEM_EX_Data[15:0]};
        else
          wPE37_DMEM_EX_Data = {16'b0, iPE37_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE37_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE37_DMEM_EX_Data = {24'b0, iPE37_DMEM_EX_Data[7 : 0]};
          2'b01: wPE37_DMEM_EX_Data = {24'b0, iPE37_DMEM_EX_Data[15: 8]};
          2'b10: wPE37_DMEM_EX_Data = {24'b0, iPE37_DMEM_EX_Data[23:16]};
          2'b11: wPE37_DMEM_EX_Data = {24'b0, iPE37_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE37_DMEM_EX_Data = iPE37_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 38
  assign oPE38_DMEM_Valid       = oPE38_AGU_DMEM_Write_Enable || oPE38_AGU_DMEM_Read_Enable;
  assign oPE38_AGU_DMEM_Address = wPE38_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE38_AGU_DMEM_Opcode        <= 'b0;
        PR_PE38_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE38_AGU_DMEM_Read_Enable )
      begin
        PR_PE38_AGU_DMEM_Opcode        <= wPE38_AGU_DMEM_Opcode;
        PR_PE38_AGU_DMEM_Addr_Last_Two <= wPE38_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE38_AGU_DMEM_Opcode or PR_PE38_AGU_DMEM_Addr_Last_Two or iPE38_DMEM_EX_Data )
    case ( PR_PE38_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE38_DMEM_EX_Data = iPE38_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE38_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE38_DMEM_EX_Data = {16'b0, iPE38_DMEM_EX_Data[15:0]};
        else
          wPE38_DMEM_EX_Data = {16'b0, iPE38_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE38_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE38_DMEM_EX_Data = {24'b0, iPE38_DMEM_EX_Data[7 : 0]};
          2'b01: wPE38_DMEM_EX_Data = {24'b0, iPE38_DMEM_EX_Data[15: 8]};
          2'b10: wPE38_DMEM_EX_Data = {24'b0, iPE38_DMEM_EX_Data[23:16]};
          2'b11: wPE38_DMEM_EX_Data = {24'b0, iPE38_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE38_DMEM_EX_Data = iPE38_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 39
  assign oPE39_DMEM_Valid       = oPE39_AGU_DMEM_Write_Enable || oPE39_AGU_DMEM_Read_Enable;
  assign oPE39_AGU_DMEM_Address = wPE39_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE39_AGU_DMEM_Opcode        <= 'b0;
        PR_PE39_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE39_AGU_DMEM_Read_Enable )
      begin
        PR_PE39_AGU_DMEM_Opcode        <= wPE39_AGU_DMEM_Opcode;
        PR_PE39_AGU_DMEM_Addr_Last_Two <= wPE39_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE39_AGU_DMEM_Opcode or PR_PE39_AGU_DMEM_Addr_Last_Two or iPE39_DMEM_EX_Data )
    case ( PR_PE39_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE39_DMEM_EX_Data = iPE39_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE39_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE39_DMEM_EX_Data = {16'b0, iPE39_DMEM_EX_Data[15:0]};
        else
          wPE39_DMEM_EX_Data = {16'b0, iPE39_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE39_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE39_DMEM_EX_Data = {24'b0, iPE39_DMEM_EX_Data[7 : 0]};
          2'b01: wPE39_DMEM_EX_Data = {24'b0, iPE39_DMEM_EX_Data[15: 8]};
          2'b10: wPE39_DMEM_EX_Data = {24'b0, iPE39_DMEM_EX_Data[23:16]};
          2'b11: wPE39_DMEM_EX_Data = {24'b0, iPE39_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE39_DMEM_EX_Data = iPE39_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 40
  assign oPE40_DMEM_Valid       = oPE40_AGU_DMEM_Write_Enable || oPE40_AGU_DMEM_Read_Enable;
  assign oPE40_AGU_DMEM_Address = wPE40_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE40_AGU_DMEM_Opcode        <= 'b0;
        PR_PE40_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE40_AGU_DMEM_Read_Enable )
      begin
        PR_PE40_AGU_DMEM_Opcode        <= wPE40_AGU_DMEM_Opcode;
        PR_PE40_AGU_DMEM_Addr_Last_Two <= wPE40_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE40_AGU_DMEM_Opcode or PR_PE40_AGU_DMEM_Addr_Last_Two or iPE40_DMEM_EX_Data )
    case ( PR_PE40_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE40_DMEM_EX_Data = iPE40_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE40_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE40_DMEM_EX_Data = {16'b0, iPE40_DMEM_EX_Data[15:0]};
        else
          wPE40_DMEM_EX_Data = {16'b0, iPE40_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE40_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE40_DMEM_EX_Data = {24'b0, iPE40_DMEM_EX_Data[7 : 0]};
          2'b01: wPE40_DMEM_EX_Data = {24'b0, iPE40_DMEM_EX_Data[15: 8]};
          2'b10: wPE40_DMEM_EX_Data = {24'b0, iPE40_DMEM_EX_Data[23:16]};
          2'b11: wPE40_DMEM_EX_Data = {24'b0, iPE40_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE40_DMEM_EX_Data = iPE40_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 41
  assign oPE41_DMEM_Valid       = oPE41_AGU_DMEM_Write_Enable || oPE41_AGU_DMEM_Read_Enable;
  assign oPE41_AGU_DMEM_Address = wPE41_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE41_AGU_DMEM_Opcode        <= 'b0;
        PR_PE41_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE41_AGU_DMEM_Read_Enable )
      begin
        PR_PE41_AGU_DMEM_Opcode        <= wPE41_AGU_DMEM_Opcode;
        PR_PE41_AGU_DMEM_Addr_Last_Two <= wPE41_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE41_AGU_DMEM_Opcode or PR_PE41_AGU_DMEM_Addr_Last_Two or iPE41_DMEM_EX_Data )
    case ( PR_PE41_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE41_DMEM_EX_Data = iPE41_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE41_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE41_DMEM_EX_Data = {16'b0, iPE41_DMEM_EX_Data[15:0]};
        else
          wPE41_DMEM_EX_Data = {16'b0, iPE41_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE41_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE41_DMEM_EX_Data = {24'b0, iPE41_DMEM_EX_Data[7 : 0]};
          2'b01: wPE41_DMEM_EX_Data = {24'b0, iPE41_DMEM_EX_Data[15: 8]};
          2'b10: wPE41_DMEM_EX_Data = {24'b0, iPE41_DMEM_EX_Data[23:16]};
          2'b11: wPE41_DMEM_EX_Data = {24'b0, iPE41_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE41_DMEM_EX_Data = iPE41_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 42
  assign oPE42_DMEM_Valid       = oPE42_AGU_DMEM_Write_Enable || oPE42_AGU_DMEM_Read_Enable;
  assign oPE42_AGU_DMEM_Address = wPE42_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE42_AGU_DMEM_Opcode        <= 'b0;
        PR_PE42_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE42_AGU_DMEM_Read_Enable )
      begin
        PR_PE42_AGU_DMEM_Opcode        <= wPE42_AGU_DMEM_Opcode;
        PR_PE42_AGU_DMEM_Addr_Last_Two <= wPE42_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE42_AGU_DMEM_Opcode or PR_PE42_AGU_DMEM_Addr_Last_Two or iPE42_DMEM_EX_Data )
    case ( PR_PE42_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE42_DMEM_EX_Data = iPE42_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE42_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE42_DMEM_EX_Data = {16'b0, iPE42_DMEM_EX_Data[15:0]};
        else
          wPE42_DMEM_EX_Data = {16'b0, iPE42_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE42_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE42_DMEM_EX_Data = {24'b0, iPE42_DMEM_EX_Data[7 : 0]};
          2'b01: wPE42_DMEM_EX_Data = {24'b0, iPE42_DMEM_EX_Data[15: 8]};
          2'b10: wPE42_DMEM_EX_Data = {24'b0, iPE42_DMEM_EX_Data[23:16]};
          2'b11: wPE42_DMEM_EX_Data = {24'b0, iPE42_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE42_DMEM_EX_Data = iPE42_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 43
  assign oPE43_DMEM_Valid       = oPE43_AGU_DMEM_Write_Enable || oPE43_AGU_DMEM_Read_Enable;
  assign oPE43_AGU_DMEM_Address = wPE43_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE43_AGU_DMEM_Opcode        <= 'b0;
        PR_PE43_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE43_AGU_DMEM_Read_Enable )
      begin
        PR_PE43_AGU_DMEM_Opcode        <= wPE43_AGU_DMEM_Opcode;
        PR_PE43_AGU_DMEM_Addr_Last_Two <= wPE43_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE43_AGU_DMEM_Opcode or PR_PE43_AGU_DMEM_Addr_Last_Two or iPE43_DMEM_EX_Data )
    case ( PR_PE43_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE43_DMEM_EX_Data = iPE43_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE43_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE43_DMEM_EX_Data = {16'b0, iPE43_DMEM_EX_Data[15:0]};
        else
          wPE43_DMEM_EX_Data = {16'b0, iPE43_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE43_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE43_DMEM_EX_Data = {24'b0, iPE43_DMEM_EX_Data[7 : 0]};
          2'b01: wPE43_DMEM_EX_Data = {24'b0, iPE43_DMEM_EX_Data[15: 8]};
          2'b10: wPE43_DMEM_EX_Data = {24'b0, iPE43_DMEM_EX_Data[23:16]};
          2'b11: wPE43_DMEM_EX_Data = {24'b0, iPE43_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE43_DMEM_EX_Data = iPE43_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 44
  assign oPE44_DMEM_Valid       = oPE44_AGU_DMEM_Write_Enable || oPE44_AGU_DMEM_Read_Enable;
  assign oPE44_AGU_DMEM_Address = wPE44_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE44_AGU_DMEM_Opcode        <= 'b0;
        PR_PE44_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE44_AGU_DMEM_Read_Enable )
      begin
        PR_PE44_AGU_DMEM_Opcode        <= wPE44_AGU_DMEM_Opcode;
        PR_PE44_AGU_DMEM_Addr_Last_Two <= wPE44_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE44_AGU_DMEM_Opcode or PR_PE44_AGU_DMEM_Addr_Last_Two or iPE44_DMEM_EX_Data )
    case ( PR_PE44_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE44_DMEM_EX_Data = iPE44_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE44_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE44_DMEM_EX_Data = {16'b0, iPE44_DMEM_EX_Data[15:0]};
        else
          wPE44_DMEM_EX_Data = {16'b0, iPE44_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE44_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE44_DMEM_EX_Data = {24'b0, iPE44_DMEM_EX_Data[7 : 0]};
          2'b01: wPE44_DMEM_EX_Data = {24'b0, iPE44_DMEM_EX_Data[15: 8]};
          2'b10: wPE44_DMEM_EX_Data = {24'b0, iPE44_DMEM_EX_Data[23:16]};
          2'b11: wPE44_DMEM_EX_Data = {24'b0, iPE44_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE44_DMEM_EX_Data = iPE44_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 45
  assign oPE45_DMEM_Valid       = oPE45_AGU_DMEM_Write_Enable || oPE45_AGU_DMEM_Read_Enable;
  assign oPE45_AGU_DMEM_Address = wPE45_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE45_AGU_DMEM_Opcode        <= 'b0;
        PR_PE45_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE45_AGU_DMEM_Read_Enable )
      begin
        PR_PE45_AGU_DMEM_Opcode        <= wPE45_AGU_DMEM_Opcode;
        PR_PE45_AGU_DMEM_Addr_Last_Two <= wPE45_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE45_AGU_DMEM_Opcode or PR_PE45_AGU_DMEM_Addr_Last_Two or iPE45_DMEM_EX_Data )
    case ( PR_PE45_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE45_DMEM_EX_Data = iPE45_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE45_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE45_DMEM_EX_Data = {16'b0, iPE45_DMEM_EX_Data[15:0]};
        else
          wPE45_DMEM_EX_Data = {16'b0, iPE45_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE45_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE45_DMEM_EX_Data = {24'b0, iPE45_DMEM_EX_Data[7 : 0]};
          2'b01: wPE45_DMEM_EX_Data = {24'b0, iPE45_DMEM_EX_Data[15: 8]};
          2'b10: wPE45_DMEM_EX_Data = {24'b0, iPE45_DMEM_EX_Data[23:16]};
          2'b11: wPE45_DMEM_EX_Data = {24'b0, iPE45_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE45_DMEM_EX_Data = iPE45_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 46
  assign oPE46_DMEM_Valid       = oPE46_AGU_DMEM_Write_Enable || oPE46_AGU_DMEM_Read_Enable;
  assign oPE46_AGU_DMEM_Address = wPE46_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE46_AGU_DMEM_Opcode        <= 'b0;
        PR_PE46_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE46_AGU_DMEM_Read_Enable )
      begin
        PR_PE46_AGU_DMEM_Opcode        <= wPE46_AGU_DMEM_Opcode;
        PR_PE46_AGU_DMEM_Addr_Last_Two <= wPE46_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE46_AGU_DMEM_Opcode or PR_PE46_AGU_DMEM_Addr_Last_Two or iPE46_DMEM_EX_Data )
    case ( PR_PE46_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE46_DMEM_EX_Data = iPE46_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE46_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE46_DMEM_EX_Data = {16'b0, iPE46_DMEM_EX_Data[15:0]};
        else
          wPE46_DMEM_EX_Data = {16'b0, iPE46_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE46_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE46_DMEM_EX_Data = {24'b0, iPE46_DMEM_EX_Data[7 : 0]};
          2'b01: wPE46_DMEM_EX_Data = {24'b0, iPE46_DMEM_EX_Data[15: 8]};
          2'b10: wPE46_DMEM_EX_Data = {24'b0, iPE46_DMEM_EX_Data[23:16]};
          2'b11: wPE46_DMEM_EX_Data = {24'b0, iPE46_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE46_DMEM_EX_Data = iPE46_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 47
  assign oPE47_DMEM_Valid       = oPE47_AGU_DMEM_Write_Enable || oPE47_AGU_DMEM_Read_Enable;
  assign oPE47_AGU_DMEM_Address = wPE47_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE47_AGU_DMEM_Opcode        <= 'b0;
        PR_PE47_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE47_AGU_DMEM_Read_Enable )
      begin
        PR_PE47_AGU_DMEM_Opcode        <= wPE47_AGU_DMEM_Opcode;
        PR_PE47_AGU_DMEM_Addr_Last_Two <= wPE47_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE47_AGU_DMEM_Opcode or PR_PE47_AGU_DMEM_Addr_Last_Two or iPE47_DMEM_EX_Data )
    case ( PR_PE47_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE47_DMEM_EX_Data = iPE47_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE47_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE47_DMEM_EX_Data = {16'b0, iPE47_DMEM_EX_Data[15:0]};
        else
          wPE47_DMEM_EX_Data = {16'b0, iPE47_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE47_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE47_DMEM_EX_Data = {24'b0, iPE47_DMEM_EX_Data[7 : 0]};
          2'b01: wPE47_DMEM_EX_Data = {24'b0, iPE47_DMEM_EX_Data[15: 8]};
          2'b10: wPE47_DMEM_EX_Data = {24'b0, iPE47_DMEM_EX_Data[23:16]};
          2'b11: wPE47_DMEM_EX_Data = {24'b0, iPE47_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE47_DMEM_EX_Data = iPE47_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 48
  assign oPE48_DMEM_Valid       = oPE48_AGU_DMEM_Write_Enable || oPE48_AGU_DMEM_Read_Enable;
  assign oPE48_AGU_DMEM_Address = wPE48_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE48_AGU_DMEM_Opcode        <= 'b0;
        PR_PE48_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE48_AGU_DMEM_Read_Enable )
      begin
        PR_PE48_AGU_DMEM_Opcode        <= wPE48_AGU_DMEM_Opcode;
        PR_PE48_AGU_DMEM_Addr_Last_Two <= wPE48_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE48_AGU_DMEM_Opcode or PR_PE48_AGU_DMEM_Addr_Last_Two or iPE48_DMEM_EX_Data )
    case ( PR_PE48_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE48_DMEM_EX_Data = iPE48_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE48_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE48_DMEM_EX_Data = {16'b0, iPE48_DMEM_EX_Data[15:0]};
        else
          wPE48_DMEM_EX_Data = {16'b0, iPE48_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE48_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE48_DMEM_EX_Data = {24'b0, iPE48_DMEM_EX_Data[7 : 0]};
          2'b01: wPE48_DMEM_EX_Data = {24'b0, iPE48_DMEM_EX_Data[15: 8]};
          2'b10: wPE48_DMEM_EX_Data = {24'b0, iPE48_DMEM_EX_Data[23:16]};
          2'b11: wPE48_DMEM_EX_Data = {24'b0, iPE48_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE48_DMEM_EX_Data = iPE48_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 49
  assign oPE49_DMEM_Valid       = oPE49_AGU_DMEM_Write_Enable || oPE49_AGU_DMEM_Read_Enable;
  assign oPE49_AGU_DMEM_Address = wPE49_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE49_AGU_DMEM_Opcode        <= 'b0;
        PR_PE49_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE49_AGU_DMEM_Read_Enable )
      begin
        PR_PE49_AGU_DMEM_Opcode        <= wPE49_AGU_DMEM_Opcode;
        PR_PE49_AGU_DMEM_Addr_Last_Two <= wPE49_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE49_AGU_DMEM_Opcode or PR_PE49_AGU_DMEM_Addr_Last_Two or iPE49_DMEM_EX_Data )
    case ( PR_PE49_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE49_DMEM_EX_Data = iPE49_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE49_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE49_DMEM_EX_Data = {16'b0, iPE49_DMEM_EX_Data[15:0]};
        else
          wPE49_DMEM_EX_Data = {16'b0, iPE49_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE49_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE49_DMEM_EX_Data = {24'b0, iPE49_DMEM_EX_Data[7 : 0]};
          2'b01: wPE49_DMEM_EX_Data = {24'b0, iPE49_DMEM_EX_Data[15: 8]};
          2'b10: wPE49_DMEM_EX_Data = {24'b0, iPE49_DMEM_EX_Data[23:16]};
          2'b11: wPE49_DMEM_EX_Data = {24'b0, iPE49_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE49_DMEM_EX_Data = iPE49_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 50
  assign oPE50_DMEM_Valid       = oPE50_AGU_DMEM_Write_Enable || oPE50_AGU_DMEM_Read_Enable;
  assign oPE50_AGU_DMEM_Address = wPE50_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE50_AGU_DMEM_Opcode        <= 'b0;
        PR_PE50_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE50_AGU_DMEM_Read_Enable )
      begin
        PR_PE50_AGU_DMEM_Opcode        <= wPE50_AGU_DMEM_Opcode;
        PR_PE50_AGU_DMEM_Addr_Last_Two <= wPE50_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE50_AGU_DMEM_Opcode or PR_PE50_AGU_DMEM_Addr_Last_Two or iPE50_DMEM_EX_Data )
    case ( PR_PE50_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE50_DMEM_EX_Data = iPE50_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE50_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE50_DMEM_EX_Data = {16'b0, iPE50_DMEM_EX_Data[15:0]};
        else
          wPE50_DMEM_EX_Data = {16'b0, iPE50_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE50_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE50_DMEM_EX_Data = {24'b0, iPE50_DMEM_EX_Data[7 : 0]};
          2'b01: wPE50_DMEM_EX_Data = {24'b0, iPE50_DMEM_EX_Data[15: 8]};
          2'b10: wPE50_DMEM_EX_Data = {24'b0, iPE50_DMEM_EX_Data[23:16]};
          2'b11: wPE50_DMEM_EX_Data = {24'b0, iPE50_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE50_DMEM_EX_Data = iPE50_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 51
  assign oPE51_DMEM_Valid       = oPE51_AGU_DMEM_Write_Enable || oPE51_AGU_DMEM_Read_Enable;
  assign oPE51_AGU_DMEM_Address = wPE51_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE51_AGU_DMEM_Opcode        <= 'b0;
        PR_PE51_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE51_AGU_DMEM_Read_Enable )
      begin
        PR_PE51_AGU_DMEM_Opcode        <= wPE51_AGU_DMEM_Opcode;
        PR_PE51_AGU_DMEM_Addr_Last_Two <= wPE51_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE51_AGU_DMEM_Opcode or PR_PE51_AGU_DMEM_Addr_Last_Two or iPE51_DMEM_EX_Data )
    case ( PR_PE51_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE51_DMEM_EX_Data = iPE51_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE51_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE51_DMEM_EX_Data = {16'b0, iPE51_DMEM_EX_Data[15:0]};
        else
          wPE51_DMEM_EX_Data = {16'b0, iPE51_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE51_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE51_DMEM_EX_Data = {24'b0, iPE51_DMEM_EX_Data[7 : 0]};
          2'b01: wPE51_DMEM_EX_Data = {24'b0, iPE51_DMEM_EX_Data[15: 8]};
          2'b10: wPE51_DMEM_EX_Data = {24'b0, iPE51_DMEM_EX_Data[23:16]};
          2'b11: wPE51_DMEM_EX_Data = {24'b0, iPE51_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE51_DMEM_EX_Data = iPE51_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 52
  assign oPE52_DMEM_Valid       = oPE52_AGU_DMEM_Write_Enable || oPE52_AGU_DMEM_Read_Enable;
  assign oPE52_AGU_DMEM_Address = wPE52_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE52_AGU_DMEM_Opcode        <= 'b0;
        PR_PE52_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE52_AGU_DMEM_Read_Enable )
      begin
        PR_PE52_AGU_DMEM_Opcode        <= wPE52_AGU_DMEM_Opcode;
        PR_PE52_AGU_DMEM_Addr_Last_Two <= wPE52_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE52_AGU_DMEM_Opcode or PR_PE52_AGU_DMEM_Addr_Last_Two or iPE52_DMEM_EX_Data )
    case ( PR_PE52_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE52_DMEM_EX_Data = iPE52_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE52_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE52_DMEM_EX_Data = {16'b0, iPE52_DMEM_EX_Data[15:0]};
        else
          wPE52_DMEM_EX_Data = {16'b0, iPE52_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE52_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE52_DMEM_EX_Data = {24'b0, iPE52_DMEM_EX_Data[7 : 0]};
          2'b01: wPE52_DMEM_EX_Data = {24'b0, iPE52_DMEM_EX_Data[15: 8]};
          2'b10: wPE52_DMEM_EX_Data = {24'b0, iPE52_DMEM_EX_Data[23:16]};
          2'b11: wPE52_DMEM_EX_Data = {24'b0, iPE52_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE52_DMEM_EX_Data = iPE52_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 53
  assign oPE53_DMEM_Valid       = oPE53_AGU_DMEM_Write_Enable || oPE53_AGU_DMEM_Read_Enable;
  assign oPE53_AGU_DMEM_Address = wPE53_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE53_AGU_DMEM_Opcode        <= 'b0;
        PR_PE53_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE53_AGU_DMEM_Read_Enable )
      begin
        PR_PE53_AGU_DMEM_Opcode        <= wPE53_AGU_DMEM_Opcode;
        PR_PE53_AGU_DMEM_Addr_Last_Two <= wPE53_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE53_AGU_DMEM_Opcode or PR_PE53_AGU_DMEM_Addr_Last_Two or iPE53_DMEM_EX_Data )
    case ( PR_PE53_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE53_DMEM_EX_Data = iPE53_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE53_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE53_DMEM_EX_Data = {16'b0, iPE53_DMEM_EX_Data[15:0]};
        else
          wPE53_DMEM_EX_Data = {16'b0, iPE53_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE53_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE53_DMEM_EX_Data = {24'b0, iPE53_DMEM_EX_Data[7 : 0]};
          2'b01: wPE53_DMEM_EX_Data = {24'b0, iPE53_DMEM_EX_Data[15: 8]};
          2'b10: wPE53_DMEM_EX_Data = {24'b0, iPE53_DMEM_EX_Data[23:16]};
          2'b11: wPE53_DMEM_EX_Data = {24'b0, iPE53_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE53_DMEM_EX_Data = iPE53_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 54
  assign oPE54_DMEM_Valid       = oPE54_AGU_DMEM_Write_Enable || oPE54_AGU_DMEM_Read_Enable;
  assign oPE54_AGU_DMEM_Address = wPE54_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE54_AGU_DMEM_Opcode        <= 'b0;
        PR_PE54_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE54_AGU_DMEM_Read_Enable )
      begin
        PR_PE54_AGU_DMEM_Opcode        <= wPE54_AGU_DMEM_Opcode;
        PR_PE54_AGU_DMEM_Addr_Last_Two <= wPE54_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE54_AGU_DMEM_Opcode or PR_PE54_AGU_DMEM_Addr_Last_Two or iPE54_DMEM_EX_Data )
    case ( PR_PE54_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE54_DMEM_EX_Data = iPE54_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE54_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE54_DMEM_EX_Data = {16'b0, iPE54_DMEM_EX_Data[15:0]};
        else
          wPE54_DMEM_EX_Data = {16'b0, iPE54_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE54_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE54_DMEM_EX_Data = {24'b0, iPE54_DMEM_EX_Data[7 : 0]};
          2'b01: wPE54_DMEM_EX_Data = {24'b0, iPE54_DMEM_EX_Data[15: 8]};
          2'b10: wPE54_DMEM_EX_Data = {24'b0, iPE54_DMEM_EX_Data[23:16]};
          2'b11: wPE54_DMEM_EX_Data = {24'b0, iPE54_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE54_DMEM_EX_Data = iPE54_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 55
  assign oPE55_DMEM_Valid       = oPE55_AGU_DMEM_Write_Enable || oPE55_AGU_DMEM_Read_Enable;
  assign oPE55_AGU_DMEM_Address = wPE55_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE55_AGU_DMEM_Opcode        <= 'b0;
        PR_PE55_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE55_AGU_DMEM_Read_Enable )
      begin
        PR_PE55_AGU_DMEM_Opcode        <= wPE55_AGU_DMEM_Opcode;
        PR_PE55_AGU_DMEM_Addr_Last_Two <= wPE55_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE55_AGU_DMEM_Opcode or PR_PE55_AGU_DMEM_Addr_Last_Two or iPE55_DMEM_EX_Data )
    case ( PR_PE55_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE55_DMEM_EX_Data = iPE55_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE55_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE55_DMEM_EX_Data = {16'b0, iPE55_DMEM_EX_Data[15:0]};
        else
          wPE55_DMEM_EX_Data = {16'b0, iPE55_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE55_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE55_DMEM_EX_Data = {24'b0, iPE55_DMEM_EX_Data[7 : 0]};
          2'b01: wPE55_DMEM_EX_Data = {24'b0, iPE55_DMEM_EX_Data[15: 8]};
          2'b10: wPE55_DMEM_EX_Data = {24'b0, iPE55_DMEM_EX_Data[23:16]};
          2'b11: wPE55_DMEM_EX_Data = {24'b0, iPE55_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE55_DMEM_EX_Data = iPE55_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 56
  assign oPE56_DMEM_Valid       = oPE56_AGU_DMEM_Write_Enable || oPE56_AGU_DMEM_Read_Enable;
  assign oPE56_AGU_DMEM_Address = wPE56_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE56_AGU_DMEM_Opcode        <= 'b0;
        PR_PE56_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE56_AGU_DMEM_Read_Enable )
      begin
        PR_PE56_AGU_DMEM_Opcode        <= wPE56_AGU_DMEM_Opcode;
        PR_PE56_AGU_DMEM_Addr_Last_Two <= wPE56_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE56_AGU_DMEM_Opcode or PR_PE56_AGU_DMEM_Addr_Last_Two or iPE56_DMEM_EX_Data )
    case ( PR_PE56_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE56_DMEM_EX_Data = iPE56_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE56_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE56_DMEM_EX_Data = {16'b0, iPE56_DMEM_EX_Data[15:0]};
        else
          wPE56_DMEM_EX_Data = {16'b0, iPE56_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE56_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE56_DMEM_EX_Data = {24'b0, iPE56_DMEM_EX_Data[7 : 0]};
          2'b01: wPE56_DMEM_EX_Data = {24'b0, iPE56_DMEM_EX_Data[15: 8]};
          2'b10: wPE56_DMEM_EX_Data = {24'b0, iPE56_DMEM_EX_Data[23:16]};
          2'b11: wPE56_DMEM_EX_Data = {24'b0, iPE56_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE56_DMEM_EX_Data = iPE56_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 57
  assign oPE57_DMEM_Valid       = oPE57_AGU_DMEM_Write_Enable || oPE57_AGU_DMEM_Read_Enable;
  assign oPE57_AGU_DMEM_Address = wPE57_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE57_AGU_DMEM_Opcode        <= 'b0;
        PR_PE57_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE57_AGU_DMEM_Read_Enable )
      begin
        PR_PE57_AGU_DMEM_Opcode        <= wPE57_AGU_DMEM_Opcode;
        PR_PE57_AGU_DMEM_Addr_Last_Two <= wPE57_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE57_AGU_DMEM_Opcode or PR_PE57_AGU_DMEM_Addr_Last_Two or iPE57_DMEM_EX_Data )
    case ( PR_PE57_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE57_DMEM_EX_Data = iPE57_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE57_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE57_DMEM_EX_Data = {16'b0, iPE57_DMEM_EX_Data[15:0]};
        else
          wPE57_DMEM_EX_Data = {16'b0, iPE57_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE57_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE57_DMEM_EX_Data = {24'b0, iPE57_DMEM_EX_Data[7 : 0]};
          2'b01: wPE57_DMEM_EX_Data = {24'b0, iPE57_DMEM_EX_Data[15: 8]};
          2'b10: wPE57_DMEM_EX_Data = {24'b0, iPE57_DMEM_EX_Data[23:16]};
          2'b11: wPE57_DMEM_EX_Data = {24'b0, iPE57_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE57_DMEM_EX_Data = iPE57_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 58
  assign oPE58_DMEM_Valid       = oPE58_AGU_DMEM_Write_Enable || oPE58_AGU_DMEM_Read_Enable;
  assign oPE58_AGU_DMEM_Address = wPE58_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE58_AGU_DMEM_Opcode        <= 'b0;
        PR_PE58_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE58_AGU_DMEM_Read_Enable )
      begin
        PR_PE58_AGU_DMEM_Opcode        <= wPE58_AGU_DMEM_Opcode;
        PR_PE58_AGU_DMEM_Addr_Last_Two <= wPE58_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE58_AGU_DMEM_Opcode or PR_PE58_AGU_DMEM_Addr_Last_Two or iPE58_DMEM_EX_Data )
    case ( PR_PE58_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE58_DMEM_EX_Data = iPE58_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE58_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE58_DMEM_EX_Data = {16'b0, iPE58_DMEM_EX_Data[15:0]};
        else
          wPE58_DMEM_EX_Data = {16'b0, iPE58_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE58_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE58_DMEM_EX_Data = {24'b0, iPE58_DMEM_EX_Data[7 : 0]};
          2'b01: wPE58_DMEM_EX_Data = {24'b0, iPE58_DMEM_EX_Data[15: 8]};
          2'b10: wPE58_DMEM_EX_Data = {24'b0, iPE58_DMEM_EX_Data[23:16]};
          2'b11: wPE58_DMEM_EX_Data = {24'b0, iPE58_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE58_DMEM_EX_Data = iPE58_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 59
  assign oPE59_DMEM_Valid       = oPE59_AGU_DMEM_Write_Enable || oPE59_AGU_DMEM_Read_Enable;
  assign oPE59_AGU_DMEM_Address = wPE59_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE59_AGU_DMEM_Opcode        <= 'b0;
        PR_PE59_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE59_AGU_DMEM_Read_Enable )
      begin
        PR_PE59_AGU_DMEM_Opcode        <= wPE59_AGU_DMEM_Opcode;
        PR_PE59_AGU_DMEM_Addr_Last_Two <= wPE59_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE59_AGU_DMEM_Opcode or PR_PE59_AGU_DMEM_Addr_Last_Two or iPE59_DMEM_EX_Data )
    case ( PR_PE59_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE59_DMEM_EX_Data = iPE59_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE59_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE59_DMEM_EX_Data = {16'b0, iPE59_DMEM_EX_Data[15:0]};
        else
          wPE59_DMEM_EX_Data = {16'b0, iPE59_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE59_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE59_DMEM_EX_Data = {24'b0, iPE59_DMEM_EX_Data[7 : 0]};
          2'b01: wPE59_DMEM_EX_Data = {24'b0, iPE59_DMEM_EX_Data[15: 8]};
          2'b10: wPE59_DMEM_EX_Data = {24'b0, iPE59_DMEM_EX_Data[23:16]};
          2'b11: wPE59_DMEM_EX_Data = {24'b0, iPE59_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE59_DMEM_EX_Data = iPE59_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 60
  assign oPE60_DMEM_Valid       = oPE60_AGU_DMEM_Write_Enable || oPE60_AGU_DMEM_Read_Enable;
  assign oPE60_AGU_DMEM_Address = wPE60_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE60_AGU_DMEM_Opcode        <= 'b0;
        PR_PE60_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE60_AGU_DMEM_Read_Enable )
      begin
        PR_PE60_AGU_DMEM_Opcode        <= wPE60_AGU_DMEM_Opcode;
        PR_PE60_AGU_DMEM_Addr_Last_Two <= wPE60_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE60_AGU_DMEM_Opcode or PR_PE60_AGU_DMEM_Addr_Last_Two or iPE60_DMEM_EX_Data )
    case ( PR_PE60_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE60_DMEM_EX_Data = iPE60_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE60_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE60_DMEM_EX_Data = {16'b0, iPE60_DMEM_EX_Data[15:0]};
        else
          wPE60_DMEM_EX_Data = {16'b0, iPE60_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE60_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE60_DMEM_EX_Data = {24'b0, iPE60_DMEM_EX_Data[7 : 0]};
          2'b01: wPE60_DMEM_EX_Data = {24'b0, iPE60_DMEM_EX_Data[15: 8]};
          2'b10: wPE60_DMEM_EX_Data = {24'b0, iPE60_DMEM_EX_Data[23:16]};
          2'b11: wPE60_DMEM_EX_Data = {24'b0, iPE60_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE60_DMEM_EX_Data = iPE60_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 61
  assign oPE61_DMEM_Valid       = oPE61_AGU_DMEM_Write_Enable || oPE61_AGU_DMEM_Read_Enable;
  assign oPE61_AGU_DMEM_Address = wPE61_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE61_AGU_DMEM_Opcode        <= 'b0;
        PR_PE61_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE61_AGU_DMEM_Read_Enable )
      begin
        PR_PE61_AGU_DMEM_Opcode        <= wPE61_AGU_DMEM_Opcode;
        PR_PE61_AGU_DMEM_Addr_Last_Two <= wPE61_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE61_AGU_DMEM_Opcode or PR_PE61_AGU_DMEM_Addr_Last_Two or iPE61_DMEM_EX_Data )
    case ( PR_PE61_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE61_DMEM_EX_Data = iPE61_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE61_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE61_DMEM_EX_Data = {16'b0, iPE61_DMEM_EX_Data[15:0]};
        else
          wPE61_DMEM_EX_Data = {16'b0, iPE61_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE61_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE61_DMEM_EX_Data = {24'b0, iPE61_DMEM_EX_Data[7 : 0]};
          2'b01: wPE61_DMEM_EX_Data = {24'b0, iPE61_DMEM_EX_Data[15: 8]};
          2'b10: wPE61_DMEM_EX_Data = {24'b0, iPE61_DMEM_EX_Data[23:16]};
          2'b11: wPE61_DMEM_EX_Data = {24'b0, iPE61_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE61_DMEM_EX_Data = iPE61_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 62
  assign oPE62_DMEM_Valid       = oPE62_AGU_DMEM_Write_Enable || oPE62_AGU_DMEM_Read_Enable;
  assign oPE62_AGU_DMEM_Address = wPE62_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE62_AGU_DMEM_Opcode        <= 'b0;
        PR_PE62_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE62_AGU_DMEM_Read_Enable )
      begin
        PR_PE62_AGU_DMEM_Opcode        <= wPE62_AGU_DMEM_Opcode;
        PR_PE62_AGU_DMEM_Addr_Last_Two <= wPE62_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE62_AGU_DMEM_Opcode or PR_PE62_AGU_DMEM_Addr_Last_Two or iPE62_DMEM_EX_Data )
    case ( PR_PE62_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE62_DMEM_EX_Data = iPE62_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE62_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE62_DMEM_EX_Data = {16'b0, iPE62_DMEM_EX_Data[15:0]};
        else
          wPE62_DMEM_EX_Data = {16'b0, iPE62_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE62_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE62_DMEM_EX_Data = {24'b0, iPE62_DMEM_EX_Data[7 : 0]};
          2'b01: wPE62_DMEM_EX_Data = {24'b0, iPE62_DMEM_EX_Data[15: 8]};
          2'b10: wPE62_DMEM_EX_Data = {24'b0, iPE62_DMEM_EX_Data[23:16]};
          2'b11: wPE62_DMEM_EX_Data = {24'b0, iPE62_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE62_DMEM_EX_Data = iPE62_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 63
  assign oPE63_DMEM_Valid       = oPE63_AGU_DMEM_Write_Enable || oPE63_AGU_DMEM_Read_Enable;
  assign oPE63_AGU_DMEM_Address = wPE63_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE63_AGU_DMEM_Opcode        <= 'b0;
        PR_PE63_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE63_AGU_DMEM_Read_Enable )
      begin
        PR_PE63_AGU_DMEM_Opcode        <= wPE63_AGU_DMEM_Opcode;
        PR_PE63_AGU_DMEM_Addr_Last_Two <= wPE63_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE63_AGU_DMEM_Opcode or PR_PE63_AGU_DMEM_Addr_Last_Two or iPE63_DMEM_EX_Data )
    case ( PR_PE63_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE63_DMEM_EX_Data = iPE63_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE63_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE63_DMEM_EX_Data = {16'b0, iPE63_DMEM_EX_Data[15:0]};
        else
          wPE63_DMEM_EX_Data = {16'b0, iPE63_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE63_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE63_DMEM_EX_Data = {24'b0, iPE63_DMEM_EX_Data[7 : 0]};
          2'b01: wPE63_DMEM_EX_Data = {24'b0, iPE63_DMEM_EX_Data[15: 8]};
          2'b10: wPE63_DMEM_EX_Data = {24'b0, iPE63_DMEM_EX_Data[23:16]};
          2'b11: wPE63_DMEM_EX_Data = {24'b0, iPE63_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE63_DMEM_EX_Data = iPE63_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 64
  assign oPE64_DMEM_Valid       = oPE64_AGU_DMEM_Write_Enable || oPE64_AGU_DMEM_Read_Enable;
  assign oPE64_AGU_DMEM_Address = wPE64_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE64_AGU_DMEM_Opcode        <= 'b0;
        PR_PE64_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE64_AGU_DMEM_Read_Enable )
      begin
        PR_PE64_AGU_DMEM_Opcode        <= wPE64_AGU_DMEM_Opcode;
        PR_PE64_AGU_DMEM_Addr_Last_Two <= wPE64_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE64_AGU_DMEM_Opcode or PR_PE64_AGU_DMEM_Addr_Last_Two or iPE64_DMEM_EX_Data )
    case ( PR_PE64_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE64_DMEM_EX_Data = iPE64_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE64_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE64_DMEM_EX_Data = {16'b0, iPE64_DMEM_EX_Data[15:0]};
        else
          wPE64_DMEM_EX_Data = {16'b0, iPE64_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE64_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE64_DMEM_EX_Data = {24'b0, iPE64_DMEM_EX_Data[7 : 0]};
          2'b01: wPE64_DMEM_EX_Data = {24'b0, iPE64_DMEM_EX_Data[15: 8]};
          2'b10: wPE64_DMEM_EX_Data = {24'b0, iPE64_DMEM_EX_Data[23:16]};
          2'b11: wPE64_DMEM_EX_Data = {24'b0, iPE64_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE64_DMEM_EX_Data = iPE64_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 65
  assign oPE65_DMEM_Valid       = oPE65_AGU_DMEM_Write_Enable || oPE65_AGU_DMEM_Read_Enable;
  assign oPE65_AGU_DMEM_Address = wPE65_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE65_AGU_DMEM_Opcode        <= 'b0;
        PR_PE65_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE65_AGU_DMEM_Read_Enable )
      begin
        PR_PE65_AGU_DMEM_Opcode        <= wPE65_AGU_DMEM_Opcode;
        PR_PE65_AGU_DMEM_Addr_Last_Two <= wPE65_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE65_AGU_DMEM_Opcode or PR_PE65_AGU_DMEM_Addr_Last_Two or iPE65_DMEM_EX_Data )
    case ( PR_PE65_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE65_DMEM_EX_Data = iPE65_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE65_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE65_DMEM_EX_Data = {16'b0, iPE65_DMEM_EX_Data[15:0]};
        else
          wPE65_DMEM_EX_Data = {16'b0, iPE65_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE65_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE65_DMEM_EX_Data = {24'b0, iPE65_DMEM_EX_Data[7 : 0]};
          2'b01: wPE65_DMEM_EX_Data = {24'b0, iPE65_DMEM_EX_Data[15: 8]};
          2'b10: wPE65_DMEM_EX_Data = {24'b0, iPE65_DMEM_EX_Data[23:16]};
          2'b11: wPE65_DMEM_EX_Data = {24'b0, iPE65_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE65_DMEM_EX_Data = iPE65_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 66
  assign oPE66_DMEM_Valid       = oPE66_AGU_DMEM_Write_Enable || oPE66_AGU_DMEM_Read_Enable;
  assign oPE66_AGU_DMEM_Address = wPE66_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE66_AGU_DMEM_Opcode        <= 'b0;
        PR_PE66_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE66_AGU_DMEM_Read_Enable )
      begin
        PR_PE66_AGU_DMEM_Opcode        <= wPE66_AGU_DMEM_Opcode;
        PR_PE66_AGU_DMEM_Addr_Last_Two <= wPE66_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE66_AGU_DMEM_Opcode or PR_PE66_AGU_DMEM_Addr_Last_Two or iPE66_DMEM_EX_Data )
    case ( PR_PE66_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE66_DMEM_EX_Data = iPE66_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE66_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE66_DMEM_EX_Data = {16'b0, iPE66_DMEM_EX_Data[15:0]};
        else
          wPE66_DMEM_EX_Data = {16'b0, iPE66_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE66_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE66_DMEM_EX_Data = {24'b0, iPE66_DMEM_EX_Data[7 : 0]};
          2'b01: wPE66_DMEM_EX_Data = {24'b0, iPE66_DMEM_EX_Data[15: 8]};
          2'b10: wPE66_DMEM_EX_Data = {24'b0, iPE66_DMEM_EX_Data[23:16]};
          2'b11: wPE66_DMEM_EX_Data = {24'b0, iPE66_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE66_DMEM_EX_Data = iPE66_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 67
  assign oPE67_DMEM_Valid       = oPE67_AGU_DMEM_Write_Enable || oPE67_AGU_DMEM_Read_Enable;
  assign oPE67_AGU_DMEM_Address = wPE67_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE67_AGU_DMEM_Opcode        <= 'b0;
        PR_PE67_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE67_AGU_DMEM_Read_Enable )
      begin
        PR_PE67_AGU_DMEM_Opcode        <= wPE67_AGU_DMEM_Opcode;
        PR_PE67_AGU_DMEM_Addr_Last_Two <= wPE67_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE67_AGU_DMEM_Opcode or PR_PE67_AGU_DMEM_Addr_Last_Two or iPE67_DMEM_EX_Data )
    case ( PR_PE67_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE67_DMEM_EX_Data = iPE67_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE67_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE67_DMEM_EX_Data = {16'b0, iPE67_DMEM_EX_Data[15:0]};
        else
          wPE67_DMEM_EX_Data = {16'b0, iPE67_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE67_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE67_DMEM_EX_Data = {24'b0, iPE67_DMEM_EX_Data[7 : 0]};
          2'b01: wPE67_DMEM_EX_Data = {24'b0, iPE67_DMEM_EX_Data[15: 8]};
          2'b10: wPE67_DMEM_EX_Data = {24'b0, iPE67_DMEM_EX_Data[23:16]};
          2'b11: wPE67_DMEM_EX_Data = {24'b0, iPE67_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE67_DMEM_EX_Data = iPE67_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 68
  assign oPE68_DMEM_Valid       = oPE68_AGU_DMEM_Write_Enable || oPE68_AGU_DMEM_Read_Enable;
  assign oPE68_AGU_DMEM_Address = wPE68_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE68_AGU_DMEM_Opcode        <= 'b0;
        PR_PE68_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE68_AGU_DMEM_Read_Enable )
      begin
        PR_PE68_AGU_DMEM_Opcode        <= wPE68_AGU_DMEM_Opcode;
        PR_PE68_AGU_DMEM_Addr_Last_Two <= wPE68_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE68_AGU_DMEM_Opcode or PR_PE68_AGU_DMEM_Addr_Last_Two or iPE68_DMEM_EX_Data )
    case ( PR_PE68_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE68_DMEM_EX_Data = iPE68_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE68_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE68_DMEM_EX_Data = {16'b0, iPE68_DMEM_EX_Data[15:0]};
        else
          wPE68_DMEM_EX_Data = {16'b0, iPE68_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE68_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE68_DMEM_EX_Data = {24'b0, iPE68_DMEM_EX_Data[7 : 0]};
          2'b01: wPE68_DMEM_EX_Data = {24'b0, iPE68_DMEM_EX_Data[15: 8]};
          2'b10: wPE68_DMEM_EX_Data = {24'b0, iPE68_DMEM_EX_Data[23:16]};
          2'b11: wPE68_DMEM_EX_Data = {24'b0, iPE68_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE68_DMEM_EX_Data = iPE68_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 69
  assign oPE69_DMEM_Valid       = oPE69_AGU_DMEM_Write_Enable || oPE69_AGU_DMEM_Read_Enable;
  assign oPE69_AGU_DMEM_Address = wPE69_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE69_AGU_DMEM_Opcode        <= 'b0;
        PR_PE69_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE69_AGU_DMEM_Read_Enable )
      begin
        PR_PE69_AGU_DMEM_Opcode        <= wPE69_AGU_DMEM_Opcode;
        PR_PE69_AGU_DMEM_Addr_Last_Two <= wPE69_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE69_AGU_DMEM_Opcode or PR_PE69_AGU_DMEM_Addr_Last_Two or iPE69_DMEM_EX_Data )
    case ( PR_PE69_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE69_DMEM_EX_Data = iPE69_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE69_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE69_DMEM_EX_Data = {16'b0, iPE69_DMEM_EX_Data[15:0]};
        else
          wPE69_DMEM_EX_Data = {16'b0, iPE69_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE69_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE69_DMEM_EX_Data = {24'b0, iPE69_DMEM_EX_Data[7 : 0]};
          2'b01: wPE69_DMEM_EX_Data = {24'b0, iPE69_DMEM_EX_Data[15: 8]};
          2'b10: wPE69_DMEM_EX_Data = {24'b0, iPE69_DMEM_EX_Data[23:16]};
          2'b11: wPE69_DMEM_EX_Data = {24'b0, iPE69_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE69_DMEM_EX_Data = iPE69_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 70
  assign oPE70_DMEM_Valid       = oPE70_AGU_DMEM_Write_Enable || oPE70_AGU_DMEM_Read_Enable;
  assign oPE70_AGU_DMEM_Address = wPE70_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE70_AGU_DMEM_Opcode        <= 'b0;
        PR_PE70_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE70_AGU_DMEM_Read_Enable )
      begin
        PR_PE70_AGU_DMEM_Opcode        <= wPE70_AGU_DMEM_Opcode;
        PR_PE70_AGU_DMEM_Addr_Last_Two <= wPE70_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE70_AGU_DMEM_Opcode or PR_PE70_AGU_DMEM_Addr_Last_Two or iPE70_DMEM_EX_Data )
    case ( PR_PE70_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE70_DMEM_EX_Data = iPE70_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE70_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE70_DMEM_EX_Data = {16'b0, iPE70_DMEM_EX_Data[15:0]};
        else
          wPE70_DMEM_EX_Data = {16'b0, iPE70_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE70_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE70_DMEM_EX_Data = {24'b0, iPE70_DMEM_EX_Data[7 : 0]};
          2'b01: wPE70_DMEM_EX_Data = {24'b0, iPE70_DMEM_EX_Data[15: 8]};
          2'b10: wPE70_DMEM_EX_Data = {24'b0, iPE70_DMEM_EX_Data[23:16]};
          2'b11: wPE70_DMEM_EX_Data = {24'b0, iPE70_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE70_DMEM_EX_Data = iPE70_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 71
  assign oPE71_DMEM_Valid       = oPE71_AGU_DMEM_Write_Enable || oPE71_AGU_DMEM_Read_Enable;
  assign oPE71_AGU_DMEM_Address = wPE71_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE71_AGU_DMEM_Opcode        <= 'b0;
        PR_PE71_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE71_AGU_DMEM_Read_Enable )
      begin
        PR_PE71_AGU_DMEM_Opcode        <= wPE71_AGU_DMEM_Opcode;
        PR_PE71_AGU_DMEM_Addr_Last_Two <= wPE71_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE71_AGU_DMEM_Opcode or PR_PE71_AGU_DMEM_Addr_Last_Two or iPE71_DMEM_EX_Data )
    case ( PR_PE71_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE71_DMEM_EX_Data = iPE71_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE71_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE71_DMEM_EX_Data = {16'b0, iPE71_DMEM_EX_Data[15:0]};
        else
          wPE71_DMEM_EX_Data = {16'b0, iPE71_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE71_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE71_DMEM_EX_Data = {24'b0, iPE71_DMEM_EX_Data[7 : 0]};
          2'b01: wPE71_DMEM_EX_Data = {24'b0, iPE71_DMEM_EX_Data[15: 8]};
          2'b10: wPE71_DMEM_EX_Data = {24'b0, iPE71_DMEM_EX_Data[23:16]};
          2'b11: wPE71_DMEM_EX_Data = {24'b0, iPE71_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE71_DMEM_EX_Data = iPE71_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 72
  assign oPE72_DMEM_Valid       = oPE72_AGU_DMEM_Write_Enable || oPE72_AGU_DMEM_Read_Enable;
  assign oPE72_AGU_DMEM_Address = wPE72_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE72_AGU_DMEM_Opcode        <= 'b0;
        PR_PE72_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE72_AGU_DMEM_Read_Enable )
      begin
        PR_PE72_AGU_DMEM_Opcode        <= wPE72_AGU_DMEM_Opcode;
        PR_PE72_AGU_DMEM_Addr_Last_Two <= wPE72_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE72_AGU_DMEM_Opcode or PR_PE72_AGU_DMEM_Addr_Last_Two or iPE72_DMEM_EX_Data )
    case ( PR_PE72_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE72_DMEM_EX_Data = iPE72_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE72_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE72_DMEM_EX_Data = {16'b0, iPE72_DMEM_EX_Data[15:0]};
        else
          wPE72_DMEM_EX_Data = {16'b0, iPE72_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE72_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE72_DMEM_EX_Data = {24'b0, iPE72_DMEM_EX_Data[7 : 0]};
          2'b01: wPE72_DMEM_EX_Data = {24'b0, iPE72_DMEM_EX_Data[15: 8]};
          2'b10: wPE72_DMEM_EX_Data = {24'b0, iPE72_DMEM_EX_Data[23:16]};
          2'b11: wPE72_DMEM_EX_Data = {24'b0, iPE72_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE72_DMEM_EX_Data = iPE72_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 73
  assign oPE73_DMEM_Valid       = oPE73_AGU_DMEM_Write_Enable || oPE73_AGU_DMEM_Read_Enable;
  assign oPE73_AGU_DMEM_Address = wPE73_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE73_AGU_DMEM_Opcode        <= 'b0;
        PR_PE73_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE73_AGU_DMEM_Read_Enable )
      begin
        PR_PE73_AGU_DMEM_Opcode        <= wPE73_AGU_DMEM_Opcode;
        PR_PE73_AGU_DMEM_Addr_Last_Two <= wPE73_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE73_AGU_DMEM_Opcode or PR_PE73_AGU_DMEM_Addr_Last_Two or iPE73_DMEM_EX_Data )
    case ( PR_PE73_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE73_DMEM_EX_Data = iPE73_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE73_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE73_DMEM_EX_Data = {16'b0, iPE73_DMEM_EX_Data[15:0]};
        else
          wPE73_DMEM_EX_Data = {16'b0, iPE73_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE73_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE73_DMEM_EX_Data = {24'b0, iPE73_DMEM_EX_Data[7 : 0]};
          2'b01: wPE73_DMEM_EX_Data = {24'b0, iPE73_DMEM_EX_Data[15: 8]};
          2'b10: wPE73_DMEM_EX_Data = {24'b0, iPE73_DMEM_EX_Data[23:16]};
          2'b11: wPE73_DMEM_EX_Data = {24'b0, iPE73_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE73_DMEM_EX_Data = iPE73_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 74
  assign oPE74_DMEM_Valid       = oPE74_AGU_DMEM_Write_Enable || oPE74_AGU_DMEM_Read_Enable;
  assign oPE74_AGU_DMEM_Address = wPE74_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE74_AGU_DMEM_Opcode        <= 'b0;
        PR_PE74_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE74_AGU_DMEM_Read_Enable )
      begin
        PR_PE74_AGU_DMEM_Opcode        <= wPE74_AGU_DMEM_Opcode;
        PR_PE74_AGU_DMEM_Addr_Last_Two <= wPE74_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE74_AGU_DMEM_Opcode or PR_PE74_AGU_DMEM_Addr_Last_Two or iPE74_DMEM_EX_Data )
    case ( PR_PE74_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE74_DMEM_EX_Data = iPE74_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE74_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE74_DMEM_EX_Data = {16'b0, iPE74_DMEM_EX_Data[15:0]};
        else
          wPE74_DMEM_EX_Data = {16'b0, iPE74_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE74_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE74_DMEM_EX_Data = {24'b0, iPE74_DMEM_EX_Data[7 : 0]};
          2'b01: wPE74_DMEM_EX_Data = {24'b0, iPE74_DMEM_EX_Data[15: 8]};
          2'b10: wPE74_DMEM_EX_Data = {24'b0, iPE74_DMEM_EX_Data[23:16]};
          2'b11: wPE74_DMEM_EX_Data = {24'b0, iPE74_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE74_DMEM_EX_Data = iPE74_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 75
  assign oPE75_DMEM_Valid       = oPE75_AGU_DMEM_Write_Enable || oPE75_AGU_DMEM_Read_Enable;
  assign oPE75_AGU_DMEM_Address = wPE75_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE75_AGU_DMEM_Opcode        <= 'b0;
        PR_PE75_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE75_AGU_DMEM_Read_Enable )
      begin
        PR_PE75_AGU_DMEM_Opcode        <= wPE75_AGU_DMEM_Opcode;
        PR_PE75_AGU_DMEM_Addr_Last_Two <= wPE75_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE75_AGU_DMEM_Opcode or PR_PE75_AGU_DMEM_Addr_Last_Two or iPE75_DMEM_EX_Data )
    case ( PR_PE75_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE75_DMEM_EX_Data = iPE75_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE75_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE75_DMEM_EX_Data = {16'b0, iPE75_DMEM_EX_Data[15:0]};
        else
          wPE75_DMEM_EX_Data = {16'b0, iPE75_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE75_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE75_DMEM_EX_Data = {24'b0, iPE75_DMEM_EX_Data[7 : 0]};
          2'b01: wPE75_DMEM_EX_Data = {24'b0, iPE75_DMEM_EX_Data[15: 8]};
          2'b10: wPE75_DMEM_EX_Data = {24'b0, iPE75_DMEM_EX_Data[23:16]};
          2'b11: wPE75_DMEM_EX_Data = {24'b0, iPE75_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE75_DMEM_EX_Data = iPE75_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 76
  assign oPE76_DMEM_Valid       = oPE76_AGU_DMEM_Write_Enable || oPE76_AGU_DMEM_Read_Enable;
  assign oPE76_AGU_DMEM_Address = wPE76_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE76_AGU_DMEM_Opcode        <= 'b0;
        PR_PE76_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE76_AGU_DMEM_Read_Enable )
      begin
        PR_PE76_AGU_DMEM_Opcode        <= wPE76_AGU_DMEM_Opcode;
        PR_PE76_AGU_DMEM_Addr_Last_Two <= wPE76_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE76_AGU_DMEM_Opcode or PR_PE76_AGU_DMEM_Addr_Last_Two or iPE76_DMEM_EX_Data )
    case ( PR_PE76_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE76_DMEM_EX_Data = iPE76_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE76_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE76_DMEM_EX_Data = {16'b0, iPE76_DMEM_EX_Data[15:0]};
        else
          wPE76_DMEM_EX_Data = {16'b0, iPE76_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE76_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE76_DMEM_EX_Data = {24'b0, iPE76_DMEM_EX_Data[7 : 0]};
          2'b01: wPE76_DMEM_EX_Data = {24'b0, iPE76_DMEM_EX_Data[15: 8]};
          2'b10: wPE76_DMEM_EX_Data = {24'b0, iPE76_DMEM_EX_Data[23:16]};
          2'b11: wPE76_DMEM_EX_Data = {24'b0, iPE76_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE76_DMEM_EX_Data = iPE76_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 77
  assign oPE77_DMEM_Valid       = oPE77_AGU_DMEM_Write_Enable || oPE77_AGU_DMEM_Read_Enable;
  assign oPE77_AGU_DMEM_Address = wPE77_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE77_AGU_DMEM_Opcode        <= 'b0;
        PR_PE77_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE77_AGU_DMEM_Read_Enable )
      begin
        PR_PE77_AGU_DMEM_Opcode        <= wPE77_AGU_DMEM_Opcode;
        PR_PE77_AGU_DMEM_Addr_Last_Two <= wPE77_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE77_AGU_DMEM_Opcode or PR_PE77_AGU_DMEM_Addr_Last_Two or iPE77_DMEM_EX_Data )
    case ( PR_PE77_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE77_DMEM_EX_Data = iPE77_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE77_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE77_DMEM_EX_Data = {16'b0, iPE77_DMEM_EX_Data[15:0]};
        else
          wPE77_DMEM_EX_Data = {16'b0, iPE77_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE77_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE77_DMEM_EX_Data = {24'b0, iPE77_DMEM_EX_Data[7 : 0]};
          2'b01: wPE77_DMEM_EX_Data = {24'b0, iPE77_DMEM_EX_Data[15: 8]};
          2'b10: wPE77_DMEM_EX_Data = {24'b0, iPE77_DMEM_EX_Data[23:16]};
          2'b11: wPE77_DMEM_EX_Data = {24'b0, iPE77_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE77_DMEM_EX_Data = iPE77_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 78
  assign oPE78_DMEM_Valid       = oPE78_AGU_DMEM_Write_Enable || oPE78_AGU_DMEM_Read_Enable;
  assign oPE78_AGU_DMEM_Address = wPE78_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE78_AGU_DMEM_Opcode        <= 'b0;
        PR_PE78_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE78_AGU_DMEM_Read_Enable )
      begin
        PR_PE78_AGU_DMEM_Opcode        <= wPE78_AGU_DMEM_Opcode;
        PR_PE78_AGU_DMEM_Addr_Last_Two <= wPE78_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE78_AGU_DMEM_Opcode or PR_PE78_AGU_DMEM_Addr_Last_Two or iPE78_DMEM_EX_Data )
    case ( PR_PE78_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE78_DMEM_EX_Data = iPE78_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE78_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE78_DMEM_EX_Data = {16'b0, iPE78_DMEM_EX_Data[15:0]};
        else
          wPE78_DMEM_EX_Data = {16'b0, iPE78_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE78_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE78_DMEM_EX_Data = {24'b0, iPE78_DMEM_EX_Data[7 : 0]};
          2'b01: wPE78_DMEM_EX_Data = {24'b0, iPE78_DMEM_EX_Data[15: 8]};
          2'b10: wPE78_DMEM_EX_Data = {24'b0, iPE78_DMEM_EX_Data[23:16]};
          2'b11: wPE78_DMEM_EX_Data = {24'b0, iPE78_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE78_DMEM_EX_Data = iPE78_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 79
  assign oPE79_DMEM_Valid       = oPE79_AGU_DMEM_Write_Enable || oPE79_AGU_DMEM_Read_Enable;
  assign oPE79_AGU_DMEM_Address = wPE79_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE79_AGU_DMEM_Opcode        <= 'b0;
        PR_PE79_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE79_AGU_DMEM_Read_Enable )
      begin
        PR_PE79_AGU_DMEM_Opcode        <= wPE79_AGU_DMEM_Opcode;
        PR_PE79_AGU_DMEM_Addr_Last_Two <= wPE79_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE79_AGU_DMEM_Opcode or PR_PE79_AGU_DMEM_Addr_Last_Two or iPE79_DMEM_EX_Data )
    case ( PR_PE79_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE79_DMEM_EX_Data = iPE79_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE79_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE79_DMEM_EX_Data = {16'b0, iPE79_DMEM_EX_Data[15:0]};
        else
          wPE79_DMEM_EX_Data = {16'b0, iPE79_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE79_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE79_DMEM_EX_Data = {24'b0, iPE79_DMEM_EX_Data[7 : 0]};
          2'b01: wPE79_DMEM_EX_Data = {24'b0, iPE79_DMEM_EX_Data[15: 8]};
          2'b10: wPE79_DMEM_EX_Data = {24'b0, iPE79_DMEM_EX_Data[23:16]};
          2'b11: wPE79_DMEM_EX_Data = {24'b0, iPE79_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE79_DMEM_EX_Data = iPE79_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 80
  assign oPE80_DMEM_Valid       = oPE80_AGU_DMEM_Write_Enable || oPE80_AGU_DMEM_Read_Enable;
  assign oPE80_AGU_DMEM_Address = wPE80_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE80_AGU_DMEM_Opcode        <= 'b0;
        PR_PE80_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE80_AGU_DMEM_Read_Enable )
      begin
        PR_PE80_AGU_DMEM_Opcode        <= wPE80_AGU_DMEM_Opcode;
        PR_PE80_AGU_DMEM_Addr_Last_Two <= wPE80_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE80_AGU_DMEM_Opcode or PR_PE80_AGU_DMEM_Addr_Last_Two or iPE80_DMEM_EX_Data )
    case ( PR_PE80_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE80_DMEM_EX_Data = iPE80_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE80_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE80_DMEM_EX_Data = {16'b0, iPE80_DMEM_EX_Data[15:0]};
        else
          wPE80_DMEM_EX_Data = {16'b0, iPE80_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE80_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE80_DMEM_EX_Data = {24'b0, iPE80_DMEM_EX_Data[7 : 0]};
          2'b01: wPE80_DMEM_EX_Data = {24'b0, iPE80_DMEM_EX_Data[15: 8]};
          2'b10: wPE80_DMEM_EX_Data = {24'b0, iPE80_DMEM_EX_Data[23:16]};
          2'b11: wPE80_DMEM_EX_Data = {24'b0, iPE80_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE80_DMEM_EX_Data = iPE80_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 81
  assign oPE81_DMEM_Valid       = oPE81_AGU_DMEM_Write_Enable || oPE81_AGU_DMEM_Read_Enable;
  assign oPE81_AGU_DMEM_Address = wPE81_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE81_AGU_DMEM_Opcode        <= 'b0;
        PR_PE81_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE81_AGU_DMEM_Read_Enable )
      begin
        PR_PE81_AGU_DMEM_Opcode        <= wPE81_AGU_DMEM_Opcode;
        PR_PE81_AGU_DMEM_Addr_Last_Two <= wPE81_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE81_AGU_DMEM_Opcode or PR_PE81_AGU_DMEM_Addr_Last_Two or iPE81_DMEM_EX_Data )
    case ( PR_PE81_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE81_DMEM_EX_Data = iPE81_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE81_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE81_DMEM_EX_Data = {16'b0, iPE81_DMEM_EX_Data[15:0]};
        else
          wPE81_DMEM_EX_Data = {16'b0, iPE81_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE81_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE81_DMEM_EX_Data = {24'b0, iPE81_DMEM_EX_Data[7 : 0]};
          2'b01: wPE81_DMEM_EX_Data = {24'b0, iPE81_DMEM_EX_Data[15: 8]};
          2'b10: wPE81_DMEM_EX_Data = {24'b0, iPE81_DMEM_EX_Data[23:16]};
          2'b11: wPE81_DMEM_EX_Data = {24'b0, iPE81_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE81_DMEM_EX_Data = iPE81_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 82
  assign oPE82_DMEM_Valid       = oPE82_AGU_DMEM_Write_Enable || oPE82_AGU_DMEM_Read_Enable;
  assign oPE82_AGU_DMEM_Address = wPE82_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE82_AGU_DMEM_Opcode        <= 'b0;
        PR_PE82_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE82_AGU_DMEM_Read_Enable )
      begin
        PR_PE82_AGU_DMEM_Opcode        <= wPE82_AGU_DMEM_Opcode;
        PR_PE82_AGU_DMEM_Addr_Last_Two <= wPE82_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE82_AGU_DMEM_Opcode or PR_PE82_AGU_DMEM_Addr_Last_Two or iPE82_DMEM_EX_Data )
    case ( PR_PE82_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE82_DMEM_EX_Data = iPE82_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE82_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE82_DMEM_EX_Data = {16'b0, iPE82_DMEM_EX_Data[15:0]};
        else
          wPE82_DMEM_EX_Data = {16'b0, iPE82_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE82_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE82_DMEM_EX_Data = {24'b0, iPE82_DMEM_EX_Data[7 : 0]};
          2'b01: wPE82_DMEM_EX_Data = {24'b0, iPE82_DMEM_EX_Data[15: 8]};
          2'b10: wPE82_DMEM_EX_Data = {24'b0, iPE82_DMEM_EX_Data[23:16]};
          2'b11: wPE82_DMEM_EX_Data = {24'b0, iPE82_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE82_DMEM_EX_Data = iPE82_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 83
  assign oPE83_DMEM_Valid       = oPE83_AGU_DMEM_Write_Enable || oPE83_AGU_DMEM_Read_Enable;
  assign oPE83_AGU_DMEM_Address = wPE83_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE83_AGU_DMEM_Opcode        <= 'b0;
        PR_PE83_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE83_AGU_DMEM_Read_Enable )
      begin
        PR_PE83_AGU_DMEM_Opcode        <= wPE83_AGU_DMEM_Opcode;
        PR_PE83_AGU_DMEM_Addr_Last_Two <= wPE83_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE83_AGU_DMEM_Opcode or PR_PE83_AGU_DMEM_Addr_Last_Two or iPE83_DMEM_EX_Data )
    case ( PR_PE83_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE83_DMEM_EX_Data = iPE83_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE83_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE83_DMEM_EX_Data = {16'b0, iPE83_DMEM_EX_Data[15:0]};
        else
          wPE83_DMEM_EX_Data = {16'b0, iPE83_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE83_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE83_DMEM_EX_Data = {24'b0, iPE83_DMEM_EX_Data[7 : 0]};
          2'b01: wPE83_DMEM_EX_Data = {24'b0, iPE83_DMEM_EX_Data[15: 8]};
          2'b10: wPE83_DMEM_EX_Data = {24'b0, iPE83_DMEM_EX_Data[23:16]};
          2'b11: wPE83_DMEM_EX_Data = {24'b0, iPE83_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE83_DMEM_EX_Data = iPE83_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 84
  assign oPE84_DMEM_Valid       = oPE84_AGU_DMEM_Write_Enable || oPE84_AGU_DMEM_Read_Enable;
  assign oPE84_AGU_DMEM_Address = wPE84_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE84_AGU_DMEM_Opcode        <= 'b0;
        PR_PE84_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE84_AGU_DMEM_Read_Enable )
      begin
        PR_PE84_AGU_DMEM_Opcode        <= wPE84_AGU_DMEM_Opcode;
        PR_PE84_AGU_DMEM_Addr_Last_Two <= wPE84_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE84_AGU_DMEM_Opcode or PR_PE84_AGU_DMEM_Addr_Last_Two or iPE84_DMEM_EX_Data )
    case ( PR_PE84_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE84_DMEM_EX_Data = iPE84_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE84_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE84_DMEM_EX_Data = {16'b0, iPE84_DMEM_EX_Data[15:0]};
        else
          wPE84_DMEM_EX_Data = {16'b0, iPE84_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE84_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE84_DMEM_EX_Data = {24'b0, iPE84_DMEM_EX_Data[7 : 0]};
          2'b01: wPE84_DMEM_EX_Data = {24'b0, iPE84_DMEM_EX_Data[15: 8]};
          2'b10: wPE84_DMEM_EX_Data = {24'b0, iPE84_DMEM_EX_Data[23:16]};
          2'b11: wPE84_DMEM_EX_Data = {24'b0, iPE84_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE84_DMEM_EX_Data = iPE84_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 85
  assign oPE85_DMEM_Valid       = oPE85_AGU_DMEM_Write_Enable || oPE85_AGU_DMEM_Read_Enable;
  assign oPE85_AGU_DMEM_Address = wPE85_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE85_AGU_DMEM_Opcode        <= 'b0;
        PR_PE85_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE85_AGU_DMEM_Read_Enable )
      begin
        PR_PE85_AGU_DMEM_Opcode        <= wPE85_AGU_DMEM_Opcode;
        PR_PE85_AGU_DMEM_Addr_Last_Two <= wPE85_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE85_AGU_DMEM_Opcode or PR_PE85_AGU_DMEM_Addr_Last_Two or iPE85_DMEM_EX_Data )
    case ( PR_PE85_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE85_DMEM_EX_Data = iPE85_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE85_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE85_DMEM_EX_Data = {16'b0, iPE85_DMEM_EX_Data[15:0]};
        else
          wPE85_DMEM_EX_Data = {16'b0, iPE85_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE85_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE85_DMEM_EX_Data = {24'b0, iPE85_DMEM_EX_Data[7 : 0]};
          2'b01: wPE85_DMEM_EX_Data = {24'b0, iPE85_DMEM_EX_Data[15: 8]};
          2'b10: wPE85_DMEM_EX_Data = {24'b0, iPE85_DMEM_EX_Data[23:16]};
          2'b11: wPE85_DMEM_EX_Data = {24'b0, iPE85_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE85_DMEM_EX_Data = iPE85_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 86
  assign oPE86_DMEM_Valid       = oPE86_AGU_DMEM_Write_Enable || oPE86_AGU_DMEM_Read_Enable;
  assign oPE86_AGU_DMEM_Address = wPE86_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE86_AGU_DMEM_Opcode        <= 'b0;
        PR_PE86_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE86_AGU_DMEM_Read_Enable )
      begin
        PR_PE86_AGU_DMEM_Opcode        <= wPE86_AGU_DMEM_Opcode;
        PR_PE86_AGU_DMEM_Addr_Last_Two <= wPE86_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE86_AGU_DMEM_Opcode or PR_PE86_AGU_DMEM_Addr_Last_Two or iPE86_DMEM_EX_Data )
    case ( PR_PE86_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE86_DMEM_EX_Data = iPE86_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE86_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE86_DMEM_EX_Data = {16'b0, iPE86_DMEM_EX_Data[15:0]};
        else
          wPE86_DMEM_EX_Data = {16'b0, iPE86_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE86_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE86_DMEM_EX_Data = {24'b0, iPE86_DMEM_EX_Data[7 : 0]};
          2'b01: wPE86_DMEM_EX_Data = {24'b0, iPE86_DMEM_EX_Data[15: 8]};
          2'b10: wPE86_DMEM_EX_Data = {24'b0, iPE86_DMEM_EX_Data[23:16]};
          2'b11: wPE86_DMEM_EX_Data = {24'b0, iPE86_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE86_DMEM_EX_Data = iPE86_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 87
  assign oPE87_DMEM_Valid       = oPE87_AGU_DMEM_Write_Enable || oPE87_AGU_DMEM_Read_Enable;
  assign oPE87_AGU_DMEM_Address = wPE87_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE87_AGU_DMEM_Opcode        <= 'b0;
        PR_PE87_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE87_AGU_DMEM_Read_Enable )
      begin
        PR_PE87_AGU_DMEM_Opcode        <= wPE87_AGU_DMEM_Opcode;
        PR_PE87_AGU_DMEM_Addr_Last_Two <= wPE87_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE87_AGU_DMEM_Opcode or PR_PE87_AGU_DMEM_Addr_Last_Two or iPE87_DMEM_EX_Data )
    case ( PR_PE87_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE87_DMEM_EX_Data = iPE87_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE87_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE87_DMEM_EX_Data = {16'b0, iPE87_DMEM_EX_Data[15:0]};
        else
          wPE87_DMEM_EX_Data = {16'b0, iPE87_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE87_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE87_DMEM_EX_Data = {24'b0, iPE87_DMEM_EX_Data[7 : 0]};
          2'b01: wPE87_DMEM_EX_Data = {24'b0, iPE87_DMEM_EX_Data[15: 8]};
          2'b10: wPE87_DMEM_EX_Data = {24'b0, iPE87_DMEM_EX_Data[23:16]};
          2'b11: wPE87_DMEM_EX_Data = {24'b0, iPE87_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE87_DMEM_EX_Data = iPE87_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 88
  assign oPE88_DMEM_Valid       = oPE88_AGU_DMEM_Write_Enable || oPE88_AGU_DMEM_Read_Enable;
  assign oPE88_AGU_DMEM_Address = wPE88_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE88_AGU_DMEM_Opcode        <= 'b0;
        PR_PE88_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE88_AGU_DMEM_Read_Enable )
      begin
        PR_PE88_AGU_DMEM_Opcode        <= wPE88_AGU_DMEM_Opcode;
        PR_PE88_AGU_DMEM_Addr_Last_Two <= wPE88_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE88_AGU_DMEM_Opcode or PR_PE88_AGU_DMEM_Addr_Last_Two or iPE88_DMEM_EX_Data )
    case ( PR_PE88_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE88_DMEM_EX_Data = iPE88_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE88_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE88_DMEM_EX_Data = {16'b0, iPE88_DMEM_EX_Data[15:0]};
        else
          wPE88_DMEM_EX_Data = {16'b0, iPE88_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE88_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE88_DMEM_EX_Data = {24'b0, iPE88_DMEM_EX_Data[7 : 0]};
          2'b01: wPE88_DMEM_EX_Data = {24'b0, iPE88_DMEM_EX_Data[15: 8]};
          2'b10: wPE88_DMEM_EX_Data = {24'b0, iPE88_DMEM_EX_Data[23:16]};
          2'b11: wPE88_DMEM_EX_Data = {24'b0, iPE88_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE88_DMEM_EX_Data = iPE88_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 89
  assign oPE89_DMEM_Valid       = oPE89_AGU_DMEM_Write_Enable || oPE89_AGU_DMEM_Read_Enable;
  assign oPE89_AGU_DMEM_Address = wPE89_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE89_AGU_DMEM_Opcode        <= 'b0;
        PR_PE89_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE89_AGU_DMEM_Read_Enable )
      begin
        PR_PE89_AGU_DMEM_Opcode        <= wPE89_AGU_DMEM_Opcode;
        PR_PE89_AGU_DMEM_Addr_Last_Two <= wPE89_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE89_AGU_DMEM_Opcode or PR_PE89_AGU_DMEM_Addr_Last_Two or iPE89_DMEM_EX_Data )
    case ( PR_PE89_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE89_DMEM_EX_Data = iPE89_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE89_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE89_DMEM_EX_Data = {16'b0, iPE89_DMEM_EX_Data[15:0]};
        else
          wPE89_DMEM_EX_Data = {16'b0, iPE89_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE89_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE89_DMEM_EX_Data = {24'b0, iPE89_DMEM_EX_Data[7 : 0]};
          2'b01: wPE89_DMEM_EX_Data = {24'b0, iPE89_DMEM_EX_Data[15: 8]};
          2'b10: wPE89_DMEM_EX_Data = {24'b0, iPE89_DMEM_EX_Data[23:16]};
          2'b11: wPE89_DMEM_EX_Data = {24'b0, iPE89_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE89_DMEM_EX_Data = iPE89_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 90
  assign oPE90_DMEM_Valid       = oPE90_AGU_DMEM_Write_Enable || oPE90_AGU_DMEM_Read_Enable;
  assign oPE90_AGU_DMEM_Address = wPE90_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE90_AGU_DMEM_Opcode        <= 'b0;
        PR_PE90_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE90_AGU_DMEM_Read_Enable )
      begin
        PR_PE90_AGU_DMEM_Opcode        <= wPE90_AGU_DMEM_Opcode;
        PR_PE90_AGU_DMEM_Addr_Last_Two <= wPE90_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE90_AGU_DMEM_Opcode or PR_PE90_AGU_DMEM_Addr_Last_Two or iPE90_DMEM_EX_Data )
    case ( PR_PE90_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE90_DMEM_EX_Data = iPE90_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE90_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE90_DMEM_EX_Data = {16'b0, iPE90_DMEM_EX_Data[15:0]};
        else
          wPE90_DMEM_EX_Data = {16'b0, iPE90_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE90_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE90_DMEM_EX_Data = {24'b0, iPE90_DMEM_EX_Data[7 : 0]};
          2'b01: wPE90_DMEM_EX_Data = {24'b0, iPE90_DMEM_EX_Data[15: 8]};
          2'b10: wPE90_DMEM_EX_Data = {24'b0, iPE90_DMEM_EX_Data[23:16]};
          2'b11: wPE90_DMEM_EX_Data = {24'b0, iPE90_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE90_DMEM_EX_Data = iPE90_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 91
  assign oPE91_DMEM_Valid       = oPE91_AGU_DMEM_Write_Enable || oPE91_AGU_DMEM_Read_Enable;
  assign oPE91_AGU_DMEM_Address = wPE91_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE91_AGU_DMEM_Opcode        <= 'b0;
        PR_PE91_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE91_AGU_DMEM_Read_Enable )
      begin
        PR_PE91_AGU_DMEM_Opcode        <= wPE91_AGU_DMEM_Opcode;
        PR_PE91_AGU_DMEM_Addr_Last_Two <= wPE91_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE91_AGU_DMEM_Opcode or PR_PE91_AGU_DMEM_Addr_Last_Two or iPE91_DMEM_EX_Data )
    case ( PR_PE91_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE91_DMEM_EX_Data = iPE91_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE91_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE91_DMEM_EX_Data = {16'b0, iPE91_DMEM_EX_Data[15:0]};
        else
          wPE91_DMEM_EX_Data = {16'b0, iPE91_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE91_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE91_DMEM_EX_Data = {24'b0, iPE91_DMEM_EX_Data[7 : 0]};
          2'b01: wPE91_DMEM_EX_Data = {24'b0, iPE91_DMEM_EX_Data[15: 8]};
          2'b10: wPE91_DMEM_EX_Data = {24'b0, iPE91_DMEM_EX_Data[23:16]};
          2'b11: wPE91_DMEM_EX_Data = {24'b0, iPE91_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE91_DMEM_EX_Data = iPE91_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 92
  assign oPE92_DMEM_Valid       = oPE92_AGU_DMEM_Write_Enable || oPE92_AGU_DMEM_Read_Enable;
  assign oPE92_AGU_DMEM_Address = wPE92_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE92_AGU_DMEM_Opcode        <= 'b0;
        PR_PE92_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE92_AGU_DMEM_Read_Enable )
      begin
        PR_PE92_AGU_DMEM_Opcode        <= wPE92_AGU_DMEM_Opcode;
        PR_PE92_AGU_DMEM_Addr_Last_Two <= wPE92_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE92_AGU_DMEM_Opcode or PR_PE92_AGU_DMEM_Addr_Last_Two or iPE92_DMEM_EX_Data )
    case ( PR_PE92_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE92_DMEM_EX_Data = iPE92_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE92_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE92_DMEM_EX_Data = {16'b0, iPE92_DMEM_EX_Data[15:0]};
        else
          wPE92_DMEM_EX_Data = {16'b0, iPE92_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE92_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE92_DMEM_EX_Data = {24'b0, iPE92_DMEM_EX_Data[7 : 0]};
          2'b01: wPE92_DMEM_EX_Data = {24'b0, iPE92_DMEM_EX_Data[15: 8]};
          2'b10: wPE92_DMEM_EX_Data = {24'b0, iPE92_DMEM_EX_Data[23:16]};
          2'b11: wPE92_DMEM_EX_Data = {24'b0, iPE92_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE92_DMEM_EX_Data = iPE92_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 93
  assign oPE93_DMEM_Valid       = oPE93_AGU_DMEM_Write_Enable || oPE93_AGU_DMEM_Read_Enable;
  assign oPE93_AGU_DMEM_Address = wPE93_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE93_AGU_DMEM_Opcode        <= 'b0;
        PR_PE93_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE93_AGU_DMEM_Read_Enable )
      begin
        PR_PE93_AGU_DMEM_Opcode        <= wPE93_AGU_DMEM_Opcode;
        PR_PE93_AGU_DMEM_Addr_Last_Two <= wPE93_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE93_AGU_DMEM_Opcode or PR_PE93_AGU_DMEM_Addr_Last_Two or iPE93_DMEM_EX_Data )
    case ( PR_PE93_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE93_DMEM_EX_Data = iPE93_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE93_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE93_DMEM_EX_Data = {16'b0, iPE93_DMEM_EX_Data[15:0]};
        else
          wPE93_DMEM_EX_Data = {16'b0, iPE93_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE93_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE93_DMEM_EX_Data = {24'b0, iPE93_DMEM_EX_Data[7 : 0]};
          2'b01: wPE93_DMEM_EX_Data = {24'b0, iPE93_DMEM_EX_Data[15: 8]};
          2'b10: wPE93_DMEM_EX_Data = {24'b0, iPE93_DMEM_EX_Data[23:16]};
          2'b11: wPE93_DMEM_EX_Data = {24'b0, iPE93_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE93_DMEM_EX_Data = iPE93_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 94
  assign oPE94_DMEM_Valid       = oPE94_AGU_DMEM_Write_Enable || oPE94_AGU_DMEM_Read_Enable;
  assign oPE94_AGU_DMEM_Address = wPE94_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE94_AGU_DMEM_Opcode        <= 'b0;
        PR_PE94_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE94_AGU_DMEM_Read_Enable )
      begin
        PR_PE94_AGU_DMEM_Opcode        <= wPE94_AGU_DMEM_Opcode;
        PR_PE94_AGU_DMEM_Addr_Last_Two <= wPE94_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE94_AGU_DMEM_Opcode or PR_PE94_AGU_DMEM_Addr_Last_Two or iPE94_DMEM_EX_Data )
    case ( PR_PE94_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE94_DMEM_EX_Data = iPE94_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE94_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE94_DMEM_EX_Data = {16'b0, iPE94_DMEM_EX_Data[15:0]};
        else
          wPE94_DMEM_EX_Data = {16'b0, iPE94_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE94_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE94_DMEM_EX_Data = {24'b0, iPE94_DMEM_EX_Data[7 : 0]};
          2'b01: wPE94_DMEM_EX_Data = {24'b0, iPE94_DMEM_EX_Data[15: 8]};
          2'b10: wPE94_DMEM_EX_Data = {24'b0, iPE94_DMEM_EX_Data[23:16]};
          2'b11: wPE94_DMEM_EX_Data = {24'b0, iPE94_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE94_DMEM_EX_Data = iPE94_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 95
  assign oPE95_DMEM_Valid       = oPE95_AGU_DMEM_Write_Enable || oPE95_AGU_DMEM_Read_Enable;
  assign oPE95_AGU_DMEM_Address = wPE95_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE95_AGU_DMEM_Opcode        <= 'b0;
        PR_PE95_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE95_AGU_DMEM_Read_Enable )
      begin
        PR_PE95_AGU_DMEM_Opcode        <= wPE95_AGU_DMEM_Opcode;
        PR_PE95_AGU_DMEM_Addr_Last_Two <= wPE95_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE95_AGU_DMEM_Opcode or PR_PE95_AGU_DMEM_Addr_Last_Two or iPE95_DMEM_EX_Data )
    case ( PR_PE95_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE95_DMEM_EX_Data = iPE95_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE95_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE95_DMEM_EX_Data = {16'b0, iPE95_DMEM_EX_Data[15:0]};
        else
          wPE95_DMEM_EX_Data = {16'b0, iPE95_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE95_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE95_DMEM_EX_Data = {24'b0, iPE95_DMEM_EX_Data[7 : 0]};
          2'b01: wPE95_DMEM_EX_Data = {24'b0, iPE95_DMEM_EX_Data[15: 8]};
          2'b10: wPE95_DMEM_EX_Data = {24'b0, iPE95_DMEM_EX_Data[23:16]};
          2'b11: wPE95_DMEM_EX_Data = {24'b0, iPE95_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE95_DMEM_EX_Data = iPE95_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 96
  assign oPE96_DMEM_Valid       = oPE96_AGU_DMEM_Write_Enable || oPE96_AGU_DMEM_Read_Enable;
  assign oPE96_AGU_DMEM_Address = wPE96_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE96_AGU_DMEM_Opcode        <= 'b0;
        PR_PE96_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE96_AGU_DMEM_Read_Enable )
      begin
        PR_PE96_AGU_DMEM_Opcode        <= wPE96_AGU_DMEM_Opcode;
        PR_PE96_AGU_DMEM_Addr_Last_Two <= wPE96_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE96_AGU_DMEM_Opcode or PR_PE96_AGU_DMEM_Addr_Last_Two or iPE96_DMEM_EX_Data )
    case ( PR_PE96_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE96_DMEM_EX_Data = iPE96_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE96_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE96_DMEM_EX_Data = {16'b0, iPE96_DMEM_EX_Data[15:0]};
        else
          wPE96_DMEM_EX_Data = {16'b0, iPE96_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE96_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE96_DMEM_EX_Data = {24'b0, iPE96_DMEM_EX_Data[7 : 0]};
          2'b01: wPE96_DMEM_EX_Data = {24'b0, iPE96_DMEM_EX_Data[15: 8]};
          2'b10: wPE96_DMEM_EX_Data = {24'b0, iPE96_DMEM_EX_Data[23:16]};
          2'b11: wPE96_DMEM_EX_Data = {24'b0, iPE96_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE96_DMEM_EX_Data = iPE96_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 97
  assign oPE97_DMEM_Valid       = oPE97_AGU_DMEM_Write_Enable || oPE97_AGU_DMEM_Read_Enable;
  assign oPE97_AGU_DMEM_Address = wPE97_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE97_AGU_DMEM_Opcode        <= 'b0;
        PR_PE97_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE97_AGU_DMEM_Read_Enable )
      begin
        PR_PE97_AGU_DMEM_Opcode        <= wPE97_AGU_DMEM_Opcode;
        PR_PE97_AGU_DMEM_Addr_Last_Two <= wPE97_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE97_AGU_DMEM_Opcode or PR_PE97_AGU_DMEM_Addr_Last_Two or iPE97_DMEM_EX_Data )
    case ( PR_PE97_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE97_DMEM_EX_Data = iPE97_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE97_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE97_DMEM_EX_Data = {16'b0, iPE97_DMEM_EX_Data[15:0]};
        else
          wPE97_DMEM_EX_Data = {16'b0, iPE97_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE97_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE97_DMEM_EX_Data = {24'b0, iPE97_DMEM_EX_Data[7 : 0]};
          2'b01: wPE97_DMEM_EX_Data = {24'b0, iPE97_DMEM_EX_Data[15: 8]};
          2'b10: wPE97_DMEM_EX_Data = {24'b0, iPE97_DMEM_EX_Data[23:16]};
          2'b11: wPE97_DMEM_EX_Data = {24'b0, iPE97_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE97_DMEM_EX_Data = iPE97_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 98
  assign oPE98_DMEM_Valid       = oPE98_AGU_DMEM_Write_Enable || oPE98_AGU_DMEM_Read_Enable;
  assign oPE98_AGU_DMEM_Address = wPE98_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE98_AGU_DMEM_Opcode        <= 'b0;
        PR_PE98_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE98_AGU_DMEM_Read_Enable )
      begin
        PR_PE98_AGU_DMEM_Opcode        <= wPE98_AGU_DMEM_Opcode;
        PR_PE98_AGU_DMEM_Addr_Last_Two <= wPE98_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE98_AGU_DMEM_Opcode or PR_PE98_AGU_DMEM_Addr_Last_Two or iPE98_DMEM_EX_Data )
    case ( PR_PE98_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE98_DMEM_EX_Data = iPE98_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE98_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE98_DMEM_EX_Data = {16'b0, iPE98_DMEM_EX_Data[15:0]};
        else
          wPE98_DMEM_EX_Data = {16'b0, iPE98_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE98_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE98_DMEM_EX_Data = {24'b0, iPE98_DMEM_EX_Data[7 : 0]};
          2'b01: wPE98_DMEM_EX_Data = {24'b0, iPE98_DMEM_EX_Data[15: 8]};
          2'b10: wPE98_DMEM_EX_Data = {24'b0, iPE98_DMEM_EX_Data[23:16]};
          2'b11: wPE98_DMEM_EX_Data = {24'b0, iPE98_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE98_DMEM_EX_Data = iPE98_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 99
  assign oPE99_DMEM_Valid       = oPE99_AGU_DMEM_Write_Enable || oPE99_AGU_DMEM_Read_Enable;
  assign oPE99_AGU_DMEM_Address = wPE99_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE99_AGU_DMEM_Opcode        <= 'b0;
        PR_PE99_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE99_AGU_DMEM_Read_Enable )
      begin
        PR_PE99_AGU_DMEM_Opcode        <= wPE99_AGU_DMEM_Opcode;
        PR_PE99_AGU_DMEM_Addr_Last_Two <= wPE99_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE99_AGU_DMEM_Opcode or PR_PE99_AGU_DMEM_Addr_Last_Two or iPE99_DMEM_EX_Data )
    case ( PR_PE99_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE99_DMEM_EX_Data = iPE99_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE99_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE99_DMEM_EX_Data = {16'b0, iPE99_DMEM_EX_Data[15:0]};
        else
          wPE99_DMEM_EX_Data = {16'b0, iPE99_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE99_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE99_DMEM_EX_Data = {24'b0, iPE99_DMEM_EX_Data[7 : 0]};
          2'b01: wPE99_DMEM_EX_Data = {24'b0, iPE99_DMEM_EX_Data[15: 8]};
          2'b10: wPE99_DMEM_EX_Data = {24'b0, iPE99_DMEM_EX_Data[23:16]};
          2'b11: wPE99_DMEM_EX_Data = {24'b0, iPE99_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE99_DMEM_EX_Data = iPE99_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 100
  assign oPE100_DMEM_Valid       = oPE100_AGU_DMEM_Write_Enable || oPE100_AGU_DMEM_Read_Enable;
  assign oPE100_AGU_DMEM_Address = wPE100_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE100_AGU_DMEM_Opcode        <= 'b0;
        PR_PE100_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE100_AGU_DMEM_Read_Enable )
      begin
        PR_PE100_AGU_DMEM_Opcode        <= wPE100_AGU_DMEM_Opcode;
        PR_PE100_AGU_DMEM_Addr_Last_Two <= wPE100_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE100_AGU_DMEM_Opcode or PR_PE100_AGU_DMEM_Addr_Last_Two or iPE100_DMEM_EX_Data )
    case ( PR_PE100_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE100_DMEM_EX_Data = iPE100_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE100_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE100_DMEM_EX_Data = {16'b0, iPE100_DMEM_EX_Data[15:0]};
        else
          wPE100_DMEM_EX_Data = {16'b0, iPE100_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE100_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE100_DMEM_EX_Data = {24'b0, iPE100_DMEM_EX_Data[7 : 0]};
          2'b01: wPE100_DMEM_EX_Data = {24'b0, iPE100_DMEM_EX_Data[15: 8]};
          2'b10: wPE100_DMEM_EX_Data = {24'b0, iPE100_DMEM_EX_Data[23:16]};
          2'b11: wPE100_DMEM_EX_Data = {24'b0, iPE100_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE100_DMEM_EX_Data = iPE100_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 101
  assign oPE101_DMEM_Valid       = oPE101_AGU_DMEM_Write_Enable || oPE101_AGU_DMEM_Read_Enable;
  assign oPE101_AGU_DMEM_Address = wPE101_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE101_AGU_DMEM_Opcode        <= 'b0;
        PR_PE101_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE101_AGU_DMEM_Read_Enable )
      begin
        PR_PE101_AGU_DMEM_Opcode        <= wPE101_AGU_DMEM_Opcode;
        PR_PE101_AGU_DMEM_Addr_Last_Two <= wPE101_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE101_AGU_DMEM_Opcode or PR_PE101_AGU_DMEM_Addr_Last_Two or iPE101_DMEM_EX_Data )
    case ( PR_PE101_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE101_DMEM_EX_Data = iPE101_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE101_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE101_DMEM_EX_Data = {16'b0, iPE101_DMEM_EX_Data[15:0]};
        else
          wPE101_DMEM_EX_Data = {16'b0, iPE101_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE101_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE101_DMEM_EX_Data = {24'b0, iPE101_DMEM_EX_Data[7 : 0]};
          2'b01: wPE101_DMEM_EX_Data = {24'b0, iPE101_DMEM_EX_Data[15: 8]};
          2'b10: wPE101_DMEM_EX_Data = {24'b0, iPE101_DMEM_EX_Data[23:16]};
          2'b11: wPE101_DMEM_EX_Data = {24'b0, iPE101_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE101_DMEM_EX_Data = iPE101_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 102
  assign oPE102_DMEM_Valid       = oPE102_AGU_DMEM_Write_Enable || oPE102_AGU_DMEM_Read_Enable;
  assign oPE102_AGU_DMEM_Address = wPE102_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE102_AGU_DMEM_Opcode        <= 'b0;
        PR_PE102_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE102_AGU_DMEM_Read_Enable )
      begin
        PR_PE102_AGU_DMEM_Opcode        <= wPE102_AGU_DMEM_Opcode;
        PR_PE102_AGU_DMEM_Addr_Last_Two <= wPE102_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE102_AGU_DMEM_Opcode or PR_PE102_AGU_DMEM_Addr_Last_Two or iPE102_DMEM_EX_Data )
    case ( PR_PE102_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE102_DMEM_EX_Data = iPE102_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE102_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE102_DMEM_EX_Data = {16'b0, iPE102_DMEM_EX_Data[15:0]};
        else
          wPE102_DMEM_EX_Data = {16'b0, iPE102_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE102_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE102_DMEM_EX_Data = {24'b0, iPE102_DMEM_EX_Data[7 : 0]};
          2'b01: wPE102_DMEM_EX_Data = {24'b0, iPE102_DMEM_EX_Data[15: 8]};
          2'b10: wPE102_DMEM_EX_Data = {24'b0, iPE102_DMEM_EX_Data[23:16]};
          2'b11: wPE102_DMEM_EX_Data = {24'b0, iPE102_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE102_DMEM_EX_Data = iPE102_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 103
  assign oPE103_DMEM_Valid       = oPE103_AGU_DMEM_Write_Enable || oPE103_AGU_DMEM_Read_Enable;
  assign oPE103_AGU_DMEM_Address = wPE103_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE103_AGU_DMEM_Opcode        <= 'b0;
        PR_PE103_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE103_AGU_DMEM_Read_Enable )
      begin
        PR_PE103_AGU_DMEM_Opcode        <= wPE103_AGU_DMEM_Opcode;
        PR_PE103_AGU_DMEM_Addr_Last_Two <= wPE103_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE103_AGU_DMEM_Opcode or PR_PE103_AGU_DMEM_Addr_Last_Two or iPE103_DMEM_EX_Data )
    case ( PR_PE103_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE103_DMEM_EX_Data = iPE103_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE103_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE103_DMEM_EX_Data = {16'b0, iPE103_DMEM_EX_Data[15:0]};
        else
          wPE103_DMEM_EX_Data = {16'b0, iPE103_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE103_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE103_DMEM_EX_Data = {24'b0, iPE103_DMEM_EX_Data[7 : 0]};
          2'b01: wPE103_DMEM_EX_Data = {24'b0, iPE103_DMEM_EX_Data[15: 8]};
          2'b10: wPE103_DMEM_EX_Data = {24'b0, iPE103_DMEM_EX_Data[23:16]};
          2'b11: wPE103_DMEM_EX_Data = {24'b0, iPE103_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE103_DMEM_EX_Data = iPE103_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 104
  assign oPE104_DMEM_Valid       = oPE104_AGU_DMEM_Write_Enable || oPE104_AGU_DMEM_Read_Enable;
  assign oPE104_AGU_DMEM_Address = wPE104_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE104_AGU_DMEM_Opcode        <= 'b0;
        PR_PE104_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE104_AGU_DMEM_Read_Enable )
      begin
        PR_PE104_AGU_DMEM_Opcode        <= wPE104_AGU_DMEM_Opcode;
        PR_PE104_AGU_DMEM_Addr_Last_Two <= wPE104_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE104_AGU_DMEM_Opcode or PR_PE104_AGU_DMEM_Addr_Last_Two or iPE104_DMEM_EX_Data )
    case ( PR_PE104_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE104_DMEM_EX_Data = iPE104_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE104_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE104_DMEM_EX_Data = {16'b0, iPE104_DMEM_EX_Data[15:0]};
        else
          wPE104_DMEM_EX_Data = {16'b0, iPE104_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE104_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE104_DMEM_EX_Data = {24'b0, iPE104_DMEM_EX_Data[7 : 0]};
          2'b01: wPE104_DMEM_EX_Data = {24'b0, iPE104_DMEM_EX_Data[15: 8]};
          2'b10: wPE104_DMEM_EX_Data = {24'b0, iPE104_DMEM_EX_Data[23:16]};
          2'b11: wPE104_DMEM_EX_Data = {24'b0, iPE104_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE104_DMEM_EX_Data = iPE104_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 105
  assign oPE105_DMEM_Valid       = oPE105_AGU_DMEM_Write_Enable || oPE105_AGU_DMEM_Read_Enable;
  assign oPE105_AGU_DMEM_Address = wPE105_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE105_AGU_DMEM_Opcode        <= 'b0;
        PR_PE105_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE105_AGU_DMEM_Read_Enable )
      begin
        PR_PE105_AGU_DMEM_Opcode        <= wPE105_AGU_DMEM_Opcode;
        PR_PE105_AGU_DMEM_Addr_Last_Two <= wPE105_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE105_AGU_DMEM_Opcode or PR_PE105_AGU_DMEM_Addr_Last_Two or iPE105_DMEM_EX_Data )
    case ( PR_PE105_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE105_DMEM_EX_Data = iPE105_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE105_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE105_DMEM_EX_Data = {16'b0, iPE105_DMEM_EX_Data[15:0]};
        else
          wPE105_DMEM_EX_Data = {16'b0, iPE105_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE105_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE105_DMEM_EX_Data = {24'b0, iPE105_DMEM_EX_Data[7 : 0]};
          2'b01: wPE105_DMEM_EX_Data = {24'b0, iPE105_DMEM_EX_Data[15: 8]};
          2'b10: wPE105_DMEM_EX_Data = {24'b0, iPE105_DMEM_EX_Data[23:16]};
          2'b11: wPE105_DMEM_EX_Data = {24'b0, iPE105_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE105_DMEM_EX_Data = iPE105_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 106
  assign oPE106_DMEM_Valid       = oPE106_AGU_DMEM_Write_Enable || oPE106_AGU_DMEM_Read_Enable;
  assign oPE106_AGU_DMEM_Address = wPE106_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE106_AGU_DMEM_Opcode        <= 'b0;
        PR_PE106_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE106_AGU_DMEM_Read_Enable )
      begin
        PR_PE106_AGU_DMEM_Opcode        <= wPE106_AGU_DMEM_Opcode;
        PR_PE106_AGU_DMEM_Addr_Last_Two <= wPE106_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE106_AGU_DMEM_Opcode or PR_PE106_AGU_DMEM_Addr_Last_Two or iPE106_DMEM_EX_Data )
    case ( PR_PE106_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE106_DMEM_EX_Data = iPE106_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE106_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE106_DMEM_EX_Data = {16'b0, iPE106_DMEM_EX_Data[15:0]};
        else
          wPE106_DMEM_EX_Data = {16'b0, iPE106_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE106_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE106_DMEM_EX_Data = {24'b0, iPE106_DMEM_EX_Data[7 : 0]};
          2'b01: wPE106_DMEM_EX_Data = {24'b0, iPE106_DMEM_EX_Data[15: 8]};
          2'b10: wPE106_DMEM_EX_Data = {24'b0, iPE106_DMEM_EX_Data[23:16]};
          2'b11: wPE106_DMEM_EX_Data = {24'b0, iPE106_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE106_DMEM_EX_Data = iPE106_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 107
  assign oPE107_DMEM_Valid       = oPE107_AGU_DMEM_Write_Enable || oPE107_AGU_DMEM_Read_Enable;
  assign oPE107_AGU_DMEM_Address = wPE107_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE107_AGU_DMEM_Opcode        <= 'b0;
        PR_PE107_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE107_AGU_DMEM_Read_Enable )
      begin
        PR_PE107_AGU_DMEM_Opcode        <= wPE107_AGU_DMEM_Opcode;
        PR_PE107_AGU_DMEM_Addr_Last_Two <= wPE107_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE107_AGU_DMEM_Opcode or PR_PE107_AGU_DMEM_Addr_Last_Two or iPE107_DMEM_EX_Data )
    case ( PR_PE107_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE107_DMEM_EX_Data = iPE107_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE107_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE107_DMEM_EX_Data = {16'b0, iPE107_DMEM_EX_Data[15:0]};
        else
          wPE107_DMEM_EX_Data = {16'b0, iPE107_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE107_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE107_DMEM_EX_Data = {24'b0, iPE107_DMEM_EX_Data[7 : 0]};
          2'b01: wPE107_DMEM_EX_Data = {24'b0, iPE107_DMEM_EX_Data[15: 8]};
          2'b10: wPE107_DMEM_EX_Data = {24'b0, iPE107_DMEM_EX_Data[23:16]};
          2'b11: wPE107_DMEM_EX_Data = {24'b0, iPE107_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE107_DMEM_EX_Data = iPE107_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 108
  assign oPE108_DMEM_Valid       = oPE108_AGU_DMEM_Write_Enable || oPE108_AGU_DMEM_Read_Enable;
  assign oPE108_AGU_DMEM_Address = wPE108_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE108_AGU_DMEM_Opcode        <= 'b0;
        PR_PE108_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE108_AGU_DMEM_Read_Enable )
      begin
        PR_PE108_AGU_DMEM_Opcode        <= wPE108_AGU_DMEM_Opcode;
        PR_PE108_AGU_DMEM_Addr_Last_Two <= wPE108_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE108_AGU_DMEM_Opcode or PR_PE108_AGU_DMEM_Addr_Last_Two or iPE108_DMEM_EX_Data )
    case ( PR_PE108_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE108_DMEM_EX_Data = iPE108_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE108_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE108_DMEM_EX_Data = {16'b0, iPE108_DMEM_EX_Data[15:0]};
        else
          wPE108_DMEM_EX_Data = {16'b0, iPE108_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE108_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE108_DMEM_EX_Data = {24'b0, iPE108_DMEM_EX_Data[7 : 0]};
          2'b01: wPE108_DMEM_EX_Data = {24'b0, iPE108_DMEM_EX_Data[15: 8]};
          2'b10: wPE108_DMEM_EX_Data = {24'b0, iPE108_DMEM_EX_Data[23:16]};
          2'b11: wPE108_DMEM_EX_Data = {24'b0, iPE108_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE108_DMEM_EX_Data = iPE108_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 109
  assign oPE109_DMEM_Valid       = oPE109_AGU_DMEM_Write_Enable || oPE109_AGU_DMEM_Read_Enable;
  assign oPE109_AGU_DMEM_Address = wPE109_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE109_AGU_DMEM_Opcode        <= 'b0;
        PR_PE109_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE109_AGU_DMEM_Read_Enable )
      begin
        PR_PE109_AGU_DMEM_Opcode        <= wPE109_AGU_DMEM_Opcode;
        PR_PE109_AGU_DMEM_Addr_Last_Two <= wPE109_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE109_AGU_DMEM_Opcode or PR_PE109_AGU_DMEM_Addr_Last_Two or iPE109_DMEM_EX_Data )
    case ( PR_PE109_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE109_DMEM_EX_Data = iPE109_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE109_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE109_DMEM_EX_Data = {16'b0, iPE109_DMEM_EX_Data[15:0]};
        else
          wPE109_DMEM_EX_Data = {16'b0, iPE109_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE109_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE109_DMEM_EX_Data = {24'b0, iPE109_DMEM_EX_Data[7 : 0]};
          2'b01: wPE109_DMEM_EX_Data = {24'b0, iPE109_DMEM_EX_Data[15: 8]};
          2'b10: wPE109_DMEM_EX_Data = {24'b0, iPE109_DMEM_EX_Data[23:16]};
          2'b11: wPE109_DMEM_EX_Data = {24'b0, iPE109_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE109_DMEM_EX_Data = iPE109_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 110
  assign oPE110_DMEM_Valid       = oPE110_AGU_DMEM_Write_Enable || oPE110_AGU_DMEM_Read_Enable;
  assign oPE110_AGU_DMEM_Address = wPE110_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE110_AGU_DMEM_Opcode        <= 'b0;
        PR_PE110_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE110_AGU_DMEM_Read_Enable )
      begin
        PR_PE110_AGU_DMEM_Opcode        <= wPE110_AGU_DMEM_Opcode;
        PR_PE110_AGU_DMEM_Addr_Last_Two <= wPE110_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE110_AGU_DMEM_Opcode or PR_PE110_AGU_DMEM_Addr_Last_Two or iPE110_DMEM_EX_Data )
    case ( PR_PE110_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE110_DMEM_EX_Data = iPE110_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE110_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE110_DMEM_EX_Data = {16'b0, iPE110_DMEM_EX_Data[15:0]};
        else
          wPE110_DMEM_EX_Data = {16'b0, iPE110_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE110_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE110_DMEM_EX_Data = {24'b0, iPE110_DMEM_EX_Data[7 : 0]};
          2'b01: wPE110_DMEM_EX_Data = {24'b0, iPE110_DMEM_EX_Data[15: 8]};
          2'b10: wPE110_DMEM_EX_Data = {24'b0, iPE110_DMEM_EX_Data[23:16]};
          2'b11: wPE110_DMEM_EX_Data = {24'b0, iPE110_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE110_DMEM_EX_Data = iPE110_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 111
  assign oPE111_DMEM_Valid       = oPE111_AGU_DMEM_Write_Enable || oPE111_AGU_DMEM_Read_Enable;
  assign oPE111_AGU_DMEM_Address = wPE111_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE111_AGU_DMEM_Opcode        <= 'b0;
        PR_PE111_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE111_AGU_DMEM_Read_Enable )
      begin
        PR_PE111_AGU_DMEM_Opcode        <= wPE111_AGU_DMEM_Opcode;
        PR_PE111_AGU_DMEM_Addr_Last_Two <= wPE111_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE111_AGU_DMEM_Opcode or PR_PE111_AGU_DMEM_Addr_Last_Two or iPE111_DMEM_EX_Data )
    case ( PR_PE111_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE111_DMEM_EX_Data = iPE111_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE111_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE111_DMEM_EX_Data = {16'b0, iPE111_DMEM_EX_Data[15:0]};
        else
          wPE111_DMEM_EX_Data = {16'b0, iPE111_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE111_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE111_DMEM_EX_Data = {24'b0, iPE111_DMEM_EX_Data[7 : 0]};
          2'b01: wPE111_DMEM_EX_Data = {24'b0, iPE111_DMEM_EX_Data[15: 8]};
          2'b10: wPE111_DMEM_EX_Data = {24'b0, iPE111_DMEM_EX_Data[23:16]};
          2'b11: wPE111_DMEM_EX_Data = {24'b0, iPE111_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE111_DMEM_EX_Data = iPE111_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 112
  assign oPE112_DMEM_Valid       = oPE112_AGU_DMEM_Write_Enable || oPE112_AGU_DMEM_Read_Enable;
  assign oPE112_AGU_DMEM_Address = wPE112_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE112_AGU_DMEM_Opcode        <= 'b0;
        PR_PE112_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE112_AGU_DMEM_Read_Enable )
      begin
        PR_PE112_AGU_DMEM_Opcode        <= wPE112_AGU_DMEM_Opcode;
        PR_PE112_AGU_DMEM_Addr_Last_Two <= wPE112_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE112_AGU_DMEM_Opcode or PR_PE112_AGU_DMEM_Addr_Last_Two or iPE112_DMEM_EX_Data )
    case ( PR_PE112_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE112_DMEM_EX_Data = iPE112_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE112_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE112_DMEM_EX_Data = {16'b0, iPE112_DMEM_EX_Data[15:0]};
        else
          wPE112_DMEM_EX_Data = {16'b0, iPE112_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE112_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE112_DMEM_EX_Data = {24'b0, iPE112_DMEM_EX_Data[7 : 0]};
          2'b01: wPE112_DMEM_EX_Data = {24'b0, iPE112_DMEM_EX_Data[15: 8]};
          2'b10: wPE112_DMEM_EX_Data = {24'b0, iPE112_DMEM_EX_Data[23:16]};
          2'b11: wPE112_DMEM_EX_Data = {24'b0, iPE112_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE112_DMEM_EX_Data = iPE112_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 113
  assign oPE113_DMEM_Valid       = oPE113_AGU_DMEM_Write_Enable || oPE113_AGU_DMEM_Read_Enable;
  assign oPE113_AGU_DMEM_Address = wPE113_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE113_AGU_DMEM_Opcode        <= 'b0;
        PR_PE113_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE113_AGU_DMEM_Read_Enable )
      begin
        PR_PE113_AGU_DMEM_Opcode        <= wPE113_AGU_DMEM_Opcode;
        PR_PE113_AGU_DMEM_Addr_Last_Two <= wPE113_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE113_AGU_DMEM_Opcode or PR_PE113_AGU_DMEM_Addr_Last_Two or iPE113_DMEM_EX_Data )
    case ( PR_PE113_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE113_DMEM_EX_Data = iPE113_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE113_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE113_DMEM_EX_Data = {16'b0, iPE113_DMEM_EX_Data[15:0]};
        else
          wPE113_DMEM_EX_Data = {16'b0, iPE113_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE113_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE113_DMEM_EX_Data = {24'b0, iPE113_DMEM_EX_Data[7 : 0]};
          2'b01: wPE113_DMEM_EX_Data = {24'b0, iPE113_DMEM_EX_Data[15: 8]};
          2'b10: wPE113_DMEM_EX_Data = {24'b0, iPE113_DMEM_EX_Data[23:16]};
          2'b11: wPE113_DMEM_EX_Data = {24'b0, iPE113_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE113_DMEM_EX_Data = iPE113_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 114
  assign oPE114_DMEM_Valid       = oPE114_AGU_DMEM_Write_Enable || oPE114_AGU_DMEM_Read_Enable;
  assign oPE114_AGU_DMEM_Address = wPE114_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE114_AGU_DMEM_Opcode        <= 'b0;
        PR_PE114_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE114_AGU_DMEM_Read_Enable )
      begin
        PR_PE114_AGU_DMEM_Opcode        <= wPE114_AGU_DMEM_Opcode;
        PR_PE114_AGU_DMEM_Addr_Last_Two <= wPE114_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE114_AGU_DMEM_Opcode or PR_PE114_AGU_DMEM_Addr_Last_Two or iPE114_DMEM_EX_Data )
    case ( PR_PE114_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE114_DMEM_EX_Data = iPE114_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE114_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE114_DMEM_EX_Data = {16'b0, iPE114_DMEM_EX_Data[15:0]};
        else
          wPE114_DMEM_EX_Data = {16'b0, iPE114_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE114_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE114_DMEM_EX_Data = {24'b0, iPE114_DMEM_EX_Data[7 : 0]};
          2'b01: wPE114_DMEM_EX_Data = {24'b0, iPE114_DMEM_EX_Data[15: 8]};
          2'b10: wPE114_DMEM_EX_Data = {24'b0, iPE114_DMEM_EX_Data[23:16]};
          2'b11: wPE114_DMEM_EX_Data = {24'b0, iPE114_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE114_DMEM_EX_Data = iPE114_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 115
  assign oPE115_DMEM_Valid       = oPE115_AGU_DMEM_Write_Enable || oPE115_AGU_DMEM_Read_Enable;
  assign oPE115_AGU_DMEM_Address = wPE115_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE115_AGU_DMEM_Opcode        <= 'b0;
        PR_PE115_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE115_AGU_DMEM_Read_Enable )
      begin
        PR_PE115_AGU_DMEM_Opcode        <= wPE115_AGU_DMEM_Opcode;
        PR_PE115_AGU_DMEM_Addr_Last_Two <= wPE115_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE115_AGU_DMEM_Opcode or PR_PE115_AGU_DMEM_Addr_Last_Two or iPE115_DMEM_EX_Data )
    case ( PR_PE115_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE115_DMEM_EX_Data = iPE115_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE115_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE115_DMEM_EX_Data = {16'b0, iPE115_DMEM_EX_Data[15:0]};
        else
          wPE115_DMEM_EX_Data = {16'b0, iPE115_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE115_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE115_DMEM_EX_Data = {24'b0, iPE115_DMEM_EX_Data[7 : 0]};
          2'b01: wPE115_DMEM_EX_Data = {24'b0, iPE115_DMEM_EX_Data[15: 8]};
          2'b10: wPE115_DMEM_EX_Data = {24'b0, iPE115_DMEM_EX_Data[23:16]};
          2'b11: wPE115_DMEM_EX_Data = {24'b0, iPE115_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE115_DMEM_EX_Data = iPE115_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 116
  assign oPE116_DMEM_Valid       = oPE116_AGU_DMEM_Write_Enable || oPE116_AGU_DMEM_Read_Enable;
  assign oPE116_AGU_DMEM_Address = wPE116_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE116_AGU_DMEM_Opcode        <= 'b0;
        PR_PE116_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE116_AGU_DMEM_Read_Enable )
      begin
        PR_PE116_AGU_DMEM_Opcode        <= wPE116_AGU_DMEM_Opcode;
        PR_PE116_AGU_DMEM_Addr_Last_Two <= wPE116_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE116_AGU_DMEM_Opcode or PR_PE116_AGU_DMEM_Addr_Last_Two or iPE116_DMEM_EX_Data )
    case ( PR_PE116_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE116_DMEM_EX_Data = iPE116_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE116_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE116_DMEM_EX_Data = {16'b0, iPE116_DMEM_EX_Data[15:0]};
        else
          wPE116_DMEM_EX_Data = {16'b0, iPE116_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE116_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE116_DMEM_EX_Data = {24'b0, iPE116_DMEM_EX_Data[7 : 0]};
          2'b01: wPE116_DMEM_EX_Data = {24'b0, iPE116_DMEM_EX_Data[15: 8]};
          2'b10: wPE116_DMEM_EX_Data = {24'b0, iPE116_DMEM_EX_Data[23:16]};
          2'b11: wPE116_DMEM_EX_Data = {24'b0, iPE116_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE116_DMEM_EX_Data = iPE116_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 117
  assign oPE117_DMEM_Valid       = oPE117_AGU_DMEM_Write_Enable || oPE117_AGU_DMEM_Read_Enable;
  assign oPE117_AGU_DMEM_Address = wPE117_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE117_AGU_DMEM_Opcode        <= 'b0;
        PR_PE117_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE117_AGU_DMEM_Read_Enable )
      begin
        PR_PE117_AGU_DMEM_Opcode        <= wPE117_AGU_DMEM_Opcode;
        PR_PE117_AGU_DMEM_Addr_Last_Two <= wPE117_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE117_AGU_DMEM_Opcode or PR_PE117_AGU_DMEM_Addr_Last_Two or iPE117_DMEM_EX_Data )
    case ( PR_PE117_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE117_DMEM_EX_Data = iPE117_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE117_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE117_DMEM_EX_Data = {16'b0, iPE117_DMEM_EX_Data[15:0]};
        else
          wPE117_DMEM_EX_Data = {16'b0, iPE117_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE117_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE117_DMEM_EX_Data = {24'b0, iPE117_DMEM_EX_Data[7 : 0]};
          2'b01: wPE117_DMEM_EX_Data = {24'b0, iPE117_DMEM_EX_Data[15: 8]};
          2'b10: wPE117_DMEM_EX_Data = {24'b0, iPE117_DMEM_EX_Data[23:16]};
          2'b11: wPE117_DMEM_EX_Data = {24'b0, iPE117_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE117_DMEM_EX_Data = iPE117_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 118
  assign oPE118_DMEM_Valid       = oPE118_AGU_DMEM_Write_Enable || oPE118_AGU_DMEM_Read_Enable;
  assign oPE118_AGU_DMEM_Address = wPE118_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE118_AGU_DMEM_Opcode        <= 'b0;
        PR_PE118_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE118_AGU_DMEM_Read_Enable )
      begin
        PR_PE118_AGU_DMEM_Opcode        <= wPE118_AGU_DMEM_Opcode;
        PR_PE118_AGU_DMEM_Addr_Last_Two <= wPE118_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE118_AGU_DMEM_Opcode or PR_PE118_AGU_DMEM_Addr_Last_Two or iPE118_DMEM_EX_Data )
    case ( PR_PE118_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE118_DMEM_EX_Data = iPE118_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE118_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE118_DMEM_EX_Data = {16'b0, iPE118_DMEM_EX_Data[15:0]};
        else
          wPE118_DMEM_EX_Data = {16'b0, iPE118_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE118_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE118_DMEM_EX_Data = {24'b0, iPE118_DMEM_EX_Data[7 : 0]};
          2'b01: wPE118_DMEM_EX_Data = {24'b0, iPE118_DMEM_EX_Data[15: 8]};
          2'b10: wPE118_DMEM_EX_Data = {24'b0, iPE118_DMEM_EX_Data[23:16]};
          2'b11: wPE118_DMEM_EX_Data = {24'b0, iPE118_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE118_DMEM_EX_Data = iPE118_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 119
  assign oPE119_DMEM_Valid       = oPE119_AGU_DMEM_Write_Enable || oPE119_AGU_DMEM_Read_Enable;
  assign oPE119_AGU_DMEM_Address = wPE119_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE119_AGU_DMEM_Opcode        <= 'b0;
        PR_PE119_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE119_AGU_DMEM_Read_Enable )
      begin
        PR_PE119_AGU_DMEM_Opcode        <= wPE119_AGU_DMEM_Opcode;
        PR_PE119_AGU_DMEM_Addr_Last_Two <= wPE119_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE119_AGU_DMEM_Opcode or PR_PE119_AGU_DMEM_Addr_Last_Two or iPE119_DMEM_EX_Data )
    case ( PR_PE119_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE119_DMEM_EX_Data = iPE119_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE119_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE119_DMEM_EX_Data = {16'b0, iPE119_DMEM_EX_Data[15:0]};
        else
          wPE119_DMEM_EX_Data = {16'b0, iPE119_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE119_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE119_DMEM_EX_Data = {24'b0, iPE119_DMEM_EX_Data[7 : 0]};
          2'b01: wPE119_DMEM_EX_Data = {24'b0, iPE119_DMEM_EX_Data[15: 8]};
          2'b10: wPE119_DMEM_EX_Data = {24'b0, iPE119_DMEM_EX_Data[23:16]};
          2'b11: wPE119_DMEM_EX_Data = {24'b0, iPE119_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE119_DMEM_EX_Data = iPE119_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 120
  assign oPE120_DMEM_Valid       = oPE120_AGU_DMEM_Write_Enable || oPE120_AGU_DMEM_Read_Enable;
  assign oPE120_AGU_DMEM_Address = wPE120_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE120_AGU_DMEM_Opcode        <= 'b0;
        PR_PE120_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE120_AGU_DMEM_Read_Enable )
      begin
        PR_PE120_AGU_DMEM_Opcode        <= wPE120_AGU_DMEM_Opcode;
        PR_PE120_AGU_DMEM_Addr_Last_Two <= wPE120_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE120_AGU_DMEM_Opcode or PR_PE120_AGU_DMEM_Addr_Last_Two or iPE120_DMEM_EX_Data )
    case ( PR_PE120_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE120_DMEM_EX_Data = iPE120_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE120_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE120_DMEM_EX_Data = {16'b0, iPE120_DMEM_EX_Data[15:0]};
        else
          wPE120_DMEM_EX_Data = {16'b0, iPE120_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE120_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE120_DMEM_EX_Data = {24'b0, iPE120_DMEM_EX_Data[7 : 0]};
          2'b01: wPE120_DMEM_EX_Data = {24'b0, iPE120_DMEM_EX_Data[15: 8]};
          2'b10: wPE120_DMEM_EX_Data = {24'b0, iPE120_DMEM_EX_Data[23:16]};
          2'b11: wPE120_DMEM_EX_Data = {24'b0, iPE120_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE120_DMEM_EX_Data = iPE120_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 121
  assign oPE121_DMEM_Valid       = oPE121_AGU_DMEM_Write_Enable || oPE121_AGU_DMEM_Read_Enable;
  assign oPE121_AGU_DMEM_Address = wPE121_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE121_AGU_DMEM_Opcode        <= 'b0;
        PR_PE121_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE121_AGU_DMEM_Read_Enable )
      begin
        PR_PE121_AGU_DMEM_Opcode        <= wPE121_AGU_DMEM_Opcode;
        PR_PE121_AGU_DMEM_Addr_Last_Two <= wPE121_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE121_AGU_DMEM_Opcode or PR_PE121_AGU_DMEM_Addr_Last_Two or iPE121_DMEM_EX_Data )
    case ( PR_PE121_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE121_DMEM_EX_Data = iPE121_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE121_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE121_DMEM_EX_Data = {16'b0, iPE121_DMEM_EX_Data[15:0]};
        else
          wPE121_DMEM_EX_Data = {16'b0, iPE121_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE121_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE121_DMEM_EX_Data = {24'b0, iPE121_DMEM_EX_Data[7 : 0]};
          2'b01: wPE121_DMEM_EX_Data = {24'b0, iPE121_DMEM_EX_Data[15: 8]};
          2'b10: wPE121_DMEM_EX_Data = {24'b0, iPE121_DMEM_EX_Data[23:16]};
          2'b11: wPE121_DMEM_EX_Data = {24'b0, iPE121_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE121_DMEM_EX_Data = iPE121_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 122
  assign oPE122_DMEM_Valid       = oPE122_AGU_DMEM_Write_Enable || oPE122_AGU_DMEM_Read_Enable;
  assign oPE122_AGU_DMEM_Address = wPE122_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE122_AGU_DMEM_Opcode        <= 'b0;
        PR_PE122_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE122_AGU_DMEM_Read_Enable )
      begin
        PR_PE122_AGU_DMEM_Opcode        <= wPE122_AGU_DMEM_Opcode;
        PR_PE122_AGU_DMEM_Addr_Last_Two <= wPE122_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE122_AGU_DMEM_Opcode or PR_PE122_AGU_DMEM_Addr_Last_Two or iPE122_DMEM_EX_Data )
    case ( PR_PE122_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE122_DMEM_EX_Data = iPE122_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE122_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE122_DMEM_EX_Data = {16'b0, iPE122_DMEM_EX_Data[15:0]};
        else
          wPE122_DMEM_EX_Data = {16'b0, iPE122_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE122_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE122_DMEM_EX_Data = {24'b0, iPE122_DMEM_EX_Data[7 : 0]};
          2'b01: wPE122_DMEM_EX_Data = {24'b0, iPE122_DMEM_EX_Data[15: 8]};
          2'b10: wPE122_DMEM_EX_Data = {24'b0, iPE122_DMEM_EX_Data[23:16]};
          2'b11: wPE122_DMEM_EX_Data = {24'b0, iPE122_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE122_DMEM_EX_Data = iPE122_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 123
  assign oPE123_DMEM_Valid       = oPE123_AGU_DMEM_Write_Enable || oPE123_AGU_DMEM_Read_Enable;
  assign oPE123_AGU_DMEM_Address = wPE123_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE123_AGU_DMEM_Opcode        <= 'b0;
        PR_PE123_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE123_AGU_DMEM_Read_Enable )
      begin
        PR_PE123_AGU_DMEM_Opcode        <= wPE123_AGU_DMEM_Opcode;
        PR_PE123_AGU_DMEM_Addr_Last_Two <= wPE123_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE123_AGU_DMEM_Opcode or PR_PE123_AGU_DMEM_Addr_Last_Two or iPE123_DMEM_EX_Data )
    case ( PR_PE123_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE123_DMEM_EX_Data = iPE123_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE123_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE123_DMEM_EX_Data = {16'b0, iPE123_DMEM_EX_Data[15:0]};
        else
          wPE123_DMEM_EX_Data = {16'b0, iPE123_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE123_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE123_DMEM_EX_Data = {24'b0, iPE123_DMEM_EX_Data[7 : 0]};
          2'b01: wPE123_DMEM_EX_Data = {24'b0, iPE123_DMEM_EX_Data[15: 8]};
          2'b10: wPE123_DMEM_EX_Data = {24'b0, iPE123_DMEM_EX_Data[23:16]};
          2'b11: wPE123_DMEM_EX_Data = {24'b0, iPE123_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE123_DMEM_EX_Data = iPE123_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 124
  assign oPE124_DMEM_Valid       = oPE124_AGU_DMEM_Write_Enable || oPE124_AGU_DMEM_Read_Enable;
  assign oPE124_AGU_DMEM_Address = wPE124_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE124_AGU_DMEM_Opcode        <= 'b0;
        PR_PE124_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE124_AGU_DMEM_Read_Enable )
      begin
        PR_PE124_AGU_DMEM_Opcode        <= wPE124_AGU_DMEM_Opcode;
        PR_PE124_AGU_DMEM_Addr_Last_Two <= wPE124_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE124_AGU_DMEM_Opcode or PR_PE124_AGU_DMEM_Addr_Last_Two or iPE124_DMEM_EX_Data )
    case ( PR_PE124_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE124_DMEM_EX_Data = iPE124_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE124_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE124_DMEM_EX_Data = {16'b0, iPE124_DMEM_EX_Data[15:0]};
        else
          wPE124_DMEM_EX_Data = {16'b0, iPE124_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE124_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE124_DMEM_EX_Data = {24'b0, iPE124_DMEM_EX_Data[7 : 0]};
          2'b01: wPE124_DMEM_EX_Data = {24'b0, iPE124_DMEM_EX_Data[15: 8]};
          2'b10: wPE124_DMEM_EX_Data = {24'b0, iPE124_DMEM_EX_Data[23:16]};
          2'b11: wPE124_DMEM_EX_Data = {24'b0, iPE124_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE124_DMEM_EX_Data = iPE124_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 125
  assign oPE125_DMEM_Valid       = oPE125_AGU_DMEM_Write_Enable || oPE125_AGU_DMEM_Read_Enable;
  assign oPE125_AGU_DMEM_Address = wPE125_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE125_AGU_DMEM_Opcode        <= 'b0;
        PR_PE125_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE125_AGU_DMEM_Read_Enable )
      begin
        PR_PE125_AGU_DMEM_Opcode        <= wPE125_AGU_DMEM_Opcode;
        PR_PE125_AGU_DMEM_Addr_Last_Two <= wPE125_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE125_AGU_DMEM_Opcode or PR_PE125_AGU_DMEM_Addr_Last_Two or iPE125_DMEM_EX_Data )
    case ( PR_PE125_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE125_DMEM_EX_Data = iPE125_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE125_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE125_DMEM_EX_Data = {16'b0, iPE125_DMEM_EX_Data[15:0]};
        else
          wPE125_DMEM_EX_Data = {16'b0, iPE125_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE125_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE125_DMEM_EX_Data = {24'b0, iPE125_DMEM_EX_Data[7 : 0]};
          2'b01: wPE125_DMEM_EX_Data = {24'b0, iPE125_DMEM_EX_Data[15: 8]};
          2'b10: wPE125_DMEM_EX_Data = {24'b0, iPE125_DMEM_EX_Data[23:16]};
          2'b11: wPE125_DMEM_EX_Data = {24'b0, iPE125_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE125_DMEM_EX_Data = iPE125_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 126
  assign oPE126_DMEM_Valid       = oPE126_AGU_DMEM_Write_Enable || oPE126_AGU_DMEM_Read_Enable;
  assign oPE126_AGU_DMEM_Address = wPE126_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE126_AGU_DMEM_Opcode        <= 'b0;
        PR_PE126_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE126_AGU_DMEM_Read_Enable )
      begin
        PR_PE126_AGU_DMEM_Opcode        <= wPE126_AGU_DMEM_Opcode;
        PR_PE126_AGU_DMEM_Addr_Last_Two <= wPE126_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE126_AGU_DMEM_Opcode or PR_PE126_AGU_DMEM_Addr_Last_Two or iPE126_DMEM_EX_Data )
    case ( PR_PE126_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE126_DMEM_EX_Data = iPE126_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE126_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE126_DMEM_EX_Data = {16'b0, iPE126_DMEM_EX_Data[15:0]};
        else
          wPE126_DMEM_EX_Data = {16'b0, iPE126_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE126_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE126_DMEM_EX_Data = {24'b0, iPE126_DMEM_EX_Data[7 : 0]};
          2'b01: wPE126_DMEM_EX_Data = {24'b0, iPE126_DMEM_EX_Data[15: 8]};
          2'b10: wPE126_DMEM_EX_Data = {24'b0, iPE126_DMEM_EX_Data[23:16]};
          2'b11: wPE126_DMEM_EX_Data = {24'b0, iPE126_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE126_DMEM_EX_Data = iPE126_DMEM_EX_Data;
      end
    endcase
  // end of always
  
  // PE 127
  assign oPE127_DMEM_Valid       = oPE127_AGU_DMEM_Write_Enable || oPE127_AGU_DMEM_Read_Enable;
  assign oPE127_AGU_DMEM_Address = wPE127_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE127_AGU_DMEM_Opcode        <= 'b0;
        PR_PE127_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE127_AGU_DMEM_Read_Enable )
      begin
        PR_PE127_AGU_DMEM_Opcode        <= wPE127_AGU_DMEM_Opcode;
        PR_PE127_AGU_DMEM_Addr_Last_Two <= wPE127_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE127_AGU_DMEM_Opcode or PR_PE127_AGU_DMEM_Addr_Last_Two or iPE127_DMEM_EX_Data )
    case ( PR_PE127_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE127_DMEM_EX_Data = iPE127_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE127_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE127_DMEM_EX_Data = {16'b0, iPE127_DMEM_EX_Data[15:0]};
        else
          wPE127_DMEM_EX_Data = {16'b0, iPE127_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE127_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE127_DMEM_EX_Data = {24'b0, iPE127_DMEM_EX_Data[7 : 0]};
          2'b01: wPE127_DMEM_EX_Data = {24'b0, iPE127_DMEM_EX_Data[15: 8]};
          2'b10: wPE127_DMEM_EX_Data = {24'b0, iPE127_DMEM_EX_Data[23:16]};
          2'b11: wPE127_DMEM_EX_Data = {24'b0, iPE127_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE127_DMEM_EX_Data = iPE127_DMEM_EX_Data;
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
    
    // PE 8
    .oPE8_AGU_DMEM_Write_Enable ( oPE8_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE8_AGU_DMEM_Read_Enable  ( oPE8_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE8_AGU_DMEM_Address      ( wPE8_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE8_AGU_DMEM_Opcode       ( wPE8_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE8_AGU_DMEM_Byte_Select  ( oPE8_AGU_DMEM_Byte_Select  ),
    .oPE8_AGU_DMEM_Store_Data   ( oPE8_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE8_DMEM_EX_Data          ( wPE8_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 9
    .oPE9_AGU_DMEM_Write_Enable ( oPE9_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE9_AGU_DMEM_Read_Enable  ( oPE9_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE9_AGU_DMEM_Address      ( wPE9_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE9_AGU_DMEM_Opcode       ( wPE9_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE9_AGU_DMEM_Byte_Select  ( oPE9_AGU_DMEM_Byte_Select  ),
    .oPE9_AGU_DMEM_Store_Data   ( oPE9_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE9_DMEM_EX_Data          ( wPE9_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 10
    .oPE10_AGU_DMEM_Write_Enable ( oPE10_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE10_AGU_DMEM_Read_Enable  ( oPE10_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE10_AGU_DMEM_Address      ( wPE10_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE10_AGU_DMEM_Opcode       ( wPE10_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE10_AGU_DMEM_Byte_Select  ( oPE10_AGU_DMEM_Byte_Select  ),
    .oPE10_AGU_DMEM_Store_Data   ( oPE10_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE10_DMEM_EX_Data          ( wPE10_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 11
    .oPE11_AGU_DMEM_Write_Enable ( oPE11_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE11_AGU_DMEM_Read_Enable  ( oPE11_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE11_AGU_DMEM_Address      ( wPE11_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE11_AGU_DMEM_Opcode       ( wPE11_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE11_AGU_DMEM_Byte_Select  ( oPE11_AGU_DMEM_Byte_Select  ),
    .oPE11_AGU_DMEM_Store_Data   ( oPE11_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE11_DMEM_EX_Data          ( wPE11_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 12
    .oPE12_AGU_DMEM_Write_Enable ( oPE12_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE12_AGU_DMEM_Read_Enable  ( oPE12_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE12_AGU_DMEM_Address      ( wPE12_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE12_AGU_DMEM_Opcode       ( wPE12_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE12_AGU_DMEM_Byte_Select  ( oPE12_AGU_DMEM_Byte_Select  ),
    .oPE12_AGU_DMEM_Store_Data   ( oPE12_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE12_DMEM_EX_Data          ( wPE12_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 13
    .oPE13_AGU_DMEM_Write_Enable ( oPE13_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE13_AGU_DMEM_Read_Enable  ( oPE13_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE13_AGU_DMEM_Address      ( wPE13_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE13_AGU_DMEM_Opcode       ( wPE13_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE13_AGU_DMEM_Byte_Select  ( oPE13_AGU_DMEM_Byte_Select  ),
    .oPE13_AGU_DMEM_Store_Data   ( oPE13_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE13_DMEM_EX_Data          ( wPE13_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 14
    .oPE14_AGU_DMEM_Write_Enable ( oPE14_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE14_AGU_DMEM_Read_Enable  ( oPE14_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE14_AGU_DMEM_Address      ( wPE14_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE14_AGU_DMEM_Opcode       ( wPE14_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE14_AGU_DMEM_Byte_Select  ( oPE14_AGU_DMEM_Byte_Select  ),
    .oPE14_AGU_DMEM_Store_Data   ( oPE14_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE14_DMEM_EX_Data          ( wPE14_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 15
    .oPE15_AGU_DMEM_Write_Enable ( oPE15_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE15_AGU_DMEM_Read_Enable  ( oPE15_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE15_AGU_DMEM_Address      ( wPE15_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE15_AGU_DMEM_Opcode       ( wPE15_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE15_AGU_DMEM_Byte_Select  ( oPE15_AGU_DMEM_Byte_Select  ),
    .oPE15_AGU_DMEM_Store_Data   ( oPE15_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE15_DMEM_EX_Data          ( wPE15_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 16
    .oPE16_AGU_DMEM_Write_Enable ( oPE16_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE16_AGU_DMEM_Read_Enable  ( oPE16_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE16_AGU_DMEM_Address      ( wPE16_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE16_AGU_DMEM_Opcode       ( wPE16_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE16_AGU_DMEM_Byte_Select  ( oPE16_AGU_DMEM_Byte_Select  ),
    .oPE16_AGU_DMEM_Store_Data   ( oPE16_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE16_DMEM_EX_Data          ( wPE16_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 17
    .oPE17_AGU_DMEM_Write_Enable ( oPE17_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE17_AGU_DMEM_Read_Enable  ( oPE17_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE17_AGU_DMEM_Address      ( wPE17_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE17_AGU_DMEM_Opcode       ( wPE17_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE17_AGU_DMEM_Byte_Select  ( oPE17_AGU_DMEM_Byte_Select  ),
    .oPE17_AGU_DMEM_Store_Data   ( oPE17_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE17_DMEM_EX_Data          ( wPE17_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 18
    .oPE18_AGU_DMEM_Write_Enable ( oPE18_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE18_AGU_DMEM_Read_Enable  ( oPE18_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE18_AGU_DMEM_Address      ( wPE18_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE18_AGU_DMEM_Opcode       ( wPE18_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE18_AGU_DMEM_Byte_Select  ( oPE18_AGU_DMEM_Byte_Select  ),
    .oPE18_AGU_DMEM_Store_Data   ( oPE18_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE18_DMEM_EX_Data          ( wPE18_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 19
    .oPE19_AGU_DMEM_Write_Enable ( oPE19_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE19_AGU_DMEM_Read_Enable  ( oPE19_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE19_AGU_DMEM_Address      ( wPE19_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE19_AGU_DMEM_Opcode       ( wPE19_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE19_AGU_DMEM_Byte_Select  ( oPE19_AGU_DMEM_Byte_Select  ),
    .oPE19_AGU_DMEM_Store_Data   ( oPE19_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE19_DMEM_EX_Data          ( wPE19_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 20
    .oPE20_AGU_DMEM_Write_Enable ( oPE20_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE20_AGU_DMEM_Read_Enable  ( oPE20_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE20_AGU_DMEM_Address      ( wPE20_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE20_AGU_DMEM_Opcode       ( wPE20_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE20_AGU_DMEM_Byte_Select  ( oPE20_AGU_DMEM_Byte_Select  ),
    .oPE20_AGU_DMEM_Store_Data   ( oPE20_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE20_DMEM_EX_Data          ( wPE20_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 21
    .oPE21_AGU_DMEM_Write_Enable ( oPE21_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE21_AGU_DMEM_Read_Enable  ( oPE21_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE21_AGU_DMEM_Address      ( wPE21_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE21_AGU_DMEM_Opcode       ( wPE21_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE21_AGU_DMEM_Byte_Select  ( oPE21_AGU_DMEM_Byte_Select  ),
    .oPE21_AGU_DMEM_Store_Data   ( oPE21_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE21_DMEM_EX_Data          ( wPE21_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 22
    .oPE22_AGU_DMEM_Write_Enable ( oPE22_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE22_AGU_DMEM_Read_Enable  ( oPE22_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE22_AGU_DMEM_Address      ( wPE22_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE22_AGU_DMEM_Opcode       ( wPE22_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE22_AGU_DMEM_Byte_Select  ( oPE22_AGU_DMEM_Byte_Select  ),
    .oPE22_AGU_DMEM_Store_Data   ( oPE22_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE22_DMEM_EX_Data          ( wPE22_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 23
    .oPE23_AGU_DMEM_Write_Enable ( oPE23_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE23_AGU_DMEM_Read_Enable  ( oPE23_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE23_AGU_DMEM_Address      ( wPE23_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE23_AGU_DMEM_Opcode       ( wPE23_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE23_AGU_DMEM_Byte_Select  ( oPE23_AGU_DMEM_Byte_Select  ),
    .oPE23_AGU_DMEM_Store_Data   ( oPE23_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE23_DMEM_EX_Data          ( wPE23_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 24
    .oPE24_AGU_DMEM_Write_Enable ( oPE24_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE24_AGU_DMEM_Read_Enable  ( oPE24_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE24_AGU_DMEM_Address      ( wPE24_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE24_AGU_DMEM_Opcode       ( wPE24_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE24_AGU_DMEM_Byte_Select  ( oPE24_AGU_DMEM_Byte_Select  ),
    .oPE24_AGU_DMEM_Store_Data   ( oPE24_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE24_DMEM_EX_Data          ( wPE24_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 25
    .oPE25_AGU_DMEM_Write_Enable ( oPE25_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE25_AGU_DMEM_Read_Enable  ( oPE25_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE25_AGU_DMEM_Address      ( wPE25_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE25_AGU_DMEM_Opcode       ( wPE25_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE25_AGU_DMEM_Byte_Select  ( oPE25_AGU_DMEM_Byte_Select  ),
    .oPE25_AGU_DMEM_Store_Data   ( oPE25_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE25_DMEM_EX_Data          ( wPE25_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 26
    .oPE26_AGU_DMEM_Write_Enable ( oPE26_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE26_AGU_DMEM_Read_Enable  ( oPE26_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE26_AGU_DMEM_Address      ( wPE26_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE26_AGU_DMEM_Opcode       ( wPE26_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE26_AGU_DMEM_Byte_Select  ( oPE26_AGU_DMEM_Byte_Select  ),
    .oPE26_AGU_DMEM_Store_Data   ( oPE26_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE26_DMEM_EX_Data          ( wPE26_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 27
    .oPE27_AGU_DMEM_Write_Enable ( oPE27_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE27_AGU_DMEM_Read_Enable  ( oPE27_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE27_AGU_DMEM_Address      ( wPE27_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE27_AGU_DMEM_Opcode       ( wPE27_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE27_AGU_DMEM_Byte_Select  ( oPE27_AGU_DMEM_Byte_Select  ),
    .oPE27_AGU_DMEM_Store_Data   ( oPE27_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE27_DMEM_EX_Data          ( wPE27_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 28
    .oPE28_AGU_DMEM_Write_Enable ( oPE28_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE28_AGU_DMEM_Read_Enable  ( oPE28_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE28_AGU_DMEM_Address      ( wPE28_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE28_AGU_DMEM_Opcode       ( wPE28_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE28_AGU_DMEM_Byte_Select  ( oPE28_AGU_DMEM_Byte_Select  ),
    .oPE28_AGU_DMEM_Store_Data   ( oPE28_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE28_DMEM_EX_Data          ( wPE28_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 29
    .oPE29_AGU_DMEM_Write_Enable ( oPE29_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE29_AGU_DMEM_Read_Enable  ( oPE29_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE29_AGU_DMEM_Address      ( wPE29_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE29_AGU_DMEM_Opcode       ( wPE29_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE29_AGU_DMEM_Byte_Select  ( oPE29_AGU_DMEM_Byte_Select  ),
    .oPE29_AGU_DMEM_Store_Data   ( oPE29_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE29_DMEM_EX_Data          ( wPE29_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 30
    .oPE30_AGU_DMEM_Write_Enable ( oPE30_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE30_AGU_DMEM_Read_Enable  ( oPE30_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE30_AGU_DMEM_Address      ( wPE30_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE30_AGU_DMEM_Opcode       ( wPE30_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE30_AGU_DMEM_Byte_Select  ( oPE30_AGU_DMEM_Byte_Select  ),
    .oPE30_AGU_DMEM_Store_Data   ( oPE30_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE30_DMEM_EX_Data          ( wPE30_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 31
    .oPE31_AGU_DMEM_Write_Enable ( oPE31_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE31_AGU_DMEM_Read_Enable  ( oPE31_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE31_AGU_DMEM_Address      ( wPE31_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE31_AGU_DMEM_Opcode       ( wPE31_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE31_AGU_DMEM_Byte_Select  ( oPE31_AGU_DMEM_Byte_Select  ),
    .oPE31_AGU_DMEM_Store_Data   ( oPE31_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE31_DMEM_EX_Data          ( wPE31_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 32
    .oPE32_AGU_DMEM_Write_Enable ( oPE32_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE32_AGU_DMEM_Read_Enable  ( oPE32_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE32_AGU_DMEM_Address      ( wPE32_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE32_AGU_DMEM_Opcode       ( wPE32_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE32_AGU_DMEM_Byte_Select  ( oPE32_AGU_DMEM_Byte_Select  ),
    .oPE32_AGU_DMEM_Store_Data   ( oPE32_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE32_DMEM_EX_Data          ( wPE32_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 33
    .oPE33_AGU_DMEM_Write_Enable ( oPE33_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE33_AGU_DMEM_Read_Enable  ( oPE33_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE33_AGU_DMEM_Address      ( wPE33_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE33_AGU_DMEM_Opcode       ( wPE33_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE33_AGU_DMEM_Byte_Select  ( oPE33_AGU_DMEM_Byte_Select  ),
    .oPE33_AGU_DMEM_Store_Data   ( oPE33_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE33_DMEM_EX_Data          ( wPE33_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 34
    .oPE34_AGU_DMEM_Write_Enable ( oPE34_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE34_AGU_DMEM_Read_Enable  ( oPE34_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE34_AGU_DMEM_Address      ( wPE34_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE34_AGU_DMEM_Opcode       ( wPE34_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE34_AGU_DMEM_Byte_Select  ( oPE34_AGU_DMEM_Byte_Select  ),
    .oPE34_AGU_DMEM_Store_Data   ( oPE34_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE34_DMEM_EX_Data          ( wPE34_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 35
    .oPE35_AGU_DMEM_Write_Enable ( oPE35_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE35_AGU_DMEM_Read_Enable  ( oPE35_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE35_AGU_DMEM_Address      ( wPE35_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE35_AGU_DMEM_Opcode       ( wPE35_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE35_AGU_DMEM_Byte_Select  ( oPE35_AGU_DMEM_Byte_Select  ),
    .oPE35_AGU_DMEM_Store_Data   ( oPE35_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE35_DMEM_EX_Data          ( wPE35_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 36
    .oPE36_AGU_DMEM_Write_Enable ( oPE36_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE36_AGU_DMEM_Read_Enable  ( oPE36_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE36_AGU_DMEM_Address      ( wPE36_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE36_AGU_DMEM_Opcode       ( wPE36_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE36_AGU_DMEM_Byte_Select  ( oPE36_AGU_DMEM_Byte_Select  ),
    .oPE36_AGU_DMEM_Store_Data   ( oPE36_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE36_DMEM_EX_Data          ( wPE36_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 37
    .oPE37_AGU_DMEM_Write_Enable ( oPE37_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE37_AGU_DMEM_Read_Enable  ( oPE37_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE37_AGU_DMEM_Address      ( wPE37_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE37_AGU_DMEM_Opcode       ( wPE37_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE37_AGU_DMEM_Byte_Select  ( oPE37_AGU_DMEM_Byte_Select  ),
    .oPE37_AGU_DMEM_Store_Data   ( oPE37_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE37_DMEM_EX_Data          ( wPE37_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 38
    .oPE38_AGU_DMEM_Write_Enable ( oPE38_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE38_AGU_DMEM_Read_Enable  ( oPE38_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE38_AGU_DMEM_Address      ( wPE38_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE38_AGU_DMEM_Opcode       ( wPE38_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE38_AGU_DMEM_Byte_Select  ( oPE38_AGU_DMEM_Byte_Select  ),
    .oPE38_AGU_DMEM_Store_Data   ( oPE38_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE38_DMEM_EX_Data          ( wPE38_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 39
    .oPE39_AGU_DMEM_Write_Enable ( oPE39_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE39_AGU_DMEM_Read_Enable  ( oPE39_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE39_AGU_DMEM_Address      ( wPE39_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE39_AGU_DMEM_Opcode       ( wPE39_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE39_AGU_DMEM_Byte_Select  ( oPE39_AGU_DMEM_Byte_Select  ),
    .oPE39_AGU_DMEM_Store_Data   ( oPE39_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE39_DMEM_EX_Data          ( wPE39_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 40
    .oPE40_AGU_DMEM_Write_Enable ( oPE40_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE40_AGU_DMEM_Read_Enable  ( oPE40_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE40_AGU_DMEM_Address      ( wPE40_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE40_AGU_DMEM_Opcode       ( wPE40_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE40_AGU_DMEM_Byte_Select  ( oPE40_AGU_DMEM_Byte_Select  ),
    .oPE40_AGU_DMEM_Store_Data   ( oPE40_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE40_DMEM_EX_Data          ( wPE40_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 41
    .oPE41_AGU_DMEM_Write_Enable ( oPE41_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE41_AGU_DMEM_Read_Enable  ( oPE41_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE41_AGU_DMEM_Address      ( wPE41_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE41_AGU_DMEM_Opcode       ( wPE41_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE41_AGU_DMEM_Byte_Select  ( oPE41_AGU_DMEM_Byte_Select  ),
    .oPE41_AGU_DMEM_Store_Data   ( oPE41_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE41_DMEM_EX_Data          ( wPE41_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 42
    .oPE42_AGU_DMEM_Write_Enable ( oPE42_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE42_AGU_DMEM_Read_Enable  ( oPE42_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE42_AGU_DMEM_Address      ( wPE42_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE42_AGU_DMEM_Opcode       ( wPE42_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE42_AGU_DMEM_Byte_Select  ( oPE42_AGU_DMEM_Byte_Select  ),
    .oPE42_AGU_DMEM_Store_Data   ( oPE42_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE42_DMEM_EX_Data          ( wPE42_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 43
    .oPE43_AGU_DMEM_Write_Enable ( oPE43_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE43_AGU_DMEM_Read_Enable  ( oPE43_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE43_AGU_DMEM_Address      ( wPE43_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE43_AGU_DMEM_Opcode       ( wPE43_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE43_AGU_DMEM_Byte_Select  ( oPE43_AGU_DMEM_Byte_Select  ),
    .oPE43_AGU_DMEM_Store_Data   ( oPE43_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE43_DMEM_EX_Data          ( wPE43_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 44
    .oPE44_AGU_DMEM_Write_Enable ( oPE44_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE44_AGU_DMEM_Read_Enable  ( oPE44_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE44_AGU_DMEM_Address      ( wPE44_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE44_AGU_DMEM_Opcode       ( wPE44_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE44_AGU_DMEM_Byte_Select  ( oPE44_AGU_DMEM_Byte_Select  ),
    .oPE44_AGU_DMEM_Store_Data   ( oPE44_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE44_DMEM_EX_Data          ( wPE44_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 45
    .oPE45_AGU_DMEM_Write_Enable ( oPE45_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE45_AGU_DMEM_Read_Enable  ( oPE45_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE45_AGU_DMEM_Address      ( wPE45_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE45_AGU_DMEM_Opcode       ( wPE45_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE45_AGU_DMEM_Byte_Select  ( oPE45_AGU_DMEM_Byte_Select  ),
    .oPE45_AGU_DMEM_Store_Data   ( oPE45_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE45_DMEM_EX_Data          ( wPE45_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 46
    .oPE46_AGU_DMEM_Write_Enable ( oPE46_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE46_AGU_DMEM_Read_Enable  ( oPE46_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE46_AGU_DMEM_Address      ( wPE46_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE46_AGU_DMEM_Opcode       ( wPE46_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE46_AGU_DMEM_Byte_Select  ( oPE46_AGU_DMEM_Byte_Select  ),
    .oPE46_AGU_DMEM_Store_Data   ( oPE46_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE46_DMEM_EX_Data          ( wPE46_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 47
    .oPE47_AGU_DMEM_Write_Enable ( oPE47_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE47_AGU_DMEM_Read_Enable  ( oPE47_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE47_AGU_DMEM_Address      ( wPE47_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE47_AGU_DMEM_Opcode       ( wPE47_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE47_AGU_DMEM_Byte_Select  ( oPE47_AGU_DMEM_Byte_Select  ),
    .oPE47_AGU_DMEM_Store_Data   ( oPE47_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE47_DMEM_EX_Data          ( wPE47_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 48
    .oPE48_AGU_DMEM_Write_Enable ( oPE48_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE48_AGU_DMEM_Read_Enable  ( oPE48_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE48_AGU_DMEM_Address      ( wPE48_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE48_AGU_DMEM_Opcode       ( wPE48_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE48_AGU_DMEM_Byte_Select  ( oPE48_AGU_DMEM_Byte_Select  ),
    .oPE48_AGU_DMEM_Store_Data   ( oPE48_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE48_DMEM_EX_Data          ( wPE48_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 49
    .oPE49_AGU_DMEM_Write_Enable ( oPE49_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE49_AGU_DMEM_Read_Enable  ( oPE49_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE49_AGU_DMEM_Address      ( wPE49_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE49_AGU_DMEM_Opcode       ( wPE49_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE49_AGU_DMEM_Byte_Select  ( oPE49_AGU_DMEM_Byte_Select  ),
    .oPE49_AGU_DMEM_Store_Data   ( oPE49_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE49_DMEM_EX_Data          ( wPE49_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 50
    .oPE50_AGU_DMEM_Write_Enable ( oPE50_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE50_AGU_DMEM_Read_Enable  ( oPE50_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE50_AGU_DMEM_Address      ( wPE50_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE50_AGU_DMEM_Opcode       ( wPE50_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE50_AGU_DMEM_Byte_Select  ( oPE50_AGU_DMEM_Byte_Select  ),
    .oPE50_AGU_DMEM_Store_Data   ( oPE50_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE50_DMEM_EX_Data          ( wPE50_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 51
    .oPE51_AGU_DMEM_Write_Enable ( oPE51_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE51_AGU_DMEM_Read_Enable  ( oPE51_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE51_AGU_DMEM_Address      ( wPE51_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE51_AGU_DMEM_Opcode       ( wPE51_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE51_AGU_DMEM_Byte_Select  ( oPE51_AGU_DMEM_Byte_Select  ),
    .oPE51_AGU_DMEM_Store_Data   ( oPE51_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE51_DMEM_EX_Data          ( wPE51_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 52
    .oPE52_AGU_DMEM_Write_Enable ( oPE52_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE52_AGU_DMEM_Read_Enable  ( oPE52_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE52_AGU_DMEM_Address      ( wPE52_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE52_AGU_DMEM_Opcode       ( wPE52_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE52_AGU_DMEM_Byte_Select  ( oPE52_AGU_DMEM_Byte_Select  ),
    .oPE52_AGU_DMEM_Store_Data   ( oPE52_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE52_DMEM_EX_Data          ( wPE52_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 53
    .oPE53_AGU_DMEM_Write_Enable ( oPE53_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE53_AGU_DMEM_Read_Enable  ( oPE53_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE53_AGU_DMEM_Address      ( wPE53_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE53_AGU_DMEM_Opcode       ( wPE53_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE53_AGU_DMEM_Byte_Select  ( oPE53_AGU_DMEM_Byte_Select  ),
    .oPE53_AGU_DMEM_Store_Data   ( oPE53_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE53_DMEM_EX_Data          ( wPE53_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 54
    .oPE54_AGU_DMEM_Write_Enable ( oPE54_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE54_AGU_DMEM_Read_Enable  ( oPE54_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE54_AGU_DMEM_Address      ( wPE54_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE54_AGU_DMEM_Opcode       ( wPE54_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE54_AGU_DMEM_Byte_Select  ( oPE54_AGU_DMEM_Byte_Select  ),
    .oPE54_AGU_DMEM_Store_Data   ( oPE54_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE54_DMEM_EX_Data          ( wPE54_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 55
    .oPE55_AGU_DMEM_Write_Enable ( oPE55_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE55_AGU_DMEM_Read_Enable  ( oPE55_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE55_AGU_DMEM_Address      ( wPE55_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE55_AGU_DMEM_Opcode       ( wPE55_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE55_AGU_DMEM_Byte_Select  ( oPE55_AGU_DMEM_Byte_Select  ),
    .oPE55_AGU_DMEM_Store_Data   ( oPE55_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE55_DMEM_EX_Data          ( wPE55_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 56
    .oPE56_AGU_DMEM_Write_Enable ( oPE56_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE56_AGU_DMEM_Read_Enable  ( oPE56_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE56_AGU_DMEM_Address      ( wPE56_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE56_AGU_DMEM_Opcode       ( wPE56_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE56_AGU_DMEM_Byte_Select  ( oPE56_AGU_DMEM_Byte_Select  ),
    .oPE56_AGU_DMEM_Store_Data   ( oPE56_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE56_DMEM_EX_Data          ( wPE56_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 57
    .oPE57_AGU_DMEM_Write_Enable ( oPE57_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE57_AGU_DMEM_Read_Enable  ( oPE57_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE57_AGU_DMEM_Address      ( wPE57_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE57_AGU_DMEM_Opcode       ( wPE57_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE57_AGU_DMEM_Byte_Select  ( oPE57_AGU_DMEM_Byte_Select  ),
    .oPE57_AGU_DMEM_Store_Data   ( oPE57_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE57_DMEM_EX_Data          ( wPE57_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 58
    .oPE58_AGU_DMEM_Write_Enable ( oPE58_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE58_AGU_DMEM_Read_Enable  ( oPE58_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE58_AGU_DMEM_Address      ( wPE58_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE58_AGU_DMEM_Opcode       ( wPE58_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE58_AGU_DMEM_Byte_Select  ( oPE58_AGU_DMEM_Byte_Select  ),
    .oPE58_AGU_DMEM_Store_Data   ( oPE58_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE58_DMEM_EX_Data          ( wPE58_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 59
    .oPE59_AGU_DMEM_Write_Enable ( oPE59_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE59_AGU_DMEM_Read_Enable  ( oPE59_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE59_AGU_DMEM_Address      ( wPE59_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE59_AGU_DMEM_Opcode       ( wPE59_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE59_AGU_DMEM_Byte_Select  ( oPE59_AGU_DMEM_Byte_Select  ),
    .oPE59_AGU_DMEM_Store_Data   ( oPE59_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE59_DMEM_EX_Data          ( wPE59_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 60
    .oPE60_AGU_DMEM_Write_Enable ( oPE60_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE60_AGU_DMEM_Read_Enable  ( oPE60_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE60_AGU_DMEM_Address      ( wPE60_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE60_AGU_DMEM_Opcode       ( wPE60_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE60_AGU_DMEM_Byte_Select  ( oPE60_AGU_DMEM_Byte_Select  ),
    .oPE60_AGU_DMEM_Store_Data   ( oPE60_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE60_DMEM_EX_Data          ( wPE60_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 61
    .oPE61_AGU_DMEM_Write_Enable ( oPE61_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE61_AGU_DMEM_Read_Enable  ( oPE61_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE61_AGU_DMEM_Address      ( wPE61_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE61_AGU_DMEM_Opcode       ( wPE61_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE61_AGU_DMEM_Byte_Select  ( oPE61_AGU_DMEM_Byte_Select  ),
    .oPE61_AGU_DMEM_Store_Data   ( oPE61_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE61_DMEM_EX_Data          ( wPE61_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 62
    .oPE62_AGU_DMEM_Write_Enable ( oPE62_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE62_AGU_DMEM_Read_Enable  ( oPE62_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE62_AGU_DMEM_Address      ( wPE62_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE62_AGU_DMEM_Opcode       ( wPE62_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE62_AGU_DMEM_Byte_Select  ( oPE62_AGU_DMEM_Byte_Select  ),
    .oPE62_AGU_DMEM_Store_Data   ( oPE62_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE62_DMEM_EX_Data          ( wPE62_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 63
    .oPE63_AGU_DMEM_Write_Enable ( oPE63_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE63_AGU_DMEM_Read_Enable  ( oPE63_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE63_AGU_DMEM_Address      ( wPE63_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE63_AGU_DMEM_Opcode       ( wPE63_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE63_AGU_DMEM_Byte_Select  ( oPE63_AGU_DMEM_Byte_Select  ),
    .oPE63_AGU_DMEM_Store_Data   ( oPE63_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE63_DMEM_EX_Data          ( wPE63_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 64
    .oPE64_AGU_DMEM_Write_Enable ( oPE64_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE64_AGU_DMEM_Read_Enable  ( oPE64_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE64_AGU_DMEM_Address      ( wPE64_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE64_AGU_DMEM_Opcode       ( wPE64_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE64_AGU_DMEM_Byte_Select  ( oPE64_AGU_DMEM_Byte_Select  ),
    .oPE64_AGU_DMEM_Store_Data   ( oPE64_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE64_DMEM_EX_Data          ( wPE64_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 65
    .oPE65_AGU_DMEM_Write_Enable ( oPE65_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE65_AGU_DMEM_Read_Enable  ( oPE65_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE65_AGU_DMEM_Address      ( wPE65_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE65_AGU_DMEM_Opcode       ( wPE65_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE65_AGU_DMEM_Byte_Select  ( oPE65_AGU_DMEM_Byte_Select  ),
    .oPE65_AGU_DMEM_Store_Data   ( oPE65_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE65_DMEM_EX_Data          ( wPE65_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 66
    .oPE66_AGU_DMEM_Write_Enable ( oPE66_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE66_AGU_DMEM_Read_Enable  ( oPE66_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE66_AGU_DMEM_Address      ( wPE66_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE66_AGU_DMEM_Opcode       ( wPE66_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE66_AGU_DMEM_Byte_Select  ( oPE66_AGU_DMEM_Byte_Select  ),
    .oPE66_AGU_DMEM_Store_Data   ( oPE66_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE66_DMEM_EX_Data          ( wPE66_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 67
    .oPE67_AGU_DMEM_Write_Enable ( oPE67_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE67_AGU_DMEM_Read_Enable  ( oPE67_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE67_AGU_DMEM_Address      ( wPE67_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE67_AGU_DMEM_Opcode       ( wPE67_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE67_AGU_DMEM_Byte_Select  ( oPE67_AGU_DMEM_Byte_Select  ),
    .oPE67_AGU_DMEM_Store_Data   ( oPE67_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE67_DMEM_EX_Data          ( wPE67_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 68
    .oPE68_AGU_DMEM_Write_Enable ( oPE68_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE68_AGU_DMEM_Read_Enable  ( oPE68_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE68_AGU_DMEM_Address      ( wPE68_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE68_AGU_DMEM_Opcode       ( wPE68_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE68_AGU_DMEM_Byte_Select  ( oPE68_AGU_DMEM_Byte_Select  ),
    .oPE68_AGU_DMEM_Store_Data   ( oPE68_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE68_DMEM_EX_Data          ( wPE68_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 69
    .oPE69_AGU_DMEM_Write_Enable ( oPE69_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE69_AGU_DMEM_Read_Enable  ( oPE69_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE69_AGU_DMEM_Address      ( wPE69_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE69_AGU_DMEM_Opcode       ( wPE69_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE69_AGU_DMEM_Byte_Select  ( oPE69_AGU_DMEM_Byte_Select  ),
    .oPE69_AGU_DMEM_Store_Data   ( oPE69_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE69_DMEM_EX_Data          ( wPE69_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 70
    .oPE70_AGU_DMEM_Write_Enable ( oPE70_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE70_AGU_DMEM_Read_Enable  ( oPE70_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE70_AGU_DMEM_Address      ( wPE70_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE70_AGU_DMEM_Opcode       ( wPE70_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE70_AGU_DMEM_Byte_Select  ( oPE70_AGU_DMEM_Byte_Select  ),
    .oPE70_AGU_DMEM_Store_Data   ( oPE70_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE70_DMEM_EX_Data          ( wPE70_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 71
    .oPE71_AGU_DMEM_Write_Enable ( oPE71_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE71_AGU_DMEM_Read_Enable  ( oPE71_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE71_AGU_DMEM_Address      ( wPE71_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE71_AGU_DMEM_Opcode       ( wPE71_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE71_AGU_DMEM_Byte_Select  ( oPE71_AGU_DMEM_Byte_Select  ),
    .oPE71_AGU_DMEM_Store_Data   ( oPE71_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE71_DMEM_EX_Data          ( wPE71_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 72
    .oPE72_AGU_DMEM_Write_Enable ( oPE72_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE72_AGU_DMEM_Read_Enable  ( oPE72_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE72_AGU_DMEM_Address      ( wPE72_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE72_AGU_DMEM_Opcode       ( wPE72_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE72_AGU_DMEM_Byte_Select  ( oPE72_AGU_DMEM_Byte_Select  ),
    .oPE72_AGU_DMEM_Store_Data   ( oPE72_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE72_DMEM_EX_Data          ( wPE72_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 73
    .oPE73_AGU_DMEM_Write_Enable ( oPE73_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE73_AGU_DMEM_Read_Enable  ( oPE73_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE73_AGU_DMEM_Address      ( wPE73_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE73_AGU_DMEM_Opcode       ( wPE73_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE73_AGU_DMEM_Byte_Select  ( oPE73_AGU_DMEM_Byte_Select  ),
    .oPE73_AGU_DMEM_Store_Data   ( oPE73_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE73_DMEM_EX_Data          ( wPE73_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 74
    .oPE74_AGU_DMEM_Write_Enable ( oPE74_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE74_AGU_DMEM_Read_Enable  ( oPE74_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE74_AGU_DMEM_Address      ( wPE74_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE74_AGU_DMEM_Opcode       ( wPE74_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE74_AGU_DMEM_Byte_Select  ( oPE74_AGU_DMEM_Byte_Select  ),
    .oPE74_AGU_DMEM_Store_Data   ( oPE74_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE74_DMEM_EX_Data          ( wPE74_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 75
    .oPE75_AGU_DMEM_Write_Enable ( oPE75_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE75_AGU_DMEM_Read_Enable  ( oPE75_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE75_AGU_DMEM_Address      ( wPE75_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE75_AGU_DMEM_Opcode       ( wPE75_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE75_AGU_DMEM_Byte_Select  ( oPE75_AGU_DMEM_Byte_Select  ),
    .oPE75_AGU_DMEM_Store_Data   ( oPE75_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE75_DMEM_EX_Data          ( wPE75_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 76
    .oPE76_AGU_DMEM_Write_Enable ( oPE76_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE76_AGU_DMEM_Read_Enable  ( oPE76_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE76_AGU_DMEM_Address      ( wPE76_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE76_AGU_DMEM_Opcode       ( wPE76_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE76_AGU_DMEM_Byte_Select  ( oPE76_AGU_DMEM_Byte_Select  ),
    .oPE76_AGU_DMEM_Store_Data   ( oPE76_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE76_DMEM_EX_Data          ( wPE76_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 77
    .oPE77_AGU_DMEM_Write_Enable ( oPE77_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE77_AGU_DMEM_Read_Enable  ( oPE77_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE77_AGU_DMEM_Address      ( wPE77_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE77_AGU_DMEM_Opcode       ( wPE77_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE77_AGU_DMEM_Byte_Select  ( oPE77_AGU_DMEM_Byte_Select  ),
    .oPE77_AGU_DMEM_Store_Data   ( oPE77_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE77_DMEM_EX_Data          ( wPE77_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 78
    .oPE78_AGU_DMEM_Write_Enable ( oPE78_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE78_AGU_DMEM_Read_Enable  ( oPE78_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE78_AGU_DMEM_Address      ( wPE78_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE78_AGU_DMEM_Opcode       ( wPE78_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE78_AGU_DMEM_Byte_Select  ( oPE78_AGU_DMEM_Byte_Select  ),
    .oPE78_AGU_DMEM_Store_Data   ( oPE78_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE78_DMEM_EX_Data          ( wPE78_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 79
    .oPE79_AGU_DMEM_Write_Enable ( oPE79_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE79_AGU_DMEM_Read_Enable  ( oPE79_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE79_AGU_DMEM_Address      ( wPE79_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE79_AGU_DMEM_Opcode       ( wPE79_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE79_AGU_DMEM_Byte_Select  ( oPE79_AGU_DMEM_Byte_Select  ),
    .oPE79_AGU_DMEM_Store_Data   ( oPE79_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE79_DMEM_EX_Data          ( wPE79_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 80
    .oPE80_AGU_DMEM_Write_Enable ( oPE80_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE80_AGU_DMEM_Read_Enable  ( oPE80_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE80_AGU_DMEM_Address      ( wPE80_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE80_AGU_DMEM_Opcode       ( wPE80_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE80_AGU_DMEM_Byte_Select  ( oPE80_AGU_DMEM_Byte_Select  ),
    .oPE80_AGU_DMEM_Store_Data   ( oPE80_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE80_DMEM_EX_Data          ( wPE80_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 81
    .oPE81_AGU_DMEM_Write_Enable ( oPE81_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE81_AGU_DMEM_Read_Enable  ( oPE81_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE81_AGU_DMEM_Address      ( wPE81_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE81_AGU_DMEM_Opcode       ( wPE81_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE81_AGU_DMEM_Byte_Select  ( oPE81_AGU_DMEM_Byte_Select  ),
    .oPE81_AGU_DMEM_Store_Data   ( oPE81_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE81_DMEM_EX_Data          ( wPE81_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 82
    .oPE82_AGU_DMEM_Write_Enable ( oPE82_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE82_AGU_DMEM_Read_Enable  ( oPE82_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE82_AGU_DMEM_Address      ( wPE82_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE82_AGU_DMEM_Opcode       ( wPE82_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE82_AGU_DMEM_Byte_Select  ( oPE82_AGU_DMEM_Byte_Select  ),
    .oPE82_AGU_DMEM_Store_Data   ( oPE82_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE82_DMEM_EX_Data          ( wPE82_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 83
    .oPE83_AGU_DMEM_Write_Enable ( oPE83_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE83_AGU_DMEM_Read_Enable  ( oPE83_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE83_AGU_DMEM_Address      ( wPE83_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE83_AGU_DMEM_Opcode       ( wPE83_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE83_AGU_DMEM_Byte_Select  ( oPE83_AGU_DMEM_Byte_Select  ),
    .oPE83_AGU_DMEM_Store_Data   ( oPE83_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE83_DMEM_EX_Data          ( wPE83_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 84
    .oPE84_AGU_DMEM_Write_Enable ( oPE84_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE84_AGU_DMEM_Read_Enable  ( oPE84_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE84_AGU_DMEM_Address      ( wPE84_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE84_AGU_DMEM_Opcode       ( wPE84_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE84_AGU_DMEM_Byte_Select  ( oPE84_AGU_DMEM_Byte_Select  ),
    .oPE84_AGU_DMEM_Store_Data   ( oPE84_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE84_DMEM_EX_Data          ( wPE84_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 85
    .oPE85_AGU_DMEM_Write_Enable ( oPE85_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE85_AGU_DMEM_Read_Enable  ( oPE85_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE85_AGU_DMEM_Address      ( wPE85_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE85_AGU_DMEM_Opcode       ( wPE85_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE85_AGU_DMEM_Byte_Select  ( oPE85_AGU_DMEM_Byte_Select  ),
    .oPE85_AGU_DMEM_Store_Data   ( oPE85_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE85_DMEM_EX_Data          ( wPE85_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 86
    .oPE86_AGU_DMEM_Write_Enable ( oPE86_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE86_AGU_DMEM_Read_Enable  ( oPE86_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE86_AGU_DMEM_Address      ( wPE86_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE86_AGU_DMEM_Opcode       ( wPE86_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE86_AGU_DMEM_Byte_Select  ( oPE86_AGU_DMEM_Byte_Select  ),
    .oPE86_AGU_DMEM_Store_Data   ( oPE86_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE86_DMEM_EX_Data          ( wPE86_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 87
    .oPE87_AGU_DMEM_Write_Enable ( oPE87_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE87_AGU_DMEM_Read_Enable  ( oPE87_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE87_AGU_DMEM_Address      ( wPE87_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE87_AGU_DMEM_Opcode       ( wPE87_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE87_AGU_DMEM_Byte_Select  ( oPE87_AGU_DMEM_Byte_Select  ),
    .oPE87_AGU_DMEM_Store_Data   ( oPE87_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE87_DMEM_EX_Data          ( wPE87_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 88
    .oPE88_AGU_DMEM_Write_Enable ( oPE88_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE88_AGU_DMEM_Read_Enable  ( oPE88_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE88_AGU_DMEM_Address      ( wPE88_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE88_AGU_DMEM_Opcode       ( wPE88_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE88_AGU_DMEM_Byte_Select  ( oPE88_AGU_DMEM_Byte_Select  ),
    .oPE88_AGU_DMEM_Store_Data   ( oPE88_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE88_DMEM_EX_Data          ( wPE88_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 89
    .oPE89_AGU_DMEM_Write_Enable ( oPE89_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE89_AGU_DMEM_Read_Enable  ( oPE89_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE89_AGU_DMEM_Address      ( wPE89_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE89_AGU_DMEM_Opcode       ( wPE89_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE89_AGU_DMEM_Byte_Select  ( oPE89_AGU_DMEM_Byte_Select  ),
    .oPE89_AGU_DMEM_Store_Data   ( oPE89_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE89_DMEM_EX_Data          ( wPE89_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 90
    .oPE90_AGU_DMEM_Write_Enable ( oPE90_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE90_AGU_DMEM_Read_Enable  ( oPE90_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE90_AGU_DMEM_Address      ( wPE90_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE90_AGU_DMEM_Opcode       ( wPE90_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE90_AGU_DMEM_Byte_Select  ( oPE90_AGU_DMEM_Byte_Select  ),
    .oPE90_AGU_DMEM_Store_Data   ( oPE90_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE90_DMEM_EX_Data          ( wPE90_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 91
    .oPE91_AGU_DMEM_Write_Enable ( oPE91_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE91_AGU_DMEM_Read_Enable  ( oPE91_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE91_AGU_DMEM_Address      ( wPE91_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE91_AGU_DMEM_Opcode       ( wPE91_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE91_AGU_DMEM_Byte_Select  ( oPE91_AGU_DMEM_Byte_Select  ),
    .oPE91_AGU_DMEM_Store_Data   ( oPE91_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE91_DMEM_EX_Data          ( wPE91_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 92
    .oPE92_AGU_DMEM_Write_Enable ( oPE92_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE92_AGU_DMEM_Read_Enable  ( oPE92_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE92_AGU_DMEM_Address      ( wPE92_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE92_AGU_DMEM_Opcode       ( wPE92_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE92_AGU_DMEM_Byte_Select  ( oPE92_AGU_DMEM_Byte_Select  ),
    .oPE92_AGU_DMEM_Store_Data   ( oPE92_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE92_DMEM_EX_Data          ( wPE92_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 93
    .oPE93_AGU_DMEM_Write_Enable ( oPE93_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE93_AGU_DMEM_Read_Enable  ( oPE93_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE93_AGU_DMEM_Address      ( wPE93_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE93_AGU_DMEM_Opcode       ( wPE93_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE93_AGU_DMEM_Byte_Select  ( oPE93_AGU_DMEM_Byte_Select  ),
    .oPE93_AGU_DMEM_Store_Data   ( oPE93_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE93_DMEM_EX_Data          ( wPE93_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 94
    .oPE94_AGU_DMEM_Write_Enable ( oPE94_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE94_AGU_DMEM_Read_Enable  ( oPE94_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE94_AGU_DMEM_Address      ( wPE94_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE94_AGU_DMEM_Opcode       ( wPE94_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE94_AGU_DMEM_Byte_Select  ( oPE94_AGU_DMEM_Byte_Select  ),
    .oPE94_AGU_DMEM_Store_Data   ( oPE94_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE94_DMEM_EX_Data          ( wPE94_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 95
    .oPE95_AGU_DMEM_Write_Enable ( oPE95_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE95_AGU_DMEM_Read_Enable  ( oPE95_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE95_AGU_DMEM_Address      ( wPE95_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE95_AGU_DMEM_Opcode       ( wPE95_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE95_AGU_DMEM_Byte_Select  ( oPE95_AGU_DMEM_Byte_Select  ),
    .oPE95_AGU_DMEM_Store_Data   ( oPE95_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE95_DMEM_EX_Data          ( wPE95_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 96
    .oPE96_AGU_DMEM_Write_Enable ( oPE96_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE96_AGU_DMEM_Read_Enable  ( oPE96_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE96_AGU_DMEM_Address      ( wPE96_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE96_AGU_DMEM_Opcode       ( wPE96_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE96_AGU_DMEM_Byte_Select  ( oPE96_AGU_DMEM_Byte_Select  ),
    .oPE96_AGU_DMEM_Store_Data   ( oPE96_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE96_DMEM_EX_Data          ( wPE96_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 97
    .oPE97_AGU_DMEM_Write_Enable ( oPE97_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE97_AGU_DMEM_Read_Enable  ( oPE97_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE97_AGU_DMEM_Address      ( wPE97_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE97_AGU_DMEM_Opcode       ( wPE97_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE97_AGU_DMEM_Byte_Select  ( oPE97_AGU_DMEM_Byte_Select  ),
    .oPE97_AGU_DMEM_Store_Data   ( oPE97_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE97_DMEM_EX_Data          ( wPE97_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 98
    .oPE98_AGU_DMEM_Write_Enable ( oPE98_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE98_AGU_DMEM_Read_Enable  ( oPE98_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE98_AGU_DMEM_Address      ( wPE98_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE98_AGU_DMEM_Opcode       ( wPE98_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE98_AGU_DMEM_Byte_Select  ( oPE98_AGU_DMEM_Byte_Select  ),
    .oPE98_AGU_DMEM_Store_Data   ( oPE98_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE98_DMEM_EX_Data          ( wPE98_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 99
    .oPE99_AGU_DMEM_Write_Enable ( oPE99_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE99_AGU_DMEM_Read_Enable  ( oPE99_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE99_AGU_DMEM_Address      ( wPE99_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE99_AGU_DMEM_Opcode       ( wPE99_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE99_AGU_DMEM_Byte_Select  ( oPE99_AGU_DMEM_Byte_Select  ),
    .oPE99_AGU_DMEM_Store_Data   ( oPE99_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE99_DMEM_EX_Data          ( wPE99_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 100
    .oPE100_AGU_DMEM_Write_Enable ( oPE100_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE100_AGU_DMEM_Read_Enable  ( oPE100_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE100_AGU_DMEM_Address      ( wPE100_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE100_AGU_DMEM_Opcode       ( wPE100_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE100_AGU_DMEM_Byte_Select  ( oPE100_AGU_DMEM_Byte_Select  ),
    .oPE100_AGU_DMEM_Store_Data   ( oPE100_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE100_DMEM_EX_Data          ( wPE100_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 101
    .oPE101_AGU_DMEM_Write_Enable ( oPE101_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE101_AGU_DMEM_Read_Enable  ( oPE101_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE101_AGU_DMEM_Address      ( wPE101_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE101_AGU_DMEM_Opcode       ( wPE101_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE101_AGU_DMEM_Byte_Select  ( oPE101_AGU_DMEM_Byte_Select  ),
    .oPE101_AGU_DMEM_Store_Data   ( oPE101_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE101_DMEM_EX_Data          ( wPE101_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 102
    .oPE102_AGU_DMEM_Write_Enable ( oPE102_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE102_AGU_DMEM_Read_Enable  ( oPE102_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE102_AGU_DMEM_Address      ( wPE102_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE102_AGU_DMEM_Opcode       ( wPE102_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE102_AGU_DMEM_Byte_Select  ( oPE102_AGU_DMEM_Byte_Select  ),
    .oPE102_AGU_DMEM_Store_Data   ( oPE102_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE102_DMEM_EX_Data          ( wPE102_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 103
    .oPE103_AGU_DMEM_Write_Enable ( oPE103_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE103_AGU_DMEM_Read_Enable  ( oPE103_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE103_AGU_DMEM_Address      ( wPE103_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE103_AGU_DMEM_Opcode       ( wPE103_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE103_AGU_DMEM_Byte_Select  ( oPE103_AGU_DMEM_Byte_Select  ),
    .oPE103_AGU_DMEM_Store_Data   ( oPE103_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE103_DMEM_EX_Data          ( wPE103_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 104
    .oPE104_AGU_DMEM_Write_Enable ( oPE104_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE104_AGU_DMEM_Read_Enable  ( oPE104_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE104_AGU_DMEM_Address      ( wPE104_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE104_AGU_DMEM_Opcode       ( wPE104_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE104_AGU_DMEM_Byte_Select  ( oPE104_AGU_DMEM_Byte_Select  ),
    .oPE104_AGU_DMEM_Store_Data   ( oPE104_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE104_DMEM_EX_Data          ( wPE104_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 105
    .oPE105_AGU_DMEM_Write_Enable ( oPE105_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE105_AGU_DMEM_Read_Enable  ( oPE105_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE105_AGU_DMEM_Address      ( wPE105_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE105_AGU_DMEM_Opcode       ( wPE105_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE105_AGU_DMEM_Byte_Select  ( oPE105_AGU_DMEM_Byte_Select  ),
    .oPE105_AGU_DMEM_Store_Data   ( oPE105_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE105_DMEM_EX_Data          ( wPE105_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 106
    .oPE106_AGU_DMEM_Write_Enable ( oPE106_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE106_AGU_DMEM_Read_Enable  ( oPE106_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE106_AGU_DMEM_Address      ( wPE106_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE106_AGU_DMEM_Opcode       ( wPE106_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE106_AGU_DMEM_Byte_Select  ( oPE106_AGU_DMEM_Byte_Select  ),
    .oPE106_AGU_DMEM_Store_Data   ( oPE106_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE106_DMEM_EX_Data          ( wPE106_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 107
    .oPE107_AGU_DMEM_Write_Enable ( oPE107_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE107_AGU_DMEM_Read_Enable  ( oPE107_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE107_AGU_DMEM_Address      ( wPE107_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE107_AGU_DMEM_Opcode       ( wPE107_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE107_AGU_DMEM_Byte_Select  ( oPE107_AGU_DMEM_Byte_Select  ),
    .oPE107_AGU_DMEM_Store_Data   ( oPE107_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE107_DMEM_EX_Data          ( wPE107_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 108
    .oPE108_AGU_DMEM_Write_Enable ( oPE108_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE108_AGU_DMEM_Read_Enable  ( oPE108_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE108_AGU_DMEM_Address      ( wPE108_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE108_AGU_DMEM_Opcode       ( wPE108_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE108_AGU_DMEM_Byte_Select  ( oPE108_AGU_DMEM_Byte_Select  ),
    .oPE108_AGU_DMEM_Store_Data   ( oPE108_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE108_DMEM_EX_Data          ( wPE108_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 109
    .oPE109_AGU_DMEM_Write_Enable ( oPE109_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE109_AGU_DMEM_Read_Enable  ( oPE109_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE109_AGU_DMEM_Address      ( wPE109_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE109_AGU_DMEM_Opcode       ( wPE109_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE109_AGU_DMEM_Byte_Select  ( oPE109_AGU_DMEM_Byte_Select  ),
    .oPE109_AGU_DMEM_Store_Data   ( oPE109_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE109_DMEM_EX_Data          ( wPE109_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 110
    .oPE110_AGU_DMEM_Write_Enable ( oPE110_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE110_AGU_DMEM_Read_Enable  ( oPE110_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE110_AGU_DMEM_Address      ( wPE110_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE110_AGU_DMEM_Opcode       ( wPE110_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE110_AGU_DMEM_Byte_Select  ( oPE110_AGU_DMEM_Byte_Select  ),
    .oPE110_AGU_DMEM_Store_Data   ( oPE110_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE110_DMEM_EX_Data          ( wPE110_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 111
    .oPE111_AGU_DMEM_Write_Enable ( oPE111_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE111_AGU_DMEM_Read_Enable  ( oPE111_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE111_AGU_DMEM_Address      ( wPE111_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE111_AGU_DMEM_Opcode       ( wPE111_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE111_AGU_DMEM_Byte_Select  ( oPE111_AGU_DMEM_Byte_Select  ),
    .oPE111_AGU_DMEM_Store_Data   ( oPE111_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE111_DMEM_EX_Data          ( wPE111_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 112
    .oPE112_AGU_DMEM_Write_Enable ( oPE112_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE112_AGU_DMEM_Read_Enable  ( oPE112_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE112_AGU_DMEM_Address      ( wPE112_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE112_AGU_DMEM_Opcode       ( wPE112_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE112_AGU_DMEM_Byte_Select  ( oPE112_AGU_DMEM_Byte_Select  ),
    .oPE112_AGU_DMEM_Store_Data   ( oPE112_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE112_DMEM_EX_Data          ( wPE112_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 113
    .oPE113_AGU_DMEM_Write_Enable ( oPE113_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE113_AGU_DMEM_Read_Enable  ( oPE113_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE113_AGU_DMEM_Address      ( wPE113_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE113_AGU_DMEM_Opcode       ( wPE113_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE113_AGU_DMEM_Byte_Select  ( oPE113_AGU_DMEM_Byte_Select  ),
    .oPE113_AGU_DMEM_Store_Data   ( oPE113_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE113_DMEM_EX_Data          ( wPE113_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 114
    .oPE114_AGU_DMEM_Write_Enable ( oPE114_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE114_AGU_DMEM_Read_Enable  ( oPE114_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE114_AGU_DMEM_Address      ( wPE114_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE114_AGU_DMEM_Opcode       ( wPE114_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE114_AGU_DMEM_Byte_Select  ( oPE114_AGU_DMEM_Byte_Select  ),
    .oPE114_AGU_DMEM_Store_Data   ( oPE114_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE114_DMEM_EX_Data          ( wPE114_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 115
    .oPE115_AGU_DMEM_Write_Enable ( oPE115_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE115_AGU_DMEM_Read_Enable  ( oPE115_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE115_AGU_DMEM_Address      ( wPE115_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE115_AGU_DMEM_Opcode       ( wPE115_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE115_AGU_DMEM_Byte_Select  ( oPE115_AGU_DMEM_Byte_Select  ),
    .oPE115_AGU_DMEM_Store_Data   ( oPE115_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE115_DMEM_EX_Data          ( wPE115_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 116
    .oPE116_AGU_DMEM_Write_Enable ( oPE116_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE116_AGU_DMEM_Read_Enable  ( oPE116_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE116_AGU_DMEM_Address      ( wPE116_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE116_AGU_DMEM_Opcode       ( wPE116_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE116_AGU_DMEM_Byte_Select  ( oPE116_AGU_DMEM_Byte_Select  ),
    .oPE116_AGU_DMEM_Store_Data   ( oPE116_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE116_DMEM_EX_Data          ( wPE116_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 117
    .oPE117_AGU_DMEM_Write_Enable ( oPE117_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE117_AGU_DMEM_Read_Enable  ( oPE117_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE117_AGU_DMEM_Address      ( wPE117_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE117_AGU_DMEM_Opcode       ( wPE117_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE117_AGU_DMEM_Byte_Select  ( oPE117_AGU_DMEM_Byte_Select  ),
    .oPE117_AGU_DMEM_Store_Data   ( oPE117_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE117_DMEM_EX_Data          ( wPE117_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 118
    .oPE118_AGU_DMEM_Write_Enable ( oPE118_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE118_AGU_DMEM_Read_Enable  ( oPE118_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE118_AGU_DMEM_Address      ( wPE118_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE118_AGU_DMEM_Opcode       ( wPE118_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE118_AGU_DMEM_Byte_Select  ( oPE118_AGU_DMEM_Byte_Select  ),
    .oPE118_AGU_DMEM_Store_Data   ( oPE118_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE118_DMEM_EX_Data          ( wPE118_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 119
    .oPE119_AGU_DMEM_Write_Enable ( oPE119_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE119_AGU_DMEM_Read_Enable  ( oPE119_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE119_AGU_DMEM_Address      ( wPE119_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE119_AGU_DMEM_Opcode       ( wPE119_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE119_AGU_DMEM_Byte_Select  ( oPE119_AGU_DMEM_Byte_Select  ),
    .oPE119_AGU_DMEM_Store_Data   ( oPE119_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE119_DMEM_EX_Data          ( wPE119_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 120
    .oPE120_AGU_DMEM_Write_Enable ( oPE120_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE120_AGU_DMEM_Read_Enable  ( oPE120_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE120_AGU_DMEM_Address      ( wPE120_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE120_AGU_DMEM_Opcode       ( wPE120_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE120_AGU_DMEM_Byte_Select  ( oPE120_AGU_DMEM_Byte_Select  ),
    .oPE120_AGU_DMEM_Store_Data   ( oPE120_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE120_DMEM_EX_Data          ( wPE120_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 121
    .oPE121_AGU_DMEM_Write_Enable ( oPE121_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE121_AGU_DMEM_Read_Enable  ( oPE121_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE121_AGU_DMEM_Address      ( wPE121_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE121_AGU_DMEM_Opcode       ( wPE121_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE121_AGU_DMEM_Byte_Select  ( oPE121_AGU_DMEM_Byte_Select  ),
    .oPE121_AGU_DMEM_Store_Data   ( oPE121_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE121_DMEM_EX_Data          ( wPE121_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 122
    .oPE122_AGU_DMEM_Write_Enable ( oPE122_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE122_AGU_DMEM_Read_Enable  ( oPE122_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE122_AGU_DMEM_Address      ( wPE122_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE122_AGU_DMEM_Opcode       ( wPE122_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE122_AGU_DMEM_Byte_Select  ( oPE122_AGU_DMEM_Byte_Select  ),
    .oPE122_AGU_DMEM_Store_Data   ( oPE122_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE122_DMEM_EX_Data          ( wPE122_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 123
    .oPE123_AGU_DMEM_Write_Enable ( oPE123_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE123_AGU_DMEM_Read_Enable  ( oPE123_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE123_AGU_DMEM_Address      ( wPE123_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE123_AGU_DMEM_Opcode       ( wPE123_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE123_AGU_DMEM_Byte_Select  ( oPE123_AGU_DMEM_Byte_Select  ),
    .oPE123_AGU_DMEM_Store_Data   ( oPE123_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE123_DMEM_EX_Data          ( wPE123_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 124
    .oPE124_AGU_DMEM_Write_Enable ( oPE124_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE124_AGU_DMEM_Read_Enable  ( oPE124_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE124_AGU_DMEM_Address      ( wPE124_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE124_AGU_DMEM_Opcode       ( wPE124_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE124_AGU_DMEM_Byte_Select  ( oPE124_AGU_DMEM_Byte_Select  ),
    .oPE124_AGU_DMEM_Store_Data   ( oPE124_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE124_DMEM_EX_Data          ( wPE124_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 125
    .oPE125_AGU_DMEM_Write_Enable ( oPE125_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE125_AGU_DMEM_Read_Enable  ( oPE125_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE125_AGU_DMEM_Address      ( wPE125_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE125_AGU_DMEM_Opcode       ( wPE125_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE125_AGU_DMEM_Byte_Select  ( oPE125_AGU_DMEM_Byte_Select  ),
    .oPE125_AGU_DMEM_Store_Data   ( oPE125_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE125_DMEM_EX_Data          ( wPE125_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 126
    .oPE126_AGU_DMEM_Write_Enable ( oPE126_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE126_AGU_DMEM_Read_Enable  ( oPE126_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE126_AGU_DMEM_Address      ( wPE126_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE126_AGU_DMEM_Opcode       ( wPE126_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE126_AGU_DMEM_Byte_Select  ( oPE126_AGU_DMEM_Byte_Select  ),
    .oPE126_AGU_DMEM_Store_Data   ( oPE126_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE126_DMEM_EX_Data          ( wPE126_DMEM_EX_Data          ),  // data loaded from data memory
    
    // PE 127
    .oPE127_AGU_DMEM_Write_Enable ( oPE127_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE127_AGU_DMEM_Read_Enable  ( oPE127_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE127_AGU_DMEM_Address      ( wPE127_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE127_AGU_DMEM_Opcode       ( wPE127_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE127_AGU_DMEM_Byte_Select  ( oPE127_AGU_DMEM_Byte_Select  ),
    .oPE127_AGU_DMEM_Store_Data   ( oPE127_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE127_DMEM_EX_Data          ( wPE127_DMEM_EX_Data          ),  // data loaded from data memory
    
    // from/to CP
    .iCP_Data                      ( wCP_Port1_Data            ),  // cp port 1 data to pe
    .oFirst_PE_Port1_Data          ( wFirst_PE_Port1_Data      ),  // data from first PE RF port 1
    .oLast_PE_Port1_Data           ( wLast_PE_Port1_Data       )   // data from last PE RF port 1
  );


endmodule