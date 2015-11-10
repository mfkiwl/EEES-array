library verilog;
use verilog.vl_types.all;
entity pe_imem is
    generic(
        RAM_WIDTH       : integer := 29;
        RAM_ADDR_BITS   : integer := 13
    );
    port(
        iClk            : in     vl_logic;
        iBus_Valid      : in     vl_logic;
        iBus_Address    : in     vl_logic_vector(16 downto 0);
        iBus_Write_Data : in     vl_logic_vector(28 downto 0);
        iBus_Write_Enable: in     vl_logic;
        oBus_Read_Data  : out    vl_logic_vector(28 downto 0);
        iIF_IMEM_Addr   : in     vl_logic_vector(16 downto 0);
        oIMEM_IF_Instruction: out    vl_logic_vector(28 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of RAM_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of RAM_ADDR_BITS : constant is 1;
end pe_imem;
