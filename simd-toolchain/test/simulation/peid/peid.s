# Test PEID special register: it should be the PE id and cannot be overwritten
###BEGIN: PEID test 4 stage
###TOOL: ${S_AS}
###ARGS: ${FILE} -o peid-4-stage
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:peid-4-stage -arch-param cp-dmem-depth:2,pe-dmem-depth:2 -dump-dmem -dump-dmem-prefix peid
###MDUMP: peid.baseline.vector.dump
###END:

###BEGIN: PEID test 5 stage
###TOOL: ${S_AS}
###ARGS: ${FILE} -o peid-5-stage -arch-param stage:5
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:peid-5-stage -arch-param stage:5,cp-dmem-depth:2,pe-dmem-depth:2 -dump-dmem -dump-dmem-prefix peid
###MDUMP: peid.baseline.vector.dump
###END:

###BEGIN: PEID test 4 stage bypass RTL
###TOOL: ${S_CC}
###ARGS: ${FILE} -o peid-4s-b --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json
###RTL: peid-4s-b.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json ${SOLVER_ROOT}/rtl
###MDUMP: pe-array.dmem.dump:peid.baseline.vector.dump.ref
###END:

###BEGIN: PEID test 4 stage auto-bypass RTL
###TOOL: ${S_CC}
###ARGS: ${FILE} -o peid-4s --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json
###RTL: peid-4s.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage.json ${SOLVER_ROOT}/rtl
###MDUMP: pe-array.dmem.dump:peid.baseline.vector.dump.ref
###END:

v.swi   ZERO, PEID, 0
v.addi  r1, ZERO, 3 # Value should not be committed to PEID, i.e., r1
nop
nop
nop
v.swi   ZERO, PEID, 1
nop
nop
j 0
nop
