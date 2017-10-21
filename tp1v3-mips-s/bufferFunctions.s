	.file	1 "bufferFunctions.c"
	.section .mdebug.abi32
	.previous
	.abicalls
	.globl	ifd
	.globl	ifd
	.section	.bss
	.align	2
	.type	ifd, @object
	.size	ifd, 4
ifd:
	.space	4
	.globl	lastPositionInIBufferRead
	.data
	.align	2
	.type	lastPositionInIBufferRead, @object
	.size	lastPositionInIBufferRead, 4
lastPositionInIBufferRead:
	.word	-1
	.globl	ibuffer
	.globl	ibuffer
	.section	.bss
	.align	2
	.type	ibuffer, @object
	.size	ibuffer, 12
ibuffer:
	.space	12
	.globl	endIFile
	.globl	endIFile
	.align	2
	.type	endIFile, @object
	.size	endIFile, 4
endIFile:
	.space	4
	.globl	ofd
	.globl	ofd
	.align	2
	.type	ofd, @object
	.size	ofd, 4
ofd:
	.space	4
	.globl	obuffer
	.globl	obuffer
	.align	2
	.type	obuffer, @object
	.size	obuffer, 12
obuffer:
	.space	12
	.text
	.align	2
	.globl	initializeInput
	.ent	initializeInput
initializeInput:
	.frame	$fp,16,$ra		# vars= 0, regs= 2/0, args= 0, extra= 8
	.mask	0x50000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$t9
	.set	reorder
	subu	$sp,$sp,16
	.cprestore 0
	sw	$fp,12($sp)
	sw	$gp,8($sp)
	move	$fp,$sp
	sw	$a0,16($fp)
	sw	$a1,20($fp)
	lw	$v0,16($fp)
	sw	$v0,ifd
	lw	$v0,20($fp)
	sw	$v0,ibuffer+8
	move	$sp,$fp
	lw	$fp,12($sp)
	addu	$sp,$sp,16
	j	$ra
	.end	initializeInput
	.size	initializeInput, .-initializeInput
	.align	2
	.globl	initializeOutput
	.ent	initializeOutput
initializeOutput:
	.frame	$fp,16,$ra		# vars= 0, regs= 2/0, args= 0, extra= 8
	.mask	0x50000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$t9
	.set	reorder
	subu	$sp,$sp,16
	.cprestore 0
	sw	$fp,12($sp)
	sw	$gp,8($sp)
	move	$fp,$sp
	sw	$a0,16($fp)
	sw	$a1,20($fp)
	lw	$v0,16($fp)
	sw	$v0,ofd
	lw	$v0,20($fp)
	sw	$v0,obuffer+8
	move	$sp,$fp
	lw	$fp,12($sp)
	addu	$sp,$sp,16
	j	$ra
	.end	initializeOutput
	.size	initializeOutput, .-initializeOutput
	.rdata
	.align	2
$LC0:
	.ascii	"[Error] Hubo un error de asignacion de memoria (ibuffer)"
	.ascii	". \n\000"
	.align	2
$LC1:
	.ascii	"[Error] Hubo un error en la lectura de datos del archivo"
	.ascii	". \n\000"
	.text
	.align	2
	.globl	loadIBufferWithIFile
	.ent	loadIBufferWithIFile
loadIBufferWithIFile:
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
	lw	$v0,ibuffer
	bne	$v0,$zero,$L20
	lw	$a0,ibuffer+8
	la	$t9,malloc
	jal	$ra,$t9
	sw	$v0,ibuffer
	lw	$v0,ibuffer
	bne	$v0,$zero,$L20
	la	$a0,__sF+176
	la	$a1,$LC0
	la	$t9,fprintf
	jal	$ra,$t9
	li	$v0,5			# 0x5
	sw	$v0,36($fp)
	b	$L19
$L20:
	sw	$zero,24($fp)
	sw	$zero,ibuffer+4
	lw	$v0,ibuffer+8
	sw	$v0,28($fp)
$L22:
	lw	$v0,24($fp)
	bne	$v0,$zero,$L23
	lw	$v0,endIFile
	bne	$v0,$zero,$L23
	lw	$v1,ibuffer
	lw	$v0,ibuffer+4
	addu	$v0,$v1,$v0
	lw	$a0,ifd
	move	$a1,$v0
	lw	$a2,28($fp)
	la	$t9,read
	jal	$ra,$t9
	sw	$v0,32($fp)
	lw	$v1,32($fp)
	li	$v0,-1			# 0xffffffffffffffff
	bne	$v1,$v0,$L26
	la	$a0,__sF+176
	la	$a1,$LC1
	la	$t9,fprintf
	jal	$ra,$t9
	li	$v0,-6			# 0xfffffffffffffffa
	sw	$v0,36($fp)
	b	$L19
$L26:
	lw	$v0,32($fp)
	bne	$v0,$zero,$L27
	li	$v0,1			# 0x1
	sw	$v0,endIFile
$L27:
	lw	$v1,ibuffer+4
	lw	$v0,32($fp)
	addu	$v0,$v1,$v0
	sw	$v0,ibuffer+4
	lw	$v1,ibuffer+8
	lw	$v0,ibuffer+4
	subu	$v0,$v1,$v0
	sw	$v0,28($fp)
	lw	$v0,28($fp)
	bgtz	$v0,$L22
	li	$v0,1			# 0x1
	sw	$v0,24($fp)
	b	$L22
$L23:
	li	$v0,-1			# 0xffffffffffffffff
	sw	$v0,lastPositionInIBufferRead
	li	$v0,1			# 0x1
	sw	$v0,36($fp)
$L19:
	lw	$v0,36($fp)
	move	$sp,$fp
	lw	$ra,48($sp)
	lw	$fp,44($sp)
	addu	$sp,$sp,56
	j	$ra
	.end	loadIBufferWithIFile
	.size	loadIBufferWithIFile, .-loadIBufferWithIFile
	.align	2
	.globl	getch
	.ent	getch
getch:
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
	lw	$v0,ibuffer
	beq	$v0,$zero,$L31
	lw	$v0,ibuffer+4
	addu	$v1,$v0,-1
	lw	$v0,lastPositionInIBufferRead
	beq	$v0,$v1,$L31
	b	$L30
$L31:
	lw	$v1,endIFile
	li	$v0,1			# 0x1
	bne	$v1,$v0,$L32
	li	$v0,-1			# 0xffffffffffffffff
	sw	$v0,28($fp)
	b	$L29
$L32:
	la	$t9,loadIBufferWithIFile
	jal	$ra,$t9
	sw	$v0,24($fp)
	lw	$v1,24($fp)
	li	$v0,-6			# 0xfffffffffffffffa
	bne	$v1,$v0,$L33
	li	$v0,-6			# 0xfffffffffffffffa
	sw	$v0,28($fp)
	b	$L29
$L33:
	lw	$v0,ibuffer+4
	bne	$v0,$zero,$L30
	li	$v0,-1			# 0xffffffffffffffff
	sw	$v0,28($fp)
	b	$L29
$L30:
	lw	$v0,lastPositionInIBufferRead
	addu	$v0,$v0,1
	sw	$v0,lastPositionInIBufferRead
	lw	$v1,ibuffer
	lw	$v0,lastPositionInIBufferRead
	addu	$v0,$v1,$v0
	lb	$v0,0($v0)
	sw	$v0,28($fp)
$L29:
	lw	$v0,28($fp)
	move	$sp,$fp
	lw	$ra,40($sp)
	lw	$fp,36($sp)
	addu	$sp,$sp,48
	j	$ra
	.end	getch
	.size	getch, .-getch
	.rdata
	.align	2
$LC2:
	.ascii	"[Error] Hubo un error al escribir en el archivo. \n\000"
	.text
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
	lw	$v0,obuffer
	beq	$v0,$zero,$L37
	lw	$v0,obuffer+4
	blez	$v0,$L37
	b	$L36
$L37:
	sw	$zero,40($fp)
	b	$L35
$L36:
	sw	$zero,24($fp)
	sw	$zero,28($fp)
	lw	$v0,obuffer+4
	sw	$v0,32($fp)
$L38:
	lw	$v0,24($fp)
	beq	$v0,$zero,$L40
	b	$L39
$L40:
	lw	$v1,obuffer
	lw	$v0,28($fp)
	addu	$v0,$v1,$v0
	lw	$a0,ofd
	move	$a1,$v0
	lw	$a2,32($fp)
	la	$t9,write
	jal	$ra,$t9
	sw	$v0,36($fp)
	lw	$v0,36($fp)
	bgez	$v0,$L41
	la	$a0,__sF+176
	la	$a1,$LC2
	la	$t9,fprintf
	jal	$ra,$t9
	li	$v0,-4			# 0xfffffffffffffffc
	sw	$v0,40($fp)
	b	$L35
$L41:
	lw	$v1,28($fp)
	lw	$v0,36($fp)
	addu	$v0,$v1,$v0
	sw	$v0,28($fp)
	lw	$v1,obuffer+4
	lw	$v0,28($fp)
	subu	$v0,$v1,$v0
	sw	$v0,32($fp)
	lw	$v0,32($fp)
	bgtz	$v0,$L38
	li	$v0,1			# 0x1
	sw	$v0,24($fp)
	b	$L38
$L39:
	sw	$zero,40($fp)
$L35:
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
$LC3:
	.ascii	"[Error] Hubo un error de asignacion de memoria (obuffer)"
	.ascii	". \n\000"
	.text
	.align	2
	.globl	putch
	.ent	putch
putch:
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
	lw	$v0,obuffer
	bne	$v0,$zero,$L44
	lw	$a0,obuffer+8
	la	$t9,malloc
	jal	$ra,$t9
	sw	$v0,obuffer
	lw	$v0,obuffer
	bne	$v0,$zero,$L45
	la	$a0,__sF+176
	la	$a1,$LC3
	la	$t9,fprintf
	jal	$ra,$t9
	li	$v0,5			# 0x5
	sw	$v0,24($fp)
	b	$L43
$L45:
	sw	$zero,obuffer+4
$L44:
	lw	$v1,obuffer
	lw	$v0,obuffer+4
	addu	$v1,$v1,$v0
	lbu	$v0,48($fp)
	sb	$v0,0($v1)
	lw	$v0,obuffer+4
	addu	$v0,$v0,1
	sw	$v0,obuffer+4
	lw	$v1,obuffer+4
	lw	$v0,obuffer+8
	bne	$v1,$v0,$L46
	la	$t9,writeBufferInOFile
	jal	$ra,$t9
	sw	$zero,obuffer+4
$L46:
	sw	$zero,24($fp)
$L43:
	lw	$v0,24($fp)
	move	$sp,$fp
	lw	$ra,40($sp)
	lw	$fp,36($sp)
	addu	$sp,$sp,48
	j	$ra
	.end	putch
	.size	putch, .-putch
	.align	2
	.globl	flush
	.ent	flush
flush:
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
	lw	$v0,obuffer
	beq	$v0,$zero,$L48
	lw	$v0,obuffer+4
	blez	$v0,$L48
	la	$t9,writeBufferInOFile
	jal	$ra,$t9
	sw	$v0,24($fp)
	b	$L47
$L48:
	sw	$zero,24($fp)
$L47:
	lw	$v0,24($fp)
	move	$sp,$fp
	lw	$ra,40($sp)
	lw	$fp,36($sp)
	addu	$sp,$sp,48
	j	$ra
	.end	flush
	.size	flush, .-flush
	.align	2
	.globl	freeResources
	.ent	freeResources
freeResources:
	.frame	$fp,40,$ra		# vars= 0, regs= 3/0, args= 16, extra= 8
	.mask	0xd0000000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$t9
	.set	reorder
	subu	$sp,$sp,40
	.cprestore 16
	sw	$ra,32($sp)
	sw	$fp,28($sp)
	sw	$gp,24($sp)
	move	$fp,$sp
	lw	$v0,ibuffer
	beq	$v0,$zero,$L50
	lw	$a0,ibuffer
	la	$t9,free
	jal	$ra,$t9
	sw	$zero,ibuffer
$L50:
	lw	$v0,obuffer
	beq	$v0,$zero,$L49
	lw	$a0,obuffer
	la	$t9,free
	jal	$ra,$t9
	sw	$zero,obuffer
$L49:
	move	$sp,$fp
	lw	$ra,32($sp)
	lw	$fp,28($sp)
	addu	$sp,$sp,40
	j	$ra
	.end	freeResources
	.size	freeResources, .-freeResources
	.rdata
	.align	2
$LC4:
	.ascii	"[Error] Hubo un error en memoria (lexico). \n\000"
	.text
	.align	2
	.globl	loadInBuffer
	.ent	loadInBuffer
loadInBuffer:
	.frame	$fp,56,$ra		# vars= 16, regs= 4/0, args= 16, extra= 8
	.mask	0xd0010000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$t9
	.set	reorder
	subu	$sp,$sp,56
	.cprestore 16
	sw	$ra,52($sp)
	sw	$fp,48($sp)
	sw	$gp,44($sp)
	sw	$s0,40($sp)
	move	$fp,$sp
	move	$v0,$a0
	sw	$a1,60($fp)
	sw	$a2,64($fp)
	sb	$v0,24($fp)
	lw	$v0,60($fp)
	lw	$v0,0($v0)
	bne	$v0,$zero,$L53
	lw	$s0,60($fp)
	lw	$a0,64($fp)
	la	$t9,malloc
	jal	$ra,$t9
	sw	$v0,0($s0)
	lw	$v1,60($fp)
	lw	$v0,64($fp)
	sw	$v0,8($v1)
	b	$L54
$L53:
	lw	$v0,60($fp)
	lw	$v1,60($fp)
	lw	$a0,4($v0)
	lw	$v0,8($v1)
	sltu	$v0,$a0,$v0
	bne	$v0,$zero,$L54
	lw	$v0,60($fp)
	lw	$v0,8($v0)
	sw	$v0,28($fp)
	lw	$v1,60($fp)
	lw	$v0,28($fp)
	sll	$v0,$v0,1
	sw	$v0,8($v1)
	lw	$v0,60($fp)
	lw	$v1,60($fp)
	lw	$a0,0($v0)
	lw	$a1,8($v1)
	lw	$a2,28($fp)
	la	$t9,myRealloc
	jal	$ra,$t9
	sw	$v0,32($fp)
	lw	$v0,32($fp)
	bne	$v0,$zero,$L56
	lw	$a0,60($fp)
	la	$t9,cleanContentBuffer
	jal	$ra,$t9
	b	$L54
$L56:
	lw	$v1,60($fp)
	lw	$v0,32($fp)
	sw	$v0,0($v1)
$L54:
	lw	$v0,60($fp)
	lw	$v0,0($v0)
	bne	$v0,$zero,$L58
	la	$a0,__sF+176
	la	$a1,$LC4
	la	$t9,fprintf
	jal	$ra,$t9
	li	$v0,5			# 0x5
	sw	$v0,36($fp)
	b	$L52
$L58:
	lw	$v0,60($fp)
	lw	$v1,60($fp)
	lw	$a0,0($v0)
	lw	$v0,4($v1)
	addu	$v1,$a0,$v0
	lbu	$v0,24($fp)
	sb	$v0,0($v1)
	lw	$v1,60($fp)
	lw	$v0,60($fp)
	lw	$v0,4($v0)
	addu	$v0,$v0,1
	sw	$v0,4($v1)
	sw	$zero,36($fp)
$L52:
	lw	$v0,36($fp)
	move	$sp,$fp
	lw	$ra,52($sp)
	lw	$fp,48($sp)
	lw	$s0,40($sp)
	addu	$sp,$sp,56
	j	$ra
	.end	loadInBuffer
	.size	loadInBuffer, .-loadInBuffer
	.align	2
	.globl	cleanContentBuffer
	.ent	cleanContentBuffer
cleanContentBuffer:
	.frame	$fp,40,$ra		# vars= 0, regs= 3/0, args= 16, extra= 8
	.mask	0xd0000000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$t9
	.set	reorder
	subu	$sp,$sp,40
	.cprestore 16
	sw	$ra,32($sp)
	sw	$fp,28($sp)
	sw	$gp,24($sp)
	move	$fp,$sp
	sw	$a0,40($fp)
	lw	$v0,40($fp)
	lw	$v0,0($v0)
	beq	$v0,$zero,$L60
	lw	$v0,40($fp)
	lw	$a0,0($v0)
	la	$t9,free
	jal	$ra,$t9
	lw	$v0,40($fp)
	sw	$zero,0($v0)
$L60:
	lw	$v0,40($fp)
	sw	$zero,4($v0)
	lw	$v0,40($fp)
	sw	$zero,8($v0)
	move	$sp,$fp
	lw	$ra,32($sp)
	lw	$fp,28($sp)
	addu	$sp,$sp,40
	j	$ra
	.end	cleanContentBuffer
	.size	cleanContentBuffer, .-cleanContentBuffer
	.ident	"GCC: (GNU) 3.3.3 (NetBSD nb3 20040520)"
