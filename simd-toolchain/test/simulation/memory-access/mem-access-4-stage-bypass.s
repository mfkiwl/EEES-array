# Test memory access instructions, especial non-word access (LH/SW and LB/SB)
###BEGIN: lb/lh mem instruction test 4 stage
###TOOL: ${S_AS}
###ARGS: ${FILE} -o mem-access-4-b
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:mem-access-4-b -dump-dmem -dump-dmem-prefix mem-access-4-b -dmem 0:pe:mem-access-4-b.pe.dmem_init -dmem 0:cp:mem-access-4-b.cp.dmem_init
###MDUMP: mem-access-4-b.baseline.scalar.dump:memory-access.baseline.scalar.dump.ref
###MDUMP: mem-access-4-b.baseline.vector.dump:memory-access.baseline.vector.dump.ref
###END:

###BEGIN: lb/lh mem instruction test 4 stage RTL
###TOOL: ${S_CC}
###ARGS: ${FILE} -o mem-access-4-b --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json
###RTL: mem-access-4-b.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json ${SOLVER_ROOT}/rtl
###MDUMP: cp.dmem.dump:memory-access.baseline.scalar.dump.ref
###MDUMP: pe-array.dmem.dump:memory-access.baseline.vector.dump.ref
###END:

lbi     --,   ZERO, 0 || v.lbi   --,   ZERO, 0
addi    --,   LSU,  2 || v.addi  --,   LSU,  2
sbi     ZERO, ALU,  4 || v.sbi   ZERO, ALU,  4
lhi     --,   ZERO, 0 || v.lhi   --,   ZERO, 0
shi     ZERO, LSU,  3 || v.shi   ZERO, LSU,  3
nop
nop
j 0
nop

        .data
        .address 0
        .long  0x01020304
        .long 0
        .long 0
        .long 0

.vdata
.address 0
.long 0x00010203
.long 0x04050607
.long 0x08090a0b
.long 0x0c0d0e0f

