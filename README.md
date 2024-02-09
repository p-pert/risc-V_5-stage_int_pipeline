# risc-V_5-stage_int_pipeline
This project was created for didactic purpose to learn VHDL and how computer architectures work, through a RISC-V-ISA based pipeline. There is an explicative pdf in the related folder and a schematic of what's implemented.

Abstract

In this project for didactic purposes a 5-stage pipeline of Risc-V has been implemented, described entirely in vhdl. The implemented instruction set architecture (ISA) is that of RV64IM, therefore multiply-divide-remainder instructions have been implemented alongside all basic 64-bit integer instructions, with the exception of CSR instructions and FENCE, FENCE.I instructions. Unimplemented instructions are executed as NOP. The pipeline was tested with instructions extracted from a simple bubble sort program and an arithmetic operations program.
