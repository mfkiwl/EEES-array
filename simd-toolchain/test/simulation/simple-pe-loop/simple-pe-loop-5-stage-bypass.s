###BEGIN: simple loop 5 stage
###TOOL: ${S_AS}
###ARGS: ${FILE} -o simple_pe_loop_5_stage -arch-param pe-dwidth:16,stage:5
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:simple_pe_loop_5_stage -arch-param pe-dwidth:16,cp-dmem-depth:10,pe-dmem-depth:10,stage:5 -dump-dmem -dump-dmem-prefix simple_pe_loop_5_stage
###MDUMP: simple_pe_loop_5_stage.baseline.scalar.dump
###MDUMP: simple_pe_loop_5_stage.baseline.vector.dump
###END:
addi r3, ZERO, 10 || v.addi r3, ZERO, 10
L:
sfgts ALU1, ZERO
swi ZERO, ALU1, 1
nop               || v.addi r4 ,r3, 2
nop               || v.swi  ZERO, r3, 1
lwi r4, ZERO, 1
bf L              || v.lwi  r5, ZERO, 1
addi r3, r3, -1
E:
j E
nop
