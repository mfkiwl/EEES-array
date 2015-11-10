library verilog;
use verilog.vl_types.all;
entity pe_bypass is
    port(
        iWB_RF_Write_Addr: in     vl_logic_vector(4 downto 0);
        iWB_RF_Write_Data: in     vl_logic_vector(31 downto 0);
        iIF_RF_Read_Addr_A: in     vl_logic_vector(4 downto 0);
        iIF_RF_Read_Addr_B: in     vl_logic_vector(4 downto 0);
        iIF_BP_Select_Imm: in     vl_logic;
        iIF_BP_Bypass_Read_A: in     vl_logic;
        iIF_BP_Bypass_Read_B: in     vl_logic;
        iIF_BP_Bypass_Sel_A: in     vl_logic_vector(1 downto 0);
        iIF_BP_Bypass_Sel_B: in     vl_logic_vector(1 downto 0);
        iID_BP_Immediate: in     vl_logic_vector(31 downto 0);
        iID_BP_Is_SUB   : in     vl_logic;
        oBP_ID_Operand_A: out    vl_logic_vector(31 downto 0);
        oBP_ID_Operand_B: out    vl_logic_vector(31 downto 0);
        oBP_ID_LSU_Store_Data: out    vl_logic_vector(31 downto 0);
        iRF_BP_Read_Data_A: in     vl_logic_vector(31 downto 0);
        iRF_BP_Read_Data_B: in     vl_logic_vector(31 downto 0);
        iEX_BP_ALU_Result: in     vl_logic_vector(31 downto 0);
        iEX_BP_MUL_Result: in     vl_logic_vector(31 downto 0);
        iEX_BP_LSU_Result: in     vl_logic_vector(31 downto 0);
        iEX_BP_Shadow_Result: in     vl_logic_vector(31 downto 0);
        iData_Selection : in     vl_logic_vector(1 downto 0);
        iLeft_PE_Port1_Data: in     vl_logic_vector(31 downto 0);
        iRight_PE_Port1_Data: in     vl_logic_vector(31 downto 0);
        iCP_Data        : in     vl_logic_vector(31 downto 0);
        oPE_Port1_Data  : out    vl_logic_vector(31 downto 0)
    );
end pe_bypass;
