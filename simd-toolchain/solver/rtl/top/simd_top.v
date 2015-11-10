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
  {% for i in range(cfg.pe.size) %}
  // PE{{i}}
  wire                                    wPE{{i}}_DMEM_Valid;
  wire                                    wPE{{i}}_AGU_DMEM_Write_Enable; // data memory write enable
  wire                                    wPE{{i}}_AGU_DMEM_Read_Enable;  // data memory read enable
  wire [(`DEF_PE_DATA_WIDTH/8-1):0]       wPE{{i}}_AGU_DMEM_Byte_Select;
  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]      wPE{{i}}_AGU_DMEM_Address;      // Address to DMEM
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE{{i}}_AGU_DMEM_Write_Data;   // data memory write data
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE{{i}}_DMEM_EX_Data;          // data loaded from data memory
  {% endfor %}
  
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
  
  {% for i in range(cfg.pe.size) %}
  pe_dmem inst_pe{{i}}_dmem(
    .iClk                          ( iClk                     ),  // system clock
    // port A: bus
    .iBus_Valid                    ( iBus_PE_DMEM_Valid[{{i}}]    ), // data memory access valid
    .iBus_Address                  ( iBus_PE_DMEM_Address[(`DEF_PE_D_MEM_ADDR_WIDTH*{{i+1}}-1):`DEF_PE_D_MEM_ADDR_WIDTH*{{i}}]), // data memory access address
    .iBus_Write_Data               ( iBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*{{i+1}}-1):`DEF_PE_DATA_WIDTH*{{i}}]), // data memory write data
    .iBus_Write_Enable             ( iBus_PE_DMEM_Write_Enable[{{i}}] ), // data memory write enable
    .oBus_Read_Data                ( oBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*{{i+1}}-1):`DEF_PE_DATA_WIDTH*{{i}}] ), // data memory read data

    // port B: core
    .iCore_Valid                   ( wPE{{i}}_DMEM_Valid            ), // memory access valid
    .iAGU_DMEM_Memory_Write_Enable ( wPE{{i}}_AGU_DMEM_Write_Enable ), // LSU stage data-memory write enable
    .iAGU_DMEM_Memory_Read_Enable  ( wPE{{i}}_AGU_DMEM_Read_Enable  ), // LSU stage data-memory read enable
    .iAGU_DMEM_Byte_Select         ( wPE{{i}}_AGU_DMEM_Byte_Select  ), // memory byte selection
    .iAGU_DMEM_Address             ( wPE{{i}}_AGU_DMEM_Address      ), // Address to operate on
    .iAGU_DMEM_Store_Data          ( wPE{{i}}_AGU_DMEM_Write_Data   ), // Store data to EX stage (for store instruction only)
    .oDMEM_EX_Data                 ( wPE{{i}}_DMEM_EX_Data          )  // data loaded from data memory
  );
  {% endfor %}

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
    {% for i in range(cfg.pe.size) %}
    // PE{{i}}
    .oPE{{i}}_DMEM_Valid            ( wPE{{i}}_DMEM_Valid           ),
    .oPE{{i}}_AGU_DMEM_Write_Enable ( wPE{{i}}_AGU_DMEM_Write_Enable),  // data memory write enable
    .oPE{{i}}_AGU_DMEM_Read_Enable  ( wPE{{i}}_AGU_DMEM_Read_Enable ),  // data memory read enable
    .oPE{{i}}_AGU_DMEM_Byte_Select  ( wPE{{i}}_AGU_DMEM_Byte_Select ),
    .oPE{{i}}_AGU_DMEM_Address      ( wPE{{i}}_AGU_DMEM_Address     ),  // data memory address
    .oPE{{i}}_AGU_DMEM_Write_Data   ( wPE{{i}}_AGU_DMEM_Write_Data  ),  // data memory write data
    .iPE{{i}}_DMEM_EX_Data          ( wPE{{i}}_DMEM_EX_Data         ),  // data loaded from data memory
    {% endfor %}
    // -----
    //  PE
    // -----
    .iIMEM_PE_Instruction          ( wIMEM_PE_Instruction      )  // instruction fetched from PE instruction memory
  );


//*********************
//  Output Assignment
//*********************


endmodule
