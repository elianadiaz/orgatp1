#include <mips/regdef.h>
#include <sys/syscall.h>

#STATICS VAR DEFINITIONS

#define FALSE 			0
#define TRUE 			1
#define DIR_NULL 		0
#define FILE_DESCRIPTOR_STDERR	2

# Resultados de funciones posibles
#define OKEY			0
#define ERROR_MEMORY		2
#define LOAD_I_BUFFER		5

# Size mensajes
#define BYTES_MENSAJE_ERROR_MEMORIA_OBUFFER	60


##-----	processDataInIBuffer -----##

	.align		2
	.globl		processDataInIBuffer
	.ent		processDataInIBuffer
processDataInIBuffer:
	.frame		$fp,80,ra	
	.set		noreorder
	.cpload		t9
	.set		reorder
	
	#Stack frame creation
	subu		sp,sp,80
	
	.cprestore 16
	sw		ra,72(sp)
	sw		$fp,68(sp)
	sw		gp,64(sp)
	move		$fp,sp
	
	# Parameter
	sw		a0,80($fp)			# Guardo en la direccion de memoria 80($fp) la variable * ibuffer (char * ibuffer).
	sw		a1,84($fp)			# Guardo en la direccion de memoria 84($fp) la variable * amountSavedInOBuffer (int * amountSavedInOBuffer).
	
	sw		zero,24($fp)			# Guardo en la direccion de memoria 24($fp) el valor FALSE (que seria 0), representa la variable findEnd (int findEnd = FALSE).
	sw		zero,28($fp)			# Guardo en la direccion de memoria 28($fp) el valor FALSE (que seria 0), representa la variable loadIBuffer (int loadIBuffer = FALSE).
	sw		zero,32($fp)			# Guardo en la direccion de memoria 32($fp) el valor 0, representa la variable idx (int idx = 0).
	sw		zero,36($fp)			# Guardo en la direccion de memoria 36($fp) el valor OKEY (que seria 0), representa la variable rdo (int rdo = FALSE).
$WhileProcessDataInIBuffer:
	# findEnd == FALSE ?
	lw		v0,24($fp)			# Cargo en v0 el contenido de la direccion de memoria 24($fp), que seria la variable findEnd.
	bne		v0,FALSE,$LeaveWhileProcessDataInIBuffer # If (findEnd != FALSE) goto LeaveWhileProcessDataInIBuffer.
	
	# loadIBuffer == FALSE ?
	lw		v0,28($fp)			# Cargo en v0 el contenido de la direccion de memoria 28($fp), que seria la variable loadIBuffer.
	bne		v0,zero,$LeaveWhileProcessDataInIBuffer # If (loadIBuffer != FALSE) goto LeaveWhileProcessDataInIBuffer.
	
	# Comienzo a ejecutar las intrucciones dentro del while
	
	# char character = ibuffer[idx];
	lw		v1,80($fp)			# Cargo en v1 lo guardado en la direccion de memoria 80($fp), que seria la variable ibuffer.
	lw		v0,32($fp)			# Cargo en v0 lo guardado en la direccion de memoria 32($fp), que seria la variable idx.
	addu		v0,v1,v0			# Me corro en la direccion de memoria: a la apuntada por v1 (ibuffer) me corro la cantidad de posiciones establecidas por idx.
	lbu		v0,0(v0)			# Cargo en v0 la direccion de memoria guardada en v0 (calculada en el paso anterior).
	sb		v0,40($fp)			# Guardo en la direccion 40($fp) lo guardado en v0. Representaria la variable character.
	
	# character == '\0' ?
	lb		v0,40($fp)			# Cargo en v0 el contenido de la direccion de memoria 40($fp), que seria la variable character.
	bne		v0,zero,$VerifyCharacterToLoadInLexico  # If (character != '\0') goto VerifyCharacterToLoadInLexico.
	
	# character is equal '\0'
	li		v0,TRUE				# Cargo en v0 TRUE (que seria el literal 1).
	sw		v0,24($fp)			# Guardo en la direccion de memoria 24($fp) el contenido de v0 (findEnd = TRUE).
$VerifyCharacterToLoadInLexico:
	# findEnd != TRUE
	lw		v1,24($fp)			# Cargo en v1 el contenido de la direccion de memoria 24($fp), que seria findEnd.
	li		v0,TRUE				# Cargo en v0 el literal 1 (TRUE) para hacer luego una comparacion.
	beq		v1,v0,$VerifyQuantityCharacterInLexico  # Si findEnd (v1) es igual a TRUE (v0), salto a VerifyQuantityCharacterInLexico.
	
	# findEnd es igual a TRUE. Continuo validaciones para cargar caracter en lexico.
	# Voy a verificar si el caracter es una keyword.
	lb		v0,40($fp)			# Cargo en v0 el contenido en la direccion de memoria 40($fp), que seria character.
	move		a0,v0				# Muevo el contenido de v0 a a0. Voy a pasar como parametro la variable character a la funcion isKeywords.
	la		t9,isKeywords			# Cargo la direccion de memoria de isKeywords.
	jal		ra,t9				# Ejecuto la funcion isKeywords.
	move		v1,v0				# Muevo el resultado de la funcion isKeywords, que esta en v0, a v1.
	li		v0,TRUE
	bne		v1,v0,$VerifyQuantityCharacterInLexico  # Si el resultado de la funcion isKeywords (v1) no es igual a TRUE (v0), salto a VerifyQuantityCharacterInLexico.
	
	# El caracter es una keyword.
	lb		v0,40($fp)			# Cargo en v0 el contenido en la direccion de memoria 40($fp), que seria character.
	move		a0,v0				# Muevo el contenido de v0 a a0. Parametro de la funcion loadInLexico.
	la		t9,loadInLexico
	jal		ra,t9				# Ejecuto loadInLexico.
	sw		v0,44($fp)			# Guardo el resultado de loadInLexico en la direccion 44($fp). Variable rdo.
	lw		v0,44($fp)
	beq		v0,OKEY,$VerifyLoadIBuffer	# If (rdo == OKEY) goto VerifyLoadIBuffer.
	
	# rdo != OKEY
	lw		v0,44($fp)			# Cargo v0 el codigo de error.
	sw		v0,56($fp)			# Guardo en la direccion 56($fp) el codigo de error.
	b		$ReturnProcessDataInIBuffer # Salto incondicional al return de la funcion.
$VerifyQuantityCharacterInLexico:
	# quantityCharacterInLexico > 0 ?
	lw		v0,quantityCharacterInLexico	# Cargo en v0 quantityCharacterInLexico.
	blez		v0,$VerifyLoadIBuffer		# Si quantityCharacterInLexico (v0) es menor que 0, salto a VerifyLoadIBuffer.
	
	# quantityCharacterInLexico > 0 => Verifico si lexico es palindromo.
	lw		a0,lexico			# Cargo en a0 lexico (parametro para la funcion verifyPalindromic).
	lw		a1,quantityCharacterInLexico	# Cargo en a1 quantityCharacterInLexico (parametro para la funcion verifyPalindromic).
	la		t9,verifyPalindromic		# Cargo en t9 la direccion de la verifyPalindromic.
	jal		ra,t9				# Ejecuto la funcion verifyPalindromic.
	sw		v0,44($fp)			# Guardo en la direccion de memoria 44($fp) el resultado de la funcion verifyPalindromic, que esta 
							# almacenado en v0 y que representaria a la variable itsPalindromic.	
	lw		v1,44($fp)			# Cargo en v1 lo que se encuentra en la direccion de memoria 44($fp) que seria el resultado de la funcion verifyPalindromic.
	li		v0,TRUE
	bne		v1,v0,$myfreeLexico			# If (itsPalindromic != TRUE) goto myfreeLexico.
	
	# itsPalindromic is TRUE
	
	# int amountToSaved = (*amountSavedInOBuffer) + quantityCharacterInLexico;
	lw	v0,84($fp)				# Cargo en v0 lo almacenado en la direccion de memoria 84($fp), que seria la variable *amountSavedInOBuffer.
	lw	v1,0(v0)				# Cargo lo almacenado en la direccion de memoria apuntada por *amountSavedInOBuffer en v1.
	lw	v0,quantityCharacterInLexico		# Cargo en v0 quantityCharacterInLexico.
	addu	v0,v1,v0				# Hago (*amountSavedInOBuffer) + quantityCharacterInLexico, y guardo el resultado en v0.
	sw	v0,48($fp)				# Guardo el resultado de la suma (almacenado el v0) en la direccion de memoria 48($fp), que representaria a la variable amountToSaved.
	
	# (*amountSavedInOBuffer) > 0 ?
	lw	v0,84($fp)				# Cargo en v0 lo almacenado en la direccion de memoria 84($fp), que seria la variable *amountSavedInOBuffer.
	lw	v0,0(v0)				# Cargo lo almacenado en la direccion de memoria apuntada por *amountSavedInOBuffer en v0.
	bgtz	v0,$IncrementAmountToSaved		# Si el contenido de lo almacenado en la direccion apuntada por amountSavedInOBuffer (que esta en v0) 
								# es mas grande que 0, salto a IncrementAmountToSaved.
	
	# (*amountSavedInOBuffer) <= 0
	# savedInOFile == TRUE ?
	lw	v1,savedInOFile				# Cargo en v1 savedInOFile.
	li	v0,TRUE
	beq	v1,v0,$IncrementAmountToSaved 		# If (savedInOFile == TRUE) goto IncrementAmountToSaved.
	b	$ContinueVerificationAboutAmountToSaved # Salto incondicional a ContinueVerificationAboutAmountToSaved.
$IncrementAmountToSaved:
	# amountToSaved ++;  Es para el separador entre lexicos
	lw	v0,48($fp)				# Cargo en v0 lo guardado en la direccion de memoria 48($fp), que representaria a la variable amountToSaved.
	addu	v0,v0,1					# Incremento en uno a amountToSaved.
	sw	v0,48($fp)				# Guardo el nuevo valor de amountToSaved (almacenado en v0) en la direccion de memoria 48($fp).
$ContinueVerificationAboutAmountToSaved:
	# amountToSaved > osize ?
	lw	v0,48($fp)				# Cargo en v0 lo guardado en la direccion de memoria 48($fp), que representaria a la variable amountToSaved.
	lw	v1,osize				# Cargo en v1 osize.
	sltu	v0,v1,v0				# Si v1 (osize) es mas chico que v0 (amountToSaved), guardo TRUE en v0, sino guardo FALSE.
	beq	v0,FALSE,$LoadLexicoInOBuffer		# Si el resultado de la comparacion es FALSE (amountToSaved <= osize), salto a LoadLexicoInOBuffer.
	
	# amountToSaved > osize
	# Tomo la decision de pedir mas memoria para bajar el lexico completo
	# y luego rearmo el buffer de salida y reinicio la cantidad guardada en 0.
	
	# obuffer = myRealloc(obuffer, amountToSaved*sizeof(char), (*amountSavedInOBuffer));
	lw	v0,84($fp)				# Cargo en v0 lo guardado en la direccion de memoria 84($fp), que representaria a la variable *amountSavedInOBuffer.
	lw	a0,obuffer				# Cargo en a0 obuffer (parametro para la funcion myRealloc).
	lw	a1,48($fp)				# Cargo en a1 lo guardado en la direccion de memoria 48($fp), que representaria a la variable *amountToSaved. Parametro 
								# para la funcion myRealloc.
	lw	a2,0(v0)				# Cargo en a2 lo almacenado en la direccion de memoria guardada en v0 (parametro para la funcion myRealloc).
	la	t9,myRealloc				# Cargo en t9 la direccion de la myRealloc.
	jal	ra,t9					# Ejecuto myRealloc con los parametros: myRealloc(obuffer, amountToSaved*sizeof(char), (*amountSavedInOBuffer));
	sw	v0,obuffer				# Asigno a obuffer el resultado de myRealloc almacenado en v0.
	
	# (obuffer == NULL) ?
	lw	v0,obuffer
	bne	v0,DIR_NULL,$CopyLexicoInBuffer # If (obuffer != NULL) goto CopyLexicoInBuffer
	
	# obuffer is NULL => Mensaje error.
	li		a0,FILE_DESCRIPTOR_STDERR		# Cargo en a0 FILE_DESCRIPTOR_STDERR.
	la		a1,MENSAJE_ERROR_MEMORIA_OBUFFER 	# Cargo en a1 la direccion de memoria donde se encuentra el mensaje a cargar.
	li		a2,BYTES_MENSAJE_ERROR_MEMORIA_OBUFFER	# Cargo en a2 la cantidad de bytes a escribir.
	li		v0, SYS_write
	syscall						# No controlo error porque sale de por si de la funcion por error.
	
	li	v0,ERROR_MEMORY
	sw	v0,56($fp)
	b	$ReturnProcessDataInIBuffer
$CopyLexicoInBuffer:
	# copyFromLexicoToOBuffer(amountSavedInOBuffer);
	lw	a0,84($fp)				# Cargo en a0 amountSavedInOBuffer. Parametro de la funcion copyFromLexicoToOBuffer.
	la	t9,copyFromLexicoToOBuffer
	jal	ra,t9					# Ejecuto la funcion copyFromLexicoToOBuffer.
	
	# int rdoWrite = writeBufferInOFile(amountSavedInOBuffer, obuffer);
	lw	a0,84($fp)			# Cargo en a0 amountSavedInOBuffer. Parametro de la funcion writeBufferInOFile.
	lw	a1,obuffer			# Cargo en a1 obuffer. Parametro de la funcion writeBufferInOFile.
	la	t9,writeBufferInOFile
	jal	ra,t9				# Ejecuto la funcion writeBufferInOFile.
	sw	v0,52($fp)			# Guardo en la direccion 52($fp) el resultado de writeBufferInOFile.
	
	# (rdoWrite != OKEY) ?
	lw	v0,52($fp)
	beq	v0,OKEY,$WriteInNewOBuffer	# If (rdoWrite == OKEY) goto WriteInNewOBuffer.
	
	# rdoWrite is not OKEY
	lw	v0,52($fp)			# Cargo en v0 el codigo de error de escribir en el archivo de salida.
	sw	v0,56($fp)			# Guardo en la direccion de memoria 56($fp) ese codigo de error.
	b	$ReturnProcessDataInIBuffer # Salto incondicional al return de la funcion.
$WriteInNewOBuffer:
	# *amountSavedInOBuffer = 0;
	lw	v0,84($fp)				# Cargo en v0 lo guardado en la direccion de memoria 84($fp), que representaria a la variable *amountSavedInOBuffer.
	sw	zero,0(v0)				# Guardo 0 en la direccion apuntada por amountSavedInOBuffer.
	
	# savedInOFile = TRUE;
	li	v0,TRUE
	sw	v0,savedInOFile				# Guardo en savedInOFile el contenido de v0 (TRUE).
	
	# obuffer != NULL ?
	lw	v0,obuffer
	beq	v0,DIR_NULL,$mymallocNewOBuffer			# If (obuffer == NULL) goto mymallocNewOBuffer.
	
	# obuffer != NULL => myfree(obuffer) and obuffer = NULL.
	lw	a0,obuffer
	la	t9,myfree
	jal	ra,t9		# Ejecuto myfree sobre obuffer.
	sw	zero,obuffer				# Asigno NULL a obuffer.
$mymallocNewOBuffer:
	# obuffer = loadBufferInitial(osize, obuffer);
	lw	a0,osize				# Cargo en a0 osize. Parametro de la funcion loadBufferInitial.
	lw	a1,obuffer				# Cargo en a1 obuffer. Parametro de la funcion loadBufferInitial.
	la	t9,loadBufferInitial
	jal	ra,t9					# Ejecuto la funcion loadBufferInitial.	
	sw	v0,obuffer				# Asigno la nueva direccion de memoria, que se encuentra almacenada en v0, a obuffer.
	
	# (obuffer == NULL) ?
	lw	v0,obuffer
	bne	v0,DIR_NULL,$myfreeLexico	# If (obuffer != NULL) goto myfreeLexico.
	
	li	v0,ERROR_MEMORY
	sw	v0,56($fp)					# Guardo en la direccion de memoria 56($fp) ese codigo de error.
	b	$ReturnProcessDataInIBuffer # Salto incondicional al return de la funcion.
$LoadLexicoInOBuffer:
	# (*amountSavedInOBuffer) > 0 ?
	lw	a0,84($fp)				# Cargo en a0 lo guardado en la direccion de memoria 84($fp), que representaria a la variable *amountSavedInOBuffer.
								# Parametro de la funcion copyFromLexicoToOBuffer.
	la	t9,copyFromLexicoToOBuffer
	jal	ra,t9					# Ejecuto la funcion copyFromLexicoToOBuffer.
$myfreeLexico:
	lw	a0,lexico				# Cargo en a0 lexico.
	la	t9,myfree				
	jal	ra,t9					# Ejecuto la funcion myfree
	sw	zero,lexico				# Asigno NULL a lexico.
	sw	zero,quantityCharacterInLexico  	# Dejo quantityCharacterInLexico en 0.
$VerifyLoadIBuffer:
	# (idx + 1) == isize ?
	lw	v0,32($fp)				# Cargo en v0 lo guardado en la direccion 32($fp), que seria la variable idx.
	addu	v1,v0,1					# Incremento en 1 a idx y lo guardo en v1.
	lw	v0,isize				# Cargo en v0 isize para luego hacer comparacion.
	bne	v1,v0,$IncrementIdx			# If ((idx+1) != isize) goto IncrementIdx
	
	# ((idx + 1) == isize) is TRUE
	li	v0,TRUE
	sw	v0,28($fp)				# Guardo en la direccion 28($fp), que estaba la variable loadIBuffer, TRUE.
	li	v0,LOAD_I_BUFFER
	sw	v0,36($fp)				# Guardo en la direccion 36($fp), que estaba la variable rdo -resultado de la operacion-, LOAD_I_BUFFER.
	
	b	$WhileProcessDataInIBuffer		# Salto incondicional al comienzo del while para verificar entrada al mismo.
$IncrementIdx:
	# idx ++
	lw	v0,32($fp)				# Cargo en v0 idx, guardado en la direccion 32($fp).
	addu	v0,v0,1					# Incremento en 1 a idx.
	sw	v0,32($fp)				# Guardo el nuevo valor de idx.
	
	b	$WhileProcessDataInIBuffer		# Salto incondicional al comienzo del while para verificar entrada al mismo.
$LeaveWhileProcessDataInIBuffer:
	lw	v0,36($fp)				# Cargo en v0 el resultado del while: variable rdo guardada en la direccion 36($fp).
	sw	v0,56($fp)				# Guardo en 56($fp) el resultado de la funcion.
$ReturnProcessDataInIBuffer:
	lw	v0,56($fp)
	move	sp,$fp
	lw	ra,72(sp)
	lw	$fp,68(sp)
	addu	sp,sp,80
	j	ra						# Jump and return
	.end	processDataInIBuffer
	

## Mensajes de error

	.rdata
	
	.align	2
MENSAJE_ERROR_MEMORIA_OBUFFER:
	.ascii	"[Error] Hubo un error de asignacion de memoria (obuffer)"
	.ascii	". \n\000"
	

	
