###BEGIN: vector add OpenCL kernel static app 4 stage bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/cl_add.sir -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json -o cl_add-4stage-bypass.s
###TOOL: ${S_AS}
###ARGS: cl_add-4stage-bypass.s -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json -o cl_add-4stage-bypass
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:cl_add-4stage-bypass -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json -dump-dmem -dump-dmem-prefix cl_add -dmem 0:pe:${FILEDIR}/cl_add.baseline.vector.dmem_init -dmem 0:cp:cl_add-4stage-bypass.cp.dmem_init -max-cycle 1500
###MDUMP: cl_add.baseline.vector.dump
###END:

###BEGIN: vector add OpenCL kernel static app 4 stage no bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/cl_add.sir -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json -o cl_add-4stage.s
###TOOL: ${S_AS}
###ARGS: cl_add-4stage.s -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json -o cl_add-4stage
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:cl_add-4stage -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json -dump-dmem -dump-dmem-prefix cl_add -dmem 0:pe:${FILEDIR}/cl_add.baseline.vector.dmem_init -dmem 0:cp:cl_add-4stage.cp.dmem_init -max-cycle 1500
###MDUMP: cl_add.baseline.vector.dump
###END:

###BEGIN: vector add OpenCL kernel static app 5 stage bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/cl_add.sir -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage-bypass.json -o cl_add-5stage-bypass.s
###TOOL: ${S_AS}
###ARGS: cl_add-5stage-bypass.s -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage-bypass.json -o cl_add-5stage-bypass
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:cl_add-5stage-bypass -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage-bypass.json -dump-dmem -dump-dmem-prefix cl_add -dmem 0:pe:${FILEDIR}/cl_add.baseline.vector.dmem_init -dmem 0:cp:cl_add-5stage-bypass.cp.dmem_init -max-cycle 1500
###MDUMP: cl_add.baseline.vector.dump
###END:

###BEGIN: vector add OpenCL kernel static app 5 stage no bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/cl_add.sir -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage.json -o cl_add-5stage.s
###TOOL: ${S_AS}
###ARGS: cl_add-5stage.s -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage.json -o cl_add-5stage
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:cl_add-5stage -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage.json -dump-dmem -dump-dmem-prefix cl_add -dmem 0:pe:${FILEDIR}/cl_add.baseline.vector.dmem_init -dmem 0:cp:cl_add-5stage.cp.dmem_init -max-cycle 1500
###MDUMP: cl_add.baseline.vector.dump
###END:

###BEGIN: vector add OpenCL kernel static app 4 stage RTL
###TOOL: ${S_CC}
###ARGS: ${FILEDIR}/cl_add.sir -o cl_add-4stage --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json --pe-dmem ${FILEDIR}/cl_add.baseline.vector.dmem_init
###RTL: cl_add-4stage.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage.json ${SOLVER_ROOT}/rtl
###MDUMP: pe-array.dmem.dump:cl_add.baseline.vector.dump.ref
###END:

###BEGIN: vector add OpenCL kernel static app 4 stage bypass RTL
###TOOL: ${S_CC}
###ARGS: ${FILEDIR}/cl_add.sir -o cl_add-4stage-bypass --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json --pe-dmem ${FILEDIR}/cl_add.baseline.vector.dmem_init
###RTL: cl_add-4stage-bypass.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json ${SOLVER_ROOT}/rtl
###MDUMP: pe-array.dmem.dump:cl_add.baseline.vector.dump.ref
###END:

###BEGIN: vector add OpenCL kernel multi-group static app 4 stage bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/cl_add_multi_gr.sir -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json -o cl_add-4stage-bypass_mg.s
###TOOL: ${S_AS}
###ARGS: cl_add-4stage-bypass_mg.s -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json -o cl_add-4stage-bypass_mg
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:cl_add-4stage-bypass_mg -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json -dump-dmem -dump-dmem-prefix cl_add -dmem 0:pe:${FILEDIR}/cl_add.baseline.vector.dmem_init -dmem 0:cp:cl_add-4stage-bypass_mg.cp.dmem_init -max-cycle 1500
###MDUMP: cl_add.baseline.vector.dump
###END:

###BEGIN: vector add OpenCL kernel multi-group static app 4 stage no bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/cl_add_multi_gr.sir -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json -o cl_add-4stage_mg.s
###TOOL: ${S_AS}
###ARGS: cl_add-4stage_mg.s -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json -o cl_add-4stage_mg
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:cl_add-4stage_mg -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json -dump-dmem -dump-dmem-prefix cl_add -dmem 0:pe:${FILEDIR}/cl_add.baseline.vector.dmem_init -dmem 0:cp:cl_add-4stage_mg.cp.dmem_init -max-cycle 1500
###MDUMP: cl_add.baseline.vector.dump
###END:

###BEGIN: vector add OpenCL kernel multi-group static app 5 stage bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/cl_add_multi_gr.sir -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage-bypass.json -o cl_add-5stage-bypass_mg.s
###TOOL: ${S_AS}
###ARGS: cl_add-5stage-bypass_mg.s -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage-bypass.json -o cl_add-5stage-bypass_mg
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:cl_add-5stage-bypass_mg -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage-bypass.json -dump-dmem -dump-dmem-prefix cl_add -dmem 0:pe:${FILEDIR}/cl_add.baseline.vector.dmem_init -dmem 0:cp:cl_add-5stage-bypass_mg.cp.dmem_init -max-cycle 1500
###MDUMP: cl_add.baseline.vector.dump
###END:

###BEGIN: vector add OpenCL kernel multi-group static app 5 stage no bypass
###TOOL: ${S_CG}
###ARGS: ${FILEDIR}/cl_add_multi_gr.sir -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage.json -o cl_add-5stage_mg.s
###TOOL: ${S_AS}
###ARGS: cl_add-5stage_mg.s -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage.json -o cl_add-5stage_mg
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:cl_add-5stage_mg -arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-5stage.json -dump-dmem -dump-dmem-prefix cl_add -dmem 0:pe:${FILEDIR}/cl_add.baseline.vector.dmem_init -dmem 0:cp:cl_add-5stage_mg.cp.dmem_init -max-cycle 1500
###MDUMP: cl_add.baseline.vector.dump
###END:

###BEGIN: vector add OpenCL kernel multi-group static app 4 stage RTL
###TOOL: ${S_CC}
###ARGS: ${FILEDIR}/cl_add_multi_gr.sir -o cl_add-4stage-mg --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage.json --pe-dmem ${FILEDIR}/cl_add.baseline.vector.dmem_init
###RTL: cl_add-4stage-mg.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage.json ${SOLVER_ROOT}/rtl
###MDUMP: pe-array.dmem.dump:cl_add.baseline.vector.dump.ref
###END:

###BEGIN: vector add OpenCL kernel multi-group static app 4 stage bypass RTL
###TOOL: ${S_CC}
###ARGS: ${FILEDIR}/cl_add_multi_gr.sir -o cl_add-4stage-bypass-mg --arch-cfg ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json --pe-dmem ${FILEDIR}/cl_add.baseline.vector.dmem_init
###RTL: cl_add-4stage-bypass-mg.zip ${SOLVER_ROOT}/arch/baseline-32b-4stage-bypass.json ${SOLVER_ROOT}/rtl
###MDUMP: pe-array.dmem.dump:cl_add.baseline.vector.dump.ref
###END:
