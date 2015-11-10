###BEGIN: crc32-slow 4 stage CP only bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/crc32-slow.sir -o crc32-slow-4-b.s -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json
###TOOL: ${S_AS}
###ARGS: crc32-slow-4-b.s -o crc32-slow-4-b -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:crc32-slow-4-b -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json  -dump-dmem -dump-dmem-prefix crc32-slow-4-b -dmem 0:cp:crc32-slow-4-b.cp.dmem_init -max-cycle 5000
###MDUMP: crc32-slow-4-b.baseline.scalar.dump:crc32.out.ref
###END:

###BEGIN: crc32-slow 4 stage CP only
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/crc32-slow.sir -o crc32-slow-4.s -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json
###TOOL: ${S_AS}
###ARGS: crc32-slow-4.s -o crc32-slow-4 -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:crc32-slow-4 -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json  -dump-dmem -dump-dmem-prefix crc32-slow-4 -dmem 0:cp:crc32-slow-4.cp.dmem_init -max-cycle 5000
###MDUMP: crc32-slow-4.baseline.scalar.dump:crc32.out.ref
###END:

###BEGIN: crc32-slow 5 stage CP only bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/crc32-slow.sir -o crc32-slow-5-b.s -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage-bypass.json
###TOOL: ${S_AS}
###ARGS: crc32-slow-5-b.s -o crc32-slow-5-b -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage-bypass.json
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:crc32-slow-5-b -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage-bypass.json  -dump-dmem -dump-dmem-prefix crc32-slow-5-b -dmem 0:cp:crc32-slow-5-b.cp.dmem_init -max-cycle 5000
###MDUMP: crc32-slow-5-b.baseline.scalar.dump:crc32.out.ref
###END:

###BEGIN: crc32-slow 5 stage CP only
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/crc32-slow.sir -o crc32-slow-5.s -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage.json
###TOOL: ${S_AS}
###ARGS: crc32-slow-5.s -o crc32-slow-5 -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage.json
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:crc32-slow-5 -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage.json  -dump-dmem -dump-dmem-prefix crc32-slow-5 -dmem 0:cp:crc32-slow-5.cp.dmem_init -max-cycle 5000
###MDUMP: crc32-slow-5.baseline.scalar.dump:crc32.out.ref
###END:

###BEGIN: crc32-fast 4 stage CP only bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/crc32-fast.sir -o crc32-fast-4-b.s -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json
###TOOL: ${S_AS}
###ARGS: crc32-fast-4-b.s -o crc32-fast-4-b -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:crc32-fast-4-b -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json  -dump-dmem -dump-dmem-prefix crc32-fast-4-b -dmem 0:cp:crc32-fast-4-b.cp.dmem_init -max-cycle 25000
###MDUMP: crc32-fast-4-b.baseline.scalar.dump:crc32.out.ref
###END:

###BEGIN: crc32-fast 4 stage CP only
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/crc32-fast.sir -o crc32-fast-4.s -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json
###TOOL: ${S_AS}
###ARGS: crc32-fast-4.s -o crc32-fast-4 -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:crc32-fast-4 -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json  -dump-dmem -dump-dmem-prefix crc32-fast-4 -dmem 0:cp:crc32-fast-4.cp.dmem_init -max-cycle 25000
###MDUMP: crc32-fast-4.baseline.scalar.dump:crc32.out.ref
###END:

###BEGIN: crc32-fast 5 stage CP only bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/crc32-fast.sir -o crc32-fast-5-b.s -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage-bypass.json
###TOOL: ${S_AS}
###ARGS: crc32-fast-5-b.s -o crc32-fast-5-b -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage-bypass.json
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:crc32-fast-5-b -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage-bypass.json  -dump-dmem -dump-dmem-prefix crc32-fast-5-b -dmem 0:cp:crc32-fast-5-b.cp.dmem_init -max-cycle 25000
###MDUMP: crc32-fast-5-b.baseline.scalar.dump:crc32.out.ref
###END:

###BEGIN: crc32-fast 5 stage CP only
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/crc32-fast.sir -o crc32-fast-5.s -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage.json
###TOOL: ${S_AS}
###ARGS: crc32-fast-5.s -o crc32-fast-5 -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage.json
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:crc32-fast-5 -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage.json  -dump-dmem -dump-dmem-prefix crc32-fast-5 -dmem 0:cp:crc32-fast-5.cp.dmem_init -max-cycle 25000
###MDUMP: crc32-fast-5.baseline.scalar.dump:crc32.out.ref
###END:

###BEGIN: crc32-slow 4 stage CP only RTL
###TOOL: ${S_CC}
###ARGS: ${FILEDIR}/crc32-slow.sir -o crc32-slow-4 --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json
###RTL: crc32-slow-4.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage.json ${SOLVER_ROOT}/rtl
###MDUMP: cp.dmem.dump:crc32.out.ref
###END:

###BEGIN: crc32-slow 4 stage CP only bypass RTL
###TOOL: ${S_CC}
###ARGS: ${FILEDIR}/crc32-slow.sir -o crc32-slow-4-b --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json
###RTL: crc32-slow-4-b.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json ${SOLVER_ROOT}/rtl
###MDUMP: cp.dmem.dump:crc32.out.ref
###END:

###BEGIN: crc32-fast 4 stage CP only RTL
###TOOL: ${S_CC}
###ARGS: ${FILEDIR}/crc32-fast.sir -o crc32-fast-4 --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json
###RTL:  crc32-fast-4.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage.json ${SOLVER_ROOT}/rtl
###MDUMP: cp.dmem.dump:crc32.out.ref
###END:

###BEGIN: crc32-fast 4 stage CP only bypass RTL
###TOOL: ${S_CC}
###ARGS: ${FILEDIR}/crc32-fast.sir -o crc32-fast-4-b --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json
###RTL: crc32-fast-4-b.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json ${SOLVER_ROOT}/rtl
###MDUMP: cp.dmem.dump:crc32.out.ref
###END:
