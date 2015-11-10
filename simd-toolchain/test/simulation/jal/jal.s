###BEGIN: jal test 4 stage
###TOOL: ${S_AS}
###ARGS: ${FILE} -o jal
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:jal -arch-param cp-dmem-depth:4,pe-dmem-depth:4 -dump-dmem -dump-dmem-prefix jal
###END:

###BEGIN: jal test 4 stage RTL
###TOOL: ${S_CC}
###ARGS: ${FILE} -o jal_4stage --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json
###RTL: jal_4stage.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json ${SOLVER_ROOT}/rtl
###END:
nop
jal f
nop
j 0
nop

f:
jr r9
nop
