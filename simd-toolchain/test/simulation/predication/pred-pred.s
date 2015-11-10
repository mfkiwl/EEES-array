# Test predication of compare operation, related to issue 85
###BEGIN: predication compare instruction 4 stage
###TOOL: ${S_AS}
###ARGS: ${FILE} -o pred-pred-4-b -arch-param stage:4,predicate:2
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:pred-pred-4-b -arch-param stage:4,predicate:2 -dump-dmem -dump-dmem-prefix pred-pred-4-b
###MDUMP: pred-pred-4-b.baseline.vector.dump:pred-pred.vector.ref
###END:

###BEGIN: predication compare instruction 4 stage RTL
###TOOL: ${S_CC}
###ARGS: ${FILE} -o pred-pred-4-b --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json
###RTL: pred-pred-4-b.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json ${SOLVER_ROOT}/rtl
###MDUMP: pe-array.dmem.dump:pred-pred.vector.ref
###END:

v.sfne      P1,  r0,  r0   # unset P1 (seems to work)
v.sfne      P2,  r0,  r0   # unset P2 (seems to work)
v.sfeq.P1   P2,  r0,  r0   # should be disabled by P1, thus P2 should be unaffected (simulator seems to set it anyway)

#test for predication on P2. storing 5=unset, 10=set.
v.add       --,  r0,  5    # ALU=5
v.add.P2    --,  r0,  10   # should be predicated by P2
v.sw        r0,  ALU, 0    # RTL simulation stores 5,  simulator stores 10
nop
nop
j 0
nop
