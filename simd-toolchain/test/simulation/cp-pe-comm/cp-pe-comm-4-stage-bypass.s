# PE sends a value to CP
###BEGIN: CP-PE communication 4 stage
###TOOL: ${S_AS}
###ARGS: ${FILE} -o cp_pe_comm_4_stage
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:cp_pe_comm_4_stage -dmem 0:pe:cp_pe_comm_4_stage.pe.dmem_init -arch-param cp-dmem-depth:4,pe-dmem-depth:4 -dump-dmem -dump-dmem-prefix cp-pe-comm
###MDUMP: cp-pe-comm.baseline.scalar.dump
###END:
###BEGIN: CP-PE communication 4 stage RTL
###TOOL: ${S_CC}
###ARGS: ${FILE} -o cp_pe_comm_4stage --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json
###RTL:  cp_pe_comm_4stage.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json ${SOLVER_ROOT}/rtl
###MDUMP: cp.dmem.dump:cp-pe-comm.baseline.scalar.dump.ref
###END:
v.lwi --,   ZERO,  0
addi --, t.ALU, 1 || v.addi --,   l.LSU, 0
swi ZERO, ALU, 0
addi --, h.ALU, 1 || v.addi --,   l.LSU, 0
swi ZERO, ALU, 1
nop
nop
E:
j E
nop

        .vdata
        .type          A, @object
        .address       0
        .long          1
        .long          2
        .long          3
        .long          4
        .size          A, 16
