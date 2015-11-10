###BEGIN: predication test 4 stage
###TOOL: ${S_AS}
###ARGS: ${FILE} -o predication -arch-param stage:4,predicate:2
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:predication -arch-param stage:4,predicate:2,cp-dmem-depth:6,pe-dmem-depth:6 -dump-dmem -dump-dmem-prefix predication -dmem 0:pe:predication.pe.dmem_init -dmem 0:cp:predication.cp.dmem_init
###MDUMP: predication.baseline.scalar.dump
###MDUMP: predication.baseline.vector.dump
###END:

###BEGIN: predication test 4 stage RTL
###TOOL: ${S_CC}
###ARGS: ${FILE} -o predication-4stage --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json
###RTL: predication-4stage.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json ${SOLVER_ROOT}/rtl
###MDUMP: cp.dmem.dump:predication.baseline.scalar.dump.ref
###MDUMP: pe-array.dmem.dump:predication.baseline.vector.dump.ref
###END:
lwi     --,   ZERO, 0 || v.lwi     --,   ZERO, 0
sfgtsi  P1,   LSU,  2 || v.sfgesi  P2,   LSU,  3
addi.P1 r3,   ZERO, 2 || v.addi.P2 r3,   ZERO, 2
swi.P1  ZERO, ALU,  2 || v.swi.P2  ZERO, ALU,  2
lwi     --,   ZERO, 1 || v.lwi     --,   ZERO, 1
sfgtsi  P2,   LSU,  2 || v.sfgesi  P1,   LSU,  6
addi.P2 r4,   ZERO, 2 || v.addi.P1 r4,   ZERO, 3
swi.P2  ZERO, ALU,  3 || v.swi.P1  ZERO, ALU,  3
# Check if the predication works for the add instructions
swi     ZERO, r3,   4 || v.swi     ZERO, r3,   4
swi     ZERO, r4,   5 || v.swi     ZERO, r4,   5
nop
nop
j 0
nop
        .data
        .type    A, @object
        .address 0
        .long    1
        .long    5
        .size    A, 8

        .vdata
        .type    B, @object
        .address 0
        .long    1
        .long    2
        .long    3
        .long    4
        .long    5
        .long    6
        .long    7
        .long    8
        .size    B, 32
