###BEGIN: dead function elimination
###TOOL: ${S_CG}
###ARGS: ${FILE} -o func-elim.s -arch-param cp-dmem-depth:2 -no-sched
###TOOL: ${S_AS}
###ARGS: func-elim.s -o func-elim
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:func-elim -arch-param pe:4,cp-dmem-depth:2,pe-dmem-depth:1 -dump-dmem -dump-dmem-prefix func-elim -max-cycle 1500
###MDUMP: func-elim.baseline.scalar.dump:func-elim.scalar.dump.ref
###END:
        .text
	.globl	foo
	.align	2
	.type	foo,@function
	.ent       foo                  # @foo
foo:
	.frame     %SP,0
# BB#0:                                 # %entry
	args       2
	mnum       1
	bb         0
	rli        %a1
	rli        %a0
	mloc       1
	sw         %a1, %a0, 0
	ret        %RA
	.end       foo
$tmp0:
	.size	foo, ($tmp0)-foo

	.globl	bar
	.align	2
	.type	bar,@function
	.ent       bar                  # @bar
bar:
	.frame     %SP,0
# BB#0:                                 # %entry
	args       2
	bb         0
	rli        %a1
	rli        %a0
	add        %a1, %a1, 1
	call       foo
	ret        %RA
	.end       bar
$tmp1:
	.size	bar, ($tmp1)-bar

	.globl	main
	.align	2
	.type	main,@function
	.ent       main                 # @main
main:
	.frame     %SP,0
# BB#0:                                 # %entry
	args       0
	rvals      32
	bb         0
	mov        %a0, a
	mov        %a1, 10
	call       foo
	mov        %v0, %ZERO
	ret        %RA
	.end       main
$tmp2:
	.size	main, ($tmp2)-main

	.type	a,@object               # @a
	.comm	a,4,4

