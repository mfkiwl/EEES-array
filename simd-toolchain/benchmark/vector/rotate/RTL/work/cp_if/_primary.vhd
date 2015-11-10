library verilog;
use verilog.vl_types.all;
entity cp_if is
    port(
        iClk            : in     vl_logic;
        iReset          : in     vl_logic;
        iID_IF_Branch_Target_Addr: in     vl_logic_vector(16 downto 0);
        iID_IF_Branch_Taken_Flag: in     vl_logic;
        oIF_ID_PC       : out    vl_logic_vector(16 downto 0);
        oIF_ID_Instruction: out    vl_logic_vector(23 downto 0);
        oIF_ID_Branch_Op: out    vl_logic_vector(2 downto 0);
        oSelect_First_PE: out    vl_logic;
        oSelect_Last_PE : out    vl_logic;
        oPredication    : out    vl_logic_vector(1 downto 0);
        oIF_RF_Read_Addr_A: out    vl_logic_vector(4 downto 0);
        oIF_RF_Read_Addr_B: out    vl_logic_vector(4 downto 0);
        oIF_BP_Select_Imm: out    vl_logic;
        oIF_BP_Bypass_Read_A: out    vl_logic;
        oIF_BP_Bypass_Read_B: out    vl_logic;
        oIF_BP_Bypass_Sel_A: out    vl_logic_vector(1 downto 0);
        oIF_BP_Bypass_Sel_B: out    vl_logic_vector(1 downto 0);
        iPredication    : in     vl_logic_vector(1 downto 0);
        iSelect_First_PE: in     vl_logic;
        iSelect_Last_PE : in     vl_logic;
        iIMEM_IF_Instruction: in     vl_logic_vector(23 downto 0);
        oIF_IMEM_Addr   : out    vl_logic_vector(16 downto 0)
    );
end cp_if;
