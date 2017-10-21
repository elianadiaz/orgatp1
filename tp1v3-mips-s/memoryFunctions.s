	.file	1 "memoryFunctions.c"
	.section .mdebug.abi32
	.previous
	.abicalls
	.text
	.align	2
	.globl	myRealloc
	.ent	myRealloc
myRealloc:
	.frame	$fp,64,$ra		# vars= 24, regs= 3/0, args= 16, extra= 8
	.mask	0xd0000000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$t9
	.set	reorder
	subu	$sp,$sp,64
	.cprestore 16
	sw	$ra,56($sp)
	sw	$fp,52($sp)
	sw	$gp,48($sp)
	move	$fp,$sp
	sw	$a0,64($fp)
	sw	$a1,68($fp)
	sw	$a2,72($fp)
	lw	$v0,68($fp)
	bne	$v0,$zero,$L18
	lw	$a0,64($fp)
	la	$t9,free
	jal	$ra,$t9
	sw	$zero,64($fp)
	sw	$zero,40($fp)
	b	$L17
$L18:
	lw	$a0,68($fp)
	la	$t9,malloc
	jal	$ra,$t9
	sw	$v0,24($fp)
	lw	$v0,24($fp)
	bne	$v0,$zero,$L19
	sw	$zero,40($fp)
	b	$L17
$L19:
	lw	$v0,64($fp)
	bne	$v0,$zero,$L20
	lw	$v0,24($fp)
	sw	$v0,40($fp)
	b	$L17
$L20:
	lw	$v0,68($fp)
	sw	$v0,28($fp)
	lw	$v1,72($fp)
	lw	$v0,68($fp)
	sltu	$v0,$v1,$v0
	beq	$v0,$zero,$L21
	lw	$v0,72($fp)
	sw	$v0,28($fp)
$L21:
	lw	$v0,24($fp)
	sw	$v0,32($fp)
	lw	$v0,64($fp)
	sw	$v0,36($fp)
$L22:
	lw	$v0,28($fp)
	addu	$v0,$v0,-1
	move	$v1,$v0
	sw	$v1,28($fp)
	li	$v0,-1			# 0xffffffffffffffff
	bne	$v1,$v0,$L24
	b	$L23
$L24:
	lw	$v1,32($fp)
	lw	$v0,36($fp)
	lbu	$v0,0($v0)
	sb	$v0,0($v1)
	lw	$v0,32($fp)
	addu	$v0,$v0,1
	sw	$v0,32($fp)
	lw	$v0,36($fp)
	addu	$v0,$v0,1
	sw	$v0,36($fp)
	b	$L22
$L23:
	lw	$a0,64($fp)
	la	$t9,free
	jal	$ra,$t9
	sw	$zero,64($fp)
	lw	$v0,24($fp)
	sw	$v0,40($fp)
$L17:
	lw	$v0,40($fp)
	move	$sp,$fp
	lw	$ra,56($sp)
	lw	$fp,52($sp)
	addu	$sp,$sp,64
	j	$ra
	.end	myRealloc
	.size	myRealloc, .-myRealloc
	.ident	"GCC: (GNU) 3.3.3 (NetBSD nb3 20040520)"
