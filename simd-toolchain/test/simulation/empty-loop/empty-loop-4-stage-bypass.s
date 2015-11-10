###BEGIN: empty loop 4 stage
###TOOL: ${S_AS}
###ARGS: ${FILE} -o empty_loop_4_stage -arch-param pe-dwidth:16,stage:4
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:empty_loop_4_stage -arch-param pe-dwidth:16,cp-dmem-depth:10,pe-dmem-depth:10 -dump-dmem -dump-dmem-prefix empty_loop_4_stage
###MDUMP: empty_loop_4_stage.baseline.scalar.dump
###MDUMP: empty_loop_4_stage.baseline.vector.dump
###END:

###BEGIN: empty loop 4 stage bypass RTL
###TOOL: ${S_CC}
###ARGS: ${FILE} -o empty_loop-4s-b --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json
###RTL: empty_loop-4s-b.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json ${SOLVER_ROOT}/rtl
###MDUMP: cp.dmem.dump:empty_loop_4_stage.baseline.scalar.dump.ref
###MDUMP: pe-array.dmem.dump:empty_loop_4_stage.baseline.vector.dump.ref
###END:
nop
addi r3, ZERO, 10
L:
sfgts ALU, ZERO
swi ZERO, r3, 1
lwi r4, ZERO, 1
bf L
addi r3, r3, -1
E:
j E
nop
