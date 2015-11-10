# Test Predication Persistency: make sure that predication flag P2 keeps its value as long as it is not updated
###BEGIN: Predication Persistency 4 stage
###TOOL: ${S_AS}
###ARGS: ${FILE} -o predication-persistency-4-stage
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:predication-persistency-4-stage -arch-param cp-dmem-depth:2,pe-dmem-depth:2 -dump-dmem -dump-dmem-prefix predication-persistency-4-stage
###MDUMP: predication-persistency-4-stage.baseline.vector.dump
###END:

###BEGIN: Test Predication Persistency RTL:
###TOOL: ${S_CC}
###ARGS: ${FILE} -o predication-persistency-4-stage --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json
###RTL: predication-persistency-4-stage.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json ${SOLVER_ROOT}/rtl
###MDUMP: pe-array.dmem.dump:predication-persistency-4-stage.baseline.vector.dump.ref
###END:

nop     || v.sfeq    P2, r0,  r0    # set P2 everywhere
nop     || v.sfeq    P1, r0,  r1    # set P1 on PE0
nop     || v.add.P1  r2, r0,  0     # magic command that could break P2 (in RTL)
nop     || v.sw      r0, r0,  0     # dmem[0]=0
nop     || v.add     --, r0,  1
nop     || v.sw.P2   r0, ALU, 0     # if(P2) dmem[0]=1  (should be ALL)
nop
nop
j 0
nop
