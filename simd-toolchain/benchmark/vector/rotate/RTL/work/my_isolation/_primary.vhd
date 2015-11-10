library verilog;
use verilog.vl_types.all;
entity my_isolation is
    generic(
        ISOLATION_DATA_WIDTH: integer := 32
    );
    port(
        iData_In        : in     vl_logic_vector;
        iIsolation_Signal: in     vl_logic;
        oIsolated_Out   : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ISOLATION_DATA_WIDTH : constant is 1;
end my_isolation;
