//----------------------------------------------------------------------------
// user_logic.v - module
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
// Naming Conventions:
//   active low signals:                    "*_n"
//   clock signals:                         "clk", "clk_div#", "clk_#x"
//   reset signals:                         "rst", "rst_n"
//   generics:                              "C_*"
//   user defined types:                    "*_TYPE"
//   state machine next state:              "*_ns"
//   state machine current state:           "*_cs"
//   combinatorial signals:                 "*_com"
//   pipelined or register delay signals:   "*_d#"
//   counter signals:                       "*cnt*"
//   clock enable signals:                  "*_ce"
//   internal version of output port:       "*_i"
//   device pins:                           "*_pin"
//   ports:                                 "- Names begin with Uppercase"
//   processes:                             "*_PROCESS"
//   component instantiations:              "<ENTITY_>I_<#|FUNC>"
//----------------------------------------------------------------------------

`uselib lib=unisims_ver
`uselib lib=proc_common_v3_00_a

`include "def-cp.v"
`include "def-pe.v"

module user_logic
(
  Bus2IP_Clk,                     // Bus to IP clock
  Bus2IP_Resetn,                  // Bus to IP reset
  Bus2IP_Addr,                    // Bus to IP address bus
  Bus2IP_Data,                    // Bus to IP data bus
  Bus2IP_BE,                      // Bus to IP byte enables
  Bus2IP_RdCE,                    // Bus to IP read chip enable
  Bus2IP_WrCE,                    // Bus to IP write chip enable
  IP2Bus_Data,                    // IP to Bus data bus
  IP2Bus_RdAck,                   // IP to Bus read transfer acknowledgement
  IP2Bus_WrAck,                   // IP to Bus write transfer acknowledgement
  IP2Bus_Error                    // IP to Bus error response
); // user_logic

parameter C_NUM_REG                      = 1;
parameter C_SLV_DWIDTH                   = 32;

input                                     Bus2IP_Clk;
input                                     Bus2IP_Resetn;
input      [0 : 31]                       Bus2IP_Addr;
input      [C_SLV_DWIDTH-1 : 0]           Bus2IP_Data;
input      [C_SLV_DWIDTH/8-1 : 0]         Bus2IP_BE;
input      [C_NUM_REG-1 : 0]              Bus2IP_RdCE;
input      [C_NUM_REG-1 : 0]              Bus2IP_WrCE;
output     [C_SLV_DWIDTH-1 : 0]           IP2Bus_Data;
output                                    IP2Bus_RdAck;
output                                    IP2Bus_WrAck;
output                                    IP2Bus_Error;
// -- DO NOT EDIT ABOVE THIS LINE --------------------

//----------------------------------------------------------------------------
// Implementation
//----------------------------------------------------------------------------
  
  integer     i;
  reg  [31:0] Bus2IP_Addr_Converted; // byte aligned                         
  wire        slv_write_ack;                // write acknowledgement
  reg         slv_read_ack;                 // read acknowledgement
  wire        wCore_Reset;                 // reset signal for core

  // config. reg
  reg         rConfigure_Done;
  wire        wBus_Configure_Read_Enable;
  // task ready
  wire        wTask_Finished;
  wire        wBus_Task_Ready_Read_Enable;
  // pc
  wire [(`DEF_CP_I_MEM_ADDR_WIDTH-3):0] wPC;
  //wire                             wBus_PC_Read_Enable;

  // Address decoding
  wire                                wAddrCE;
  wire                                wCtrlEn;
  wire [31:0]                         wCtrlAddr;
  wire                                wCPIMemEn;
  wire [31:0]                         wCPIMemAddr;
  wire                                wPEIMemEn;
  wire [31:0]                         wPEIMemAddr;
  wire                                wCPDMemEn;
  wire [31:0]                         wCPDMemAddr;
  wire [`DEF_PE_NUM-1:0]              wPEDMemEn;
  wire [`DEF_PE_D_MEM_ADDR_WIDTH-1:0] wPEDMemRowAddr;
  
  // cp imem
  wire                               wBus_CP_IMEM_Write_Enable;
  wire                               wBus_CP_IMEM_Read_Enable;
  wire [(`DEF_CP_INS_WIDTH+3):0]     wBus_CP_IMEM_Read_Data;   // CP IMEM read data to bus
  
  // cp dmem
  wire                               wBus_CP_DMEM_Write_Enable;
  wire                               wBus_CP_DMEM_Read_Enable;
  wire [(`DEF_CP_DATA_WIDTH-1):0]    wBus_CP_DMEM_Read_Data;   // CP DMEM read data to bus
  
  // pe imem
  wire                               wBus_PE_IMEM_Write_Enable;
  wire                               wBus_PE_IMEM_Read_Enable;
  wire [(`DEF_PE_INS_WIDTH+3):0]     wBus_PE_IMEM_Read_Data;   // PE IMEM read data to bus
  
  // pe dmem
  wire [(`DEF_PE_NUM-1):0]           wBus_PE_DMEM_Write_Enable;  
  wire [(`DEF_PE_NUM-1):0]           wBus_PE_DMEM_Read_Enable; 
  
  wire [(`DEF_PE_DATA_WIDTH*`DEF_PE_NUM-1):0] wBus_PE_DMEM_Read_Data;
  
  // bus read
  reg  [C_SLV_DWIDTH-1 : 0]          rRead_Data;               // bus read data
  reg                                rDelayed_Read_Enable;     // BRAM is synchronous read, 1 cycle latency is required!
  
  // hardware cycle counter for dubug
  reg  [C_SLV_DWIDTH-1 : 0]          rCycle_Counter;
  
  
//****************************** 
//  Behavioral Description       
//****************************** 
  // big-endian to little-endian
  always @ ( Bus2IP_Addr )
    for( i = 0; i < 32; i = i+1 )
      Bus2IP_Addr_Converted[i] = Bus2IP_Addr[31-i];
  // end of always
  
  
  
  assign slv_write_ack = Bus2IP_WrCE[0];
  //assign slv_read_ack  = Bus2IP_RdCE[0];
  
  always @ ( posedge Bus2IP_Clk )
    if ( Bus2IP_Resetn == 'b0 )
      rDelayed_Read_Enable <= 'b0;
    else
      rDelayed_Read_Enable <= Bus2IP_RdCE[0];
  // end of always  
  
  
  // flag register: configure ready
  always @ ( posedge Bus2IP_Clk )
    if (Bus2IP_Resetn == 'b0) begin
      rConfigure_Done <= 'b0;
    end
    else if (Bus2IP_WrCE[0] && wCtrlEn && (~wCtrlAddr[3]) && (~wCtrlAddr[2]))
      begin
        rConfigure_Done <= Bus2IP_Data[0];
      end
  // end of always  
  // Active high core reset
  assign wCore_Reset = ~(Bus2IP_Resetn && rConfigure_Done);
  assign wAddrCE = Bus2IP_RdCE[0] || Bus2IP_WrCE[0];

  // ctrl reg
  assign wBus_Configure_Read_Enable
    = (Bus2IP_RdCE[0] && wCtrlEn && (~wCtrlAddr[3]) && (~wCtrlAddr[2]));
  assign wBus_Counter_Read_Enable
    = (Bus2IP_RdCE[0] && wCtrlEn && (~wCtrlAddr[3]) && wCtrlAddr[2]);
  assign wBus_Task_Ready_Read_Enable
    = (Bus2IP_RdCE[0] && wCtrlEn && wCtrlAddr[3]  && (~wCtrlAddr[2]));
  
  // cp
  assign wBus_CP_IMEM_Write_Enable = (Bus2IP_WrCE[0] && wCPIMemEn);
  assign wBus_CP_IMEM_Read_Enable  = (Bus2IP_RdCE[0] && wCPIMemEn);
  
  assign wBus_CP_DMEM_Write_Enable = (Bus2IP_WrCE[0] && wCPDMemEn);
  assign wBus_CP_DMEM_Read_Enable  = (Bus2IP_RdCE[0] && wCPDMemEn);
  
  // pe
  assign wBus_PE_IMEM_Write_Enable  = (Bus2IP_WrCE[0] && wPEIMemEn);
  assign wBus_PE_IMEM_Read_Enable   = (Bus2IP_RdCE[0] && wPEIMemEn);
  {% for i in range(cfg.pe.size) %}
  assign wBus_PE_DMEM_Write_Enable[{{i}}]=(Bus2IP_WrCE[0] && wPEDMemEn[{{i}}]);
  assign wBus_PE_DMEM_Read_Enable[{{i}}]=(Bus2IP_RdCE[0] && wPEDMemEn[{{i}}]);
  {% endfor %}
  
  always @ (wBus_Configure_Read_Enable or wBus_Task_Ready_Read_Enable
            or wBus_Counter_Read_Enable or rConfigure_Done  or wTask_Finished
            or rCycle_Counter or wBus_CP_DMEM_Read_Enable
            or wBus_PE_DMEM_Read_Enable or wBus_CP_DMEM_Read_Data
            or wBus_PE_DMEM_Read_Data or rDelayed_Read_Enable or Bus2IP_RdCE[0])
    casez ({wBus_Configure_Read_Enable, wBus_Task_Ready_Read_Enable,
            wBus_Counter_Read_Enable, wBus_CP_DMEM_Read_Enable,
            wBus_PE_DMEM_Read_Enable})
      8'b1???????: begin      
        rRead_Data   = { {(C_SLV_DWIDTH-1){1'b0}}, rConfigure_Done};
        slv_read_ack = Bus2IP_RdCE[0];
      end
      8'b01??????: begin
        rRead_Data   = { {(C_SLV_DWIDTH-1){1'b0}}, wTask_Finished};
        slv_read_ack = Bus2IP_RdCE[0];
      end      
      8'b001?????: begin
        rRead_Data   = rCycle_Counter;
        slv_read_ack = Bus2IP_RdCE[0];
      end
      8'b0001????: begin
        rRead_Data   = wBus_CP_DMEM_Read_Data;
        slv_read_ack = rDelayed_Read_Enable;
      end
      8'b00001???: begin
        rRead_Data   = wBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*4-1):`DEF_PE_DATA_WIDTH*3];
        slv_read_ack = rDelayed_Read_Enable;
      end
      8'b000001??: begin
        rRead_Data   = wBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*3-1):`DEF_PE_DATA_WIDTH*2];
        slv_read_ack = rDelayed_Read_Enable;
      end
      8'b0000001?: begin
        rRead_Data   = wBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*2-1):`DEF_PE_DATA_WIDTH*1];
        slv_read_ack = rDelayed_Read_Enable;
      end
      8'b00000001: begin
        rRead_Data   = wBus_PE_DMEM_Read_Data[(`DEF_PE_DATA_WIDTH*1-1):`DEF_PE_DATA_WIDTH*0];
        slv_read_ack = rDelayed_Read_Enable;
      end
      default: begin
        rRead_Data   = rCycle_Counter;
        slv_read_ack = Bus2IP_RdCE[0];
      end  
    endcase
  // end of always
  
  
  // cycle counter
  always @ ( posedge Bus2IP_Clk )
    if ( wCore_Reset == 'b1 ) begin
      rCycle_Counter <= 'b0;
    end
    else if ( wTask_Finished == 1'b0 ) begin
      rCycle_Counter <= rCycle_Counter + 'b1;
    end
  // end of always

  sys_address_decoder inst_sys_addr_dec
    (
     .iClk(Bus2IP_Clk),
     .iRst(Bus2IP_Resetn),
     .iCE(wAddrCE),
     .iAddr(Bus2IP_Addr_Converted),
     .oCtrlEn(wCtrlEn),
     .oCtrlAddr(wCtrlAddr),
     .oCPIMemEn(wCPIMemEn),
     .oCPIMemAddr(wCPIMemAddr),
     .oPEIMemEn(wPEIMemEn),
     .oPEIMemAddr(wPEIMemAddr),
     .oCPDMemEn(wCPDMemEn),
     .oCPDMemAddr(wCPDMemAddr),
     .oPEDMemEn(wPEDMemEn),
     .oPEDMemRowAddr(wPEDMemRowAddr)
     );
  
  simd_top inst_simd_top (                                                        
    .iClk                          (Bus2IP_Clk),
    .iReset                        (wCore_Reset), // Active high sync-reset

    .oIF_ID_PC                     (wPC),
    .oTask_Finished                (wTask_Finished),
    // Instruction Memory
    .iBus_CP_IMEM_Valid            (wCPIMemEn),
    .iBus_CP_IMEM_Address          (wCPIMemAddr[(`DEF_CP_I_MEM_ADDR_WIDTH-1):2]),
    .iBus_CP_IMEM_Write_Data       (Bus2IP_Data[(`DEF_CP_INS_WIDTH+3):0] ),
    .iBus_CP_IMEM_Write_Enable     (wBus_CP_IMEM_Write_Enable),
    .oBus_CP_IMEM_Read_Data        (wBus_CP_IMEM_Read_Data),
     
    .iBus_PE_IMEM_Valid            (wPEIMemEn),
    .iBus_PE_IMEM_Address          (wPEIMemAddr[(`DEF_PE_I_MEM_ADDR_WIDTH-1):2]),
    .iBus_PE_IMEM_Write_Data       (Bus2IP_Data[(`DEF_PE_INS_WIDTH+3):0]),
    .iBus_PE_IMEM_Write_Enable     (wBus_PE_IMEM_Write_Enable),
    .oBus_PE_IMEM_Read_Data        (wBus_PE_IMEM_Read_Data),

    // Data Memory
    .iBus_CP_DMEM_Valid            (wCPDMemEn),
    .iBus_CP_DMEM_Address          (wCPDMemAddr[(`DEF_CP_D_MEM_ADDR_WIDTH-1):0]),
    .iBus_CP_DMEM_Write_Data       (Bus2IP_Data[(`DEF_CP_DATA_WIDTH-1):0]),
    .iBus_CP_DMEM_Write_Enable     (wBus_CP_DMEM_Write_Enable),
    .oBus_CP_DMEM_Read_Data        (wBus_CP_DMEM_Read_Data),

    .iBus_PE_DMEM_Valid           (wPEDMemEn),
    .iBus_PE_DMEM_Address({`DEF_PE_NUM{wPEDMemRowAddr[(`DEF_PE_D_MEM_ADDR_WIDTH-1):0]}} ),
    .iBus_PE_DMEM_Write_Data      ({`DEF_PE_NUM{Bus2IP_Data[(`DEF_PE_DATA_WIDTH-1):0]}}),
    .iBus_PE_DMEM_Write_Enable    (wBus_PE_DMEM_Write_Enable),
    .oBus_PE_DMEM_Read_Data       (wBus_PE_DMEM_Read_Data)
  );  
    
//*********************
//  Output Assignment
//*********************  
  assign IP2Bus_Data  = rRead_Data;
  assign IP2Bus_WrAck = slv_write_ack;
  assign IP2Bus_RdAck = slv_read_ack;
  assign IP2Bus_Error = 0;

endmodule
