# Test memory access instructions, especial non-word access (LH/SW and LB/SB)
###BEGIN: memory instruction test 4 stage
###TOOL: ${S_AS}
###ARGS: ${FILE} -o memory-access-4-stage -arch-param pe-dwidth:32,stage:4
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:memory-access-4-stage -arch-param pe-dwidth:32,stage:4,cp-dmem-depth:2,pe-dmem-depth:2 -dump-dmem -dump-dmem-prefix memory-access -dmem 0:pe:${FILEDIR}/memory-access.baseline.vector.dmem_init -dmem 0:cp:${FILEDIR}/memory-access.baseline.scalar.dmem_init
###MDUMP: memory-access.baseline.scalar.dump
###MDUMP: memory-access.baseline.vector.dump
###END:

lbi     --,   ZERO, 0 || v.lbi   --,   ZERO, 0
addi    --,   LSU,  2 || v.addi  --,   LSU,  2
sbi     ZERO, ALU,  4 || v.sbi   ZERO, ALU,  4
lhi     --,   ZERO, 0 || v.lhi   --,   ZERO, 0
shi     ZERO, LSU,  3 || v.shi   ZERO, LSU,  3
nop
nop
j 0
nop
