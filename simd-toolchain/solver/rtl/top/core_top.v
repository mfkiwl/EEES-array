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
  {% for i in range(cfg.pe.size) %}
  // PE{{i}}
  oPE{{i}}_DMEM_Valid,
  oPE{{i}}_AGU_DMEM_Write_Enable, // data memory write enable
  oPE{{i}}_AGU_DMEM_Read_Enable,  // data memory read enable
  oPE{{i}}_AGU_DMEM_Byte_Select,
  oPE{{i}}_AGU_DMEM_Address,      // address to DMEM
  oPE{{i}}_AGU_DMEM_Write_Data,   // data memory write data
  iPE{{i}}_DMEM_EX_Data,          // data loaded from data memory
  {% endfor %}
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
  {% for i in range(cfg.pe.size) %}
  // PE{{i}}
  output                                  oPE{{i}}_DMEM_Valid;
  output                                  oPE{{i}}_AGU_DMEM_Write_Enable; // data memory write enable
  output                                  oPE{{i}}_AGU_DMEM_Read_Enable;  // data memory read enable
  output [(`DEF_PE_DATA_WIDTH/8-1):0]     oPE{{i}}_AGU_DMEM_Byte_Select;
  output [(`DEF_PE_RAM_ADDR_BITS-1):0]    oPE{{i}}_AGU_DMEM_Address;      // Address to DMEM
  output [(`DEF_PE_DATA_WIDTH-1):0]       oPE{{i}}_AGU_DMEM_Write_Data;   // data memory write data
  input  [(`DEF_PE_DATA_WIDTH-1):0]       iPE{{i}}_DMEM_EX_Data;          // data loaded from data memory
  {% endfor %}

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
  {% for i in range(cfg.pe.size) %}
  // PE {{i}}
  wire [(`RISC24_PE_LSU_OP_WIDTH-1):0]    wPE{{i}}_AGU_DMEM_Opcode;
  wire [(`DEF_PE_DATA_WIDTH-1):0]         wPE{{i}}_AGU_DMEM_Address;
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]         wPE{{i}}_DMEM_EX_Data;
  reg  [(`RISC24_PE_LSU_OP_WIDTH-1):0]    PR_PE{{i}}_AGU_DMEM_Opcode;
  reg  [1:0]                              PR_PE{{i}}_AGU_DMEM_Addr_Last_Two;  
  {% endfor %}

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
  {% for i in range(cfg.pe.size) %}
  // PE {{i}}
  assign oPE{{i}}_DMEM_Valid       = oPE{{i}}_AGU_DMEM_Write_Enable || oPE{{i}}_AGU_DMEM_Read_Enable;
  assign oPE{{i}}_AGU_DMEM_Address = wPE{{i}}_AGU_DMEM_Address[(`DEF_PE_RAM_ADDR_BITS+1):2];
  
  // pipeline registers
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        PR_PE{{i}}_AGU_DMEM_Opcode        <= 'b0;
        PR_PE{{i}}_AGU_DMEM_Addr_Last_Two <= 2'b0;
      end
    else if ( oPE{{i}}_AGU_DMEM_Read_Enable )
      begin
        PR_PE{{i}}_AGU_DMEM_Opcode        <= wPE{{i}}_AGU_DMEM_Opcode;
        PR_PE{{i}}_AGU_DMEM_Addr_Last_Two <= wPE{{i}}_AGU_DMEM_Address[1:0];
      end
  // end of always
  
  // if pe-data-width = 32bit
  always @ ( PR_PE{{i}}_AGU_DMEM_Opcode or PR_PE{{i}}_AGU_DMEM_Addr_Last_Two or iPE{{i}}_DMEM_EX_Data )
    case ( PR_PE{{i}}_AGU_DMEM_Opcode )
      `RISC24_LSU_OP_WORD: begin
        wPE{{i}}_DMEM_EX_Data = iPE{{i}}_DMEM_EX_Data;
      end
      
      `RISC24_LSU_OP_HALF_WORD: begin
        if ( PR_PE{{i}}_AGU_DMEM_Addr_Last_Two[1] == 1'b0 )
          wPE{{i}}_DMEM_EX_Data = {16'b0, iPE{{i}}_DMEM_EX_Data[15:0]};
        else
          wPE{{i}}_DMEM_EX_Data = {16'b0, iPE{{i}}_DMEM_EX_Data[31:16]};
      end
      
      `RISC24_LSU_OP_BYTE: begin
        case (PR_PE{{i}}_AGU_DMEM_Addr_Last_Two[1:0])
          2'b00: wPE{{i}}_DMEM_EX_Data = {24'b0, iPE{{i}}_DMEM_EX_Data[7 : 0]};
          2'b01: wPE{{i}}_DMEM_EX_Data = {24'b0, iPE{{i}}_DMEM_EX_Data[15: 8]};
          2'b10: wPE{{i}}_DMEM_EX_Data = {24'b0, iPE{{i}}_DMEM_EX_Data[23:16]};
          2'b11: wPE{{i}}_DMEM_EX_Data = {24'b0, iPE{{i}}_DMEM_EX_Data[31:24]};
        endcase
      end
        
      default: begin
        wPE{{i}}_DMEM_EX_Data = iPE{{i}}_DMEM_EX_Data;
      end
    endcase
  // end of always
  {% endfor %}
  
  
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
    {% for i in range(cfg.pe.size) %}
    // PE {{i}}
    .oPE{{i}}_AGU_DMEM_Write_Enable ( oPE{{i}}_AGU_DMEM_Write_Enable ),  // LSU stage data-memory write enable
    .oPE{{i}}_AGU_DMEM_Read_Enable  ( oPE{{i}}_AGU_DMEM_Read_Enable  ),  // LSU stage data-memory read enable
    .oPE{{i}}_AGU_DMEM_Address      ( wPE{{i}}_AGU_DMEM_Address      ),  // Address to DMEM
    .oPE{{i}}_AGU_DMEM_Opcode       ( wPE{{i}}_AGU_DMEM_Opcode       ),  // LSU opcoce: word/half-word/byte
    .oPE{{i}}_AGU_DMEM_Byte_Select  ( oPE{{i}}_AGU_DMEM_Byte_Select  ),
    .oPE{{i}}_AGU_DMEM_Store_Data   ( oPE{{i}}_AGU_DMEM_Write_Data   ),  // Store data to EX stage (for store instruction only)
    .iPE{{i}}_DMEM_EX_Data          ( wPE{{i}}_DMEM_EX_Data          ),  // data loaded from data memory
    {% endfor %}
    // from/to CP
    .iCP_Data                      ( wCP_Port1_Data            ),  // cp port 1 data to pe
    .oFirst_PE_Port1_Data          ( wFirst_PE_Port1_Data      ),  // data from first PE RF port 1
    .oLast_PE_Port1_Data           ( wLast_PE_Port1_Data       )   // data from last PE RF port 1
  );


endmodule
