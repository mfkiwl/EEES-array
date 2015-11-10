###BEGIN: incorrect bypass src
###TOOL: ${S_AS}
###ARGS: ${FILE} -arch-param stage:5
###ERR: [Syntax ERROR]: ln23: invalid operand symbol "ALU"
###END:
###BEGIN: fir5 4-stage baseline
###TOOL: ${S_AS}
###ARGS: ${FILE} -o fir5-s4.s
###OFILE: fir5-s4.s.cp.imem_init
###OFILE: fir5-s4.s.pe.imem_init
###END:
    sfltsi   r6, 1
    bf       $BB0_3
    nop
    v.lwi    r8,  r5, 1
    v.lwi    r7,  r5, 2
    v.lwi    r12, r5, 3
    v.lwi    r11, r5, 4
    v.lwi    r5,  r5, 0
$BB0_2:
    addi     r6,  r6, -1
 || v.lwi    --, r4, 1
    sfne     ALU, ZERO
 || v.mul    WB, LSU, r8
    v.lwi    --, r4, 0
    v.mul    --, LSU, r5
    v.add    --, WB, MUL
    v.lwi    --, r4, 2
    v.mul    --, LSU, r7
    v.add    --, MUL, ALU
    v.lwi    --, r4, 3
    v.mul    --, LSU, r12
    v.add    --, MUL, ALU
    v.lwi    --, r4, 4
    v.mul    --, LSU, r11
    v.add    --, MUL, ALU
    v.swi    r3, ALU, 0
    bf   $BB0_2
 || v.addi   r4, r4, 4
    v.addi   r3, r3, 4
$BB0_3:
    jr       RA
    nop
