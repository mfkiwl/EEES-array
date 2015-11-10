{% set rows = cfg.pe.size %}
{% set startAddr = 0 %}
{% set threshold = pow(2,15) %}

zimm {{ imm1(startAddr) }}
add r2, r0, {{ imm2(startAddr) }}
zimm {{ imm1(rows) }}
add r3, r0, {{ imm2(rows) }}
nop

$VECTOR_ADD:
sll --, r3, 2                   || v.zimm   {{ imm1(threshold) }}
add --, r2, MUL					|| v.add    r2, r0, {{ imm2(threshold) }}
add r4, ALU, -8    	            || v.add    --, r0, 0
add --, r2, 0                   || v.lw     --, CP, 0

$VADD_LOOP:
nop                             || v.add    --,  LSU, ALU
sfeq ALU, r4                    || v.lw     --,  CP, 1
bnf $VADD_LOOP                  || v.add    --,  LSU, ALU
add r2, r2, 8                   || v.lw     --,  CP,  2

nop                             || v.sw     r0, ALU, 0

nop || v.nop
nop || v.nop
j 0
nop
nop


#See scripts/python/utils/datasection_utils.py for the generation
#of this 'random' datasection
# genDataSection([[randrange(pow(2,16)) for i in range(nCols)] for j in range(nRows)])
{{ randomDataSection(cfg.pe.size, cfg.pe.size) }}