	.file	"fpadd.c"
	.option nopic
	.attribute arch, "rv64i2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.globl	__adddf3
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-48
	sd	ra,40(sp)
	sd	s0,32(sp)
	addi	s0,sp,48
	lui	a5,%hi(.LC0)
	ld	a5,%lo(.LC0)(a5)
	sd	a5,-24(s0)
	lui	a5,%hi(.LC1)
	ld	a5,%lo(.LC1)(a5)
	sd	a5,-32(s0)
	ld	a1,-32(s0)
	ld	a0,-24(s0)
	call	__adddf3
	mv	a5,a0
	sd	a5,-40(s0)
	li	a5,0
	mv	a0,a5
	ld	ra,40(sp)
	ld	s0,32(sp)
	addi	sp,sp,48
	jr	ra
	.size	main, .-main
	.section	.rodata
	.align	3
.LC0:
	.word	858993459
	.word	1074475827
	.align	3
.LC1:
	.word	0
	.word	1072693248
	.ident	"GCC: (g5964b5cd727) 11.1.0"
