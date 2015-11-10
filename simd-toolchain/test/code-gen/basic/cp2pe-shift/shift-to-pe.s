# Shift a row to PE data memory from CP data memory

###BEGIN: CP to PE shifting 4 stage
###TOOL: ${S_CG}
###ARGS: ${FILE} -o cp2pe-shift-4-b.s
###TOOL: ${S_AS}
###ARGS: cp2pe-shift-4-b.s -o cp2pe-shift-4-b
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:cp2pe-shift-4-b -dmem 0:cp:cp2pe-shift-4-b.cp.dmem_init -dump-dmem -dump-dmem-prefix cp2pe-shift-4-b -max-cycle 1500
###MDUMP: cp2pe-shift-4-b.baseline.vector.dump:shift-to-pe.vector.ref
###END:

###BEGIN: CP to PE shifting 4 stage no bypass
###TOOL: ${S_CG}
###ARGS: ${FILE} -o cp2pe-shift-4.s -arch-param bypass:false
###TOOL: ${S_AS}
###ARGS: cp2pe-shift-4.s -o cp2pe-shift-4 -arch-param bypass:false
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:cp2pe-shift-4 -dmem 0:cp:cp2pe-shift-4.cp.dmem_init -dump-dmem -dump-dmem-prefix cp2pe-shift-4 -max-cycle 1500 -arch-param bypass:false
###MDUMP: cp2pe-shift-4.baseline.vector.dump:shift-to-pe.vector.ref
###END:

###BEGIN: CP to PE shifting 5 stage
###TOOL: ${S_CG}
###ARGS: ${FILE} -o cp2pe-shift-5-b.s -arch-param stage:5
###TOOL: ${S_AS}
###ARGS: cp2pe-shift-5-b.s -o cp2pe-shift-5-b -arch-param stage:5
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:cp2pe-shift-5-b -dmem 0:cp:cp2pe-shift-5-b.cp.dmem_init -dump-dmem -dump-dmem-prefix cp2pe-shift-5-b -max-cycle 1500 -arch-param stage:5
###MDUMP: cp2pe-shift-5-b.baseline.vector.dump:shift-to-pe.vector.ref
###END:

###BEGIN: CP to PE shifting 5 stage no bypass
###TOOL: ${S_CG}
###ARGS: ${FILE} -o cp2pe-shift-5.s -arch-param bypass:false,stage:5
###TOOL: ${S_AS}
###ARGS: cp2pe-shift-5.s -o cp2pe-shift-5 -arch-param bypass:false,stage:5
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:cp2pe-shift-5 -dmem 0:cp:cp2pe-shift-5.cp.dmem_init -dump-dmem -dump-dmem-prefix cp2pe-shift-5 -max-cycle 1500 -arch-param bypass:false,stage:5
###MDUMP: cp2pe-shift-5.baseline.vector.dump:shift-to-pe.vector.ref
###END:
    .text
    .globl  main
    .align  2
    .type   main,@function
    .ent       main
main:
    .frame     %SP,0
    args       0
    rvals      32
    bb         0
    mov        %a0, 0
    mov        %a1, samples
    call       shift_row_to_pe
    mov        %v0, %ZERO
    ret        %RA
    .end       main

    .text
    .globl  shift_row_to_pe
    .type   shift_row_to_pe,@function
    .ent    shift_row_to_pe
shift_row_to_pe:
    .frame     %SP,0
    args       2
    mnum       5
    bb         0
    succ       1
    mloc       1
    lw         %r100, %ZERO, -1
    mov        %r101, 1
    mloc       2
    sw         %r101, %ZERO, -1 # Set boundary mode to scalar
    v.mov      %r2, 0
    mov        %r0, %NUMPE
$shift_row_to_pe_P_loop:
    bb         1
    pred       0
    pred       1
    succ       1
    succ       2
    mloc       3
    lw         %r1,  %a1, 0
    v.push_h   %r2, %r1, %r2
    add        %a1, %a1, 4
    add        %r0, %r0, -1
    brgt       %r0, 0, $shift_row_to_pe_P_loop
    bb         2
    pred       1
    mloc       4
    v.sw       %r2,   %a0,   0
    mloc       5
    sw         %r100, %ZERO, -1
    ret        %RA
    .end       shift_row_to_pe

    .type   samples,@object
    .data
    .globl  samples
samples:
    .long   17101
    .long   30365
    .long   58637
    .long   40520
    .long   30365
    .long   58637
    .long   17101
    .long   40520
    .size   samples, 32
