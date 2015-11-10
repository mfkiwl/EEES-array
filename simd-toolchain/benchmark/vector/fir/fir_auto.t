										    #set filter coefficients

# PE register usage: +2
# CP register usage: +0
#
# instructions: +0
#
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
											v.lw r8,  r7, 0
											v.lw r9,  r7, 1
											v.lw r10, r7, 2
											v.lw r11, r7, 3

$FIR:
add r1, r1, -5						   ||	v.lw  r12, r7,  4
											v.mul r13, r2,  r8
											v.mul r14, r3,  r9
											v.add r13, r13, r14
											v.mul r14, r4,  r10
											v.add r13, r13, r14
											v.mul r14, r5,  r11
											v.add r13, r13, r14
											v.mul r14, r6,  r12
											v.add r13, r13, r14
											v.sw  r7,  r13, 0

											v.lw  r8,  r7,  5
											v.mul r13, r2,  r9
											v.mul r14, r3,  r10
											v.add r13, r13, r14
											v.mul r14, r4,  r11
											v.add r13, r13, r14
											v.mul r14, r5,  r12
											v.add r13, r13, r14
											v.mul r14, r6,  r8
											v.add r13, r13, r14
											v.sw  r7,  r13, 1

											v.lw  r9,  r7,  6
											v.mul r13, r2,  r10
											v.mul r14, r3,  r11
											v.add r13, r13, r14
											v.mul r14, r4,  r12
											v.add r13, r13, r14
											v.mul r14, r5,  r8
											v.add r13, r13, r14
											v.mul r14, r6,  r9
											v.add r13, r13, r14
											v.sw  r7,  r13, 2

											v.lw  r10, r7,  7
											v.mul r13, r2,  r11
											v.mul r14, r3,  r12
											v.add r13, r13, r14
											v.mul r14, r4,  r8
											v.add r13, r13, r14
											v.mul r14, r5,  r9
											v.add r13, r13, r14
											v.mul r14, r6,  r10
											v.add r13, r13, r14
											v.sw  r7,  r13, 3

											v.lw  r11, r7,  8
											v.mul r13, r2,  r12
											v.mul r14, r3,  r8
											v.add r13, r13, r14
											v.mul r14, r4,  r9
											v.add r13, r13, r14
											v.mul r14, r5,  r10
											v.add r13, r13, r14
											v.mul r14, r6,  r11
sfgts r1,	0			               ||	v.add r13, r13, r14
bf $FIR					               ||	v.sw  r7,  r13, 4

nop						               ||	v.add r7,  r7,  20

nop
j 0
nop


#See scripts/python/utils/datasection_utils.py for the generation
#of this 'random' datasection
# genDataSection([[randrange(pow(2,16)) for i in range(nCols)] for j in range(nRows)])
{{ randomDataSection(cfg.pe.size, cfg.pe.size) }}