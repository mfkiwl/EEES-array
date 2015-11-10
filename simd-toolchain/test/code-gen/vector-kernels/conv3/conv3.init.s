###BEGIN: vector conv3 4 stage no bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/conv3.sir -bare -init-asm=${FILEDIR}/conv3.init.s -o conv3-4stage-cg.s -arch-param stage:4,predicate:2,bypass:false
###TOOL: ${S_AS}
###ARGS: conv3-4stage-cg.s -o conv3-4stage -arch-param stage:4,predicate:2,bypass:false,pe:16
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:conv3-4stage -arch-param pe:16,cp-dmem-depth:4,pe-dmem-depth:16,stage:4,predicate:2,bypass:false -dump-dmem -dump-dmem-prefix conv3 -dmem 0:pe:${FILEDIR}/conv3.baseline.vector.dmem_init -max-cycle 1500
###MDUMP: conv3.baseline.vector.dump
###END:
###BEGIN: vector conv3 5 stage no bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/conv3.sir -bare -init-asm=${FILEDIR}/conv3.init.s -o conv3-5stage-cg.s -arch-param stage:5,predicate:2,bypass:false
###TOOL: ${S_AS}
###ARGS: conv3-5stage-cg.s -o conv3-5stage -arch-param stage:5,predicate:2,bypass:false,pe:16
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:conv3-5stage -arch-param pe:16,cp-dmem-depth:4,pe-dmem-depth:16,stage:5,predicate:2,bypass:false -dump-dmem -dump-dmem-prefix conv3 -dmem 0:pe:${FILEDIR}/conv3.baseline.vector.dmem_init -max-cycle 1500
###MDUMP: conv3.baseline.vector.dump
###END:
###BEGIN: vector conv3 4 stage bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/conv3.sir -bare -init-asm=${FILEDIR}/conv3.init.s -o conv3-4stage-cg-b.s -arch-param stage:4,predicate:2,bypass:true
###TOOL: ${S_AS}
###ARGS: conv3-4stage-cg-b.s -o conv3-4stage-b -arch-param stage:4,predicate:2,bypass:true,pe:16
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:conv3-4stage-b -arch-param pe:16,cp-dmem-depth:4,pe-dmem-depth:16,stage:4,predicate:2,bypass:true -dump-dmem -dump-dmem-prefix conv3 -dmem 0:pe:${FILEDIR}/conv3.baseline.vector.dmem_init -max-cycle 1500
###MDUMP: conv3.baseline.vector.dump
###END:
###BEGIN: vector conv3 5 stage bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/conv3.sir -bare -init-asm=${FILEDIR}/conv3.init.s -o conv3-5stage-cg-b.s -arch-param stage:5,predicate:2,bypass:true
###TOOL: ${S_AS}
###ARGS: conv3-5stage-cg-b.s -o conv3-5stage-b -arch-param stage:5,predicate:2,bypass:true,pe:16
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:conv3-5stage-b -arch-param pe:16,cp-dmem-depth:4,pe-dmem-depth:16,stage:5,predicate:2,bypass:true -dump-dmem -dump-dmem-prefix conv3 -dmem 0:pe:${FILEDIR}/conv3.baseline.vector.dmem_init -max-cycle 1500
###MDUMP: conv3.baseline.vector.dump
###END:
        addi r1,  ZERO, 16
        addi r13, ZERO, 16
        jal cl_conv3_launch
        nop
        j 0
        nop
