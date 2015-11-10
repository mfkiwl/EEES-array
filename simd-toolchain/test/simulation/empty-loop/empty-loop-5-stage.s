###BEGIN: empty loop 5 stage
###TOOL: ${S_AS}
###ARGS: ${FILE} -o empty_loop_5_stage -arch-param pe-dwidth:16,stage:5
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:empty_loop_5_stage -arch-param pe-dwidth:16,stage:5,cp-dmem-depth:10,pe-dmem-depth:10 -dump-dmem -dump-dmem-prefix empty_loop_5_stage
###MDUMP: empty_loop_5_stage.baseline.scalar.dump
###MDUMP: empty_loop_5_stage.baseline.vector.dump
###END:
nop
addi r3, ZERO, 10
L:
sfgts ALU1, ZERO
swi ZERO, ALU1, 1
nop
nop
lwi r4, ZERO, 1
bf L
addi r3, r3, -1
E:
j E
nop
