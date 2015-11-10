###BEGIN: Gather results of reduce2 into first segment
###TOOL: ${S_AS}
###ARGS: ${FILE} -arch-param dwidth:32,stage:5,bypass:false,pe:32,predicate:2 -o gather2
###TOOL: ${S_SIM}
###ARGS:  -imem 0:uni:gather2 -arch-param dwidth:32,stage:5,bypass:false,pe:32,predicate:2 -dump-dmem -dump-dmem-prefix gather2 -dmem 0:pe:gather2.pe.dmem_init
###MDUMP: gather2.baseline.scalar.dump
###END:

#
# U = user set
#
# Ur1 = length of segment
# Ur2 = number of segments (aka nPE/segment_length)
# Ur3 = start address of vector (on PE) 
# Ur4 = number of vectors
# r5 = temp for segment length and remaining shifts
# r6 = temp for number of segments left
# r7 = temp for number of vectors left

# Ur8 = start address for storing on CP

add r1, r0, 8
add r2, r0, 4
add r3, r0, 0
add r4, r0, 2

add r8, r0, 0

##end of user settings


add r7, r4, 0
$G2_outer:
						#load vector into RF
add r3, r3, 4 		||	v.lw r2, CP, 0
add r6, r2, 0	    || 	v.nop
			     
						#move vector to pipeline
						v.add r3, r2, 0
$G2_inner:
add r5, r1, 0		||  v.nop
$G2_inner2:			
						#shift left segment_lenght (-1 only for first time, so lets ignore for simplicity)
sfeq r5, 1			||	v.add r3, r.r3, 0
bnf $G2_inner2
add r5, r5, -1				 
	 
					#sum into r2
sfeq r6, 2			||	v.add r2, r3, r2

bnf $G2_inner      
add r6, r6, -1								


############################
#
# Sum results into CP
#
# Code is given here, but consider calling a nice function
# r5 = number of elements left

sll r5, r1, 2	|| v.sw r0, r2, 0
add r5, r8, r5

$G2_toCP:
add r10, h.r0, r0 || v.add r2, r.r2, 0  #need to use add, because sw only allows communicating the base address 
add r8, r8, 4
sfeq r8, r5
bnf $G2_toCP
sw r8, r10, -1

#
#
#############################
					
sfeq r7, 1					
bnf $G2_outer
add r7, r7, -1				 



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

