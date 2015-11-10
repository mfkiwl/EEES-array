###BEGIN: signed extended load
###TOOL: ${S_CG}
###ARGS: ${FILE} -o sext-load.s -arch-param cp-dmem-depth:4 -no-sched
###TOOL: ${S_AS}
###ARGS: sext-load.s -o sext-load
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:sext-load -arch-param pe:4,cp-dmem-depth:4,pe-dmem-depth:1 -dump-dmem -dump-dmem-prefix sext-load -max-cycle 1500 -dmem 0:cp:sext-load.cp.dmem_init
###MDUMP: sext-load.baseline.scalar.dump:sext-load.scalar.dump.ref
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
	lbs        %r0, %r0, 0
	mov        %r1, b
	mloc       2
	sw         %r0, %r1, 0
	mov        %v0, %ZERO
	ret        %RA
	.end       main
$tmp0:
	.size	main, ($tmp0)-main

	.type	a,@object               # @a
	.data
	.globl	a
a:
	.byte	249                     # 0xf9
	.size	a, 1

	.type	b,@object               # @b
	.comm	b,4,4

