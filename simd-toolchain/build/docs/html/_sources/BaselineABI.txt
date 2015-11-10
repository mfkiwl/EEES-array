=====================================
Baseline Application Binary Interface
=====================================

Abstract
========


Register Usage
==============

CP Registers
~~~~~~~~~~~~

CP assumed to have at least 16 registers in the register file.

===========  ====================  ============= 
 Register       Usage              Enforced By
===========  ====================  ============= 
 R0 (ZERO)    Always zero               HW
 R1 (SP)      CP stack pointer          SW 
 R2 (VSP)     PE stack pointer          SW 
 R3-R8        Function arguments        SW
 R9 (RA)      Link register             HW
 R11-R12      Return value              SW
 R13          Number of PEs             SW
===========  ====================  =============

PE Registers
~~~~~~~~~~~~

===========  ====================  ============= 
 Register       Usage              Enforced By
===========  ====================  ============= 
 R0 (ZERO)    Always zero               HW
 R1 (PEID)    PE ID                     HW
===========  ====================  =============

Calling Convention
==================

At the moment baseline can only handle function with no more than six arguments.

