###BEGIN: fir5 app 4 stage CP only bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/fir5.sir -o fir5-4stage-cp-cg-bypass.s -arch-param cp-dmem-depth:32,pe-dmem-depth:1
###TOOL: ${S_AS}
###ARGS: fir5-4stage-cp-cg-bypass.s -o fir5-4stage-cp-bypass
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:fir5-4stage-cp-bypass -arch-param pe:4,cp-dmem-depth:32,pe-dmem-depth:1 -dump-dmem -dump-dmem-prefix fir5 -dmem 0:cp:fir5-4stage-cp-bypass.cp.dmem_init -max-cycle 1500
###MDUMP: fir5.baseline.scalar.dump
###END:
###BEGIN: fir5 4 app stage CP only no bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/fir5.sir -o fir5-4stage-cp-cg.s -arch-param bypass:false,cp-dmem-depth:32,pe-dmem-depth:1
###TOOL: ${S_AS}
###ARGS: fir5-4stage-cp-cg.s -o fir5-4stage-cp -arch-param bypass:false
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:fir5-4stage-cp -arch-param pe:4,cp-dmem-depth:32,pe-dmem-depth:1,bypass:false -dump-dmem -dump-dmem-prefix fir5 -dmem 0:cp:fir5-4stage-cp.cp.dmem_init -max-cycle 1500
###MDUMP: fir5.baseline.scalar.dump
###END:
###BEGIN: fir5 5 app stage CP only bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/fir5.sir -arch-param stage:5,cp-dmem-depth:32,pe-dmem-depth:1 -o fir5-5stage-cp-cg-bypass.s
###TOOL: ${S_AS}
###ARGS: fir5-5stage-cp-cg-bypass.s -arch-param stage:5 -o fir5-5stage-cp-bypass
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:fir5-5stage-cp-bypass -arch-param pe:4,cp-dmem-depth:32,pe-dmem-depth:1,stage:5 -dump-dmem -dump-dmem-prefix fir5 -dmem 0:cp:fir5-5stage-cp-bypass.cp.dmem_init -max-cycle 1500
###MDUMP: fir5.baseline.scalar.dump
###END:
###BEGIN: fir5 5 app stage CP only no bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/fir5.sir -o fir5-5stage-cp-cg.s -arch-param bypass:false,stage:5,cp-dmem-depth:32,pe-dmem-depth:1
###TOOL: ${S_AS}
###ARGS: fir5-5stage-cp-cg.s -o fir5-5stage-cp -arch-param bypass:false,stage:5
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:fir5-5stage-cp -arch-param pe:4,cp-dmem-depth:32,pe-dmem-depth:1,bypass:false,stage:5 -dump-dmem -dump-dmem-prefix fir5 -dmem 0:cp:fir5-5stage-cp.cp.dmem_init -max-cycle 1500
###MDUMP: fir5.baseline.scalar.dump
###END:

###BEGIN: fir5 4 stage CP only RTL
###TOOL: ${S_CC}
###ARGS: ${FILEDIR}/fir5.sir -o fir5-4 --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json
###RTL: fir5-4.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage.json ${SOLVER_ROOT}/rtl
###MDUMP: cp.dmem.dump:fir5.baseline.scalar.dump.ref
###END:

###BEGIN: fir5 4 stage CP only bypass RTL
###TOOL: ${S_CC}
###ARGS: ${FILEDIR}/fir5.sir -o fir5-4stage-cp-bypass --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json
###RTL: fir5-4stage-cp-bypass.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json ${SOLVER_ROOT}/rtl
###MDUMP: cp.dmem.dump:fir5.baseline.scalar.dump.ref
###END:
