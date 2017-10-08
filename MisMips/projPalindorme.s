	.file	1 "projPalindorme.c"
	.section .mdebug.abi32
	.previous
	.abicalls
	.globl	lexico
	.globl	lexico
	.section	.bss
	.align	2
	.type	lexico, @object
	.size	lexico, 4
lexico:
	.space	4
	.globl	quantityCharacterInLexico
	.globl	quantityCharacterInLexico
	.align	2
	.type	quantityCharacterInLexico, @object
	.size	quantityCharacterInLexico, 4
quantityCharacterInLexico:
	.space	4
	.globl	savedInOFile
	.globl	savedInOFile
	.align	2
	.type	savedInOFile, @object
	.size	savedInOFile, 4
savedInOFile:
	.space	4
	.globl	obuffer
	.globl	obuffer
	.align	2
	.type	obuffer, @object
	.size	obuffer, 4
obuffer:
	.space	4
	.globl	bytesLexico
	.globl	bytesLexico
	.align	2
	.type	bytesLexico, @object
	.size	bytesLexico, 4
bytesLexico:
	.space	4
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
	sw	$a0,72($fp)
	sw	$a1,76($fp)
	lw	$v0,72($fp)
	beq	$v0,$zero,$L21
	lw	$v0,76($fp)
	blez	$v0,$L21
	b	$L20
$L21:
	sw	$zero,52($fp)
	b	$L19
$L20:
	lw	$v1,76($fp)
	li	$v0,1			# 0x1
	bne	$v1,$v0,$L22
	li	$v0,1			# 0x1
	sw	$v0,52($fp)
	b	$L19
$L22:
	lw	$v1,76($fp)
	li	$v0,2			# 0x2
	bne	$v1,$v0,$L23
	lw	$v0,72($fp)
	lb	$v0,0($v0)
	move	$a0,$v0
	la	$t9,toLowerCase
	jal	$ra,$t9
	sb	$v0,24($fp)
	lw	$v0,72($fp)
	addu	$v0,$v0,1
	lb	$v0,0($v0)
	move	$a0,$v0
	la	$t9,toLowerCase
	jal	$ra,$t9
	sb	$v0,25($fp)
	lb	$v1,24($fp)
	lb	$v0,25($fp)
	beq	$v1,$v0,$L24
	sw	$zero,52($fp)
	b	$L19
$L24:
	li	$v0,1			# 0x1
	sw	$v0,52($fp)
	b	$L19
$L23:
	l.s	$f0,76($fp)
	cvt.d.w	$f2,$f0
	l.d	$f0,$LC0
	div.d	$f0,$f2,$f0
	s.d	$f0,32($fp)
	sw	$zero,40($fp)
	li	$v0,1			# 0x1
	sw	$v0,44($fp)
	lw	$v0,76($fp)
	addu	$v0,$v0,-1
	sw	$v0,48($fp)
$L25:
	l.s	$f0,40($fp)
	cvt.d.w	$f2,$f0
	l.d	$f0,32($fp)
	c.lt.d	$f2,$f0
	bc1t	$L29
	b	$L26
$L29:
	l.s	$f0,48($fp)
	cvt.d.w	$f2,$f0
	l.d	$f0,32($fp)
	c.lt.d	$f0,$f2
	bc1t	$L30
	b	$L26
$L30:
	lw	$v1,44($fp)
	li	$v0,1			# 0x1
	beq	$v1,$v0,$L27
	b	$L26
$L27:
	lw	$v1,72($fp)
	lw	$v0,40($fp)
	addu	$v0,$v1,$v0
	lb	$v0,0($v0)
	move	$a0,$v0
	la	$t9,toLowerCase
	jal	$ra,$t9
	sb	$v0,25($fp)
	lw	$v1,72($fp)
	lw	$v0,48($fp)
	addu	$v0,$v1,$v0
	lb	$v0,0($v0)
	move	$a0,$v0
	la	$t9,toLowerCase
	jal	$ra,$t9
	sb	$v0,24($fp)
	lb	$v1,25($fp)
	lb	$v0,24($fp)
	beq	$v1,$v0,$L31
	sw	$zero,44($fp)
$L31:
	lw	$v0,40($fp)
	addu	$v0,$v0,1
	sw	$v0,40($fp)
	lw	$v0,48($fp)
	addu	$v0,$v0,-1
	sw	$v0,48($fp)
	b	$L25
$L26:
	lw	$v0,44($fp)
	sw	$v0,52($fp)
$L19:
	lw	$v0,52($fp)
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
	bne	$v0,$zero,$L35
	lb	$v0,8($fp)
	slt	$v0,$v0,91
	bne	$v0,$zero,$L34
$L35:
	lb	$v0,8($fp)
	slt	$v0,$v0,97
	bne	$v0,$zero,$L36
	lb	$v0,8($fp)
	slt	$v0,$v0,123
	bne	$v0,$zero,$L34
$L36:
	lb	$v0,8($fp)
	slt	$v0,$v0,48
	bne	$v0,$zero,$L37
	lb	$v0,8($fp)
	slt	$v0,$v0,58
	bne	$v0,$zero,$L34
$L37:
	lb	$v1,8($fp)
	li	$v0,45			# 0x2d
	beq	$v1,$v0,$L34
	lb	$v1,8($fp)
	li	$v0,95			# 0x5f
	beq	$v1,$v0,$L34
	b	$L33
$L34:
	li	$v0,1			# 0x1
	sw	$v0,12($fp)
	b	$L32
$L33:
	sw	$zero,12($fp)
$L32:
	lw	$v0,12($fp)
	move	$sp,$fp
	lw	$fp,20($sp)
	addu	$sp,$sp,24
	j	$ra
	.end	isKeywords
	.size	isKeywords, .-isKeywords
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
	bne	$v0,$zero,$L39
	lw	$a0,64($fp)
	la	$t9,free
	jal	$ra,$t9
	sw	$zero,64($fp)
	sw	$zero,40($fp)
	b	$L38
$L39:
	lw	$a0,68($fp)
	la	$t9,malloc
	jal	$ra,$t9
	sw	$v0,24($fp)
	lw	$v0,24($fp)
	bne	$v0,$zero,$L40
	lw	$a0,64($fp)
	la	$t9,free
	jal	$ra,$t9
	sw	$zero,64($fp)
	sw	$zero,40($fp)
	b	$L38
$L40:
	lw	$v0,64($fp)
	bne	$v0,$zero,$L41
	lw	$v0,24($fp)
	sw	$v0,40($fp)
	b	$L38
$L41:
	lw	$v0,68($fp)
	sw	$v0,28($fp)
	lw	$v1,72($fp)
	lw	$v0,68($fp)
	sltu	$v0,$v1,$v0
	beq	$v0,$zero,$L42
	lw	$v0,72($fp)
	sw	$v0,28($fp)
$L42:
	lw	$v0,24($fp)
	sw	$v0,32($fp)
	lw	$v0,64($fp)
	sw	$v0,36($fp)
$L43:
	lw	$v0,28($fp)
	addu	$v0,$v0,-1
	move	$v1,$v0
	sw	$v1,28($fp)
	li	$v0,-1			# 0xffffffffffffffff
	bne	$v1,$v0,$L45
	b	$L44
$L45:
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
	b	$L43
$L44:
	lw	$a0,64($fp)
	la	$t9,free
	jal	$ra,$t9
	sw	$zero,64($fp)
	lw	$v0,24($fp)
	sw	$v0,40($fp)
$L38:
	lw	$v0,40($fp)
	move	$sp,$fp
	lw	$ra,56($sp)
	lw	$fp,52($sp)
	addu	$sp,$sp,64
	j	$ra
	.end	myRealloc
	.size	myRealloc, .-myRealloc
	.align	2
	.globl	initializeBuffer
	.ent	initializeBuffer
initializeBuffer:
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
	sw	$a0,24($fp)
	sw	$a1,28($fp)
	sw	$zero,8($fp)
$L47:
	lw	$v0,8($fp)
	lw	$v1,24($fp)
	sltu	$v0,$v0,$v1
	bne	$v0,$zero,$L50
	b	$L46
$L50:
	lw	$v1,28($fp)
	lw	$v0,8($fp)
	addu	$v0,$v1,$v0
	sb	$zero,0($v0)
	lw	$v0,8($fp)
	addu	$v0,$v0,1
	sw	$v0,8($fp)
	b	$L47
$L46:
	move	$sp,$fp
	lw	$fp,20($sp)
	addu	$sp,$sp,24
	j	$ra
	.end	initializeBuffer
	.size	initializeBuffer, .-initializeBuffer
	.align	2
	.globl	writeOBufferInOFile
	.ent	writeOBufferInOFile
writeOBufferInOFile:
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
	sw	$zero,24($fp)
	sw	$zero,28($fp)
	lw	$v0,64($fp)
	lw	$v0,0($v0)
	sw	$v0,32($fp)
$L52:
	lw	$v0,24($fp)
	beq	$v0,$zero,$L54
	b	$L53
$L54:
	lw	$v1,obuffer
	lw	$v0,28($fp)
	addu	$v0,$v1,$v0
	lw	$a0,oFileDescriptor
	move	$a1,$v0
	lw	$a2,32($fp)
	la	$t9,write
	jal	$ra,$t9
	sw	$v0,36($fp)
	lw	$v0,36($fp)
	bgez	$v0,$L55
	li	$v0,4			# 0x4
	sw	$v0,40($fp)
	b	$L51
$L55:
	lw	$v1,28($fp)
	lw	$v0,36($fp)
	addu	$v0,$v1,$v0
	sw	$v0,28($fp)
	lw	$v0,64($fp)
	lw	$v1,0($v0)
	lw	$v0,28($fp)
	subu	$v0,$v1,$v0
	sw	$v0,32($fp)
	lw	$v0,32($fp)
	bgtz	$v0,$L52
	li	$v0,1			# 0x1
	sw	$v0,24($fp)
	b	$L52
$L53:
	sw	$zero,40($fp)
$L51:
	lw	$v0,40($fp)
	move	$sp,$fp
	lw	$ra,56($sp)
	lw	$fp,52($sp)
	addu	$sp,$sp,64
	j	$ra
	.end	writeOBufferInOFile
	.size	writeOBufferInOFile, .-writeOBufferInOFile
	.rdata
	.align	2
$LC1:
	.ascii	"[Error] Hubo un error en memoria (lexico). \n\000"
	.align	2
$LC2:
	.ascii	"[Error] Hubo un error de asignacion de memoria (obuffer)"
	.ascii	". \n\000"
	.text
	.align	2
	.globl	executePalindromeWrite
	.ent	executePalindromeWrite
executePalindromeWrite:
	.frame	$fp,80,$ra		# vars= 40, regs= 3/0, args= 16, extra= 8
	.mask	0xd0000000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$t9
	.set	reorder
	subu	$sp,$sp,80
	.cprestore 16
	sw	$ra,72($sp)
	sw	$fp,68($sp)
	sw	$gp,64($sp)
	move	$fp,$sp
	sw	$a0,80($fp)
	sw	$a1,84($fp)
	sw	$zero,24($fp)
	sw	$zero,28($fp)
	sw	$zero,32($fp)
	sw	$zero,36($fp)
$L58:
	lw	$v0,24($fp)
	bne	$v0,$zero,$L59
	lw	$v0,28($fp)
	bne	$v0,$zero,$L59
	lw	$v1,80($fp)
	lw	$v0,32($fp)
	addu	$v0,$v1,$v0
	lbu	$v0,0($v0)
	sb	$v0,40($fp)
	lb	$v0,40($fp)
	bne	$v0,$zero,$L62
	li	$v0,1			# 0x1
	sw	$v0,24($fp)
$L62:
	lw	$v1,24($fp)
	li	$v0,1			# 0x1
	beq	$v1,$v0,$L63
	lb	$v0,40($fp)
	move	$a0,$v0
	la	$t9,isKeywords
	jal	$ra,$t9
	move	$v1,$v0
	li	$v0,1			# 0x1
	bne	$v1,$v0,$L63
	lw	$v0,lexico
	bne	$v0,$zero,$L64
	li	$a0,10			# 0xa
	la	$t9,malloc
	jal	$ra,$t9
	sw	$v0,lexico
	li	$v0,10			# 0xa
	sw	$v0,bytesLexico
	b	$L65
$L64:
	lw	$v0,quantityCharacterInLexico
	lw	$v1,bytesLexico
	slt	$v0,$v0,$v1
	bne	$v0,$zero,$L65
	lw	$v0,bytesLexico
	sw	$v0,44($fp)
	lw	$v0,bytesLexico
	addu	$v0,$v0,10
	sw	$v0,bytesLexico
	lw	$a0,lexico
	lw	$a1,bytesLexico
	lw	$a2,44($fp)
	la	$t9,myRealloc
	jal	$ra,$t9
	sw	$v0,lexico
$L65:
	lw	$v0,lexico
	bne	$v0,$zero,$L67
	la	$a0,__sF+176
	la	$a1,$LC1
	la	$t9,fprintf
	jal	$ra,$t9
	li	$v0,2			# 0x2
	sw	$v0,60($fp)
	b	$L57
$L67:
	lw	$v1,lexico
	lw	$v0,quantityCharacterInLexico
	addu	$v1,$v1,$v0
	lbu	$v0,40($fp)
	sb	$v0,0($v1)
	lw	$v0,quantityCharacterInLexico
	addu	$v0,$v0,1
	sw	$v0,quantityCharacterInLexico
	b	$L68
$L63:
	lw	$v0,quantityCharacterInLexico
	blez	$v0,$L68
	lw	$a0,lexico
	lw	$a1,quantityCharacterInLexico
	la	$t9,verifyPalindromic
	jal	$ra,$t9
	sw	$v0,44($fp)
	lw	$v1,44($fp)
	li	$v0,1			# 0x1
	bne	$v1,$v0,$L70
	lw	$v0,84($fp)
	lw	$v1,0($v0)
	lw	$v0,quantityCharacterInLexico
	addu	$v0,$v1,$v0
	sw	$v0,48($fp)
	lw	$v0,84($fp)
	lw	$v0,0($v0)
	bgtz	$v0,$L72
	lw	$v1,savedInOFile
	li	$v0,1			# 0x1
	beq	$v1,$v0,$L72
	b	$L71
$L72:
	lw	$v0,48($fp)
	addu	$v0,$v0,1
	sw	$v0,48($fp)
$L71:
	lw	$v0,48($fp)
	lw	$v1,osize
	sltu	$v0,$v1,$v0
	beq	$v0,$zero,$L73
	lw	$v0,84($fp)
	lw	$a0,obuffer
	lw	$a1,48($fp)
	lw	$a2,0($v0)
	la	$t9,myRealloc
	jal	$ra,$t9
	sw	$v0,obuffer
	lw	$v0,84($fp)
	lw	$v0,0($v0)
	bgtz	$v0,$L75
	lw	$v1,savedInOFile
	li	$v0,1			# 0x1
	beq	$v1,$v0,$L75
	b	$L74
$L75:
	lw	$v0,84($fp)
	lw	$v1,obuffer
	lw	$v0,0($v0)
	addu	$v1,$v1,$v0
	li	$v0,10			# 0xa
	sb	$v0,0($v1)
	lw	$v1,84($fp)
	lw	$v0,84($fp)
	lw	$v0,0($v0)
	addu	$v0,$v0,1
	sw	$v0,0($v1)
$L74:
	sw	$zero,52($fp)
$L76:
	lw	$v0,52($fp)
	lw	$v1,quantityCharacterInLexico
	slt	$v0,$v0,$v1
	bne	$v0,$zero,$L79
	b	$L77
$L79:
	lw	$v0,84($fp)
	lw	$v1,obuffer
	lw	$v0,0($v0)
	addu	$a0,$v1,$v0
	lw	$v1,lexico
	lw	$v0,52($fp)
	addu	$v0,$v1,$v0
	lbu	$v0,0($v0)
	sb	$v0,0($a0)
	lw	$v1,84($fp)
	lw	$v0,84($fp)
	lw	$v0,0($v0)
	addu	$v0,$v0,1
	sw	$v0,0($v1)
	lw	$v0,52($fp)
	addu	$v0,$v0,1
	sw	$v0,52($fp)
	b	$L76
$L77:
	lw	$a0,84($fp)
	la	$t9,writeOBufferInOFile
	jal	$ra,$t9
	sw	$v0,56($fp)
	lw	$v0,56($fp)
	beq	$v0,$zero,$L80
	lw	$v0,56($fp)
	sw	$v0,60($fp)
	b	$L57
$L80:
	lw	$v0,84($fp)
	sw	$zero,0($v0)
	li	$v0,1			# 0x1
	sw	$v0,savedInOFile
	lw	$v0,obuffer
	beq	$v0,$zero,$L81
	lw	$a0,obuffer
	la	$t9,free
	jal	$ra,$t9
	sw	$zero,obuffer
$L81:
	lw	$a0,osize
	la	$t9,malloc
	jal	$ra,$t9
	sw	$v0,obuffer
	lw	$v0,obuffer
	bne	$v0,$zero,$L82
	la	$a0,__sF+176
	la	$a1,$LC2
	la	$t9,fprintf
	jal	$ra,$t9
	li	$v0,2			# 0x2
	sw	$v0,60($fp)
	b	$L57
$L82:
	lw	$a0,osize
	lw	$a1,obuffer
	la	$t9,initializeBuffer
	jal	$ra,$t9
	b	$L70
$L73:
	lw	$v0,84($fp)
	lw	$v0,0($v0)
	bgtz	$v0,$L85
	lw	$v1,savedInOFile
	li	$v0,1			# 0x1
	beq	$v1,$v0,$L85
	b	$L84
$L85:
	lw	$v0,84($fp)
	lw	$v1,obuffer
	lw	$v0,0($v0)
	addu	$v1,$v1,$v0
	li	$v0,10			# 0xa
	sb	$v0,0($v1)
	lw	$v1,84($fp)
	lw	$v0,84($fp)
	lw	$v0,0($v0)
	addu	$v0,$v0,1
	sw	$v0,0($v1)
$L84:
	sw	$zero,56($fp)
$L86:
	lw	$v0,56($fp)
	lw	$v1,quantityCharacterInLexico
	slt	$v0,$v0,$v1
	bne	$v0,$zero,$L89
	b	$L70
$L89:
	lw	$v0,84($fp)
	lw	$v1,obuffer
	lw	$v0,0($v0)
	addu	$a0,$v1,$v0
	lw	$v1,lexico
	lw	$v0,56($fp)
	addu	$v0,$v1,$v0
	lbu	$v0,0($v0)
	sb	$v0,0($a0)
	lw	$v1,84($fp)
	lw	$v0,84($fp)
	lw	$v0,0($v0)
	addu	$v0,$v0,1
	sw	$v0,0($v1)
	lw	$v0,56($fp)
	addu	$v0,$v0,1
	sw	$v0,56($fp)
	b	$L86
$L70:
	lw	$a0,lexico
	la	$t9,free
	jal	$ra,$t9
	sw	$zero,lexico
	sw	$zero,quantityCharacterInLexico
$L68:
	lw	$v0,32($fp)
	addu	$v1,$v0,1
	lw	$v0,isize
	bne	$v1,$v0,$L90
	li	$v0,1			# 0x1
	sw	$v0,28($fp)
	li	$v0,5			# 0x5
	sw	$v0,36($fp)
	b	$L58
$L90:
	lw	$v0,32($fp)
	addu	$v0,$v0,1
	sw	$v0,32($fp)
	b	$L58
$L59:
	lw	$v0,36($fp)
	sw	$v0,60($fp)
$L57:
	lw	$v0,60($fp)
	move	$sp,$fp
	lw	$ra,72($sp)
	lw	$fp,68($sp)
	addu	$sp,$sp,80
	j	$ra
	.end	executePalindromeWrite
	.size	executePalindromeWrite, .-executePalindromeWrite
	.rdata
	.align	2
$LC3:
	.ascii	"[Error] Hubo un error de asignacion de memoria (ibuffer)"
	.ascii	". \n\000"
	.align	2
$LC4:
	.ascii	"[Error] Hubo un error de asignacion de memoria (amountSa"
	.ascii	"ved). \n\000"
	.align	2
$LC5:
	.ascii	"[Error] Hubo un error en la lectura de datos del archivo"
	.ascii	". \n\000"
	.text
	.align	2
	.globl	palindrome
	.ent	palindrome
palindrome:
	.frame	$fp,80,$ra		# vars= 40, regs= 3/0, args= 16, extra= 8
	.mask	0xd0000000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$t9
	.set	reorder
	subu	$sp,$sp,80
	.cprestore 16
	sw	$ra,72($sp)
	sw	$fp,68($sp)
	sw	$gp,64($sp)
	move	$fp,$sp
	sw	$a0,80($fp)
	sw	$a1,84($fp)
	sw	$a2,88($fp)
	sw	$a3,92($fp)
	lw	$v0,84($fp)
	sw	$v0,isize
	lw	$v0,92($fp)
	sw	$v0,osize
	lw	$v0,88($fp)
	sw	$v0,oFileDescriptor
	lw	$a0,84($fp)
	la	$t9,malloc
	jal	$ra,$t9
	sw	$v0,24($fp)
	lw	$v0,24($fp)
	bne	$v0,$zero,$L93
	la	$a0,__sF+176
	la	$a1,$LC3
	la	$t9,fprintf
	jal	$ra,$t9
	li	$v0,2			# 0x2
	sw	$v0,60($fp)
	b	$L92
$L93:
	lw	$a0,92($fp)
	la	$t9,malloc
	jal	$ra,$t9
	sw	$v0,obuffer
	lw	$v0,obuffer
	bne	$v0,$zero,$L94
	la	$a0,__sF+176
	la	$a1,$LC2
	la	$t9,fprintf
	jal	$ra,$t9
	lw	$a0,24($fp)
	la	$t9,free
	jal	$ra,$t9
	sw	$zero,24($fp)
	li	$v0,2			# 0x2
	sw	$v0,60($fp)
	b	$L92
$L94:
	lw	$a0,84($fp)
	lw	$a1,24($fp)
	la	$t9,initializeBuffer
	jal	$ra,$t9
	lw	$a0,92($fp)
	lw	$a1,obuffer
	la	$t9,initializeBuffer
	jal	$ra,$t9
	li	$a0,4			# 0x4
	la	$t9,malloc
	jal	$ra,$t9
	sw	$v0,28($fp)
	lw	$v0,28($fp)
	bne	$v0,$zero,$L95
	la	$a0,__sF+176
	la	$a1,$LC4
	la	$t9,fprintf
	jal	$ra,$t9
	lw	$a0,24($fp)
	la	$t9,free
	jal	$ra,$t9
	sw	$zero,24($fp)
	lw	$a0,obuffer
	la	$t9,free
	jal	$ra,$t9
	sw	$zero,obuffer
	li	$v0,2			# 0x2
	sw	$v0,60($fp)
	b	$L92
$L95:
	lw	$v0,28($fp)
	sw	$zero,0($v0)
	sw	$zero,32($fp)
	sw	$zero,36($fp)
	sw	$zero,40($fp)
$L96:
	lw	$v0,36($fp)
	bne	$v0,$zero,$L97
	lw	$v0,40($fp)
	bne	$v0,$zero,$L97
	sw	$zero,44($fp)
	sw	$zero,48($fp)
	lw	$v0,84($fp)
	sw	$v0,52($fp)
$L100:
	lw	$v0,44($fp)
	bne	$v0,$zero,$L101
	lw	$v0,36($fp)
	bne	$v0,$zero,$L101
	lw	$v1,24($fp)
	lw	$v0,48($fp)
	addu	$v0,$v1,$v0
	lw	$a0,80($fp)
	move	$a1,$v0
	lw	$a2,52($fp)
	la	$t9,read
	jal	$ra,$t9
	sw	$v0,56($fp)
	lw	$v1,56($fp)
	li	$v0,-1			# 0xffffffffffffffff
	bne	$v1,$v0,$L104
	la	$a0,__sF+176
	la	$a1,$LC5
	la	$t9,fprintf
	jal	$ra,$t9
	lw	$a0,24($fp)
	la	$t9,free
	jal	$ra,$t9
	sw	$zero,24($fp)
	lw	$a0,obuffer
	la	$t9,free
	jal	$ra,$t9
	sw	$zero,obuffer
	lw	$a0,28($fp)
	la	$t9,free
	jal	$ra,$t9
	sw	$zero,28($fp)
	lw	$v0,lexico
	beq	$v0,$zero,$L105
	lw	$a0,lexico
	la	$t9,free
	jal	$ra,$t9
	sw	$zero,lexico
$L105:
	li	$v0,3			# 0x3
	sw	$v0,60($fp)
	b	$L92
$L104:
	lw	$v0,56($fp)
	bne	$v0,$zero,$L106
	li	$v0,1			# 0x1
	sw	$v0,36($fp)
$L106:
	lw	$v1,48($fp)
	lw	$v0,56($fp)
	addu	$v0,$v1,$v0
	sw	$v0,48($fp)
	lw	$v1,84($fp)
	lw	$v0,48($fp)
	subu	$v0,$v1,$v0
	sw	$v0,52($fp)
	lw	$v0,52($fp)
	bne	$v0,$zero,$L100
	li	$v0,1			# 0x1
	sw	$v0,44($fp)
	b	$L100
$L101:
	lw	$v0,24($fp)
	beq	$v0,$zero,$L96
	lw	$v0,24($fp)
	lb	$v0,0($v0)
	beq	$v0,$zero,$L96
	lw	$a0,24($fp)
	lw	$a1,28($fp)
	la	$t9,executePalindromeWrite
	jal	$ra,$t9
	sw	$v0,56($fp)
	lw	$v1,56($fp)
	li	$v0,5			# 0x5
	bne	$v1,$v0,$L109
	lw	$a0,84($fp)
	lw	$a1,24($fp)
	la	$t9,initializeBuffer
	jal	$ra,$t9
$L109:
	lw	$v1,56($fp)
	li	$v0,2			# 0x2
	beq	$v1,$v0,$L111
	lw	$v1,56($fp)
	li	$v0,4			# 0x4
	beq	$v1,$v0,$L111
	b	$L96
$L111:
	li	$v0,1			# 0x1
	sw	$v0,40($fp)
	lw	$v0,56($fp)
	sw	$v0,32($fp)
	b	$L96
$L97:
	lw	$v0,24($fp)
	beq	$v0,$zero,$L112
	lw	$a0,24($fp)
	la	$t9,free
	jal	$ra,$t9
	sw	$zero,24($fp)
$L112:
	lw	$v0,obuffer
	beq	$v0,$zero,$L113
	lw	$v0,28($fp)
	beq	$v0,$zero,$L114
	lw	$v0,28($fp)
	lw	$v0,0($v0)
	blez	$v0,$L114
	lw	$a0,28($fp)
	la	$t9,writeOBufferInOFile
	jal	$ra,$t9
	sw	$v0,56($fp)
	lw	$v0,56($fp)
	beq	$v0,$zero,$L114
	lw	$v0,56($fp)
	sw	$v0,32($fp)
$L114:
	lw	$a0,obuffer
	la	$t9,free
	jal	$ra,$t9
	sw	$zero,obuffer
$L113:
	lw	$v0,lexico
	beq	$v0,$zero,$L116
	lw	$a0,lexico
	la	$t9,free
	jal	$ra,$t9
	sw	$zero,lexico
$L116:
	lw	$v0,28($fp)
	beq	$v0,$zero,$L117
	lw	$a0,28($fp)
	la	$t9,free
	jal	$ra,$t9
	sw	$zero,28($fp)
$L117:
	lw	$v0,32($fp)
	sw	$v0,60($fp)
$L92:
	lw	$v0,60($fp)
	move	$sp,$fp
	lw	$ra,72($sp)
	lw	$fp,68($sp)
	addu	$sp,$sp,80
	j	$ra
	.end	palindrome
	.size	palindrome, .-palindrome
	.rdata
	.align	2
$LC6:
	.ascii	"[Error] Cantidad de par\303\241metros incorrecta: %d \n\000"
	.text
	.align	2
	.globl	main
	.ent	main
main:
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
	lw	$v1,64($fp)
	li	$v0,5			# 0x5
	beq	$v1,$v0,$L119
	lw	$v1,64($fp)
	li	$v0,3			# 0x3
	beq	$v1,$v0,$L119
	la	$a0,__sF+176
	la	$a1,$LC6
	lw	$a2,64($fp)
	la	$t9,fprintf
	jal	$ra,$t9
	li	$v0,1			# 0x1
	sw	$v0,40($fp)
	b	$L118
$L119:
	lw	$v0,68($fp)
	addu	$v0,$v0,4
	lw	$a0,0($v0)
	la	$t9,atoi
	jal	$ra,$t9
	sw	$v0,24($fp)
	lw	$v0,68($fp)
	addu	$v0,$v0,8
	lw	$a0,0($v0)
	la	$t9,atoi
	jal	$ra,$t9
	sw	$v0,28($fp)
	li	$v0,1			# 0x1
	sw	$v0,32($fp)
	li	$v0,1			# 0x1
	sw	$v0,36($fp)
	lw	$v1,64($fp)
	li	$v0,5			# 0x5
	bne	$v1,$v0,$L120
	lw	$v0,68($fp)
	addu	$v0,$v0,8
	lw	$a0,0($v0)
	la	$t9,atoi
	jal	$ra,$t9
	sw	$v0,32($fp)
	lw	$v0,68($fp)
	addu	$v0,$v0,16
	lw	$a0,0($v0)
	la	$t9,atoi
	jal	$ra,$t9
	sw	$v0,36($fp)
	lw	$v0,68($fp)
	addu	$v0,$v0,12
	lw	$a0,0($v0)
	la	$t9,atoi
	jal	$ra,$t9
	sw	$v0,28($fp)
$L120:
	lw	$a0,24($fp)
	lw	$a1,32($fp)
	lw	$a2,28($fp)
	lw	$a3,36($fp)
	la	$t9,palindrome
	jal	$ra,$t9
	sw	$v0,40($fp)
$L118:
	lw	$v0,40($fp)
	move	$sp,$fp
	lw	$ra,56($sp)
	lw	$fp,52($sp)
	addu	$sp,$sp,64
	j	$ra
	.end	main
	.size	main, .-main

	.comm	isize,4

	.comm	osize,4

	.comm	oFileDescriptor,4
	.ident	"GCC: (GNU) 3.3.3 (NetBSD nb3 20040520)"
