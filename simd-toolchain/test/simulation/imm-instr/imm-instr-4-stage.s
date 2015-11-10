###BEGIN: immediate instruction 4 stage Automatic Bypass
###TOOL: ${S_AS}
###ARGS: ${FILE} -o imm_instr_4_stage -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:imm_instr_4_stage -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json -dump-dmem -dump-dmem-prefix imm_instr
###MDUMP: imm_instr.baseline.scalar.dump
###MDUMP: imm_instr.baseline.vector.dump
###END:
###BEGIN: immediate instruction 4 stage RTL Automatic Bypass
###TOOL: ${S_CC}
###ARGS: ${FILE} -o imm_instr_4stage --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json
###RTL:  imm_instr_4stage.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage.json ${SOLVER_ROOT}/rtl
###MDUMP: cp.dmem.dump:imm_instr.baseline.scalar.dump.ref
###MDUMP: pe-array.dmem.dump:imm_instr.baseline.vector.dump.ref
###END:

simm -1             || v.simm -1
addi r1,   r0, 2    || v.addi r2,   r0, 2
swi  r0, r1,  0     || v.swi  r0, r2,  0
zimm 0xFFFF         || v.zimm 0xFFFF
ori  r1,   r0, 0xFF || v.ori  r2,   r0, 0xFF
swi  r0, r1,  1     || v.swi  r0, r2,  1
simm 0              || v.simm 0
addi r1,  r0,  -1   || v.addi r2,   r0, -1
swi  r0, r1,  2     || v.swi  r0, r2,  2
nop
nop
j 0
nop
