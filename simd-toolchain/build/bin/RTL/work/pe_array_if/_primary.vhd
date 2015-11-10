library verilog;
use verilog.vl_types.all;
entity pe_array_if is
    port(
        iClk            : in     vl_logic;
        iReset          : in     vl_logic;
        oIF_ID_Instruction: out    vl_logic_vector(23 downto 0);
        oPredication    : out    vl_logic_vector(1 downto 0);
        oIF_RF_Read_Addr_A: out    vl_logic_vector(4 downto 0);
        oIF_RF_Read_Addr_B: out    vl_logic_vector(4 downto 0);
        oIF_BP_Select_Imm: out    vl_logic;
        oIF_BP_Bypass_Read_A: out    vl_logic;
        oIF_BP_Bypass_Read_B: out    vl_logic;
        oIF_BP_Bypass_Sel_A: out    vl_logic_vector(1 downto 0);
        oIF_BP_Bypass_Sel_B: out    vl_logic_vector(1 downto 0);
        oIF_BP_Data_Selection: out    vl_logic_vector(1 downto 0);
        iPredication    : in     vl_logic_vector(1 downto 0);
        iData_Selection : in     vl_logic_vector(1 downto 0);
        iIMEM_IF_Instruction: in     vl_logic_vector(23 downto 0)
    );
end pe_array_if;
