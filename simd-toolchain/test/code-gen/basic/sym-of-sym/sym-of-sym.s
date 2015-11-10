###BEGIN: symbol of symbol test
###TOOL: ${S_CG}
###ARGS: ${FILE} -o sym-cg.s -no-sched
###TOOL: ${S_AS}
###ARGS: sym-cg.s -o sym-cg
###MDUMP: sym-cg.cp.dmem_init
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
	bb         0
	mov        %v0, a
	ret        %RA
	.end       main
$tmp0:
	.size	main, ($tmp0)-main

	.type	s1,@object              # @s1
	.comm	s1,40,4
	.type	a,@object               # @a
	.data
	.globl	a
	.align	2
a:
	.long	s1
	.long	s2
	.size	a, 8

        .type	s2,@object              # @s2
	.comm	s2,40,4

