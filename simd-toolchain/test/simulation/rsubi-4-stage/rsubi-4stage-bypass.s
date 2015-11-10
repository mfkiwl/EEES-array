# Test RSUBI Ins.
###BEGIN: RSUBI test 4 stage
###TOOL: ${S_AS}
###ARGS: ${FILE} -o peid-4-stage -arch-param pe-dwidth:32,stage:4
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:peid-4-stage -arch-param pe-dwidth:32,stage:4,cp-dmem-depth:2,pe-dmem-depth:2 -dump-dmem -dump-dmem-prefix rsubi
###MDUMP: rsubi.baseline.scalar.dump
###MDUMP: rsubi.baseline.vector.dump
###END:

###BEGIN: RSUBI 4 stage RTL
###TOOL: ${S_CC}
###ARGS: ${FILE} -o rsubi_4stage --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json
###RTL:  rsubi_4stage.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json ${SOLVER_ROOT}/rtl
###MDUMP: cp.dmem.dump:rsubi.baseline.scalar.dump.ref
###MDUMP: pe-array.dmem.dump:rsubi.baseline.vector.dump.ref
###END:

addi    r4, ZERO, 3 || v.addi  r4, ZERO,  7
rsubi   r5,  ALU, 5 || v.rsubi r5,  ALU, 11
nop
nop
nop
swi   ZERO,   r5, 1 || v.swi ZERO, r5, 0
nop
nop
j 0
nop
