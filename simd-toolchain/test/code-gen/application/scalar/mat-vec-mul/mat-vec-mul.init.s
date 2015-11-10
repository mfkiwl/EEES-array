###BEGIN: mat-vec-mul app 4 stage CP only bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/mat-vec-mul.sir -o mat-vec-mul-4stage-cp-cg-bypass.s -arch-param cp-dmem-depth:32,pe-dmem-depth:1
###TOOL: ${S_AS}
###ARGS: mat-vec-mul-4stage-cp-cg-bypass.s -o mat-vec-mul-4stage-cp-bypass
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:mat-vec-mul-4stage-cp-bypass -arch-param pe:4,cp-dmem-depth:32,pe-dmem-depth:1 -dump-dmem -dump-dmem-prefix mat-vec-mul -dmem 0:cp:mat-vec-mul-4stage-cp-bypass.cp.dmem_init -max-cycle 1500
###MDUMP: mat-vec-mul.baseline.scalar.dump
###END:
###BEGIN: mat-vec-mul app 4 stage CP only no bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/mat-vec-mul.sir -o mat-vec-mul-4stage-cp-cg.s -arch-param bypass:false,cp-dmem-depth:32,pe-dmem-depth:1
###TOOL: ${S_AS}
###ARGS: mat-vec-mul-4stage-cp-cg.s -o mat-vec-mul-4stage-cp -arch-param bypass:false
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:mat-vec-mul-4stage-cp -arch-param pe:4,cp-dmem-depth:32,pe-dmem-depth:1,bypass:false -dump-dmem -dump-dmem-prefix mat-vec-mul -dmem 0:cp:mat-vec-mul-4stage-cp.cp.dmem_init -max-cycle 1500
###MDUMP: mat-vec-mul.baseline.scalar.dump
###END:
###BEGIN: mat-vec-mul app 5 stage CP only bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/mat-vec-mul.sir -arch-param stage:5,cp-dmem-depth:32,pe-dmem-depth:1 -o mat-vec-mul-5stage-cp-cg-bypass.s
###TOOL: ${S_AS}
###ARGS: mat-vec-mul-5stage-cp-cg-bypass.s -arch-param stage:5 -o mat-vec-mul-5stage-cp-bypass
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:mat-vec-mul-5stage-cp-bypass -arch-param pe:4,cp-dmem-depth:32,pe-dmem-depth:1,stage:5 -dump-dmem -dump-dmem-prefix mat-vec-mul -dmem 0:cp:mat-vec-mul-5stage-cp-bypass.cp.dmem_init -max-cycle 1500
###MDUMP: mat-vec-mul.baseline.scalar.dump
###END:
###BEGIN: mat-vec-mul app 5 stage CP only no bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/mat-vec-mul.sir -o mat-vec-mul-5stage-cp-cg.s -arch-param bypass:false,stage:5,cp-dmem-depth:32,pe-dmem-depth:1
###TOOL: ${S_AS}
###ARGS: mat-vec-mul-5stage-cp-cg.s -o mat-vec-mul-5stage-cp -arch-param bypass:false,stage:5
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:mat-vec-mul-5stage-cp -arch-param pe:4,cp-dmem-depth:32,pe-dmem-depth:1,bypass:false,stage:5 -dump-dmem -dump-dmem-prefix mat-vec-mul -dmem 0:cp:mat-vec-mul-5stage-cp.cp.dmem_init -max-cycle 1500
###MDUMP: mat-vec-mul.baseline.scalar.dump
###END:

###BEGIN: mat-vec-mul 4 stage CP only RTL
###TOOL: ${S_CC}
###ARGS: ${FILEDIR}/mat-vec-mul.sir -o mat-vec-mul-4 --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json
###RTL: mat-vec-mul-4.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage.json ${SOLVER_ROOT}/rtl
###MDUMP: cp.dmem.dump:mat-vec-mul.baseline.scalar.dump.ref
###END:

###BEGIN: mat-vec-mul 4 stage CP only bypass RTL
###TOOL: ${S_CC}
###ARGS: ${FILEDIR}/mat-vec-mul.sir -o mat-vec-mul-4stage-cp-bypass --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json
###RTL: mat-vec-mul-4stage-cp-bypass.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json ${SOLVER_ROOT}/rtl
###MDUMP: cp.dmem.dump:mat-vec-mul.baseline.scalar.dump.ref
###END:
