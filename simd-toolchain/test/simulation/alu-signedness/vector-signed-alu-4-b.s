# Test ALU signedness problem, related to issue #91
###BEGIN: ALU signedness 4 stage bypass
###TOOL: ${S_AS}
###ARGS: ${FILE} -o alu-signedness-4-b
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:alu-signedness-4-b -dump-dmem -dump-dmem-prefix alu-signedness-4-b
###MDUMP: alu-signedness-4-b.baseline.vector.dump:alu-signedness.vector.ref
###END:

###BEGIN: Test ALU signedness4 stage bypass RTL
###TOOL: ${S_CC}
###ARGS: ${FILE} -o alu-signedness-4-b --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json
###RTL: alu-signedness-4-b.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json ${SOLVER_ROOT}/rtl
###MDUMP: pe-array.dmem.dump:alu-signedness.vector.ref
###END:

v.add    --,  r0, -1
v.sfgtu  ALU, 0
v.add    --,  r0,  1
v.cmov   --,  ALU, 0
v.sw     r0,  ALU, 0
nop
nop
v.add  r2, r0, -1
v.srl  --, ALU, 6
v.sw   r0, MUL, 1
nop
nop
j 0
nop
