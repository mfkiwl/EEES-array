###BEGIN: communication boundary 4 stage Automatic Bypass
###TOOL: ${S_AS}
###ARGS: ${FILE} -o comm-boundary-4-b -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:comm-boundary-4-b -dump-dmem -dump-dmem-prefix comm-boundary-4-b -dmem 0:pe:comm-boundary-4-b.pe.dmem_init -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json
###MDUMP: comm-boundary-4-b.baseline.vector.dump:comm-boundary.vector.ref
###END:

###BEGIN: communication boundary 4 stage RTL Automatic Bypass
###TOOL: ${S_CC}
###ARGS: ${FILE} -o comm-boundary-4-b --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json
###RTL: comm-boundary-4-b.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage.json ${SOLVER_ROOT}/rtl
###MDUMP: pe-array.dmem.dump:comm-boundary.vector.ref
###END:

  addi   r3,   ZERO,  1   # Set to scalar mode
  swi,   ZERO, r3,   -1
  v.lwi  r3,   ZERO,  0
  addi,  r4    r0,    21
  addi,  r0,   r4,    0   ||   v.addi r4, l.r3, 0
  v.swi  ZERO, r4,    1
  addi,  r0,   r4,    0   ||   v.addi r5, r.r4, 1
  v.swi  ZERO, r5,    2
  addi   r3,   ZERO,  2   # Set to wrap mode
  swi,   ZERO, r3,   -1
  v.addi r4,   l.r3,  0
  v.swi  ZERO, r4,    3
  v.addi r5,   r.r4,  1
  v.swi  ZERO, r5,    4
  addi   r3,   ZERO,  3   # Set to self mode
  swi,   ZERO, r3,   -1
  v.addi r4,   l.r3,  0
  v.swi  ZERO, r4,    5
  v.addi r5,   r.r4,  1
  v.swi  ZERO, r5,    6
  addi   r3,   ZERO,  0   # Set to zero mode
  swi,   ZERO, r3,   -1
  v.addi r4,   l.r3,  0
  v.swi  ZERO, r4,    7
  v.addi r5,   r.r4,  1
  v.swi  ZERO, r5,    8
  nop
  nop
  nop
  j 0
  j 0
  nop


.vdata
.address 0
.long 1
.long 2
.long 3
.long 4

