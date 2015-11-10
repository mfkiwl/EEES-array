# 0 4 8 c   |   0 1 2 3
# 1 5 9 d   |   0 1 2 3
# 2 6 a e   |   0 1 2 3
# 3 7 b f   |   0 1 2 3
#
# transpose:
# 0 1 2 3   |   3 3 3 3
# 4 5 6 7   |   2 2 2 2
# 8 9 a b   |   1 1 1 1
# c d e f   |   0 0 0 0


#######################################
### Current under test
#######################################

#transpose neigborhood network improved nPE=128 --> 5606

# Set network to wrap mode
add  r1,   r0,  2
sw   r0,   r1,  -1

nop                                  || zimm {{ imm1(cfg.pe.size-1) }}
zimm {{imm1(int(cfg.pe.size/2))}}        || v.add r9,  r0, {{ imm2(cfg.pe.size-1) }}  #bitmask
add r4, r0, {{imm2(int(cfg.pe.size/2))}} || v.add r3,  r1,   0                #|| pe.r3 = store_base_address   = num_pe-1-pe_id
add r2, r0, 0       || v.or r2, r1, 0          #|| r2 = load_address (start@dmem[pe_id +1inload])

$TRANSPOSE_1:
add r3, r2, 0       || v.sll r7, r2, 2        #load_addr*4
sflts r3, 3         || v.lw  r7, r7, 0        #load element dmem[addr+1] into r4
bf $TRANSPOSE_3     || v.add r4, r3, r9
nop                 || v.add r6, r3, -1         #increase store address by 1 in tmp r6

#main shift loop in steps of 3+3n (minimal 3 and 3 extra for each loop)
$TRANSPOSE_4:
sfges r3, 6         || v.add r7, l.r7, 0     #fetch load element from left neighbor
bf $TRANSPOSE_4     || v.add r7, l.r7, 0     #fetch load element from left neighbor
add r3, r3, -3      || v.add r7, l.r7, 0     #fetch load element from left neighbor

#loop to do any remaining shifts
$TRANSPOSE_3:
sfeq r3, 0          || v.sll r8, r4,   2     #store address*4
bf $TRANSPOSE_2     || v.sw  r8, r7,   1     #store received element at  store_addr+ offset off num_pe+1                    !!!!!
sfeq r3, 1          || v.add r7, l.r7, 0
bf $TRANSPOSE_2     || v.sw  r8, r7,   1     #store received element at  store_addr+ offset off num_pe+1                    !!!!!
nop                 || v.add r7, l.r7, 0
nop                 || v.sw  r8, r7,   1     #store received element at  store_addr+ offset off num_pe+1

$TRANSPOSE_2:
sfeq r2, r4         || v.and r3, r6, r9      #wrap around store address with bitmask
bnf $TRANSPOSE_1    || v.add r2, r2, 1

    #increase load_addres by 1
add r2, r2, 1       || v.and r2, r2, r9      # load_Address wrap around by bitmask


### Reverse directions!, instead of 66 to the left, we now go 64 to the right!
#r2 arrives set to 65, so contineous offset of -1 corrects this to 63
$TRANSPOSE_5:
add r3, r2, -2      || v.sll r7, r2, 2        #load_addr*4
sflts r3, 3         || v.lw  r7, r7, 0         # load elements
bf $TRANSPOSE_7     || v.add r4, r3, r9
nop                 || v.add r6, r3, -1        #increase store address by 1 in tmp r6

#main shift loop in steps of 3+3n (minimal 3 and 3 extra for each loop)
$TRANSPOSE_8:
sfges r3, 6         || v.add r7, r.r7, 0     #fetch load element from left neighbor
bf $TRANSPOSE_8     || v.add r7, r.r7, 0     #fetch load element from left neighbor
add r3, r3, -3      || v.add r7, r.r7, 0     #fetch load element from left neighbor

$TRANSPOSE_7:
sfeq r3, 0          || v.sll r8, r4, 2       #store address*4
bf $TRANSPOSE_6     || v.sw  r8, r7, 1     #store received element at  store_addr+ offset off num_pe+1                    !!!!!
sfeq r3, 1          || v.add r7, r.r7, 0
bf $TRANSPOSE_6     || v.sw  r8, r7, 1     #store received element at  store_addr+ offset off num_pe+1                    !!!!!
nop                 || v.add r7, r.r7, 0
nop                 || v.sw  r8, r7, 1     #store received element at  store_addr+ offset off num_pe+1

$TRANSPOSE_6:
sfeq r2, 2          || v.and r3, r6, r9      #wrap around store address
bnf $TRANSPOSE_5    || v.add r2, r2, 1        #increase load_addres by 1
add r2, r2, -1      || v.and r2, r2, r9      # load_Address wrap around by bitmask

j 0
nop

#See scripts/python/utils/datasection_utils.py for the generation
#of this 'random' datasection
# genDataSection([[randrange(pow(2,16)) for i in range(nCols)] for j in range(nRows)])
{{ randomDataSection(cfg.pe.size, cfg.pe.size) }}