###BEGIN: predication with auto bypass 4 stage test Automatic Bypassing
###TOOL: ${S_AS}
###ARGS: ${FILE} -o predication-auto-bypass -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:predication-auto-bypass -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json -dump-dmem -dump-dmem-prefix predication-auto-bypass
###MDUMP: predication-auto-bypass.baseline.vector.dump
###END:

###BEGIN: predication with auto bypass 5 stage test Automatic Bypassing
###TOOL: ${S_AS}
###ARGS: ${FILE} -o predication-auto-bypass -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage.json
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:predication-auto-bypass -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage.json -dump-dmem -dump-dmem-prefix predication-auto-bypass
###MDUMP: predication-auto-bypass.baseline.vector.dump
###END:


###BEGIN: predication with auto bypass 4 stage test RTL Automatic Bypassing
###TOOL: ${S_CC}
###ARGS: ${FILE} -o predication-auto-bypass --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json
###RTL: predication-auto-bypass.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage.json ${SOLVER_ROOT}/rtl
###MDUMP: pe-array.dmem.dump:predication-auto-bypass.baseline.vector.dump.ref
###END:

        v.add.P1  r3, r0, 5
        v.sw      r0, r3, 0
        v.sw      r0, r3, 1
        v.sw      r0, r3, 2
        v.sfges   P1, r1, 2
        v.add.P1  r4, r0, 3
        v.sw      r0, r4, 3
        v.sw      r0, r4, 4
        v.sw      r0, r4, 5
        nop
        nop
        j 0
        nop

