###BEGIN: struct 4 stage bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/struct.sir -o struct-4stage-cp-cg-bypass.s -arch-param cp-dmem-depth:16 -no-sched
###TOOL: ${S_AS}
###ARGS: struct-4stage-cp-cg-bypass.s -o struct-4stage-cp-bypass
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:struct-4stage-cp-bypass -arch-param pe:4,cp-dmem-depth:16,pe-dmem-depth:1 -dump-dmem -dump-dmem-prefix struct -max-cycle 1500
###MDUMP: struct.baseline.scalar.dump
###END:
###BEGIN: struct 4 stage no bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/struct.sir -o struct-4stage-cp-cg.s -arch-param bypass:false,cp-dmem-depth:16 -no-sched
###TOOL: ${S_AS}
###ARGS: struct-4stage-cp-cg.s -o struct-4stage-cp -arch-param bypass:false,cp-dmem-depth:16
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:struct-4stage-cp -arch-param pe:4,cp-dmem-depth:16,pe-dmem-depth:1,bypass:false -dump-dmem -dump-dmem-prefix struct -max-cycle 1500
###MDUMP: struct.baseline.scalar.dump
###END:
###BEGIN: struct 5 stage bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/struct.sir -arch-param stage:5,cp-dmem-depth:16 -o struct-5stage-cp-cg-bypass.s -no-sched
###TOOL: ${S_AS}
###ARGS: struct-5stage-cp-cg-bypass.s -arch-param stage:5,cp-dmem-depth:16 -o struct-5stage-cp-bypass
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:struct-5stage-cp-bypass -arch-param pe:4,cp-dmem-depth:16,pe-dmem-depth:1,stage:5 -dump-dmem -dump-dmem-prefix struct -max-cycle 1500
###MDUMP: struct.baseline.scalar.dump
###END:
###BEGIN: struct 5 stage no bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/struct.sir -o struct-5stage-cp-cg.s -arch-param bypass:false,stage:5,cp-dmem-depth:16 -no-sched
###TOOL: ${S_AS}
###ARGS: struct-5stage-cp-cg.s -o struct-5stage-cp -arch-param bypass:false,stage:5,cp-dmem-depth:16
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:struct-5stage-cp -arch-param pe:4,cp-dmem-depth:16,pe-dmem-depth:1,bypass:false,stage:5 -dump-dmem -dump-dmem-prefix struct -max-cycle 1500
###MDUMP: struct.baseline.scalar.dump
###END:

####BEGIN: struct 4 stage CP only bypass RTL
####TOOL: ${S_CC}
####ARGS: ${FILEDIR}/struct.sir -o struct-4stage-cp-bypass --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json --no-sched
####RTL: struct-4stage-cp-bypass.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json ${SOLVER_ROOT}/rtl
####MDUMP: cp.dmem.dump:struct.baseline.scalar.dump.ref
####END:
