	.file	1 "main.c"
	.section .mdebug.abi32
	.previous
	.abicalls
	.rdata
	.align	2
$LC0:
	.ascii	"malloc(%ld) ...\000"
	.align	2
$LC1:
	.ascii	" %p.\000"
	.align	2
$LC2:
	.ascii	" Writing ...\000"
	.align	2
$LC3:
	.ascii	" Ok.\000"
	.align	2
$LC4:
	.ascii	"Writing myRealloc...\000"
	.align	2
$LC5:
	.ascii	"end writing myRealloc...\000"
	.align	2
$LC6:
	.ascii	" Freeing memory ...\000"
	.align	2
$LC7:
	.ascii	" Ok.\n\000"
	.text
	.align	2
	.globl	main
	.ent	main
main:
	.frame	$fp,56,$ra		# vars= 16, regs= 3/0, args= 16, extra= 8
	.mask	0xd0000000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$t9
	.set	reorder
	subu	$sp,$sp,56
	.cprestore 16
	sw	$ra,48($sp)
	sw	$fp,44($sp)
	sw	$gp,40($sp)
	move	$fp,$sp
	sw	$a0,56($fp)
	sw	$a1,60($fp)
	li	$v0,1			# 0x1
	sw	$v0,24($fp)
$L18:
	lw	$v0,24($fp)
	bne	$v0,$zero,$L21
	b	$L19
$L21:
	la	$a0,__sF+88
	la	$a1,$LC0
	lw	$a2,24($fp)
	la	$t9,fprintf
	jal	$ra,$t9
	la	$a0,__sF+88
	la	$t9,fflush
	jal	$ra,$t9
	lw	$a0,24($fp)
	la	$t9,mymalloc
	jal	$ra,$t9
	sw	$v0,32($fp)
	la	$a0,__sF+88
	la	$a1,$LC1
	lw	$a2,32($fp)
	la	$t9,fprintf
	jal	$ra,$t9
	la	$a0,$LC2
	la	$t9,printf
	jal	$ra,$t9
	la	$a0,__sF+88
	la	$t9,fflush
	jal	$ra,$t9
	sw	$zero,28($fp)
$L22:
	lw	$v0,28($fp)
	lw	$v1,24($fp)
	sltu	$v0,$v0,$v1
	bne	$v0,$zero,$L25
	b	$L23
$L25:
	lw	$v1,32($fp)
	lw	$v0,28($fp)
	addu	$v1,$v1,$v0
	li	$v0,-1			# 0xffffffffffffffff
	sb	$v0,0($v1)
	lw	$v0,28($fp)
	addu	$v0,$v0,1
	sw	$v0,28($fp)
	b	$L22
$L23:
	la	$a0,$LC3
	la	$t9,printf
	jal	$ra,$t9
	la	$a0,$LC4
	la	$t9,printf
	jal	$ra,$t9
	lw	$a0,32($fp)
	li	$a1,16			# 0x10
	li	$a2,4			# 0x4
	la	$t9,myRealloc
	jal	$ra,$t9
	sw	$v0,36($fp)
	la	$a0,__sF+88
	la	$a1,$LC1
	lw	$a2,36($fp)
	la	$t9,fprintf
	jal	$ra,$t9
	la	$a0,$LC5
	la	$t9,printf
	jal	$ra,$t9
	la	$a0,$LC6
	la	$t9,printf
	jal	$ra,$t9
	la	$a0,__sF+88
	la	$t9,fflush
	jal	$ra,$t9
	lw	$a0,36($fp)
	la	$t9,myfree
	jal	$ra,$t9
	la	$a0,$LC7
	la	$t9,printf
	jal	$ra,$t9
	la	$a0,__sF+88
	la	$t9,fflush
	jal	$ra,$t9
	lw	$v0,24($fp)
	addu	$v0,$v0,1
	sw	$v0,24($fp)
	b	$L18
$L19:
	move	$v0,$zero
	move	$sp,$fp
	lw	$ra,48($sp)
	lw	$fp,44($sp)
	addu	$sp,$sp,56
	j	$ra
	.end	main
	.size	main, .-main
	.ident	"GCC: (GNU) 3.3.3 (NetBSD nb3 20040520)"
