onbreak {resume}

if { [file exists work]  == 0 } {
    puts stderr "Library \"work\" not found, please run compilation first."
    exit -code 1
}

if { [file exists cp.imem_init]  == 0 } {
    puts stderr "Cannot find cp.imem_init, aborting."
    exit -code 1
}

vsim -quiet -nostdout -novopt work.simd_top_testbench

run -all
run -all
quit
