###BEGIN: CP no explicit bypass 4 stage
###TOOL: ${S_AS}
###ARGS: ${FILE} -o cp_no_exp_bypass_4_stage -arch-param pe-dwidth:16,stage:4,cp-bypass:false
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:cp_no_exp_bypass_4_stage -arch-param pe-dwidth:16,cp-dmem-depth:4,pe-dmem-depth:4,cp-bypass:false -dump-dmem -dump-dmem-prefix cp-no-exp-bypass
###MDUMP: cp-no-exp-bypass.baseline.scalar.dump
###END:
###BEGIN: CP no explicit bypass 5 stage
###TOOL: ${S_AS}
###ARGS: ${FILE} -o cp_no_exp_bypass_5_stage -arch-param pe-dwidth:16,stage:5,cp-bypass:false
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:cp_no_exp_bypass_5_stage -arch-param pe-dwidth:16,cp-dmem-depth:4,pe-dmem-depth:4,stage:5,cp-bypass:false -dump-dmem -dump-dmem-prefix cp-no-exp-bypass
###MDUMP: cp-no-exp-bypass.baseline.scalar.dump
###END:

###BEGIN: CP no explicit bypass 4 stage RTL
###TOOL: ${S_CC}
###ARGS: ${FILE} -o cp_no_exp_bypass_4_stage --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json
###RTL: cp_no_exp_bypass_4_stage.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage.json ${SOLVER_ROOT}/rtl
###MDUMP: cp.dmem.dump:cp-no-exp-bypass.baseline.scalar.dump.ref
###END:

addi r1,  r1, 3
swi ZERO, r1, 0
nop
nop
nop
E:
j E
nop
