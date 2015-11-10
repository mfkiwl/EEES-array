###BEGIN: bypass test 4 stage
###TOOL: ${S_AS}
###ARGS: ${FILE} -o bypass_reg-bypass
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:bypass_reg-bypass -arch-param cp-dmem-depth:4,pe-dmem-depth:4 -dump-dmem -dump-dmem-prefix bypass_reg
###MDUMP: bypass_reg.baseline.scalar.dump
###MDUMP: bypass_reg.baseline.vector.dump
###END:

###BEGIN: bypass test 4 stage RTL
###TOOL: ${S_CC}
###ARGS: ${FILE} -o bypass_reg_4stage-bypass --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json
###RTL: bypass_reg_4stage-bypass.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json ${SOLVER_ROOT}/rtl
###MDUMP: cp.dmem.dump:bypass_reg.baseline.scalar.dump.ref
###MDUMP: pe-array.dmem.dump:bypass_reg.baseline.vector.dump.ref
###END:

addi WB,   ZERO, 3 || v.addi WB,   ZERO, 4
addi WB,   ZERO, 2 || v.addi WB,   ZERO, 2
swi  ZERO, WB,   0 || v.swi  ZERO, WB,   0
swi  ZERO, WB,   1 || v.swi  ZERO, WB,   1
nop
nop
E:
j E
nop
