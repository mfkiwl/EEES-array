###BEGIN: vector 3-tap convolution OpenCL kernel app 4 stage
###TOOL: ${S_CG}
###ARGS: ${FILE} -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json -arch-param pe:16 -o cl_conv3-4-b.s
###TOOL: ${S_AS}
###ARGS: cl_conv3-4-b.s -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json -arch-param pe:16 -o cl_conv3-4-b
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:cl_conv3-4-b -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json -arch-param pe:16 -dump-dmem -dump-dmem-prefix cl_conv3-4-b -dmem 0:pe:cl_conv3-4-b.pe.dmem_init -dmem 0:cp:cl_conv3-4-b.cp.dmem_init -max-cycle 1500
###MDUMP: cl_conv3-4-b.baseline.vector.dump:cl_conv3.vector.ref
###END:

###BEGIN: vector 3-tap convolution OpenCL kernel app 4 stage no bypass
###TOOL: ${S_CG}
###ARGS: ${FILE} -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json -arch-param pe:16 -o cl_conv3-4.s
###TOOL: ${S_AS}
###ARGS: cl_conv3-4.s -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json -arch-param pe:16 -o cl_conv3-4
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:cl_conv3-4 -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json -arch-param pe:16 -dump-dmem -dump-dmem-prefix cl_conv3-4 -dmem 0:pe:cl_conv3-4.pe.dmem_init -dmem 0:cp:cl_conv3-4.cp.dmem_init -max-cycle 1500
###MDUMP: cl_conv3-4.baseline.vector.dump:cl_conv3.vector.ref
###END:

###BEGIN: vector 3-tap convolution OpenCL kernel app 5 stage
###TOOL: ${S_CG}
###ARGS: ${FILE} -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage-bypass.json -arch-param pe:16 -o cl_conv3-5-b.s
###TOOL: ${S_AS}
###ARGS: cl_conv3-5-b.s -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage-bypass.json -arch-param pe:16 -o cl_conv3-5-b
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:cl_conv3-5-b -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage-bypass.json -arch-param pe:16 -dump-dmem -dump-dmem-prefix cl_conv3-5-b -dmem 0:pe:cl_conv3-5-b.pe.dmem_init -dmem 0:cp:cl_conv3-5-b.cp.dmem_init -max-cycle 1500
###MDUMP: cl_conv3-5-b.baseline.vector.dump:cl_conv3.vector.ref
###END:

###BEGIN: vector 3-tap convolution OpenCL kernel app 5 stage no bypass
###TOOL: ${S_CG}
###ARGS: ${FILE} -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage.json -arch-param pe:16 -o cl_conv3-5.s
###TOOL: ${S_AS}
###ARGS: cl_conv3-5.s -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage.json -arch-param pe:16 -o cl_conv3-5
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:cl_conv3-5 -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage.json -arch-param pe:16 -dump-dmem -dump-dmem-prefix cl_conv3-5 -dmem 0:pe:cl_conv3-5.pe.dmem_init -dmem 0:cp:cl_conv3-5.cp.dmem_init -max-cycle 1500
###MDUMP: cl_conv3-5.baseline.vector.dump:cl_conv3.vector.ref
###END:

####BEGIN: vector 3-tap convolution OpenCL kernel app 4 stage bypass RTL
####TOOL: ${S_CC}
####ARGS: ${FILE} -X sir -o cl_conv3-4-b --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json --arch-param pe:16
####RTL: cl_conv3-4-b.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json ${SOLVER_ROOT}/rtl
####MDUMP: pe-array.dmem.dump:cl_conv3.vector.ref
####END:
    .text
	.globl	cl_conv3
	.align	2
	.type	cl_conv3,@function
	.ent       cl_conv3             # @cl_conv3
cl_conv3:
	.solverkernel
	.frame     %SP,0
# BB#0:                                 # %entry
	args       2
	argspc     1, 3
	argspc     0, 3
	mnum       4
	bb         0
	rli        %a1
	rli        %a0
	sll        %r0, %ITEM_ID.X, 2
	mloc       1
	lw         %r1, %a1, %r0
	mul        %r1, %r1, 67
	add        %r2, %a1, %r0
	mloc       2
	lw         %r3, %r2, -4
	mul        %r3, %r3, -23
	add        %r1, %r1, %r3
	mloc       3
	lw         %r2, %r2, 4
	mul        %r2, %r2, -20
	add        %r1, %r1, %r2
	mloc       4
	sw         %r1, %a0, %r0
	ret        %RA
	.end       cl_conv3
$tmp0:
	.size	cl_conv3, ($tmp0)-cl_conv3

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
	grsize     32, 1, 1
	mov        %r1, samples
        sra        %a1, %r1, 4
	mov        %r0, $out
        sra        %a0, %r0, 4
	call       cl_conv3
	mov        %v0, %ZERO
	ret        %RA
	.end       main
$tmp1:
	.size	main, ($tmp1)-main

    .vdata
    .type $out,@object
$out:
    .long 0
    .long 0
    .long 0
    .long 0
    .long 0
    .long 0
    .long 0
    .long 0
    .long 0
    .long 0
    .long 0
    .long 0
    .long 0
    .long 0
    .long 0
    .long 0
    .long 0
    .long 0
    .long 0
    .long 0
    .long 0
    .long 0
    .long 0
    .long 0
    .long 0
    .long 0
    .long 0
    .long 0
    .long 0
    .long 0
    .long 0
    .long 0
    .size $out,128
    
    .vdata
    .type samples,@object
samples:
    .long 0
    .long 1
    .long 2
    .long 3
    .long 4
    .long 5
    .long 6
    .long 7
    .long 8
    .long 9
    .long 10
    .long 11
    .long 12
    .long 13
    .long 14
    .long 15
    .long 15
    .long 14
    .long 13
    .long 12
    .long 11
    .long 10
    .long 9
    .long 8
    .long 7
    .long 6
    .long 5
    .long 4
    .long 3
    .long 2
    .long 1
    .long 0
    .size samples,128
