////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//    Module Name :  cp_rf                                                    //
//    Description :  This is the register file for CP. Depending on the       //
//                   target, it use either flip-flops (generic) or look-up    //
//                   table (FPGA).                                            //
//                                                                            //
//    Author(s)   :  Yifan He                                                 //
//                   Dongrui She                                              //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

`include "def-cp.v"

// synopsys translate_off
`timescale 1ns / 1ps
// synopsys translate_on

module cp_rf (
  iClk,               // system clock, positive-edge trigger
  // from IF stage
  iIF_RF_Read_Addr_A, // RF read port A address
  iIF_RF_Read_Addr_B, // RF read port B address
  // to bypass
  oRF_BP_Read_Data_A, // RF read data from port A
  oRF_BP_Read_Data_B, // RF read data from port B
  // from WB stage
  iWB_RF_Write_Addr,  // RF write address
  iWB_RF_Write_Data,  // RF write data
  iWB_RF_Write_Enable // RF write enable signal
);

//****************************
//  Input/Output Declaration
//****************************
   input iClk;                        // system clock, positive-edge trigger
   // from IF stage
   input [`DEF_CP_RF_INDEX_WIDTH-1:0] iIF_RF_Read_Addr_A;  // Read address A
   input [`DEF_CP_RF_INDEX_WIDTH-1:0] iIF_RF_Read_Addr_B;  // Read address B
   output [`DEF_CP_DATA_WIDTH-1:0]    oRF_BP_Read_Data_A;  // Read data A
   output [`DEF_CP_DATA_WIDTH-1:0]    oRF_BP_Read_Data_B;  // Read data B
   // from WB stage
   input [`DEF_CP_RF_INDEX_WIDTH-1:0] iWB_RF_Write_Addr;   // Write address
   input [`DEF_CP_DATA_WIDTH-1:0]     iWB_RF_Write_Data;   // Write data
   input                              iWB_RF_Write_Enable; // Write enable
//******************************
//  Local Wire/Reg Declaration
//******************************


   reg [`DEF_CP_RF_DEPTH*`DEF_CP_DATA_WIDTH-1:0] rRegister_File_Memory;
   reg [`DEF_CP_DATA_WIDTH-1:0]                  rID_RF_Read_Data_A;
   reg [`DEF_CP_DATA_WIDTH-1:0]                  rID_RF_Read_Data_B;
//******************************
//  Behavioral Description
//******************************
  // ===========
  // Write port
  // ===========
  always @ ( posedge iClk )
    if ( iWB_RF_Write_Enable )
      case ( iWB_RF_Write_Addr )
        5'd1: rRegister_File_Memory[32*2-1:32*1] <= iWB_RF_Write_Data;
        5'd2: rRegister_File_Memory[32*3-1:32*2] <= iWB_RF_Write_Data;
        5'd3: rRegister_File_Memory[32*4-1:32*3] <= iWB_RF_Write_Data;
        5'd4: rRegister_File_Memory[32*5-1:32*4] <= iWB_RF_Write_Data;
        5'd5: rRegister_File_Memory[32*6-1:32*5] <= iWB_RF_Write_Data;
        5'd6: rRegister_File_Memory[32*7-1:32*6] <= iWB_RF_Write_Data;
        5'd7: rRegister_File_Memory[32*8-1:32*7] <= iWB_RF_Write_Data;
        5'd8: rRegister_File_Memory[32*9-1:32*8] <= iWB_RF_Write_Data;
        5'd9: rRegister_File_Memory[32*10-1:32*9] <= iWB_RF_Write_Data;
        5'd10: rRegister_File_Memory[32*11-1:32*10] <= iWB_RF_Write_Data;
        5'd11: rRegister_File_Memory[32*12-1:32*11] <= iWB_RF_Write_Data;
        5'd12: rRegister_File_Memory[32*13-1:32*12] <= iWB_RF_Write_Data;
        5'd13: rRegister_File_Memory[32*14-1:32*13] <= iWB_RF_Write_Data;
        5'd14: rRegister_File_Memory[32*15-1:32*14] <= iWB_RF_Write_Data;
        5'd15: rRegister_File_Memory[32*16-1:32*15] <= iWB_RF_Write_Data;
        5'd16: rRegister_File_Memory[32*17-1:32*16] <= iWB_RF_Write_Data;
        5'd17: rRegister_File_Memory[32*18-1:32*17] <= iWB_RF_Write_Data;
        5'd18: rRegister_File_Memory[32*19-1:32*18] <= iWB_RF_Write_Data;
        5'd19: rRegister_File_Memory[32*20-1:32*19] <= iWB_RF_Write_Data;
        5'd20: rRegister_File_Memory[32*21-1:32*20] <= iWB_RF_Write_Data;
        5'd21: rRegister_File_Memory[32*22-1:32*21] <= iWB_RF_Write_Data;
        5'd22: rRegister_File_Memory[32*23-1:32*22] <= iWB_RF_Write_Data;
        5'd23: rRegister_File_Memory[32*24-1:32*23] <= iWB_RF_Write_Data;
        5'd24: rRegister_File_Memory[32*25-1:32*24] <= iWB_RF_Write_Data;
        5'd25: rRegister_File_Memory[32*26-1:32*25] <= iWB_RF_Write_Data;
        5'd26: rRegister_File_Memory[32*27-1:32*26] <= iWB_RF_Write_Data;
        5'd27: rRegister_File_Memory[32*28-1:32*27] <= iWB_RF_Write_Data;
        default: rRegister_File_Memory[31:0] <= 32'h0;
      endcase
  // end of always
  // ============
  // Read port A
  // ============  
  always @ ( rRegister_File_Memory or iIF_RF_Read_Addr_A )
    case ( iIF_RF_Read_Addr_A ) // synopsys parallel_case
      5'd1: rID_RF_Read_Data_A = rRegister_File_Memory[32*2-1:32*1];
      5'd2: rID_RF_Read_Data_A = rRegister_File_Memory[32*3-1:32*2];
      5'd3: rID_RF_Read_Data_A = rRegister_File_Memory[32*4-1:32*3];
      5'd4: rID_RF_Read_Data_A = rRegister_File_Memory[32*5-1:32*4];
      5'd5: rID_RF_Read_Data_A = rRegister_File_Memory[32*6-1:32*5];
      5'd6: rID_RF_Read_Data_A = rRegister_File_Memory[32*7-1:32*6];
      5'd7: rID_RF_Read_Data_A = rRegister_File_Memory[32*8-1:32*7];
      5'd8: rID_RF_Read_Data_A = rRegister_File_Memory[32*9-1:32*8];
      5'd9: rID_RF_Read_Data_A = rRegister_File_Memory[32*10-1:32*9];
      5'd10: rID_RF_Read_Data_A = rRegister_File_Memory[32*11-1:32*10];
      5'd11: rID_RF_Read_Data_A = rRegister_File_Memory[32*12-1:32*11];
      5'd12: rID_RF_Read_Data_A = rRegister_File_Memory[32*13-1:32*12];
      5'd13: rID_RF_Read_Data_A = rRegister_File_Memory[32*14-1:32*13];
      5'd14: rID_RF_Read_Data_A = rRegister_File_Memory[32*15-1:32*14];
      5'd15: rID_RF_Read_Data_A = rRegister_File_Memory[32*16-1:32*15];
      5'd16: rID_RF_Read_Data_A = rRegister_File_Memory[32*17-1:32*16];
      5'd17: rID_RF_Read_Data_A = rRegister_File_Memory[32*18-1:32*17];
      5'd18: rID_RF_Read_Data_A = rRegister_File_Memory[32*19-1:32*18];
      5'd19: rID_RF_Read_Data_A = rRegister_File_Memory[32*20-1:32*19];
      5'd20: rID_RF_Read_Data_A = rRegister_File_Memory[32*21-1:32*20];
      5'd21: rID_RF_Read_Data_A = rRegister_File_Memory[32*22-1:32*21];
      5'd22: rID_RF_Read_Data_A = rRegister_File_Memory[32*23-1:32*22];
      5'd23: rID_RF_Read_Data_A = rRegister_File_Memory[32*24-1:32*23];
      5'd24: rID_RF_Read_Data_A = rRegister_File_Memory[32*25-1:32*24];
      5'd25: rID_RF_Read_Data_A = rRegister_File_Memory[32*26-1:32*25];
      5'd26: rID_RF_Read_Data_A = rRegister_File_Memory[32*27-1:32*26];
      5'd27: rID_RF_Read_Data_A = rRegister_File_Memory[32*28-1:32*27];
      default: rID_RF_Read_Data_A = 32'h0;
    endcase
  // end of always    
  // ============
  // Read port B
  // ============
  always @ ( rRegister_File_Memory or iIF_RF_Read_Addr_B )
    case ( iIF_RF_Read_Addr_B ) // synopsys parallel_case
      5'd1: rID_RF_Read_Data_B = rRegister_File_Memory[32*2-1:32*1];
      5'd2: rID_RF_Read_Data_B = rRegister_File_Memory[32*3-1:32*2];
      5'd3: rID_RF_Read_Data_B = rRegister_File_Memory[32*4-1:32*3];
      5'd4: rID_RF_Read_Data_B = rRegister_File_Memory[32*5-1:32*4];
      5'd5: rID_RF_Read_Data_B = rRegister_File_Memory[32*6-1:32*5];
      5'd6: rID_RF_Read_Data_B = rRegister_File_Memory[32*7-1:32*6];
      5'd7: rID_RF_Read_Data_B = rRegister_File_Memory[32*8-1:32*7];
      5'd8: rID_RF_Read_Data_B = rRegister_File_Memory[32*9-1:32*8];
      5'd9: rID_RF_Read_Data_B = rRegister_File_Memory[32*10-1:32*9];
      5'd10: rID_RF_Read_Data_B = rRegister_File_Memory[32*11-1:32*10];
      5'd11: rID_RF_Read_Data_B = rRegister_File_Memory[32*12-1:32*11];
      5'd12: rID_RF_Read_Data_B = rRegister_File_Memory[32*13-1:32*12];
      5'd13: rID_RF_Read_Data_B = rRegister_File_Memory[32*14-1:32*13];
      5'd14: rID_RF_Read_Data_B = rRegister_File_Memory[32*15-1:32*14];
      5'd15: rID_RF_Read_Data_B = rRegister_File_Memory[32*16-1:32*15];
      5'd16: rID_RF_Read_Data_B = rRegister_File_Memory[32*17-1:32*16];
      5'd17: rID_RF_Read_Data_B = rRegister_File_Memory[32*18-1:32*17];
      5'd18: rID_RF_Read_Data_B = rRegister_File_Memory[32*19-1:32*18];
      5'd19: rID_RF_Read_Data_B = rRegister_File_Memory[32*20-1:32*19];
      5'd20: rID_RF_Read_Data_B = rRegister_File_Memory[32*21-1:32*20];
      5'd21: rID_RF_Read_Data_B = rRegister_File_Memory[32*22-1:32*21];
      5'd22: rID_RF_Read_Data_B = rRegister_File_Memory[32*23-1:32*22];
      5'd23: rID_RF_Read_Data_B = rRegister_File_Memory[32*24-1:32*23];
      5'd24: rID_RF_Read_Data_B = rRegister_File_Memory[32*25-1:32*24];
      5'd25: rID_RF_Read_Data_B = rRegister_File_Memory[32*26-1:32*25];
      5'd26: rID_RF_Read_Data_B = rRegister_File_Memory[32*27-1:32*26];
      5'd27: rID_RF_Read_Data_B = rRegister_File_Memory[32*28-1:32*27];
      default: rID_RF_Read_Data_B = 32'h0;
    endcase
  // end of always
  //*********************
  //  Output Assignment
  //*********************
  assign oRF_BP_Read_Data_A = rID_RF_Read_Data_A;
  assign oRF_BP_Read_Data_B = rID_RF_Read_Data_B;
endmodule