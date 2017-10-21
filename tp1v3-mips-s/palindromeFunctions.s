	.file	1 "palindromeFunctions.c"
	.section .mdebug.abi32
	.previous
	.abicalls
	.text
	.align	2
	.globl	toLowerCase
	.ent	toLowerCase
toLowerCase:
	.frame	$fp,24,$ra		# vars= 8, regs= 2/0, args= 0, extra= 8
	.mask	0x50000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$t9
	.set	reorder
	subu	$sp,$sp,24
	.cprestore 0
	sw	$fp,20($sp)
	sw	$gp,16($sp)
	move	$fp,$sp
	move	$v0,$a0
	sb	$v0,8($fp)
	lb	$v0,8($fp)
	slt	$v0,$v0,65
	bne	$v0,$zero,$L18
	lb	$v0,8($fp)
	slt	$v0,$v0,91
	beq	$v0,$zero,$L18
	lbu	$v0,8($fp)
	addu	$v0,$v0,32
	sb	$v0,8($fp)
$L18:
	lb	$v0,8($fp)
	move	$sp,$fp
	lw	$fp,20($sp)
	addu	$sp,$sp,24
	j	$ra
	.end	toLowerCase
	.size	toLowerCase, .-toLowerCase
	.rdata
	.align	3
$LC0:
	.word	0
	.word	1073741824
	.text
	.align	2
	.globl	verifyPalindromic
	.ent	verifyPalindromic
verifyPalindromic:
	.frame	$fp,72,$ra		# vars= 32, regs= 3/0, args= 16, extra= 8
	.mask	0xd0000000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$t9
	.set	reorder
	subu	$sp,$sp,72
	.cprestore 16
	sw	$ra,64($sp)
	sw	$fp,60($sp)
	sw	$gp,56($sp)
	move	$fp,$sp
	lw	$v0,lexico
	beq	$v0,$zero,$L21
	lw	$v0,lexico+4
	blez	$v0,$L21
	b	$L20
$L21:
	sw	$zero,48($fp)
	b	$L19
$L20:
	lw	$v1,lexico+4
	li	$v0,1			# 0x1
	bne	$v1,$v0,$L22
	li	$v0,1			# 0x1
	sw	$v0,48($fp)
	b	$L19
$L22:
	l.s	$f0,lexico+4
	cvt.d.w	$f2,$f0
	l.d	$f0,$LC0
	div.d	$f0,$f2,$f0
	s.d	$f0,24($fp)
	sw	$zero,32($fp)
	li	$v0,1			# 0x1
	sw	$v0,36($fp)
	lw	$v0,lexico+4
	addu	$v0,$v0,-1
	sw	$v0,40($fp)
$L23:
	l.s	$f0,32($fp)
	cvt.d.w	$f2,$f0
	l.d	$f0,24($fp)
	c.lt.d	$f2,$f0
	bc1t	$L27
	b	$L24
$L27:
	l.s	$f0,40($fp)
	cvt.d.w	$f2,$f0
	l.d	$f0,24($fp)
	c.le.d	$f0,$f2
	bc1t	$L28
	b	$L24
$L28:
	lw	$v1,36($fp)
	li	$v0,1			# 0x1
	beq	$v1,$v0,$L25
	b	$L24
$L25:
	lw	$v1,lexico
	lw	$v0,32($fp)
	addu	$v0,$v1,$v0
	lb	$v0,0($v0)
	move	$a0,$v0
	la	$t9,toLowerCase
	jal	$ra,$t9
	sb	$v0,44($fp)
	lw	$v1,lexico
	lw	$v0,40($fp)
	addu	$v0,$v1,$v0
	lb	$v0,0($v0)
	move	$a0,$v0
	la	$t9,toLowerCase
	jal	$ra,$t9
	sb	$v0,45($fp)
	lb	$v1,44($fp)
	lb	$v0,45($fp)
	beq	$v1,$v0,$L29
	sw	$zero,36($fp)
$L29:
	lw	$v0,32($fp)
	addu	$v0,$v0,1
	sw	$v0,32($fp)
	lw	$v0,40($fp)
	addu	$v0,$v0,-1
	sw	$v0,40($fp)
	b	$L23
$L24:
	lw	$v0,36($fp)
	sw	$v0,48($fp)
$L19:
	lw	$v0,48($fp)
	move	$sp,$fp
	lw	$ra,64($sp)
	lw	$fp,60($sp)
	addu	$sp,$sp,72
	j	$ra
	.end	verifyPalindromic
	.size	verifyPalindromic, .-verifyPalindromic
	.align	2
	.globl	isKeywords
	.ent	isKeywords
isKeywords:
	.frame	$fp,24,$ra		# vars= 8, regs= 2/0, args= 0, extra= 8
	.mask	0x50000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$t9
	.set	reorder
	subu	$sp,$sp,24
	.cprestore 0
	sw	$fp,20($sp)
	sw	$gp,16($sp)
	move	$fp,$sp
	move	$v0,$a0
	sb	$v0,8($fp)
	lb	$v0,8($fp)
	slt	$v0,$v0,65
	bne	$v0,$zero,$L33
	lb	$v0,8($fp)
	slt	$v0,$v0,91
	bne	$v0,$zero,$L32
$L33:
	lb	$v0,8($fp)
	slt	$v0,$v0,97
	bne	$v0,$zero,$L34
	lb	$v0,8($fp)
	slt	$v0,$v0,123
	bne	$v0,$zero,$L32
$L34:
	lb	$v0,8($fp)
	slt	$v0,$v0,48
	bne	$v0,$zero,$L35
	lb	$v0,8($fp)
	slt	$v0,$v0,58
	bne	$v0,$zero,$L32
$L35:
	lb	$v1,8($fp)
	li	$v0,45			# 0x2d
	beq	$v1,$v0,$L32
	lb	$v1,8($fp)
	li	$v0,95			# 0x5f
	beq	$v1,$v0,$L32
	b	$L31
$L32:
	li	$v0,1			# 0x1
	sw	$v0,12($fp)
	b	$L30
$L31:
	sw	$zero,12($fp)
$L30:
	lw	$v0,12($fp)
	move	$sp,$fp
	lw	$fp,20($sp)
	addu	$sp,$sp,24
	j	$ra
	.end	isKeywords
	.size	isKeywords, .-isKeywords
	.rdata
	.align	2
$LC1:
	.ascii	"[Error] Error al escribir en el archivo output la palabr"
	.ascii	"a %s\000"
	.text
	.align	2
	.globl	saveIfPalindrome
	.ent	saveIfPalindrome
saveIfPalindrome:
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
	la	$t9,verifyPalindromic
	jal	$ra,$t9
	sw	$v0,24($fp)
	lw	$v1,24($fp)
	li	$v0,1			# 0x1
	bne	$v1,$v0,$L37
	sw	$zero,28($fp)
	sw	$zero,32($fp)
$L38:
	lw	$v0,28($fp)
	lw	$v1,lexico+4
	slt	$v0,$v0,$v1
	beq	$v0,$zero,$L39
	lw	$v0,32($fp)
	bne	$v0,$zero,$L39
	lw	$v1,lexico
	lw	$v0,28($fp)
	addu	$v0,$v1,$v0
	lb	$v0,0($v0)
	move	$a0,$v0
	la	$t9,putch
	jal	$ra,$t9
	sw	$v0,36($fp)
	lw	$v1,36($fp)
	li	$v0,-1			# 0xffffffffffffffff
	bne	$v1,$v0,$L42
	li	$v0,1			# 0x1
	sw	$v0,32($fp)
$L42:
	lw	$v0,28($fp)
	addu	$v0,$v0,1
	sw	$v0,28($fp)
	b	$L38
$L39:
	lw	$v0,32($fp)
	bne	$v0,$zero,$L43
	li	$a0,10			# 0xa
	la	$t9,putch
	jal	$ra,$t9
	sw	$v0,36($fp)
	lw	$v1,36($fp)
	li	$v0,-1			# 0xffffffffffffffff
	bne	$v1,$v0,$L43
	li	$v0,1			# 0x1
	sw	$v0,32($fp)
$L43:
	lw	$v1,32($fp)
	li	$v0,1			# 0x1
	bne	$v1,$v0,$L37
	la	$a0,__sF+176
	la	$a1,$LC1
	lw	$a2,lexico
	la	$t9,fprintf
	jal	$ra,$t9
	li	$v0,-5			# 0xfffffffffffffffb
	sw	$v0,40($fp)
	b	$L36
$L37:
	sw	$zero,40($fp)
$L36:
	lw	$v0,40($fp)
	move	$sp,$fp
	lw	$ra,56($sp)
	lw	$fp,52($sp)
	addu	$sp,$sp,64
	j	$ra
	.end	saveIfPalindrome
	.size	saveIfPalindrome, .-saveIfPalindrome
	.align	2
	.globl	palindrome
	.ent	palindrome
palindrome:
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
	sw	$a2,64($fp)
	sw	$a3,68($fp)
	lw	$a0,56($fp)
	lw	$a1,60($fp)
	la	$t9,initializeInput
	jal	$ra,$t9
	lw	$a0,64($fp)
	lw	$a1,68($fp)
	la	$t9,initializeOutput
	jal	$ra,$t9
	sw	$zero,lexico+4
	la	$t9,getch
	jal	$ra,$t9
	sw	$v0,24($fp)
	sw	$zero,28($fp)
$L47:
	lw	$v1,24($fp)
	li	$v0,-1			# 0xffffffffffffffff
	beq	$v1,$v0,$L48
	lw	$v1,24($fp)
	li	$v0,-6			# 0xfffffffffffffffa
	beq	$v1,$v0,$L48
	lw	$v0,28($fp)
	bne	$v0,$zero,$L48
	lbu	$v0,24($fp)
	sb	$v0,32($fp)
	lb	$v0,32($fp)
	move	$a0,$v0
	la	$t9,isKeywords
	jal	$ra,$t9
	move	$v1,$v0
	li	$v0,1			# 0x1
	bne	$v1,$v0,$L51
	lb	$v0,32($fp)
	move	$a0,$v0
	la	$a1,lexico
	li	$a2,10			# 0xa
	la	$t9,loadInBuffer
	jal	$ra,$t9
	sw	$v0,28($fp)
	b	$L52
$L51:
	la	$t9,saveIfPalindrome
	jal	$ra,$t9
	sw	$v0,28($fp)
	la	$a0,lexico
	la	$t9,cleanContentBuffer
	jal	$ra,$t9
$L52:
	la	$t9,getch
	jal	$ra,$t9
	sw	$v0,24($fp)
	b	$L47
$L48:
	la	$t9,saveIfPalindrome
	jal	$ra,$t9
	sw	$v0,36($fp)
	lw	$v0,28($fp)
	bne	$v0,$zero,$L53
	lw	$v0,36($fp)
	sw	$v0,28($fp)
$L53:
	la	$a0,lexico
	la	$t9,cleanContentBuffer
	jal	$ra,$t9
	la	$t9,flush
	jal	$ra,$t9
	sw	$v0,36($fp)
	lw	$v0,28($fp)
	bne	$v0,$zero,$L54
	lw	$v0,36($fp)
	sw	$v0,28($fp)
$L54:
	la	$t9,freeResources
	jal	$ra,$t9
	lw	$v0,28($fp)
	move	$sp,$fp
	lw	$ra,48($sp)
	lw	$fp,44($sp)
	addu	$sp,$sp,56
	j	$ra
	.end	palindrome
	.size	palindrome, .-palindrome

	.comm	lexico,12
	.ident	"GCC: (GNU) 3.3.3 (NetBSD nb3 20040520)"
