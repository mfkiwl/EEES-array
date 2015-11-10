# PE0 sends a value to CP, all other PEs simultaneously shift a value to their neighbor (row-projection into CP)
###BEGIN: CP-PE-PE communication 5 stage bypass
###TOOL: ${S_AS}
###ARGS: ${FILE} -o cp_pe_pe_comm_5_stage_bypass --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage-bypass.json
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:cp_pe_pe_comm_5_stage_bypass -dmem 0:pe:cp_pe_pe_comm_5_stage_bypass.pe.dmem_init --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage-bypass.json --arch-param cp-dmem-depth:1,pe-dmem-depth:1 -dump-dmem -dump-dmem-prefix cp-pe-pe-comm-bypass
###MDUMP: cp-pe-pe-comm-bypass.baseline.scalar.dump
###END:

addi 	--, r0, 0			||	v.lw   --, r0, 0
								v.nop
add		--, h.r0, ALU1		||	v.addi --, r.LSU, 0
add		--, h.r0, ALU1		||	v.addi --, r.ALU1, 0
add		--, h.r0, ALU1		||	v.addi --, r.ALU1, 0
add		--, h.r0, ALU1      ||  v.addi --, ALU1, 0
sw		r0,   ALU1, 0
nop
nop

j 0
nop


        .vdata
        .type          A, @object
        .address       0
        .long          1
        .long          2
        .long          3
        .long          4
        .size          A, 16
