###BEGIN: init register file 4 stage
###TOOL: ${S_AS}
###ARGS: ${FILE} -o init_register_file -arch-param pe-dwidth:16,stage:4
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:init_register_file -arch-param pe-dwidth:16,cp-dmem-depth:32,pe-dmem-depth:32 -dump-dmem -dump-dmem-prefix init_rf
###MDUMP: init_rf.baseline.scalar.dump
###MDUMP: init_rf.baseline.vector.dump
###END:

###BEGIN: init register file 5 stage
###TOOL: ${S_AS}
###ARGS: ${FILE} -o init_register_file -arch-param pe-dwidth:16,stage:5
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:init_register_file -arch-param pe-dwidth:16,cp-dmem-depth:32,pe-dmem-depth:32,stage:5 -dump-dmem -dump-dmem-prefix init_rf
###MDUMP: init_rf.baseline.scalar.dump
###MDUMP: init_rf.baseline.vector.dump
###END:

###BEGIN: init register file 4 stage bypass RTL
###TOOL: ${S_CC}
###ARGS: ${FILE} -o init-rf-4s-b --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json
###RTL: init-rf-4s-b.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json ${SOLVER_ROOT}/rtl
###MDUMP: cp.dmem.dump:init_rf.baseline.scalar.dump.ref
###MDUMP: pe-array.dmem.dump:init_rf.baseline.vector.dump.ref
###END:

###BEGIN: init register file 4 stage auto-bypass RTL
###TOOL: ${S_CC}
###ARGS: ${FILE} -o init-rf-4s --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json
###RTL: init-rf-4s.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage.json ${SOLVER_ROOT}/rtl
###MDUMP: cp.dmem.dump:init_rf.baseline.scalar.dump.ref
###MDUMP: pe-array.dmem.dump:init_rf.baseline.vector.dump.ref
###END:

addi  r1,   ZERO, 1
addi  r2,   ZERO, 2    || v.addi  r2,   ZERO, 2
addi  r3,   ZERO, 3    || v.addi  r3,   ZERO, 3
addi  r4,   ZERO, 4    || v.addi  r4,   ZERO, 4
addi  r5,   ZERO, 5    || v.addi  r5,   ZERO, 5
addi  r6,   ZERO, 6    || v.addi  r6,   ZERO, 6
addi  r7,   ZERO, 7    || v.addi  r7,   ZERO, 7
addi  r8,   ZERO, 8    || v.addi  r8,   ZERO, 8
addi  r9,   ZERO, 9    || v.addi  r9,   ZERO, 9
addi  r10,  ZERO, 10   || v.addi  r10,  ZERO, 10
addi  r11,  ZERO, 11   || v.addi  r11,  ZERO, 11
addi  r12,  ZERO, 12   || v.addi  r12,  ZERO, 12
addi  r13,  ZERO, 13   || v.addi  r13,  ZERO, 13
addi  r14,  ZERO, 14   || v.addi  r14,  ZERO, 14
addi  r15,  ZERO, 15   || v.addi  r15,  ZERO, 15
addi  r16,  ZERO, 16   || v.addi  r16,  ZERO, 16
addi  r17,  ZERO, 17   || v.addi  r17,  ZERO, 17
addi  r18,  ZERO, 18   || v.addi  r18,  ZERO, 18
addi  r19,  ZERO, 19   || v.addi  r19,  ZERO, 19
addi  r20,  ZERO, 20   || v.addi  r20,  ZERO, 20
addi  r21,  ZERO, 21   || v.addi  r21,  ZERO, 21
addi  r22,  ZERO, 22   || v.addi  r22,  ZERO, 22
addi  r23,  ZERO, 23   || v.addi  r23,  ZERO, 23
addi  r24,  ZERO, 24   || v.addi  r24,  ZERO, 24
addi  r25,  ZERO, 25   || v.addi  r25,  ZERO, 25
addi  r26,  ZERO, 26   || v.addi  r26,  ZERO, 26
swi   ZERO, r1,   0
swi   ZERO, r2,   1    || v.swi   ZERO, r2,   1
swi   ZERO, r3,   2    || v.swi   ZERO, r3,   2
swi   ZERO, r4,   3    || v.swi   ZERO, r4,   3
swi   ZERO, r5,   4    || v.swi   ZERO, r5,   4
swi   ZERO, r6,   5    || v.swi   ZERO, r6,   5
swi   ZERO, r7,   6    || v.swi   ZERO, r7,   6
swi   ZERO, r8,   7    || v.swi   ZERO, r8,   7
swi   ZERO, r9,   8    || v.swi   ZERO, r9,   8
swi   ZERO, r10,  9    || v.swi   ZERO, r10,  9
swi   ZERO, r11,  10   || v.swi   ZERO, r11,  10
swi   ZERO, r12,  11   || v.swi   ZERO, r12,  11
swi   ZERO, r13,  12   || v.swi   ZERO, r13,  12
swi   ZERO, r14,  13   || v.swi   ZERO, r14,  13
swi   ZERO, r15,  14   || v.swi   ZERO, r15,  14
swi   ZERO, r16,  15   || v.swi   ZERO, r16,  15
swi   ZERO, r17,  16   || v.swi   ZERO, r17,  16
swi   ZERO, r18,  17   || v.swi   ZERO, r18,  17
swi   ZERO, r19,  18   || v.swi   ZERO, r19,  18
swi   ZERO, r20,  19   || v.swi   ZERO, r20,  19
swi   ZERO, r21,  20   || v.swi   ZERO, r21,  20
swi   ZERO, r22,  21   || v.swi   ZERO, r22,  21
swi   ZERO, r23,  22   || v.swi   ZERO, r23,  22
swi   ZERO, r24,  23   || v.swi   ZERO, r24,  23
swi   ZERO, r25,  24   || v.swi   ZERO, r25,  24
swi   ZERO, r26,  25   || v.swi   ZERO, r26,  25
nop
nop
E:
j E
nop
