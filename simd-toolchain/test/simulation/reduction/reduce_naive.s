###BEGIN: Naive Reduction (out RF)
###TOOL: ${S_AS}
###ARGS: ${FILE} -arch-param dwidth:32,stage:5,bypass:false,pe:32,predicate:2 -o reduce_naive
###TOOL: ${S_SIM}
###ARGS:  -imem 0:uni:reduce_naive -arch-param dwidth:32,stage:5,bypass:false,pe:32,predicate:2 -dump-dmem -dump-dmem-prefix reduce_naive -dmem 0:pe:reduce_naive.pe.dmem_init
###MDUMP: reduce_naive.baseline.scalar.dump
###END:


j $NI	#jump to naive_interleaved with generic interleave factor
nop
nop


###########################################################################################
##
## Interleaving = 0 (in RF)
##
add r17, r0, 0	 # start address for storing
add r18, r0, 32  # vector length
add r23, r0, 16   # number of vectors
#end of user land

sll r21, r23, 2
add r21, r17, r21
srl  r20, r18,  3	#mask lower 3 bits part1 
sll  r20, r20,  3	#mask lower 3 bits part2
add  r20, r20, -8

$BB0_2:
add  r17,  r17,  4 		||	v.lw 		r2, CP, 0	#load data into pipeline
add  r1,   r0,   0		||  v.nop
add  r19,  r0,   0

#check if we even need to enter the big loop
sfltu  r18, 8
bf $BB0_4
		
$BB0_0: #big unrolled loop
sfeq r19, r20			
add  r1,  h.r2, r1		||	v.addi 		r2, r.r2, 	0	# shift left
add  r1,  h.r2, r1		||	v.addi		r2, r.r2,	0
add  r1,  h.r2, r1		||	v.addi 		r2, r.r2, 	0
add  r1,  h.r2, r1		||	v.addi		r2, r.r2,	0
add  r1,  h.r2, r1		||	v.addi 		r2, r.r2, 	0
add  r1,  h.r2, r1		||	v.addi		r2, r.r2,	0
add  r1,  h.r2, r1		||	v.addi 		r2, r.r2, 	0
add  r1,  h.r2, r1		||	v.addi		r2, r.r2,	0
bnf  $BB0_0			
add  r19, r19,  8

$BB0_4:		 #check if there is a remainder
sfeq r19, r18
bf $BB0_3

$BB0_1: #resolve remainder of vector
addi  r19, r19, 1
addi  r1, h.r2, r1			||	v.addi		r2, r.r2,	0						
bnf   $BB0_1
sfeq  r19, r18

$BB0_3:
sw r17, r1, -1 		#-1 because it is already increased at the beginning of the code
sfeq r17, r21
bnf $BB0_2
nop				
j STOP
nop				

###########################################################################################





###########################################################################################
##
## Interleaving = n (generic slow version) (all out mem)
##
#U indicates user set
# Ur1    = first element address of dest on CP
# Ur2	 = first element address of src on CP
# Ur3	 = vector Length (elements)
# Ur4    = number of vectors
# Ur5    = interleave factor (==round number) (aka r)
##Assumption 2^r < num_vectors (o.w there is not much point in using this technique right, it means you pipeline will be empty at locations
## N.B.  maybe its usefull for clean up though, TODO: modify this function such that it can handle this if required

$NI:
add r1, r0, 0
add r2, r0, 0
add r3, r0, 32
add r4, r0, 16
add r5, r0, 3

# r7     = temp
# r8	 = load_addr
# r9	 = length of leadin in address (x4)
# r10	 = number of required "lead_out_inner" loops to get all elements
# r11    = temp
# r12    = number of required reductions to get all vectors done
# r13    = temp
# r14    = stop criteria for lead-in and inner loop
# r15 	 = temp

add r0, r2, r0 		|| 	v.add r2, CP, 0		#communicate start_addr of vector to PEs
add r6, r0, 1
sll r6, r6, r5
sll r9, r6, 2 		||	v.add r3, CP, -1	#get bitmask
add r8, r1, 0		||	v.and r4, r1, r3	#and pe_id
srl r10, r3, r5 	||	v.sfeq P1,r4, r0    #set flag for load and cmov PEs
srl r12, r4, r5	    ||  v.sfeq r4, r0
add r10, r10, -1 #minus 1 from the lead in

add r14, r8, 0
sub r8, r8, r9 #correct for first addition
add r13, r0, 0
$NI_nextSegment:
#first check if we aren't done by any coincidence
sfeq r13, r12
bf $NI_stop
add r13, r13, 1
#move on to next segment
add r8, r8,   r9
add r14, r14, r9

add r15, r8, 0
$NI_leadin:			
lw r7, r15, 0 		||	v.lw.P1 r4, r2, 0	#load element
add r15, r15, 4		||	v.add.P1 r2, r2, 4	#increase addres
sfeq r15, r14		||	v.cmov r5, r4, r5	#put element in the pipeline if P1 (==flag set since no other comparisons are done!)
add r7, h.r0, 0     ||	v.add r5, r.r5, 0	#add in CP and shift left 1
bnf $NI_leadin					
sw r15, r7, -1


add r11, r0, 0
$NI_leadout:
sfeq r11, r10
bf $NI_nextSegment
add r15, r8, 0
$NI_leadout_inner:
lw r7, r15, 0
add r15, r15, 4
sfeq r15, r14
add r7, h.r0, r7		|| v.add r5, r.r5, 0
bnf $NI_leadout_inner					
sw r15, r7, -1
j $NI_leadout
add r11, r11, 1


$NI_stop:
j STOP
nop	
###########################################################################################


STOP:
nop
nop
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

 
