# The idea is that the immediate value that doesn't fit in 16+8 bits should be put in memory

###BEGIN: long immediate test 
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/long-imm.sir -o long-imm-4-b.s -no-sched
###TOOL: ${S_AS}
###ARGS: long-imm-4-b.s -o long-imm-4-b
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:long-imm-4-b -dmem 0:cp:long-imm-4-b.cp.dmem_init -dump-dmem -dump-dmem-prefix long-imm-4-b -max-cycle 1500
###MDUMP: long-imm-4-b.baseline.scalar.dump:long-imm.scalar.out.ref
###END:

