###BEGIN: predication FU output test 4 stage
###TOOL: ${S_AS}
###ARGS: ${FILE} -o pred-fu-4-b -arch-param stage:4,predicate:2
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:pred-fu-4-b -arch-param stage:4,predicate:2 -dump-dmem -dump-dmem-prefix pred-fu-4-b
###MDUMP: pred-fu-4-b.baseline.scalar.dump:pred-fu.scalar.ref
###END:

###BEGIN: predication FU output test 4 stage RTL
###TOOL: ${S_CC}
###ARGS: ${FILE} -o pred-fu-4-b --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json
###RTL: pred-fu-4-b.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json ${SOLVER_ROOT}/rtl
###MDUMP: cp.dmem.dump:pred-fu.scalar.ref
###END:

v.add --, r0, 5        # put 5 in ALU
v.sfleu P1, ALU, 0     # set P1 if 5 <= 0                            -- should NOT be the case
v.add --, r0, 10       # put 10 in ALU
v.add.P1 --, r0, 5     # if(P1) put 5 in ALU, o.w. keep 10           -- should NOT happen
add --, h.r0, 0      || v.add --, ALU, 0       # communicate ALU contents to CP for storing  -- should be 10
sw r0, ALU, 0                                  # store ALU contents 
nop                                            # make sure store commits
nop                                            # make sure store commits
j 0                                            # end
nop
