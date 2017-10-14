#include <mips/regdef.h>
#include <sys/syscall.h>

#STATICS VAR DEFINITIONS

#define TRUE 			1
#define DIR_NULL 		0
#define LINE_BREAK		10

# Resultados de funciones posibles
#define OKEY			0


##-----	cleanBuffers -----##

	.align	2
	.globl		cleanBuffers
	.ent		cleanBuffers
cleanBuffers:
	.frame		$fp,48,ra
	.set		noreorder
	.cpload	t9
	.set		reorder

	#Stack frame creation
	subu		sp,sp,48
	.cprestore 16
	sw		ra,40(sp)
	sw		$fp,36(sp)
	sw		gp,32(sp)
	move		$fp,sp

	# Parameter
	sw		a0,48($fp)				# Guardo en la direccion de memoria 48($fp) la variable * amountSavedInOBuffer (int * amountSavedInOBuffer).

	sw		zero,24($fp)				# Guardo en la direccion 24($fp) OKEY (=zero). Representa la variable rdo.

	lw		v0,ibuffer
	beq		v0,DIR_NULL,$FreeObuffer		# If (ibuffer == NULL) goto FreeObuffer.

	lw		a0,ibuffer				# Cargo en a0 ibuffer. Parametro de la funcion myfree.
	la		t9,myfree
	jal		ra,t9					# Ejecuto la funcion myfree.
	sw		zero,ibuffer				# ibuffer = NULL
$FreeObuffer:
	lw		v0,obuffer
	beq		v0,DIR_NULL,$FreeLexico			# If (obuffer == NULL) goto FreeLexico.

	# (amountSavedInOBuffer != NULL && (*amountSavedInOBuffer) > 0) ?
	
	# (amountSavedInOBuffer != NULL) ?
	lw		v0,48($fp)				# Cargo en v0 amountSavedInOBuffer.
	beq		v0,DIR_NULL,$FreeMyOBuffer		# If (amountSavedInOBuffer == NULL) goto FreeMyOBuffer

	# amountSavedInOBuffer is not NULL
	
	# ((*amountSavedInOBuffer) > 0) ?
	lw		v0,48($fp)				# Cargo en v0 amountSavedInOBuffer.
	lw		v0,0(v0)				# Cargo el contenido de lo apuntado por amountSavedInOBuffer en v0.
	blez		v0,$FreeMyOBuffer			# If ((* amountSavedInOBuffer) <= 0) goto FreeMyOBuffer.

	# (*amountSavedInOBuffer) is greater then 0
	
	# int rdoWrite = writeBufferInOFile(amountSavedInOBuffer, obuffer);
	lw		a0,48($fp)				# Cargo en a0 amountSavedInOBuffer. Parametro de la funcion writeBufferInOFile.
	lw		a1,obuffer				# Cargo en a1 obuffer. Parametro de la funcion writeBufferInOFile.
	la		t9,writeBufferInOFile
	jal		ra,t9					# Ejecuto la funcion writeBufferInOFile.
	sw		v0,28($fp)				# En v0 esta el resultado de writeOBufferInOFile (que seria la variable rdoWrite). 
								# Guardo esto en la direccion 28($fp).

	# (rdoWrite != OKEY) ?
	lw		v0,28($fp)				# Cargo en v0 rdoWrite.
	beq		v0,OKEY,$FreeMyOBuffer			# If (rdoWrite == OKEY) goto FreeMyOBuffer.
	
	# rdoWrite is not OKEY.

	# rdo = rdoWrite;
	lw		v0,28($fp)				# Cargo en v0 rdoWrite.
	sw		v0,24($fp)				# Asigno a la variable rdo rdoWrite.
$FreeMyOBuffer:
	lw		a0,obuffer				# Cargo en a0 obuffer. Parametro de la funcion myfree.
	la		t9,myfree
	jal		ra,t9					# Ejecuto la funcion myfree.
	sw		zero,obuffer				# obuffer = NULL
$FreeLexico:
	# (lexico != NULL) ?
	lw		v0,lexico
	beq		v0,DIR_NULL,$ReturnCleanBuffers		# If (lexico == NULL) goto ReturnCleanBuffers.

	# lexico is not NULL
	lw		v0,quantityCharacterInLexico
	blez		v0,$FreeMyLexico			# If (quantityCharacterInLexico <= 0) goto FreeMyLexico

	lw		a0,lexico				
	lw		a1,quantityCharacterInLexico
	la		t9,verifyPalindromic
	jal		ra,t9					# Ejecuto verifyPalindromic. Verifico si lo que quedo en lexico es palindromo.
	move		v1,v0
	li		v0,TRUE
	bne		v1,v0,$FreeMyLexico			# If no es palindromo, goto FreeMyLexico

	li		a0,LINE_BREAK
	la		t9,loadInLexico
	jal		ra,t9					# Ejecuto loadInLexico. Agrego el salto de linea al lexico.

	# int rdoWrite = writeBufferInOFile(&quantityCharacterInLexico, lexico);
	la		a0,quantityCharacterInLexico
	lw		a1,lexico
	la		t9,writeBufferInOFile
	jal		ra,t9					# Ejecuto writeBufferInOFile para guardar el lexico que es palindromo.
	sw		v0,28($fp)				# Guardo en la direccion 28($fp) el resultado de la funcion writeBufferInOFile.

	lw		v0,28($fp)
	beq		v0,OKEY,$FreeMyLexico			# Si el resultado de escribir en el archivo de salida no da error, salto a FreeMyLexico.

	lw		v0,28($fp)				# Cargo en v0 el error de escribir en el file de salida.
	sw		v0,24($fp)				# Guardo este codigo de error en la direccion 24($fp).
$FreeMyLexico:
	lw		a0,lexico
	la		t9,myfree		
	jal		ra,t9					# Ejecuto myfree para lexico.
	sw		zero,lexico				# lexico = NULL.
$ReturnCleanBuffers:
	lw		v0,24($fp)
	move		sp,$fp
	lw		ra,40(sp)
	lw		$fp,36(sp)
	addu		sp,sp,48
	j		ra
	.end		cleanBuffers


