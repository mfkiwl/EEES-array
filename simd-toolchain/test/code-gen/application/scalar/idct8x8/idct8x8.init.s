###BEGIN: idct8x8 app 4 stage CP only bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/idct8x8.sir -o idct8x8-4stage-cp-cg-bypass.s
###TOOL: ${S_AS}
###ARGS: idct8x8-4stage-cp-cg-bypass.s -o idct8x8-4stage-cp-bypass
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:idct8x8-4stage-cp-bypass -dump-dmem -dump-dmem-prefix idct8x8 -dmem 0:cp:idct8x8-4stage-cp-bypass.cp.dmem_init -max-cycle 5000
###MDUMP: idct8x8.baseline.scalar.dump
###END:
###BEGIN: idct8x8 app 4 stage CP only no bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/idct8x8.sir -o idct8x8-4stage-cp-cg.s -arch-param bypass:false
###TOOL: ${S_AS}
###ARGS: idct8x8-4stage-cp-cg.s -o idct8x8-4stage-cp -arch-param bypass:false
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:idct8x8-4stage-cp -arch-param bypass:false -dump-dmem -dump-dmem-prefix idct8x8 -dmem 0:cp:idct8x8-4stage-cp.cp.dmem_init -max-cycle 5000
###MDUMP: idct8x8.baseline.scalar.dump
###END:
###BEGIN: idct8x8 app 5 stage CP only bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/idct8x8.sir -arch-param stage:5 -o idct8x8-5-b.s
###TOOL: ${S_AS}
###ARGS: idct8x8-5-b.s -arch-param stage:5 -o idct8x8-5-b
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:idct8x8-5-b -arch-param stage:5 -dump-dmem -dump-dmem-prefix idct8x8-5-b -dmem 0:cp:idct8x8-5-b.cp.dmem_init -max-cycle 5000
###MDUMP: idct8x8-5-b.baseline.scalar.dump:idct8x8.baseline.scalar.dump.ref
###END:
###BEGIN: idct8x8 app 5 stage CP only no bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/idct8x8.sir -o idct8x8-5stage-cp-cg.s -arch-param bypass:false,stage:5
###TOOL: ${S_AS}
###ARGS: idct8x8-5stage-cp-cg.s -o idct8x8-5stage-cp -arch-param bypass:false,stage:5
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:idct8x8-5stage-cp -arch-param bypass:false,stage:5 -dump-dmem -dump-dmem-prefix idct8x8 -dmem 0:cp:idct8x8-5stage-cp.cp.dmem_init -max-cycle 5000
###MDUMP: idct8x8.baseline.scalar.dump
###END:

###BEGIN: idct8x8 4 stage CP only RTL
###TOOL: ${S_CC}
###ARGS: ${FILEDIR}/idct8x8.sir -o idct8x8-4 --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json
###RTL: idct8x8-4.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage.json ${SOLVER_ROOT}/rtl
###MDUMP: cp.dmem.dump:idct8x8.baseline.scalar.dump.ref
###END:

###BEGIN: idct8x8 4 stage CP only bypass RTL
###TOOL: ${S_CC}
###ARGS: ${FILEDIR}/idct8x8.sir -o idct8x8-4stage-cp-bypass --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json
###RTL: idct8x8-4stage-cp-bypass.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json ${SOLVER_ROOT}/rtl
###MDUMP: cp.dmem.dump:idct8x8.baseline.scalar.dump.ref
###END:
