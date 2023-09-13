# risc-V_5-stage_int_pipeline
Project done for didactic purpose. There is an explicative pdf in the related folder.
In this project for didactic purposes a 5-stage pipeline of Risc-V has been implemented, described
entirely in vhdl. The implemented instruction set architecture (ISA) is that of RV64IM, therefore multiply-divide-remainder instructions have been implemented alongside all basic 64-bit integer
instructions, with the exception of CSR instructions and FENCE, FENCE.I instructions. Unimplemented instructions are executed as NOP. The pipeline was tested with instructions extracted from a
simple bubble sort program and and an arithmetic operations program.
