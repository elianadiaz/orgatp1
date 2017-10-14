#include <mips/regdef.h>
#include <sys/syscall.h>

#STATICS VAR DEFINITIONS

#define FALSE 			0
#define TRUE 			1


##-----	copyFromLexicoToOBuffer -----##

	.align		2
	.globl		copyFromLexicoToOBuffer
	.ent		copyFromLexicoToOBuffer
copyFromLexicoToOBuffer:
	.frame		$fp,24,ra
	.set		noreorder
	.cpload		t9
	.set		reorder

	#Stack frame creation
	subu		sp,sp,24
	
	.cprestore 0
	sw		$fp,20(sp)
	sw		gp,16(sp)
	move		$fp,sp

	# Parameter
	sw		a0,24($fp)				# Guardo en la direccion de memoria 24($fp) la variable * amountSavedInOBuffer (int * amountSavedInOBuffer).
	
	sw		zero,8($fp)				# Guardo en la direccion 8($fp) el contador i para el for inicializado en 0.
$ForCopy:
	lw		v0,8($fp)				# Cargo en v0 el contador i.
	lw		v1,quantityCharacterInLexico
	slt		v0,v0,v1				# Guardo TRUE en v0 si (i < quantityCharacterInLexico), sino guardo FALSE.
	bne		v0,FALSE,$InForCopy			# Si el resultado de la comparacion no es FALSE, o sea, (i < quantityCharacterInLexico), entro 
								# al for (goto InForCopy).
	b		$ReturnCopyFromLexicoToOBuffer		# Salto incondicional a ReturnCopyFromLexicoToOBuffer (el return de la funcion).
$InForCopy:
	# obuffer[*amountSavedInOBuffer] = lexico[i];
	lw		v0,24($fp)				# Cargo *amountSavedInOBuffer en v0.
	lw		v1,obuffer
	lw		v0,0(v0)				# Cargo en v0 lo almacenado en la direccion de memoria guardada en v0 (*amountSavedInOBuffer).
	addu		a0,v1,v0				# Guardo en a0 la nueva direccion de memoria sobre obuffer: 
								# obuffer + *amountSavedInOBuffer = obuffer[*amountSavedInOBuffer]
	lw		v1,lexico				# Cargo en v1 lexico.
	lw		v0,8($fp)				# Cargo en v0 el indice i guardado en la direccion de memoria 8($fp).
	addu		v0,v1,v0				# Me muevo sobre lexico: lexico + i = lexico[i]. Guardo la direccion en v0.
	lbu		v0,0(v0)				# Cargo en v0 lo guardado en la direccion de memoria almacenada en v0 (es sobre lexico).			
	sb		v0,0(a0)				# Guardo en la direccion de memoria almacenada en a0 (es sobre obuffer) lo almacenado en v0. O sea:
								# obuffer[*amountSavedInOBuffer] = lexico[i];
	
	# *amountSavedInOBuffer = (*amountSavedInOBuffer) + 1;	
	lw		v1,24($fp)				# Cargo *amountSavedInOBuffer en v1.
	lw		v0,24($fp)				# Cargo *amountSavedInOBuffer en v0.
	lw		v0,0(v0)				# Cargo en v0 lo almacenado en la direccion de memoria guardada en v0 (*amountSavedInOBuffer).
	addu		v0,v0,1					# Incremento en 1.
	sw		v0,0(v1)				# Guargo el nuevo valor de amountSavedInOBuffer.

	# ++i
	lw		v0,8($fp)				# Cargo en v0 el indice i guardado en la direccion de memoria 8($fp).
	addu		v0,v0,1					# Incremento en 1 el indice i.
	sw		v0,8($fp)				# Guardo el incremento.

	b		$ForCopy				# Salto incondicional. Vuelvo al comienzo del loop for.
$ReturnCopyFromLexicoToOBuffer:
	move		sp,$fp
	lw		$fp,20(sp)
	addu		sp,sp,24
	j		ra
	.end		copyFromLexicoToOBuffer


