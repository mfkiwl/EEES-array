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
    
    // PE 4
    oPE4_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE4_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE4_AGU_DMEM_Address,         // Address to DMEM
    oPE4_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE4_AGU_DMEM_Byte_Select,
    oPE4_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE4_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 5
    oPE5_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE5_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE5_AGU_DMEM_Address,         // Address to DMEM
    oPE5_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE5_AGU_DMEM_Byte_Select,
    oPE5_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE5_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 6
    oPE6_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE6_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE6_AGU_DMEM_Address,         // Address to DMEM
    oPE6_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE6_AGU_DMEM_Byte_Select,
    oPE6_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE6_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 7
    oPE7_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE7_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE7_AGU_DMEM_Address,         // Address to DMEM
    oPE7_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE7_AGU_DMEM_Byte_Select,
    oPE7_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE7_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 8
    oPE8_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE8_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE8_AGU_DMEM_Address,         // Address to DMEM
    oPE8_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE8_AGU_DMEM_Byte_Select,
    oPE8_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE8_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 9
    oPE9_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE9_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE9_AGU_DMEM_Address,         // Address to DMEM
    oPE9_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE9_AGU_DMEM_Byte_Select,
    oPE9_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE9_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 10
    oPE10_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE10_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE10_AGU_DMEM_Address,         // Address to DMEM
    oPE10_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE10_AGU_DMEM_Byte_Select,
    oPE10_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE10_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 11
    oPE11_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE11_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE11_AGU_DMEM_Address,         // Address to DMEM
    oPE11_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE11_AGU_DMEM_Byte_Select,
    oPE11_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE11_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 12
    oPE12_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE12_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE12_AGU_DMEM_Address,         // Address to DMEM
    oPE12_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE12_AGU_DMEM_Byte_Select,
    oPE12_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE12_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 13
    oPE13_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE13_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE13_AGU_DMEM_Address,         // Address to DMEM
    oPE13_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE13_AGU_DMEM_Byte_Select,
    oPE13_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE13_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 14
    oPE14_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE14_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE14_AGU_DMEM_Address,         // Address to DMEM
    oPE14_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE14_AGU_DMEM_Byte_Select,
    oPE14_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE14_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 15
    oPE15_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE15_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE15_AGU_DMEM_Address,         // Address to DMEM
    oPE15_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE15_AGU_DMEM_Byte_Select,
    oPE15_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE15_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 16
    oPE16_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE16_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE16_AGU_DMEM_Address,         // Address to DMEM
    oPE16_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE16_AGU_DMEM_Byte_Select,
    oPE16_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE16_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 17
    oPE17_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE17_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE17_AGU_DMEM_Address,         // Address to DMEM
    oPE17_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE17_AGU_DMEM_Byte_Select,
    oPE17_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE17_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 18
    oPE18_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE18_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE18_AGU_DMEM_Address,         // Address to DMEM
    oPE18_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE18_AGU_DMEM_Byte_Select,
    oPE18_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE18_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 19
    oPE19_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE19_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE19_AGU_DMEM_Address,         // Address to DMEM
    oPE19_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE19_AGU_DMEM_Byte_Select,
    oPE19_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE19_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 20
    oPE20_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE20_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE20_AGU_DMEM_Address,         // Address to DMEM
    oPE20_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE20_AGU_DMEM_Byte_Select,
    oPE20_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE20_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 21
    oPE21_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE21_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE21_AGU_DMEM_Address,         // Address to DMEM
    oPE21_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE21_AGU_DMEM_Byte_Select,
    oPE21_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE21_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 22
    oPE22_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE22_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE22_AGU_DMEM_Address,         // Address to DMEM
    oPE22_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE22_AGU_DMEM_Byte_Select,
    oPE22_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE22_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 23
    oPE23_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE23_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE23_AGU_DMEM_Address,         // Address to DMEM
    oPE23_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE23_AGU_DMEM_Byte_Select,
    oPE23_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE23_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 24
    oPE24_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE24_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE24_AGU_DMEM_Address,         // Address to DMEM
    oPE24_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE24_AGU_DMEM_Byte_Select,
    oPE24_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE24_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 25
    oPE25_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE25_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE25_AGU_DMEM_Address,         // Address to DMEM
    oPE25_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE25_AGU_DMEM_Byte_Select,
    oPE25_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE25_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 26
    oPE26_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE26_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE26_AGU_DMEM_Address,         // Address to DMEM
    oPE26_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE26_AGU_DMEM_Byte_Select,
    oPE26_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE26_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 27
    oPE27_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE27_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE27_AGU_DMEM_Address,         // Address to DMEM
    oPE27_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE27_AGU_DMEM_Byte_Select,
    oPE27_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE27_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 28
    oPE28_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE28_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE28_AGU_DMEM_Address,         // Address to DMEM
    oPE28_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE28_AGU_DMEM_Byte_Select,
    oPE28_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE28_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 29
    oPE29_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE29_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE29_AGU_DMEM_Address,         // Address to DMEM
    oPE29_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE29_AGU_DMEM_Byte_Select,
    oPE29_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE29_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 30
    oPE30_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE30_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE30_AGU_DMEM_Address,         // Address to DMEM
    oPE30_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE30_AGU_DMEM_Byte_Select,
    oPE30_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE30_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 31
    oPE31_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE31_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE31_AGU_DMEM_Address,         // Address to DMEM
    oPE31_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE31_AGU_DMEM_Byte_Select,
    oPE31_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE31_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 32
    oPE32_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE32_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE32_AGU_DMEM_Address,         // Address to DMEM
    oPE32_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE32_AGU_DMEM_Byte_Select,
    oPE32_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE32_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 33
    oPE33_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE33_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE33_AGU_DMEM_Address,         // Address to DMEM
    oPE33_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE33_AGU_DMEM_Byte_Select,
    oPE33_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE33_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 34
    oPE34_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE34_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE34_AGU_DMEM_Address,         // Address to DMEM
    oPE34_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE34_AGU_DMEM_Byte_Select,
    oPE34_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE34_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 35
    oPE35_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE35_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE35_AGU_DMEM_Address,         // Address to DMEM
    oPE35_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE35_AGU_DMEM_Byte_Select,
    oPE35_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE35_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 36
    oPE36_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE36_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE36_AGU_DMEM_Address,         // Address to DMEM
    oPE36_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE36_AGU_DMEM_Byte_Select,
    oPE36_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE36_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 37
    oPE37_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE37_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE37_AGU_DMEM_Address,         // Address to DMEM
    oPE37_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE37_AGU_DMEM_Byte_Select,
    oPE37_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE37_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 38
    oPE38_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE38_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE38_AGU_DMEM_Address,         // Address to DMEM
    oPE38_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE38_AGU_DMEM_Byte_Select,
    oPE38_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE38_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 39
    oPE39_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE39_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE39_AGU_DMEM_Address,         // Address to DMEM
    oPE39_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE39_AGU_DMEM_Byte_Select,
    oPE39_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE39_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 40
    oPE40_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE40_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE40_AGU_DMEM_Address,         // Address to DMEM
    oPE40_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE40_AGU_DMEM_Byte_Select,
    oPE40_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE40_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 41
    oPE41_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE41_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE41_AGU_DMEM_Address,         // Address to DMEM
    oPE41_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE41_AGU_DMEM_Byte_Select,
    oPE41_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE41_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 42
    oPE42_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE42_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE42_AGU_DMEM_Address,         // Address to DMEM
    oPE42_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE42_AGU_DMEM_Byte_Select,
    oPE42_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE42_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 43
    oPE43_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE43_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE43_AGU_DMEM_Address,         // Address to DMEM
    oPE43_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE43_AGU_DMEM_Byte_Select,
    oPE43_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE43_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 44
    oPE44_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE44_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE44_AGU_DMEM_Address,         // Address to DMEM
    oPE44_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE44_AGU_DMEM_Byte_Select,
    oPE44_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE44_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 45
    oPE45_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE45_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE45_AGU_DMEM_Address,         // Address to DMEM
    oPE45_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE45_AGU_DMEM_Byte_Select,
    oPE45_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE45_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 46
    oPE46_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE46_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE46_AGU_DMEM_Address,         // Address to DMEM
    oPE46_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE46_AGU_DMEM_Byte_Select,
    oPE46_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE46_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 47
    oPE47_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE47_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE47_AGU_DMEM_Address,         // Address to DMEM
    oPE47_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE47_AGU_DMEM_Byte_Select,
    oPE47_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE47_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 48
    oPE48_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE48_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE48_AGU_DMEM_Address,         // Address to DMEM
    oPE48_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE48_AGU_DMEM_Byte_Select,
    oPE48_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE48_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 49
    oPE49_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE49_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE49_AGU_DMEM_Address,         // Address to DMEM
    oPE49_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE49_AGU_DMEM_Byte_Select,
    oPE49_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE49_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 50
    oPE50_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE50_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE50_AGU_DMEM_Address,         // Address to DMEM
    oPE50_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE50_AGU_DMEM_Byte_Select,
    oPE50_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE50_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 51
    oPE51_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE51_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE51_AGU_DMEM_Address,         // Address to DMEM
    oPE51_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE51_AGU_DMEM_Byte_Select,
    oPE51_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE51_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 52
    oPE52_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE52_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE52_AGU_DMEM_Address,         // Address to DMEM
    oPE52_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE52_AGU_DMEM_Byte_Select,
    oPE52_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE52_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 53
    oPE53_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE53_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE53_AGU_DMEM_Address,         // Address to DMEM
    oPE53_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE53_AGU_DMEM_Byte_Select,
    oPE53_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE53_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 54
    oPE54_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE54_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE54_AGU_DMEM_Address,         // Address to DMEM
    oPE54_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE54_AGU_DMEM_Byte_Select,
    oPE54_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE54_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 55
    oPE55_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE55_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE55_AGU_DMEM_Address,         // Address to DMEM
    oPE55_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE55_AGU_DMEM_Byte_Select,
    oPE55_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE55_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 56
    oPE56_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE56_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE56_AGU_DMEM_Address,         // Address to DMEM
    oPE56_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE56_AGU_DMEM_Byte_Select,
    oPE56_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE56_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 57
    oPE57_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE57_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE57_AGU_DMEM_Address,         // Address to DMEM
    oPE57_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE57_AGU_DMEM_Byte_Select,
    oPE57_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE57_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 58
    oPE58_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE58_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE58_AGU_DMEM_Address,         // Address to DMEM
    oPE58_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE58_AGU_DMEM_Byte_Select,
    oPE58_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE58_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 59
    oPE59_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE59_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE59_AGU_DMEM_Address,         // Address to DMEM
    oPE59_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE59_AGU_DMEM_Byte_Select,
    oPE59_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE59_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 60
    oPE60_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE60_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE60_AGU_DMEM_Address,         // Address to DMEM
    oPE60_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE60_AGU_DMEM_Byte_Select,
    oPE60_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE60_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 61
    oPE61_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE61_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE61_AGU_DMEM_Address,         // Address to DMEM
    oPE61_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE61_AGU_DMEM_Byte_Select,
    oPE61_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE61_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 62
    oPE62_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE62_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE62_AGU_DMEM_Address,         // Address to DMEM
    oPE62_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE62_AGU_DMEM_Byte_Select,
    oPE62_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE62_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 63
    oPE63_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE63_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE63_AGU_DMEM_Address,         // Address to DMEM
    oPE63_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE63_AGU_DMEM_Byte_Select,
    oPE63_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE63_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 64
    oPE64_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE64_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE64_AGU_DMEM_Address,         // Address to DMEM
    oPE64_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE64_AGU_DMEM_Byte_Select,
    oPE64_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE64_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 65
    oPE65_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE65_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE65_AGU_DMEM_Address,         // Address to DMEM
    oPE65_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE65_AGU_DMEM_Byte_Select,
    oPE65_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE65_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 66
    oPE66_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE66_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE66_AGU_DMEM_Address,         // Address to DMEM
    oPE66_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE66_AGU_DMEM_Byte_Select,
    oPE66_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE66_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 67
    oPE67_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE67_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE67_AGU_DMEM_Address,         // Address to DMEM
    oPE67_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE67_AGU_DMEM_Byte_Select,
    oPE67_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE67_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 68
    oPE68_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE68_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE68_AGU_DMEM_Address,         // Address to DMEM
    oPE68_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE68_AGU_DMEM_Byte_Select,
    oPE68_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE68_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 69
    oPE69_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE69_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE69_AGU_DMEM_Address,         // Address to DMEM
    oPE69_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE69_AGU_DMEM_Byte_Select,
    oPE69_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE69_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 70
    oPE70_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE70_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE70_AGU_DMEM_Address,         // Address to DMEM
    oPE70_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE70_AGU_DMEM_Byte_Select,
    oPE70_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE70_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 71
    oPE71_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE71_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE71_AGU_DMEM_Address,         // Address to DMEM
    oPE71_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE71_AGU_DMEM_Byte_Select,
    oPE71_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE71_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 72
    oPE72_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE72_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE72_AGU_DMEM_Address,         // Address to DMEM
    oPE72_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE72_AGU_DMEM_Byte_Select,
    oPE72_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE72_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 73
    oPE73_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE73_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE73_AGU_DMEM_Address,         // Address to DMEM
    oPE73_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE73_AGU_DMEM_Byte_Select,
    oPE73_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE73_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 74
    oPE74_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE74_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE74_AGU_DMEM_Address,         // Address to DMEM
    oPE74_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE74_AGU_DMEM_Byte_Select,
    oPE74_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE74_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 75
    oPE75_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE75_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE75_AGU_DMEM_Address,         // Address to DMEM
    oPE75_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE75_AGU_DMEM_Byte_Select,
    oPE75_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE75_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 76
    oPE76_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE76_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE76_AGU_DMEM_Address,         // Address to DMEM
    oPE76_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE76_AGU_DMEM_Byte_Select,
    oPE76_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE76_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 77
    oPE77_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE77_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE77_AGU_DMEM_Address,         // Address to DMEM
    oPE77_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE77_AGU_DMEM_Byte_Select,
    oPE77_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE77_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 78
    oPE78_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE78_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE78_AGU_DMEM_Address,         // Address to DMEM
    oPE78_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE78_AGU_DMEM_Byte_Select,
    oPE78_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE78_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 79
    oPE79_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE79_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE79_AGU_DMEM_Address,         // Address to DMEM
    oPE79_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE79_AGU_DMEM_Byte_Select,
    oPE79_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE79_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 80
    oPE80_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE80_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE80_AGU_DMEM_Address,         // Address to DMEM
    oPE80_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE80_AGU_DMEM_Byte_Select,
    oPE80_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE80_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 81
    oPE81_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE81_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE81_AGU_DMEM_Address,         // Address to DMEM
    oPE81_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE81_AGU_DMEM_Byte_Select,
    oPE81_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE81_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 82
    oPE82_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE82_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE82_AGU_DMEM_Address,         // Address to DMEM
    oPE82_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE82_AGU_DMEM_Byte_Select,
    oPE82_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE82_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 83
    oPE83_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE83_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE83_AGU_DMEM_Address,         // Address to DMEM
    oPE83_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE83_AGU_DMEM_Byte_Select,
    oPE83_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE83_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 84
    oPE84_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE84_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE84_AGU_DMEM_Address,         // Address to DMEM
    oPE84_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE84_AGU_DMEM_Byte_Select,
    oPE84_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE84_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 85
    oPE85_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE85_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE85_AGU_DMEM_Address,         // Address to DMEM
    oPE85_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE85_AGU_DMEM_Byte_Select,
    oPE85_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE85_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 86
    oPE86_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE86_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE86_AGU_DMEM_Address,         // Address to DMEM
    oPE86_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE86_AGU_DMEM_Byte_Select,
    oPE86_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE86_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 87
    oPE87_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE87_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE87_AGU_DMEM_Address,         // Address to DMEM
    oPE87_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE87_AGU_DMEM_Byte_Select,
    oPE87_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE87_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 88
    oPE88_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE88_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE88_AGU_DMEM_Address,         // Address to DMEM
    oPE88_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE88_AGU_DMEM_Byte_Select,
    oPE88_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE88_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 89
    oPE89_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE89_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE89_AGU_DMEM_Address,         // Address to DMEM
    oPE89_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE89_AGU_DMEM_Byte_Select,
    oPE89_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE89_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 90
    oPE90_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE90_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE90_AGU_DMEM_Address,         // Address to DMEM
    oPE90_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE90_AGU_DMEM_Byte_Select,
    oPE90_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE90_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 91
    oPE91_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE91_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE91_AGU_DMEM_Address,         // Address to DMEM
    oPE91_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE91_AGU_DMEM_Byte_Select,
    oPE91_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE91_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 92
    oPE92_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE92_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE92_AGU_DMEM_Address,         // Address to DMEM
    oPE92_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE92_AGU_DMEM_Byte_Select,
    oPE92_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE92_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 93
    oPE93_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE93_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE93_AGU_DMEM_Address,         // Address to DMEM
    oPE93_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE93_AGU_DMEM_Byte_Select,
    oPE93_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE93_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 94
    oPE94_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE94_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE94_AGU_DMEM_Address,         // Address to DMEM
    oPE94_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE94_AGU_DMEM_Byte_Select,
    oPE94_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE94_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 95
    oPE95_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE95_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE95_AGU_DMEM_Address,         // Address to DMEM
    oPE95_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE95_AGU_DMEM_Byte_Select,
    oPE95_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE95_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 96
    oPE96_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE96_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE96_AGU_DMEM_Address,         // Address to DMEM
    oPE96_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE96_AGU_DMEM_Byte_Select,
    oPE96_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE96_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 97
    oPE97_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE97_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE97_AGU_DMEM_Address,         // Address to DMEM
    oPE97_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE97_AGU_DMEM_Byte_Select,
    oPE97_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE97_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 98
    oPE98_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE98_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE98_AGU_DMEM_Address,         // Address to DMEM
    oPE98_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE98_AGU_DMEM_Byte_Select,
    oPE98_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE98_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 99
    oPE99_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE99_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE99_AGU_DMEM_Address,         // Address to DMEM
    oPE99_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE99_AGU_DMEM_Byte_Select,
    oPE99_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE99_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 100
    oPE100_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE100_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE100_AGU_DMEM_Address,         // Address to DMEM
    oPE100_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE100_AGU_DMEM_Byte_Select,
    oPE100_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE100_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 101
    oPE101_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE101_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE101_AGU_DMEM_Address,         // Address to DMEM
    oPE101_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE101_AGU_DMEM_Byte_Select,
    oPE101_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE101_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 102
    oPE102_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE102_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE102_AGU_DMEM_Address,         // Address to DMEM
    oPE102_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE102_AGU_DMEM_Byte_Select,
    oPE102_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE102_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 103
    oPE103_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE103_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE103_AGU_DMEM_Address,         // Address to DMEM
    oPE103_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE103_AGU_DMEM_Byte_Select,
    oPE103_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE103_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 104
    oPE104_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE104_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE104_AGU_DMEM_Address,         // Address to DMEM
    oPE104_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE104_AGU_DMEM_Byte_Select,
    oPE104_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE104_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 105
    oPE105_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE105_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE105_AGU_DMEM_Address,         // Address to DMEM
    oPE105_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE105_AGU_DMEM_Byte_Select,
    oPE105_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE105_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 106
    oPE106_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE106_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE106_AGU_DMEM_Address,         // Address to DMEM
    oPE106_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE106_AGU_DMEM_Byte_Select,
    oPE106_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE106_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 107
    oPE107_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE107_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE107_AGU_DMEM_Address,         // Address to DMEM
    oPE107_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE107_AGU_DMEM_Byte_Select,
    oPE107_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE107_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 108
    oPE108_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE108_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE108_AGU_DMEM_Address,         // Address to DMEM
    oPE108_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE108_AGU_DMEM_Byte_Select,
    oPE108_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE108_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 109
    oPE109_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE109_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE109_AGU_DMEM_Address,         // Address to DMEM
    oPE109_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE109_AGU_DMEM_Byte_Select,
    oPE109_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE109_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 110
    oPE110_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE110_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE110_AGU_DMEM_Address,         // Address to DMEM
    oPE110_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE110_AGU_DMEM_Byte_Select,
    oPE110_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE110_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 111
    oPE111_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE111_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE111_AGU_DMEM_Address,         // Address to DMEM
    oPE111_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE111_AGU_DMEM_Byte_Select,
    oPE111_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE111_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 112
    oPE112_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE112_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE112_AGU_DMEM_Address,         // Address to DMEM
    oPE112_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE112_AGU_DMEM_Byte_Select,
    oPE112_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE112_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 113
    oPE113_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE113_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE113_AGU_DMEM_Address,         // Address to DMEM
    oPE113_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE113_AGU_DMEM_Byte_Select,
    oPE113_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE113_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 114
    oPE114_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE114_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE114_AGU_DMEM_Address,         // Address to DMEM
    oPE114_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE114_AGU_DMEM_Byte_Select,
    oPE114_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE114_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 115
    oPE115_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE115_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE115_AGU_DMEM_Address,         // Address to DMEM
    oPE115_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE115_AGU_DMEM_Byte_Select,
    oPE115_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE115_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 116
    oPE116_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE116_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE116_AGU_DMEM_Address,         // Address to DMEM
    oPE116_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE116_AGU_DMEM_Byte_Select,
    oPE116_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE116_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 117
    oPE117_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE117_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE117_AGU_DMEM_Address,         // Address to DMEM
    oPE117_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE117_AGU_DMEM_Byte_Select,
    oPE117_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE117_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 118
    oPE118_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE118_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE118_AGU_DMEM_Address,         // Address to DMEM
    oPE118_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE118_AGU_DMEM_Byte_Select,
    oPE118_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE118_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 119
    oPE119_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE119_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE119_AGU_DMEM_Address,         // Address to DMEM
    oPE119_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE119_AGU_DMEM_Byte_Select,
    oPE119_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE119_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 120
    oPE120_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE120_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE120_AGU_DMEM_Address,         // Address to DMEM
    oPE120_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE120_AGU_DMEM_Byte_Select,
    oPE120_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE120_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 121
    oPE121_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE121_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE121_AGU_DMEM_Address,         // Address to DMEM
    oPE121_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE121_AGU_DMEM_Byte_Select,
    oPE121_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE121_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 122
    oPE122_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE122_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE122_AGU_DMEM_Address,         // Address to DMEM
    oPE122_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE122_AGU_DMEM_Byte_Select,
    oPE122_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE122_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 123
    oPE123_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE123_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE123_AGU_DMEM_Address,         // Address to DMEM
    oPE123_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE123_AGU_DMEM_Byte_Select,
    oPE123_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE123_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 124
    oPE124_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE124_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE124_AGU_DMEM_Address,         // Address to DMEM
    oPE124_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE124_AGU_DMEM_Byte_Select,
    oPE124_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE124_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 125
    oPE125_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE125_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE125_AGU_DMEM_Address,         // Address to DMEM
    oPE125_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE125_AGU_DMEM_Byte_Select,
    oPE125_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE125_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 126
    oPE126_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE126_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE126_AGU_DMEM_Address,         // Address to DMEM
    oPE126_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE126_AGU_DMEM_Byte_Select,
    oPE126_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE126_DMEM_EX_Data,             // data loaded from data memory
    
    // PE 127
    oPE127_AGU_DMEM_Write_Enable,    // LSU stage data-memory write enable
    oPE127_AGU_DMEM_Read_Enable,     // LSU stage data-memory read enable
    oPE127_AGU_DMEM_Address,         // Address to DMEM
    oPE127_AGU_DMEM_Opcode,          // LSU opcoce: word/half-word/byte
    oPE127_AGU_DMEM_Byte_Select,
    oPE127_AGU_DMEM_Store_Data,      // Store data to EX stage (for store instruction only)
    iPE127_DMEM_EX_Data,             // data loaded from data memory
    
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
  
  // PE 4
  output                                  oPE4_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE4_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE4_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE4_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE4_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE4_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE4_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 5
  output                                  oPE5_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE5_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE5_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE5_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE5_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE5_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE5_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 6
  output                                  oPE6_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE6_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE6_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE6_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE6_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE6_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE6_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 7
  output                                  oPE7_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE7_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE7_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE7_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE7_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE7_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE7_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 8
  output                                  oPE8_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE8_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE8_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE8_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE8_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE8_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE8_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 9
  output                                  oPE9_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE9_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE9_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE9_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE9_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE9_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE9_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 10
  output                                  oPE10_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE10_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE10_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE10_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE10_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE10_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE10_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 11
  output                                  oPE11_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE11_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE11_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE11_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE11_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE11_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE11_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 12
  output                                  oPE12_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE12_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE12_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE12_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE12_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE12_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE12_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 13
  output                                  oPE13_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE13_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE13_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE13_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE13_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE13_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE13_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 14
  output                                  oPE14_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE14_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE14_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE14_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE14_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE14_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE14_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 15
  output                                  oPE15_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE15_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE15_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE15_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE15_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE15_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE15_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 16
  output                                  oPE16_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE16_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE16_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE16_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE16_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE16_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE16_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 17
  output                                  oPE17_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE17_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE17_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE17_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE17_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE17_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE17_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 18
  output                                  oPE18_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE18_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE18_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE18_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE18_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE18_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE18_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 19
  output                                  oPE19_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE19_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE19_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE19_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE19_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE19_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE19_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 20
  output                                  oPE20_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE20_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE20_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE20_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE20_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE20_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE20_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 21
  output                                  oPE21_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE21_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE21_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE21_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE21_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE21_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE21_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 22
  output                                  oPE22_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE22_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE22_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE22_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE22_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE22_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE22_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 23
  output                                  oPE23_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE23_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE23_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE23_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE23_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE23_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE23_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 24
  output                                  oPE24_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE24_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE24_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE24_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE24_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE24_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE24_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 25
  output                                  oPE25_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE25_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE25_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE25_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE25_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE25_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE25_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 26
  output                                  oPE26_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE26_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE26_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE26_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE26_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE26_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE26_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 27
  output                                  oPE27_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE27_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE27_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE27_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE27_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE27_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE27_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 28
  output                                  oPE28_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE28_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE28_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE28_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE28_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE28_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE28_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 29
  output                                  oPE29_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE29_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE29_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE29_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE29_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE29_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE29_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 30
  output                                  oPE30_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE30_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE30_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE30_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE30_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE30_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE30_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 31
  output                                  oPE31_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE31_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE31_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE31_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE31_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE31_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE31_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 32
  output                                  oPE32_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE32_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE32_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE32_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE32_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE32_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE32_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 33
  output                                  oPE33_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE33_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE33_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE33_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE33_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE33_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE33_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 34
  output                                  oPE34_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE34_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE34_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE34_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE34_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE34_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE34_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 35
  output                                  oPE35_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE35_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE35_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE35_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE35_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE35_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE35_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 36
  output                                  oPE36_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE36_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE36_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE36_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE36_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE36_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE36_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 37
  output                                  oPE37_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE37_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE37_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE37_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE37_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE37_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE37_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 38
  output                                  oPE38_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE38_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE38_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE38_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE38_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE38_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE38_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 39
  output                                  oPE39_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE39_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE39_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE39_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE39_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE39_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE39_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 40
  output                                  oPE40_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE40_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE40_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE40_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE40_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE40_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE40_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 41
  output                                  oPE41_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE41_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE41_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE41_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE41_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE41_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE41_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 42
  output                                  oPE42_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE42_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE42_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE42_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE42_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE42_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE42_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 43
  output                                  oPE43_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE43_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE43_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE43_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE43_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE43_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE43_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 44
  output                                  oPE44_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE44_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE44_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE44_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE44_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE44_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE44_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 45
  output                                  oPE45_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE45_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE45_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE45_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE45_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE45_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE45_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 46
  output                                  oPE46_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE46_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE46_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE46_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE46_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE46_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE46_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 47
  output                                  oPE47_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE47_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE47_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE47_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE47_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE47_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE47_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 48
  output                                  oPE48_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE48_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE48_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE48_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE48_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE48_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE48_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 49
  output                                  oPE49_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE49_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE49_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE49_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE49_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE49_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE49_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 50
  output                                  oPE50_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE50_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE50_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE50_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE50_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE50_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE50_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 51
  output                                  oPE51_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE51_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE51_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE51_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE51_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE51_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE51_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 52
  output                                  oPE52_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE52_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE52_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE52_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE52_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE52_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE52_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 53
  output                                  oPE53_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE53_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE53_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE53_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE53_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE53_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE53_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 54
  output                                  oPE54_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE54_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE54_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE54_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE54_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE54_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE54_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 55
  output                                  oPE55_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE55_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE55_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE55_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE55_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE55_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE55_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 56
  output                                  oPE56_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE56_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE56_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE56_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE56_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE56_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE56_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 57
  output                                  oPE57_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE57_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE57_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE57_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE57_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE57_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE57_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 58
  output                                  oPE58_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE58_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE58_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE58_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE58_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE58_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE58_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 59
  output                                  oPE59_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE59_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE59_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE59_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE59_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE59_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE59_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 60
  output                                  oPE60_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE60_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE60_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE60_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE60_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE60_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE60_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 61
  output                                  oPE61_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE61_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE61_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE61_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE61_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE61_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE61_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 62
  output                                  oPE62_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE62_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE62_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE62_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE62_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE62_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE62_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 63
  output                                  oPE63_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE63_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE63_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE63_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE63_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE63_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE63_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 64
  output                                  oPE64_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE64_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE64_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE64_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE64_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE64_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE64_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 65
  output                                  oPE65_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE65_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE65_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE65_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE65_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE65_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE65_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 66
  output                                  oPE66_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE66_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE66_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE66_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE66_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE66_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE66_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 67
  output                                  oPE67_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE67_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE67_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE67_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE67_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE67_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE67_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 68
  output                                  oPE68_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE68_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE68_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE68_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE68_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE68_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE68_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 69
  output                                  oPE69_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE69_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE69_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE69_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE69_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE69_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE69_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 70
  output                                  oPE70_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE70_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE70_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE70_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE70_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE70_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE70_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 71
  output                                  oPE71_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE71_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE71_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE71_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE71_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE71_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE71_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 72
  output                                  oPE72_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE72_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE72_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE72_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE72_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE72_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE72_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 73
  output                                  oPE73_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE73_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE73_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE73_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE73_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE73_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE73_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 74
  output                                  oPE74_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE74_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE74_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE74_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE74_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE74_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE74_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 75
  output                                  oPE75_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE75_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE75_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE75_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE75_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE75_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE75_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 76
  output                                  oPE76_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE76_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE76_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE76_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE76_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE76_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE76_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 77
  output                                  oPE77_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE77_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE77_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE77_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE77_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE77_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE77_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 78
  output                                  oPE78_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE78_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE78_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE78_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE78_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE78_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE78_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 79
  output                                  oPE79_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE79_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE79_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE79_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE79_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE79_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE79_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 80
  output                                  oPE80_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE80_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE80_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE80_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE80_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE80_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE80_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 81
  output                                  oPE81_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE81_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE81_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE81_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE81_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE81_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE81_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 82
  output                                  oPE82_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE82_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE82_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE82_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE82_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE82_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE82_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 83
  output                                  oPE83_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE83_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE83_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE83_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE83_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE83_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE83_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 84
  output                                  oPE84_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE84_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE84_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE84_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE84_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE84_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE84_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 85
  output                                  oPE85_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE85_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE85_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE85_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE85_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE85_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE85_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 86
  output                                  oPE86_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE86_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE86_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE86_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE86_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE86_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE86_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 87
  output                                  oPE87_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE87_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE87_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE87_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE87_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE87_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE87_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 88
  output                                  oPE88_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE88_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE88_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE88_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE88_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE88_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE88_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 89
  output                                  oPE89_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE89_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE89_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE89_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE89_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE89_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE89_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 90
  output                                  oPE90_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE90_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE90_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE90_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE90_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE90_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE90_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 91
  output                                  oPE91_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE91_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE91_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE91_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE91_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE91_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE91_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 92
  output                                  oPE92_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE92_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE92_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE92_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE92_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE92_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE92_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 93
  output                                  oPE93_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE93_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE93_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE93_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE93_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE93_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE93_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 94
  output                                  oPE94_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE94_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE94_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE94_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE94_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE94_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE94_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 95
  output                                  oPE95_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE95_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE95_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE95_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE95_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE95_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE95_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 96
  output                                  oPE96_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE96_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE96_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE96_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE96_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE96_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE96_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 97
  output                                  oPE97_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE97_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE97_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE97_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE97_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE97_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE97_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 98
  output                                  oPE98_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE98_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE98_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE98_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE98_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE98_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE98_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 99
  output                                  oPE99_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE99_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE99_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE99_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE99_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE99_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE99_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 100
  output                                  oPE100_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE100_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE100_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE100_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE100_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE100_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE100_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 101
  output                                  oPE101_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE101_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE101_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE101_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE101_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE101_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE101_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 102
  output                                  oPE102_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE102_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE102_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE102_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE102_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE102_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE102_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 103
  output                                  oPE103_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE103_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE103_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE103_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE103_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE103_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE103_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 104
  output                                  oPE104_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE104_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE104_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE104_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE104_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE104_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE104_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 105
  output                                  oPE105_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE105_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE105_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE105_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE105_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE105_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE105_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 106
  output                                  oPE106_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE106_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE106_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE106_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE106_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE106_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE106_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 107
  output                                  oPE107_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE107_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE107_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE107_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE107_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE107_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE107_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 108
  output                                  oPE108_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE108_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE108_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE108_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE108_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE108_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE108_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 109
  output                                  oPE109_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE109_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE109_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE109_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE109_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE109_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE109_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 110
  output                                  oPE110_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE110_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE110_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE110_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE110_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE110_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE110_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 111
  output                                  oPE111_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE111_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE111_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE111_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE111_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE111_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE111_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 112
  output                                  oPE112_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE112_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE112_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE112_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE112_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE112_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE112_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 113
  output                                  oPE113_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE113_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE113_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE113_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE113_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE113_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE113_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 114
  output                                  oPE114_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE114_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE114_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE114_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE114_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE114_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE114_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 115
  output                                  oPE115_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE115_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE115_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE115_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE115_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE115_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE115_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 116
  output                                  oPE116_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE116_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE116_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE116_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE116_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE116_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE116_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 117
  output                                  oPE117_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE117_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE117_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE117_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE117_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE117_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE117_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 118
  output                                  oPE118_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE118_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE118_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE118_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE118_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE118_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE118_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 119
  output                                  oPE119_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE119_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE119_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE119_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE119_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE119_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE119_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 120
  output                                  oPE120_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE120_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE120_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE120_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE120_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE120_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE120_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 121
  output                                  oPE121_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE121_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE121_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE121_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE121_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE121_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE121_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 122
  output                                  oPE122_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE122_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE122_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE122_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE122_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE122_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE122_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 123
  output                                  oPE123_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE123_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE123_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE123_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE123_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE123_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE123_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 124
  output                                  oPE124_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE124_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE124_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE124_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE124_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE124_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE124_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 125
  output                                  oPE125_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE125_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE125_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE125_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE125_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE125_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE125_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 126
  output                                  oPE126_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE126_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE126_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE126_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE126_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE126_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE126_DMEM_EX_Data;               // data loaded from data memory
  
  // PE 127
  output                                  oPE127_AGU_DMEM_Write_Enable;       // LSU stage data-memory write enable
  output                                  oPE127_AGU_DMEM_Read_Enable;        // LSU stage data-memory read enable
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE127_AGU_DMEM_Address;           // Address to DMEM

  output [(`RISC24_PE_LSU_OP_WIDTH-1):0]  oPE127_AGU_DMEM_Opcode;             // LSU opcoce: word/half-word/byte
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE127_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE127_AGU_DMEM_Store_Data;         // Store data to EX stage (for store instruction only)
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE127_DMEM_EX_Data;               // data loaded from data memory
  


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
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE4_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE5_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE6_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE7_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE8_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE9_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE10_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE11_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE12_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE13_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE14_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE15_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE16_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE17_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE18_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE19_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE20_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE21_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE22_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE23_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE24_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE25_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE26_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE27_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE28_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE29_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE30_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE31_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE32_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE33_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE34_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE35_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE36_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE37_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE38_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE39_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE40_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE41_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE42_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE43_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE44_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE45_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE46_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE47_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE48_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE49_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE50_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE51_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE52_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE53_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE54_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE55_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE56_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE57_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE58_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE59_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE60_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE61_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE62_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE63_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE64_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE65_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE66_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE67_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE68_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE69_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE70_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE71_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE72_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE73_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE74_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE75_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE76_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE77_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE78_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE79_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE80_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE81_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE82_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE83_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE84_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE85_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE86_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE87_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE88_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE89_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE90_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE91_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE92_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE93_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE94_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE95_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE96_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE97_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE98_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE99_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE100_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE101_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE102_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE103_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE104_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE105_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE106_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE107_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE108_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE109_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE110_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE111_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE112_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE113_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE114_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE115_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE116_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE117_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE118_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE119_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE120_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE121_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE122_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE123_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE124_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE125_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE126_Port1_Data;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE127_Port1_Data;
  
  
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
  assign oLast_PE_Port1_Data  = wPE127_Port1_Data; // data from last  PE RF port 1
  
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
    .iLeft_PE_Port1_Minus4_Data    ( wPE124_Port1_Data  ),  // data from PE 124
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
    .iRight_PE_Port1_Data          ( wPE4_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE7_Port1_Data), // data from right+4 PE
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
  
  pe_top #(
   .Para_PE_ID ( 32'd4 )   // use pe data width parameter later
  ) inst_pe_top_4 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE3_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE0_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE5_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE8_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE4_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE4_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE4_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE4_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE4_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE4_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE4_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE4_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd5 )   // use pe data width parameter later
  ) inst_pe_top_5 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE4_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE1_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE6_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE9_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE5_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE5_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE5_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE5_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE5_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE5_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE5_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE5_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd6 )   // use pe data width parameter later
  ) inst_pe_top_6 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE5_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE2_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE7_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE10_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE6_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE6_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE6_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE6_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE6_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE6_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE6_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE6_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd7 )   // use pe data width parameter later
  ) inst_pe_top_7 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE6_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE3_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE8_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE11_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE7_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE7_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE7_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE7_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE7_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE7_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE7_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE7_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd8 )   // use pe data width parameter later
  ) inst_pe_top_8 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE7_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE4_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE9_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE12_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE8_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE8_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE8_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE8_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE8_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE8_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE8_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE8_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd9 )   // use pe data width parameter later
  ) inst_pe_top_9 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE8_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE5_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE10_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE13_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE9_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE9_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE9_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE9_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE9_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE9_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE9_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE9_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd10 )   // use pe data width parameter later
  ) inst_pe_top_10 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE9_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE6_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE11_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE14_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE10_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE10_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE10_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE10_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE10_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE10_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE10_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE10_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd11 )   // use pe data width parameter later
  ) inst_pe_top_11 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE10_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE7_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE12_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE15_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE11_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE11_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE11_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE11_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE11_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE11_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE11_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE11_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd12 )   // use pe data width parameter later
  ) inst_pe_top_12 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE11_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE8_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE13_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE16_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE12_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE12_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE12_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE12_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE12_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE12_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE12_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE12_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd13 )   // use pe data width parameter later
  ) inst_pe_top_13 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE12_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE9_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE14_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE17_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE13_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE13_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE13_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE13_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE13_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE13_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE13_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE13_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd14 )   // use pe data width parameter later
  ) inst_pe_top_14 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE13_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE10_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE15_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE18_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE14_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE14_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE14_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE14_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE14_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE14_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE14_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE14_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd15 )   // use pe data width parameter later
  ) inst_pe_top_15 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE14_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE11_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE16_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE19_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE15_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE15_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE15_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE15_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE15_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE15_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE15_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE15_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd16 )   // use pe data width parameter later
  ) inst_pe_top_16 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE15_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE12_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE17_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE20_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE16_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE16_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE16_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE16_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE16_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE16_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE16_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE16_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd17 )   // use pe data width parameter later
  ) inst_pe_top_17 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE16_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE13_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE18_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE21_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE17_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE17_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE17_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE17_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE17_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE17_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE17_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE17_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd18 )   // use pe data width parameter later
  ) inst_pe_top_18 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE17_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE14_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE19_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE22_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE18_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE18_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE18_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE18_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE18_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE18_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE18_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE18_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd19 )   // use pe data width parameter later
  ) inst_pe_top_19 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE18_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE15_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE20_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE23_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE19_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE19_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE19_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE19_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE19_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE19_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE19_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE19_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd20 )   // use pe data width parameter later
  ) inst_pe_top_20 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE19_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE16_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE21_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE24_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE20_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE20_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE20_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE20_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE20_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE20_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE20_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE20_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd21 )   // use pe data width parameter later
  ) inst_pe_top_21 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE20_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE17_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE22_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE25_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE21_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE21_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE21_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE21_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE21_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE21_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE21_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE21_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd22 )   // use pe data width parameter later
  ) inst_pe_top_22 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE21_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE18_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE23_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE26_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE22_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE22_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE22_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE22_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE22_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE22_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE22_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE22_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd23 )   // use pe data width parameter later
  ) inst_pe_top_23 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE22_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE19_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE24_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE27_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE23_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE23_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE23_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE23_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE23_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE23_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE23_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE23_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd24 )   // use pe data width parameter later
  ) inst_pe_top_24 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE23_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE20_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE25_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE28_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE24_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE24_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE24_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE24_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE24_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE24_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE24_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE24_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd25 )   // use pe data width parameter later
  ) inst_pe_top_25 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE24_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE21_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE26_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE29_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE25_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE25_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE25_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE25_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE25_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE25_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE25_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE25_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd26 )   // use pe data width parameter later
  ) inst_pe_top_26 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE25_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE22_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE27_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE30_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE26_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE26_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE26_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE26_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE26_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE26_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE26_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE26_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd27 )   // use pe data width parameter later
  ) inst_pe_top_27 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE26_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE23_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE28_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE31_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE27_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE27_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE27_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE27_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE27_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE27_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE27_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE27_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd28 )   // use pe data width parameter later
  ) inst_pe_top_28 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE27_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE24_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE29_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE32_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE28_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE28_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE28_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE28_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE28_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE28_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE28_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE28_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd29 )   // use pe data width parameter later
  ) inst_pe_top_29 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE28_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE25_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE30_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE33_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE29_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE29_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE29_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE29_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE29_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE29_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE29_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE29_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd30 )   // use pe data width parameter later
  ) inst_pe_top_30 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE29_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE26_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE31_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE34_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE30_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE30_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE30_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE30_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE30_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE30_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE30_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE30_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd31 )   // use pe data width parameter later
  ) inst_pe_top_31 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE30_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE27_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE32_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE35_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE31_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE31_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE31_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE31_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE31_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE31_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE31_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE31_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd32 )   // use pe data width parameter later
  ) inst_pe_top_32 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE31_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE28_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE33_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE36_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE32_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE32_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE32_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE32_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE32_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE32_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE32_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE32_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd33 )   // use pe data width parameter later
  ) inst_pe_top_33 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE32_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE29_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE34_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE37_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE33_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE33_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE33_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE33_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE33_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE33_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE33_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE33_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd34 )   // use pe data width parameter later
  ) inst_pe_top_34 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE33_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE30_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE35_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE38_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE34_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE34_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE34_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE34_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE34_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE34_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE34_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE34_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd35 )   // use pe data width parameter later
  ) inst_pe_top_35 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE34_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE31_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE36_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE39_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE35_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE35_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE35_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE35_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE35_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE35_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE35_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE35_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd36 )   // use pe data width parameter later
  ) inst_pe_top_36 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE35_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE32_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE37_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE40_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE36_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE36_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE36_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE36_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE36_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE36_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE36_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE36_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd37 )   // use pe data width parameter later
  ) inst_pe_top_37 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE36_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE33_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE38_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE41_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE37_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE37_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE37_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE37_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE37_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE37_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE37_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE37_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd38 )   // use pe data width parameter later
  ) inst_pe_top_38 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE37_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE34_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE39_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE42_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE38_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE38_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE38_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE38_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE38_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE38_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE38_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE38_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd39 )   // use pe data width parameter later
  ) inst_pe_top_39 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE38_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE35_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE40_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE43_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE39_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE39_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE39_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE39_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE39_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE39_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE39_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE39_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd40 )   // use pe data width parameter later
  ) inst_pe_top_40 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE39_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE36_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE41_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE44_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE40_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE40_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE40_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE40_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE40_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE40_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE40_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE40_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd41 )   // use pe data width parameter later
  ) inst_pe_top_41 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE40_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE37_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE42_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE45_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE41_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE41_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE41_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE41_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE41_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE41_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE41_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE41_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd42 )   // use pe data width parameter later
  ) inst_pe_top_42 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE41_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE38_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE43_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE46_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE42_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE42_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE42_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE42_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE42_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE42_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE42_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE42_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd43 )   // use pe data width parameter later
  ) inst_pe_top_43 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE42_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE39_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE44_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE47_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE43_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE43_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE43_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE43_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE43_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE43_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE43_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE43_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd44 )   // use pe data width parameter later
  ) inst_pe_top_44 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE43_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE40_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE45_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE48_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE44_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE44_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE44_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE44_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE44_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE44_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE44_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE44_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd45 )   // use pe data width parameter later
  ) inst_pe_top_45 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE44_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE41_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE46_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE49_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE45_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE45_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE45_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE45_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE45_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE45_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE45_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE45_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd46 )   // use pe data width parameter later
  ) inst_pe_top_46 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE45_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE42_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE47_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE50_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE46_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE46_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE46_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE46_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE46_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE46_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE46_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE46_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd47 )   // use pe data width parameter later
  ) inst_pe_top_47 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE46_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE43_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE48_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE51_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE47_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE47_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE47_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE47_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE47_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE47_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE47_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE47_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd48 )   // use pe data width parameter later
  ) inst_pe_top_48 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE47_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE44_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE49_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE52_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE48_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE48_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE48_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE48_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE48_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE48_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE48_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE48_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd49 )   // use pe data width parameter later
  ) inst_pe_top_49 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE48_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE45_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE50_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE53_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE49_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE49_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE49_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE49_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE49_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE49_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE49_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE49_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd50 )   // use pe data width parameter later
  ) inst_pe_top_50 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE49_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE46_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE51_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE54_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE50_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE50_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE50_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE50_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE50_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE50_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE50_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE50_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd51 )   // use pe data width parameter later
  ) inst_pe_top_51 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE50_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE47_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE52_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE55_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE51_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE51_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE51_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE51_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE51_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE51_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE51_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE51_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd52 )   // use pe data width parameter later
  ) inst_pe_top_52 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE51_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE48_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE53_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE56_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE52_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE52_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE52_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE52_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE52_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE52_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE52_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE52_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd53 )   // use pe data width parameter later
  ) inst_pe_top_53 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE52_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE49_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE54_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE57_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE53_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE53_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE53_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE53_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE53_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE53_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE53_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE53_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd54 )   // use pe data width parameter later
  ) inst_pe_top_54 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE53_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE50_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE55_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE58_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE54_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE54_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE54_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE54_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE54_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE54_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE54_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE54_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd55 )   // use pe data width parameter later
  ) inst_pe_top_55 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE54_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE51_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE56_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE59_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE55_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE55_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE55_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE55_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE55_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE55_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE55_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE55_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd56 )   // use pe data width parameter later
  ) inst_pe_top_56 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE55_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE52_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE57_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE60_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE56_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE56_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE56_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE56_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE56_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE56_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE56_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE56_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd57 )   // use pe data width parameter later
  ) inst_pe_top_57 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE56_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE53_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE58_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE61_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE57_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE57_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE57_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE57_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE57_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE57_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE57_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE57_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd58 )   // use pe data width parameter later
  ) inst_pe_top_58 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE57_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE54_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE59_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE62_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE58_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE58_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE58_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE58_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE58_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE58_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE58_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE58_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd59 )   // use pe data width parameter later
  ) inst_pe_top_59 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE58_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE55_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE60_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE63_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE59_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE59_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE59_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE59_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE59_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE59_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE59_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE59_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd60 )   // use pe data width parameter later
  ) inst_pe_top_60 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE59_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE56_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE61_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE64_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE60_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE60_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE60_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE60_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE60_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE60_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE60_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE60_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd61 )   // use pe data width parameter later
  ) inst_pe_top_61 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE60_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE57_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE62_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE65_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE61_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE61_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE61_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE61_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE61_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE61_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE61_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE61_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd62 )   // use pe data width parameter later
  ) inst_pe_top_62 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE61_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE58_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE63_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE66_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE62_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE62_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE62_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE62_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE62_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE62_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE62_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE62_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd63 )   // use pe data width parameter later
  ) inst_pe_top_63 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE62_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE59_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE64_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE67_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE63_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE63_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE63_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE63_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE63_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE63_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE63_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE63_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd64 )   // use pe data width parameter later
  ) inst_pe_top_64 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE63_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE60_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE65_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE68_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE64_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE64_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE64_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE64_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE64_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE64_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE64_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE64_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd65 )   // use pe data width parameter later
  ) inst_pe_top_65 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE64_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE61_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE66_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE69_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE65_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE65_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE65_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE65_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE65_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE65_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE65_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE65_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd66 )   // use pe data width parameter later
  ) inst_pe_top_66 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE65_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE62_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE67_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE70_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE66_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE66_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE66_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE66_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE66_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE66_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE66_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE66_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd67 )   // use pe data width parameter later
  ) inst_pe_top_67 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE66_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE63_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE68_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE71_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE67_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE67_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE67_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE67_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE67_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE67_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE67_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE67_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd68 )   // use pe data width parameter later
  ) inst_pe_top_68 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE67_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE64_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE69_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE72_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE68_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE68_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE68_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE68_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE68_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE68_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE68_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE68_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd69 )   // use pe data width parameter later
  ) inst_pe_top_69 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE68_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE65_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE70_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE73_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE69_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE69_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE69_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE69_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE69_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE69_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE69_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE69_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd70 )   // use pe data width parameter later
  ) inst_pe_top_70 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE69_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE66_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE71_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE74_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE70_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE70_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE70_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE70_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE70_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE70_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE70_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE70_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd71 )   // use pe data width parameter later
  ) inst_pe_top_71 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE70_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE67_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE72_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE75_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE71_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE71_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE71_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE71_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE71_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE71_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE71_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE71_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd72 )   // use pe data width parameter later
  ) inst_pe_top_72 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE71_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE68_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE73_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE76_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE72_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE72_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE72_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE72_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE72_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE72_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE72_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE72_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd73 )   // use pe data width parameter later
  ) inst_pe_top_73 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE72_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE69_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE74_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE77_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE73_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE73_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE73_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE73_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE73_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE73_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE73_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE73_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd74 )   // use pe data width parameter later
  ) inst_pe_top_74 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE73_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE70_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE75_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE78_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE74_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE74_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE74_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE74_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE74_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE74_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE74_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE74_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd75 )   // use pe data width parameter later
  ) inst_pe_top_75 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE74_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE71_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE76_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE79_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE75_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE75_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE75_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE75_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE75_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE75_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE75_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE75_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd76 )   // use pe data width parameter later
  ) inst_pe_top_76 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE75_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE72_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE77_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE80_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE76_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE76_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE76_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE76_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE76_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE76_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE76_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE76_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd77 )   // use pe data width parameter later
  ) inst_pe_top_77 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE76_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE73_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE78_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE81_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE77_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE77_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE77_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE77_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE77_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE77_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE77_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE77_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd78 )   // use pe data width parameter later
  ) inst_pe_top_78 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE77_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE74_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE79_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE82_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE78_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE78_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE78_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE78_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE78_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE78_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE78_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE78_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd79 )   // use pe data width parameter later
  ) inst_pe_top_79 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE78_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE75_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE80_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE83_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE79_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE79_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE79_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE79_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE79_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE79_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE79_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE79_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd80 )   // use pe data width parameter later
  ) inst_pe_top_80 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE79_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE76_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE81_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE84_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE80_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE80_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE80_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE80_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE80_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE80_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE80_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE80_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd81 )   // use pe data width parameter later
  ) inst_pe_top_81 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE80_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE77_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE82_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE85_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE81_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE81_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE81_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE81_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE81_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE81_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE81_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE81_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd82 )   // use pe data width parameter later
  ) inst_pe_top_82 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE81_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE78_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE83_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE86_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE82_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE82_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE82_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE82_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE82_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE82_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE82_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE82_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd83 )   // use pe data width parameter later
  ) inst_pe_top_83 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE82_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE79_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE84_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE87_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE83_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE83_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE83_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE83_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE83_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE83_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE83_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE83_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd84 )   // use pe data width parameter later
  ) inst_pe_top_84 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE83_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE80_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE85_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE88_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE84_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE84_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE84_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE84_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE84_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE84_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE84_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE84_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd85 )   // use pe data width parameter later
  ) inst_pe_top_85 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE84_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE81_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE86_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE89_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE85_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE85_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE85_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE85_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE85_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE85_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE85_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE85_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd86 )   // use pe data width parameter later
  ) inst_pe_top_86 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE85_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE82_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE87_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE90_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE86_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE86_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE86_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE86_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE86_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE86_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE86_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE86_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd87 )   // use pe data width parameter later
  ) inst_pe_top_87 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE86_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE83_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE88_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE91_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE87_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE87_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE87_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE87_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE87_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE87_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE87_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE87_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd88 )   // use pe data width parameter later
  ) inst_pe_top_88 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE87_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE84_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE89_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE92_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE88_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE88_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE88_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE88_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE88_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE88_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE88_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE88_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd89 )   // use pe data width parameter later
  ) inst_pe_top_89 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE88_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE85_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE90_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE93_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE89_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE89_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE89_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE89_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE89_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE89_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE89_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE89_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd90 )   // use pe data width parameter later
  ) inst_pe_top_90 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE89_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE86_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE91_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE94_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE90_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE90_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE90_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE90_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE90_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE90_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE90_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE90_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd91 )   // use pe data width parameter later
  ) inst_pe_top_91 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE90_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE87_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE92_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE95_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE91_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE91_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE91_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE91_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE91_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE91_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE91_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE91_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd92 )   // use pe data width parameter later
  ) inst_pe_top_92 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE91_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE88_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE93_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE96_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE92_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE92_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE92_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE92_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE92_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE92_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE92_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE92_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd93 )   // use pe data width parameter later
  ) inst_pe_top_93 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE92_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE89_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE94_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE97_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE93_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE93_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE93_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE93_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE93_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE93_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE93_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE93_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd94 )   // use pe data width parameter later
  ) inst_pe_top_94 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE93_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE90_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE95_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE98_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE94_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE94_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE94_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE94_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE94_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE94_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE94_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE94_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd95 )   // use pe data width parameter later
  ) inst_pe_top_95 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE94_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE91_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE96_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE99_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE95_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE95_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE95_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE95_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE95_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE95_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE95_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE95_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd96 )   // use pe data width parameter later
  ) inst_pe_top_96 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE95_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE92_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE97_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE100_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE96_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE96_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE96_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE96_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE96_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE96_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE96_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE96_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd97 )   // use pe data width parameter later
  ) inst_pe_top_97 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE96_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE93_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE98_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE101_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE97_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE97_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE97_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE97_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE97_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE97_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE97_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE97_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd98 )   // use pe data width parameter later
  ) inst_pe_top_98 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE97_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE94_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE99_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE102_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE98_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE98_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE98_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE98_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE98_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE98_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE98_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE98_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd99 )   // use pe data width parameter later
  ) inst_pe_top_99 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE98_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE95_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE100_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE103_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE99_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE99_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE99_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE99_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE99_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE99_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE99_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE99_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd100 )   // use pe data width parameter later
  ) inst_pe_top_100 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE99_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE96_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE101_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE104_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE100_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE100_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE100_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE100_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE100_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE100_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE100_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE100_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd101 )   // use pe data width parameter later
  ) inst_pe_top_101 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE100_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE97_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE102_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE105_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE101_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE101_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE101_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE101_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE101_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE101_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE101_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE101_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd102 )   // use pe data width parameter later
  ) inst_pe_top_102 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE101_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE98_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE103_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE106_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE102_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE102_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE102_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE102_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE102_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE102_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE102_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE102_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd103 )   // use pe data width parameter later
  ) inst_pe_top_103 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE102_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE99_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE104_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE107_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE103_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE103_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE103_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE103_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE103_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE103_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE103_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE103_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd104 )   // use pe data width parameter later
  ) inst_pe_top_104 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE103_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE100_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE105_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE108_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE104_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE104_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE104_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE104_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE104_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE104_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE104_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE104_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd105 )   // use pe data width parameter later
  ) inst_pe_top_105 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE104_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE101_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE106_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE109_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE105_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE105_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE105_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE105_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE105_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE105_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE105_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE105_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd106 )   // use pe data width parameter later
  ) inst_pe_top_106 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE105_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE102_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE107_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE110_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE106_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE106_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE106_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE106_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE106_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE106_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE106_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE106_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd107 )   // use pe data width parameter later
  ) inst_pe_top_107 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE106_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE103_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE108_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE111_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE107_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE107_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE107_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE107_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE107_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE107_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE107_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE107_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd108 )   // use pe data width parameter later
  ) inst_pe_top_108 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE107_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE104_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE109_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE112_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE108_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE108_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE108_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE108_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE108_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE108_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE108_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE108_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd109 )   // use pe data width parameter later
  ) inst_pe_top_109 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE108_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE105_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE110_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE113_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE109_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE109_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE109_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE109_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE109_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE109_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE109_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE109_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd110 )   // use pe data width parameter later
  ) inst_pe_top_110 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE109_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE106_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE111_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE114_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE110_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE110_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE110_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE110_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE110_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE110_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE110_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE110_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd111 )   // use pe data width parameter later
  ) inst_pe_top_111 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE110_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE107_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE112_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE115_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE111_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE111_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE111_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE111_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE111_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE111_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE111_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE111_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd112 )   // use pe data width parameter later
  ) inst_pe_top_112 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE111_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE108_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE113_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE116_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE112_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE112_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE112_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE112_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE112_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE112_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE112_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE112_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd113 )   // use pe data width parameter later
  ) inst_pe_top_113 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE112_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE109_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE114_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE117_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE113_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE113_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE113_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE113_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE113_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE113_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE113_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE113_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd114 )   // use pe data width parameter later
  ) inst_pe_top_114 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE113_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE110_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE115_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE118_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE114_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE114_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE114_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE114_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE114_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE114_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE114_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE114_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd115 )   // use pe data width parameter later
  ) inst_pe_top_115 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE114_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE111_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE116_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE119_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE115_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE115_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE115_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE115_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE115_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE115_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE115_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE115_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd116 )   // use pe data width parameter later
  ) inst_pe_top_116 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE115_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE112_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE117_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE120_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE116_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE116_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE116_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE116_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE116_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE116_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE116_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE116_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd117 )   // use pe data width parameter later
  ) inst_pe_top_117 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE116_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE113_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE118_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE121_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE117_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE117_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE117_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE117_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE117_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE117_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE117_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE117_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd118 )   // use pe data width parameter later
  ) inst_pe_top_118 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE117_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE114_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE119_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE122_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE118_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE118_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE118_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE118_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE118_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE118_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE118_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE118_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd119 )   // use pe data width parameter later
  ) inst_pe_top_119 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE118_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE115_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE120_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE123_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE119_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE119_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE119_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE119_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE119_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE119_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE119_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE119_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd120 )   // use pe data width parameter later
  ) inst_pe_top_120 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE119_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE116_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE121_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE124_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE120_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE120_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE120_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE120_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE120_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE120_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE120_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE120_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd121 )   // use pe data width parameter later
  ) inst_pe_top_121 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE120_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE117_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE122_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE125_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE121_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE121_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE121_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE121_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE121_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE121_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE121_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE121_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd122 )   // use pe data width parameter later
  ) inst_pe_top_122 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE121_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE118_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE123_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE126_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE122_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE122_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE122_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE122_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE122_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE122_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE122_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE122_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd123 )   // use pe data width parameter later
  ) inst_pe_top_123 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE122_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE119_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE124_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE127_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE123_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE123_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE123_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE123_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE123_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE123_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE123_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE123_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd124 )   // use pe data width parameter later
  ) inst_pe_top_124 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE123_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE120_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE125_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE0_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE124_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE124_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE124_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE124_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE124_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE124_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE124_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE124_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd125 )   // use pe data width parameter later
  ) inst_pe_top_125 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE124_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE121_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE126_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE1_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE125_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE125_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE125_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE125_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE125_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE125_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE125_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE125_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd126 )   // use pe data width parameter later
  ) inst_pe_top_126 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE125_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE122_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wPE127_Port1_Data),  // data from right PE
    .iRight_PE_Port1_Plus4_Data    ( wPE2_Port1_Data), // data from right+4 PE
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE126_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE126_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE126_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE126_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE126_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE126_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE126_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE126_DMEM_EX_Data         )   // data loaded from data memory
  );
  
  pe_top #(
   .Para_PE_ID ( 32'd127 )   // use pe data width parameter later
  ) inst_pe_top_127 (
    .iClk                          ( iClk  ),  // system clock, positive-edge trigger
    .iReset                        ( iReset),  // global synchronous reset signal, Active high

    .iUpdate_Flag                  ( wUpdate_Flag),  // selection bits for updating flag/P0/P1

    // neighbourhood communication
    .iData_Selection               ( wIF_BP_Data_Selection),  // data selection  bits
    // predication
    .iIF_ID_Predication            ( wIF_ID_Predication   ),  // IF-ID predication bits
    .iLeft_PE_Port1_Data           ( wPE126_Port1_Data),  // data from left PE
    .iLeft_PE_Port1_Minus4_Data    ( wPE123_Port1_Data), // data from left-4 PE
    .iRight_PE_Port1_Data          ( wLast_PE_Input_Data  ),  // NOTE: for boundary PEs, we will support wrap-up/self/'0' later!
    .iRight_PE_Port1_Plus4_Data    ( wPE3_Port1_Data    ),  // data from PE 3 
    .iCP_Data                      ( iCP_Data           ),  // data from cp
    .oPE_Port1_Data                ( wPE127_Port1_Data),  // data to left/right PE

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
    .oAGU_DMEM_Write_Enable        ( oPE127_AGU_DMEM_Write_Enable),  // LSU stage data-memory write enable
    .oAGU_DMEM_Read_Enable         ( oPE127_AGU_DMEM_Read_Enable ),  // LSU stage data-memory read enable
    .oAGU_DMEM_Address             ( oPE127_AGU_DMEM_Address     ),  // Address to DMEM
    .oAGU_DMEM_Byte_Select         ( oPE127_AGU_DMEM_Byte_Select ),  // 
    .oAGU_DMEM_Opcode              ( oPE127_AGU_DMEM_Opcode      ),  // LSU opcoce: word/half-word/byte
    .oAGU_DMEM_Store_Data          ( oPE127_AGU_DMEM_Store_Data  ),  // Store data to EX stage (for store instruction only)
    .iDMEM_EX_Data                 ( iPE127_DMEM_EX_Data         )   // data loaded from data memory
  );
  
//*********************
//  Output Assignment
//*********************
endmodule