# The idea is that the ALU output should have the value of a-b for a compare instruction

###BEGIN: compare instruction output test 4 stage
###TOOL: ${S_AS}
###ARGS: ${FILE} -o cmp-out-4-stage
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:cmp-out-4-stage -arch-param cp-dmem-depth:4,pe-dmem-depth:4 -dump-dmem -dump-dmem-prefix cmp-out-4-stage
###MDUMP: cmp-out-4-stage.baseline.scalar.dump:cmp-out.cp.dmem.ref
###MDUMP: cmp-out-4-stage.baseline.vector.dump:cmp-out.pe.dmem.ref
###END:

###BEGIN: compare instruction output test 4 stage RTL
###TOOL: ${S_CC}
###ARGS: ${FILE} -o cmp-out-4-stage --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json
###RTL: cmp-out-4-stage.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json ${SOLVER_ROOT}/rtl
###MDUMP: cp.dmem.dump:cmp-out.cp.dmem.ref
###MDUMP: pe-array.dmem.dump:cmp-out.pe.dmem.ref
###END:

sflts  ZERO, 5        || v.sflts ZERO, 5
swi    ZERO, ALU, 0   || v.swi   ZERO, ALU, 0
nop
nop
j 0
nop
