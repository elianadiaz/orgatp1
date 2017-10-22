	.file	1 "myRealloc.c"
	.section .mdebug.abi32
	.previous
	.abicalls
	.text
	.align	2
	.globl	myRealloc
	.ent	myRealloc
myRealloc:
	.frame	$fp,64,ra		# vars= 24, regs= 3/0, args= 16, extra= 8
	.mask	0xd0000000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	t9
	.set	reorder
	subu	sp,sp,64
	.cprestore 16
	sw	ra,56(sp)
	sw	$fp,52(sp)
	sw	$gp,48(sp)
	move	$fp,sp
	sw	a0,64($fp)
	sw	a1,68($fp)
	sw	a2,72($fp)
	lw	v0,68($fp)
	bne	v0,zero,six
	lw	a0,64($fp)
	la	t9,myfree
	jal	ra,t9
	sw	zero,64($fp)
	sw	zero,40($fp)
	b	$L5
six:
	lw	a0,68($fp)
	la	t9,mymalloc
	jal	ra,t9
	sw	v0,24($fp)
	lw	v0,24($fp)
	bne	v0,zero,seven
	lw	a0,64($fp)
	la	t9,myfree
	jal	ra,t9
	sw	zero,64($fp)
	sw	zero,40($fp)
	b	$L5
seven:
	lw	v0,64($fp)
	bne	v0,zero,$L8
	lw	v0,24($fp)
	sw	v0,40($fp)
	b	$L5
$L8:
	lw	v0,68($fp)
	sw	v0,28($fp)
	lw	$v1,72($fp)
	lw	v0,68($fp)
	sltu	v0,$v1,v0
	beq	v0,zero,$L9
	lw	v0,72($fp)
	sw	v0,28($fp)
$L9:
	lw	v0,24($fp)
	sw	v0,32($fp)
	lw	v0,64($fp)
	sw	v0,36($fp)
$L10:
	lw	v0,28($fp)
	addu	v0,v0,-1
	move	$v1,v0
	sw	$v1,28($fp)
	li	v0,-1			# 0xffffffffffffffff
	bne	$v1,v0,$L12
	b	$L11
$L12:
	lw	$v1,32($fp)
	lw	v0,36($fp)
	lbu	v0,0(v0)
	sb	v0,0($v1)
	lw	v0,32($fp)
	addu	v0,v0,1
	sw	v0,32($fp)
	lw	v0,36($fp)
	addu	v0,v0,1
	sw	v0,36($fp)
	b	$L10
$L11:
	lw	a0,64($fp)
	la	t9,myfree
	jal	ra,t9
	sw	zero,64($fp)
	lw	v0,24($fp)
	sw	v0,40($fp)
$L5:
	lw	v0,40($fp)
	move	sp,$fp
	lw	ra,56(sp)
	lw	$fp,52(sp)
	addu	sp,sp,64
	j	ra
	.end	myRealloc
	.size	myRealloc, .-myRealloc
	.ident	"GCC: (GNU) 3.3.3 (NetBSD nb3 20040520)"
