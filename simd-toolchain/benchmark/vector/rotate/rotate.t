# 0 4 8 c
# 1 5 9 d
# 2 6 a e
# 3 7 b f
#
# rotate:
# c d e f
# 8 9 a b
# 4 5 6 7
# 0 1 2 3


#######################################
### ONLY USE POWER OF 2 NUMBER OF PEs
#######################################
#rotate neigborhood network improved nPE=128 --> cycles 5671

# Set network to wrap mode
add  --,   r0,  2
sw   r0,   ALU,  -1

nop                                 || zimm {{ imm1(cfg.pe.size-1) }}
zimm {{imm1(int(cfg.pe.size/2))}}       || v.add r9,  r0, {{ imm2(cfg.pe.size-1) }}  #bitmask
add r4, r0, {{imm2(int(cfg.pe.size/2))}} || v.sub r3,  ALU,   r1                #|| pe.r3 = store_base_address   = num_pe-1-pe_id
add r2, r0, 0                       || v.or  r2,  r1,     0                #cp.r2 = 0 || r2 = load_address (start@dmem[pe_id +1inload])

$ROTATE_1:
add r3, ALU, 0                      || v.sll --,  MUL,   2                 #load_addr*4
sflts ALU, 12                       || v.lw  --,  MUL,   0                 #load element dmem[addr+1] into r4
nop                                 || v.add r4,  r3,    r9
bf $ROTATE_G                        || v.add r6,  r3,    1                 #increase store address by 1 in tmp r6
add --, r3, 0                       || v.add --,  LSU,   0                 #put load Data into ALU

$ROTATE_F:
sfges ALU, 24                        || v.add --,  l.ALU, 0                 #fetch load element from left neighbor
bf $ROTATE_F                         || v.add --,  l.ALU, 0                 #fetch load element from left neighbor
add r3, r3, -12                      || v.add --,  l.ALU, 0                 #fetch load element from left neighbor



$ROTATE_G:
sflts ALU, 4
bf $ROTATE_3
add --, r3, 0

sfles ALU, 7                         || v.add --,  l.ALU, 0                 #fetch load element from left neighbor
bf $ROTATE_3                      #  || v.add --,  l.ALU, 0                 #fetch load element from left neighbor
add r3, r3, -4                    #  || v.add --,  l.ALU, 0                 #fetch load element from left neighbor
nop                                  || v.add --,  l.ALU, 0
add r3, r3, -4

#loop to do any remaining shifts
$ROTATE_3:
sfeq ALU, 0                         || v.sll --,  r4,   2                 #store address*4
bf $ROTATE_2                        || v.sw  MUL, ALU,    1                 #store received element at  store_addr+ offset off num_pe+1                    !!!!!
sfeq r3, 1                          || v.add --,  l.ALU,  0
bf $ROTATE_2                        || v.sw  MUL,  ALU,   1                 #store received element at  store_addr+ offset off num_pe+1                    !!!!!
sfeq r3, 2                          || v.add --,  l.ALU,  0
bf $ROTATE_2                        || v.sw  MUL,  ALU,   1
nop                                 || v.add --,  l.ALU, 0
nop                                 || v.sw  MUL,  ALU,   1                 #store received element at  store_addr+ offset off num_pe+1

$ROTATE_2:
sfeq r2, r4                         || v.and r3,  r6,    r9                #wrap around store address with bitmask
bnf $ROTATE_1                       || v.add --,  r2,    1                 #increase load_addres by 1
add r2, r2, 1                       || v.and r2,  ALU,   r9                #load_Address wrap around by bitmask


### Reverse directions!, instead of 66 to the left, we now go 64 to the right!
#r2 arrives set to 65, so contineous offset of -1 corrects this to 64
$ROTATE_5:
add r3, ALU, -2                     || v.sll --, MUL,    2                 #load_addr*4
sflts ALU, 12                        || v.lw  --, MUL,    0                 #load elements
nop                                 || v.add r4,  r3,    r9
bf $ROTATE_P                        || v.add r6, r3,     1                 #increase store address by 1 in tmp r6
add --, r3, 0                       || v.add --, LSU,    0                 #put LSU into ALU

#main shift loop in steps of 3+3n (minimal 3 and 3 extra for each loop)
$ROTATE_8:
sfges ALU, 24                       || v.add --, r.ALU,  0                 #fetch load element from left neighbor
bf $ROTATE_8                        || v.add --, r.ALU,  0                 #fetch load element from left neighbor
add r3, r3, -12                      || v.add --, r.ALU,  0                 #fetch load element from left neighbor

$ROTATE_P:
sflts ALU, 4
bf $ROTATE_7
add --, r3, 0
sfles ALU, 7                         || v.add --,  r.ALU, 0                 #fetch load element from left neighbor
bf $ROTATE_7                    
add r3, r3, -4                  
nop                                  || v.add --,  r.ALU, 0
add r3, r3, -4


$ROTATE_7:
sfeq ALU, 0                         || v.sll --,  r4,   2                 #store address*4
bf $ROTATE_6                        || v.sw  MUL, ALU,    1                 #store received element at  store_addr+ offset off num_pe+1                    !!!!!
sfeq r3, 1                          || v.add --,  r.ALU,  0
bf $ROTATE_6                        || v.sw  MUL,  ALU,   1                 #store received element at  store_addr+ offset off num_pe+1                    !!!!!
sfeq r3, 2                          || v.add --,  r.ALU,  0
bf $ROTATE_6                        || v.sw  MUL,  ALU,   1                 #store received element at  store_addr+ offset off num_pe+1                    !!!!!
nop                                 || v.add --,  r.ALU, 0
nop                                 || v.sw  MUL,  ALU,   1                 #store received element at  store_addr+ offset off num_pe+1

$ROTATE_6:
sfeq r2, 2                          || v.and r3,  r6,    r9                #wrap around store address
bnf $ROTATE_5                       || v.add --,  r2,    1                 #increase load_addres by 1
add r2, r2, -1                      || v.and r2,  ALU,   r9                #load_Address wrap around by bitmask

j 0
nop


#See scripts/python/utils/datasection_utils.py for the generation
#of this 'random' datasection
#  genDataSection([[randrange(pow(2,16)) for i in range(nCols)] for j in range(nRows)])
 {{randomDataSection(cfg.pe.size, cfg.pe.size) }}
