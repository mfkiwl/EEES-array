###BEGIN: Reduction in RF
###TOOL: ${S_AS}
###ARGS: ${FILE} -arch-param dwidth:32,stage:5,bypass:false,pe:32 -o reduce1
###TOOL: ${S_SIM}
###ARGS:  -imem 0:uni:reduce1 -arch-param dwidth:32,stage:5,bypass:false,pe:32 -dump-dmem -dump-dmem-prefix reduce1 -dmem 0:pe:reduce1.pe.dmem_init
###MDUMP: reduce1.baseline.vector.dump
###END:

#init function call
# v.r1	= pe_id
# v.r2-v.r17 are going to be used as vector hold
# v.r18 = address of first element
# v.r19 = used as communication register
# v.r20 = NOT_USED!!!
# v.r21 = masked flag
# v.r22 = address of temp array
#
# cp.r1 = address of first element
# cp.r2 = Number of Vectors
# cp.r4 = address of temp array (can be equal to cp.r1, but then the original vectors will be destroyed!)


add r1, r0, 0
add r2, r0, 16
add r4, r0, 0

$BB0:
#in Mem Reduction Alg1 with m=16
add r0, r1, r1 		|| 	v.addi r18, CP, 0
add r0, r4, r4		||  v.addi r22, CP, 0
srl r3, r2, 4

$BB0_0:
add r3, r3, -1       || v.lw   r2,  r18, 0
						v.lw   r3,  r18, 1
						v.lw   r4,  r18, 2
						v.lw   r5,  r18, 3
						v.lw   r6,  r18, 4
						v.lw   r7,  r18, 5
						v.lw   r8,  r18, 6
						v.lw   r9,  r18, 7
						v.lw   r10, r18, 8
						v.lw   r11, r18, 9
						v.lw   r12, r18, 10
						v.lw   r13, r18, 11
						v.lw   r14, r18, 12
						v.lw   r15, r18, 13
						v.lw   r16, r18, 14
						v.lw   r17, r18, 15

						#reduction round 1, sum with neighbour
						#32 --> 16
						v.add  r2,  r.r2,  r2
						v.add  r3,  r.r3,  r3
						v.add  r4,  r.r4,  r4
						v.add  r5,  r.r5,  r5
						v.add  r6,  r.r6,  r6
						v.add  r7,  r.r7,  r7
						v.add  r8,  r.r8,  r8
						v.add  r9,  r.r9,  r9
						v.add  r10, r.r10, r10
						v.add  r11, r.r11, r11
						v.add  r12, r.r12, r12
						v.add  r13, r.r13, r13
						v.add  r14, r.r14, r14
						v.add  r15, r.r15, r15
						v.add  r16, r.r16, r16
						v.add  r17, r.r17, r17
#if Vlenght==2
#abort here				
						#reduction round 2
						#16 --> 8
					    v.addi r19, r.r2 , 0
						v.add  r2 , r.r19, r2 
						v.addi r19, r.r3 , 0
						v.add  r3 , r.r19, r3 
						v.addi r19, r.r4 , 0
						v.add  r4 , r.r19, r4 
						v.addi r19, r.r5 , 0
						v.add  r5 , r.r19, r5 
						v.addi r19, r.r6 , 0
						v.add  r6 , r.r19, r6 
						v.addi r19, r.r7 , 0
						v.add  r7 , r.r19, r7 
						v.addi r19, r.r8 , 0
						v.add  r8 , r.r19, r8 
						v.addi r19, r.r9 , 0
						v.add  r9 , r.r19, r9 
						v.addi r19, r.r10 , 0
						v.add  r10 , r.r19, r10 
						v.addi r19, r.r11, 0
						v.add  r11, r.r19, r11
						v.addi r19, r.r12, 0
						v.add  r12, r.r19, r12
						v.addi r19, r.r13, 0
						v.add  r13, r.r19, r13
						v.addi r19, r.r14, 0
						v.add  r14, r.r19, r14
						v.addi r19, r.r15, 0
						v.add  r15, r.r19, r15
						v.addi r19, r.r16, 0
						v.add  r16, r.r19, r16	
						v.addi r19, r.r17, 0
						v.add  r17, r.r19, r17						

#if Vlenght==4
#abort here				
						#reduction round 3
						#8 --> 4
						#set flag for pe 3, 7, 11, 15, ...
						v.andi  r21, r1, 3
						v.sfeqi r21, 3
														#start of pipeline lead in
						v.addi r19, r.r2 , 0			#load r2 into r19
						v.addi r19, r.r19, 0			#shift left
						v.cmov r19, r.r3 , r19			#if flag is set, put r3 in r19
						v.addi r19, r.r19, 0			#shift left
						v.cmov r19, r.r4 , r19			#if flag is set, put r4 in r19
														#pipeline filled
						v.add  r2 , r.r19, r2 		#add r19 into r2 						v.addi r19, r.r19, 0			#shift left
						v.addi r19, r.r19, 0
						v.cmov r19, r.r5 , r19			#if flag is set, put r5 in r19
						v.add r3 , r.r19, r3 
						v.addi r19, r.r19, 0
						v.cmov r19, r.r6 , r19 
						v.add r4 , r.r19, r4 
						v.addi r19, r.r19, 0
						v.cmov r19, r.r7 , r19 
						v.add r5 , r.r19, r5 
						v.addi r19, r.r19, 0
						v.cmov r19, r.r8 , r19 
						v.add r6 , r.r19, r6 
						v.addi r19, r.r19, 0
						v.cmov r19, r.r9 , r19 
						v.add r7 , r.r19, r7 
						v.addi r19, r.r19, 0
						v.cmov r19, r.r10 , r19 
						v.add r8 , r.r19, r8 
						v.addi r19, r.r19, 0
						v.cmov r19, r.r11, r19 
						v.add r9 , r.r19, r9 
						v.addi r19, r.r19, 0
						v.cmov r19, r.r12, r19 
						v.add r10 , r.r19, r10 
						v.addi r19, r.r19, 0
						v.cmov r19, r.r13, r19 
						v.add r11, r.r19, r11
						v.addi r19, r.r19, 0
						v.cmov r19, r.r14, r19 
						v.add r12, r.r19, r12
						v.addi r19, r.r19, 0
						v.cmov r19, r.r15, r19 
						v.add r13, r.r19, r13
						v.addi r19, r.r19, 0
						v.cmov r19, r.r16, r19 
						v.add r14, r.r19, r14
						v.addi r19, r.r19, 0
						v.cmov r19, r.r17, r19 
														#start of pipeline lead-out
						v.add r15, r.r19, r15
						v.addi r19, r.r19, 0
						v.add r16, r.r19, r16
						v.addi r19, r.r19, 0
						v.add r17, r.r19, r17

#if Vlenght==8
#abort here									
						#reduction round 4
						#4 --> 2
						#set flag for pe 7, 15 , ...
						v.andi  r21, r1, 7
						v.sfeqi r21, 7
														#start of pipeline lead-in
						v.addi r19, r.r2 , 0			#load r2 into r19
						v.addi r19, r.r19, 0			#shift left
						v.cmov r19, r.r3 , r19			#if flag is set, put r3 in r19
						v.addi r19, r.r19, 0			#shift left
						v.cmov r19, r.r4 , r19			#if flag is set, put r4 in r19
						v.addi r19, r.r19, 0			#shift left
						v.cmov r19, r.r5 , r19			#if flag is set, put r5 in r19
						v.addi r19, r.r19, 0			#shift left
						v.cmov r19, r.r6 , r19			#if flag is set, put r6 in r19
						v.addi r19, r.r19, 0			#shift left
						v.cmov r19, r.r7 , r19			#if flag is set, put r7 in r19
						v.addi r19, r.r19, 0			#shift left
						v.cmov r19, r.r8 , r19			#if flag is set, put r8 in r19
						
						#pipeline filled
						v.add  r2 , r.r19, r2 		#add r19 into r2 						
						v.addi r19, r.r19, 0			#shift left
						v.cmov r19, r.r9 , r19			#if flag is set, put r9 in r19
						v.add r3 , r.r19, r3 
						v.addi r19, r.r19, 0
						v.cmov r19, r.r10 , r19 
						v.add r4 , r.r19, r4 
						v.addi r19, r.r19, 0
						v.cmov r19, r.r11, r19 
						v.add r5 , r.r19, r5 
						v.addi r19, r.r19, 0
						v.cmov r19, r.r12, r19 
						v.add r6 , r.r19, r6 
						v.addi r19, r.r19, 0
						v.cmov r19, r.r13, r19 
						v.add r7 , r.r19, r7 
						v.addi r19, r.r19, 0
						v.cmov r19, r.r14, r19 
						v.add r8 , r.r19, r8 
						v.addi r19, r.r19, 0
						v.cmov r19, r.r15, r19 
						v.add r9 , r.r19, r9 
						v.addi r19, r.r19, 0
						v.cmov r19, r.r16, r19 
						v.add r10 , r.r19, r10 
						v.addi r19, r.r19, 0
						v.cmov r19, r.r17, r19 
													#start pipeline lead-out
						v.add r11, r.r19, r11
						v.addi r19, r.r19, 0
						v.add r12, r.r19, r12
						v.addi r19, r.r19, 0
						v.add r13, r.r19, r13
						v.addi r19, r.r19, 0
						v.add r14, r.r19, r14
						v.addi r19, r.r19, 0
						v.add r15, r.r19, r15
						v.addi r19, r.r19, 0
						v.add r16, r.r19, r16
						v.addi r19, r.r19, 0
						v.add r17, r.r19, r17


#if Vlenght==16
#abort here	
						#reduction round 5
						#2 --> 1
						#set flag for pe 15, ...
						v.andi  r21, r1, 15
						v.sfeqi r21, 15
														#start of pipeline lead-in
						v.addi r19, r.r2 , 0			#load r2 into r19
						v.addi r19, r.r19, 0			#shift left
						v.cmov r19, r.r3 , r19			#if flag is set, put r3 in r19
						v.addi r19, r.r19, 0			#shift left
						v.cmov r19, r.r4 , r19			#if flag is set, put r4 in r19
						v.addi r19, r.r19, 0			#shift left
						v.cmov r19, r.r5 , r19			#if flag is set, put r5 in r19
						v.addi r19, r.r19, 0			#shift left
						v.cmov r19, r.r6 , r19			#if flag is set, put r6 in r19
						v.addi r19, r.r19, 0			#shift left
						v.cmov r19, r.r7 , r19			#if flag is set, put r7 in r19		
						v.addi r19, r.r19, 0
						v.cmov r19, r.r8 , r19
						v.addi r19, r.r19, 0
						v.cmov r19, r.r9 , r19
						v.addi r19, r.r19, 0
						v.cmov r19, r.r10 , r19
						v.addi r19, r.r19, 0
						v.cmov r19, r.r11, r19
						v.addi r19, r.r19, 0
						v.cmov r19, r.r12, r19
						v.addi r19, r.r19, 0
						v.cmov r19, r.r13, r19
						v.addi r19, r.r19, 0
						v.cmov r19, r.r14, r19
						v.addi r19, r.r19, 0
						v.cmov r19, r.r15, r19
						v.addi r19, r.r19, 0
						v.cmov r19, r.r16, r19
						
						v.add  r2,  r.r19, r2 		 #add 
						v.addi r19, r.r19, 0		 #shift
						v.cmov r19, r.r17, r19		 #cmov
						
						v.add  r3,  r.r19, r3 	 	 #add
						v.addi r19, r.r19, 0		 #shift
						v.add  r4 , r.r19, r4        #add
						v.addi r19, r.r19, 0		 #shift
						v.add  r5 , r.r19, r5 
						v.addi r19, r.r19, 0
						v.add  r6 , r.r19, r6 
						v.addi r19, r.r19, 0
						v.add  r7 , r.r19, r7 
						v.addi r19, r.r19, 0
						v.add  r8 , r.r19, r8 
						v.addi r19, r.r19, 0
						v.add  r9 , r.r19, r9 
						v.addi r19, r.r19, 0
						v.add  r10, r.r19, r10 
						v.addi r19, r.r19, 0
						v.add  r11, r.r19, r11
						v.addi r19, r.r19, 0
						v.add  r12, r.r19, r12
						v.addi r19, r.r19, 0
						v.add  r13, r.r19, r13
						v.addi r19, r.r19, 0
						v.add  r14, r.r19, r14
						v.addi r19, r.r19, 0
						v.add  r15, r.r19, r15
						v.addi r19, r.r19, 0
						v.add  r16, r.r19, r16
						v.addi r19, r.r19, 0
						v.add  r17, r.r19, r17

#vector sections of 32 reduced to one column at this point
$BB1_1:					#store results
						v.sw  r22, r2 , 0 
						v.sw  r22, r3 , 1 
						v.sw  r22, r4 , 2 
						v.sw  r22, r5 , 3 
						v.sw  r22, r6 , 4 
						v.sw  r22, r7 , 5 
						v.sw  r22, r8 , 6 
						v.sw  r22, r9 , 7 
						v.sw  r22, r10, 8 
						v.sw  r22, r11, 9
						v.sw  r22, r12, 10
						v.sw  r22, r13, 11
						v.sw  r22, r14, 12
						v.sw  r22, r15, 13
						v.sw  r22, r16, 14					
sfeq r0, r3 		||	v.sw  r22, r17, 15				
bf	$BB0_0			||	v.addi r18, r18, 64				#16*4=64
nop					||	v.addi r22, r22, 64 	


nop || v.nop
nop || v.nop
j 0
nop


#################################################################################################
#
#  INPUT MATRIX
#
#[3, 4, 6, 2, 3, 6, 0, 0, 5, 3, 3, 3, 1, 3, 5, 1, 6, 7, 7, 6, 4, 3, 5, 7, 1, 7, 7, 3, 0, 7, 1, 5]
#[6, 4, 4, 7, 7, 3, 5, 2, 5, 2, 6, 1, 1, 0, 2, 3, 3, 4, 2, 1, 6, 2, 6, 5, 2, 5, 4, 5, 2, 3, 0, 5]
#[4, 2, 2, 1, 1, 3, 5, 0, 7, 7, 4, 2, 6, 5, 0, 4, 1, 0, 1, 3, 6, 7, 2, 4, 1, 0, 1, 0, 1, 1, 6, 1]
#[0, 7, 7, 6, 3, 5, 6, 5, 2, 6, 3, 4, 6, 2, 6, 0, 7, 4, 5, 2, 5, 0, 7, 5, 4, 3, 6, 0, 0, 1, 3, 1]
#[4, 5, 7, 6, 1, 6, 4, 1, 5, 7, 6, 6, 7, 0, 1, 2, 0, 7, 6, 5, 7, 2, 0, 3, 4, 2, 4, 0, 2, 7, 6, 2]
#[5, 5, 2, 6, 3, 7, 1, 5, 1, 6, 3, 1, 6, 2, 3, 1, 5, 4, 1, 5, 3, 7, 0, 0, 0, 6, 2, 6, 3, 7, 0, 4]
#[2, 1, 6, 6, 6, 4, 0, 1, 0, 6, 2, 7, 5, 4, 0, 2, 7, 3, 2, 1, 2, 2, 2, 6, 5, 4, 4, 1, 4, 0, 1, 7]
#[1, 0, 0, 6, 3, 3, 6, 4, 7, 6, 5, 7, 4, 2, 6, 3, 7, 7, 1, 7, 5, 6, 1, 2, 6, 1, 3, 3, 2, 6, 2, 2]
#[7, 4, 7, 5, 3, 1, 5, 1, 6, 7, 2, 2, 4, 5, 5, 4, 7, 7, 7, 6, 2, 7, 0, 5, 1, 7, 3, 5, 3, 2, 0, 3]
#[6, 1, 6, 2, 5, 4, 5, 4, 0, 7, 1, 3, 7, 1, 6, 5, 4, 3, 1, 0, 2, 5, 1, 0, 4, 2, 0, 5, 5, 2, 7, 5]
#[6, 1, 3, 5, 3, 7, 2, 1, 5, 0, 0, 5, 3, 3, 0, 2, 3, 4, 6, 3, 4, 7, 5, 0, 7, 0, 2, 2, 1, 6, 7, 4]
#[6, 4, 6, 4, 1, 2, 3, 1, 0, 1, 2, 3, 2, 0, 2, 0, 6, 1, 4, 7, 5, 3, 2, 3, 7, 0, 2, 3, 4, 6, 5, 5]
#[2, 0, 2, 0, 6, 2, 1, 1, 1, 2, 4, 2, 3, 4, 1, 6, 7, 2, 3, 1, 6, 2, 0, 5, 6, 2, 7, 4, 7, 1, 6, 3]
#[2, 0, 5, 0, 7, 7, 0, 1, 6, 2, 2, 2, 2, 3, 0, 7, 7, 7, 0, 7, 6, 7, 2, 2, 4, 1, 1, 2, 0, 3, 7, 0]
#[4, 5, 4, 0, 2, 1, 4, 2, 3, 4, 7, 0, 3, 7, 3, 0, 1, 0, 4, 1, 2, 3, 1, 6, 5, 5, 6, 0, 1, 0, 3, 1]
#[1, 5, 6, 2, 6, 1, 1, 1, 5, 6, 4, 2, 3, 4, 2, 7, 4, 0, 0, 2, 0, 7, 5, 5, 6, 1, 1, 4, 3, 2, 7, 2]
	.vdata
	.type		a,@object
	.address		0
	.long		3
	.long		4
	.long		6
	.long		2
	.long		3
	.long		6
	.long		0
	.long		0
	.long		5
	.long		3
	.long		3
	.long		3
	.long		1
	.long		3
	.long		5
	.long		1
	.long		6
	.long		7
	.long		7
	.long		6
	.long		4
	.long		3
	.long		5
	.long		7
	.long		1
	.long		7
	.long		7
	.long		3
	.long		0
	.long		7
	.long		1
	.long		5
	.size		a,128
	.type		b,@object
	.address		128
	.long		6
	.long		4
	.long		4
	.long		7
	.long		7
	.long		3
	.long		5
	.long		2
	.long		5
	.long		2
	.long		6
	.long		1
	.long		1
	.long		0
	.long		2
	.long		3
	.long		3
	.long		4
	.long		2
	.long		1
	.long		6
	.long		2
	.long		6
	.long		5
	.long		2
	.long		5
	.long		4
	.long		5
	.long		2
	.long		3
	.long		0
	.long		5
	.size		b,128
	.type		c,@object
	.address		256
	.long		4
	.long		2
	.long		2
	.long		1
	.long		1
	.long		3
	.long		5
	.long		0
	.long		7
	.long		7
	.long		4
	.long		2
	.long		6
	.long		5
	.long		0
	.long		4
	.long		1
	.long		0
	.long		1
	.long		3
	.long		6
	.long		7
	.long		2
	.long		4
	.long		1
	.long		0
	.long		1
	.long		0
	.long		1
	.long		1
	.long		6
	.long		1
	.size		c,128
	.type		d,@object
	.address		384
	.long		0
	.long		7
	.long		7
	.long		6
	.long		3
	.long		5
	.long		6
	.long		5
	.long		2
	.long		6
	.long		3
	.long		4
	.long		6
	.long		2
	.long		6
	.long		0
	.long		7
	.long		4
	.long		5
	.long		2
	.long		5
	.long		0
	.long		7
	.long		5
	.long		4
	.long		3
	.long		6
	.long		0
	.long		0
	.long		1
	.long		3
	.long		1
	.size		d,128
	.type		e,@object
	.address		512
	.long		4
	.long		5
	.long		7
	.long		6
	.long		1
	.long		6
	.long		4
	.long		1
	.long		5
	.long		7
	.long		6
	.long		6
	.long		7
	.long		0
	.long		1
	.long		2
	.long		0
	.long		7
	.long		6
	.long		5
	.long		7
	.long		2
	.long		0
	.long		3
	.long		4
	.long		2
	.long		4
	.long		0
	.long		2
	.long		7
	.long		6
	.long		2
	.size		e,128
	.type		f,@object
	.address		640
	.long		5
	.long		5
	.long		2
	.long		6
	.long		3
	.long		7
	.long		1
	.long		5
	.long		1
	.long		6
	.long		3
	.long		1
	.long		6
	.long		2
	.long		3
	.long		1
	.long		5
	.long		4
	.long		1
	.long		5
	.long		3
	.long		7
	.long		0
	.long		0
	.long		0
	.long		6
	.long		2
	.long		6
	.long		3
	.long		7
	.long		0
	.long		4
	.size		f,128
	.type		g,@object
	.address		768
	.long		2
	.long		1
	.long		6
	.long		6
	.long		6
	.long		4
	.long		0
	.long		1
	.long		0
	.long		6
	.long		2
	.long		7
	.long		5
	.long		4
	.long		0
	.long		2
	.long		7
	.long		3
	.long		2
	.long		1
	.long		2
	.long		2
	.long		2
	.long		6
	.long		5
	.long		4
	.long		4
	.long		1
	.long		4
	.long		0
	.long		1
	.long		7
	.size		g,128
	.type		h,@object
	.address		896
	.long		1
	.long		0
	.long		0
	.long		6
	.long		3
	.long		3
	.long		6
	.long		4
	.long		7
	.long		6
	.long		5
	.long		7
	.long		4
	.long		2
	.long		6
	.long		3
	.long		7
	.long		7
	.long		1
	.long		7
	.long		5
	.long		6
	.long		1
	.long		2
	.long		6
	.long		1
	.long		3
	.long		3
	.long		2
	.long		6
	.long		2
	.long		2
	.size		h,128
	.type		i,@object
	.address		1024
	.long		7
	.long		4
	.long		7
	.long		5
	.long		3
	.long		1
	.long		5
	.long		1
	.long		6
	.long		7
	.long		2
	.long		2
	.long		4
	.long		5
	.long		5
	.long		4
	.long		7
	.long		7
	.long		7
	.long		6
	.long		2
	.long		7
	.long		0
	.long		5
	.long		1
	.long		7
	.long		3
	.long		5
	.long		3
	.long		2
	.long		0
	.long		3
	.size		i,128
	.type		j,@object
	.address		1152
	.long		6
	.long		1
	.long		6
	.long		2
	.long		5
	.long		4
	.long		5
	.long		4
	.long		0
	.long		7
	.long		1
	.long		3
	.long		7
	.long		1
	.long		6
	.long		5
	.long		4
	.long		3
	.long		1
	.long		0
	.long		2
	.long		5
	.long		1
	.long		0
	.long		4
	.long		2
	.long		0
	.long		5
	.long		5
	.long		2
	.long		7
	.long		5
	.size		j,128
	.type		k,@object
	.address		1280
	.long		6
	.long		1
	.long		3
	.long		5
	.long		3
	.long		7
	.long		2
	.long		1
	.long		5
	.long		0
	.long		0
	.long		5
	.long		3
	.long		3
	.long		0
	.long		2
	.long		3
	.long		4
	.long		6
	.long		3
	.long		4
	.long		7
	.long		5
	.long		0
	.long		7
	.long		0
	.long		2
	.long		2
	.long		1
	.long		6
	.long		7
	.long		4
	.size		k,128
	.type		l,@object
	.address		1408
	.long		6
	.long		4
	.long		6
	.long		4
	.long		1
	.long		2
	.long		3
	.long		1
	.long		0
	.long		1
	.long		2
	.long		3
	.long		2
	.long		0
	.long		2
	.long		0
	.long		6
	.long		1
	.long		4
	.long		7
	.long		5
	.long		3
	.long		2
	.long		3
	.long		7
	.long		0
	.long		2
	.long		3
	.long		4
	.long		6
	.long		5
	.long		5
	.size		l,128
	.type		m,@object
	.address		1536
	.long		2
	.long		0
	.long		2
	.long		0
	.long		6
	.long		2
	.long		1
	.long		1
	.long		1
	.long		2
	.long		4
	.long		2
	.long		3
	.long		4
	.long		1
	.long		6
	.long		7
	.long		2
	.long		3
	.long		1
	.long		6
	.long		2
	.long		0
	.long		5
	.long		6
	.long		2
	.long		7
	.long		4
	.long		7
	.long		1
	.long		6
	.long		3
	.size		m,128
	.type		n,@object
	.address		1664
	.long		2
	.long		0
	.long		5
	.long		0
	.long		7
	.long		7
	.long		0
	.long		1
	.long		6
	.long		2
	.long		2
	.long		2
	.long		2
	.long		3
	.long		0
	.long		7
	.long		7
	.long		7
	.long		0
	.long		7
	.long		6
	.long		7
	.long		2
	.long		2
	.long		4
	.long		1
	.long		1
	.long		2
	.long		0
	.long		3
	.long		7
	.long		0
	.size		n,128
	.type		o,@object
	.address		1792
	.long		4
	.long		5
	.long		4
	.long		0
	.long		2
	.long		1
	.long		4
	.long		2
	.long		3
	.long		4
	.long		7
	.long		0
	.long		3
	.long		7
	.long		3
	.long		0
	.long		1
	.long		0
	.long		4
	.long		1
	.long		2
	.long		3
	.long		1
	.long		6
	.long		5
	.long		5
	.long		6
	.long		0
	.long		1
	.long		0
	.long		3
	.long		1
	.size		o,128
	.type		p,@object
	.address		1920
	.long		1
	.long		5
	.long		6
	.long		2
	.long		6
	.long		1
	.long		1
	.long		1
	.long		5
	.long		6
	.long		4
	.long		2
	.long		3
	.long		4
	.long		2
	.long		7
	.long		4
	.long		0
	.long		0
	.long		2
	.long		0
	.long		7
	.long		5
	.long		5
	.long		6
	.long		1
	.long		1
	.long		4
	.long		3
	.long		2
	.long		7
	.long		2
	.size		p,128
