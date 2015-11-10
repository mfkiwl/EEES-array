###BEGIN: vector add 4 stage no bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/add.sir -bare -init-asm=${FILEDIR}/add.init.s -o add-4stage-cg.s -arch-param stage:4,predicate:2,bypass:false
###TOOL: ${S_AS}
###ARGS: add-4stage-cg.s -o add-4stage -arch-param stage:4,predicate:2,bypass:false,pe:16
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:add-4stage -arch-param pe:16,cp-dmem-depth:4,pe-dmem-depth:8,stage:4,predicate:2,bypass:false -dump-dmem -dump-dmem-prefix add -dmem 0:pe:${FILEDIR}/add.baseline.vector.dmem_init -max-cycle 1500
###MDUMP: add.baseline.vector.dump
###END:
###BEGIN: vector add 5 stage no bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/add.sir -bare -init-asm=${FILEDIR}/add.init.s -o add-5stage-cg.s -arch-param stage:5,predicate:2,bypass:false
###TOOL: ${S_AS}
###ARGS: add-5stage-cg.s -o add-5stage -arch-param stage:5,predicate:2,bypass:false,pe:16
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:add-5stage -arch-param pe:16,cp-dmem-depth:4,pe-dmem-depth:8,stage:5,predicate:2,bypass:false -dump-dmem -dump-dmem-prefix add -dmem 0:pe:${FILEDIR}/add.baseline.vector.dmem_init -max-cycle 1500
###MDUMP: add.baseline.vector.dump
###END:
###BEGIN: vector add 4 stage bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/add.sir -bare -init-asm=${FILEDIR}/add.init.s -o add-4stage-cg-b.s -arch-param stage:4,predicate:2,bypass:true
###TOOL: ${S_AS}
###ARGS: add-4stage-cg-b.s -o add-4stage-b -arch-param stage:4,predicate:2,bypass:true,pe:16
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:add-4stage-b -arch-param pe:16,cp-dmem-depth:4,pe-dmem-depth:8,stage:4,predicate:2,bypass:true -dump-dmem -dump-dmem-prefix add -dmem 0:pe:${FILEDIR}/add.baseline.vector.dmem_init -max-cycle 1500
###MDUMP: add.baseline.vector.dump
###END:
###BEGIN: vector add 5 stage bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/add.sir -bare -init-asm=${FILEDIR}/add.init.s -o add-5stage-cg-b.s -arch-param stage:5,predicate:2,bypass:true
###TOOL: ${S_AS}
###ARGS: add-5stage-cg-b.s -o add-5stage-b -arch-param stage:5,predicate:2,bypass:true,pe:16
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:add-5stage-b -arch-param pe:16,cp-dmem-depth:4,pe-dmem-depth:8,stage:5,predicate:2,bypass:true -dump-dmem -dump-dmem-prefix add -dmem 0:pe:${FILEDIR}/add.baseline.vector.dmem_init -max-cycle 1500
###MDUMP: add.baseline.vector.dump
###END:
        addi r1,  ZERO, 16
        addi r13, ZERO, 16
        jal cl_add_launch
        nop
        j 0
        nop
