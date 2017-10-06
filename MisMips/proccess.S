#include <mips/regdef.h>
#include <sys/syscall.h>

#STATICS VAR DEFINITIONS FUNCTION PALINDROME
#define SF_SIZE_TO_LOWER_CASE    24 
#define SF_SIZE_PALINDROME       56 

#define FALSE 0
#define TRUE 1
#define LEXICO_SIZE 10

##-----	toLowerCase -----##
	.text
	.abicalls
	.align 2
	.globl toLowerCase 
	.ent toLowerCase
toLowerCase:
	.frame		$fp, SF_SIZE_TO_LOWER_CASE, ra	# vars= 16, regs= 2/0, args= 0, extra= 8 => 24 = 16 + 0 + 8
	.set		noreorder
	.cpload		t9
	.set		reorder
	
	#Stack frame creation
	subu		sp,sp,SF_SIZE_TO_LOWER_CASE
	
	.cprestore	16 								# equivale a  sw gp,16(sp) 
	sw			$fp,20(sp) 		 				#Register saving: gp y fp. Leaf function.
	move		$fp,sp
	
	move		$v0,$a0							# word (this is the character)
	sb			$v0,8($fp)
	lb			$v0,8($fp)
	slt			$v0,$v0,65
	bne			$v0,$zero,$IfNotLower			# if !(word >= 65) goto IfNotLower 
	lb			$v0,8($fp)
	slt			$v0,$v0,91
	beq			$v0,$zero,$IfNotLower			# if !(word <= 90) goto IfNotLower 
	lbu			$v0,8($fp)
	addu		$v0,$v0,32						# word += 32
	sb			$v0,8($fp)
$IfNotLower:
	lb			$v0,8($fp)
	move		$sp,$fp
	
	#Stack frame destruction.
	lw			$fp,20($sp)
	addu		$sp,$sp,SF_SIZE_TO_LOWER_CASE
	j			$ra								#jump and return
	.end		toLowerCase
	
	# TODO VER SI LAS SIGUIENTES 3 LINEAS SON NECESARIAS
	.size		toLowerCase, .-toLowerCase
	.rdata
	.align	3


##-----	verifyPalindromic -----##

	.text
	.align		2
	.globl		verifyPalindromic
	.ent		verifyPalindromic
verifyPalindromic:
	.frame		$fp,72,$ra						# vars= 32, regs= 3/0, args= 16, extra= 8 => 72 = 32 + 16 + 3*8
	.set		noreorder
	.cpload		$t9
	.set		reorder
	
	#Stack frame creation
	subu		$sp,$sp,72
	
	.cprestore 	16
	sw			$ra,64($sp)
	sw			$fp,60($sp)
	sw			$gp,56($sp)
	move		$fp,$sp
	
	sw			$a0,72($fp)						# char * word
	sw			$a1,76($fp)						# int quantityCharacterInWord
	lw			$v0,72($fp)
	beq			$v0,$zero,$IfPalindromicFalse	# if (word == NULL) goto IfPalindromicFalse
	lw			$v0,76($fp)
	blez		$v0,$IfPalindromicFalse			# if (quantityCharacterInWord <= 0) goto IfPalindromicFalse
	b			$VerifyWhenOneCharacter			# Salta siempre - goto VerifyWhenOneCharacter
$IfPalindromicFalse:
	sw			FALSE,52($fp)
	b			$ReturnVerifyPalindromic		# Salta siempre - goto ReturnVerifyPalindromic (con return FALSE)
$VerifyWhenOneCharacter:
	lw			$v1,76($fp)						# Cargo quantityCharacterInWord
	li			$v0,1							# Cargo en v0, el valor 1, para luego hacer la comparacion
	bne			$v1,$v0,$VerifyWhenTwoCharacteres	# if (quantityCharacterInWord != 1) goto VerifyWhenTwoCharacteres
	li			$v0,TRUE						# Cargo resultado (TRUE es igual a 1)
	sw			$v0,52($fp)
	b			$ReturnVerifyPalindromic		# Salta siempre - goto ReturnVerifyPalindromic (con return TRUE)
$VerifyWhenTwoCharacteres:
	lw			$v1,76($fp)						# Cargo quantityCharacterInWord
	li			$v0,2							# Cargo en v0, el valor 2, para luego hacer la comparacion
	bne			$v1,$v0,$VerifyWhenMoreThanOneCharacter	# if (quantityCharacterInWord != 2) goto VerifyWhenMoreThanOneCharacter
	
	# Paso a minuscula el primer caracter del lexico
	lw			$v0,72($fp)						# Cargo word
	lb			$v0,0($v0)						# Cargo el primer caracter apuntado por word	
	move		$a0,$v0							# Cargo el primer caracter que estaba en v0, en a0. Voy a enviarlo por parametro a la funcion toLoweCase
	la			$t9,toLowerCase					# Cargo la direccion de la funcion toLowerCase
	jal			$ra,$t9							# Salto a la funcion toLowerCase	
	sb			$v0,24($fp)						# Cargo el resultado en v0 en 24($fp)  TODO
	
	# Paso a minuscula el segundo caracter del lexico
	lw			$v0,72($fp)						# Cargo la direccion de memoria en donde esta word	
	addu		$v0,$v0,1						# Sumo uno a la direccion de memoria, me corro un lugar.
	lb			$v0,0($v0)						# Cargo el segundo caracter apuntado por word (solo habian dos caracteres)
	move		$a0,$v0							# Cargo el segundo caracter que estaba en v0, en a0. Voy a enviarlo por parametro a la funcion toLoweCase
	la			$t9,toLowerCase					# Cargo la direccion de la funcion toLowerCase
	jal			$ra,$t9							# Salto a la funcion toLowerCase
	sb			$v0,25($fp)						# Cargo el resultado en v0 en 25($fp)  TODO
	
	lb			$v1,24($fp)						# Cargo el primer caracter en minuscula en v1
	lb			$v0,25($fp)						# Cargo el segundo caracter en minuscula en v0
	beq			$v1,$v0,$IfPalindromicTrue		# if (firstCharacter == lastCharacter) goto IfPalindromicTrue
	sw			FALSE,52($fp)
	b			$ReturnVerifyPalindromic		# Salta siempre - goto ReturnVerifyPalindromic (con return FALSE)
$IfPalindromicTrue:
	li			$v0,TRUE						# TRUE es igual a 1
	sw			$v0,52($fp)
	b			$ReturnVerifyPalindromic		# Salta siempre - goto ReturnVerifyPalindromic (con return TRUE)
$VerifyWhenMoreThanOneCharacter:
	l.s			$f0,76($fp)
	cvt.d.w		$f2,$f0
	l.d			$f0,$LC0
	div.d		$f0,$f2,$f0
	s.d			$f0,32($fp)
	sw			$zero,40($fp)
	li			$v0,1			# 0x1
	sw			$v0,44($fp)
	lw			$v0,76($fp)
	addu		$v0,$v0,-1
	sw			$v0,48($fp)
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
$ReturnVerifyPalindromic:
	lw	$v0,52($fp)
	move	$sp,$fp
	lw	$ra,64($sp)
	lw	$fp,60($sp)
	addu	$sp,$sp,72
	j	$ra
	.end	verifyPalindromic
	.size	verifyPalindromic, .-verifyPalindromic
	