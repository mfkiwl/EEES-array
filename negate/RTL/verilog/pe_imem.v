///:SYNTH: -asic
////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//    Module Name :  pe_imem                                                  //
//    Description :  BRAM for instructioin memory (PE).                       //
//                                                                            //
//    Author(s)   :  Yifan He                                                 //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

`include "def-pe.v"

// synopsys translate_off
`timescale 1ns / 1ps
// synopsys translate_on


module pe_imem (
  iClk,                             // system clock, positive-edge trigger

  // port A: bus
  iBus_Valid,                       // memory access valid  
  iBus_Address,                     // memory access address
  iBus_Write_Data,                  // memory write data    
  iBus_Write_Enable,                // memory write enable  
  oBus_Read_Data,                   // memory read data     
  
  // port B: core
  iIF_IMEM_Addr,                    // address to the insruction memory  
  oIMEM_IF_Instruction              // instruction fetched from instruction memory
);
  

//******************************
//  Local Parameter Definition
//******************************
   parameter RAM_WIDTH     = (`DEF_PE_INS_WIDTH + 3 + 2);            // inst. width + 2-bit data selection + 2-bit predication
   parameter RAM_ADDR_BITS = 13;                                     // 8K-entry


//****************************
//  Input/Output Declaration
//****************************

  input                                   iClk;                      // system clock, positive-edge trigger
  
  // port A: bus
  input                                   iBus_Valid;                // memory access valid
  input  [(`DEF_PE_I_MEM_ADDR_WIDTH-3):0] iBus_Address;              // memory access address 
  input  [(`DEF_PE_INS_WIDTH+4):0]        iBus_Write_Data;           // memory write data
  input                                   iBus_Write_Enable;         // memory write enable
  output [(`DEF_PE_INS_WIDTH+4):0]        oBus_Read_Data;            // memory read data
  
  // port B: core
  input  [(`DEF_PE_I_MEM_ADDR_WIDTH-3):0] iIF_IMEM_Addr;             // address to the insruction memory  
  output [(`DEF_PE_INS_WIDTH+4):0]        oIMEM_IF_Instruction;      // instruction fetched from instruction memory

   
//******************************
//  Local Wire/Reg Declaration
//******************************   
   
  reg  [RAM_WIDTH-1:0]       imem [(2**RAM_ADDR_BITS)-1:0];
  
  reg  [RAM_WIDTH-1:0]       rCore_Data_Out;
  reg  [RAM_WIDTH-1:0]       rBus_Data_Out;


  wire                       wCore_Valid;
  
  wire [(RAM_ADDR_BITS-1):0] wCore_Address;                           // Ins. memory address: core side
  wire [(RAM_ADDR_BITS-1):0] wBus_Address;                            // Ins. memory address: bus side
  
   
//******************************
//  Behavioral Description
//******************************
   
  assign wCore_Valid   = 'b1;  
  assign wCore_Address = iIF_IMEM_Addr[(RAM_ADDR_BITS-1):0];
  assign wBus_Address  = iBus_Address[(RAM_ADDR_BITS-1):0];
  
  //initial
  //  begin
  //    $readmemh("./../testdata_risc24_bypass/histogram256.imem_init", imem);
  //    $readmemh("./../testdata_risc24_bypass/histogram256.or24.rf_init", imem);
  //  end
    
  always @ ( posedge iClk ) begin
   if ( iBus_Valid ) begin
      if ( iBus_Write_Enable )
         imem[wBus_Address] <= iBus_Write_Data;
      rBus_Data_Out <= imem[wBus_Address];
   end
   
   if ( wCore_Valid )
      rCore_Data_Out <= imem[wCore_Address];
  end
  // end of always
  
            
//*********************
//  Output Assignment
//*********************
  assign oBus_Read_Data       = rBus_Data_Out;
  
  assign oIMEM_IF_Instruction = rCore_Data_Out;
  
            
endmodule 



                        