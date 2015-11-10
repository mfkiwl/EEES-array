# PE register usage: +1
# CP register usage:
#
# instructions: -1
#

{% set rows = cfg.pe.size %}
{% set startAddr = 0 %}
{% set threshold = pow(2,15) %}

zimm {{ imm1(startAddr) }}
add r2, r0, {{ imm2(startAddr) }}
zimm {{ imm1(rows) }}
add r3, r0, {{ imm2(rows) }}
nop

$VECTOR_ADD:
sll r5, r3, 2                   || v.zimm   {{ imm1(threshold) }}
add r4, r2, r5                  || v.add    r2, r0, {{ imm2(threshold) }}
add r4, r4, -8                  || v.add    r3, r0, 0
add r0, r2, 0                   || v.lw     r4, CP, 0

$VADD_LOOP:
nop                             || v.add    r3,  r4, r3
sfeq r2, r4                     || v.lw     r4,  CP, 1
bnf $VADD_LOOP                  || v.add    r3,  r4, r3
add r2, r2, 8                   || v.lw     r4,  CP, 2

nop                             || v.sw     r0,  r3, 0

nop || v.nop
nop || v.nop
j 0
nop
nop

#See scripts/python/utils/datasection_utils.py for the generation
#of this 'random' datasection
# genDataSection([[randrange(pow(2,16)) for i in range(nCols)] for j in range(nRows)])
{{ randomDataSection(cfg.pe.size, cfg.pe.size) }}