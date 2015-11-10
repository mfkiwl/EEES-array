# Test RSUBI Ins.
###BEGIN: RSUBI test 4 stage Automatic Bypass
###TOOL: ${S_AS}
###ARGS: ${FILE} -o peid-4-stage -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:peid-4-stage -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json -dump-dmem -dump-dmem-prefix rsubi
###MDUMP: rsubi.baseline.scalar.dump
###MDUMP: rsubi.baseline.vector.dump
###END:

###BEGIN: RSUBI 4 stage RTL Automatic Bypass
###TOOL: ${S_CC}
###ARGS: ${FILE} -o rsubi_4stage --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json
###RTL:  rsubi_4stage.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage.json ${SOLVER_ROOT}/rtl
###MDUMP: cp.dmem.dump:rsubi.baseline.scalar.dump.ref
###MDUMP: pe-array.dmem.dump:rsubi.baseline.vector.dump.ref
###END:

addi    r4, ZERO, 3 || v.addi  r4, ZERO,  7
rsubi   r5,  r4, 5  || v.rsubi r5,  r4, 11
swi   ZERO,   r5, 1 || v.swi ZERO, r5, 0
nop
nop
j 0
nop
