###BEGIN: pred for #87 test 4 stage
###TOOL: ${S_AS}
###ARGS: ${FILE} -o pred-87-4-b -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:pred-87-4-b -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json -dump-dmem -dump-dmem-prefix pred-87-4-b
###MDUMP: pred-87-4-b.baseline.vector.dump:pred-87.baseline.vector.dump.ref
###END:

###BEGIN: pred for #87 test 4 stage RTL
###TOOL: ${S_CC}
###ARGS: ${FILE} -o pred-87-4-b --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json
###RTL: pred-87-4-b.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage.json ${SOLVER_ROOT}/rtl
###MDUMP: pe-array.dmem.dump:pred-87.baseline.vector.dump.ref
###END:

v.add    r3, r0, 10             #set r3 to 10
v.add    r2, r0, 2              #set r2 to 2
v.sfne   P1, r0, r0             #unset P1
v.add    r3, r0, 3              #set r3 to 3
v.add.P1 r2, r0, r0             #Predicated set r2 to r0
v.add    r4, r0, 4              #set r4 to 4
nop
nop
nop
v.sw     r0, r2, 0              #store r2, should be 2  (gets 3  in RTL)
v.sw     r0, r3, 1              #store r3, should be 3  (gets 10 in RTL)
v.sw     r0, r4, 2              #store r4, should be 4
v.nop
v.nop
j 0 || v.nop
nop
