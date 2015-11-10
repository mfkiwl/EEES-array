# Test ALU Isolation Automated Bypass: make sure that when the ALU executes a nop, the output of the ALU remains constant
###BEGIN: ALU Isolation test 4 stage
###TOOL: ${S_AS}
###ARGS: ${FILE} -o alu-isolation-4-stage
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:alu-isolation-4-stage -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json -dump-dmem -dump-dmem-prefix alu-isolation
###MDUMP: alu-isolation.baseline.vector.dump
###END:

###BEGIN: Test ALU Isolation RTL Automated Bypass
###TOOL: ${S_CC}
###ARGS: ${FILE} -o alu-isolation-4-stage --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json
###RTL: alu-isolation-4-stage.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage.json ${SOLVER_ROOT}/rtl
###MDUMP: pe-array.dmem.dump:alu-isolation.baseline.vector.dump.ref
###END:

nop || v.add r2, r0, 1
nop || v.sfltu r2, r1
nop || v.cmov r2, r0, 1
nop || v.nop                # insert nop and check if ALU doesn't change
nop || v.sw r0, r2, 0
nop
nop
j 0
nop
