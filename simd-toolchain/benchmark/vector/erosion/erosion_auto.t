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

# PE register usage: +1
# CP register usage: +1
#
# instructions: +0
#

# erosion runs in place

{% set rows = cfg.pe.size %}
{% set startAddr = 0 %}

zimm {{ imm1(rows) }}
add r3, r0, {{ imm2(rows) }}
zimm {{ imm1(startAddr) }}
add r2, r0, {{ imm2(startAddr) }}


add r3, r3, -4                  || v.lw r2,  CP,   0
sll r4, r3,  2                  || v.lw r3,  CP,   0
add r1, r2,  8

$ER_LOOP:
add r1, r1, 4                   || v.lw r4,  CP,   0
nop                             || v.and r5, r3,   r2
nop                             || v.and r5, r.r3, r5
nop                             || v.and r5, l.r3, r5
nop                             || v.and r5, r4,  r5
add r0, r1, 0                   || v.sw  CP, r5,  -2

add r1, r1, 4                   || v.lw r2,  CP,   0
nop                             || v.and r5, r4,   r3
nop                             || v.and r5, r.r4, r5
nop                             || v.and r5, l.r4, r5
nop                             || v.and r5, r2,  r5
add r0, r1, 0                   || v.sw  CP, r5,  -2

add r1, r1, 4                   || v.lw r3,  CP,   0
nop                             || v.and r5, r2,   r4
nop                             || v.and r5, r.r2, r5
sfltu r1, r4                    || v.and r5, l.r2, r5
bf  $ER_LOOP                    || v.and r5, r3,  r5
add r0, r1, 0                   || v.sw  CP, r5,  -2

nop
nop
j 0
nop


#See scripts/python/utils/datasection_utils.py for the generation
#of this 'random' datasection
# genDataSection([[randrange(pow(2,16)) for i in range(nCols)] for j in range(nRows)])
{{ randomDataSection(cfg.pe.size, cfg.pe.size) }}