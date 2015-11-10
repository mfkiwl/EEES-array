library verilog;
use verilog.vl_types.all;
entity pe_top is
    generic(
        Para_PE_ID      : integer := 0
    );
    port(
        iClk            : in     vl_logic;
        iReset          : in     vl_logic;
        iData_Selection : in     vl_logic_vector(1 downto 0);
        iUpdate_Flag    : in     vl_logic_vector(1 downto 0);
        iIF_ID_Predication: in     vl_logic_vector(1 downto 0);
        iLeft_PE_Port1_Data: in     vl_logic_vector(31 downto 0);
        iRight_PE_Port1_Data: in     vl_logic_vector(31 downto 0);
        iCP_Data        : in     vl_logic_vector(31 downto 0);
        oPE_Port1_Data  : out    vl_logic_vector(31 downto 0);
        iIF_RF_Read_Addr_A: in     vl_logic_vector(4 downto 0);
        iIF_RF_Read_Addr_B: in     vl_logic_vector(4 downto 0);
        iIF_BP_Select_Imm: in     vl_logic;
        iIF_BP_Bypass_Read_A: in     vl_logic;
        iIF_BP_Bypass_Read_B: in     vl_logic;
        iIF_BP_Bypass_Sel_A: in     vl_logic_vector(1 downto 0);
        iIF_BP_Bypass_Sel_B: in     vl_logic_vector(1 downto 0);
        iID_ID_RF_Write_Addr: in     vl_logic_vector(4 downto 0);
        iID_ID_RF_WriteBack: in     vl_logic_vector(2 downto 0);
        iID_ID_ALU_Opcode: in     vl_logic_vector(3 downto 0);
        iID_ID_Is_ALU   : in     vl_logic;
        iID_ID_LSU_Write_Enable: in     vl_logic;
        iID_ID_LSU_Read_Enable: in     vl_logic;
        iID_ID_LSU_Opcode: in     vl_logic_vector(1 downto 0);
        iID_ID_MUL_SHIFT_LOGIC_Opcode: in     vl_logic_vector(2 downto 0);
        iID_ID_Is_MUL   : in     vl_logic;
        iID_ID_Is_Shift : in     vl_logic;
        iID_ID_Is_MUL_SHIFT_LOGIC: in     vl_logic;
        iID_BP_Immediate: in     vl_logic_vector(31 downto 0);
        oAGU_DMEM_Write_Enable: out    vl_logic;
        oAGU_DMEM_Read_Enable: out    vl_logic;
        oAGU_DMEM_Address: out    vl_logic_vector(31 downto 0);
        oAGU_DMEM_Byte_Select: out    vl_logic_vector(3 downto 0);
        oAGU_DMEM_Opcode: out    vl_logic_vector(1 downto 0);
        oAGU_DMEM_Store_Data: out    vl_logic_vector(31 downto 0);
        iDMEM_EX_Data   : in     vl_logic_vector(31 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of Para_PE_ID : constant is 1;
end pe_top;
