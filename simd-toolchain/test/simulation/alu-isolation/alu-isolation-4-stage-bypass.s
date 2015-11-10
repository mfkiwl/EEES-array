# Test ALU Isolation: make sure that when the ALU executes a nop, the output of the ALU remains constant
###BEGIN: ALU Isolation test 4 stage
###TOOL: ${S_AS}
###ARGS: ${FILE} -o alu-isolation-4-stage-bypass
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:alu-isolation-4-stage-bypass -arch-param cp-dmem-depth:2,pe-dmem-depth:2 -dump-dmem -dump-dmem-prefix alu-isolation
###MDUMP: alu-isolation.baseline.vector.dump
###END:

###BEGIN: Test ALU Isolation RTL
###TOOL: ${S_CC}
###ARGS: ${FILE} -o alu-isolation-4-stage-bypass --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json
###RTL: alu-isolation-4-stage-bypass.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json ${SOLVER_ROOT}/rtl
###MDUMP: pe-array.dmem.dump:alu-isolation.baseline.vector.dump.ref
###END:

nop || v.add --, r0, 1
nop || v.sfltu ALU, r1
nop || v.cmov --, r0, 1
nop || v.nop                # insert nop and check if ALU doesn't change
nop || v.sw r0, ALU, 0
nop
nop
j 0
nop
