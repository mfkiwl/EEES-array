###BEGIN: Data initialization 32b
###TOOL: ${S_AS}
###ARGS: ${FILE} -o data.32 -arch-param dwidth:32,stage:4
###MDUMP: data.32.pe.dmem_init
###MDUMP: data.32.cp.dmem_init
###END:
###BEGIN: Data initialization 16b
###TOOL: ${S_AS}
###ARGS: ${FILE} -o data.16 -arch-param dwidth:16,stage:4
###MDUMP: data.16.pe.dmem_init
###MDUMP: data.16.cp.dmem_init
###END:
        .vdata
        .type          A, @object
        .address       0
        .short         1
        .short         2
        .short         3
        .short         4
        .size          A, 16

        .data
        .type          B, @object
        .address       0
        .byte          1
        .byte          2
        .byte          3
        .byte          4
        .size          B, 4
