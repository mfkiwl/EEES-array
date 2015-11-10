# Shift a row in PE data memory to CP data memory

###BEGIN: PE to CP shifting 4 stage
###TOOL: ${S_CG}
###ARGS: ${FILE} -o pe2cp-shift-4-b.s
###TOOL: ${S_AS}
###ARGS: pe2cp-shift-4-b.s -o pe2cp-shift-4-b
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:pe2cp-shift-4-b -dmem 0:cp:pe2cp-shift-4-b.cp.dmem_init -dmem 0:pe:pe2cp-shift-4-b.pe.dmem_init -dump-dmem -dump-dmem-prefix pe2cp-shift-4-b -max-cycle 1500
###MDUMP: pe2cp-shift-4-b.baseline.scalar.dump:pe2cp-shift.cp.ref
###END:

###BEGIN: PE to CP shifting 4 stage no bypass
###TOOL: ${S_CG}
###ARGS: ${FILE} -o pe2cp-shift-4.s -arch-param bypass:false
###TOOL: ${S_AS}
###ARGS: pe2cp-shift-4.s -o pe2cp-shift-4 -arch-param bypass:false
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:pe2cp-shift-4 -dmem 0:cp:pe2cp-shift-4.cp.dmem_init -dmem 0:pe:pe2cp-shift-4.pe.dmem_init -dump-dmem -dump-dmem-prefix pe2cp-shift-4 -max-cycle 1500 -arch-param bypass:false
###MDUMP: pe2cp-shift-4.baseline.scalar.dump:pe2cp-shift.cp.ref
###END:

###BEGIN: PE to CP shifting 5 stage
###TOOL: ${S_CG}
###ARGS: ${FILE} -o pe2cp-shift-5-b.s -arch-param stage:5
###TOOL: ${S_AS}
###ARGS: pe2cp-shift-5-b.s -o pe2cp-shift-5-b -arch-param stage:5
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:pe2cp-shift-5-b -dmem 0:cp:pe2cp-shift-5-b.cp.dmem_init -dmem 0:pe:pe2cp-shift-5-b.pe.dmem_init -dump-dmem -dump-dmem-prefix pe2cp-shift-5-b -max-cycle 1500 -arch-param stage:5
###MDUMP: pe2cp-shift-5-b.baseline.scalar.dump:pe2cp-shift.cp.ref
###END:

###BEGIN: PE to CP shifting 5 stage no bypass
###TOOL: ${S_CG}
###ARGS: ${FILE} -o pe2cp-shift-5.s -arch-param stage:5,bypass:false
###TOOL: ${S_AS}
###ARGS: pe2cp-shift-5.s -o pe2cp-shift-5 -arch-param stage:5,bypass:false
###TOOL: ${S_SIM}
###ARGS: -imem 0:uni:pe2cp-shift-5 -dmem 0:cp:pe2cp-shift-5.cp.dmem_init -dmem 0:pe:pe2cp-shift-5.pe.dmem_init -dump-dmem -dump-dmem-prefix pe2cp-shift-5 -max-cycle 1500 -arch-param stage:5,bypass:false
###MDUMP: pe2cp-shift-5.baseline.scalar.dump:pe2cp-shift.cp.ref
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
    mov        %a0, 4
    mov        %a1, samples
    call       shift_row_to_cp
    mov        %v0, %ZERO
    ret        %RA
    .end       main

    .globl  shift_row_to_cp
    .align  2
    .type   shift_row_to_cp,@function
    .ent       shift_row_to_cp
shift_row_to_cp:
    .frame     %SP,0
    args       2
    mnum       2
    bb         0
    succ       1
    mov        %r0, %NUMPE
    mloc       1
    v.lw       %r1, %a1, 0

$BB1_1:
    bb         1
    pred       0
    pred       1
    succ       1
    succ       2
    read_h     %r3, %r1, 1
    v.read_r   %r1, %r1, 1
    mloc       2
    sw         %r3, %a0, 0
    add        %a0, %a0, 4
    add        %r0, %r0, -1
    brgt       %r0, 0, $BB1_1
$BB1_2:
    bb         2
    pred       1
    ret        %RA
    .end       shift_row_to_cp

    .type   samples,@object
    .vdata
    .globl  samples
    .align  2
samples:
    .long   17101
    .long   30365
    .long   58637
    .long   40520
    .size   samples, 16
