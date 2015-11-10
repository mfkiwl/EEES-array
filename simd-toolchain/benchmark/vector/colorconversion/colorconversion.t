{% set pixels = cfg.pe.size*cfg.pe.size %}
        .text
        .global        __start
        .type          __start,@function
        .ent           __start
__start: # BB_0:
        simm           1
        add            r1, r0, 0
        simm           32
        add            r2, r0, 0
        jal            main
        nop
        j              0
        j              0
        nop
        .end           __start

        .global        main
        .type          main,@function
        .ent           main
main: # BB_0:    .entry
        add            r1, r1, -4
        sw             ALU, r9, 0
        add            r4, r0, 48
        add            r5, r0, 96
        simm           0
        add            r6, r0, 144
        simm           0
        add            r7, r0, 192
        simm           0
        add            r8, r0, 240
        jal            cl_yuv2rgb
        add            r3, r0, 0
# BB_1:        .exit
        lw             r9, r1, 0
        add            r11, r0, 0
        add            r1, r1, 4
        jr             r9
        nop
        .end           main

        .global        cl_yuv2rgb
        .type          cl_yuv2rgb,@function
        .ent           cl_yuv2rgb
cl_yuv2rgb: # BB_1:    .entry
        lw             r13, r0, 1         || v.simm         1
        add            r27, r0, 0         || v.add          r20, r0, 103
        simm           {{ imm1(pixels) }}                   || v.simm         0
        add            r26, r0, {{ imm2(pixels) }}         || v.add          r19, r0, 227
                                             v.simm         0
        lw,            --, r0, 0          || v.add          r18, r0, 183
        add            --, LSU, 0         || v.add          r17, CP, 0
$cl_yuv2rgb.kernel: # BB_0:    l=1
        sll            --, r27, 2
        add            --, r8, MUL
        add            --, ALU, 0         || v.lw           --, CP, 0
                                             v.add          r24, LSU, -128
                                             v.mul          --, ALU, r20
        add            --, r6, MUL        || v.sra          --, MUL, 8
        add            --, ALU, 0         || v.lw           r23, CP, 0
                                             v.add          WB, MUL, LSU
                                             v.sflts        ALU, r17
                                             v.cmov         WB, WB, r17
        add            WB, r7, MUL        || v.sfgts        ALU, 0
        add            --, r3, MUL        || v.cmov         --, WB, 0
        add            --, ALU, 0         || v.sw           CP, ALU, 0
        add            --, WB, 0          || v.lw           --, CP, 0
                                             v.add          r25, LSU, -128
                                             v.mul          --, ALU, r19
                                             v.sra          --, MUL, 7
                                             v.add          WB, MUL, r23
                                             v.sflts        ALU, r17
                                             v.cmov         WB, WB, r17
                                             v.sfgts        ALU, 0
        add            --, r5, MUL        || v.cmov         --, WB, 0
        add            --, ALU, 0         || v.sw           CP, ALU, 0
                                             v.mul          --, r25, 11
                                             v.sra          --, MUL, 5
                                             v.sub          --, r23, MUL
                                             v.mul          --, r24, r18
        add            r27, r27, 1        || v.sra          --, MUL, 8
        sub            r26, r26, r13      || v.sub          WB, ALU, MUL
                                             v.sflts        ALU, r17
        add            WB, r4, MUL        || v.cmov         WB, WB, r17
        sfgts          WB, r0             || v.sfgts        ALU, 0
        bf             $cl_yuv2rgb.kernel || v.cmov         --, WB, 0
        add            --, WB, 0          || v.sw           CP, ALU, 0
# BB_2:        .exit
        jr             r9
        nop
        .end           cl_yuv2rgb



        .data
        .type          $const_Int32_ff, @object
        .global        $const_Int32_ff
        .address       0
        .long          255
        .size          $const_Int32_ff, 4

        .type          __pe_array_size, @object
        .global        __pe_array_size
        .address       4
        .long          {{cfg.pe.size}}
        .size          __pe_array_size, 4


{{ randomDataSection(cfg.pe.size, cfg.pe.size) }}