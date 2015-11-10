###BEGIN: multi-cycle operation test
###TOOL: ${S_AS}
###ARGS: ${FILE} -o multi-cycle-op -arch-param pe-dwidth:16,stage:5
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:multi-cycle-op -arch-param stage:5,pe-dwidth:16,cp-dmem-depth:4,pe-dmem-depth:4 -dump-dmem -dump-dmem-prefix multi-cycle-op
###MDUMP: multi-cycle-op.baseline.scalar.dump
###MDUMP: multi-cycle-op.baseline.vector.dump
###END:
addi r1,   ZERO, 3 || v.addi r1,   ZERO, 4
muli WB,   ALU1, 2 || v.muli WB,   ALU1, 2
swi  ZERO, ALU1, 0 || v.swi  ZERO, ALU1, 0
nop
swi  ZERO, WB,   1 || v.swi  ZERO, WB,   1
nop
nop
nop
nop
j 0
nop
