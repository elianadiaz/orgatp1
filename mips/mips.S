#include <mips/regdef.h>
#include <sys/syscall.h>

	.text

	.abicalls
	.align 2

	.globl palindrome
	.ent palindrome
palindrome:
#Inicializo
#Encabezado Funcion palindrome (ifd,buffer_size_read,ofd,buffer_size_write)
	.frame 	$fp, 40, ra
	.set 	noreorder
	.cpload	t9
	.set 	reorder
	
	subu sp, sp, 40
	
	.cprestore	24
	
	sw $fp, 28(sp)
	sw ra, 32(sp)
	move $fp, sp
	sw a0, 40($fp)

	#Programa principal palindrome
	lw a0, 40($fp)

	li	v0, SYS_write
	li  a0, 1  # esto es stdout (pantalla)
	la	a1, input  
	lw	a2, input_len
	syscall		# Imprime

	la	a0, input_len	# Carga el largo de la variable
	lw	a0, 0(a0)
	la	a1, input	# Carga la variable
	
	la	t9, _isPalindrome	# Ejecuta la funcion
	jal	ra, t9

	add	a0, v0, zero

	la	t9, _printRes	# Imprimir resultado
	jal	ra, t9

	j	_final_palindromo

_isPalindrome:
	# caso basico

	slti	t0, a0, 2	# la palabra es mas corta que 2
	bne	t0, zero, _returnTrue # es palindroma
	
	# me aseguro que la primera y ultima letra sean iguales
	lb	t0, 0(a1)	# cargo la primera letra
	addi	t1, a0, -1 # offset para la anteultima letra
	add	t1, t1, a1 # posiciono en la anteultima letra
	lb	t1, 0(t1) # cargo la ultima letra

	bne	t0, t1, _returnFalse # no es palindroma

	addi	a0, a0, -2	# descarto 2 caracteres (primero y ultimo)
	addi	a1, a1, 1	# muevo el cursor de la palabra
	j	_isPalindrome

_returnFalse:
	addi	v0, zero, 0
	jr	ra


_returnTrue:
	addi	v0, zero, 1
	jr	ra

_printRes:
	move	t4, a0	# Stash result
	bne	t4, zero, _print_es

_print_no_es:
	li	v0, SYS_write
	li  a0, 1  # esto es stdout (pantalla)
	la	a1, NO_ES_STRING  
	li	a2, 7
	syscall		# Imprime

	j _printResCont

_print_es:
	li	v0, SYS_write
	li  a0, 1  # esto es stdout (pantalla)
	la	a1, ES_STRING
	li	a2, 4
	syscall			# Imprime 

_printResCont:
	li	v0, SYS_write
	li  a0, 1  # esto es stdout (pantalla)
	la	a1, A_PAL_STRING
	li	a2, 11
	syscall			# Imprime
	jr	ra

##################################3
_final_palindromo:
	lw	ra,32(sp)
	lw	$fp,28(sp)
	addu	sp,sp,40

	jr	ra

	.end palindrome
	.size palindrome,.-palindrome

	.ent	mystrlen
mystrlen:
	.frame	$fp, 16, ra
	.set	noreorder
	.cpload t9
	.set	reorder

	# creo stack frame
	subu	sp, sp, 16	# 2 (SRA) + 2 (LTA)
	.cprestore 8		# sw gp, 8(sp)
	sw	$fp, 12(sp)
	move	$fp, sp

	# salvo 1er arg (siempre)
	sw	a0, 16($fp)			## redundante

	# for (i=0; s[i] != 0; i++)
	move	t0, zero	# i=0: t0, fp+0
	sw	t0, 0($fp)	# i: t0
_for_loop:
	# condicion de corte: s[i] != 0
	lw	a0, 16($fp)			## redundante
	lw	t0, 0($fp)			## redundante
	addu	t1, a0, t0	# s[i]: t1
	lb	t1, 0(t1)			## lb, NO lw!
	beq	t1, zero, _end_for
	
	lw	t0, 0($fp)	# i++		## redundante
	addu	t0, t0, 1
	sw	t0, 0($fp)			## redundante
	j	_for_loop

_end_for:
	lw	v0, 0($fp)			## podria ser un move v0, t0
	lw	gp, 8(sp)
	lw	$fp, 12(sp)
	addu	sp, sp, 16
	jr	ra

	.end	mystrlen
	.size	mystrlen,.-mystrlen

	.data

frase: .asciiz "cero es el numero que imprime\n"
frase_len:	.word	31
input: .asciiz		"ipolopi"
input_len: .word	7
entra_pal: .asciiz		"Entro a _isPalindrome\n"
entra_pal_len: .word	22

ES_STRING: .asciiz	" es "
NO_ES_STRING: .asciiz	" no es "
A_PAL_STRING: .asciiz	"palindroma\n"
fdi: .word 
