###BEGIN: communication boundary 5 stage
###TOOL: ${S_AS}
###ARGS: ${FILE} -o comm-boundary-5-b -arch-param stage:5
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:comm-boundary-5-b -dump-dmem -dump-dmem-prefix comm-boundary-5-b -dmem 0:pe:comm-boundary-5-b.pe.dmem_init -arch-param stage:5
###MDUMP: comm-boundary-5-b.baseline.vector.dump:comm-boundary.vector.ref
###END:
  addi   --,   ZERO,  1   # Set to scalar mode
  swi,   ZERO, ALU1,   -1
  v.lwi  --,   ZERO,  0
  addi,  --    r0,    21
  addi,  --,   ALU1,   0   ||   v.addi r3,   l.LSU, 0
  v.swi  ZERO, ALU1,   1
  v.addi --,   r.ALU2, 1
  v.swi  ZERO, ALU1,   2
  addi   --,   ZERO,  2   # Set to wrap mode
  swi,   ZERO, ALU1,   -1
  nop
  v.addi r3,   l.LSU,  0
  v.swi  ZERO, ALU1,   3
  v.addi r3,   r.ALU2, 1
  v.swi  ZERO, ALU1,   4
  addi   --,   ZERO,  3   # Set to self mode
  swi,   ZERO, ALU1,   -1
  nop
  v.addi r3,   l.LSU,  0
  v.swi  ZERO, ALU1,   5
  v.addi r3,   r.ALU2, 1
  v.swi  ZERO, ALU1,   6
  addi   --,   ZERO,  0   # Set to zero mode
  swi,   ZERO, ALU1,   -1
  nop
  v.addi r3,   l.LSU,  0
  v.swi  ZERO, ALU1,   7
  v.addi r3,   r.ALU2, 1
  v.swi  ZERO, ALU1,   8
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

