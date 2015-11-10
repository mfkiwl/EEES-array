if [file exists work] {
    vdel -all
}

vlib work

vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/verilog/pe_array_id.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/verilog/pe_agu.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/verilog/cp_agu.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/verilog/cp_imem.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/verilog/cp_dmem.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/verilog/pe_wb.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/verilog/cp_rf.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/verilog/cp_ex.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/verilog/pe_top.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/verilog/pe_dmem.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/verilog/pe_bypass.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/verilog/cp_id.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/verilog/pe_array_top.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/verilog/pe_id.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/verilog/simd_top.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/verilog/cp_wb.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/verilog/cp_top.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/verilog/cp_if.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/verilog/cp_bypass.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/verilog/my_isolation.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/verilog/pe_imem.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/verilog/pe_rf.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/verilog/pe_array_if.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/verilog/pe_ex.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/verilog/core_top.v
vlog -quiet +incdir+/home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/define /home/shahnawaz/simd-toolchain/benchmark/vector/rotate/RTL-baseline-32b-4stage-bypass/testbench/simd_top_testbench.v
quit
