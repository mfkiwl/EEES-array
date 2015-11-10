////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//    Module Name :  my_isolation                                             //
//    Description :  This is the signal isolation unit.                       //
//                                                                            //
//    Author(s)   :  Yifan He                                                 //
//                   Dongrui She                                              //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

// synopsys translate_off
`timescale 1ns / 1ps
// synopsys translate_on

module my_isolation #(
  parameter ISOLATION_DATA_WIDTH = 32
) (
  iData_In,
  iIsolation_Signal,

  oIsolated_Out
);

//****************************
//  Input/Output Declaration
//****************************
  input   [(ISOLATION_DATA_WIDTH-1):0] iData_In;
  input                                iIsolation_Signal;

  output  [(ISOLATION_DATA_WIDTH-1):0] oIsolated_Out;

  // Isolate operand if target is not FPGA
  assign oIsolated_Out = ( iData_In & { ISOLATION_DATA_WIDTH{iIsolation_Signal} } );
  

endmodule
