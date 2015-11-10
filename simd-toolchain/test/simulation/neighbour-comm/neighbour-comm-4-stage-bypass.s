###BEGIN: neighbour communication 4 stage
###TOOL: ${S_AS}
###ARGS: ${FILE} -o neighbour_comm_4_stage -arch-cfg ${SOLVER_ROOT}/arch/baseline-16b-4stage-bypass.json
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:neighbour_comm_4_stage -arch-cfg ${SOLVER_ROOT}/arch/baseline-16b-4stage-bypass.json -dump-dmem -dump-dmem-prefix neighbour_comm -dmem 0:pe:${FILEDIR}/neighbour_comm.baseline.vector.dmem_init
###MDUMP: neighbour_comm.baseline.vector.dump
###END:

#enabling this test case causes RTL simulation to crash...is 16b implemented?
####BEGIN: neighbour communication 4 stage RTL
####TOOL: ${S_CC}
####ARGS: ${FILE} -o neighbour_comm --arch-cfg ${SOLVER_ROOT}/arch/baseline-16b-4stage-bypass.json
####RTL: neighbour_comm.zip ${SOLVER_ROOT}/arch/baseline-16b-4stage-bypass.json ${SOLVER_ROOT}/rtl
####MDUMP: pe-array.dmem.dump:neighbour_comm.baseline.vector.dump.ref
####END:

v.lwi  --,   ZERO,  0
v.addi r3,   l.LSU, 0
v.swi  ZERO, ALU,   1
v.addi --,   r.r3,  1
v.swi  ZERO, ALU,   2
nop
nop
nop
E:
j E
nop
