###BEGIN: global 4 stage CP only bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/global.sir -o global-4stage-cp-cg-bypass.s -arch-param cp-dmem-depth:16 -no-sched
###TOOL: ${S_AS}
###ARGS: global-4stage-cp-cg-bypass.s -o global-4stage-cp-bypass
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:global-4stage-cp-bypass -dmem 0:cp:global-4stage-cp-bypass.cp.dmem_init -arch-param pe:4,cp-dmem-depth:16,pe-dmem-depth:1 -dump-dmem -dump-dmem-prefix global -max-cycle 1500
###MDUMP: global.baseline.scalar.dump
###END:
###BEGIN: global 4 stage CP only no bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/global.sir -o global-4stage-cp-cg.s -arch-param bypass:false,cp-dmem-depth:16 -no-sched
###TOOL: ${S_AS}
###ARGS: global-4stage-cp-cg.s -o global-4stage-cp -arch-param bypass:false,cp-dmem-depth:16
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:global-4stage-cp -dmem 0:cp:global-4stage-cp.cp.dmem_init -arch-param pe:4,cp-dmem-depth:16,pe-dmem-depth:1,bypass:false -dump-dmem -dump-dmem-prefix global -max-cycle 1500
###MDUMP: global.baseline.scalar.dump
###END:
###BEGIN: global 5 stage CP only bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/global.sir -arch-param stage:5,cp-dmem-depth:16 -o global-5stage-cp-cg-bypass.s -no-sched
###TOOL: ${S_AS}
###ARGS: global-5stage-cp-cg-bypass.s -arch-param stage:5,cp-dmem-depth:16 -o global-5stage-cp-bypass
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:global-5stage-cp-bypass -dmem 0:cp:global-5stage-cp-bypass.cp.dmem_init -arch-param pe:4,cp-dmem-depth:16,pe-dmem-depth:1,stage:5 -dump-dmem -dump-dmem-prefix global -max-cycle 1500
###MDUMP: global.baseline.scalar.dump
###END:
###BEGIN: global 5 stage CP only no bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/global.sir -o global-5stage-cp-cg.s -arch-param bypass:false,stage:5,cp-dmem-depth:16 -no-sched
###TOOL: ${S_AS}
###ARGS: global-5stage-cp-cg.s -o global-5stage-cp -arch-param bypass:false,stage:5,cp-dmem-depth:16
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:global-5stage-cp -dmem 0:cp:global-5stage-cp.cp.dmem_init -arch-param pe:4,cp-dmem-depth:16,pe-dmem-depth:1,bypass:false,stage:5 -dump-dmem -dump-dmem-prefix global -max-cycle 1500
###MDUMP: global.baseline.scalar.dump
###END:

###BEGIN: global 4 stage CP only bypass RTL
###TOOL: ${S_CC}
###ARGS: ${FILEDIR}/global.sir -o global-4stage-cp-bypass --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json
###RTL: global-4stage-cp-bypass.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json ${SOLVER_ROOT}/rtl
###MDUMP: cp.dmem.dump:global.baseline.scalar.dump.ref
###END:

###BEGIN: global 4 stage CPRTL
###TOOL: ${S_CC}
###ARGS: ${FILEDIR}/global.sir -o global-4stage-cp --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json
###RTL: global-4stage-cp.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage.json ${SOLVER_ROOT}/rtl
###MDUMP: cp.dmem.dump:global.baseline.scalar.dump.ref
###END:
