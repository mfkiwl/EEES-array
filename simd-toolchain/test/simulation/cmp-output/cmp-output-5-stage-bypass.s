# The idea is that the ALU output should have the value of a-b for a compare instruction

###BEGIN: compare instruction output test 5 stage
###TOOL: ${S_AS}
###ARGS: ${FILE} -o cmp-out-5-stage -arch-param stage:5
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:cmp-out-5-stage -arch-param stage:5,cp-dmem-depth:4,pe-dmem-depth:4 -dump-dmem -dump-dmem-prefix cmp-out-5-stage
###MDUMP: cmp-out-5-stage.baseline.scalar.dump:cmp-out.cp.dmem.ref
###MDUMP: cmp-out-5-stage.baseline.vector.dump:cmp-out.pe.dmem.ref
###END:

sflts  ZERO, 5        || v.sflts ZERO, 5
swi    ZERO, ALU1, 0  || v.swi   ZERO, ALU1, 0
nop
nop
j 0
nop
