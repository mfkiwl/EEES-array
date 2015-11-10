###BEGIN: vector copy 4 stage no bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/copy.sir -bare -init-asm=${FILEDIR}/copy.init.s -o copy-4stage-cg.s -arch-param stage:4,predicate:2,bypass:false
###TOOL: ${S_AS}
###ARGS: copy-4stage-cg.s -o copy-4stage -arch-param stage:4,predicate:2,bypass:false,pe:16
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:copy-4stage -arch-param pe:16,cp-dmem-depth:4,pe-dmem-depth:8,stage:4,predicate:2,bypass:false -dump-dmem -dump-dmem-prefix copy -dmem 0:pe:${FILEDIR}/copy.baseline.vector.dmem_init -max-cycle 1500
###MDUMP: copy.baseline.vector.dump
###END:
###BEGIN: vector copy 5 stage no bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/copy.sir -bare -init-asm=${FILEDIR}/copy.init.s -o copy-5stage-cg.s -arch-param stage:5,predicate:2,bypass:false
###TOOL: ${S_AS}
###ARGS: copy-5stage-cg.s -o copy-5stage -arch-param stage:5,predicate:2,bypass:false,pe:16
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:copy-5stage -arch-param pe:16,cp-dmem-depth:4,pe-dmem-depth:8,stage:5,predicate:2,bypass:false -dump-dmem -dump-dmem-prefix copy -dmem 0:pe:${FILEDIR}/copy.baseline.vector.dmem_init -max-cycle 1500
###MDUMP: copy.baseline.vector.dump
###END:
###BEGIN: vector copy 4 stage bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/copy.sir -bare -init-asm=${FILEDIR}/copy.init.s -o copy-4stage-cg-b.s -arch-param stage:4,predicate:2,bypass:true
###TOOL: ${S_AS}
###ARGS: copy-4stage-cg-b.s -o copy-4stage-b -arch-param stage:4,predicate:2,bypass:true,pe:16
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:copy-4stage-b -arch-param pe:16,cp-dmem-depth:4,pe-dmem-depth:8,stage:4,predicate:2,bypass:true -dump-dmem -dump-dmem-prefix copy -dmem 0:pe:${FILEDIR}/copy.baseline.vector.dmem_init -max-cycle 1500
###MDUMP: copy.baseline.vector.dump
###END:
###BEGIN: vector copy 5 stage bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/copy.sir -bare -init-asm=${FILEDIR}/copy.init.s -o copy-5stage-cg-b.s -arch-param stage:5,predicate:2,bypass:true
###TOOL: ${S_AS}
###ARGS: copy-5stage-cg-b.s -o copy-5stage-b -arch-param stage:5,predicate:2,bypass:true,pe:16
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:copy-5stage-b -arch-param pe:16,cp-dmem-depth:4,pe-dmem-depth:8,stage:5,predicate:2,bypass:true -dump-dmem -dump-dmem-prefix copy -dmem 0:pe:${FILEDIR}/copy.baseline.vector.dmem_init -max-cycle 1500
###MDUMP: copy.baseline.vector.dump
###END:
        addi r1,  ZERO, 16
        addi r13, ZERO, 16
        jal cl_copy_launch
        nop
        j 0
        nop
