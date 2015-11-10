{% set pixels = cfg.pe.size*cfg.pe.size %}

        .text
        .global        __start
        .type          __start,@function
        .ent           __start
__start: # BB_0:
        simm           1                        # simm  128
        add            r1, r0, 0                  # V_0 = add  V_10000(ZERO), 0
        simm           32                         # simm  32
        add            r2, r0, 0                  # V_0 = add  V_10000(ZERO), 0
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
        sw             r1, r9, 0
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
        jr             r9
        add            r1, r1, 4
        .end           main

        .global        cl_yuv2rgb
        .type          cl_yuv2rgb,@function
        .ent           cl_yuv2rgb
cl_yuv2rgb: # BB_1:    .entry
        lw             r13, r0, 1         || v.simm         1
        simm           {{ imm1(pixels) }}                  || v.add          r23, r0, 103
        add            r29, r0, {{ imm2(pixels) }}         || v.simm         0
        add            r30, r0, 0         || v.add          r22, r0, 227
        lw             r24, r0, 0         || v.simm         0
                                             v.add          r21, r0, 183
        add            r0,  r24, 0        || v.add          r24, CP, 0
$cl_yuv2rgb.kernel: # BB_0:    l=1
        sll            r31, r30, 2
        add            r28, r8, r31
        add            r0, r28, 0         || v.lw           r28, CP, 0
                                             v.add          r26, r28, -128
                                             v.mul          r28, r26, r23
        add            r28, r6, r31       || v.sra          r28, r28, 8
        add            r0, r28, 0         || v.lw           r25, CP, 0
                                             v.add          r28, r28, r25
                                             v.sflts        r28, r24
                                             v.cmov         r28, r28, r24
        add            r28, r7, r31       || v.sfgts        r28, 0
        add            r27, r3, r31       || v.cmov         r28, r28, 0
        add            r0, r27, 0         || v.sw           CP, r28, 0
        add            r0, r28, 0         || v.lw           r28, CP, 0
                                             v.add          r27, r28, -128
                                             v.mul          r28, r27, r22
                                             v.sra          r28, r28, 7
                                             v.add          r28, r28, r25
                                             v.sflts        r28, r24
                                             v.cmov         r28, r28, r24
                                             v.sfgts        r28, 0
        add            r23, r5, r31       || v.cmov         r28, r28, 0
        add            r0, r23, 0         || v.sw           CP, r28, 0
                                             v.mul          r28, r27, 11
                                             v.sra          r28, r28, 5
                                             v.sub          r27, r25, r28
                                             v.mul          r28, r26, r21
        add            r30, r30, 1        || v.sra          r28, r28, 8
        sub            r29, r29, r13      || v.sub          r28, r27, r28
                                             v.sflts        r28, r24
        add            r27, r4, r31       || v.cmov         r28, r28, r24
        sfgts          r29, r0            || v.sfgts        r28, 0
        bf             $cl_yuv2rgb.kernel || v.cmov         r31, r28, 0
        add            r0, r27, 0         || v.sw           CP, r31, 0
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