#
# Assembly for Binarization on nPE's
#

# PE register usage: +1
# CP register usage:
#
# instructions: -1
#

{% set rows = cfg.pe.size %}
{% set threshold = pow(2,15) %}
{% set startAddr = 0 %}

zimm {{ imm1(startAddr) }}
add r2, r0, {{ imm2(startAddr) }}
zimm {{ imm1(rows) }}
add r3, r0, {{ imm2(rows) }}
nop

$BINARIZATION:
sll r5, r3, 2                   || v.zimm   {{ imm1(threshold) }}
add r4, r2, r5         		    || v.add  r2, r0, {{ imm2(threshold) }}
add r4, r4, -4

$BIN_LOOP:
sfeq r2, r4                     || v.lw 	r3,  CP,  0
nop                             || v.sfltu  r3, r2
bnf $BIN_LOOP                   || v.cmov 	r3,  r0,  1
add r2, r2, 4                   || v.sw 	CP,  r3, 0

nop || v.nop
nop || v.nop
j 0
nop
nop

#See scripts/python/utils/datasection_utils.py for the generation
#of this 'random' datasection
# genDataSection([[randrange(pow(2,16)) for i in range(nCols)] for j in range(nRows)])
{{ randomDataSection(cfg.pe.size, cfg.pe.size) }}