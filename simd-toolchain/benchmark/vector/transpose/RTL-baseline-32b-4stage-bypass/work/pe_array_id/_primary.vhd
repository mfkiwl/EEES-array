library verilog;
use verilog.vl_types.all;
entity pe_array_id is
    port(
        iClk            : in     vl_logic;
        iReset          : in     vl_logic;
        iIF_ID_Instruction: in     vl_logic_vector(23 downto 0);
        oID_ID_RF_Write_Addr: out    vl_logic_vector(4 downto 0);
        oID_ID_RF_WriteBack: out    vl_logic_vector(2 downto 0);
        oUpdate_Flag    : out    vl_logic_vector(1 downto 0);
        oID_ID_ALU_Opcode: out    vl_logic_vector(3 downto 0);
        oID_ID_Is_ALU   : out    vl_logic;
        oID_ID_LSU_Write_Enable: out    vl_logic;
        oID_ID_LSU_Read_Enable: out    vl_logic;
        oID_ID_LSU_Opcode: out    vl_logic_vector(1 downto 0);
        oID_ID_MUL_SHIFT_LOGIC_Opcode: out    vl_logic_vector(2 downto 0);
        oID_ID_Is_MUL   : out    vl_logic;
        oID_ID_Is_Shift : out    vl_logic;
        oID_ID_Is_MUL_SHIFT_LOGIC: out    vl_logic;
        oID_BP_Immediate: out    vl_logic_vector(31 downto 0)
    );
end pe_array_id;
