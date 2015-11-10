###BEGIN: jump table parsing test
###TOOL:  ${S_AS}
###ARGS:  ${FILE} -o jumptable
###OFILE: jumptable.cp.dmem_init
###END:

func:
	nop
bb1:
	nop
	nop
bb2:
	nop
bb3:
	jr	RA

.jumptable
JTAB:
.long bb1
.long bb2
.long bb3
