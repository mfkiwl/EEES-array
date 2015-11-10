###BEGIN: communication boundary 5 stage
###TOOL: ${S_AS}
###ARGS: ${FILE} -o comm-boundary-5 -arch-param bypass:false,stage:5
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:comm-boundary-5 -dump-dmem -dump-dmem-prefix comm-boundary-5 -dmem 0:pe:comm-boundary-5.pe.dmem_init -arch-param bypass:false,stage:5
###MDUMP: comm-boundary-5.baseline.vector.dump:comm-boundary.vector.ref
###END:
  addi   r3,   ZERO,  1   # Set to scalar mode
  swi,   ZERO, r3,   -1
  v.lwi  r3,   ZERO,  0
  addi,  r4    r0,    21
  addi,  r0,   r4,    0   ||   v.addi r4, l.r3, 0
  v.swi  ZERO, r4,    1
  v.addi r5,   r.r4,  1
  v.swi  ZERO, r5,    2
  addi   r3,   ZERO,  2   # Set to wrap mode
  swi,   ZERO, r3,   -1
  nop
  v.addi r4,   l.r3,  0
  v.swi  ZERO, r4,    3
  v.addi r5,   r.r4,  1
  v.swi  ZERO, r5,    4
  addi   r3,   ZERO,  3   # Set to self mode
  swi,   ZERO, r3,   -1
  nop
  v.addi r4,   l.r3,  0
  v.swi  ZERO, r4,    5
  v.addi r5,   r.r4,  1
  v.swi  ZERO, r5,    6
  addi   r3,   ZERO,  0   # Set to zero mode
  swi,   ZERO, r3,   -1
  nop
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

