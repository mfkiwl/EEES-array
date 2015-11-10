###BEGIN: immediate instruction 4 stage
###TOOL: ${S_AS}
###ARGS: ${FILE} -o imm_instr_4_stage
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:imm_instr_4_stage -arch-param cp-dmem-depth:4,pe-dmem-depth:4 -dump-dmem -dump-dmem-prefix imm_instr
###MDUMP: imm_instr.baseline.scalar.dump
###MDUMP: imm_instr.baseline.vector.dump
###END:
###BEGIN: immediate instruction 4 stage RTL
###TOOL: ${S_CC}
###ARGS: ${FILE} -o imm_instr_4stage --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json
###RTL:  imm_instr_4stage.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json ${SOLVER_ROOT}/rtl
###MDUMP: cp.dmem.dump:imm_instr.baseline.scalar.dump.ref
###MDUMP: pe-array.dmem.dump:imm_instr.baseline.vector.dump.ref
###END:
simm -1               || v.simm -1
addi r1,   ZERO, 2    || v.addi r1,   ZERO, 2
swi  ZERO, ALU,  0    || v.swi  ZERO, ALU,  0
zimm 0xFFFF           || v.zimm 0xFFFF
ori  r1,   ZERO, 0xFF || v.ori  r1,   ZERO, 0xFF
swi  ZERO, MUL,  1    || v.swi  ZERO, MUL,  1
simm 0                || v.simm 0
addi r1,  ZERO,  -1   || v.addi r1,   ZERO, -1
swi  ZERO, ALU,  2    || v.swi  ZERO, ALU,  2
nop
nop
j 0
nop
