# u.r2  = Address of first(top) vector on PE array      || v.r2U = start address of vectors on PE
# u.r3  = number of vectors                             || v.r6U = number of vectors
# u.r4  = nPE                                           || v.r5 = comm register
# u.r5  = Store Address on CP                           || v.r6 = end address of vectors
# r6    = min(nPE, nVect)
# r7    = counter

{% set rows = cfg.pe.size %}
{% set startAddr = 0 %}

zimm {{ imm1(startAddr) }}             || v.zimm {{ imm1(startAddr) }}
add r2, r0, {{ imm2(startAddr) }}      || v.add r2, r0, {{ imm2(startAddr) }}
zimm {{ imm1(rows) }}                  || v.zimm {{ imm1(rows) }}
add r3, r0, {{ imm2(rows) }}           || v.add r6, r0, {{ imm2(rows) }}
zimm {{ imm1(cfg.pe.size) }}           || v.add r5, r0, 0
add r4, r0, {{ imm2(cfg.pe.size) }}
add r5, r0, 0

add r6, r3, -1                          || v.sll r20, r6, 2
sfltu P1, r4, r3                        || v.add r6, r20, r2
add.P1 r6, r4, 0
add r7, r0, 1                           || v.sfgeu  P1, r0, r1

#phase1: lead in
#for min(nPE, nVect) = r6
$R4_PHASE1:
sfeq r7, r6                             || v.lw.P1   r20,  r2,  0
nop                                     || v.add.P1  r2,  r2,   4
bnf $R4_PHASE1                          || v.add.P1  r5,  l.r5, r20
add r7, r7, 1                           || v.sfgeu   P1,  CP,   r1

j.P1 $R4_PHASE2_INIT

#in case nVect<nPE we now need to continue without store in the CP yet
add r6, r4, 0                            || v.sfltu P2, r2, r6
$R4_PHASE1_B:
#### memory energy efficient implementation
nop                                       || v.lw.P1.P2     r20,  r2,  0
nop                                       || v.add.P1.P2    r5,  l.r5, r20
sfeq r7, r6                               || v.add.P1.P2    r2,  r2,   4
bnf  $R4_PHASE1_B                         || v.sfltu.P1.P2  P2,  r2,   r6
add  r7, r7, 1                            || v.sfgeu.P2     P1,  CP,   r1

##Faster, but accesses memory out of bounds (always reads array of nPE vectors (altough not modified)
#nop                                      || v.lw.P1   --,  r2,   0
#sfeq ALU, r6                             || v.add.P1  r5,  l.r5, LSU
#bnf $R4_PHASE1_B                         || v.add.P1  r2,  r2,   4
#add r7, r7, 1                            || v.sfgeu   P1,  CP,   r1

#the first sum has reached the CP, now comes the work loop, store + sum
# do this untill the array on the CP is filled
$R4_PHASE2_INIT:
sll r20, r3, 2
add r6, r20, r5 #real stop address
add r10, r6, -4 #address to compare to in PHASE2 loop

#stop address of floor(nVect/8)*8 loop
srl r20, r3,  3
sll r20, r20, 5
add r21, r20, r5
add r8,  r21, -32

#if (nVect/8)==0, skip unrolled loop
sfeq r20, r0
bf $R4_PHASE2
add r7, r0, 0


$R4_PHASE2_UNROLLED:
sfeq r7, r8                              || v.lw.P1    r20, r2, 0
add r20, t.r0, 0                         || v.add.P1   r5, l.r5, r20
sw  r7, r20,  0                          || v.lw.P1    r20, r2, 1
add r20, t.r0, 0                         || v.add.P1   r5, l.r5, r20
sw  r7, r20,  1                          || v.lw.P1    r20, r2, 2
add r20, t.r0, 0                         || v.add.P1   r5, l.r5, r20
sw  r7, r20,  2                          || v.lw.P1    r20, r2, 3
add r20, t.r0, 0                         || v.add.P1   r5, l.r5, r20
sw  r7, r20,  3                          || v.lw.P1    r20, r2, 4
add r20, t.r0, 0                         || v.add.P1   r5, l.r5, r20
sw  r7, r20,  4                          || v.lw.P1    r20, r2, 5
add r20, t.r0, 0                         || v.add.P1   r5, l.r5, r20
sw  r7, r20,  5                          || v.lw.P1    r20, r2, 6
add r20, t.r0, 0                         || v.add.P1   r5, l.r5, r20
sw  r7, r20,  6                          || v.lw.P1    r20, r2, 7
add r20, t.r0, 0                         || v.add.P1   r5, l.r5, r20
sw  r7, r20,  7
bnf $R4_PHASE2_UNROLLED                  || v.add.P1   r2, r2, 32
add r7, r7, 32                           || v.sfltu.P1 P1, r2, r6

sfeq r7, r6
bf $R4_END

$R4_PHASE2:
sfeq r7, r10                            || v.lw.P1 r20, r2, 0
add r20, t.r0, 0                        || v.add.P1 r5, l.r5, r20
sw  r7, r20, 0                          || v.add.P1 r2, r2, 4
bnf $R4_PHASE2                          || v.sfltu.P1 P1, r2, r6
add r7, r7, 4

$R4_END:
j 0
nop
nop


#See scripts/python/utils/datasection_utils.py for the generation
#of this 'random' datasection
# genDataSection([[randrange(pow(2,16)) for i in range(nCols)] for j in range(nRows)])
{{ randomDataSection(cfg.pe.size, cfg.pe.size) }}