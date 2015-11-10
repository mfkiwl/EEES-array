////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//    Module Name :  pe_bypass                                                //
//    Description :  This is the bypass network for the RF write-back data.   //
//                                                                            //
//    Author(s)   :  Yifan He                                                 //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

`include "def-pe.v"

// synopsys translate_off
`timescale 1ns / 1ps
// synopsys translate_on


module pe_bypass (
  // from WB stage
  iWB_RF_Write_Addr,                 // RF write address
  iWB_RF_Write_Data,                 // RF write data
                                                             
  // from IF stage  
  iIF_RF_Read_Addr_A,                // RF read port A address
  iIF_RF_Read_Addr_B,                // RF read port B address
  iIF_BP_Select_Imm,                 // indicate that the second operand is from immediate value
  iIF_BP_Bypass_Read_A,              // flag that indicate RF read port A bypassed  
  iIF_BP_Bypass_Read_B,              // flag that indicate RF read port B bypassed 
  iIF_BP_Bypass_Sel_A,               // port A bypass source selection 
  iIF_BP_Bypass_Sel_B,               // port B bypass source selection
    
  // from/to ID stage
  iID_BP_Immediate,                  // sign-extended (to 32bit) immediate
  iID_BP_Is_SUB,                     // current ins. is SUB
  oBP_ID_Operand_A,                  // operand A
  oBP_ID_Operand_B,                  // operand B
  oBP_ID_LSU_Store_Data,             // store data (for store instruction only)
  
  // from Regiser File
  iRF_BP_Read_Data_A,                // RF read data from port A
  iRF_BP_Read_Data_B,                // RF read data from port B  
  
  iEX_BP_ALU_Result,                 // bypass src from ALU (and LR)
  iEX_BP_MUL_Result,                 // bypass src from MUL
  iEX_BP_LSU_Result,                 // bypass src from LSU
  iEX_BP_Shadow_Result,              // bypass src from shadow register (R31)
  
  // from/to neighbourhood
  iData_Selection,                   // data selection bits
  iLeft_PE_Port1_Data,               // data from left PE 
  iLeft_PE_Port1_Minus4_Data,        // data from left-4 PE
  iRight_PE_Port1_Data,              // data from right PE
  iRight_PE_Port1_Plus4_Data,        // data from rigtt+4 PE
  iCP_Data,                          // data from cp
  oPE_Port1_Data                     // data to left/right PE  
);

//******************************
//  Local Parameter Definition
//******************************



//****************************
//  Input/Output Declaration
//****************************
  // from WB stage
  input  [(`DEF_RF_INDEX_WIDTH-1):0] iWB_RF_Write_Addr;      // RF write address
  input  [(`DEF_PE_DATA_WIDTH-1):0]  iWB_RF_Write_Data;      // RF write data

  // from IF stage
  input  [(`DEF_RF_INDEX_WIDTH-1):0] iIF_RF_Read_Addr_A;     // RF read port A address
  input  [(`DEF_RF_INDEX_WIDTH-1):0] iIF_RF_Read_Addr_B;     // RF read port B address
  input                              iIF_BP_Select_Imm;      // indicate that the second operand is from immediate value
  input                              iIF_BP_Bypass_Read_A;   // flag that indicate RF read port A bypassed  
  input                              iIF_BP_Bypass_Read_B;   // flag that indicate RF read port B bypassed 
  input  [1:0]                       iIF_BP_Bypass_Sel_A;    // port A bypass source selection 
  input  [1:0]                       iIF_BP_Bypass_Sel_B;    // port B bypass source selection 
  
  // from/to ID stage
  input  [(`DEF_PE_DATA_WIDTH-1):0]  iID_BP_Immediate;       // sign-extended (to 32bit) immediate
  input                              iID_BP_Is_SUB;
  
  output [(`DEF_PE_DATA_WIDTH-1):0]  oBP_ID_Operand_A;       // operand A
  output [(`DEF_PE_DATA_WIDTH-1):0]  oBP_ID_Operand_B;       // operand B
  output [(`DEF_PE_DATA_WIDTH-1):0]  oBP_ID_LSU_Store_Data;  // store data (for store instruction only)


  // from Regiser File
  input  [(`DEF_PE_DATA_WIDTH-1):0]  iRF_BP_Read_Data_A;     // RF read data from port A
  input  [(`DEF_PE_DATA_WIDTH-1):0]  iRF_BP_Read_Data_B;     // RF read data from port B

  // from EX stage
  input  [(`DEF_PE_DATA_WIDTH-1):0]  iEX_BP_ALU_Result;      // bypass src from ALU (and LR)
  input  [(`DEF_PE_DATA_WIDTH-1):0]  iEX_BP_MUL_Result;      // bypass src from MUL
  input  [(`DEF_PE_DATA_WIDTH-1):0]  iEX_BP_LSU_Result;      // bypass src from LSU
  input  [(`DEF_PE_DATA_WIDTH-1):0]  iEX_BP_Shadow_Result;   // bypass src from shadow register (R31)
  
  // from/to neighbourhood
  input  [2:0]                       iData_Selection;        // data selection bits
  
  input  [(`DEF_PE_DATA_WIDTH-1):0]  iLeft_PE_Port1_Data;    // data from left PE 
  input  [(`DEF_PE_DATA_WIDTH-1):0]  iLeft_PE_Port1_Minus4_Data; //data from left-4 PE
  input  [(`DEF_PE_DATA_WIDTH-1):0]  iRight_PE_Port1_Data;   // data from right PE
  input  [(`DEF_PE_DATA_WIDTH-1):0]  iRight_PE_Port1_Plus4_Data; // data from right+4 PE
  input  [(`DEF_PE_DATA_WIDTH-1):0]  iCP_Data;               // data from cp
  output [(`DEF_PE_DATA_WIDTH-1):0]  oPE_Port1_Data;         // data to left/right PE
  

//******************************
//  Local Wire/Reg Declaration
//******************************

  reg  [(`DEF_PE_DATA_WIDTH-1):0]    rOperand_A;             // operand A (after only bypass selection)   
  reg  [(`DEF_PE_DATA_WIDTH-1):0]    rOperand_A_with_Neighbour; // operand A (after also neighbourhood selection)
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]    rOperand_B_Bypass;      // operand B (after only bypass selection )
  reg  [(`DEF_PE_DATA_WIDTH-1):0]    rOperand_B;             // operand B (after also immediate selection )
  
  reg  [(`DEF_PE_DATA_WIDTH-1):0]    rOperand_A_switched;    // switch Operand A & B for RSUBI inst
  reg  [(`DEF_PE_DATA_WIDTH-1):0]    rOperand_B_switched;    // switch Operand A & B for RSUBI inst


//******************************
//  Behavioral Description
//******************************
  
  // ========================================
  //  bypass network for the write-back data
  // ========================================
  // RF read data A (bypass network for RF A)
  always @ ( iIF_BP_Bypass_Read_A or iIF_BP_Bypass_Sel_A or iRF_BP_Read_Data_A or
             iEX_BP_ALU_Result or iEX_BP_MUL_Result or iEX_BP_LSU_Result or iEX_BP_Shadow_Result or
             iIF_RF_Read_Addr_A or iWB_RF_Write_Addr or iWB_RF_Write_Data )
    if ( iIF_BP_Bypass_Read_A )           // bypassed 
        begin
          case ( iIF_BP_Bypass_Sel_A )
            `RISC24_BYPASS_SRC_ALU:
              rOperand_A = iEX_BP_ALU_Result;
            `RISC24_BYPASS_SRC_MUL:
              rOperand_A = iEX_BP_MUL_Result;
            `RISC24_BYPASS_SRC_LSU:
              rOperand_A = iEX_BP_LSU_Result;
            `RISC24_BYPASS_SRC_SHADOW:
              rOperand_A = iEX_BP_Shadow_Result;
            default:
              rOperand_A = iEX_BP_ALU_Result;
          endcase
        end      // if read address is equal to current/previous write address, use the data in the wb stage (except r0, r1)
    else if ( (iIF_RF_Read_Addr_A == iWB_RF_Write_Addr) && (iIF_RF_Read_Addr_A > 5'b1) )  // RF internal bypass (bypass from RF write port)
      rOperand_A = iWB_RF_Write_Data;                    // this removed the joint-point issue in the WB stage,
    else                                                 // only EX stage (thus, 1-cycle only) has joint-point issue
      rOperand_A = iRF_BP_Read_Data_A;
  // end of always  
        
  
  // rOperand_A_with_Neighbour: select between self and neighbourhood data      
  always @ ( iData_Selection or rOperand_A or iCP_Data or
             iLeft_PE_Port1_Data or iRight_PE_Port1_Data )
    case ( iData_Selection )
      3'b010:   rOperand_A_with_Neighbour = iLeft_PE_Port1_Data;
      3'b001:   rOperand_A_with_Neighbour = iRight_PE_Port1_Data;
      3'b011:   rOperand_A_with_Neighbour = iCP_Data;
      3'b110:   rOperand_A_with_Neighbour = iLeft_PE_Port1_Minus4_Data;  
      3'b101:   rOperand_A_with_Neighbour = iRight_PE_Port1_Plus4_Data;
      default: rOperand_A_with_Neighbour = rOperand_A;
    endcase
  // end of always
        
        
        
  // RF read data B (bypass network for RF B)
  always @ ( iIF_BP_Bypass_Read_B or iIF_BP_Bypass_Sel_B or iRF_BP_Read_Data_B or
             iEX_BP_ALU_Result or iEX_BP_MUL_Result or iEX_BP_LSU_Result or iEX_BP_Shadow_Result or
             iIF_RF_Read_Addr_B or iWB_RF_Write_Addr or iWB_RF_Write_Data )
    if ( iIF_BP_Bypass_Read_B )           // bypassed 
        begin
          case ( iIF_BP_Bypass_Sel_B )
            `RISC24_BYPASS_SRC_ALU:
              rOperand_B_Bypass = iEX_BP_ALU_Result;
            `RISC24_BYPASS_SRC_MUL:
              rOperand_B_Bypass = iEX_BP_MUL_Result;
            `RISC24_BYPASS_SRC_LSU:
              rOperand_B_Bypass = iEX_BP_LSU_Result;
            `RISC24_BYPASS_SRC_SHADOW:
              rOperand_B_Bypass = iEX_BP_Shadow_Result;
            default:
              rOperand_B_Bypass = iEX_BP_ALU_Result;
          endcase
        end
    else if ( (iIF_RF_Read_Addr_B == iWB_RF_Write_Addr) && (iIF_RF_Read_Addr_B > 5'b1) )  // RF internal bypass (bypass from RF write port)
      rOperand_B_Bypass = iWB_RF_Write_Data;             // this removed the joint-point issue in the WB stage, only EX stage (thus, 1-cycle only) has joint-point issue
    else
      rOperand_B_Bypass = iRF_BP_Read_Data_B;
  // end of always


  // Operand B: select between immediate value and the RF value
  always @ ( rOperand_B_Bypass or iIF_BP_Select_Imm or iID_BP_Immediate )
    if ( iIF_BP_Select_Imm )      // data from immediate value
      rOperand_B = iID_BP_Immediate; 
    else
      rOperand_B = rOperand_B_Bypass;
  // end of always


  // for RSUBI, switch operand A & B
  always @ ( rOperand_A_with_Neighbour or rOperand_B or iID_BP_Is_SUB or iIF_BP_Select_Imm )
    if ( iID_BP_Is_SUB && iIF_BP_Select_Imm ) // is RSUBI
      begin
        rOperand_A_switched = rOperand_B;
        rOperand_B_switched = rOperand_A_with_Neighbour;
      end
    else
      begin
        rOperand_A_switched = rOperand_A_with_Neighbour;
        rOperand_B_switched = rOperand_B;
      end
  // end of always



//*********************
//  Output Assignment
//*********************
  
  // to ID stage
  assign oBP_ID_Operand_A      = rOperand_A_switched;
  assign oBP_ID_Operand_B      = rOperand_B_switched;
  assign oBP_ID_LSU_Store_Data = rOperand_B_Bypass; 

  // to neighbourhood PE
  assign oPE_Port1_Data        = rOperand_A;


endmodule