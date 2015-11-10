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

# erosion runs in place

{% set rows = cfg.pe.size %}
{% set startAddr = 0 %}

zimm {{ imm1(rows) }}
add r3, r0, {{ imm2(rows) }}
zimm {{ imm1(startAddr) }}
add r2, r0, {{ imm2(startAddr) }}


add --, r3, -4                  || v.lw r2,  CP,   0
sll r4, ALU, 2                  || v.lw r3,  CP,   0
add --, r2,  8                  || v.add --, r0,   0

$ER_LOOP:
add --, ALU, 4                  || v.lw r4,  CP,   0
nop                             || v.and --, r3,   r2
nop                             || v.and --, r.r3, MUL
nop                             || v.and --, l.r3, MUL
nop                             || v.and --, LSU,  MUL
add --, ALU, 0                  || v.sw  CP, MUL,  -2

add --, ALU, 4                  || v.lw r2,  CP,   0
nop                             || v.and --, r4,   r3
nop                             || v.and --, r.r4, MUL
nop                             || v.and --, l.r4, MUL
nop                             || v.and --, LSU,  MUL
add --, ALU, 0                  || v.sw  CP, MUL,  -2

add r1, ALU, 4                  || v.lw r3,  CP,   0
nop                             || v.and --, r2,   r4
nop                             || v.and --, r.r2, MUL
sfleu ALU, r4                   || v.and --, l.r2, MUL
bf  $ER_LOOP                    || v.and --, LSU,  MUL
add --, r1, 0                   || v.sw  CP, MUL,  -2

nop
nop
j 0
nop


#See scripts/python/utils/datasection_utils.py for the generation
#of this 'random' datasection
# genDataSection([[randrange(pow(2,16)) for i in range(nCols)] for j in range(nRows)])
{{ randomDataSection(cfg.pe.size, cfg.pe.size) }}