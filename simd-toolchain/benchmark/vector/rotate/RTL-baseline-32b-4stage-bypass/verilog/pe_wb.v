////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//    Module Name :  pe_wb                                                    //
//    Description :  This is the memory-access (MEM) stage together with the  //
//                   write-back stage of the RISC processor.                  //
//                                                                            //
//    Author(s)   :  Yifan He                                                 //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

`include "def-pe.v"

// synopsys translate_off
`timescale 1ns / 1ps
// synopsys translate_on


module pe_wb (                                                        
  iClk,                              // system clock, positive-edge trigger
  iReset,                            // global synchronous reset signal, Active high
  
  // from EX stage
  iEX_WB_Write_RF_Data,              // EX stage to WB stage data
  iEX_WB_Write_RF_Address,           // EX stage to WB stage RF index
  iEX_WB_Write_RF_Enable,            // EX stage to WB stage RF write enable
  
  // to RF
  oWB_RF_Writeback_Enable,           // WB-stage RF write back enable
  oWB_RF_Write_Addr,                 // WB-stage RF write address
  oWB_RF_Write_Data                  // WB-stage RF write data
);

//******************************
//  Local Parameter Definition
//******************************



//****************************
//  Input/Output Declaration
//****************************

  input                              iClk;                        // system clock, positive-edge trigger
  input                              iReset;                      // global synchronous reset signal, Active high

  // from EX stage
  input  [(`DEF_PE_DATA_WIDTH-1):0]     iEX_WB_Write_RF_Data;        // EX stage to WB stage data
  input  [(`DEF_RF_INDEX_WIDTH-1):0] iEX_WB_Write_RF_Address;     // EX stage to WB stage RF index
  input                              iEX_WB_Write_RF_Enable;      // EX stage to WB stage RF write enable

  // RF
  output                             oWB_RF_Writeback_Enable;     // WB-stage RF write back enable
  output [(`DEF_RF_INDEX_WIDTH-1):0] oWB_RF_Write_Addr;           // WB-stage RF write address
  output [(`DEF_PE_DATA_WIDTH-1):0]     oWB_RF_Write_Data;           // WB-stage RF write data



//******************************
//  Local Wire/Reg Declaration
//******************************
  
  reg                                rPR_WB_RF_Writeback_Enable;  // WB-stage pipeline register: RF write enable
  reg  [(`DEF_RF_INDEX_WIDTH-1):0]   rPR_WB_RF_Write_Addr;        // WB-stage pipeline register: RF write address
  reg  [(`DEF_PE_DATA_WIDTH-1):0]       rPR_WB_RF_Write_Data;        // WB-stage pipeline register: RF write data

  
//******************************
//  Behavioral Description
//******************************

  // =================================
  //  Pipeline Registers to WB stage
  // =================================
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        rPR_WB_RF_Writeback_Enable <= 'b0;   
      end
    else
      begin
        rPR_WB_RF_Writeback_Enable <= iEX_WB_Write_RF_Enable;
      end
  // end of always


  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        rPR_WB_RF_Write_Addr <= 'b0;
        rPR_WB_RF_Write_Data <= 'b0;
      end
    else if ( iEX_WB_Write_RF_Enable )
      begin
        rPR_WB_RF_Write_Addr <= iEX_WB_Write_RF_Address;
        rPR_WB_RF_Write_Data <= iEX_WB_Write_RF_Data;
      end
  // end of always


//*********************
//  Output Assignment
//*********************
                                
  // to RF
  assign oWB_RF_Writeback_Enable  = rPR_WB_RF_Writeback_Enable; 
  assign oWB_RF_Write_Addr        = rPR_WB_RF_Write_Addr;       
  assign oWB_RF_Write_Data        = rPR_WB_RF_Write_Data;       


endmodule