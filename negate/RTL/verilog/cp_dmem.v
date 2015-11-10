///:SYNTH: -asic
////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//    Module Name :  cp_dmem                                                  //
//    Description :  BRAM for control processor data memory.                  //
//                                                                            //
//    Author(s)   :  Yifan He                                                 //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

`include "def-cp.v"

// synopsys translate_off
`timescale 1ns / 1ps
// synopsys translate_on


module cp_dmem (
  iClk,                              // system clock, positive-edge trigger

  // port A: bus
  iBus_Valid,                        // memory access valid
  iBus_Address,                      // memory access address
  iBus_Write_Data,                   // memory write data
  iBus_Write_Enable,                 // memory write enable
  oBus_Read_Data,                    // memory read data

  // port B: core
  iCore_Valid,                       // memory access valid
  iAGU_DMEM_Memory_Write_Enable,     // LSU stage data-memory write enable
  iAGU_DMEM_Memory_Read_Enable,      // LSU stage data-memory read enable
  iAGU_DMEM_Byte_Select,             // memory byte selection
  iAGU_DMEM_Address,                 // Address to read/write
  iAGU_DMEM_Store_Data,              // Store data to EX stage (for store instruction only)
  oDMEM_EX_Data                      // data loaded from data memory
);


//******************************
//  Local Parameter Definition
//******************************
   parameter RAM_WIDTH = `DEF_CP_DATA_WIDTH;


//****************************
//  Input/Output Declaration
//****************************

  input                                     iClk;                          // system clock, positive-edge trigger

  // port A: bus
  input                                     iBus_Valid;                    // memory access valid
  input  [(`DEF_CP_D_MEM_ADDR_WIDTH-1):0]   iBus_Address;                  // memory access address
  input  [(`DEF_CP_DATA_WIDTH-1):0]         iBus_Write_Data;               // memory write data
  input                                     iBus_Write_Enable;             // memory write enable
  output [(`DEF_CP_DATA_WIDTH-1):0]         oBus_Read_Data;                // memory read data

  // port B: core
  input                                     iCore_Valid;                   // memory access valid
  input                                     iAGU_DMEM_Memory_Write_Enable; // LSU stage data-memory write enable
  input                                     iAGU_DMEM_Memory_Read_Enable;  // LSU stage data-memory read enable
  input  [(`DEF_CP_DATA_WIDTH/8-1):0]       iAGU_DMEM_Byte_Select;
  inout  [(`DEF_CP_RAM_ADDR_BITS-1):0]      iAGU_DMEM_Address;             // Address to read/write
  input  [(`DEF_CP_DATA_WIDTH-1):0]         iAGU_DMEM_Store_Data;          // Store data to EX stage (for store instruction only)
  output [(`DEF_CP_DATA_WIDTH-1):0]         oDMEM_EX_Data;                 // data loaded from data memory



//******************************
//  Local Wire/Reg Declaration
//******************************

  //reg  [RAM_WIDTH-1:0]       dmem [(2**`DEF_CP_RAM_ADDR_BITS)-1:0];
  
  reg  [7:0]       dmem0 [(2**`DEF_CP_RAM_ADDR_BITS)-1:0];
  reg  [7:0]       rCore_Data_Out0;
  reg  [7:0]       dmem1 [(2**`DEF_CP_RAM_ADDR_BITS)-1:0];
  reg  [7:0]       rCore_Data_Out1;
  reg  [7:0]       dmem2 [(2**`DEF_CP_RAM_ADDR_BITS)-1:0];
  reg  [7:0]       rCore_Data_Out2;
  reg  [7:0]       dmem3 [(2**`DEF_CP_RAM_ADDR_BITS)-1:0];
  reg  [7:0]       rCore_Data_Out3;
  
  
  reg [(`DEF_CP_DATA_WIDTH-1):0] rBus_Data_Out;

  wire [(`DEF_CP_RAM_ADDR_BITS-1):0] wBus_Address;     // memory access address, from bus


//******************************
//  Behavioral Description
//******************************

  assign wBus_Address       = iBus_Address[(`DEF_CP_RAM_ADDR_BITS+1):2];

  //initial
  //  begin
  //    $readmemh("./../testdata_risc24_bypass/histogram256.dmem_init", dmem);
  //  end


  // Port A: bus
  always @ ( posedge iClk ) begin
    if ( iBus_Valid ) begin
      if ( iBus_Write_Enable ) begin
        dmem0[wBus_Address] <= iBus_Write_Data[(8*(0+1)-1):8*0];
        dmem1[wBus_Address] <= iBus_Write_Data[(8*(1+1)-1):8*1];
        dmem2[wBus_Address] <= iBus_Write_Data[(8*(2+1)-1):8*2];
        dmem3[wBus_Address] <= iBus_Write_Data[(8*(3+1)-1):8*3];
        
      end
      else begin
        rBus_Data_Out <= { dmem3[wBus_Address], dmem2[wBus_Address], dmem1[wBus_Address], dmem0[wBus_Address] };
      end
    end
  end
  // end of always
  
  // Port B: core
  always @ ( posedge iClk ) begin
    if ( iCore_Valid ) begin
      if ( iAGU_DMEM_Memory_Write_Enable ) begin
        if ( iAGU_DMEM_Byte_Select[0] == 1'b1 ) begin
          dmem0[iAGU_DMEM_Address] <= iAGU_DMEM_Store_Data[(8*(0+1)-1):8*0];
        end
        if ( iAGU_DMEM_Byte_Select[1] == 1'b1 ) begin
          dmem1[iAGU_DMEM_Address] <= iAGU_DMEM_Store_Data[(8*(1+1)-1):8*1];
        end
        if ( iAGU_DMEM_Byte_Select[2] == 1'b1 ) begin
          dmem2[iAGU_DMEM_Address] <= iAGU_DMEM_Store_Data[(8*(2+1)-1):8*2];
        end
        if ( iAGU_DMEM_Byte_Select[3] == 1'b1 ) begin
          dmem3[iAGU_DMEM_Address] <= iAGU_DMEM_Store_Data[(8*(3+1)-1):8*3];
        end
        
      end
      else begin
        if ( iAGU_DMEM_Byte_Select[0] == 1'b1 ) begin
            rCore_Data_Out0 <= dmem0[iAGU_DMEM_Address];
        end
        if ( iAGU_DMEM_Byte_Select[1] == 1'b1 ) begin
            rCore_Data_Out1 <= dmem1[iAGU_DMEM_Address];
        end
        if ( iAGU_DMEM_Byte_Select[2] == 1'b1 ) begin
            rCore_Data_Out2 <= dmem2[iAGU_DMEM_Address];
        end
        if ( iAGU_DMEM_Byte_Select[3] == 1'b1 ) begin
            rCore_Data_Out3 <= dmem3[iAGU_DMEM_Address];
        end
        
      end
    end
  end
  // end of always


//*********************
//  Output Assignment
//*********************
  assign oBus_Read_Data = rBus_Data_Out;
  assign oDMEM_EX_Data  = { rCore_Data_Out3, rCore_Data_Out2, rCore_Data_Out1, rCore_Data_Out0 };

endmodule