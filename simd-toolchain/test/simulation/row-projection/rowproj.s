###BEGIN: Row projection 5 stage
###TOOL: ${S_AS}
###ARGS: ${FILE} -o rowproj -arch-param cp-dwidth:32,pe-dwidth:16,stage:5
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:rowproj -arch-param cp-dwidth:32,pe-dwidth:16,pe:4,stage:5,cp-dmem-depth:8,pe-dmem-depth:8 -dump-dmem -dump-dmem-prefix rowproj -dmem 0:pe:${FILEDIR}/rowproj.vector.dmem_init
###MDUMP: rowproj.baseline.scalar.dump
###MDUMP: rowproj.baseline.vector.dump
###END:


#
# Assembly for rowProjection on 4PE's
#
# Calculates the row sum of 5 rows
#

add r4, r0, 5
add r7, r0, 4
                     ||   v.lw   r8, r0, 0              #load pixels of row0 into r8
add r8, r0, 0
                     ||   v.add  r7, r0, 2              #set rowAddr to 2 (row1)
add r15, r0, 0

sum_loop:
add 	r7, r7, -1	   
sfgts	ALU1, r0
bf 		sum_loop
add 	r15, h.r8, r15 ||
                          v.add   r8, r.r8, 0           #shift left

add r7, r0, 4
                     ||   v.lw    r8, r7, 0             #load next row
sflts r8, 16
                     ||   v.add   r7, r7, 2             #increase row Addr by 2
sw r8,r15,0
add r15, r0, 0
bf sum_loop
add r8, r8, 4

j 0
nop 
