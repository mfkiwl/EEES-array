										    #set filter coefficients
{% set rows = cfg.pe.size %}
{% set coefs = [1,2,3,4,5] %}
{% set startAddr = 0 %}

zimm {{ imm1(rows-4) }}	 			     ||	v.add r2, r0, {{ coefs[0] }}
add r1, r0,{{ imm2(rows-4)}} 			 || v.add r3, r0, {{ coefs[1] }}
											v.add r4, r0, {{ coefs[2] }}
											v.add r5, r0, {{ coefs[3] }}
											v.add r6, r0, {{ coefs[4] }}
									        v.add r7, r0, {{ startAddr }}

									        #prefetch
											v.lw r8,  ALU, 0
											v.lw r9,  ALU, 1
											v.lw r10, ALU, 2
											v.lw r11, ALU, 3

$FIR:
add r1, r1, -5						   ||	v.lw r12, ALU, 4
											v.mul WB, r2,  r8
											v.mul --, r3,  r9
											v.add --, WB,  MUL
											v.mul --, r4,  r10
											v.add --, ALU, MUL
											v.mul --, r5,  r11
											v.add --, ALU, MUL
											v.mul --, r6,  LSU
											v.add --, ALU, MUL
											v.sw  r7, ALU, 0

											v.lw  r8, r7,  5
											v.mul WB, r2,  r9
											v.mul --, r3,  r10
											v.add --, WB,  MUL
											v.mul --, r4,  r11
											v.add --, ALU, MUL
											v.mul --, r5,  r12
											v.add --, ALU, MUL
											v.mul --, r6,  LSU
											v.add --, ALU, MUL
											v.sw  r7, ALU, 1

											v.lw  r9, r7,  6
											v.mul WB, r2,  r10
											v.mul --, r3,  r11
											v.add --, WB,  MUL
											v.mul --, r4,  r12
											v.add --, ALU, MUL
											v.mul --, r5,  r8
											v.add --, ALU, MUL
											v.mul --, r6,  LSU
											v.add --, ALU, MUL
											v.sw  r7, ALU, 2

											v.lw r10, r7,  7
											v.mul WB, r2,  r11
											v.mul --, r3,  r12
											v.add --, WB,  MUL
											v.mul --, r4,  r8
											v.add --, ALU, MUL
											v.mul --, r5,  r9
											v.add --, ALU, MUL
											v.mul --, r6,  LSU
											v.add --, ALU, MUL
											v.sw  r7, ALU, 3

											v.lw r11, r7, 8
											v.mul WB, r2,  r12
											v.mul --, r3,  r8
											v.add --, WB,  MUL
											v.mul --, r4,  r9
											v.add --, ALU, MUL
											v.mul --, r5,  r10
											v.add --, ALU, MUL
											v.mul --, r6,  LSU
sfgts ALU,	0			               ||	v.add --, ALU, MUL
bf $FIR					               ||	v.sw  r7, ALU, 4

nop						               ||	v.add r7, r7, 20

nop
j 0
nop


#See scripts/python/utils/datasection_utils.py for the generation
#of this 'random' datasection
# genDataSection([[randrange(pow(2,16)) for i in range(nCols)] for j in range(nRows)])
{{ randomDataSection(cfg.pe.size, cfg.pe.size) }}