# 0 4 8 c
# 1 5 9 d
# 2 6 a e
# 3 7 b f
#
# transpose:
# 0 1 2 3
# 4 5 6 7
# 8 9 a b
# c d e f


#######################################
### Current under test
#######################################

#transpose neigborhood network improved nPE=128 --> 5606

# Set network to wrap mode
add  --,   r0,  2
sw   r0,   ALU,  -1

nop                                  || zimm 0
zimm 0        || v.add r9,  r0, 7  #bitmask
add r4, r0, 4 || v.add r3,  r1,   0                #|| pe.r3 = store_base_address   = num_pe-1-pe_id
add r2, r0, 0       || v.or r2, r1, 0          #                        || r2 = load_address (start@dmem[pe_id +1inload])

$TRANSPOSE_1:
add r3, ALU, 0      || v.sll --, MUL, 2        #load_addr*4
sflts ALU, 3        || v.lw  --, MUL, 0        #load element dmem[addr+1] into r4
nop                 || v.add r4, r3, r9
bf $TRANSPOSE_3     || v.add r6, r3, -1         #increase store address by 1 in tmp r6
add --, r3, 0       || v.add --, LSU, 0         #put load Data into ALU

#main shift loop in steps of 3+3n (minimal 3 and 3 extra for each loop)
$TRANSPOSE_4:
sfges ALU, 6        || v.add --, l.ALU, 0     #fetch load element from left neighbor
bf $TRANSPOSE_4     || v.add --, l.ALU, 0     #fetch load element from left neighbor
add r3, r3, -3      || v.add --, l.ALU, 0     #fetch load element from left neighbor

#loop to do any remaining shifts
$TRANSPOSE_3:
sfeq ALU, 0         || v.sll --, r4, 2       #store address*4
bf $TRANSPOSE_2     || v.sw  MUL, ALU, 1     #store received element at  store_addr+ offset off num_pe+1                    !!!!!
sfeq r3, 1          || v.add --, l.ALU, 0
bf $TRANSPOSE_2     || v.sw  MUL, ALU, 1     #store received element at  store_addr+ offset off num_pe+1                    !!!!!
nop                 || v.add --, l.ALU, 0
nop                 || v.sw  MUL, ALU, 1     #store received element at  store_addr+ offset off num_pe+1

$TRANSPOSE_2:
sfeq r2, r4         || v.and r3, r6, r9      #wrap around store address with bitmask
bnf $TRANSPOSE_1    || v.add --, r2, 1        #increase load_addres by 1
add r2, r2, 1       || v.and r2, ALU, r9      # load_Address wrap around by bitmask


### Reverse directions!, instead of 66 to the left, we now go 64 to the right!
#r2 arrives set to 65, so contineous offset of -1 corrects this to 63
$TRANSPOSE_5:
add r3, ALU, -2      || v.sll --, MUL, 2        #load_addr*4
sflts ALU, 3        || v.lw  --, MUL, 0         # load elements
nop                 || v.add r4, r3, r9
bf $TRANSPOSE_7     || v.add r6, r3, -1        #increase store address by 1 in tmp r6
add --, r3, 0       || v.add --, LSU, 0         #put LSU into ALU

#main shift loop in steps of 3+3n (minimal 3 and 3 extra for each loop)
$TRANSPOSE_8:
sfges ALU, 6        || v.add --, r.ALU, 0     #fetch load element from left neighbor
bf $TRANSPOSE_8     || v.add --, r.ALU, 0     #fetch load element from left neighbor
add r3, r3, -3      || v.add --, r.ALU, 0     #fetch load element from left neighbor

$TRANSPOSE_7:
sfeq ALU, 0         || v.sll --, r4, 2       #store address*4
bf $TRANSPOSE_6     || v.sw  MUL, ALU, 1     #store received element at  store_addr+ offset off num_pe+1                    !!!!!
sfeq r3, 1          || v.add --, r.ALU, 0
bf $TRANSPOSE_6     || v.sw  MUL, ALU, 1     #store received element at  store_addr+ offset off num_pe+1                    !!!!!
nop                 || v.add --, r.ALU, 0
nop                 || v.sw  MUL, ALU, 1     #store received element at  store_addr+ offset off num_pe+1

$TRANSPOSE_6:
sfeq r2, 2          || v.and r3, r6, r9      #wrap around store address
bnf $TRANSPOSE_5    || v.add --, r2, 1        #increase load_addres by 1
add r2, r2, -1      || v.and r2, ALU, r9      # load_Address wrap around by bitmask

j 0
nop

#See scripts/python/utils/datasection_utils.py for the generation
#of this 'random' datasection
# genDataSection([[randrange(pow(2,16)) for i in range(nCols)] for j in range(nRows)])
.data
.type		A,@object
.long		0
.size		A,4

.vdata
.type		A,@object
.address	0
.long		40485
.long		34948
.long		23976
.long		38390
.long		10858
.long		54026
.long		25146
.long		51748
.size		A,32
.type		B,@object
.address	32
.long		60406
.long		20161
.long		65027
.long		13431
.long		43009
.long		59788
.long		7162
.long		53768
.size		B,32
.type		C,@object
.address	64
.long		26131
.long		4282
.long		45823
.long		22813
.long		26449
.long		52534
.long		52433
.long		43499
.size		C,32
.type		D,@object
.address	96
.long		54559
.long		38958
.long		30207
.long		62754
.long		52148
.long		20560
.long		45255
.long		59971
.size		D,32
.type		E,@object
.address	128
.long		29960
.long		17357
.long		13171
.long		4410
.long		34435
.long		40545
.long		37833
.long		2875
.size		E,32
.type		F,@object
.address	160
.long		26703
.long		42789
.long		40615
.long		44276
.long		41615
.long		12912
.long		18672
.long		29643
.size		F,32
.type		G,@object
.address	192
.long		60065
.long		52313
.long		20596
.long		52127
.long		40028
.long		28322
.long		51801
.long		36019
.size		G,32
.type		H,@object
.address	224
.long		50855
.long		36399
.long		42320
.long		55602
.long		14001
.long		63862
.long		34673
.long		34632
.size		H,32

