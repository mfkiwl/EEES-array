library verilog;
use verilog.vl_types.all;
entity core_top is
    port(
        iClk            : in     vl_logic;
        iReset          : in     vl_logic;
        oIF_ID_PC       : out    vl_logic_vector(16 downto 0);
        oTask_Finished  : out    vl_logic;
        oIF_IMEM_Address: out    vl_logic_vector(16 downto 0);
        iIMEM_CP_Instruction: in     vl_logic_vector(27 downto 0);
        oCP_DMEM_Valid  : out    vl_logic;
        oCP_AGU_DMEM_Write_Enable: out    vl_logic;
        oCP_AGU_DMEM_Read_Enable: out    vl_logic;
        oCP_AGU_DMEM_Byte_Select: out    vl_logic_vector(3 downto 0);
        oCP_AGU_DMEM_Address: out    vl_logic_vector(12 downto 0);
        oCP_AGU_DMEM_Write_Data: out    vl_logic_vector(31 downto 0);
        iCP_DMEM_EX_Data: in     vl_logic_vector(31 downto 0);
        oPE0_DMEM_Valid : out    vl_logic;
        oPE0_AGU_DMEM_Write_Enable: out    vl_logic;
        oPE0_AGU_DMEM_Read_Enable: out    vl_logic;
        oPE0_AGU_DMEM_Byte_Select: out    vl_logic_vector(3 downto 0);
        oPE0_AGU_DMEM_Address: out    vl_logic_vector(10 downto 0);
        oPE0_AGU_DMEM_Write_Data: out    vl_logic_vector(31 downto 0);
        iPE0_DMEM_EX_Data: in     vl_logic_vector(31 downto 0);
        oPE1_DMEM_Valid : out    vl_logic;
        oPE1_AGU_DMEM_Write_Enable: out    vl_logic;
        oPE1_AGU_DMEM_Read_Enable: out    vl_logic;
        oPE1_AGU_DMEM_Byte_Select: out    vl_logic_vector(3 downto 0);
        oPE1_AGU_DMEM_Address: out    vl_logic_vector(10 downto 0);
        oPE1_AGU_DMEM_Write_Data: out    vl_logic_vector(31 downto 0);
        iPE1_DMEM_EX_Data: in     vl_logic_vector(31 downto 0);
        oPE2_DMEM_Valid : out    vl_logic;
        oPE2_AGU_DMEM_Write_Enable: out    vl_logic;
        oPE2_AGU_DMEM_Read_Enable: out    vl_logic;
        oPE2_AGU_DMEM_Byte_Select: out    vl_logic_vector(3 downto 0);
        oPE2_AGU_DMEM_Address: out    vl_logic_vector(10 downto 0);
        oPE2_AGU_DMEM_Write_Data: out    vl_logic_vector(31 downto 0);
        iPE2_DMEM_EX_Data: in     vl_logic_vector(31 downto 0);
        oPE3_DMEM_Valid : out    vl_logic;
        oPE3_AGU_DMEM_Write_Enable: out    vl_logic;
        oPE3_AGU_DMEM_Read_Enable: out    vl_logic;
        oPE3_AGU_DMEM_Byte_Select: out    vl_logic_vector(3 downto 0);
        oPE3_AGU_DMEM_Address: out    vl_logic_vector(10 downto 0);
        oPE3_AGU_DMEM_Write_Data: out    vl_logic_vector(31 downto 0);
        iPE3_DMEM_EX_Data: in     vl_logic_vector(31 downto 0);
        iIMEM_PE_Instruction: in     vl_logic_vector(27 downto 0)
    );
end core_top;