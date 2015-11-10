if [file exists work] {
    vdel -all
}

vlib work

vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/verilog/pe_array_id.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/verilog/pe_agu.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/verilog/cp_agu.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/verilog/cp_imem.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/verilog/cp_dmem.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/verilog/pe_wb.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/verilog/cp_rf.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/verilog/cp_ex.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/verilog/pe_top.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/verilog/pe_dmem.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/verilog/pe_bypass.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/verilog/cp_id.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/verilog/pe_array_top.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/verilog/pe_id.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/verilog/simd_top.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/verilog/cp_wb.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/verilog/cp_top.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/verilog/cp_if.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/verilog/cp_bypass.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/verilog/my_isolation.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/verilog/pe_imem.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/verilog/pe_rf.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/verilog/pe_array_if.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/verilog/pe_ex.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/verilog/core_top.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL/testbench/simd_top_testbench.v
quit
