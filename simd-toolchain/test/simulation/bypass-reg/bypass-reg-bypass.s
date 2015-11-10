###BEGIN: bypass test 4 stage automatic bypass
###TOOL: ${S_AS}
###ARGS: ${FILE} -o bypass_reg
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:bypass_reg -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json -dump-dmem -dump-dmem-prefix bypass_reg
###MDUMP: bypass_reg.baseline.scalar.dump
###MDUMP: bypass_reg.baseline.vector.dump
###END:

###BEGIN: bypass test 4 stage RTL Autmatic bypass
###TOOL: ${S_CC}
###ARGS: ${FILE} -o bypass_reg_4stage --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json
###RTL: bypass_reg_4stage.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage.json ${SOLVER_ROOT}/rtl
###MDUMP: cp.dmem.dump:bypass_reg.baseline.scalar.dump.ref
###MDUMP: pe-array.dmem.dump:bypass_reg.baseline.vector.dump.ref
###END:

addi r2,   r0, 3 || v.addi r2,   r0, 4
addi r3,   r0, 2 || v.addi r3,   r0, 2
swi  r0, r2,   0 || v.swi  r0, r2,   0
swi  r0, r3,   1 || v.swi  r0, r3,   1
nop
nop
E:
j E
nop
