# CP sends a value to all PEs
###BEGIN: CP broadcasting 4 stage
###TOOL: ${S_AS}
###ARGS: ${FILE} -o cp_broadcast_4_stage
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:cp_broadcast_4_stage -dmem 0:cp:cp_broadcast_4_stage.cp.dmem_init -arch-param cp-dmem-depth:1,pe-dmem-depth:1 -dump-dmem -dump-dmem-prefix cp-broadcast
###MDUMP: cp-broadcast.baseline.vector.dump
###END:

###BEGIN: CP broadcasting 4 stage RTL
###TOOL: ${S_CC}
###ARGS: ${FILE} -o cp_broadcast_4_stage --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json
###RTL: cp_broadcast_4_stage.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json ${SOLVER_ROOT}/rtl
###MDUMP: pe-array.dmem.dump:cp-broadcast.baseline.vector.dump.ref
###END:

lwi --,  ZERO,  0
addi --, LSU,   0 || v.addi --,   CP, 0
v.swi ZERO, ALU, 0
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
