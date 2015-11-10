library verilog;
use verilog.vl_types.all;
entity simd_top is
    port(
        iClk            : in     vl_logic;
        iReset          : in     vl_logic;
        oIF_ID_PC       : out    vl_logic_vector(16 downto 0);
        oTask_Finished  : out    vl_logic;
        iBus_CP_IMEM_Valid: in     vl_logic;
        iBus_CP_IMEM_Address: in     vl_logic_vector(16 downto 0);
        iBus_CP_IMEM_Write_Data: in     vl_logic_vector(27 downto 0);
        iBus_CP_IMEM_Write_Enable: in     vl_logic;
        oBus_CP_IMEM_Read_Data: out    vl_logic_vector(27 downto 0);
        iBus_PE_IMEM_Valid: in     vl_logic;
        iBus_PE_IMEM_Address: in     vl_logic_vector(16 downto 0);
        iBus_PE_IMEM_Write_Data: in     vl_logic_vector(27 downto 0);
        iBus_PE_IMEM_Write_Enable: in     vl_logic;
        oBus_PE_IMEM_Read_Data: out    vl_logic_vector(27 downto 0);
        iBus_CP_DMEM_Valid: in     vl_logic;
        iBus_CP_DMEM_Address: in     vl_logic_vector(17 downto 0);
        iBus_CP_DMEM_Write_Data: in     vl_logic_vector(31 downto 0);
        iBus_CP_DMEM_Write_Enable: in     vl_logic;
        oBus_CP_DMEM_Read_Data: out    vl_logic_vector(31 downto 0);
        iBus_PE_DMEM_Valid: in     vl_logic_vector(3 downto 0);
        iBus_PE_DMEM_Address: in     vl_logic_vector(71 downto 0);
        iBus_PE_DMEM_Write_Data: in     vl_logic_vector(127 downto 0);
        iBus_PE_DMEM_Write_Enable: in     vl_logic_vector(3 downto 0);
        oBus_PE_DMEM_Read_Data: out    vl_logic_vector(127 downto 0)
    );
end simd_top;
