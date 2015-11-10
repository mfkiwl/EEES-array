###BEGIN: vector long immediate
###TOOL: ${S_CG}
###ARGS: ${FILE} -o vector-long-imm.s
###TOOL: ${S_AS}
###ARGS: vector-long-imm.s -o vector-long-imm
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:vector-long-imm -arch-param pe:4 -dump-dmem -dump-dmem-prefix vector-long-imm -max-cycle 1500 -dmem 0:cp:vector-long-imm.cp.dmem_init
###MDUMP: vector-long-imm.baseline.vector.dump:vector-long-imm.vector.dump.ref
###END:
        .text
	.globl	cl_add_limm
	.align	2
	.type	cl_add_limm,@function
	.ent       cl_add_limm          # @cl_add_limm
cl_add_limm:
	.solverkernel
	.frame     %SP,0
# BB#0:                                 # %entry
	args       2
	argspc     1, 3
	argspc     0, 3
	mnum       2
	bb         0
	rli        %a1
	rli        %a0
	sll        %r0, %GLOBAL_ID.X, 2
	mloc       1
	lw         %r1, %a1, %r0
	add        %r1, %r1, 131071
	mloc       2
	sw         %r1, %a0, %r0
	ret        %RA
	.end       cl_add_limm
$tmp0:
	.size	cl_add_limm, ($tmp0)-cl_add_limm

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
	numgr      1, 1, 1
	grsize     8, 1, 1
	mov        %a1, 2048
	mov        %a0, %ZERO
	call       cl_add_limm
	mov        %v0, %ZERO
	ret        %RA
	.end       main
$tmp1:
	.size	main, ($tmp1)-main


