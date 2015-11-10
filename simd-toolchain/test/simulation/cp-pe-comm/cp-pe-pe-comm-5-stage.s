# PE0 sends a value to CP, all other PEs simultaneously shift a value to their neighbor (row-projection into CP)
###BEGIN: CP-PE-PE communication 5 stage
###TOOL: ${S_AS}
###ARGS: ${FILE} -o cp_pe_pe_comm_5_stage
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:cp_pe_pe_comm_5_stage -dmem 0:pe:cp_pe_pe_comm_5_stage.pe.dmem_init --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage.json --arch-param cp-dmem-depth:1,pe-dmem-depth:1  -dump-dmem -dump-dmem-prefix cp-pe-pe-comm
###MDUMP: cp-pe-pe-comm.baseline.scalar.dump
###END:

addi 	r2, r0, 0			||	v.lw   r2, r0, 0
								v.nop
add		r2, h.r0, r2		||	v.addi r2, r.r2, 0
add		r2, h.r0, r2		||	v.addi r2, r.r2, 0
add		r2, h.r0, r2		||	v.addi r2, r.r2, 0
add		r2, h.r0, r2        ||	v.addi r0, r2, 0
sw		r0,   r2, 0
nop
nop

j 0
nop
nop


        .vdata
        .type          A, @object
        .address       0
        .long          1
        .long          2
        .long          3
        .long          4
        .size          A, 16
