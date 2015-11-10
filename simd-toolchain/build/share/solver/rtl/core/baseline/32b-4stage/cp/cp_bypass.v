////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//    File Name   :  cp_bypass.v                                              //
//    Module Name :  cp_bypass                                                //
//    Author(s)   :  Yifan He                                                 //
//                                                                            //
//    Description :  This is the bypass network for the RF write-back data.   //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

`include "def-cp.v"

// synopsys translate_off
`timescale 1ns / 1ps
// synopsys translate_on


module cp_bypass (
  // from WB stage
  iWB_RF_Write_Addr,                 // WB-stage RF write address
  iWB_RF_Write_Data,                 // WB-stage RF write data
  iWB_RF_Write_Enable,               // WB-stage RF write enable

  // from EX stage
  iEX_RF_Write_Addr,                 // EX-stage RF write address
  iEX_RF_Write_Data,                 // EX-stage RF write data
  iEX_RF_Write_Enable,               // EX-stage RF write enable
  
  // from IF stage
  iIF_RF_Read_Addr_A,                // RF read port A address
  iIF_RF_Read_Addr_B,                // RF read port B address
  iIF_BP_Select_Imm,                 // indicate that the second operand is from immediate value

  // from/to ID stage
  iID_BP_Immediate,                  // sign-extended (to 32bit) immediate
  iID_BP_Is_Long_Immediate,          // Flag: indicate the previous ins. is a long-imm ins.
  iID_BP_Long_Immediate,             // long immdediate register
  iID_BP_Is_SUB,                     // current ins. is SUB
  oBP_ID_Operand_A,                  // operand A
  oBP_ID_Operand_B,                  // operand B
  oBP_ID_LSU_Store_Data,             // store data (for store instruction only)

  // from Regiser File
  iRF_BP_Read_Data_A,                // RF read data from port A
  iRF_BP_Read_Data_B,                // RF read data from port B

  // from first/last PE
  iFirst_PE_Port1_Data,              // data from first PE RF port 1
  iSelect_First_PE,                  // flag: select the data from first PE
  iLast_PE_Port1_Data,               // data from last PE RF port 1
  iSelect_Last_PE,                   // flag: select the data from last PE

  // to PEs
  oCP_Port1_Data                     // cp port 1 data to pe
);

//******************************
//  Local Parameter Definition
//******************************



//****************************
//  Input/Output Declaration
//****************************
  // from WB stage
  input  [(`DEF_CP_RF_INDEX_WIDTH-1):0] iWB_RF_Write_Addr;
  input  [(`DEF_CP_DATA_WIDTH-1):0]     iWB_RF_Write_Data;
  input                                 iWB_RF_Write_Enable;

  // from EX stage
  input  [(`DEF_CP_RF_INDEX_WIDTH-1):0] iEX_RF_Write_Addr;
  input  [(`DEF_CP_DATA_WIDTH-1):0]     iEX_RF_Write_Data;
  input                                 iEX_RF_Write_Enable;

  // from IF stage
  input  [(`DEF_CP_RF_INDEX_WIDTH-1):0] iIF_RF_Read_Addr_A;
  input  [(`DEF_CP_RF_INDEX_WIDTH-1):0] iIF_RF_Read_Addr_B;
  input                                 iIF_BP_Select_Imm;

  // from/to ID stage
  input  [(`DEF_CP_DATA_WIDTH-1):0]     iID_BP_Immediate;
  input                                 iID_BP_Is_Long_Immediate;
  input  [(`DEF_CP_DATA_WIDTH-`DEF_CP_INS_IMM_WIDTH-1):0] iID_BP_Long_Immediate;
  input                                 iID_BP_Is_SUB;
  output [(`DEF_CP_DATA_WIDTH-1):0]     oBP_ID_Operand_A;
  output [(`DEF_CP_DATA_WIDTH-1):0]     oBP_ID_Operand_B;
  output [(`DEF_CP_DATA_WIDTH-1):0]     oBP_ID_LSU_Store_Data;


  // from Regiser File
  input  [(`DEF_CP_DATA_WIDTH-1):0]     iRF_BP_Read_Data_A;
  input  [(`DEF_CP_DATA_WIDTH-1):0]     iRF_BP_Read_Data_B;

  // CP - PE communication
  input  [(`DEF_CP_DATA_WIDTH-1):0]     iFirst_PE_Port1_Data;
  input                                 iSelect_First_PE;
  input  [(`DEF_CP_DATA_WIDTH-1):0]     iLast_PE_Port1_Data;
  input                                 iSelect_Last_PE;

  output [(`DEF_CP_DATA_WIDTH-1):0]     oCP_Port1_Data;
  

//******************************
//  Local Wire/Reg Declaration
//******************************

  reg   [(`DEF_CP_DATA_WIDTH-1):0]      rOperand_A;             // operand A
  reg   [(`DEF_CP_DATA_WIDTH-1):0]      rOperand_A_cp_pe;       // operand A after mux the PE/CP data
  reg   [(`DEF_CP_DATA_WIDTH-1):0]      rOperand_A_switched;    // switch Operand A & B for RSUBI inst
  reg   [(`DEF_CP_DATA_WIDTH-1):0]      rOperand_B_switched;    // switch Operand A & B for RSUBI inst

  reg   [(`DEF_CP_DATA_WIDTH-1):0]      rOperand_B;             // operand B, after considering the immediate value
  reg   [(`DEF_CP_DATA_WIDTH-1):0]      rOperand_B_Bypass;      // operand B, only consider the bypass network


//******************************
//  Behavioral Description
//******************************

  // ========================================
  //  bypass network for the write-back data
  // ========================================
  // RF read data A (bypass network for RF A)
  always @ ( iIF_RF_Read_Addr_A or iRF_BP_Read_Data_A or
             iWB_RF_Write_Addr  or iWB_RF_Write_Data  or iWB_RF_Write_Enable or
             iEX_RF_Write_Addr  or iEX_RF_Write_Data  or iEX_RF_Write_Enable  )
    if ((iIF_RF_Read_Addr_A == iEX_RF_Write_Addr) && (iIF_RF_Read_Addr_A > 5'b0) && iEX_RF_Write_Enable)
      rOperand_A = iEX_RF_Write_Data;
    else if ((iIF_RF_Read_Addr_A == iWB_RF_Write_Addr) && (iIF_RF_Read_Addr_A > 5'b0) && iWB_RF_Write_Enable)
      rOperand_A = iWB_RF_Write_Data;
    else
      rOperand_A = iRF_BP_Read_Data_A;
  // end of always


  // RF read data B (bypass network for RF B)
  always @ ( iIF_RF_Read_Addr_B or iRF_BP_Read_Data_B or
             iWB_RF_Write_Addr  or iWB_RF_Write_Data  or iWB_RF_Write_Enable or
             iEX_RF_Write_Addr  or iEX_RF_Write_Data  or iEX_RF_Write_Enable  )
    if ((iIF_RF_Read_Addr_B == iEX_RF_Write_Addr) && (iIF_RF_Read_Addr_B > 5'b0) && iEX_RF_Write_Enable)
      rOperand_B_Bypass = iEX_RF_Write_Data;
    else if ((iIF_RF_Read_Addr_B == iWB_RF_Write_Addr) && (iIF_RF_Read_Addr_B > 5'b0) && iWB_RF_Write_Enable)
      rOperand_B_Bypass = iWB_RF_Write_Data;
    else
      rOperand_B_Bypass = iRF_BP_Read_Data_B;
  // end of always


  // Operand B: select between immediate value and the RF value
  always @ ( rOperand_B_Bypass or iIF_BP_Select_Imm or iID_BP_Immediate or iID_BP_Is_Long_Immediate or iID_BP_Long_Immediate )
    if ( iIF_BP_Select_Imm )      // data from immediate value
      rOperand_B = (iID_BP_Is_Long_Immediate) ? {iID_BP_Long_Immediate, iID_BP_Immediate[`DEF_CP_INS_IMM_END_BIT:`DEF_CP_INS_IMM_START_BIT]} : iID_BP_Immediate;
    else
      rOperand_B = rOperand_B_Bypass;
  // end of always


  // CP-PE communication
  always @ ( iFirst_PE_Port1_Data or iSelect_First_PE or iLast_PE_Port1_Data or iSelect_Last_PE or rOperand_A )
    casez ( {iSelect_First_PE, iSelect_Last_PE} )
      2'b1?:   rOperand_A_cp_pe = iFirst_PE_Port1_Data;
      2'b01:   rOperand_A_cp_pe = iLast_PE_Port1_Data;
      default: rOperand_A_cp_pe = rOperand_A;
    endcase
  // end of always


  // for RSUBI, switch operand A & B
  always @ ( rOperand_A_cp_pe or rOperand_B or iID_BP_Is_SUB or iIF_BP_Select_Imm )
    if ( iID_BP_Is_SUB && iIF_BP_Select_Imm ) // is RSUBI
      begin
        rOperand_A_switched = rOperand_B;
        rOperand_B_switched = rOperand_A_cp_pe;
      end
    else
      begin
        rOperand_A_switched = rOperand_A_cp_pe;
        rOperand_B_switched = rOperand_B;
      end
  // end of always


//*********************
//  Output Assignment
//*********************

  // to ID stage
  assign oBP_ID_Operand_A  = rOperand_A_switched;
  assign oBP_ID_Operand_B  = rOperand_B_switched;
  assign oBP_ID_LSU_Store_Data = rOperand_B_Bypass;

  // to PEs: broadcasting
  assign oCP_Port1_Data = rOperand_A;

endmodule
