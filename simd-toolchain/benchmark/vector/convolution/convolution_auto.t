#
# Assembly for non-separable 3x3 filter on nPE's
#
# coefs:
# r1 r3 r4
# r5 r6 r7
# r8 r9 r10

# PE register usage: +2
# CP register usage:
#
# instructions: +0
#

sw r0, r0, -1									||  v.add r2,  r0, {{ coefs[0] }}  #set wrap mode to read zero for border padding
													v.add r3,  r0, {{ coefs[1] }}
													v.add r4,  r0, {{ coefs[2] }}
													v.add r5,  r0, {{ coefs[3] }}
zimm {{ imm1(rows-3) }}	  						||	v.add r6,  r0, {{ coefs[4] }}
add r1, r0, {{ imm2(rows-3) }}	    			||  v.add r7,  r0, {{ coefs[5] }}
													v.add r8,  r0, {{ coefs[6] }}
zimm {{ imm1(startAddr) }} 						||	v.add r9,  r0, {{ coefs[7] }}
add r2, r0, {{ imm2(startAddr) }}				|| 	v.add r10, r0, {{ coefs[8] }}

add r0, r2, 0 									||	v.add r11, CP, 0	#load address
     												v.lw r12, r11, 0
													v.lw r13, r11, 1
$CONV:
add r1, r1, -3			||	v.lw r14, r11,   2
sfgts r1, r0			||	v.mul r16, l.r12, r2
							v.mul r15, r12,   r3
							v.add r16, r16,   r15
							v.mul r15, r.r12, r4
							v.add r16, r16,   r15
							v.mul r15, l.r13, r5
							v.add r16, r16,   r15
							v.mul r15, r13,   r6
							v.add r16, r16,   r15
  							v.mul r15, r.r13, r7
							v.add r16, r16,   r15
							v.mul r15, l.r14, r8
							v.add r16, r16,   r15
							v.mul r15, r14,   r9
							v.add r16, r16,   r15
							v.mul r15, r.r14, r10
							v.add r16, r16,   r15
							v.sw  r11, r16,  1


							v.lw r12, r11, 	 3
							v.mul r16, l.r13, r2
							v.mul r15, r13, 	 r3
							v.add r16, r16,  r15
							v.mul r15, r.r13, r4
							v.add r16, r16,  r15
							v.mul r15, l.r14, r5
							v.add r16, r16,  r15
							v.mul r15, r14,   r6
							v.add r16, r16,  r15
							v.mul r15, r.r14, r7
							v.add r16, r16,  r15
							v.mul r15, l.r12, r8
							v.add r16, r16,  r15
							v.mul r15, r12,   r9
							v.add r16, r16,  r15
							v.mul r15, r.r12, r10
							v.add r16, r16,  r15
							v.sw  r11, r16,  2

							v.lw r13, r11,   4
							v.mul r16, l.r14, r2
							v.mul r15, r14,   r3
							v.add r16, r16,   r15
							v.mul r15, r.r14, r4
							v.add r16, r16,  r15
							v.mul r15, l.r12, r5
							v.add r16, r16,  r15
							v.mul r15, r12,   r6
							v.add r16, r16,  r15
							v.mul r15, r.r12, r7
							v.add r16, r16,  r15
							v.mul r15, l.r13, r8
							v.add r16, r16,  r15
							v.mul r15, r13,   r9
							v.add r16, r16,  r15
							v.mul r15, r.r13, r10
							v.add r16, r16,  r15
bf $CONV				||	v.sw  r11, r16,  3
nop						||	v.add r11, r11,  12


#blanc top and bottom line:
nop						||	v.sw r11, r0, 1
nop						||	v.sw r0,  r0, 0
nop
nop
j 0
nop



#See scripts/python/utils/datasection_utils.py for the generation
#of this 'random' datasection
# genDataSection([[randrange(pow(2,16)) for i in range(nCols)] for j in range(nRows)])
{{ randomDataSection(cfg.pe.size, cfg.pe.size) }}