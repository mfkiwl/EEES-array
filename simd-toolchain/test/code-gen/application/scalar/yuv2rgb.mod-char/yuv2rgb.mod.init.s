###BEGIN: yuv2rgb.mod-char app 4 stage CP only bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/yuv2rgb.mod.sir -o yuv2rgb.mod-4stage-cp-cg-bypass.s -arch-param cp-dmem-depth:56,pe-dmem-depth:1
###TOOL: ${S_AS}
###ARGS: yuv2rgb.mod-4stage-cp-cg-bypass.s -o yuv2rgb.mod-4stage-cp-bypass
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:yuv2rgb.mod-4stage-cp-bypass -dmem 0:cp:yuv2rgb.mod-4stage-cp-bypass.cp.dmem_init -arch-param pe:4,cp-dmem-depth:56,pe-dmem-depth:1 -dump-dmem -dump-dmem-prefix yuv2rgb.mod -max-cycle 1500
###MDUMP: yuv2rgb.mod.baseline.scalar.dump
###END:
###BEGIN: yuv2rgb.mod-char app 4 stage CP only no bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/yuv2rgb.mod.sir -o yuv2rgb.mod-4stage-cp-cg.s -arch-param bypass:false,cp-dmem-depth:56,pe-dmem-depth:1
###TOOL: ${S_AS}
###ARGS: yuv2rgb.mod-4stage-cp-cg.s -o yuv2rgb.mod-4stage-cp -arch-param bypass:false
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:yuv2rgb.mod-4stage-cp -dmem 0:cp:yuv2rgb.mod-4stage-cp.cp.dmem_init -arch-param pe:4,cp-dmem-depth:56,pe-dmem-depth:1,bypass:false -dump-dmem -dump-dmem-prefix yuv2rgb.mod -max-cycle 1500
###MDUMP: yuv2rgb.mod.baseline.scalar.dump
###END:
###BEGIN: yuv2rgb.mod-char app 5 stage CP only bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/yuv2rgb.mod.sir -arch-param stage:5,cp-dmem-depth:56,pe-dmem-depth:1 -o yuv2rgb.mod-5stage-cp-cg-bypass.s
###TOOL: ${S_AS}
###ARGS: yuv2rgb.mod-5stage-cp-cg-bypass.s -arch-param stage:5 -o yuv2rgb.mod-5stage-cp-bypass
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:yuv2rgb.mod-5stage-cp-bypass -dmem 0:cp:yuv2rgb.mod-5stage-cp-bypass.cp.dmem_init -arch-param pe:4,cp-dmem-depth:56,pe-dmem-depth:1,stage:5 -dump-dmem -dump-dmem-prefix yuv2rgb.mod -max-cycle 1500
###MDUMP: yuv2rgb.mod.baseline.scalar.dump
###END:
###BEGIN: yuv2rgb.mod-char app 5 stage CP only no bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/yuv2rgb.mod.sir -o yuv2rgb.mod-5stage-cp-cg.s -arch-param bypass:false,stage:5,cp-dmem-depth:56,pe-dmem-depth:1
###TOOL: ${S_AS}
###ARGS: yuv2rgb.mod-5stage-cp-cg.s -o yuv2rgb.mod-5stage-cp -arch-param bypass:false,stage:5
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:yuv2rgb.mod-5stage-cp -dmem 0:cp:yuv2rgb.mod-5stage-cp.cp.dmem_init -arch-param pe:4,cp-dmem-depth:56,pe-dmem-depth:1,bypass:false,stage:5 -dump-dmem -dump-dmem-prefix yuv2rgb.mod -max-cycle 1500
###MDUMP: yuv2rgb.mod.baseline.scalar.dump
###END:

###BEGIN: yuv2rgb-char 4 stage RTL
###TOOL: ${S_CC}
###ARGS: ${FILEDIR}/yuv2rgb.mod.sir -o yuv2rgb-char-4 --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json
###RTL: yuv2rgb-char-4.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage.json ${SOLVER_ROOT}/rtl
###MDUMP: cp.dmem.dump:yuv2rgb.mod.baseline.scalar.dump.ref
###END:

###BEGIN: yuv2rgb-char 4 stage RTL
###TOOL: ${S_CC}
###ARGS: ${FILEDIR}/yuv2rgb.mod.sir -o yuv2rgb-char-4-b --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json
###RTL: yuv2rgb-char-4-b.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json ${SOLVER_ROOT}/rtl
###MDUMP: cp.dmem.dump:yuv2rgb.mod.baseline.scalar.dump.ref
###END:
