###BEGIN: column projection with thresholding kernel 5 stage
###TOOL: ${S_AS}
###ARGS: ${FILE} -o colproj -arch-param cp-dwidth:32,pe-dwidth:16,stage:5
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:colproj -arch-param cp-dwidth:32,pe-dwidth:16,pe:4,stage:5,cp-dmem-depth:5,pe-dmem-depth:8 -dump-dmem -dump-dmem-prefix colproj -dmem 0:pe:${FILEDIR}/colproj.vector.dmem_init
###MDUMP: colproj.baseline.scalar.dump
###MDUMP: colproj.baseline.vector.dump
###END:

#calculates The element-wise sum of 5 vectors
#sum is one line below original vectors
#theshold result is below that
																		

#ASM CP                        ASM PE

                                v.addi  r7, r0, 12		#write results at dmem[6] (6*2=12)
                                v.addi WB, r0, 0
addi r7, r0, 4                               
                           ||   v.addi WB, r0, 0

loop:             									  
sfne ALU1, 0
                           ||   v.lw	LSU,ALU2, 0
bf   loop
                           ||   v.addi WB, WB, 2	 			
addi r7, r7, -1
                           ||   v.add WB, WB, LSU

                                v.sw	r7, ALU1, 0
                                v.sflts ALU2, 16				#threshold =16
                                v.cmov ALU1, r0, 1
                                v.sw	r7, ALU1, 1

                                v.nop	##additional cycles for simulator to perform store word (sw)
                                v.nop             
j 0
                           ||   v.nop
nop
