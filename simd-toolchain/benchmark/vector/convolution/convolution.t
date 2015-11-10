#
# Assembly for non-separable 3x3 filter on nPE's
#
# coefs:
# r1 r3 r4
# r5 r6 r7
# r8 r9 r10
{% set coefs = [ 1, 1, 1,   1, 8, 1,   1, 1, 1 ] %}
{% set rows = cfg.pe.size %}
{% set startAddr = 0 %}


sw r0, r0, -1									||  v.add r2,  r0, {{ coefs[0] }}  #set wrap mode to read zero for border padding
													v.add r3,  r0, {{ coefs[1] }}
													v.add r4,  r0, {{ coefs[2] }}
													v.add r5,  r0, {{ coefs[3] }}
zimm {{ imm1(rows-3) }}	  						||	v.add r6,  r0, {{ coefs[4] }}
add r1, r0, {{ imm2(rows-3) }}	    			||  v.add r7,  r0, {{ coefs[5] }}
													v.add r8,  r0, {{ coefs[6] }}
zimm {{ imm1(startAddr) }} 						||	v.add r9,  r0, {{ coefs[7] }}
add --, r0, {{ imm2(startAddr) }}				|| 	v.add r10, r0, {{ coefs[8] }}

add --, ALU, 0 									||	v.add r11, CP, 0	#load address
     												v.lw r12, ALU, 0
													v.lw r13, ALU, 1
$CONV:
add r1, r1, -3			||	v.lw r14, ALU,   2
sfgts ALU, r0			||	v.mul WB, l.r12, r2
							v.mul --, r12,   r3
							v.add --, MUL,   WB
							v.mul --, r.r12, r4
							v.add --, ALU,   MUL
							v.mul --, l.r13, r5
							v.add --, ALU,   MUL
							v.mul --, r13,   r6
							v.add --, ALU,   MUL
							v.mul --, r.r13, r7
							v.add --, ALU,   MUL
							v.mul --, l.LSU, r8
							v.add --, ALU,   MUL
							v.mul --, LSU,   r9
							v.add --, ALU,   MUL
							v.mul --, r.LSU, r10
							v.add --, ALU,   MUL
							v.sw  r11, ALU,  1


							v.lw r12, r11, 	 3
							v.mul WB, l.r13, r2
							v.mul --, r13, 	 r3
							v.add --, WB,    MUL
							v.mul --, r.r13, r4
							v.add --, ALU,   MUL
							v.mul --, l.r14, r5
							v.add --, ALU,   MUL
							v.mul --, r14,   r6
							v.add --, ALU,   MUL
							v.mul --, r.r14, r7
							v.add --, ALU,   MUL
							v.mul --, l.LSU, r8
							v.add --, ALU,   MUL
							v.mul --, LSU,   r9
							v.add --, ALU,   MUL
							v.mul --, r.LSU, r10
							v.add --, ALU,   MUL
							v.sw  r11, ALU,  2

							v.lw r13, r11,   4
							v.mul WB, l.r14, r2
							v.mul --, r14,   r3
							v.add --, WB,    MUL
							v.mul --, r.r14, r4
							v.add --, ALU,   MUL
							v.mul --, l.r12, r5
							v.add --, ALU,   MUL
							v.mul --, r12,   r6
							v.add --, ALU,   MUL
							v.mul --, r.r12, r7
							v.add --, ALU,   MUL
							v.mul --, l.LSU, r8
							v.add --, ALU,   MUL
							v.mul --, LSU,   r9
							v.add --, ALU,   MUL
							v.mul --, r.LSU, r10
							v.add --, ALU,   MUL
bf $CONV				||	v.sw  r11, ALU,  3
nop						||	v.add r11, r11,  12

#blanc top and bottom line:
nop						||	v.sw ALU, r0, 1
nop						||	v.sw r0, r0, 0
nop
nop
j 0
nop


#See scripts/python/utils/datasection_utils.py for the generation
#of this 'random' datasection
# genDataSection([[randrange(pow(2,16)) for i in range(nCols)] for j in range(nRows)])
{{ randomDataSection(cfg.pe.size, cfg.pe.size) }}