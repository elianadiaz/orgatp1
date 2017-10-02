#include <mips/regdef.h>
#include <sys/syscall.h>

.data
input: .asciiz		"anitalavalatina"
input_len: .word	16	

	.text			# segmento de texto del programa

	.abicalls
	.align 2		# alineacion 2^2

	.globl	main
	.ent	main
main:
	# debugging info: descripcion del stack frame
	.frame	$fp, 40, ra	# $fp: registro usado como frame pointer
				# 40: tamañodel stack frame
				# ra: registro que almacena el return address
	# bloque para codigo PIC
	.set	noreorder	# apaga reordenamiento de instrucciones
	.cpload t9		# directiva usada para codigo PIC
	.set	reorder		# enciende reordenamiento de instrucciones

	# creo stack frame
	subu	sp, sp, 40	# 4 (SRA) + 2 (LTA) + 4 (ABA)

	# directiva para codigo PIC
	.cprestore 24		# inserta aqui "sw gp, 24(sp)",
				# mas "lw gp, 24(sp)" luego de cada jal.
	# salvado de callee-saved regs en SRA	
	sw	$fp, 28(sp)
	sw	ra, 32(sp)

	# de aqui al fin de la funcion uso $fp en lugar de sp.
	move	$fp, sp

	# sw	a0, 40($fp)	# n: a0, sp+40
	
	la	a0, input_len	# Carga la variable
	lw	a0, 0(a0)
	la	a1, input_len	# Carga la variable
	jal 	isPalindrome	# Ejecuta la funcion
	add	a0, v0, zero
	jal	printRes	# Imprimir resultado
	addi	v0, zero, 10
	syscall			# Exit

isPalindrome:
	# Chequeo el caso basico de palabra de hasta 2 caracteres
	slti	t0, a0, 2
	bne	t0, zero, returnTrue

	# Me aseguro que la primera y ultima letra sean iguales
	lb	t0, 0(a1)
	addi	t1, a0, -1
	add	t1, t1, a1
	lb	t1, 0(t1)
	bne	t0, t1, returnFalse
	
	# muevo los punteros del final y del principio
	addi	a0, a0, -2
	addi	a1, a1, 1
	j	isPalindrome
	
returnFalse:
	addi	v0, zero, 0
	jr	ra


returnTrue:
	addi	v0, zero, 1
	jr	ra


.data
ES_STRING: .asciiz	" es"
NO_ES_STRING: .asciiz	" no es"
A_PAL_STRING: .asciiz	"palindroma"

.text		
printRes:
	add	t4, a0, zero	# Stash result
	addi	v0, zero, 4
	la	a0, input
	syscall			# Imprime
	la	a0, ES_STRING
	syscall			# Imprime 
	bne	t4, zero, printResCont
		la a0, NO_ES_STRING  
		syscall		# Imprime
printResCont:
	la	a0, A_PAL_STRING
	syscall			# Imprime
	jr	ra
