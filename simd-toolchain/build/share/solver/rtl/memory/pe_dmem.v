///:SYNTH: -asic
////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//    Module Name :  pe_dmem                                                  //
//    Description :  BRAM for control processor data memory.                  //
//                                                                            //
//    Author(s)   :  Yifan He                                                 //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

`include "def-pe.v"

// synopsys translate_off
`timescale 1ns / 1ps
// synopsys translate_on


module pe_dmem (
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
   parameter RAM_WIDTH = `DEF_PE_DATA_WIDTH;


//****************************
//  Input/Output Declaration
//****************************

  input                                     iClk;                          // system clock, positive-edge trigger

  // port A: bus
  input                                     iBus_Valid;                    // memory access valid
  input  [(`DEF_PE_D_MEM_ADDR_WIDTH-1):0]   iBus_Address;                  // memory access address
  input  [(`DEF_PE_DATA_WIDTH-1):0]         iBus_Write_Data;               // memory write data
  input                                     iBus_Write_Enable;             // memory write enable
  output [(`DEF_PE_DATA_WIDTH-1):0]         oBus_Read_Data;                // memory read data

  // port B: core
  input                                     iCore_Valid;                   // memory access valid
  input                                     iAGU_DMEM_Memory_Write_Enable; // LSU stage data-memory write enable
  input                                     iAGU_DMEM_Memory_Read_Enable;  // LSU stage data-memory read enable
  input  [(`DEF_PE_DATA_WIDTH/8-1):0]       iAGU_DMEM_Byte_Select;
  inout  [(`DEF_PE_RAM_ADDR_BITS-1):0]      iAGU_DMEM_Address;             // Address to read/write
  input  [(`DEF_PE_DATA_WIDTH-1):0]         iAGU_DMEM_Store_Data;          // Store data to EX stage (for store instruction only)
  output [(`DEF_PE_DATA_WIDTH-1):0]         oDMEM_EX_Data;                 // data loaded from data memory

//******************************
//  Local Wire/Reg Declaration
//******************************

  {% for i in range(cfg.pe.dwidth//8) -%}
  reg  [7:0]      dmem{{i}} [(2**`DEF_PE_RAM_ADDR_BITS)-1:0];
  reg  [7:0]      rCore_Data_Out{{i}};
  {% endfor %}

  reg  [RAM_WIDTH-1:0]                rBus_Data_Out;

  wire [(`DEF_PE_RAM_ADDR_BITS-1):0]  wBus_Address;    // memory access address, from bus


//******************************
//  Behavioral Description
//******************************

  assign wBus_Address = iBus_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];

  // Port A: bus
  always @ ( posedge iClk )begin
    if ( iBus_Valid ) begin
      if ( iBus_Write_Enable ) begin
        {% for i in range(cfg.pe.dwidth//8) -%}
        dmem{{i}}[wBus_Address] <= iBus_Write_Data[(8*({{i}}+1)-1):8*{{i}}];
        {% endfor %}
      end
      else begin
        rBus_Data_Out <= { {% for i in range(cfg.cp.dwidth//8) -%}dmem{{cfg.cp.dwidth//8-i-1}}[wBus_Address]{% if i!= cfg.cp.dwidth//8-1%}, {% endif %}{% endfor %} };
      end
    end
  end
  // end of always

   // Port B: core
  always @ ( posedge iClk ) begin
    if ( iCore_Valid ) begin
      if ( iAGU_DMEM_Memory_Write_Enable ) begin
        {% for i in range(cfg.cp.dwidth//8) -%}
        if ( iAGU_DMEM_Byte_Select[{{i}}] == 1'b1 ) begin
          dmem{{i}}[iAGU_DMEM_Address] <= iAGU_DMEM_Store_Data[(8*({{i}}+1)-1):8*{{i}}];
        end
        {% endfor %}
      end
      else begin
        {% for i in range(cfg.cp.dwidth//8) -%}
        if ( iAGU_DMEM_Byte_Select[{{i}}] == 1'b1 ) begin
            rCore_Data_Out{{i}} <= dmem{{i}}[iAGU_DMEM_Address];
        end
        {% endfor %}
      end
    end
  end
  // end of always
  

//*********************
//  Output Assignment
//*********************
  assign oBus_Read_Data = rBus_Data_Out;
  assign oDMEM_EX_Data  = { {% for i in range(cfg.cp.dwidth//8) -%}rCore_Data_Out{{cfg.cp.dwidth//8-i-1}}{% if i!= cfg.cp.dwidth//8-1%}, {% endif %}{% endfor %} };

endmodule


