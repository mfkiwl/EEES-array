library verilog;
use verilog.vl_types.all;
entity pe_ex is
    port(
        iClk            : in     vl_logic;
        iReset          : in     vl_logic;
        oEX_ID_P0       : out    vl_logic;
        oEX_ID_P1       : out    vl_logic;
        iID_EX_Update_Flag: in     vl_logic;
        iID_EX_Update_P0: in     vl_logic;
        iID_EX_Update_P1: in     vl_logic;
        iID_EX_RF_Write_Addr: in     vl_logic_vector(4 downto 0);
        iID_EX_RF_WriteBack: in     vl_logic_vector(2 downto 0);
        iID_EX_Write_Shadow_Register: in     vl_logic;
        iID_EX_ALU_Opcode: in     vl_logic_vector(3 downto 0);
        iID_EX_ALU_Operand_A: in     vl_logic_vector(31 downto 0);
        iID_EX_ALU_Operand_B: in     vl_logic_vector(31 downto 0);
        iID_EX_MUL_SHIFT_LOGIC_Opcode: in     vl_logic_vector(2 downto 0);
        iID_EX_MUL_SHIFT_LOGIC_Operand_A: in     vl_logic_vector(31 downto 0);
        iID_EX_MUL_SHIFT_LOGIC_Operand_B: in     vl_logic_vector(31 downto 0);
        iID_EX_Is_Multiplication: in     vl_logic;
        iID_EX_Is_Shift : in     vl_logic;
        oEX_BP_ALU_Result: out    vl_logic_vector(31 downto 0);
        oEX_BP_MUL_Result: out    vl_logic_vector(31 downto 0);
        oEX_BP_LSU_Result: out    vl_logic_vector(31 downto 0);
        oEX_BP_Shadow_Result: out    vl_logic_vector(31 downto 0);
        iDMEM_EX_Data   : in     vl_logic_vector(31 downto 0);
        oEX_WB_Write_RF_Data: out    vl_logic_vector(31 downto 0);
        oEX_WB_Write_RF_Address: out    vl_logic_vector(4 downto 0);
        oEX_WB_Write_RF_Enable: out    vl_logic
    );
end pe_ex;
