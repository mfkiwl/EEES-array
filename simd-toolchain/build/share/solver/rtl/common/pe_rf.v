////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//    Module Name :  pe_rf                                                    //
//    Description :  This is the register file for PE. Depending on the       //
//                   target, it use either flip-flops (generic) or look-up    //
//                   table (FPGA).                                            //
//                                                                            //
//    Author(s)   :  Yifan He                                                 //
//                   Dongrui She                                              //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

`include "def-pe.v"

// synopsys translate_off
`timescale 1ns / 1ps
// synopsys translate_on

module pe_rf #(
  parameter Para_PE_ID = 32'h0
  ) (
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
   input [`DEF_RF_INDEX_WIDTH-1:0] iIF_RF_Read_Addr_A;  // Read address A
   input [`DEF_RF_INDEX_WIDTH-1:0] iIF_RF_Read_Addr_B;  // Read address B
   output [`DEF_PE_DATA_WIDTH-1:0] oRF_BP_Read_Data_A;  // Read data A
   output [`DEF_PE_DATA_WIDTH-1:0] oRF_BP_Read_Data_B;  // Read data B
   // from WB stage
   input [`DEF_RF_INDEX_WIDTH-1:0] iWB_RF_Write_Addr;   // Write address
   input [`DEF_PE_DATA_WIDTH-1:0]  iWB_RF_Write_Data;   // Write data
   input                           iWB_RF_Write_Enable; // Write enable
//******************************
//  Local Wire/Reg Declaration
//******************************
  {% if target=='xilinx' %}
   wire [`DEF_PE_DATA_WIDTH-1:0] wRF_Read_Data_A; // Read data A
   wire [`DEF_PE_DATA_WIDTH-1:0] wRF_Read_Data_B; // Read data B
   wire                          wRF_Write_En;

  assign wRF_Write_En = iWB_RF_Write_Enable && ( iWB_RF_Write_Addr[4:1] != 4'b0 );

  {% for i in range(cfg.pe.datapath['data_width']//2) %}
  RAM32M #(
      .INIT_A( {60'b0, Para_PE_ID[{{i}}*2+1:{{i}}*2], 2'b0} ),  // Initial contents of A Port
      .INIT_B( {60'b0, Para_PE_ID[{{i}}*2+1:{{i}}*2], 2'b0} ),  // Initial contents of B Port
      .INIT_C( {60'b0, Para_PE_ID[{{i}}*2+1:{{i}}*2], 2'b0} ),  // Initial contents of C Port
      .INIT_D( {60'b0, Para_PE_ID[{{i}}*2+1:{{i}}*2], 2'b0} )   // Initial contents of D Port
   ) RF_inst{{i}} (
      .DOA  (wRF_Read_Data_A[{{2*i+1}}:{{2*i}}]),// Read port A 2-bit output
      .DOB  (wRF_Read_Data_B[{{2*i+1}}:{{2*i}}]),// Read port B 2-bit output
      .DOC  (),                       // Read port C 2-bit output
      .DOD  (),                       // Readw/rite port D 2-bit output
      
      .ADDRA(iIF_RF_Read_Addr_A),     // Read port A 5-bit address input
      .ADDRB(iIF_RF_Read_Addr_B),     // Read port B 5-bit address input
      .ADDRC(5'b0),                   // Read port C 5-bit address input
      .ADDRD(iWB_RF_Write_Addr),      // Readw/rite port D 5-bit address input
      
      .DIA  (iWB_RF_Write_Data[{{2*i+1}}:{{2*i}}]), // RAM 2-bit data write input
      .DIB  (iWB_RF_Write_Data[{{2*i+1}}:{{2*i}}]), // RAM 2-bit data write input
      .DIC  (iWB_RF_Write_Data[{{2*i+1}}:{{2*i}}]), // RAM 2-bit data write input
      .DID  (iWB_RF_Write_Data[{{2*i+1}}:{{2*i}}]), // RAM 2-bit data write input

      .WCLK (iClk),    // Write clock input
      .WE   (wRF_Write_En)     // Write enable input
   );
  {% endfor %}
  //*********************
  //  Output Assignment
  //*********************
  assign oRF_BP_Read_Data_A = wRF_Read_Data_A;
  assign oRF_BP_Read_Data_B = wRF_Read_Data_B;
  {%- else %}
   reg [`DEF_RF_DEPTH*`DEF_PE_DATA_WIDTH-1:0] rRegister_File_Memory;
   reg [`DEF_PE_DATA_WIDTH-1:0]               rID_RF_Read_Data_A;
   reg [`DEF_PE_DATA_WIDTH-1:0]               rID_RF_Read_Data_B;
//******************************
//  Behavioral Description
//******************************
  // ===========
  // Write port
  // ===========
  always @ ( posedge iClk )
    if ( iWB_RF_Write_Enable )
      case ( iWB_RF_Write_Addr )
        {% for i in range(2, cfg.pe.rf_num_entries()) -%}
        {{cfg.pe.rf_id_width()}}'d{{i}}: rRegister_File_Memory[{{cfg.pe.datapath['data_width']}}*{{i+1}}-1:{{cfg.pe.datapath['data_width']}}*{{i}}] <= iWB_RF_Write_Data;
        {% endfor -%}
        default: rRegister_File_Memory[{{cfg.pe.datapath['data_width']-1}}:0] <= {{cfg.pe.datapath['data_width']}}'h0;
      endcase
  // end of always  
  // ============
  // Read port A
  // ============  
  always @ ( rRegister_File_Memory or iIF_RF_Read_Addr_A )
    case ( iIF_RF_Read_Addr_A ) // synopsys parallel_case
      {{cfg.pe.rf_id_width()}}'d1: rID_RF_Read_Data_A = Para_PE_ID;
      {% for i in range(2, cfg.pe.rf_num_entries()) -%}
      {{cfg.pe.rf_id_width()}}'d{{i}}: rID_RF_Read_Data_A = rRegister_File_Memory[{{cfg.pe.datapath['data_width']}}*{{i+1}}-1:{{cfg.pe.datapath['data_width']}}*{{i}}];
      {% endfor -%}    
      default: rID_RF_Read_Data_A = {{cfg.pe.datapath['data_width']}}'h0;
    endcase
  // end of always  
  // ============
  // Read port B
  // ============
  always @ ( rRegister_File_Memory or iIF_RF_Read_Addr_B )
    case ( iIF_RF_Read_Addr_B ) // synopsys parallel_case
      {{cfg.pe.rf_id_width()}}'d1: rID_RF_Read_Data_B = Para_PE_ID;
      {% for i in range(2, cfg.pe.rf_num_entries()) -%}
      {{cfg.pe.rf_id_width()}}'d{{i}}: rID_RF_Read_Data_B = rRegister_File_Memory[{{cfg.pe.datapath['data_width']}}*{{i+1}}-1:{{cfg.pe.datapath['data_width']}}*{{i}}];
      {% endfor -%}    
      default: rID_RF_Read_Data_B = {{cfg.pe.datapath['data_width']}}'h0;
    endcase
  // end of always
  //*********************
  //  Output Assignment
  //*********************
  assign oRF_BP_Read_Data_A = rID_RF_Read_Data_A;
  assign oRF_BP_Read_Data_B = rID_RF_Read_Data_B;
  {%- endif %}
endmodule
