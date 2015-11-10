###BEGIN: simple loop 4 stage
###TOOL: ${S_AS}
###ARGS: ${FILE} -arch-param stage:4 -o simple_pe_loop_4_stage -arch-param pe-dwidth:16
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:simple_pe_loop_4_stage -arch-param pe-dwidth:16,cp-dmem-depth:10,pe-dmem-depth:10 -dump-dmem -dump-dmem-prefix simple_pe_loop_4_stage
###MDUMP: simple_pe_loop_4_stage.baseline.scalar.dump
###MDUMP: simple_pe_loop_4_stage.baseline.vector.dump
###END:

# Predication should not affect normal execution
###BEGIN: simple loop 4 stage with predication enabled
###TOOL: ${S_AS}
###ARGS: ${FILE} -arch-param stage:4,predicate:2 -o simple_pe_loop_4_stage -arch-param pe-dwidth:16
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:simple_pe_loop_4_stage -arch-param pe-dwidth:16,cp-dmem-depth:10,pe-dmem-depth:10,predicate:2 -dump-dmem -dump-dmem-prefix simple_pe_loop_4_stage
###MDUMP: simple_pe_loop_4_stage.baseline.scalar.dump
###MDUMP: simple_pe_loop_4_stage.baseline.vector.dump
###END:

addi r3, ZERO, 10 || v.addi r3, ZERO, 10
nop
L:
sfgts ALU, ZERO || v.addi r4, r3, 1
swi ZERO, r3, 1 || v.swi  ZERO, r3, 1
lwi r4, ZERO, 1 || v.addi r3, r3, 1
bf L            || v.lwi  r5, ZERO, 1
addi r3, r3, -1
E:
j E
nop
