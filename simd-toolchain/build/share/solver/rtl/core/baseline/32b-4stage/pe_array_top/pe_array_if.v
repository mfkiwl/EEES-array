////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//    Module Name :  pe_array_if                                              //
//    Description :  Instruction Fetch (IF) stage of the PE array.            //
//                                                                            //
//    Author(s)   :  Yifan He                                                 //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

`include "def-pe.v"

// synopsys translate_off
`timescale 1ns / 1ps
// synopsys translate_on



module pe_array_if (      
  iClk,                              // system clock, positive-edge trigger
  iReset,                            // global synchronous reset signal, Active high
  
  // from/to ID stage
  oIF_ID_Instruction,                // IF stage to ID stage instruction
  oPredication,                      // IF-ID predication bits
  
  // to RF read ports
  oIF_RF_Read_Addr_A,                // RF read port A address
  oIF_RF_Read_Addr_B,                // RF read port B address
  
  // to bypass
  oIF_BP_Select_Imm,                 // indicate that the second operand is from immediate value
  oIF_BP_Data_Selection,             // data selection bits 
  
  // predication
  iPredication,                      // cp predication bits
   
  // from instruction memory
  iData_Selection,                   // data selection bits
  iIMEM_IF_Instruction               // instruction fetched from instruction memory
);

//******************************
//  Local Parameter Definition
//******************************



//****************************
//  Input/Output Declaration
//****************************

  input                                   iClk;                              // system clock, positive-edge trigger
  input                                   iReset;                            // global synchronous reset signal, Active high
                                                  
  // from/to ID stage
  output [(`DEF_PE_INS_WIDTH-1):0]        oIF_ID_Instruction;                // IF stage to ID stage instruction  
  output [1:0]                            oPredication;                      // IF-ID predication bits
  
  output [(`DEF_RF_INDEX_WIDTH-1):0]      oIF_RF_Read_Addr_A;                // RF read port A address
  output [(`DEF_RF_INDEX_WIDTH-1):0]      oIF_RF_Read_Addr_B;                // RF read port B address
  
  output                                  oIF_BP_Select_Imm;                 // indicate that the second operand is from immediate value
  
  output [1:0]                            oIF_BP_Data_Selection;             // data selection bits 
 
  // predication
  input  [1:0]                            iPredication;
  
  // from/to instruction memory
  input  [1:0]                            iData_Selection;                   // data selection bits
  input  [(`DEF_PE_INS_WIDTH-1):0]        iIMEM_IF_Instruction;              // instruction fetched from instruction memory
  


//******************************
//  Local Wire/Reg Declaration
//******************************
  
  // pipeline registers
  reg  [(`DEF_PE_INS_WIDTH-1):0]          rPR_ID_Instruction;                // instruction
  reg  [1:0]                              rPR_ID_Data_Selection;             // data selection bits 
  reg  [1:0]                              rPR_ID_Predication;                // IF_ID predication bits
  
  reg  [(`DEF_RF_INDEX_WIDTH-1):0]        rPR_ID_RF_Read_Addr_A;             // RF read port A address
  reg  [(`DEF_RF_INDEX_WIDTH-1):0]        rPR_ID_RF_Read_Addr_B;             // RF read port B address
  reg                                     rPR_ID_Select_Imm;                 // indicate that the second operand is from immediate value


//******************************
//  Behavioral Description
//******************************
  // =========================
  //  instruction to ID stage
  // =========================
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
      begin
        rPR_ID_Instruction    <= 'b0; 
        rPR_ID_Data_Selection <= 'b0;
        rPR_ID_Predication    <= 'b0; 
      end
    else
      begin
        rPR_ID_Instruction    <= iIMEM_IF_Instruction; 
        rPR_ID_Data_Selection <= iData_Selection;
        rPR_ID_Predication    <= iPredication;
      end
  // end of always  


  // ===============================
  // Register File read port A & B 
  // ===============================
  
  // Read port A
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
        rPR_ID_RF_Read_Addr_A <= 'b0;
    else
        rPR_ID_RF_Read_Addr_A <= iIMEM_IF_Instruction[`DEF_INS_SRC1_END_BIT:`DEF_INS_SRC1_START_BIT];
  // end of always      
 
  // Read port B
  always @ ( posedge iClk )
    if ( iReset == 1'b1 )
        rPR_ID_RF_Read_Addr_B <= 'b0;
    else
      rPR_ID_RF_Read_Addr_B <= iIMEM_IF_Instruction[`DEF_INS_SRC2_END_BIT:`DEF_INS_SRC2_START_BIT];
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
        case ( iIMEM_IF_Instruction[`DEF_INS_TYPE_BIT] )
          // I-Type:  // Note that Load/Store instructions require immediate value, and they belong to I-type
          `DEF_INS_IS_I_TYPE:
            rPR_ID_Select_Imm <= 1'b1;
          
          // R-Type & J-Type                            // JR & JALR do NOT need immediate!!!
          `DEF_INS_IS_R_TYPE:                           // ins[18]                              // ins[17]
            // Note that the imm of J-Type is handled separately
            //rPR_ID_Select_Imm <= ( wIs_J_Type && ( iIMEM_IF_Instruction[(`DEF_PE_INS_WIDTH-6)] ^ iIMEM_IF_Instruction[(`DEF_PE_INS_WIDTH-7)] ) );
            rPR_ID_Select_Imm <= 1'b0;
          default: 
            rPR_ID_Select_Imm <= 1'b0;
        endcase
      end
  // end of always


//*********************
//  Output Assignment
//*********************
  // IF to ID
  assign oIF_ID_Instruction    = rPR_ID_Instruction;
  
  assign oIF_RF_Read_Addr_A    = rPR_ID_RF_Read_Addr_A;
  assign oIF_RF_Read_Addr_B    = rPR_ID_RF_Read_Addr_B;
  
  assign oPredication          = rPR_ID_Predication;
  
  assign oIF_BP_Select_Imm     = rPR_ID_Select_Imm; 

  assign oIF_BP_Data_Selection = rPR_ID_Data_Selection;
  

endmodule
