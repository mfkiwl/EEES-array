###BEGIN: Erosion cross kernel 5 stage
###TOOL: ${S_AS}
###ARGS: ${FILE} -o erosion -arch-param cp-dwidth:32,pe-dwidth:16,stage:5
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:erosion -arch-param cp-dwidth:32,pe-dwidth:16,pe:4,stage:5,cp-dmem-depth:5,pe-dmem-depth:5 -dump-dmem -dump-dmem-prefix erosion -dmem 0:pe:${FILEDIR}/erosion.vector.dmem_init
###MDUMP: erosion.baseline.scalar.dump
###MDUMP: erosion.baseline.vector.dump
###END:

#
# Assembly for erosion on nPE's
#

#
#		    Cross kernel:
#
#					  top
#						 |
#		left - center - right
#						 |
#					 bottom
#


# r7, r8, r15 are pixel buffer
# r4, r5 is result buffer
# r6 contains pointer to current pixel


#ASM CP                             ASM PE
#loop init
add r7, r0, 1                                                 #CP argument (5) = number of vectors divided by 3
                                 || v.addi r6, r0, 0          #set r6 to pixel 0
                                    v.lw r7, ALU1,  0         #fill pixel buffer
                                    v.lw r8, ALU2,  1         #fill pixel buffer
                                    v.nop
                                    v.nop                     #wait for r8



main_loop: #execute floor(h/3) times (cp.r7 = 5)
nop
                                 || v.lw r15, r6, 2            #load next bottom pixel
                                    v.and ALU1, r7, r8        #and vertical buffer					
                                    v.and ALU1, ALU1,	LSU     #and with load	
                                    v.and ALU1, l.r8, ALU1    #and it with horizontal pixels (neighbor)
                                    v.and ALU1, r.r8, ALU1    #and it with horizontal pixels (neighbor)
                                    v.sw  r6, ALU1, 1         #store result (memory is not read again, this is safe!)

                                    v.lw r7, r6, 3            #load next bottom pixel
                                    v.and ALU1, r8, r15        #and vertical buffer					
                                    v.and ALU1, ALU1,	LSU     #and with load	
                                    v.and ALU1, l.r15, ALU1    #and it with horizontal pixels (neighbor)
                                    v.and ALU1, r.r15, ALU1    #and it with horizontal pixels (neighbor)
                                    v.sw  r6, ALU1, 2         #store result 

                                    v.lw r8, r6, 4            #load next bottom pixel
                                    v.and ALU1, r7, r15        #and vertical buffer					
                                    v.and ALU1, ALU1,	LSU     #and with load
                                   
add r7, r7, -1
					                       || v.and ALU1, l.r7, ALU1    #and it with horizontal pixels (neighbor)				
sfgts ALU1, r0
                                 || v.and r4, r.r7, ALU1      #and it with horizontal pixels (neighbor)								
bf	main_loop
                                 || v.sw  r6, ALU1, 3         #store result 									  
nop
                                 || v.addi r6, r6, 6          #add 3 elements to pixel pointer (3*2)

																		v.sw r6, r0, 4						#blanc bottom line
                                    v.sw r0, r0, 0						#blanc top line



																		v.nop 										#additional cycle to execute store words
                                    v.nop
j  0                      		
nop                
