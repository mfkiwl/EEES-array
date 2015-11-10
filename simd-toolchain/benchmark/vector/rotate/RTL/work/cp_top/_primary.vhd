library verilog;
use verilog.vl_types.all;
entity cp_top is
    port(
        iClk            : in     vl_logic;
        iReset          : in     vl_logic;
        oIF_ID_PC       : out    vl_logic_vector(16 downto 0);
        oTask_Finished  : out    vl_logic;
        oIF_IMEM_Address: out    vl_logic_vector(16 downto 0);
        iIMEM_IF_Instruction: in     vl_logic_vector(23 downto 0);
        oAGU_DMEM_Write_Enable: out    vl_logic;
        oAGU_DMEM_Read_Enable: out    vl_logic;
        oAGU_DMEM_Address: out    vl_logic_vector(31 downto 0);
        oAGU_DMEM_Byte_Select: out    vl_logic_vector(3 downto 0);
        oAGU_DMEM_Opcode: out    vl_logic_vector(1 downto 0);
        oAGU_DMEM_Store_Data: out    vl_logic_vector(31 downto 0);
        iDMEM_EX_Data   : in     vl_logic_vector(31 downto 0);
        iPredication    : in     vl_logic_vector(1 downto 0);
        oCP_Port1_Data  : out    vl_logic_vector(31 downto 0);
        iFirst_PE_Port1_Data: in     vl_logic_vector(31 downto 0);
        iSelect_First_PE: in     vl_logic;
        iLast_PE_Port1_Data: in     vl_logic_vector(31 downto 0);
        iSelect_Last_PE : in     vl_logic
    );
end cp_top;
