# U.r2 = top of image
# U.r3 = number of rows
# U.r4 = number of columns --> should be nPE also!
#
# r5 = start address of histogram (on vector and CP)
# r6 = temp
# r7 = temp
# r8 = temp
# r10 = temp

zimm {{ imm1(startAddr) }}
add r2,        r0,     {{ imm2(startAddr) }}
zimm {{ imm1(rows) }}
add r3,        r0,     {{ imm2(rows) }}
zimm {{ imm1(cfg.pe.size) }}
add r4,        r0,     {{ imm2(cfg.pe.size) }}

#
# END OF USER SETTINGS
########################################################################


########################################################################
# Notes for future optimizations
#
# It should be possible to merge the 'binarization/erosion' kernel with
# the row-projection kernel. This could significatly reduce the number
# of memory accesses as you produce the bins to project on the fly, and
# don't store them intermediately in DMEM.
# This will require quite some code rewritting though!
#
# In the end each pixel needs to be touched only twice:
# 1.) To calculate histogram and through otsu obtain threshold
# 2.) Apply threshold, erosion and project all in one go
#
# In the current implementation the eroded image is stored in DMEM,
# which theoretically can be avoided
#
########################################################################


#generate some addresses based on user input and do CH/CIA calculations
sll    --,     r3,     2
add    r5,     r2,     MUL
jal $HISTOGRAM #CH/CIA!
add    --,     ALU,    0       || v.add  r5,    CP,     0


#with parallel division on the PEs
jal $SIGMA
nop


#Separate kernels superseeded by the merged 'BINAROSION' kernel
#jal $BINARIZATION
#nop
#jal $EROSION
#nop

#Merged Binarization and erosion, both faster and less memory accesses!
jal $BINAROSION
nop

jal $COL_PROJ       || v.add --, r0, {{ columnThreshold }}
nop
sw r5, r0, 0        #add spacing in output in form of stored zero
add r5, r5, 4

jal $ROW_PROJ       || v.add r7, r0, {{ rowThreshold }}  #threshold in v.r7
nop
sw r5, r0, 0        #add end to output in form of stored zero

#end of main
nop
nop
j 0
nop


########################################################################
# Sigma Calculation
#
# assuming CH and CIA are consequtive and start at r0 on CP
#
# return r6 (in ALU) == index of max sigma
# if sigma value is required see near return and uncomment r7 to get it
#
# r6 = CIA load Addre
# r7 = CH load addr
# r8 = last address of CH
# r13 = loop address
# r11 = loop counter
#
# v.r2 = s
# v.r3 = CIA[255] = sum
# v.r4 = CH[i]
# v.r5 = CIA[i]
# v.r6 = temp1
# v.r7 = temp2
# v.r8 = Sigma temp
# v.r9 = max sigma
# v.r17 = index associated with max sigma
# v.r18 =

$SIGMA:
#init
mul --, r3, r4                || v.add r9, r0, 0
add --, MUL, 0                || v.add r2, CP, 0
zimm 4                        || v.add r4, r0, 0
add r6, r0, 0                 || v.add r5, r0, 0
add r8, ALU, -4
sll --, r6, 1
add --, MUL, -4
lw --, ALU, 0
add --, LSU, 0                || v.add r3, CP, 0
add r13, r0, 0



#store return address
add r12, r9, 0

#set mode to read from CP
add --, r0, 1
sw r0, ALU, -1

add r11, r0, 0               || v.add r17, r1, 0

sll  --, r4, 2
add r7, MUL, -4
add r6, ALU, r6

#distribute nPE values

$SIGMA_LOOP:
add --, r13, 0               || v.srl --, CP, 2
add --, r7, 0                || v.add r18, MUL, r1
$SIGMA_1:
lw   --, ALU, 0
add  --, LSU, 0              || v.add r4, l.r4, 0
lw   --, r6, 0
add  --, LSU, 0              || v.add r5, l.r5, 0
add  r6, r6, -4
sfeq r7, r13
bnf  $SIGMA_1
add  r7, r7, -4

#calc sigma's of these values:
nop                          || v.sll r16, r5, 11

jal $DIV                     || v.add r15, r4, 0  #DIV!! r11 = r16/r15
nop                          || v.nop
sll  --, r4, 2               || v.mul --, r11, r2
add  r13, r13, MUL           || v.sra --, MUL, 11
sll  --, r4, 3               || v.sub --, r3, MUL
add r7, r7, MUL              || v.srl r6, ALU, 6

add r6, r6, MUL              || v.sub --, r3, r5
jal $DIV                     || v.sll r16, ALU, 11   #DIV!! r11 = r16/r15
nop                          || v.sub r15, r2, r4
nop                          || v.mul --, r11, r4
sfgtu r7, r8                 || v.sra --, MUL, 11
cmov r7, r8, r7              || v.sub --, MUL, r5
nop                          || v.srl --, ALU, 6

nop                          || v.mul -- ,r6, MUL

#                            check if division was nonsense and Sigma needs to be zero
zimm 5                       || v.sub --, r2, r4
add --, r0, 0                || v.sfeq ALU, r0
add --, ALU, -4              || v.cmov WB, r0, MUL
cmov r6, ALU, r6             || v.sfeq r4, r0
zimm 4                       || v.cmov WB, r0, WB
sfgeu r13, 0                 || v.sfgtu ALU, r9
bnf $SIGMA_LOOP              || v.cmov  r9, WB, r9 #max sigma selection
nop                          || v.cmov  r17, r18 ,r17

#collect max into CP to find out the threshold:
nop                          || v.sfgtu r.WB, WB        #first do cheap reduce with neighbor
nop                          || v.cmov r9, r.r9, r9
nop                          || v.cmov r17, r.r17, r17

#set communication-wrap-mode back to normal (read from CP)
sw r0, r0, -1

srl --, r4,  1               || v.add r2,  r.r9,  0
add r6, MUL, -1              || v.add r3,  r.r17, 0
nop                          || v.sfeq P1, r1, r0

$SIGMA_MAX:
nop                          || v.sfgtu.P1 r.r2, r9
nop                          || v.cmov.P1 r9, r.r2, r9
nop                          || v.cmov.P1 r17, r.r3, r17
add r6, r6, -1               || v.add --, r.r2, 0
sfeq ALU, r0                 || v.add r2, r.ALU, 0
bnf $SIGMA_MAX               || v.add --, r.r3, 0
nop                          || v.add r3, r.ALU, 0

#add r7, h.r0, 0              || v.add.P1 --, r9, 0 #value of max sigma!
jr r12                       || v.nop
add r6, h.r0, 0              || v.add.P1 --, r17, 0 #index of max sigma == TH


#
# End of Sigma Calculation
########################################################################


########################################################################
#
# Parallel Division
#
# v.r15/v.r16
#

$DIV:
#get position of MSB of divisor in r10
add r10, r0, 0          || v.add       r10, r0, 0

$DIV_CALC_MSB:
sfeq ALU, 31            || v.srl       --, r15, ALU
bnf $DIV_CALC_MSB       || v.sfne      r0, MUL
add r10, r10, 1         || v.cmov      r10, CP, r10


#convert to number of leading zeroes -1
nop                     || v.add       --,  r0, 31
nop                     || v.sub       r10, ALU, WB

#walk over all possible shamts and do restoring division
nop                     || v.add       r14, r0,  1     #one used in shifts
nop                     || v.add       r12, r16, 0     #remainder
nop                     || v.add       r11, r0,  0     #result
v.add r10,  r0,  32     || v.add       r8,  r0,  32

$DIV_MAIN:
nop                     || v.sfleu     P1,  ALU, r10  #set flag if we want to engage in this particular round
nop                     || v.sll.P1    --,  r15, WB
nop                     || v.sub.P1    WB, r12, MUL
nop                     || v.sfges.P1  P2,  ALU, r0
nop                     || v.add.P1.P2 r12, WB, 0
sfeq r10, r0            || v.sll.P1.P2 --,  r14, r8
bnf $DIV_MAIN           || v.or.P1.P2  r11, r11, MUL
add r10, r10, -1        || v.add       r8,  r8,  -1

jr r9
nop

#                       || v.r11 = floor(r15/r16)
#                       || v.r12 = r15%r16
#
# End of division / modulo operation
#
########################################################################


########################################################################
# Histogram
#
# U.r3 = number of rows in image
# U.r4 = number of columns in image
# U.r5 = start_address image
# r6   = temp
# r7   = temp
# r9   = return address

$HISTOGRAM:
#init histogram to zeroes
zimm 0
add     r7,     r0,     128
add     r6,     r0,     0
$HIST_1:
sfeq    ALU,     r7             || v.sw      ALU,   r0,      0          #first ALU is comming from the function call!
bnf     $HIST_1                 || v.sw      ALU,   r0,      1
add     r6,     r6,     1       || v.add     --,    ALU,     8

#histogram calculation
add r6, r2, 0    #start address
sll --, r3, 2
add r7, ALU, MUL #end address
$HIST_2:
add r6, r6 , 4                  || v.lw      --,     CP,     0          # load pixel
nop                             || v.sll     --,     LSU,    2          # pixel*4
nop                             || v.add     r7,     r5,     MUL        # calc bin address
sfeq r7, ALU                    || v.lw      --,     ALU,    0          # load bin
bnf $HIST_2                     || v.add     --,     LSU,    1          # increase bin
nop                             || v.sw      r7,     ALU,    0          # store bin

#sum into CP
#backup data
add r20, r2, 0
add r21, r3, 0
add r22, r5, 0
add r23, r9, 0
#call function
add r2, r5, 0                   || v.add r2, r5, 0
zimm 1                          || v.zimm 1
add r3, r0, 0                   || v.add r6, r0, 0
jal $HIST_REDUCE
add r5, r0, 0
#restore
add r2, r20, 0
add r3, r21, 0
add r5, r22, 0

jr r23
nop


#
# End of Histogram
########################################################################



########################################################################
# Reduction (summation of rows into CP)  -- modified for histogramming!
# See bottom of code for modifications
#
# u.r2  = Address of top vector             || v.r2U = start address of vectors on PE
# u.r3  = number of vectors                 || v.r6U = number of vectors
# u.r4  = nPE                               || v.r5 = comm register
# u.r5  = Store Address on CP               || v.r6 = end address of vectors
# r6    = min(nPE, nVect)
# r7    = counter
# r9    = return address
$HIST_REDUCE:
add r6, r3, -1                              || v.sll --, r6, 2
sfltu P1, r4, r3                            || v.add r6, MUL, r2
add.P1 r6, r4, 0                            || v.add r5, r0, 0
add r7, r0, 1                               || v.sfgeu  P1, r0, r1


#phase1: lead in
#for min(nPE, nVect) = r6
$HIST_R4_PHASE1:
sfeq ALU, r6                                || v.lw.P1   --,  r2,   0
nop                                         || v.add.P1  r2,  r2,   4
bnf $HIST_R4_PHASE1                         || v.add.P1  r5,  l.r5, LSU
add r7, r7, 1                               || v.sfgeu   P1,  CP,   r1

j.P1 $HIST_R4_PHASE2_INIT

#in case nVect<nPE we now need to continue without store in the CP yet
add r6, r4, 0
add --, r7, 0                               || v.sfltu P2, r2, r6
$HIST_R4_PHASE1_B:
#### memory energy efficient implementation (untested)
#nop                                         || v.lw.P1.P2    --,  r2,   0
#nop                                         || v.add.P1.P2   r5,  l.r5, LSU
#sfeq ALU, r6                                || v.add.P1.P2   r2,  r2,   4
#bnf $HIST_R4_PHASE1_B                       || v.sfltu P2, ALU, r6
#add r7, r7, 1                               || v.sfgeu.P2 P1,  CP,   r1

##Faster, but accesses memory out of bounds (always reads array of nPE vectors (altough not modified)
nop                                        || v.lw.P1    --,  r2,   0
sfeq ALU, r6                               || v.add.P1   r5,  l.r5, LSU
bnf $HIST_R4_PHASE1_B                      || v.add.P1   r2,  r2,   4
add r7, r7, 1                              || v.sfgeu P1,  CP,   r1


#the first sum has reached the CP, now comes the work loop, store + sum
# do this untill the array on the CP is filled
$HIST_R4_PHASE2_INIT:
sll --, r3, 2
add r11, MUL, r5
add r10, ALU, -4                            || v.add  r7, r0, 0
add r6, r0, 0                               || v.zimm {{ imm1(cfg.pe.size-1) }}
add r7, r0, 0                               || v.add --, r0, {{ imm2(cfg.pe.size-1) }}
add r8, r5, 0                               || v.sfeq P2, r1, ALU

###N.B. MODIFIED FOR HISTOGRAMMING!!!
$HIST_R4_PHASE2:
sfeq ALU, r10                               || v.lw.P1    --, r2,   0
add r6, t.r0, r6                            || v.add.P1   r5, l.r5, LSU   #r5= l.r5+LSU || old_r5 to CP
sw  r8, ALU,  0                             || v.mul.P2   --, r7,   r5    #old_r5*i N.B!!!! NOT FORWARDED, NEED OLD r5!!!
add r7, t.r0, r7                            || v.add.P2   --, MUL,  0     #old_r5*i to CP
sw  r11, ALU, 0                             || v.add.P1   r2, r2,   4
add r11, r11, 4                             || v.nop
bnf $HIST_R4_PHASE2                         || v.sfltu.P1 P1, ALU,  r6
add r8, r8, 4                               || v.add.P2   r7, r7,   1

$HIST_R4_END:
jr r9
nop

#
# Reduction (summation of rows into CP) -- modified for histogramming!
########################################################################




########################################################################
#
# Binarization of input image
#
# r5 = load address
# (v.)r6 = Threshold
# r7 = stop address

$BINARIZATION:
add --, r6, 0                   || v.add r6, CP, 0
sll --, r3, 2                   || v.zimm 0
add --, r2, MUL                 || v.add r5, r0, 1
add r7, ALU, -4
add r5, r2, 0
$BIN_LOOP:
sfeq ALU, r7                    || v.lw --, CP, 0
nop                             || v.sfgeu LSU, r6
bnf $BIN_LOOP                   || v.cmov --, r5, 0
add r5, r5, 4                   || v.sw CP, ALU, 0

jr r9
nop

# Binarization
########################################################################


########################################################################
# Erosion
#
#          Cross kernel:
#
#               top
#                |
#      left - center - right
#                |
#              bottom
#

# erosion runs in place and does column projection in one go (col-proj in r2)
$EROSION:
add --, r3, -1
sll r6, ALU, 2                  || v.lw r2, CP,  0
add --, r0,  4                  || v.lw r3, CP,  0
add --, ALU, 4                  || v.add --, r0, 0

$ER_LOOP:
add --, ALU, 4                  || v.lw r4,  CP,   0
nop                             || v.and --, r3,   r2
nop                             || v.and --, r.r3, MUL
nop                             || v.and --, l.r3, MUL
nop                             || v.and --, LSU,  MUL
nop                             || v.add --, ALU,  MUL
add --, ALU, 0                  || v.sw  CP, MUL,  -2

add --, ALU, 4                  || v.lw r2,  CP,   0
nop                             || v.and --, r4,   r3
nop                             || v.and --, r.r4, MUL
nop                             || v.and --, l.r4, MUL
nop                             || v.and --, LSU,  MUL
nop                             || v.add --, ALU,  MUL
add --, ALU, 0                  || v.sw  CP, MUL,  -2

add r5, ALU, 4                  || v.lw r3,  CP,   0
nop                             || v.and --, r2,   r4
nop                             || v.and --, r.r2, MUL
nop                             || v.and --, l.r2, MUL
sfleu ALU, r6                   || v.and --, LSU,  MUL
bf  $ER_LOOP                    || v.add --, ALU,  MUL
add --, r5, 0                   || v.sw  CP, MUL,  -2


#blank bottom line:
add --, r6, 0                   || v.sw  CP, r0,  0

#blank top line and store column projection in r2
jr r9                           || v.add  r2, ALU, 0
nop                             || v.sw   r0, r0,  0

#
# erosion
########################################################################

########################################################################
# Binarosion --> binarization + erosion
#
#          Cross kernel:
#
#               top
#                |
#      left - center - right
#                |
#              bottom
#

# erosion runs in place and does column projection in one go (col-proj in r2)
#(v.)r6 = Threshold

$BINAROSION:
add --, r6, 0                   || v.add  r6,   CP, 0
nop                             || v.lw    --,  CP, 0
nop                             || v.sfltu LSU, WB
nop                             || v.cmov  r2,  r0, 1
add --, r3, -1                  || v.lw    --,  CP, 0
sll r6, ALU, 2                  || v.sfltu LSU, r6
add --, r0,  4                  || v.cmov  r3,  r0, 1
add --, ALU, 4                  || v.add   r5,  r0, 0

$BINA_LOOP:
add --, ALU, 4                  || v.lw  --,  CP,   0
nop                             || v.and --, r3,   r2
nop                             || v.and --, r.r3, MUL
nop                             || v.and --, l.r3, MUL
nop                             || v.sfltu LSU, r6
nop                             || v.cmov  r4,  r0, 1
nop                             || v.and --, ALU,  MUL
nop                             || v.add r5, r5,   MUL
add --, ALU, 0                  || v.sw  CP, MUL,  -2

add --, ALU, 4                  || v.lw  --,  CP,   0
nop                             || v.and --, r4,   r3
nop                             || v.and --, r.r4, MUL
nop                             || v.and --, l.r4, MUL
nop                             || v.sfltu LSU, r6
nop                             || v.cmov  r2,  r0, 1
nop                             || v.and --, ALU,  MUL
nop                             || v.add r5, r5,   MUL
add --, ALU, 0                  || v.sw  CP, MUL,  -2

add r5, ALU, 4                  || v.lw --,  CP,   0
nop                             || v.and --, r2,   r4
nop                             || v.and --, r.r2, MUL
nop                             || v.and --, l.r2, MUL
nop                             || v.sfltu LSU, r6
nop                             || v.cmov  r3,  r0, 1
sfleu ALU, r6                   || v.and --, ALU,  MUL
bf  $BINA_LOOP                  || v.add r5, r5,   MUL
add --, r5, 0                   || v.sw  CP, MUL,  -2



#blank bottom line:
add --, r6, 0                   || v.sw  CP, r0,  0

#blank top line and store column projection in r2
jr r9                           || v.add  r2, r5, 0
nop                             || v.sw   r0, r0,  0

#
# Binarosion
########################################################################


########################################################################
# Column Projection r5 is address of next to store element
#
$COL_PROJ:
add r8, r0, 0                                   || v.sfleu r2, ALU          #compare to threshold
add r6, r0, 3                                   || v.cmov --, r0, 1         #store thresholded result in ALU
add r5, r0, 0
add r1, r0, 0

$col_proj_comm:
sfeq r0, r8
bf $xstart_is_zero
    add --, h.r0 ,0                             || v.add --, r.ALU, 0       #communicate thresholded value through neighbors to cp
    sfne ALU, r0
    #start!=0 and pixel!=0 : continue
    bf $col_proj_comm_loop_end
    #start!=0 and pixel==0 : end
    sub  --, r1, r7
    sfleu ALU, r6
    #if length < TH: start=0
    add r8, r0, 0                                                 #start=0
    bf  $col_proj_comm_loop_end
    add --, r1, r7                                                #x_start+x_end
    srl --, ALU, 1                                                #(x_start+x_end/2)
    sw r5,MUL, 0                                                  #store center
    j   $col_proj_comm_loop_end
    add r5, r5, 4                                                 #increment storage pointer

$xstart_is_zero:
    #(thanks to branch slot ALU==pixel)
    sfeq ALU, r0

    #if start==0 and pixel==0 : start=0
        cmov r8, r0, 1
        cmov r7, r7, r1
    #if start==0 and pixel!=0 : start=1, start_x=r1(index)

$col_proj_comm_loop_end:
sfltu r1, r4
bf  $col_proj_comm
add r1, r1, 1

sfeq r0, r8
bf   $last_is_no_line
sub  --,  r1, r7
sfltu ALU, r2
bf   $last_is_no_line
add  --, r1, r7                                                     #x_start+x_end
srl  --, ALU, 1                                                    #(x_start+x_end)/2
sw   r5, MUL, 0                                                        #store center
add  r5, r5, 4
$last_is_no_line:
jr r9
nop

#
# Column Projection
########################################################################



########################################################################
# Row Projection
#

# u.r2  = Address of first(top) vector on PE array      || v.r2U = start address of vectors on PE
# u.r3  = number of vectors                             || v.r6U = number of vectors
# u.r4  = nPE                                           || v.r5 = comm register
# u.r5  = Store Address on CP                           || v.r6 = end address of vectors
#                                                       || v.r7U = threshold
# r6    = min(nPE, nVect)
# r7    = counter


$ROW_PROJ:
add r2, r0, 0                           || v.add r2, r0, 0
add --, r3, 0                           || v.add r6, CP, 0
nop                                     || v.add r5, r0, 0

add r6, r3, -1                          || v.sll --, WB, 2
sfltu P1, r4, r3                        || v.add r6, MUL, r2
add.P1 r6, r4, 0
add r7, r0, 1                           || v.sfgeu  P1, r0, r1

#phase1: lead in
#for min(nPE, nVect) = r6

$RP_PHASE1:
sfeq ALU, r6                            || v.lw.P1   --,  r2,   0
nop                                     || v.add.P1  r2,  r2,   4
bnf $RP_PHASE1                          || v.add.P1  r5,  l.r5, LSU
add r7, r7, 1                           || v.sfgeu   P1,  CP,   r1


j.P1 $row_proj_comm_init

#in case nVect<nPE we now need to continue without store in the CP yet
add r6, r4, 0
add --, r7, 0                             || v.sfltu P2, r2, r6

$RP_PHASE1_B:
#### memory energy efficient implementation
nop                                       || v.lw.P1.P2     --,  r2,   0
nop                                       || v.add.P1.P2    r5,  l.r5, LSU
sfeq ALU, r6                              || v.add.P1.P2    r2,  r2,   4
bnf  $RP_PHASE1_B                         || v.sfltu.P1.P2  P2,  ALU,  r6
add  r7, r7, 1                            || v.sfgeu.P2     P1,  CP,   r1

##Faster, but accesses memory out of bounds (always reads array of nPE vectors (altough not modified)
#nop                                      || v.lw.P1   --,  r2,   0
#sfeq ALU, r6                             || v.add.P1  r5,  l.r5, LSU
#bnf $RP_PHASE1_B                         || v.add.P1  r2,  r2,   4
#add r7, r7, 1                            || v.sfgeu   P1,  CP,   r1

$row_proj_comm_init:
nop                                       || v.zimm {{ imm1(cfg.pe.size-1) }}
add r8, r0,  0                            || v.sfeq      P2,  r1,   {{ imm2(cfg.pe.size-1) }}    #set P2 in PE_N
add r6, r0,  2                            || v.lw.P1     --,  r2,   0     #prefetch first element
add r1, r0,  0                            || v.add.P1    r5,  l.r5, LSU
add r10, r0, 1                            || v.add.P1    r2, r2, 4
nop                                       || v.sfltu.P1  P1, ALU, r6


$row_proj_comm:
sfeq r0, r8                             || v.sfltu.P2  r5, r7           #compare to threshold in r7
bf $ystart_is_zero                      || v.cmov.P2   --, r0,  1
    sfne t.r0, r0                       || v.add.P2    --, ALU, 0       #communicate thesholded value to CP
    #start!=0 and pixel!=0 : continue
    bf $row_proj_comm_loop_end          || v.lw.P1     --,  r2,   0
    #start!=0 and pixel==0 : end
    sub  --, r1, r7
    sfleu ALU, r6
    #if length < TH: start=0
    add r8, r0, 0                                                       #start=0
    bf  $row_proj_comm_loop_end
    add --, r1, r7                                                      #y_start+y_end
    srl --, ALU, 1                                                      #(y_start+y_end/2)
    sw  r5, MUL, 0                                                      #store center
    j   $row_proj_comm_loop_end
    add r5, r5, 4                                                       #increment storage pointer

$ystart_is_zero:
    #(thanks to branch slot flag is set)
    #if start==0 and pixel==0 : start=0
        cmov r8, r10, r0                || v.lw.P1     --,  r2,   0
        cmov r7, r1, r7
    #if start==0 and pixel!=0 : start=1, start_y=r1(index)

$row_proj_comm_loop_end:
sfltu r1, r3                            || v.add.P1    r5, l.r5, LSU
bf  $row_proj_comm                      || v.add.P1    r2, r2,   4
add r1, r1, 1                           || v.sfltu.P1  P1, ALU,  r6

sfeq r0, r8
bf   $last_row_is_no_line
sub  --,  r1, r7
sfltu ALU, r2
bf   $last_row_is_no_line
add  --, r1, r7                                                         #y_start+y_end
srl  --, ALU, 1                                                         #(y_start+y_end)/2
sw   r5, MUL, 0                                                         #store center
add  r5, r5, 4
$last_row_is_no_line:
jr r9
nop


#
# Row Projection
########################################################################

{{ dataSection( genMem(rows, cfg.pe.size) ) }}