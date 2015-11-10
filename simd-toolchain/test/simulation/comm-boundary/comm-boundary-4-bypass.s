###BEGIN: communication boundary 4 stage
###TOOL: ${S_AS}
###ARGS: ${FILE} -o comm-boundary-4-b
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:comm-boundary-4-b -dump-dmem -dump-dmem-prefix comm-boundary-4-b -dmem 0:pe:comm-boundary-4-b.pe.dmem_init
###MDUMP: comm-boundary-4-b.baseline.vector.dump:comm-boundary.vector.ref
###END:

###BEGIN: communication boundary 4 stage RTL
###TOOL: ${S_CC}
###ARGS: ${FILE} -o comm-boundary-4-b_4stage --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json
###RTL: comm-boundary-4-b_4stage.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json ${SOLVER_ROOT}/rtl
###MDUMP: pe-array.dmem.dump:comm-boundary.vector.ref
###END:

  addi   --,   ZERO,  1   # Set to scalar mode
  swi    ZERO, ALU,   -1
  v.lwi  --,   ZERO,  0
  addi   --,   r0,    21
  addi   --,   ALU,   0   ||   v.addi r3,   l.LSU, 0
  v.swi  ZERO, ALU,   1
  addi   --,   ALU,   0   ||   v.addi --,   r.r3,  1
  v.swi  ZERO, ALU,   2
  addi   --,   ZERO,  2   # Set to wrap mode
  swi    ZERO, ALU,   -1
  v.addi r3,   l.LSU, 0
  v.swi  ZERO, ALU,   3
  v.addi r3,   r.r3,  1
  v.swi  ZERO, ALU,   4
  addi   --,   ZERO,  3   # Set to self mode
  swi    ZERO, ALU,   -1
  v.addi r3,   l.LSU, 0
  v.swi  ZERO, ALU,   5
  v.addi r3,   r.r3,  1
  v.swi  ZERO, ALU,   6
  addi   --,   ZERO,  0   # Set to zero mode
  swi    ZERO, ALU,   -1
  v.addi r3,   l.LSU, 0
  v.swi  ZERO, ALU,   7
  v.addi r3,   r.r3,  1
  v.swi  ZERO, ALU,   8
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

