###BEGIN: func 4 stage CP only bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/func.sir -bare -init-asm=${FILEDIR}/func.init.s -o func-4stage-cp-cg-bypass.s -no-sched
###TOOL: ${S_AS}
###ARGS: func-4stage-cp-cg-bypass.s -o func-4stage-cp-bypass
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:func-4stage-cp-bypass -arch-param pe:4,cp-dmem-depth:4,pe-dmem-depth:1 -dump-dmem -dump-dmem-prefix func -max-cycle 1500
###MDUMP: func.baseline.scalar.dump
###END:
###BEGIN: func 4 stage CP only no bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/func.sir -bare -init-asm=${FILEDIR}/func.init.s -o func-4stage-cp-cg.s -arch-param bypass:false -no-sched
###TOOL: ${S_AS}
###ARGS: func-4stage-cp-cg.s -o func-4stage-cp -arch-param bypass:false
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:func-4stage-cp -arch-param pe:4,cp-dmem-depth:4,pe-dmem-depth:1,bypass:false -dump-dmem -dump-dmem-prefix func -max-cycle 1500
###MDUMP: func.baseline.scalar.dump
###END:
###BEGIN: func 5 stage CP only bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/func.sir -bare -init-asm=${FILEDIR}/func.init.s -arch-param stage:5 -o func-5stage-cp-cg-bypass.s -no-sched
###TOOL: ${S_AS}
###ARGS: func-5stage-cp-cg-bypass.s -arch-param stage:5 -o func-5stage-cp-bypass
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:func-5stage-cp-bypass -arch-param pe:4,cp-dmem-depth:4,pe-dmem-depth:1,stage:5 -dump-dmem -dump-dmem-prefix func -max-cycle 1500
###MDUMP: func.baseline.scalar.dump
###END:
###BEGIN: func 5 stage CP only no bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/func.sir -bare -init-asm=${FILEDIR}/func.init.s -o func-5stage-cp-cg.s -arch-param bypass:false,stage:5 -no-sched
###TOOL: ${S_AS}
###ARGS: func-5stage-cp-cg.s -o func-5stage-cp -arch-param bypass:false,stage:5
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:func-5stage-cp -arch-param pe:4,cp-dmem-depth:4,pe-dmem-depth:1,bypass:false,stage:5 -dump-dmem -dump-dmem-prefix func -max-cycle 1500
###MDUMP: func.baseline.scalar.dump
###END:

        addi r1,   r1,   16
        addi r3,   ZERO, 1
        addi r4,   ZERO, 2
        jal  use_add
        addi r5,   ZERO, 3
        swi  ZERO, r11,  0
        nop
        nop
        j 0
        nop
