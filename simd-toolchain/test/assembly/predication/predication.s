###BEGIN: assembly with predication
###TOOL: ${S_AS}
###ARGS: ${FILE} -arch-param predicate:2 -o predication
###OFILE: predication.cp.imem_init
###OFILE: predication.pe.imem_init
###END:
sfne    P1, r3, r7 || v.sfltsi    P2,  r2,  0
add.P1  r2, r4, r7 || v.addi.P2  r11, r11, 4
sfne    r3, r7     || v.sfltsi   r2, 0       # Check if old cmp syntax still OK
