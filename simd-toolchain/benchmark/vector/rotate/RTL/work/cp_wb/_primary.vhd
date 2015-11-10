library verilog;
use verilog.vl_types.all;
entity cp_wb is
    port(
        iClk            : in     vl_logic;
        iReset          : in     vl_logic;
        iEX_WB_Write_RF_Data: in     vl_logic_vector(31 downto 0);
        iEX_WB_Write_RF_Address: in     vl_logic_vector(4 downto 0);
        iEX_WB_Write_RF_Enable: in     vl_logic;
        oWB_RF_Writeback_Enable: out    vl_logic;
        oWB_RF_Write_Addr: out    vl_logic_vector(4 downto 0);
        oWB_RF_Write_Data: out    vl_logic_vector(31 downto 0)
    );
end cp_wb;
