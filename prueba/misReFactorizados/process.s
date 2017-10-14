	.file	1 "process.c"
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
	.globl	ibuffer
	.globl	ibuffer
	.align	2
	.type	ibuffer, @object
	.size	ibuffer, 4
ibuffer:
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
	.globl	writeBufferInOFile
	.ent	writeBufferInOFile
writeBufferInOFile:
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
	lw	$v1,68($fp)
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
	.end	writeBufferInOFile
	.size	writeBufferInOFile, .-writeBufferInOFile
	.rdata
	.align	2
$LC1:
	.ascii	"[Error] Hubo un error en memoria (lexico). \n\000"
	.text
	.align	2
	.globl	loadInLexico
	.ent	loadInLexico
loadInLexico:
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
	move	$v0,$a0
	sb	$v0,24($fp)
	lw	$v0,lexico
	bne	$v0,$zero,$L58
	li	$a0,10			# 0xa
	la	$t9,malloc
	jal	$ra,$t9
	sw	$v0,lexico
	li	$v0,10			# 0xa
	sw	$v0,bytesLexico
	b	$L59
$L58:
	lw	$v0,quantityCharacterInLexico
	lw	$v1,bytesLexico
	slt	$v0,$v0,$v1
	bne	$v0,$zero,$L59
	lw	$v0,bytesLexico
	sw	$v0,28($fp)
	lw	$v0,bytesLexico
	addu	$v0,$v0,10
	sw	$v0,bytesLexico
	lw	$a0,lexico
	lw	$a1,bytesLexico
	lw	$a2,28($fp)
	la	$t9,myRealloc
	jal	$ra,$t9
	sw	$v0,lexico
	lw	$v0,lexico
	bne	$v0,$zero,$L59
	la	$a0,__sF+176
	la	$a1,$LC1
	la	$t9,fprintf
	jal	$ra,$t9
	li	$v0,2			# 0x2
	sw	$v0,32($fp)
	b	$L57
$L59:
	lw	$v0,lexico
	bne	$v0,$zero,$L62
	la	$a0,__sF+176
	la	$a1,$LC1
	la	$t9,fprintf
	jal	$ra,$t9
	li	$v0,2			# 0x2
	sw	$v0,32($fp)
	b	$L57
$L62:
	lw	$v1,lexico
	lw	$v0,quantityCharacterInLexico
	addu	$v1,$v1,$v0
	lbu	$v0,24($fp)
	sb	$v0,0($v1)
	lw	$v0,quantityCharacterInLexico
	addu	$v0,$v0,1
	sw	$v0,quantityCharacterInLexico
	sw	$zero,32($fp)
$L57:
	lw	$v0,32($fp)
	move	$sp,$fp
	lw	$ra,48($sp)
	lw	$fp,44($sp)
	addu	$sp,$sp,56
	j	$ra
	.end	loadInLexico
	.size	loadInLexico, .-loadInLexico
	.align	2
	.globl	copyFromLexicoToOBuffer
	.ent	copyFromLexicoToOBuffer
copyFromLexicoToOBuffer:
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
	lw	$v0,24($fp)
	lw	$v0,0($v0)
	bgtz	$v0,$L65
	lw	$v1,savedInOFile
	li	$v0,1			# 0x1
	beq	$v1,$v0,$L65
	b	$L64
$L65:
	lw	$v0,24($fp)
	lw	$v1,obuffer
	lw	$v0,0($v0)
	addu	$v1,$v1,$v0
	li	$v0,10			# 0xa
	sb	$v0,0($v1)
	lw	$v1,24($fp)
	lw	$v0,24($fp)
	lw	$v0,0($v0)
	addu	$v0,$v0,1
	sw	$v0,0($v1)
$L64:
	sw	$zero,8($fp)
$L66:
	lw	$v0,8($fp)
	lw	$v1,quantityCharacterInLexico
	slt	$v0,$v0,$v1
	bne	$v0,$zero,$L69
	b	$L63
$L69:
	lw	$v0,24($fp)
	lw	$v1,obuffer
	lw	$v0,0($v0)
	addu	$a0,$v1,$v0
	lw	$v1,lexico
	lw	$v0,8($fp)
	addu	$v0,$v1,$v0
	lbu	$v0,0($v0)
	sb	$v0,0($a0)
	lw	$v1,24($fp)
	lw	$v0,24($fp)
	lw	$v0,0($v0)
	addu	$v0,$v0,1
	sw	$v0,0($v1)
	lw	$v0,8($fp)
	addu	$v0,$v0,1
	sw	$v0,8($fp)
	b	$L66
$L63:
	move	$sp,$fp
	lw	$fp,20($sp)
	addu	$sp,$sp,24
	j	$ra
	.end	copyFromLexicoToOBuffer
	.size	copyFromLexicoToOBuffer, .-copyFromLexicoToOBuffer
	.rdata
	.align	2
$LC2:
	.ascii	"[Error] Hubo un error de asignacion de memoria (buffer)."
	.ascii	" \n\000"
	.text
	.align	2
	.globl	loadBufferInitial
	.ent	loadBufferInitial
loadBufferInitial:
	.frame	$fp,48,$ra		# vars= 8, regs= 3/0, args= 16, extra= 8
	.mask	0xd0000000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$t9
	.set	reorder
	subu	$sp,$sp,48
	.cprestore 16
	sw	$ra,40($sp)
	sw	$fp,36($sp)
	sw	$gp,32($sp)
	move	$fp,$sp
	sw	$a0,48($fp)
	sw	$a1,52($fp)
	lw	$a0,48($fp)
	la	$t9,malloc
	jal	$ra,$t9
	sw	$v0,52($fp)
	lw	$v0,52($fp)
	bne	$v0,$zero,$L71
	la	$a0,__sF+176
	la	$a1,$LC2
	la	$t9,fprintf
	jal	$ra,$t9
	sw	$zero,24($fp)
	b	$L70
$L71:
	lw	$a0,48($fp)
	lw	$a1,52($fp)
	la	$t9,initializeBuffer
	jal	$ra,$t9
	lw	$v0,52($fp)
	sw	$v0,24($fp)
$L70:
	lw	$v0,24($fp)
	move	$sp,$fp
	lw	$ra,40($sp)
	lw	$fp,36($sp)
	addu	$sp,$sp,48
	j	$ra
	.end	loadBufferInitial
	.size	loadBufferInitial, .-loadBufferInitial
	.align	2
	.globl	processDataInIBuffer
	.ent	processDataInIBuffer
processDataInIBuffer:
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
$L73:
	lw	$v0,24($fp)
	bne	$v0,$zero,$L74
	lw	$v0,28($fp)
	bne	$v0,$zero,$L74
	lw	$v1,80($fp)
	lw	$v0,32($fp)
	addu	$v0,$v1,$v0
	lbu	$v0,0($v0)
	sb	$v0,40($fp)
	lb	$v0,40($fp)
	bne	$v0,$zero,$L77
	li	$v0,1			# 0x1
	sw	$v0,24($fp)
$L77:
	lw	$v1,24($fp)
	li	$v0,1			# 0x1
	beq	$v1,$v0,$L78
	lb	$v0,40($fp)
	move	$a0,$v0
	la	$t9,isKeywords
	jal	$ra,$t9
	move	$v1,$v0
	li	$v0,1			# 0x1
	bne	$v1,$v0,$L78
	lb	$v0,40($fp)
	move	$a0,$v0
	la	$t9,loadInLexico
	jal	$ra,$t9
	sw	$v0,44($fp)
	lw	$v0,44($fp)
	beq	$v0,$zero,$L80
	lw	$v0,44($fp)
	sw	$v0,56($fp)
	b	$L72
$L78:
	lw	$v0,quantityCharacterInLexico
	blez	$v0,$L80
	lw	$a0,lexico
	lw	$a1,quantityCharacterInLexico
	la	$t9,verifyPalindromic
	jal	$ra,$t9
	sw	$v0,44($fp)
	lw	$v1,44($fp)
	li	$v0,1			# 0x1
	bne	$v1,$v0,$L82
	lw	$v0,84($fp)
	lw	$v1,0($v0)
	lw	$v0,quantityCharacterInLexico
	addu	$v0,$v1,$v0
	sw	$v0,48($fp)
	lw	$v0,84($fp)
	lw	$v0,0($v0)
	bgtz	$v0,$L84
	lw	$v1,savedInOFile
	li	$v0,1			# 0x1
	beq	$v1,$v0,$L84
	b	$L83
$L84:
	lw	$v0,48($fp)
	addu	$v0,$v0,1
	sw	$v0,48($fp)
$L83:
	lw	$v0,48($fp)
	lw	$v1,osize
	sltu	$v0,$v1,$v0
	beq	$v0,$zero,$L85
	lw	$v0,84($fp)
	lw	$a0,obuffer
	lw	$a1,48($fp)
	lw	$a2,0($v0)
	la	$t9,myRealloc
	jal	$ra,$t9
	sw	$v0,obuffer
	lw	$v0,obuffer
	bne	$v0,$zero,$L86
	la	$a0,__sF+176
	la	$a1,$LC1
	la	$t9,fprintf
	jal	$ra,$t9
	li	$v0,2			# 0x2
	sw	$v0,56($fp)
	b	$L72
$L86:
	lw	$a0,84($fp)
	la	$t9,copyFromLexicoToOBuffer
	jal	$ra,$t9
	lw	$a0,84($fp)
	lw	$a1,obuffer
	la	$t9,writeBufferInOFile
	jal	$ra,$t9
	sw	$v0,52($fp)
	lw	$v0,52($fp)
	beq	$v0,$zero,$L87
	lw	$v0,52($fp)
	sw	$v0,56($fp)
	b	$L72
$L87:
	lw	$v0,84($fp)
	sw	$zero,0($v0)
	li	$v0,1			# 0x1
	sw	$v0,savedInOFile
	lw	$v0,obuffer
	beq	$v0,$zero,$L88
	lw	$a0,obuffer
	la	$t9,free
	jal	$ra,$t9
	sw	$zero,obuffer
$L88:
	lw	$a0,osize
	lw	$a1,obuffer
	la	$t9,loadBufferInitial
	jal	$ra,$t9
	sw	$v0,obuffer
	lw	$v0,obuffer
	bne	$v0,$zero,$L82
	li	$v0,2			# 0x2
	sw	$v0,56($fp)
	b	$L72
$L85:
	lw	$a0,84($fp)
	la	$t9,copyFromLexicoToOBuffer
	jal	$ra,$t9
$L82:
	lw	$a0,lexico
	la	$t9,free
	jal	$ra,$t9
	sw	$zero,lexico
	sw	$zero,quantityCharacterInLexico
$L80:
	lw	$v0,32($fp)
	addu	$v1,$v0,1
	lw	$v0,isize
	bne	$v1,$v0,$L91
	li	$v0,1			# 0x1
	sw	$v0,28($fp)
	li	$v0,5			# 0x5
	sw	$v0,36($fp)
	b	$L73
$L91:
	lw	$v0,32($fp)
	addu	$v0,$v0,1
	sw	$v0,32($fp)
	b	$L73
$L74:
	lw	$v0,36($fp)
	sw	$v0,56($fp)
$L72:
	lw	$v0,56($fp)
	move	$sp,$fp
	lw	$ra,72($sp)
	lw	$fp,68($sp)
	addu	$sp,$sp,80
	j	$ra
	.end	processDataInIBuffer
	.size	processDataInIBuffer, .-processDataInIBuffer
	.rdata
	.align	2
$LC3:
	.ascii	"[Error] Hubo un error en la lectura de datos del archivo"
	.ascii	". \n\000"
	.text
	.align	2
	.globl	loadIBufferWithIFile
	.ent	loadIBufferWithIFile
loadIBufferWithIFile:
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
	sw	$zero,24($fp)
	sw	$zero,28($fp)
	lw	$v0,64($fp)
	sw	$v0,32($fp)
	sw	$zero,36($fp)
$L94:
	lw	$v0,24($fp)
	bne	$v0,$zero,$L95
	lw	$v0,36($fp)
	bne	$v0,$zero,$L95
	lw	$v1,ibuffer
	lw	$v0,28($fp)
	addu	$v0,$v1,$v0
	lw	$a0,68($fp)
	move	$a1,$v0
	lw	$a2,32($fp)
	la	$t9,read
	jal	$ra,$t9
	sw	$v0,40($fp)
	lw	$v1,40($fp)
	li	$v0,-1			# 0xffffffffffffffff
	bne	$v1,$v0,$L98
	la	$a0,__sF+176
	la	$a1,$LC3
	la	$t9,fprintf
	jal	$ra,$t9
	li	$v0,-3			# 0xfffffffffffffffd
	sw	$v0,44($fp)
	b	$L93
$L98:
	lw	$v0,40($fp)
	bne	$v0,$zero,$L99
	li	$v0,1			# 0x1
	sw	$v0,36($fp)
$L99:
	lw	$v1,28($fp)
	lw	$v0,40($fp)
	addu	$v0,$v1,$v0
	sw	$v0,28($fp)
	lw	$v1,64($fp)
	lw	$v0,28($fp)
	subu	$v0,$v1,$v0
	sw	$v0,32($fp)
	lw	$v0,32($fp)
	bgtz	$v0,$L94
	li	$v0,1			# 0x1
	sw	$v0,24($fp)
	b	$L94
$L95:
	lw	$v1,36($fp)
	li	$v0,1			# 0x1
	bne	$v1,$v0,$L101
	li	$v0,-2			# 0xfffffffffffffffe
	sw	$v0,44($fp)
	b	$L93
$L101:
	li	$v0,-4			# 0xfffffffffffffffc
	sw	$v0,44($fp)
$L93:
	lw	$v0,44($fp)
	move	$sp,$fp
	lw	$ra,56($sp)
	lw	$fp,52($sp)
	addu	$sp,$sp,64
	j	$ra
	.end	loadIBufferWithIFile
	.size	loadIBufferWithIFile, .-loadIBufferWithIFile
	.align	2
	.globl	cleanBuffers
	.ent	cleanBuffers
cleanBuffers:
	.frame	$fp,48,$ra		# vars= 8, regs= 3/0, args= 16, extra= 8
	.mask	0xd0000000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$t9
	.set	reorder
	subu	$sp,$sp,48
	.cprestore 16
	sw	$ra,40($sp)
	sw	$fp,36($sp)
	sw	$gp,32($sp)
	move	$fp,$sp
	sw	$a0,48($fp)
	sw	$zero,24($fp)
	lw	$v0,ibuffer
	beq	$v0,$zero,$L103
	lw	$a0,ibuffer
	la	$t9,free
	jal	$ra,$t9
	sw	$zero,ibuffer
$L103:
	lw	$v0,obuffer
	beq	$v0,$zero,$L104
	lw	$v0,48($fp)
	beq	$v0,$zero,$L105
	lw	$v0,48($fp)
	lw	$v0,0($v0)
	blez	$v0,$L105
	lw	$a0,48($fp)
	lw	$a1,obuffer
	la	$t9,writeBufferInOFile
	jal	$ra,$t9
	sw	$v0,28($fp)
	lw	$v0,28($fp)
	beq	$v0,$zero,$L105
	lw	$v0,28($fp)
	sw	$v0,24($fp)
$L105:
	lw	$a0,obuffer
	la	$t9,free
	jal	$ra,$t9
	sw	$zero,obuffer
$L104:
	lw	$v0,lexico
	beq	$v0,$zero,$L107
	lw	$v0,quantityCharacterInLexico
	blez	$v0,$L108
	lw	$a0,lexico
	lw	$a1,quantityCharacterInLexico
	la	$t9,verifyPalindromic
	jal	$ra,$t9
	move	$v1,$v0
	li	$v0,1			# 0x1
	bne	$v1,$v0,$L108
	li	$a0,10			# 0xa
	la	$t9,loadInLexico
	jal	$ra,$t9
	la	$a0,quantityCharacterInLexico
	lw	$a1,lexico
	la	$t9,writeBufferInOFile
	jal	$ra,$t9
	sw	$v0,28($fp)
	lw	$v0,28($fp)
	beq	$v0,$zero,$L108
	lw	$v0,28($fp)
	sw	$v0,24($fp)
$L108:
	lw	$a0,lexico
	la	$t9,free
	jal	$ra,$t9
	sw	$zero,lexico
$L107:
	lw	$v0,24($fp)
	move	$sp,$fp
	lw	$ra,40($sp)
	lw	$fp,36($sp)
	addu	$sp,$sp,48
	j	$ra
	.end	cleanBuffers
	.size	cleanBuffers, .-cleanBuffers
	.rdata
	.align	2
$LC4:
	.ascii	"[Error] Hubo un error de asignacion de memoria (amountSa"
	.ascii	"vedInOBuffer). \n\000"
	.text
	.align	2
	.globl	palindrome
	.ent	palindrome
palindrome:
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
	sw	$a3,76($fp)
	lw	$v0,68($fp)
	sw	$v0,isize
	lw	$v0,76($fp)
	sw	$v0,osize
	lw	$v0,72($fp)
	sw	$v0,oFileDescriptor
	lw	$a0,isize
	lw	$a1,ibuffer
	la	$t9,loadBufferInitial
	jal	$ra,$t9
	sw	$v0,ibuffer
	lw	$v0,ibuffer
	bne	$v0,$zero,$L111
	li	$v0,2			# 0x2
	sw	$v0,44($fp)
	b	$L110
$L111:
	lw	$a0,osize
	lw	$a1,obuffer
	la	$t9,loadBufferInitial
	jal	$ra,$t9
	sw	$v0,obuffer
	lw	$v0,obuffer
	bne	$v0,$zero,$L112
	lw	$a0,ibuffer
	la	$t9,free
	jal	$ra,$t9
	sw	$zero,ibuffer
	li	$v0,2			# 0x2
	sw	$v0,44($fp)
	b	$L110
$L112:
	li	$a0,4			# 0x4
	la	$t9,malloc
	jal	$ra,$t9
	sw	$v0,24($fp)
	lw	$v0,24($fp)
	bne	$v0,$zero,$L113
	la	$a0,__sF+176
	la	$a1,$LC4
	la	$t9,fprintf
	jal	$ra,$t9
	lw	$a0,ibuffer
	la	$t9,free
	jal	$ra,$t9
	sw	$zero,ibuffer
	lw	$a0,obuffer
	la	$t9,free
	jal	$ra,$t9
	sw	$zero,obuffer
	li	$v0,2			# 0x2
	sw	$v0,44($fp)
	b	$L110
$L113:
	lw	$v0,24($fp)
	sw	$zero,0($v0)
	sw	$zero,28($fp)
	sw	$zero,32($fp)
	li	$v0,-4			# 0xfffffffffffffffc
	sw	$v0,36($fp)
$L114:
	lw	$v1,36($fp)
	li	$v0,-4			# 0xfffffffffffffffc
	bne	$v1,$v0,$L115
	lw	$v0,32($fp)
	bne	$v0,$zero,$L115
	lw	$a0,68($fp)
	lw	$a1,64($fp)
	la	$t9,loadIBufferWithIFile
	jal	$ra,$t9
	sw	$v0,36($fp)
	lw	$v0,ibuffer
	beq	$v0,$zero,$L114
	lw	$v0,ibuffer
	lb	$v0,0($v0)
	beq	$v0,$zero,$L114
	lw	$a0,ibuffer
	lw	$a1,24($fp)
	la	$t9,processDataInIBuffer
	jal	$ra,$t9
	sw	$v0,40($fp)
	lw	$v1,40($fp)
	li	$v0,5			# 0x5
	bne	$v1,$v0,$L119
	lw	$a0,68($fp)
	lw	$a1,ibuffer
	la	$t9,initializeBuffer
	jal	$ra,$t9
$L119:
	lw	$v1,40($fp)
	li	$v0,2			# 0x2
	beq	$v1,$v0,$L121
	lw	$v1,40($fp)
	li	$v0,4			# 0x4
	beq	$v1,$v0,$L121
	b	$L114
$L121:
	li	$v0,1			# 0x1
	sw	$v0,32($fp)
	lw	$v0,40($fp)
	sw	$v0,28($fp)
	b	$L114
$L115:
	lw	$a0,24($fp)
	la	$t9,cleanBuffers
	jal	$ra,$t9
	sw	$v0,40($fp)
	lw	$v0,24($fp)
	beq	$v0,$zero,$L122
	lw	$a0,24($fp)
	la	$t9,free
	jal	$ra,$t9
	sw	$zero,24($fp)
$L122:
	lw	$v0,40($fp)
	beq	$v0,$zero,$L123
	lw	$v0,40($fp)
	sw	$v0,44($fp)
	b	$L110
$L123:
	lw	$v0,28($fp)
	sw	$v0,44($fp)
$L110:
	lw	$v0,44($fp)
	move	$sp,$fp
	lw	$ra,56($sp)
	lw	$fp,52($sp)
	addu	$sp,$sp,64
	j	$ra
	.end	palindrome
	.size	palindrome, .-palindrome

	.comm	isize,4

	.comm	osize,4

	.comm	oFileDescriptor,4
	.ident	"GCC: (GNU) 3.3.3 (NetBSD nb3 20040520)"
