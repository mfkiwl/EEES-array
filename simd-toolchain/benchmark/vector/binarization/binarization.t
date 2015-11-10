#
# Assembly for Binarization on nPE's
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
sll --, r3, 2
add --, r2, MUL					|| v.zimm   {{ imm1(threshold) }}
add r4, ALU, -4    	            || v.add 	r2, r0, {{ imm2(threshold) }}
add --, r2, 0                   || v.nop
$BIN_LOOP:
sfeq ALU, r4                    || v.lw 	--,  CP,  0
nop                             || v.sfltu  LSU, r2
bnf $BIN_LOOP                   || v.cmov 	--,  r0,  1
add r2, r2, 4                   || v.sw 	CP,  ALU, 0

nop || v.nop
nop || v.nop
j 0
nop
nop

#See scripts/python/utils/datasection_utils.py for the generation
#of this 'random' datasection
# genDataSection([[randrange(pow(2,16)) for i in range(nCols)] for j in range(nRows)])
{{ randomDataSection(cfg.pe.size, cfg.pe.size) }}