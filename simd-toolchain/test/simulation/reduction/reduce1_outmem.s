###BEGIN: Reduction out RF (using memory accesses)
###TOOL: ${S_AS}
###ARGS: ${FILE} -arch-param dwidth:32,stage:5,bypass:false,pe:32,predicate:2 -o reduce1_outmem
###TOOL: ${S_SIM}
###ARGS:  -imem 0:uni:reduce1_outmem -arch-param dwidth:32,stage:5,bypass:false,pe:32,predicate:2 -dump-dmem -dump-dmem-prefix reduce1_outmem -dmem 0:pe:reduce1_outmem.pe.dmem_init
###MDUMP: reduce1_outmem.baseline.vector.dump
###END:

#r1==number of vectors
#r5==up to which round should we reduce? (start at 0 with couting) [  2^log(number_of_elements) -1 (correct for zero start)  ]
add r1, r0, 16		# 16 vectors
add r10, r0, 4		# 2^log(32)-1 = 4

#############################
#  Reduce
#
add r2, r0, 1
$BB1_4:
add r3, r0, 0
add r4, r0, 0
jal Round
nop
sfeq r2, r10
bnf $BB1_4
add r2, r2, 1


#end of program
j 0
nop
nop
#############################

$DEBUG:
#debug: predication check
# 3 = PE that adds and stores
# 4 = PE that loads onto bus
# 5 = PE that load new element
#v.add r12, r0, 4
#v.cmov r12, r12, r0
#v.sw r0, r12, 0
#v.add r10, r0, 5
#v.add r11, r0, 3
#v.sw.P1 r0, r10, 0
#v.sw.P2 r0, r11, 0

sw r0, r7, 0 || v.sw r0, r4, 0
sw r0, r8, 1
nop || v.nop
nop || v.nop
j 0
nop
nop


#############################
#  Round(r1=number of vectors, r2=round number, r3=src_vector* , r4=dst_vector*)
#  DOES NOT WORK FOR ROUND 0 !!! WRITE DIFFERENT CODE FOR THIS (or just use the in mem approach wich is going to be faster for round 0 anyway)
#
# U is user set!
#Ur1 = Number of vectors
#Ur2 = Round Number					# v.r2 = 2^roundNumber  
#Ur3 = First element addr			# v.r3 and v.r4 are used as temps
#Ur4 = store addr (can be == r3)	# P1 = P1 are PEs that should load
#r5=stop addr lead in				# P2 = P2 are PEs that should add and store
#r6=stop addr middle part
#r7 = load pointer
#r8 = stop address to determine end of lead-out (relative to load pointer)
#r11 = 2^r-1 = number of leadins and outs

Round:
addi 	r8, r0, 1					
sll 	r8, r8, r2				#set predicates	
add   	r8, r8, -1				||	v.add 		r2, CP, 0  	#we need R2, do not simplify by combining with next instruction!
sll		r8, r8, 2				||	v.sll   	r3, r2, 1

add 	r5, r3, r8				||	v.add   	r3, r3, -1	#r3 = mask
sll		r11, r1, 2				||	v.and   	r4, r1, r3
add     r6, r3, r11				||	v.sfeq		P1, r4, r2	#P1 is PE that should load
add 	r7, r3, 0				||	v.sfeq 		P2, r4, r0  #P2 is PE that should add and store
add     r8, r7, r11				||	v.add 		r3, r2, -1
									v.sfeq		r4, r3		#normal flag is set of PE that conditionally loads onto comm bus

									#pipeline lead-in (always odd number of times, is used to get good schedule)
add r3, r3, 4					||	v.lw.P1 	r3, CP, 0		#load next element
sfeq r3, r5						||	v.addi  	r4, r.r4, 0		#shift left
bf $BB1_1						||	v.cmov 		r4, r.r3, r4	#conditionaly load new element onto the pipeline	
nop

$BB1_0:
addi r3, r3, 8					||	v.lw.P1 	r3, CP, 0
sfeq r3, r5						||	v.addi  	r4, r.r4, 0
									v.cmov 		r4, r.r3, r4
addi r0, r3, 0					||	v.lw.P1 	r3, CP, -1
bnf	$BB1_0						||	v.addi  	r4, r.r4, 0
nop								||	v.cmov 		r4, r.r3, r4




$BB1_1:								#summation
addi r7, r7, 4					||	v.lw.P2		r5, CP, 0		#load element to add to
addi r3, r3, 4					||	v.lw.P1		r3, CP, 0		#load element next to go into the pipeline
sfeq r3, r6						||	v.add.P2	r5, r.r4, r5	#perform the addition
addi r4, r4, 4					||	v.sw.P2		CP, r5, 0		#store addition result
bnf	$BB1_1						||	v.addi		r4, r.r4, 0  	#shift left
nop								||	v.cmov 		r4, r.r3, r4	#conditionaly load new element onto the pipeline




sfeq r7, r8							#pre-lead out to get better schedule for lead out
addi r7, r7, 4					||	v.lw.P2		r3, CP, 0		#load element to add to
bf $BB1_2						||	v.nop
sfeq r7, r8						||	v.add.P2	r3, r.r4, r3	#perform the addition
addi r4, r4, 4					||	v.sw.P2		CP, r3, 0		#store addition result


$BB1_3: 							#lead-out
addi r7, r7, 8					||	v.lw.P2		r3, CP, 0		#load element to add to
bf $BB1_2						||	v.addi		r4, r.r4, 0  	#shift left
sfeq r7, r8						||	v.add.P2	r3, r.r4, r3	#perform the addition
addi r4, r4, 8					||	v.sw.P2		CP, r3, 0		#store addition result
addi r0, r7, 0					||	v.lw.P2		r3, CP, -1		#load element to add to
									v.addi		r4, r.r4, 0  	#shift left
bnf $BB1_3						||	v.add.P2	r3, r.r4, r3	#perform the addition
addi r0, r4, 0					||	v.sw.P2		CP, r3, -1		#store addition result
			
$BB1_2:
jr r9
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
