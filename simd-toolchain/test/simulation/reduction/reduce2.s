###BEGIN: Reduction in RF - Algorithm 2
###TOOL: ${S_AS}
###ARGS: ${FILE} -arch-param dwidth:32,stage:5,bypass:false,pe:32,predicate:2 -o reduce2
###TOOL: ${S_SIM}
###ARGS:  -imem 0:uni:reduce2 -arch-param dwidth:32,stage:5,bypass:false,pe:32,predicate:2 -dump-dmem -dump-dmem-prefix reduce2 -dmem 0:pe:reduce2.pe.dmem_init
###MDUMP: reduce2.baseline.vector.dump
###END:

#########################
#
# Generic slow version
#
# v.r2 = top vector
# v.r3 = bottom vector
# v.r4 = temp for predication
# v.r5 = comm pipeline
#
# Ur1 = load address of vector
# Ur2 = store address of vector
# Ur3 = number of vectors
# Ur4 = up to wich round should we reduce?  --> max log_2(num_vect)-1
# r5 = current_round (r)
# r6 = 2^r
# r7 = temp for shift count
# r8 = temp for load address
# r10 = temp address for store address


add r1, r0, 0
add r2, r0, 0
add r3, r0, 16
add r4, r0, 3
##end of user input


add r5, r0, 0	#current round
sll r3, r3, 3	#number of vectors in this round *4 to convert to address + *2 to offset for first division in outer loop
$R2_outer:

add r6, r0, 1						#set flags according to round (todo)
sll	r6, r6, r5					
add r6, r6, -1					||  v.add   r5, CP, 0
srl r3, r3, 1					||	v.sll   r2, r5, 1
add r8, r1, 0					||	v.add   r2, r2, -1
add r10, r2, 0					||	v.and   r4, r1, r2
									v.sfltu P1, r4, r5 
									v.sfgeu P2, r4, r5
									v.sfgeu     r4, r5	 #set cmov flag in P2 PEs

#make sure all vectors are treated
$R2_inner:
									#load 2 vectors
add r8, r8, 4					||	v.lw r2, CP, 0
add r8, r8, 4					||	v.lw r3, CP, 0

									#load element of top vector in pipeline 
add r7, r0, 1					||	v.add.P2  r5, r2, 0
sfeq r6, r0                     ||  v.nop #3 nops to synchronize forwarding state
bf $R2_END_SHFT_L				||  v.nop

$R2_SHFT_L:							#shift left (0 times for round 1)
sfeq r7, r6                     ||  v.nop 
bnf $R2_SHFT_L
add r7, r7, 1					||	v.add r5, r.r5, 0

$R2_END_SHFT_L:					    #add in P1s
sfeq r6, r0						||	v.add.P1 r2, r.r5, r2
							
									#load element of bottom vector in pipeline
bf $R2_END_SHIFT_R				||	v.add r5, r3, 0

$R2_SHFT_R:							#shift right (0 times for round 1)
sfeq r7, 2 
bnf $R2_SHFT_R
add r7, r7, -1					||	v.add r5, l.r5, 0

$R2_END_SHIFT_R:					#add in P2s
sfeq r8, r3						||	v.add.P2 r3, l.r5, r3
add  r10, r10, 4					||  v.add r5, CP, 0
bnf	 $R2_inner					||	v.cmov r2, r3, r2	#select correct data for storing (P2==flag set)

									#store calculated vector back in mem
nop								||	v.sw CP, r2, 0

sfeq r5, r4
bnf $R2_outer
add r5, r5, 1


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
