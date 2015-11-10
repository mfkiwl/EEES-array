library verilog;
use verilog.vl_types.all;
entity cp_rf is
    port(
        iClk            : in     vl_logic;
        iIF_RF_Read_Addr_A: in     vl_logic_vector(4 downto 0);
        iIF_RF_Read_Addr_B: in     vl_logic_vector(4 downto 0);
        oRF_BP_Read_Data_A: out    vl_logic_vector(31 downto 0);
        oRF_BP_Read_Data_B: out    vl_logic_vector(31 downto 0);
        iWB_RF_Write_Addr: in     vl_logic_vector(4 downto 0);
        iWB_RF_Write_Data: in     vl_logic_vector(31 downto 0);
        iWB_RF_Write_Enable: in     vl_logic
    );
end cp_rf;
