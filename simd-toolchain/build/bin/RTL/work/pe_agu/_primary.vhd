library verilog;
use verilog.vl_types.all;
entity pe_agu is
    port(
        iClk            : in     vl_logic;
        iReset          : in     vl_logic;
        iID_AGU_Operand_A: in     vl_logic_vector(31 downto 0);
        iID_AGU_Operand_B: in     vl_logic_vector(31 downto 0);
        iID_AGU_Memory_Write_Enable: in     vl_logic;
        iID_AGU_Memory_Read_Enable: in     vl_logic;
        iID_AGU_Memory_Opcode: in     vl_logic_vector(1 downto 0);
        iID_AGU_Memory_Store_Data: in     vl_logic_vector(31 downto 0);
        oAGU_DMEM_Memory_Write_Enable: out    vl_logic;
        oAGU_DMEM_Memory_Read_Enable: out    vl_logic;
        oAGU_DMEM_Byte_Select: out    vl_logic_vector(3 downto 0);
        oAGU_DMEM_Opcode: out    vl_logic_vector(1 downto 0);
        oAGU_DMEM_Memory_Store_Data: out    vl_logic_vector(31 downto 0);
        oAGU_DMEM_Address: out    vl_logic_vector(31 downto 0)
    );
end pe_agu;
