////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//    Module Name :  cp_if                                                    //
//    Description :  Instruction Fetch stage of the 24-bit bypass RISC        //
//                   processor. This is used as control processor (CP) in the //
//                   SIMD processor.                                          //
//                                                                            //
//    Author(s)   :  Yifan He                                                 //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

`include "def-cp.v"

// synopsys translate_off
`timescale 1ns / 1ps
// synopsys translate_on



module cp_if (      
  iClk,                              // system clock, positive-edge trigger
  iReset,                            // global synchronous reset signal, Active high
  
  // from/to ID stage
  iID_IF_Branch_Target_Addr,         // branch target address
  iID_IF_Branch_Taken_Flag,          // branch taken flag:  1 = taken, 0 = not taken
  
  oIF_ID_PC,                         // PC of the instruction at the current stage
  oIF_ID_Instruction,                // IF stage to ID stage instruction
  oIF_ID_Branch_Op,                  // branch operation types
  
  oSelect_First_PE,                  // flag: select the data from first PE
  oSelect_Last_PE,                   // flag: select the data from last PE
  
  oPredication,                      // IF-ID predication bits
  
  // to RF read ports
  oIF_RF_Read_Addr_A,                // RF read port A address
  oIF_RF_Read_Addr_B,                // RF read port B address
  
  // to bypass
  oIF_BP_Select_Imm,                 // indicate that the second operand is from immediate value
  oIF_BP_Bypass_Read_A,              // flag that indicate RF read port A bypassed  
  oIF_BP_Bypass_Read_B,              // flag that indicate RF read port B bypassed 
  oIF_BP_Bypass_Sel_A,               // port A bypass source selection 
  oIF_BP_Bypass_Sel_B,               // port B bypass source selection
  
  // predication
  iPredication,                      // cp predication bits
    
  // from/to instruction memory
  iSelect_First_PE,                  // flag: select the data from first PE
  iSelect_Last_PE,                   // flag: select the data from last PE
  iIMEM_IF_Instruction,              // instruction fetched from instruction memory
  oIF_IMEM_Addr                      // PC address to the insruction memory
  
);

//******************************
//  Local Parameter Definition
//******************************



//****************************
//  Input/Output Declaration
//****************************

  input                                    iClk;                              // system clock, positive-edge trigger
  input                                    iReset;                            // global synchronous reset signal, Active high
                                                  
  // from/to ID stage                             
  input  [(`DEF_CP_I_MEM_ADDR_WIDTH-3):0]  iID_IF_Branch_Target_Addr;         // branch target address
  input                                    iID_IF_Branch_Taken_Flag;          // branch taken flag:  1 = taken, 0 = not taken
  
  output [(`DEF_CP_I_MEM_ADDR_WIDTH-3):0]  oIF_ID_PC;                         // PC of the instruction at the current stage
  output [(`DEF_CP_INS_WIDTH-1):0]         oIF_ID_Instruction;                // IF stage to ID stage instruction  
  output [(`RISC24_CP_BRANCHOP_WIDTH-1):0] oIF_ID_Branch_Op;                  // branch operation types
  
  output                                   oSelect_First_PE;                  // flag: select the data from first PE
  output                                   oSelect_Last_PE;                   // flag: select the data from last PE
  
  output [1:0]                             oPredication;                      // IF-ID predication bits
  
  // to RF read ports
  output [(`DEF_CP_RF_INDEX_WIDTH-1):0]    oIF_RF_Read_Addr_A;                // RF read port A address
  output [(`DEF_CP_RF_INDEX_WIDTH-1):0]    oIF_RF_Read_Addr_B;                // RF read port B address
  
  // to bypass
  output                                   oIF_BP_Select_Imm;                 // indicate that the second operand is from immediate value
  output                                   oIF_BP_Bypass_Read_A;              // flag that indicate RF read port A bypassed  
  output                                   oIF_BP_Bypass_Read_B;              // flag that indicate RF read port B bypassed 
  output [1:0]                             oIF_BP_Bypass_Sel_A;               // port A bypass source selection 
  output [1:0]                             oIF_BP_Bypass_Sel_B;               // port B bypass source selection 
  
  // predication
  input  [1:0]                             iPredication;
    
  // from/to instruction memory
  input                                    iSelect_First_PE;                  // flag: select the data from first PE
  input                                    iSelect_Last_PE;                   // flag: select the data from last PE
  input  [(`DEF_CP_INS_WIDTH-1):0]         iIMEM_IF_Instruction;              // instruction fetched from instruction memory
  output [(`DEF_CP_I_MEM_ADDR_WIDTH-3):0]  oIF_IMEM_Addr;                     // PC address to the insruction memory
  


//******************************
//  Local Wire/Reg Declaration
//******************************

  reg  [(`DEF_CP_I_MEM_ADDR_WIDTH-3):0]    rNext_PC;                          // instruction fetched from instruction memory
  wire [(`DEF_CP_I_MEM_ADDR_WIDTH-3):0]    wPC_Plus_4;                        // current PC plus 4 (1)
  wire [(`DEF_CP_I_MEM_ADDR_WIDTH-3):0]    wCurrent_IMEM_Addr;                // current ins. memory address
  reg  [(`DEF_CP_I_MEM_ADDR_WIDTH-3):0]    rCurrent_PC_tmp;                   // delayed current PC
                                                                             
  wire                                     wRF_Read_A_Enable;                 // RF read port A enable
  wire                                     wRF_Read_B_Enable;                 // RF read port B enable
  wire                                     wRF_Read_A_Bypass;                 // RF read port A bypassed
  wire                                     wRF_Read_B_Bypass;                 // RF read port B bypassed 
  
  reg                                      rPR_ID_BP_Bypass_Read_A;           // Pipeline register: flag that indicate RF read port A bypassed  
  reg                                      rPR_ID_BP_Bypass_Read_B;           // Pipeline register: flag that indicate RF read port B bypassed 
  reg  [1:0]                               rPR_ID_BP_Bypass_Sel_A;            // Pipleine register: bypass source selection 
  reg  [1:0]                               rPR_ID_BP_Bypass_Sel_B;            // Pipleine register: bypass source selection 
  
  // pipeline registers                                                      
  reg  [(`DEF_CP_I_MEM_ADDR_WIDTH-3):0]    rPR_ID_PC;                         // PC with the current instruction
  reg  [(`DEF_CP_INS_WIDTH-1):0]           rPR_ID_Instruction;                // instruction
  reg                                      rSelect_First_PE;                  // flag: select the data from first PE
  reg                                      rSelect_Last_PE;                   // flag: select the data from last PE
  reg  [1:0]                               rPR_ID_Predication;                // IF_ID predication bits
                                                                             
  reg  [(`DEF_CP_RF_INDEX_WIDTH-1):0]      rPR_ID_RF_Read_Addr_A;             // RF read port A address
  reg  [(`DEF_CP_RF_INDEX_WIDTH-1):0]      rPR_ID_RF_Read_Addr_B;             // RF read port B address
  reg                                      rPR_ID_Select_Imm;                 // indicate that the second operand is from immediate value
  reg  [(`RISC24_CP_BRANCHOP_WIDTH-1):0]   rPR_ID_Branch_Op;                  // branch operation types
                                                                             
  wire                                     wIs_J_Type;                        // Flag: is a J-type instruction


//******************************
//  Behavioral Description
//******************************
  // ======================
  //   PC & instruction
  // ======================
  assign wPC_Plus_4 = wCurrent_IMEM_Addr + 1'b1;      // bit[1:0] = 2'b00

  assign wCurrent_IMEM_Addr = ( iID_IF_Branch_Taken_Flag ) ? iID_IF_Branch_Target_Addr : rNext_PC;

  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      rNext_PC <= `DEF_CP_BOOT_PC_DEFAULT;            // default program starting address
    else 
      rNext_PC <= wPC_Plus_4;
  // end of always
  

  // delay current PC as BRAM read takes one cycle
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      rCurrent_PC_tmp <= `DEF_CP_BOOT_PC_DEFAULT; 
    else 
      rCurrent_PC_tmp <= wCurrent_IMEM_Addr;
  // end of always
  
  
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        rPR_ID_PC          <= 'b0;
        rPR_ID_Instruction <= 'b0; 
        rSelect_First_PE   <= 'b0;
        rSelect_Last_PE    <= 'b0;
        rPR_ID_Predication <= 'b0;       
      end
    else
      begin
        rPR_ID_PC          <= rCurrent_PC_tmp;
        rPR_ID_Instruction <= iIMEM_IF_Instruction; 
        rSelect_First_PE   <= iSelect_First_PE;
        rSelect_Last_PE    <= iSelect_Last_PE; 
        rPR_ID_Predication <= iPredication;     
      end
  // end of always 


  // ===============================
  // Register File read port A & B 
  // ===============================
                              // RF index >= 28 (5'b11100)
  assign wRF_Read_A_Bypass = ( iIMEM_IF_Instruction[`DEF_CP_INS_SRC1_END_BIT] && iIMEM_IF_Instruction[`DEF_CP_INS_SRC1_END_BIT-1] && iIMEM_IF_Instruction[`DEF_CP_INS_SRC1_END_BIT-2] );
  assign wRF_Read_A_Enable = ~wRF_Read_A_Bypass;
 
  assign wRF_Read_B_Bypass = ( iIMEM_IF_Instruction[`DEF_CP_INS_SRC2_END_BIT] && iIMEM_IF_Instruction[`DEF_CP_INS_SRC2_END_BIT-1] && iIMEM_IF_Instruction[`DEF_CP_INS_SRC2_END_BIT-2] );
  assign wRF_Read_B_Enable = ~wRF_Read_B_Bypass;
  
  // Read port A
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
  		rPR_ID_RF_Read_Addr_A <= 'b0;
    else if ( wRF_Read_A_Enable )
  		rPR_ID_RF_Read_Addr_A <= iIMEM_IF_Instruction[`DEF_CP_INS_SRC1_END_BIT:`DEF_CP_INS_SRC1_START_BIT];
  // end of always		
 
  // Read port B
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
  		rPR_ID_RF_Read_Addr_B <= 'b0;
    else if ( wRF_Read_B_Enable )
  	  rPR_ID_RF_Read_Addr_B <= iIMEM_IF_Instruction[`DEF_CP_INS_SRC2_END_BIT:`DEF_CP_INS_SRC2_START_BIT];
  // end of always


  // ===============================
  //  Bypass selection A & B 
  // ===============================
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
  		  rPR_ID_BP_Bypass_Read_A <= 'b0;
  		  rPR_ID_BP_Bypass_Read_B <= 'b0;
  		end
    else
      begin
  		  rPR_ID_BP_Bypass_Read_A <= wRF_Read_A_Bypass;
  		  rPR_ID_BP_Bypass_Read_B <= wRF_Read_B_Bypass;
  		end
  // end of always
  
  // Bypass selection port A
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
  		rPR_ID_BP_Bypass_Sel_A <= 'b0;
    else if ( wRF_Read_A_Bypass )
  		rPR_ID_BP_Bypass_Sel_A <= iIMEM_IF_Instruction[(`DEF_CP_INS_SRC1_START_BIT+1):`DEF_CP_INS_SRC1_START_BIT];
  // end of always	
    
  // Bypass selection port B
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
  		rPR_ID_BP_Bypass_Sel_B <= 'b0;
    else if ( wRF_Read_B_Bypass )
  		rPR_ID_BP_Bypass_Sel_B <= iIMEM_IF_Instruction[(`DEF_CP_INS_SRC2_START_BIT+1):`DEF_CP_INS_SRC2_START_BIT];
  // end of always	
  
  // ======================================
  // the immediate select signal: indicate
  // that the second operand is immediate
  // ======================================
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
  		rPR_ID_Select_Imm <= 1'b0;
  	else
  	  begin
  	    case ( iIMEM_IF_Instruction[`DEF_CP_INS_TYPE_BIT] )
  	      // I-Type:  // Note that Load/Store instructions require immediate value, and they belong to I-type
  	      `DEF_CP_INS_IS_I_TYPE:
  	        rPR_ID_Select_Imm <= 1'b1;
  	      
  	      // R-Type & J-Type                            // JR & JALR do NOT need immediate!!!
  	      `DEF_CP_INS_IS_R_TYPE:                           // ins[18]                              // ins[17]
  	        // Note that the imm of J-Type is handled separately
  	        //rPR_ID_Select_Imm <= ( wIs_J_Type && ( iIMEM_IF_Instruction[(`DEF_CP_INS_WIDTH-6)] ^ iIMEM_IF_Instruction[(`DEF_CP_INS_WIDTH-7)] ) );
            rPR_ID_Select_Imm <= 1'b0;
  	      default: 
  	        rPR_ID_Select_Imm <= 1'b0;
  	          	    
  	    endcase
  	  end
  // end of always
 
 
  // =========================================
  //  determine the type of branch operation 
  // =========================================
  assign wIs_J_Type = (iIMEM_IF_Instruction[(`DEF_CP_INS_WIDTH-1):(`DEF_CP_INS_WIDTH-5)] == 5'b0);
  
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
  		rPR_ID_Branch_Op <= `RISC24_CP_BRANCHOP_NOP;
  	else if ( wIs_J_Type )
  		rPR_ID_Branch_Op <= iIMEM_IF_Instruction[(`DEF_CP_INS_WIDTH-6):(`DEF_CP_INS_WIDTH-8)];
  	else
  	  rPR_ID_Branch_Op <= `RISC24_CP_BRANCHOP_NOP;
  // end of always
    


//*********************
//  Output Assignment
//*********************
  // IF to IMEM
  assign oIF_IMEM_Addr      = wCurrent_IMEM_Addr;
  
  // IF to ID
  assign oIF_ID_PC          = rPR_ID_PC;
  assign oIF_ID_Instruction = rPR_ID_Instruction;
  assign oIF_ID_Branch_Op   = rPR_ID_Branch_Op;
  
  assign oSelect_First_PE   = rSelect_First_PE;
  assign oSelect_Last_PE    = rSelect_Last_PE;
  
  assign oPredication       = rPR_ID_Predication;
  
  assign oIF_RF_Read_Addr_A = rPR_ID_RF_Read_Addr_A;
  assign oIF_RF_Read_Addr_B = rPR_ID_RF_Read_Addr_B;
  
  assign oIF_BP_Select_Imm    = rPR_ID_Select_Imm; 
  assign oIF_BP_Bypass_Read_A = rPR_ID_BP_Bypass_Read_A;
  assign oIF_BP_Bypass_Read_B = rPR_ID_BP_Bypass_Read_B;
  assign oIF_BP_Bypass_Sel_A  = rPR_ID_BP_Bypass_Sel_A; 
  assign oIF_BP_Bypass_Sel_B  = rPR_ID_BP_Bypass_Sel_B; 
  

endmodule