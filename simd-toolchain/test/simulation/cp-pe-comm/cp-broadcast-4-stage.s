# CP sends a value to all PEs
###BEGIN: CP broadcasting 4 stage
###TOOL: ${S_AS}
###ARGS: ${FILE} -o cp_broadcast_4_stage
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:cp_broadcast_4_stage -dmem 0:cp:cp_broadcast_4_stage.cp.dmem_init -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json -dump-dmem -dump-dmem-prefix cp-broadcast
###MDUMP: cp-broadcast.baseline.vector.dump
###END:

###BEGIN: CP broadcasting 4 stage RTL
###TOOL: ${S_CC}
###ARGS: ${FILE} -o cp_broadcast_4_stage --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json
###RTL: cp_broadcast_4_stage.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage.json ${SOLVER_ROOT}/rtl
###MDUMP: pe-array.dmem.dump:cp-broadcast.baseline.vector.dump.ref
###END:

lwi   r1,  r0,  0
addi  r1, r1,   0 || v.addi r2, CP, 0
                     v.swi r0, r2,   0
nop
nop
nop
j 0
nop

        .data
        .type    A, @object
        .address 0
        .long    5
        .size    A, 4
