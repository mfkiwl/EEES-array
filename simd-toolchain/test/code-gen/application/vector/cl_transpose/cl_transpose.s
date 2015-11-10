###BEGIN: vector transpose OpenCL 4 stage
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/transpose.sir ${SOLVER_ROOT}/usr/lib/libsolver.sir -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json -o transpose-4-b.s
###TOOL: ${S_AS}
###ARGS: transpose-4-b.s -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json -o transpose-4-b
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:transpose-4-b -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json -dump-dmem -dump-dmem-prefix transpose-4-b -dmem 0:pe:transpose-4-b.pe.dmem_init -dmem 0:cp:transpose-4-b.cp.dmem_init -max-cycle 1500
###MDUMP: transpose-4-b.baseline.vector.dump:transpose.vector.ref
###END:

###BEGIN: vector transpose OpenCL 4 stage no bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/transpose.sir ${SOLVER_ROOT}/usr/lib/libsolver.sir -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json -o transpose-4.s
###TOOL: ${S_AS}
###ARGS: transpose-4.s -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json -o transpose-4
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:transpose-4 -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json -dump-dmem -dump-dmem-prefix transpose-4 -dmem 0:pe:transpose-4.pe.dmem_init -dmem 0:cp:transpose-4.cp.dmem_init -max-cycle 1500
###MDUMP: transpose-4.baseline.vector.dump:transpose.vector.ref
###END:

###BEGIN: vector transpose OpenCL 5 stage
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/transpose.sir ${SOLVER_ROOT}/usr/lib/libsolver.sir -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage-bypass.json -o transpose-5-b.s
###TOOL: ${S_AS}
###ARGS: transpose-5-b.s -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage-bypass.json -o transpose-5-b
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:transpose-5-b -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage-bypass.json -dump-dmem -dump-dmem-prefix transpose-5-b -dmem 0:pe:transpose-5-b.pe.dmem_init -dmem 0:cp:transpose-5-b.cp.dmem_init -max-cycle 1500
###MDUMP: transpose-5-b.baseline.vector.dump:transpose.vector.ref
###END:

###BEGIN: vector transpose OpenCL 5 stage no bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/transpose.sir ${SOLVER_ROOT}/usr/lib/libsolver.sir -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage.json -o transpose-5.s
###TOOL: ${S_AS}
###ARGS: transpose-5.s -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage.json -o transpose-5
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:transpose-5 -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage.json -dump-dmem -dump-dmem-prefix transpose-5 -dmem 0:pe:transpose-5.pe.dmem_init -dmem 0:cp:transpose-5.cp.dmem_init -max-cycle 1500
###MDUMP: transpose-5.baseline.vector.dump:transpose.vector.ref
###END:

###BEGIN: vector transpose OpenCL 4 stage RTL
###TOOL: ${S_CC}
###ARGS: ${FILEDIR}/transpose.sir -lsolver --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json -o transpose-4
###RTL: transpose-4.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage.json ${SOLVER_ROOT}/rtl
###MDUMP: pe-array.dmem.dump:transpose.vector.ref
###END:

###BEGIN: vector transpose OpenCL 4 stage bypass RTL
###TOOL: ${S_CC}
###ARGS: ${FILEDIR}/transpose.sir -lsolver --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json -o transpose-4-b
###RTL: transpose-4-b.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json ${SOLVER_ROOT}/rtl
###MDUMP: pe-array.dmem.dump:transpose.vector.ref
###END:
