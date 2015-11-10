////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//    Module Name :  simd_top_testbench                                       //
//    Description :  Template for the testbench for the SIMD processor.       //
//                                                                            //
//    Author(s)   :  Yifan He                                                 //
//                   Dongrui She                                              //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

`include "def-cp.v"
`include "def-pe.v"

`include "def-testbench.v"

// synopsys translate_off
`timescale 1ns / 1ps
// synopsys translate_on

module simd_top_testbench;

//******************************
//  Local Wire/Reg Declaration
//******************************

  reg                                   rClk;   // system clock, p-edge trigger
  reg                                   rReset; // global sync-reset, cctive low

  wire [(`DEF_CP_I_MEM_ADDR_WIDTH-3):0] wPC;      // PC to indicate the end of the program
  reg  [(`DEF_CP_I_MEM_ADDR_WIDTH-3):0] rLast_PC; // buffered last PC
  wire                                  wTask_Finished; // self-jump, indicate the end of the program

  // instruction memory
  reg  [31:0]                           CP_IMEM_Init[0:(`DEF_CP_IMEM_SIZE-1)];
  reg  [31:0]                           PE_IMEM_Init[0:(`DEF_PE_IMEM_SIZE-1)];

  reg                                   rBus_IMEM_Valid;       // ins. memory access valid
  reg  [(`DEF_CP_I_MEM_ADDR_WIDTH-3):0] rBus_IMEM_Address;     // ins. memory access address
  reg  [(`DEF_CP_I_MEM_ADDR_WIDTH-3):0] rBus_IMEM_Address_Next;// NEXT ins. memory access address
  reg  [63:0]                           rBus_IMEM_Write_Data;  // ins. memory write data
  reg                                   rBus_IMEM_Write_Enable;// ins. memory write enable

  wire [(`DEF_CP_INS_WIDTH+3):0]        wBus_CP_IMEM_Read_Data;// cp ins. memory read data
  wire [(`DEF_PE_INS_WIDTH+4):0]        wBus_PE_IMEM_Read_Data;// pe ins. memory read data


  // data memory
  // CP
  reg  [(`DEF_CP_DATA_WIDTH-1):0]       CP_DMEM_Init[0:(`DEF_CP_DMEM_SIZE-1)];       // CP data memory
  reg  [(`DEF_CP_DATA_WIDTH-1):0]       CP_DMEM_tmp[0:(`DEF_CP_DMEM_SIZE-1)];        // tempory buffer for dumping cp memory data
  reg  [(`DEF_CP_DATA_WIDTH-1):0]       rCP_DMEM_Reference[0:(`DEF_CP_DMEM_SIZE-1)]; // CP reference data memory (for debug only)

  reg                                   rBus_CP_DMEM_Valid;                       // cp data memory access valid
  reg  [(`DEF_CP_D_MEM_ADDR_WIDTH-3):0] rBus_CP_DMEM_Address;                     // cp data memory access address
  reg  [(`DEF_CP_D_MEM_ADDR_WIDTH-3):0] rBus_CP_DMEM_Address_Next;                // NEXT data memory access address
  reg  [(`DEF_CP_DATA_WIDTH-1):0]       rBus_CP_DMEM_Write_Data;                  // cp data memory write data
  reg                                   rBus_CP_DMEM_Write_Enable;                // cp data memory write enable
  wire [(`DEF_CP_DATA_WIDTH-1):0]       wBus_CP_DMEM_Read_Data;                   // cp data memory read data

  // PE
  reg  [(`DEF_PE_DATA_WIDTH-1):0]       PE_DMEM_Init[0:(`DEF_PE_DMEM_SIZE*`DEF_PE_NUM-1)]; // PE data memory init
  reg  [(`DEF_PE_DATA_WIDTH-1):0]       PE_DMEM_tmp[0:(`DEF_PE_DMEM_SIZE-1)];     // tempory buffer for dumping cp memory data

  reg                                   rBus_PE_DMEM_Valid;                      // pe data memory access valid
  reg  [(`DEF_PE_D_MEM_ADDR_WIDTH-3):0] rBus_PE_DMEM_Address;                    // pe data memory access address
  reg  [(`DEF_PE_D_MEM_ADDR_WIDTH-3):0] rBus_PE_DMEM_Address_Next;               // NEXT data memory access address
  reg  [(`DEF_PE_DATA_WIDTH*`DEF_PE_NUM-1):0] rBus_PE_DMEM_Write_Data;           // pe data memory write data
  reg                                   rBus_PE_DMEM_Write_Enable;               // pe data memory write enable
  wire [(`DEF_PE_DATA_WIDTH*`DEF_PE_NUM-1):0] wBus_PE_DMEM_Read_Data;            // pe data memory read data

  // control signals
  reg                                   rProgram_Finish;                // is the last instruction

  reg [31:0]                            rTest_Counter;                  // data counter for debug
  reg [2:0]                             rPlace_Holder;

  wire                                  wCore_Reset;                    // core reset signal

  reg                                   rIMEM_Configure_Done;           // IMEM initialization done
  reg                                   rCP_DMEM_Configure_Done;        // CP DMEM initialization done
  reg                                   rPE_DMEM_Configure_Done;        // PE DMEM initialization done

  integer                               i;


//******************************
//  Behavioral Description
//******************************
  // ========
  //  clock
  // ========
  always #(`CYCLE_TIME/2.0) rClk = ~rClk;


  // =====================
  //  instruction memory
  // =====================
  // configure imem (cp + pe)
  always @ ( posedge rClk )
    if ( rReset == 1'b0 )
      rIMEM_Configure_Done <= 1'b0;
    else if ( rBus_IMEM_Address == (`DEF_CP_IMEM_SIZE - 2) )
      rIMEM_Configure_Done <= 1'b1;
  // end of always

  always @ ( posedge rClk )
    if ( rReset == 1'b0 ) begin
      rBus_IMEM_Valid        <= 'b0;
      rBus_IMEM_Address      <= 'b0;
      rBus_IMEM_Address_Next <= 'b0;
      rBus_IMEM_Write_Data   <= 'b0;
      rBus_IMEM_Write_Enable <= 'b0;
    end
    else if ( rIMEM_Configure_Done == 1'b0 ) begin   // not configured yet
      rBus_IMEM_Valid        <= 'b1;
      rBus_IMEM_Address_Next <= rBus_IMEM_Address_Next + 'b1;
      rBus_IMEM_Address      <= rBus_IMEM_Address_Next;
      rBus_IMEM_Write_Data   <= {PE_IMEM_Init[rBus_IMEM_Address_Next], CP_IMEM_Init[rBus_IMEM_Address_Next]};
      rBus_IMEM_Write_Enable <= 'b1;
    end
    else begin
      rBus_IMEM_Valid        <= 'b0;
    end
  // end of always


  // ================
  //  CP data memory
  // ================
  always @ ( posedge rClk )
    if ( rReset == 1'b0 )
      rCP_DMEM_Configure_Done <= 1'b0;
    else if ( rBus_CP_DMEM_Address == (`DEF_CP_DMEM_SIZE - 2) )
      rCP_DMEM_Configure_Done <= 1'b1;
  // end of always


  always @ ( posedge rClk )
    if ( rReset == 1'b0 ) begin
      rBus_CP_DMEM_Valid        <= 'b0;
      rBus_CP_DMEM_Address      <= 'b0;
      rBus_CP_DMEM_Address_Next <= 'b0;
      rBus_CP_DMEM_Write_Data   <= 'b0;
      rBus_CP_DMEM_Write_Enable <= 'b0;
    end
    else if ( rCP_DMEM_Configure_Done == 1'b0 ) begin   // not configured yet, configure the data memory
      rBus_CP_DMEM_Valid        <= 'b1;
      rBus_CP_DMEM_Address_Next <= rBus_CP_DMEM_Address_Next + 'b1;
      rBus_CP_DMEM_Address      <= rBus_CP_DMEM_Address_Next;
      rBus_CP_DMEM_Write_Data   <= CP_DMEM_Init[rBus_CP_DMEM_Address_Next];
      rBus_CP_DMEM_Write_Enable <= 'b1;
    end
    else begin
      rBus_CP_DMEM_Valid        <= 'b0;
      rBus_CP_DMEM_Address      <= 'b0;
      rBus_CP_DMEM_Address_Next <= 'b0;
      rBus_CP_DMEM_Write_Data   <= 'b0;
      rBus_CP_DMEM_Write_Enable <= 'b0;
    end
  // end of always



  // ================
  //  PE data memory
  // ================
  always @ ( posedge rClk )
    if ( rReset == 1'b0 ) begin
      rPE_DMEM_Configure_Done <= 1'b0;
    end
    else if ( rBus_PE_DMEM_Address == (`DEF_PE_DMEM_SIZE - 2) ) begin
      rPE_DMEM_Configure_Done <= 1'b1;
    end
  // end of always

  always @ ( posedge rClk )
    if ( rReset == 1'b0 ) begin
      rBus_PE_DMEM_Valid        <= 'b0;
      rBus_PE_DMEM_Address      <= 'b0;
      rBus_PE_DMEM_Address_Next <= 'b0;
      rBus_PE_DMEM_Write_Data   <= 'b0;
      rBus_PE_DMEM_Write_Enable <= 'b0;
    end
    else if ( rPE_DMEM_Configure_Done == 1'b0 ) begin   // not configured yet, configure the data memory
      rBus_PE_DMEM_Valid        <= 'b1;
      rBus_PE_DMEM_Address_Next <= rBus_PE_DMEM_Address_Next + 'b1;
      rBus_PE_DMEM_Address      <= rBus_PE_DMEM_Address_Next;
      //for( i = 0; i < `DEF_PE_NUM; i = i+1 ) begin
      //  rBus_PE_DMEM_Write_Data[(`DEF_PE_DATA_WIDTH*i-1):`DEF_PE_DATA_WIDTH*i] <= PE_DMEM_Init[rBus_PE_DMEM_Address_Next*`DEF_PE_NUM+i];
      //end
      rBus_PE_DMEM_Write_Data <= {
        PE_DMEM_Init[rBus_PE_DMEM_Address_Next*`DEF_PE_NUM+3],
        PE_DMEM_Init[rBus_PE_DMEM_Address_Next*`DEF_PE_NUM+2],
        PE_DMEM_Init[rBus_PE_DMEM_Address_Next*`DEF_PE_NUM+1],
        PE_DMEM_Init[rBus_PE_DMEM_Address_Next*`DEF_PE_NUM+0]
      };
      rBus_PE_DMEM_Write_Enable <= 'b1;
    end
    else begin
      rBus_PE_DMEM_Valid        <= 'b0;
      rBus_PE_DMEM_Address      <= 'b0;
      rBus_PE_DMEM_Address_Next <= 'b0;
      rBus_PE_DMEM_Write_Data   <= 'b0;
      rBus_PE_DMEM_Write_Enable <= 'b0;
    end
  // end of always


  // =====================
  // Last Ins. Detection
  // =====================
  always @ ( posedge rClk )
    if ( rReset == 1'b0 )
      rProgram_Finish <= 1'b0;
    else if ( wPC == (rLast_PC - 1) ) // finsh when jump to itself
      rProgram_Finish <= 1'b1;
  // end of always


  always @ ( posedge rClk )
    if ( rReset == 1'b0 )
      rLast_PC <= 'hAAAA;
    else begin
      rLast_PC <= wPC;
      if (wPC == 'h1)
        $stop;
    end
  // end of always



  // ===========
  //   Initial
  // ===========
   initial
     begin
       rClk = 0;
       rReset = 1;
       rTest_Counter = 0;
       rPlace_Holder = 0;

       // read memory initialization files
       $readmemh("cp.imem_init", CP_IMEM_Init);
       $readmemh("pe.imem_init", PE_IMEM_Init);
       $readmemh("cp.dmem_init", CP_DMEM_Init);
       $readmemh("pe.dmem_init", PE_DMEM_Init);

       #(`CYCLE_TIME * 10) rReset = 0; // 10 cycles;
       #(`CYCLE_TIME * 20) rReset = 1; // 20 cycles
       // test the interrupt signal
       while ( rProgram_Finish == 1'b0)
         @ ( posedge rClk );

       #(`CYCLE_TIME * 2)   // 2 cycles

       // dump cp data-memory
       for (i=0; i<`DEF_CP_DMEM_SIZE; i=i+1) begin
        CP_DMEM_tmp[i] = {inst_simd_top.inst_cp_dmem.dmem3[i], inst_simd_top.inst_cp_dmem.dmem2[i], inst_simd_top.inst_cp_dmem.dmem1[i], inst_simd_top.inst_cp_dmem.dmem0[i]
        };
       end

       $writememh("cp.dmem.dump", CP_DMEM_tmp);

       // dump pe data-memory
       for (i=0; i<`DEF_PE_DMEM_SIZE; i=i+1) begin
        PE_DMEM_tmp[i] = {inst_simd_top.inst_pe0_dmem.dmem3[i], inst_simd_top.inst_pe0_dmem.dmem2[i], inst_simd_top.inst_pe0_dmem.dmem1[i], inst_simd_top.inst_pe0_dmem.dmem0[i]
        };
       end

       $writememh("pe0.dmem.dump", PE_DMEM_tmp);

       for (i=0; i<`DEF_PE_DMEM_SIZE; i=i+1) begin
        PE_DMEM_tmp[i] = {inst_simd_top.inst_pe1_dmem.dmem3[i], inst_simd_top.inst_pe1_dmem.dmem2[i], inst_simd_top.inst_pe1_dmem.dmem1[i], inst_simd_top.inst_pe1_dmem.dmem0[i]
        };
       end

       $writememh("pe1.dmem.dump", PE_DMEM_tmp);

       for (i=0; i<`DEF_PE_DMEM_SIZE; i=i+1) begin
        PE_DMEM_tmp[i] = {inst_simd_top.inst_pe2_dmem.dmem3[i], inst_simd_top.inst_pe2_dmem.dmem2[i], inst_simd_top.inst_pe2_dmem.dmem1[i], inst_simd_top.inst_pe2_dmem.dmem0[i]
        };
       end

       $writememh("pe2.dmem.dump", PE_DMEM_tmp);

       for (i=0; i<`DEF_PE_DMEM_SIZE; i=i+1) begin
        PE_DMEM_tmp[i] = {inst_simd_top.inst_pe3_dmem.dmem3[i], inst_simd_top.inst_pe3_dmem.dmem2[i], inst_simd_top.inst_pe3_dmem.dmem1[i], inst_simd_top.inst_pe3_dmem.dmem0[i]
        };
       end

       $writememh("pe3.dmem.dump", PE_DMEM_tmp);

       
       $finish;
     end
  // end of initial

  // core reset: active high
  assign wCore_Reset = ~( rReset && rIMEM_Configure_Done && rCP_DMEM_Configure_Done && rPE_DMEM_Configure_Done );

  simd_top inst_simd_top (
    .iClk                          ( rClk                      ), // system clock, positive-edge trigger
    .iReset                        ( wCore_Reset               ), // global synchronous reset signal, Active high

    .oIF_ID_PC                     ( wPC                       ), // current PC for debug
    .oTask_Finished                ( wTask_Finished            ), // indicate the end of the program

    // Instruction Memory
    .iBus_CP_IMEM_Valid            ( rBus_IMEM_Valid           ), // cp ins. memory access valid
    .iBus_CP_IMEM_Address          ( rBus_IMEM_Address         ), // cp ins. memory access address
    .iBus_CP_IMEM_Write_Data       ( rBus_IMEM_Write_Data[(`DEF_CP_INS_WIDTH+3):0] ), // cp ins. memory write data
    .iBus_CP_IMEM_Write_Enable     ( rBus_IMEM_Write_Enable    ), // cp ins. memory write enable
    .oBus_CP_IMEM_Read_Data        ( wBus_CP_IMEM_Read_Data    ), // cp ins. memory read data

    .iBus_PE_IMEM_Valid            ( rBus_IMEM_Valid           ), // pe ins. memory access valid
    .iBus_PE_IMEM_Address          ( rBus_IMEM_Address         ), // pe ins. memory access address
    .iBus_PE_IMEM_Write_Data       ( rBus_IMEM_Write_Data[(`DEF_PE_INS_WIDTH+4)+32:32] ), // pe ins. memory write data
    .iBus_PE_IMEM_Write_Enable     ( rBus_IMEM_Write_Enable    ), // pe ins. memory write enable
    .oBus_PE_IMEM_Read_Data        ( wBus_PE_IMEM_Read_Data    ), // pe ins. memory read data

    // Data Memory
    .iBus_CP_DMEM_Valid            ( rBus_CP_DMEM_Valid        ), // cp data memory access valid
    .iBus_CP_DMEM_Address          ( {rBus_CP_DMEM_Address, 2'b0} ), // cp data memory access address
    .iBus_CP_DMEM_Write_Data       ( rBus_CP_DMEM_Write_Data   ), // cp data memory write data
    .iBus_CP_DMEM_Write_Enable     ( rBus_CP_DMEM_Write_Enable ), // cp data memory write enable
    .oBus_CP_DMEM_Read_Data        ( wBus_CP_DMEM_Read_Data    ), // cp data memory read data

    .iBus_PE_DMEM_Valid            ( {`DEF_PE_NUM{rBus_PE_DMEM_Valid}} ), // pe data memory access valid
    .iBus_PE_DMEM_Address          ( {`DEF_PE_NUM{rBus_PE_DMEM_Address, 2'b0}} ), // pe data memory access address
    .iBus_PE_DMEM_Write_Data       ( rBus_PE_DMEM_Write_Data  ), // pe data memory write data
    .iBus_PE_DMEM_Write_Enable     ( {`DEF_PE_NUM{rBus_PE_DMEM_Write_Enable}} ), // pe data memory write enable
    .oBus_PE_DMEM_Read_Data        ( wBus_PE_DMEM_Read_Data   )  // pe data memory read data
  );


endmodule