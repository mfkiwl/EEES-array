###BEGIN: caller-saved 4 stage CP only bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/caller-saved.sir -o caller-saved-4stage-cp-cg-bypass.s -arch-param cp-dmem-depth:16 -no-sched
###TOOL: ${S_AS}
###ARGS: caller-saved-4stage-cp-cg-bypass.s -o caller-saved-4stage-cp-bypass
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:caller-saved-4stage-cp-bypass -dmem 0:cp:caller-saved-4stage-cp-bypass.cp.dmem_init -arch-param pe:4,cp-dmem-depth:16,pe-dmem-depth:1 -dump-dmem -dump-dmem-prefix caller-saved -max-cycle 1500
###MDUMP: caller-saved.baseline.scalar.dump
###END:
###BEGIN: caller-saved 4 stage CP only no bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/caller-saved.sir -o caller-saved-4stage-cp-cg.s -arch-param bypass:false,cp-dmem-depth:16 -no-sched
###TOOL: ${S_AS}
###ARGS: caller-saved-4stage-cp-cg.s -o caller-saved-4stage-cp -arch-param bypass:false,cp-dmem-depth:16
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:caller-saved-4stage-cp -dmem 0:cp:caller-saved-4stage-cp.cp.dmem_init -arch-param pe:4,cp-dmem-depth:16,pe-dmem-depth:1,bypass:false -dump-dmem -dump-dmem-prefix caller-saved -max-cycle 1500
###MDUMP: caller-saved.baseline.scalar.dump
###END:
###BEGIN: caller-saved 5 stage CP only bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/caller-saved.sir -arch-param stage:5,cp-dmem-depth:16 -o caller-saved-5stage-cp-cg-bypass.s  -no-sched
###TOOL: ${S_AS}
###ARGS: caller-saved-5stage-cp-cg-bypass.s -arch-param stage:5,cp-dmem-depth:16 -o caller-saved-5stage-cp-bypass
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:caller-saved-5stage-cp-bypass -dmem 0:cp:caller-saved-5stage-cp-bypass.cp.dmem_init -arch-param pe:4,cp-dmem-depth:16,pe-dmem-depth:1,stage:5 -dump-dmem -dump-dmem-prefix caller-saved -max-cycle 1500
###MDUMP: caller-saved.baseline.scalar.dump
###END:
###BEGIN: caller-saved 5 stage CP only no bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/caller-saved.sir -o caller-saved-5stage-cp-cg.s -arch-param bypass:false,stage:5,cp-dmem-depth:16 -no-sched
###TOOL: ${S_AS}
###ARGS: caller-saved-5stage-cp-cg.s -o caller-saved-5stage-cp -arch-param bypass:false,stage:5,cp-dmem-depth:16
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:caller-saved-5stage-cp -dmem 0:cp:caller-saved-5stage-cp.cp.dmem_init -arch-param pe:4,cp-dmem-depth:16,pe-dmem-depth:1,bypass:false,stage:5 -dump-dmem -dump-dmem-prefix caller-saved -max-cycle 1500
###MDUMP: caller-saved.baseline.scalar.dump
###END:

###BEGIN: caller-saved 4 stage CP only bypass RTL
###TOOL: ${S_CC}
###ARGS: ${FILEDIR}/caller-saved.sir -o caller-saved-4stage-cp-bypass --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json --no-sched
###RTL: caller-saved-4stage-cp-bypass.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json ${SOLVER_ROOT}/rtl
###MDUMP: cp.dmem.dump:caller-saved.baseline.scalar.dump.ref
###END:
