# CP non-word memory access (LH/SW and LB/SB)
###BEGIN: CP non-word mem 4 stage
###TOOL: ${S_AS}
###ARGS: ${FILE} -o cp-lb-lh-4-b
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:cp-lb-lh-4-b -dump-dmem -dump-dmem-prefix cp-lb-lh-4-b -dmem 0:cp:cp-lb-lh-4-b.cp.dmem_init
###MDUMP: cp-lb-lh-4-b.baseline.scalar.dump:memory-access.baseline.scalar.dump.ref
###END:

###BEGIN: CP non-word mem 4 stage RTL
###TOOL: ${S_CC}
###ARGS: ${FILE} -o cp-lb-lh-4-b --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json
###RTL: cp-lb-lh-4-b.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json ${SOLVER_ROOT}/rtl
###MDUMP: cp.dmem.dump:memory-access.baseline.scalar.dump.ref
###MSTRICT:
###END:
        lbi     --,   ZERO, 0
        addi    --,   LSU,  2
        sbi     ZERO, ALU,  4
        lhi     --,   ZERO, 0
        shi     ZERO, LSU,  3
        nop
        nop
        j 0
        j 0
        nop

        .data
        .address 0
        .long  0x01020304
        .long 0
        .long 0
        .long 0

