////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//    Module Name :  pe_agu                                                   //
//    Description :  This is the address generation unit for the pe           //
//                                                                            //
//    Author(s)   :  Luc Waeijen                                              //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

`include "def-cp.v"

// synopsys translate_off
`timescale 1ns / 1ps
// synopsys translate_on


module cp_agu (
  iClk,                                  // system clock, positive-edge trigger
  iReset,                                // global synchronous reset signal, Active high
  
  iID_AGU_Operand_A,                     // Operand A to the EX stage for LSU only
  iID_AGU_Operand_B,                     // Operand B to the EX stage for LSU only
  
  iID_AGU_Memory_Write_Enable,           // Write enable from ID
  iID_AGU_Memory_Read_Enable,            // Read enable from ID
  iID_AGU_Memory_Opcode,                 // LSU opcoce: word/half-word/byte
  iID_AGU_Memory_Store_Data,
  
  oAGU_DMEM_Memory_Write_Enable,         // Write enable to DMEM
  oAGU_DMEM_Memory_Read_Enable,          // Read enable to DMEM
  oAGU_DMEM_Byte_Select,
  oAGU_DMEM_Opcode, 
  oAGU_DMEM_Memory_Store_Data,
  oAGU_DMEM_Address                      // Address to DMEM
);

//****************************
//  Input/Output Declaration
//****************************

  input                                  iClk;
  input                                  iReset;                
  input  [(`DEF_CP_DATA_WIDTH-1):0]      iID_AGU_Operand_A;      
  input  [(`DEF_CP_DATA_WIDTH-1):0]      iID_AGU_Operand_B;      

  input                                  iID_AGU_Memory_Write_Enable;
  input                                  iID_AGU_Memory_Read_Enable;
  input  [(`RISC24_CP_LSU_OP_WIDTH-1):0] iID_AGU_Memory_Opcode;
  input  [(`DEF_CP_DATA_WIDTH-1):0]      iID_AGU_Memory_Store_Data;

  output                                 oAGU_DMEM_Memory_Write_Enable;
  output                                 oAGU_DMEM_Memory_Read_Enable;
  output [(`DEF_CP_DATA_WIDTH/8-1):0]    oAGU_DMEM_Byte_Select;
  output [(`RISC24_CP_LSU_OP_WIDTH-1):0] oAGU_DMEM_Opcode;
  output [(`DEF_CP_DATA_WIDTH-1):0]      oAGU_DMEM_Memory_Store_Data;

  output [(`DEF_CP_DATA_WIDTH-1):0]      oAGU_DMEM_Address;      // Generated Address


//******************************
//  Local Wire/Reg Declaration
//******************************
  wire                                   wID_AGU_Memory_Write_Enable;
  wire                                   wID_AGU_Memory_Read_Enable;

  wire [(`DEF_CP_DATA_WIDTH-1):0]        wCore_Address_Temp;
  wire [(`DEF_CP_DATA_WIDTH-1):0]        wCore_Address;          // memory access address, from AGU

  reg  [(`DEF_CP_DATA_WIDTH/8-1):0]      wMem_Byte_Select;

  reg  [(`DEF_CP_DATA_WIDTH-1):0]        wStore_data;
  

//******************************
//  Behavioral Description
//******************************
  assign wCore_Address_Temp = iID_AGU_Operand_A + iID_AGU_Operand_B;
  assign wCore_Address      = wCore_Address_Temp;

  assign wID_AGU_Memory_Write_Enable = iID_AGU_Memory_Write_Enable;
  assign wID_AGU_Memory_Read_Enable  = iID_AGU_Memory_Read_Enable;
    
  // memory byte selection signal
  // if data-width = 32bit
  always @ ( iID_AGU_Memory_Opcode or wCore_Address_Temp[1:0] or iID_AGU_Memory_Store_Data )
    case ( iID_AGU_Memory_Opcode )
      `RISC24_CP_LSU_OP_WORD: begin
        wMem_Byte_Select = 4'b1111;
        wStore_data      = iID_AGU_Memory_Store_Data;
      end
      
      `RISC24_CP_LSU_OP_HALF_WORD: begin
        if ( wCore_Address_Temp[1] == 1'b0 ) begin
          wMem_Byte_Select = 4'b0011;
          wStore_data      = iID_AGU_Memory_Store_Data;
        end
        else begin
          wMem_Byte_Select = 4'b1100;
          wStore_data      = {iID_AGU_Memory_Store_Data[15:0], iID_AGU_Memory_Store_Data[15:0]};
        end
      end
      
      `RISC24_CP_LSU_OP_BYTE: begin
        case (wCore_Address_Temp[1:0])
          2'b00: begin
            wMem_Byte_Select = 4'b0001;
            wStore_data      = iID_AGU_Memory_Store_Data;
          end
          2'b01: begin
            wMem_Byte_Select = 4'b0010;
            wStore_data      = {iID_AGU_Memory_Store_Data[31:16], iID_AGU_Memory_Store_Data[7:0], iID_AGU_Memory_Store_Data[7:0]};
          end
          2'b10: begin
            wMem_Byte_Select = 4'b0100;
            wStore_data      = {iID_AGU_Memory_Store_Data[31:24], iID_AGU_Memory_Store_Data[7:0], iID_AGU_Memory_Store_Data[15:0]};
          end
          2'b11: begin
            wMem_Byte_Select = 4'b1000;
            wStore_data      = {iID_AGU_Memory_Store_Data[7:0], iID_AGU_Memory_Store_Data[23:0]};
          end
        endcase
      end
        
      default: begin
        wMem_Byte_Select = 4'b0000;
        wStore_data      = iID_AGU_Memory_Store_Data;
      end
    endcase
  // end of always


//*********************
//  Output Assignment
//*********************

  assign oAGU_DMEM_Byte_Select         = wMem_Byte_Select;
  assign oAGU_DMEM_Opcode              = iID_AGU_Memory_Opcode;
  assign oAGU_DMEM_Address             = wCore_Address;
  assign oAGU_DMEM_Memory_Write_Enable = wID_AGU_Memory_Write_Enable;
  assign oAGU_DMEM_Memory_Read_Enable  = wID_AGU_Memory_Read_Enable;
  assign oAGU_DMEM_Memory_Store_Data   = wStore_data;

endmodule





