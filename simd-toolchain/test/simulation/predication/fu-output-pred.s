###BEGIN: predication FU output test 4 stage Automatic Bypass
###TOOL: ${S_AS}
###ARGS: ${FILE} -o pred-fu-4-b -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:pred-fu-4-b -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json -dump-dmem -dump-dmem-prefix pred-fu-4-b
###MDUMP: pred-fu-4-b.baseline.scalar.dump:pred-fu.scalar.ref
###END:

###BEGIN: predication FU output test 4 stage RTL Automatic Bypass
###TOOL: ${S_CC}
###ARGS: ${FILE} -o pred-fu-4-b --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json
###RTL: pred-fu-4-b.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage.json ${SOLVER_ROOT}/rtl
###MDUMP: cp.dmem.dump:pred-fu.scalar.ref
###END:

                          v.add    r2, r0,   5    # put 5 in ALU
                          v.sfleu  P1, r2,   0    # set P1 if 5 <= 0                            -- should NOT be the case
                          v.add    r2, r0,   10   # put 10 in ALU
                          v.add.P1 r2, r0,   5    # if(P1) put 5 in ALU, o.w. keep 10           -- should NOT happen
add      r1, h.r0, 0   || v.add    r0, r2,   0    # communicate ALU contents to CP for storing  -- should be 10
sw       r0, r1,   0                              # store ALU contents
nop                                               # make sure store commits
nop                                               # make sure store commits
j 0                                               # end
nop
