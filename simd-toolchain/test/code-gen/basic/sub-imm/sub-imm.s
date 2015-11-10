###BEGIN: sub imm
###TOOL: ${S_CG}
###ARGS: ${FILE} -o sub-imm.s -arch-param cp-dmem-depth:4 -no-sched
###TOOL: ${S_AS}
###ARGS: sub-imm.s -o sub-imm
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:sub-imm -arch-param pe:4,cp-dmem-depth:4,pe-dmem-depth:1 -dump-dmem -dump-dmem-prefix sub-imm -max-cycle 1500 -dmem 0:cp:sub-imm.cp.dmem_init
###MDUMP: sub-imm.baseline.scalar.dump:sub-imm.scalar.dump.ref
###END:
	.text
	.globl	main
	.align	2
	.type	main,@function
	.ent       main                 # @main
main:
	.frame     %SP,0
# BB#0:                                 # %entry
	args       0
	rvals      32
	mnum       2
	bb         0
	mov        %r0, a
	mloc       1
	lw         %r1, %r0, 0
	sub        %r1, %r1, 10
	mloc       2
	sw         %r1, %r0, 0
	mov        %v0, %ZERO
	ret        %RA
	.end       main
$tmp0:
	.size	main, ($tmp0)-main

	.type	a,@object               # @a
	.data
	.globl	a
a:
	.long	12
	.size	a, 4


