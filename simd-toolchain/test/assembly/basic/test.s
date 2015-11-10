###BEGIN: basic tests
###TOOL: ${S_AS}
###ARGS: ${FILE}
###END:
$BB0_1: # Basic block label
       addi     r11, r11, 1
    || v.add    r6,  r11, r3 # Vector instruction in a packet
       sfne     ALU, r7
    || v.lwi    r7,  ALU, 0
       v.addi   r11, r11, 4
       v.add    r8,  r.LSU, LSU
       v.addi   r7,  r.ALU, 0
       bf       $BB0_1
    || v.add    r8, r.ALU, r8
       nop
    || v.swi    r6,  ALU, 0
