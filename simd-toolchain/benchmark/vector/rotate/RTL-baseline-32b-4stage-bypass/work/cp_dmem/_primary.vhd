library verilog;
use verilog.vl_types.all;
entity cp_dmem is
    generic(
        RAM_WIDTH       : integer := 32
    );
    port(
        iClk            : in     vl_logic;
        iBus_Valid      : in     vl_logic;
        iBus_Address    : in     vl_logic_vector(17 downto 0);
        iBus_Write_Data : in     vl_logic_vector(31 downto 0);
        iBus_Write_Enable: in     vl_logic;
        oBus_Read_Data  : out    vl_logic_vector(31 downto 0);
        iCore_Valid     : in     vl_logic;
        iAGU_DMEM_Memory_Write_Enable: in     vl_logic;
        iAGU_DMEM_Memory_Read_Enable: in     vl_logic;
        iAGU_DMEM_Byte_Select: in     vl_logic_vector(3 downto 0);
        iAGU_DMEM_Address: inout  vl_logic_vector(10 downto 0);
        iAGU_DMEM_Store_Data: in     vl_logic_vector(31 downto 0);
        oDMEM_EX_Data   : out    vl_logic_vector(31 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of RAM_WIDTH : constant is 1;
end cp_dmem;
