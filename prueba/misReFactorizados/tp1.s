	.file	1 "tp1.c"
	.section .mdebug.abi32
	.previous
	.abicalls
	.globl	ibytes
	.data
	.align	2
	.type	ibytes, @object
	.size	ibytes, 4
ibytes:
	.word	1
	.globl	obytes
	.align	2
	.type	obytes, @object
	.size	obytes, 4
obytes:
	.word	1
	.rdata
	.align	2
$LC0:
	.ascii	"Usage: \n\000"
	.align	2
$LC1:
	.ascii	"\ttp1 -h \n\000"
	.align	2
$LC2:
	.ascii	"\ttp1 -V \n\000"
	.align	2
$LC3:
	.ascii	"\ttp1 [options] \n\000"
	.align	2
$LC4:
	.ascii	"Options: \n\000"
	.align	2
$LC5:
	.ascii	"\t-V, --version\t\tPrint version and quit. \n\000"
	.align	2
$LC6:
	.ascii	"\t-h, --help\t    \tPrint this information. \n\000"
	.align	2
$LC7:
	.ascii	"\t-i, --input\t    \tLocation of the input file. \n\000"
	.align	2
$LC8:
	.ascii	"\t-o, --output\t\tLocation of the output file. \n\000"
	.align	2
$LC9:
	.ascii	"\t-I, --ibuf-bytes\tByte-count of the input buffer. \n\000"
	.align	2
$LC10:
	.ascii	"\t-O, --obuf-bytes\tByte-count of the output buffer. \n\000"
	.align	2
$LC11:
	.ascii	"Examples: \n\000"
	.align	2
$LC12:
	.ascii	"\ttp1 -i ~/input -o ~/output \n\000"
	.text
	.align	2
	.globl	executeHelp
	.ent	executeHelp
executeHelp:
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
	la	$a0,__sF+88
	la	$a1,$LC0
	la	$t9,fprintf
	jal	$ra,$t9
	la	$a0,__sF+88
	la	$a1,$LC1
	la	$t9,fprintf
	jal	$ra,$t9
	la	$a0,__sF+88
	la	$a1,$LC2
	la	$t9,fprintf
	jal	$ra,$t9
	la	$a0,__sF+88
	la	$a1,$LC3
	la	$t9,fprintf
	jal	$ra,$t9
	la	$a0,__sF+88
	la	$a1,$LC4
	la	$t9,fprintf
	jal	$ra,$t9
	la	$a0,__sF+88
	la	$a1,$LC5
	la	$t9,fprintf
	jal	$ra,$t9
	la	$a0,__sF+88
	la	$a1,$LC6
	la	$t9,fprintf
	jal	$ra,$t9
	la	$a0,__sF+88
	la	$a1,$LC7
	la	$t9,fprintf
	jal	$ra,$t9
	la	$a0,__sF+88
	la	$a1,$LC8
	la	$t9,fprintf
	jal	$ra,$t9
	la	$a0,__sF+88
	la	$a1,$LC9
	la	$t9,fprintf
	jal	$ra,$t9
	la	$a0,__sF+88
	la	$a1,$LC10
	la	$t9,fprintf
	jal	$ra,$t9
	la	$a0,__sF+88
	la	$a1,$LC11
	la	$t9,fprintf
	jal	$ra,$t9
	la	$a0,__sF+88
	la	$a1,$LC12
	la	$t9,fprintf
	jal	$ra,$t9
	move	$v0,$zero
	move	$sp,$fp
	lw	$ra,32($sp)
	lw	$fp,28($sp)
	addu	$sp,$sp,40
	j	$ra
	.end	executeHelp
	.size	executeHelp, .-executeHelp
	.rdata
	.align	2
$LC13:
	.ascii	"Version: \"%s\" \n\000"
	.align	2
$LC14:
	.ascii	"1.1\000"
	.text
	.align	2
	.globl	executeVersion
	.ent	executeVersion
executeVersion:
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
	la	$a0,__sF+88
	la	$a1,$LC13
	la	$a2,$LC14
	la	$t9,fprintf
	jal	$ra,$t9
	move	$v0,$zero
	move	$sp,$fp
	lw	$ra,32($sp)
	lw	$fp,28($sp)
	addu	$sp,$sp,40
	j	$ra
	.end	executeVersion
	.size	executeVersion, .-executeVersion
	.rdata
	.align	2
$LC16:
	.ascii	"version\000"
	.align	2
$LC17:
	.ascii	"help\000"
	.align	2
$LC18:
	.ascii	"input\000"
	.align	2
$LC19:
	.ascii	"output\000"
	.align	2
$LC20:
	.ascii	"ibuf-bytes\000"
	.align	2
$LC21:
	.ascii	"obuf-bytes\000"
	.data
	.align	2
$LC22:
	.word	$LC16
	.word	0
	.word	0
	.word	86
	.word	$LC17
	.word	0
	.word	0
	.word	104
	.word	$LC18
	.word	1
	.word	0
	.word	105
	.word	$LC19
	.word	1
	.word	0
	.word	111
	.word	$LC20
	.word	1
	.word	0
	.word	73
	.word	$LC21
	.word	1
	.word	0
	.word	79
	.word	0
	.word	0
	.word	0
	.word	0
	.globl	memcpy
	.rdata
	.align	2
$LC15:
	.ascii	"Vhi:o:I:O:\000"
	.align	2
$LC23:
	.ascii	"[Error] Incorrecta option de menu.\n\000"
	.align	2
$LC24:
	.ascii	"[Error] Incorrecta cantidad de bytes para el buffer de e"
	.ascii	"ntrada.\n\000"
	.align	2
$LC25:
	.ascii	"[Error] Incorrecta cantidad de bytes para el buffer de s"
	.ascii	"alida.\n\000"
	.align	2
$LC26:
	.ascii	"-\000"
	.align	2
$LC27:
	.ascii	"r\000"
	.align	2
$LC28:
	.ascii	"[Error] El archivo de input no pudo ser abierto para lec"
	.ascii	"tura: %s \n\000"
	.align	2
$LC29:
	.ascii	"w\000"
	.align	2
$LC30:
	.ascii	"[Error] El archivo de output no pudo ser abierto para es"
	.ascii	"critura: %s \n\000"
	.align	2
$LC31:
	.ascii	"[Warning] El archivo de input no pudo ser cerrado correc"
	.ascii	"tamente: %s \n\000"
	.align	2
$LC32:
	.ascii	"[Warning] El archivo de output no pudo ser cerrado corre"
	.ascii	"ctamente: %s \n\000"
	.text
	.align	2
	.globl	executeByMenu
	.ent	executeByMenu
executeByMenu:
	.frame	$fp,256,$ra		# vars= 208, regs= 3/0, args= 24, extra= 8
	.mask	0xd0000000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$t9
	.set	reorder
	subu	$sp,$sp,256
	.cprestore 24
	sw	$ra,248($sp)
	sw	$fp,244($sp)
	sw	$gp,240($sp)
	move	$fp,$sp
	sw	$a0,256($fp)
	sw	$a1,260($fp)
	sw	$zero,32($fp)
	sw	$zero,36($fp)
	la	$v0,__sF
	sw	$v0,40($fp)
	la	$v0,__sF+88
	sw	$v0,44($fp)
	lw	$v1,256($fp)
	li	$v0,1			# 0x1
	bne	$v1,$v0,$L20
	li	$v0,1			# 0x1
	sw	$v0,32($fp)
	li	$v0,1			# 0x1
	sw	$v0,36($fp)
$L20:
	sw	$zero,48($fp)
	sw	$zero,52($fp)
	sw	$zero,56($fp)
	sw	$zero,60($fp)
	la	$v0,$LC15
	sw	$v0,64($fp)
	addu	$v0,$fp,72
	la	$v1,$LC22
	move	$a0,$v0
	move	$a1,$v1
	li	$a2,112			# 0x70
	la	$t9,memcpy
	jal	$ra,$t9
	sw	$zero,184($fp)
	sw	$zero,188($fp)
	sw	$zero,192($fp)
	sw	$zero,196($fp)
	sb	$zero,200($fp)
$L21:
	addu	$v1,$fp,72
	addu	$v0,$fp,196
	sw	$v0,16($sp)
	lw	$a0,256($fp)
	lw	$a1,260($fp)
	lw	$a2,64($fp)
	move	$a3,$v1
	la	$t9,getopt_long
	jal	$ra,$t9
	sb	$v0,200($fp)
	lbu	$v0,200($fp)
	sll	$v0,$v0,24
	sra	$v1,$v0,24
	li	$v0,-1			# 0xffffffffffffffff
	beq	$v1,$v0,$L22
	lw	$v0,184($fp)
	bne	$v0,$zero,$L22
	lw	$v0,188($fp)
	bne	$v0,$zero,$L22
	lb	$v0,200($fp)
	addu	$v0,$v0,-73
	sw	$v0,236($fp)
	lw	$v1,236($fp)
	sltu	$v0,$v1,39
	beq	$v0,$zero,$L32
	lw	$v0,236($fp)
	sll	$v1,$v0,2
	la	$v0,$L33
	addu	$v0,$v1,$v0
	lw	$v0,0($v0)
	.cpadd	$v0
	j	$v0
	.rdata
	.align	2
$L33:
	.gpword	$L30
	.gpword	$L32
	.gpword	$L32
	.gpword	$L32
	.gpword	$L32
	.gpword	$L32
	.gpword	$L31
	.gpword	$L32
	.gpword	$L32
	.gpword	$L32
	.gpword	$L32
	.gpword	$L32
	.gpword	$L32
	.gpword	$L26
	.gpword	$L32
	.gpword	$L32
	.gpword	$L32
	.gpword	$L32
	.gpword	$L32
	.gpword	$L32
	.gpword	$L32
	.gpword	$L32
	.gpword	$L32
	.gpword	$L32
	.gpword	$L32
	.gpword	$L32
	.gpword	$L32
	.gpword	$L32
	.gpword	$L32
	.gpword	$L32
	.gpword	$L32
	.gpword	$L27
	.gpword	$L28
	.gpword	$L32
	.gpword	$L32
	.gpword	$L32
	.gpword	$L32
	.gpword	$L32
	.gpword	$L29
	.text
$L26:
	la	$t9,executeVersion
	jal	$ra,$t9
	sw	$v0,192($fp)
	li	$v0,1			# 0x1
	sw	$v0,188($fp)
	b	$L21
$L27:
	la	$t9,executeHelp
	jal	$ra,$t9
	sw	$v0,192($fp)
	li	$v0,1			# 0x1
	sw	$v0,188($fp)
	b	$L21
$L28:
	lw	$v0,optarg
	sw	$v0,48($fp)
	b	$L21
$L29:
	lw	$v0,optarg
	sw	$v0,52($fp)
	b	$L21
$L30:
	lw	$v0,optarg
	sw	$v0,56($fp)
	b	$L21
$L31:
	lw	$v0,optarg
	sw	$v0,60($fp)
	b	$L21
$L32:
	li	$v0,1			# 0x1
	sw	$v0,184($fp)
	b	$L21
$L22:
	lw	$v1,184($fp)
	li	$v0,1			# 0x1
	bne	$v1,$v0,$L34
	la	$a0,__sF+176
	la	$a1,$LC23
	la	$t9,fprintf
	jal	$ra,$t9
	li	$v0,2			# 0x2
	sw	$v0,232($fp)
	b	$L19
$L34:
	lw	$v1,188($fp)
	li	$v0,1			# 0x1
	bne	$v1,$v0,$L35
	lw	$v0,192($fp)
	sw	$v0,232($fp)
	b	$L19
$L35:
	lw	$v0,56($fp)
	beq	$v0,$zero,$L36
	addu	$v0,$fp,204
	lw	$a0,56($fp)
	move	$a1,$v0
	li	$a2,10			# 0xa
	la	$t9,strtoul
	jal	$ra,$t9
	sw	$v0,ibytes
	lw	$v0,ibytes
	bne	$v0,$zero,$L36
	la	$a0,__sF+176
	la	$a1,$LC24
	la	$t9,fprintf
	jal	$ra,$t9
	li	$v1,6			# 0x6
	sw	$v1,232($fp)
	b	$L19
$L36:
	lw	$v0,60($fp)
	beq	$v0,$zero,$L38
	addu	$v0,$fp,208
	lw	$a0,60($fp)
	move	$a1,$v0
	li	$a2,10			# 0xa
	la	$t9,strtoul
	jal	$ra,$t9
	sw	$v0,obytes
	lw	$v0,obytes
	bne	$v0,$zero,$L38
	la	$a0,__sF+176
	la	$a1,$LC25
	la	$t9,fprintf
	jal	$ra,$t9
	li	$v0,6			# 0x6
	sw	$v0,232($fp)
	b	$L19
$L38:
	lw	$v0,48($fp)
	beq	$v0,$zero,$L41
	la	$a0,$LC26
	lw	$a1,48($fp)
	la	$t9,strcmp
	jal	$ra,$t9
	bne	$v0,$zero,$L40
$L41:
	li	$v0,1			# 0x1
	sw	$v0,32($fp)
$L40:
	lw	$v0,52($fp)
	beq	$v0,$zero,$L43
	la	$a0,$LC26
	lw	$a1,52($fp)
	la	$t9,strcmp
	jal	$ra,$t9
	bne	$v0,$zero,$L42
$L43:
	li	$v0,1			# 0x1
	sw	$v0,36($fp)
$L42:
	lw	$v0,32($fp)
	bne	$v0,$zero,$L44
	lw	$a0,48($fp)
	la	$a1,$LC27
	la	$t9,fopen
	jal	$ra,$t9
	sw	$v0,40($fp)
	lw	$v0,40($fp)
	bne	$v0,$zero,$L44
	la	$a0,__sF+176
	la	$a1,$LC28
	lw	$a2,48($fp)
	la	$t9,fprintf
	jal	$ra,$t9
	li	$v1,3			# 0x3
	sw	$v1,232($fp)
	b	$L19
$L44:
	lw	$v0,36($fp)
	bne	$v0,$zero,$L46
	lw	$a0,52($fp)
	la	$a1,$LC29
	la	$t9,fopen
	jal	$ra,$t9
	sw	$v0,44($fp)
	lw	$v0,44($fp)
	bne	$v0,$zero,$L46
	la	$a0,__sF+176
	la	$a1,$LC30
	lw	$a2,52($fp)
	la	$t9,fprintf
	jal	$ra,$t9
	lw	$v0,32($fp)
	bne	$v0,$zero,$L48
	lw	$a0,40($fp)
	la	$t9,fclose
	jal	$ra,$t9
	sw	$v0,212($fp)
	lw	$v1,212($fp)
	li	$v0,-1			# 0xffffffffffffffff
	bne	$v1,$v0,$L48
	la	$a0,__sF+176
	la	$a1,$LC31
	lw	$a2,48($fp)
	la	$t9,fprintf
	jal	$ra,$t9
$L48:
	li	$v0,3			# 0x3
	sw	$v0,232($fp)
	b	$L19
$L46:
	lw	$v0,40($fp)
	lh	$v0,14($v0)
	sw	$v0,212($fp)
	lw	$v0,44($fp)
	lh	$v0,14($v0)
	sw	$v0,216($fp)
	lw	$a0,212($fp)
	lw	$a1,ibytes
	lw	$a2,216($fp)
	lw	$a3,obytes
	la	$t9,palindrome
	jal	$ra,$t9
	sw	$v0,220($fp)
	sw	$zero,224($fp)
	lw	$v0,32($fp)
	bne	$v0,$zero,$L50
	lw	$v0,40($fp)
	beq	$v0,$zero,$L50
	lw	$a0,40($fp)
	la	$t9,fclose
	jal	$ra,$t9
	sw	$v0,224($fp)
	lw	$v1,224($fp)
	li	$v0,-1			# 0xffffffffffffffff
	bne	$v1,$v0,$L50
	la	$a0,__sF+176
	la	$a1,$LC31
	lw	$a2,48($fp)
	la	$t9,fprintf
	jal	$ra,$t9
$L50:
	lw	$v0,36($fp)
	bne	$v0,$zero,$L52
	lw	$v0,44($fp)
	beq	$v0,$zero,$L52
	lw	$a0,44($fp)
	la	$t9,fclose
	jal	$ra,$t9
	sw	$v0,228($fp)
	lw	$v1,228($fp)
	li	$v0,-1			# 0xffffffffffffffff
	bne	$v1,$v0,$L52
	la	$a0,__sF+176
	la	$a1,$LC32
	lw	$a2,52($fp)
	la	$t9,fprintf
	jal	$ra,$t9
	li	$v0,-1			# 0xffffffffffffffff
	sw	$v0,224($fp)
$L52:
	lw	$v0,224($fp)
	beq	$v0,$zero,$L54
	li	$v1,3			# 0x3
	sw	$v1,232($fp)
	b	$L19
$L54:
	lw	$v0,220($fp)
	sw	$v0,232($fp)
$L19:
	lw	$v0,232($fp)
	move	$sp,$fp
	lw	$ra,248($sp)
	lw	$fp,244($sp)
	addu	$sp,$sp,256
	j	$ra
	.end	executeByMenu
	.size	executeByMenu, .-executeByMenu
	.rdata
	.align	2
$LC33:
	.ascii	"[Error] Cantidad m\303\241xima de par\303\241metros inco"
	.ascii	"rrecta: %d \n\000"
	.text
	.align	2
	.globl	main
	.ent	main
main:
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
	lw	$v0,48($fp)
	slt	$v0,$v0,10
	bne	$v0,$zero,$L56
	la	$a0,__sF+176
	la	$a1,$LC33
	lw	$a2,48($fp)
	la	$t9,fprintf
	jal	$ra,$t9
	li	$v0,1			# 0x1
	sw	$v0,24($fp)
	b	$L55
$L56:
	lw	$a0,48($fp)
	lw	$a1,52($fp)
	la	$t9,executeByMenu
	jal	$ra,$t9
	sw	$v0,24($fp)
$L55:
	lw	$v0,24($fp)
	move	$sp,$fp
	lw	$ra,40($sp)
	lw	$fp,36($sp)
	addu	$sp,$sp,48
	j	$ra
	.end	main
	.size	main, .-main
	.ident	"GCC: (GNU) 3.3.3 (NetBSD nb3 20040520)"
