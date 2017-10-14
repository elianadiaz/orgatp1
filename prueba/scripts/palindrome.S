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
#define ERROR_READ		3
#define	ERROR_WRITE		4
#define LOAD_I_BUFFER		5

# Size mensajes
#define BYTES_MENSAJE_ERROR_MEMORIA_OBUFFER	60
#define BYTES_MENSAJE_ERROR_MEMORIA_IBUFFER 	60
#define BYTES_MENSAJE_ERROR_MEMORIA_AMOUNT_SAVED 64
#define BYTES_MENSAJE_ERROR_LECTURA_ARCHIVO	60


##-----	palindrome -----##
		
	.align		2
	.globl		palindrome
	.ent		palindrome
palindrome:
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
	
	# Parameters
	sw		a0,80($fp)				# Guardo en la direccion de memoria 80($fp) la variable ifd (int ifd).
	sw		a1,84($fp)				# Guardo en la direccion de memoria 84($fp) la variable ibytes (size_t ibytes).
	sw		a2,88($fp)				# Guardo en la direccion de memoria 88($fp) la variable ofd (int ofd).
	sw		a3,92($fp)				# Guardo en la direccion de memoria 92($fp) la variable obytes (size_t obytes).
	
	# isize = ibytes;
	lw		v0,84($fp)				# Cargo en v0 ibytes, guardado en 84($fp).
	sw		v0,isize				# Guardo en isize ibytes.
	
	# osize = obytes;
	lw		v0,92($fp)				# Cargo en v0 obytes, guardado en 92($fp).
	sw		v0,osize				# Guardo en osize obytes.
	
	# oFileDescriptor = ofd;
	lw		v0,88($fp)				# Cargo en v0 ofd, guardado en 88($fp).
	sw		v0,oFileDescriptor			# Guardo en oFileDescriptor ofd.
	
	# char * ibuffer = (char *) mymalloc(ibytes*sizeof(char));
	lw		a0,84($fp)				# Cargo en a0 ibytes, guardado en 84($fp). Parametro de la funcion mymalloc.
	la		t9,mymalloc				# Cargo en t9 la direccion de la funcion mymalloc.
	jal		ra,t9					# Ejecuto la funcion mymalloc.
	sw		v0,24($fp)				# En v0 esta el resultado de mymalloc. Guardo esto en la direccion 24($fp) que representaria la variable * ibuffer.
	
	# ibuffer == NULL ?
	lw		v0,24($fp)				# Cargo en v0 *ibuffer, guardado en la direccion 24($fp).
	bne		v0,DIR_NULL,$OBuffermymalloc		# If (ibuffer != NULL) goto OBuffermymalloc
	
	# ibuffer is NULL => Mensaje de error
	li		a0,FILE_DESCRIPTOR_STDERR		# Cargo en a0 FILE_DESCRIPTOR_STDERR.
	la		a1,MENSAJE_ERROR_MEMORIA_IBUFFER 	# Cargo en a1 la direccion de memoria donde se encuentra el mensaje a cargar.
	li		a2,BYTES_MENSAJE_ERROR_MEMORIA_IBUFFER	# Cargo en a2 la cantidad de bytes a escribir.
	li		v0, SYS_write
	syscall						# No controlo error porque sale de por si de la funcion por error.
	
	li		v0,ERROR_MEMORY				# Cargo en v0 el codigo de error.	
	sw		v0,60($fp)				# Guardo el codigo de error (en v0) en la direccion de memoria 60($fp).
	b		$ReturnPalindrome			# Salto incondicional al return de la funcion (goto ReturnPalindrome).
$OBuffermymalloc:
	# obuffer = (char *) mymalloc(obytes*sizeof(char));
	lw		a0,92($fp)				# Cargo en a0 obytes. Parametro de la funcion mymalloc.
	la		t9,mymalloc				# Cargo en t9 la direccion de la funcion mymalloc.
	jal		ra,t9					# Ejecuto la funcion mymalloc.
	sw		v0,obuffer				# En v0 esta el resultado de mymalloc. Guardo esto en obuffer.
	
	# obuffer == NULL ?
	lw		v0,obuffer				# Cargo en v0 obuffer.
	bne		v0,DIR_NULL,$InitializeBuffers 		# If (obuffer != NULL) goto InitializeBuffers
	
	# obuffer is NULL => Mensaje de error
	li		a0,FILE_DESCRIPTOR_STDERR		# Cargo en a0 FILE_DESCRIPTOR_STDERR.
	la		a1,MENSAJE_ERROR_MEMORIA_OBUFFER 	# Cargo en a1 la direccion de memoria donde se encuentra el mensaje a cargar.
	li		a2,BYTES_MENSAJE_ERROR_MEMORIA_OBUFFER	# Cargo en a2 la cantidad de bytes a escribir.
	li		v0, SYS_write
	syscall						# No controlo error porque sale de por si de la funcion por error.
	
	# myfree(ibuffer)
	lw		a0,24($fp)				# Cargo en a0 ibuffer. Parametro de la funcion myfree.
	la		t9,myfree				# Cargo en t9 direccion de la funcion myfree.
	jal		ra,t9					# Ejecuto la funcion myfree.
	sw		zero,24($fp)				# Asigno NULL a ibuffer.
	
	li		v0,ERROR_MEMORY				# Cargo en v0 el codigo de error.	
	sw		v0,60($fp)				# Guardo el codigo de error (en v0) en la direccion de memoria 60($fp).
	b		$ReturnPalindrome			# Salto incondicional al return de la funcion (goto ReturnPalindrome).	
$InitializeBuffers:
	# initialize the ibuffer: initializeBuffer(ibytes, ibuffer);
	lw		a0,84($fp)				# Cargo en a0 ibytes. Parametro de la funcion initializeBuffer.
	lw		a1,24($fp)				# Cargo en a1 ibuffer. Parametro de la funcion initializeBuffer.
	la		t9,initializeBuffer			# Cargo en t9 la direccion de la funcion initializeBuffer.
	jal		ra,t9					# Ejecuto la funcion initializeBuffer.
	
	# initialize the obuffer: initializeBuffer(obytes, obuffer);
	lw		a0,92($fp)				# Cargo en a0 0bytes. Parametro de la funcion initializeBuffer.
	lw		a1,obuffer				# Cargo en a1 0buffer. Parametro de la funcion initializeBuffer.
	la		t9,initializeBuffer			# Cargo en t9 la direccion de la funcion initializeBuffer.
	jal		ra,t9					# Ejecuto la funcion initializeBuffer.
	
	# int * amountSavedInOBuffer = (int *) mymalloc(sizeof(int));
	li		a0,4					# Cargo en a0 la cantidad de bytes a asignar (por ser un int, son 4 bytes).
	la		t9,mymalloc				# Cargo en t9 la direccion de la funcion mymalloc.
	jal		ra,t9					# Ejecuto la funcion mymalloc.
	sw		v0,28($fp)				# En v0 esta el resultado de mymalloc. Asigno este resultado a la direccion 
								# 28($fp), que representaria a la variable * amountSavedInOBuffer.
	
	# amountSavedInOBuffer == NULL ?
	lw		v0,28($fp)				# Cargo en v0 amountSavedInOBuffer
	bne		v0,DIR_NULL,$ContinueProcessToLoadIBuffer # If (amountSavedInOBuffer != NULL) goto ContinueProcessToLoadIBuffer
	
	# amountSavedInOBuffer is NULL => Mensaje de error
	li		a0,FILE_DESCRIPTOR_STDERR		# Cargo en a0 FILE_DESCRIPTOR_STDERR.
	la		a1,MENSAJE_ERROR_MEMORIA_AMOUNT_SAVED 	# Cargo en a1 la direccion de memoria donde se encuentra el mensaje a cargar.
	li		a2,BYTES_MENSAJE_ERROR_MEMORIA_AMOUNT_SAVED # Cargo en a2 la cantidad de bytes a escribir.
	li		v0, SYS_write
	syscall						# No controlo error porque sale de por si de la funcion por error.
	
	# myfree(ibuffer)
	lw		a0,24($fp)				# Cargo en a0 ibuffer. Parametro de la funcion myfree.
	la		t9,myfree				# Cargo en t9 la direccion de la funcion myfree.
	jal		ra,t9					# Ejecuto la funcion myfree.
	sw		zero,24($fp)				# Asigno NULL a ibuffer.
	
	# myfree(obuffer)
	lw		a0,obuffer				# Cargo en a0 obuffer. Parametro de la funcion myfree.
	la		t9,myfree				# Cargo en t9 la direccion de la funcion myfree.
	jal		ra,t9					# Ejecuto la funcion myfree.
	sw		zero,obuffer				# Asigno NULL a obuffer.
	
	li		v0,ERROR_MEMORY				# Cargo en v0 el codigo de error.	
	sw		v0,60($fp)				# Guardo el codigo de error (en v0) en la direccion de memoria 60($fp).
	b		$ReturnPalindrome			# Salto incondicional al return de la funcion (goto ReturnPalindrome).	
$ContinueProcessToLoadIBuffer:
	# amountSavedInOBuffer[0] = 0;
	lw		v0,28($fp)				# Cargo en v0 amountSavedInOBuffer.
	sw		zero,0(v0)				# Asigno a amountSavedInOBuffer el valor 0.
	
	# int rdoProcess = OKEY;
	sw		zero,32($fp)				# Asigno a rdoProcess, que esta en la direccion 32($fp), el valor OKEY.
	
	# int end = FALSE;
	sw		zero,36($fp)				# Asigno a end, que esta en la direccion 36($fp), el valor FALSE.
	
	# int error = FALSE;
	sw		zero,40($fp)				# Asigno a error, que esta en la direccion 40($fp), el valor FALSE.
$WhilePalindrome:
	# end == FALSE ?
	lw		v0,36($fp)				# Cargo en v0 end.
	bne		v0,FALSE,$myfreeBuffers			# If (end != FALSE) goto myfreeBuffers.
	
#	# end is FALSE
	
#	# error == FALSE ?
	lw		v0,40($fp)				# Cargo en v0 end.
	bne		v0,FALSE,$myfreeBuffers			# If (error != FALSE) goto myfreeBuffers.
	
#	#  error is FALSE
	
	# Within the while
	
	# int completeDelivery = FALSE;
	sw		zero,44($fp)				# Guardo FALSE en la direccion 44($fp), que representaria la variable completeDelivery.
	
	# int bytesReadAcum = 0;
	sw		zero,48($fp)				# Guardo 0 en la direccion 48($fp), que representaria la variable bytesReadAcum.
	
#	#  size_t bytesToRead = ibytes;
	lw		v0,84($fp)				# Cargo en v0 ibytes, que esta en la direccion 84($fp).
	sw		v0,52($fp)				# Guardo ibytes (que esta en v0) en la direccion 52($fp), que representaria la variable bytesToRead.
$WhileLoadIBuffer:
	# completeDelivery == FALSE ?
	lw		v0,44($fp)				# Cargo en v0 completeDelivery.
	bne		v0,FALSE,$VerifyIfWriteOFile		# If (completeDelivery != FALSE) goto VerifyIfWriteOFile.
	
	# end == FALSE
	lw		v0,36($fp)				# Cargo en v0 end.
	bne		v0,FALSE,$VerifyIfWriteOFile		# If (end != FALSE) goto VerifyIfWriteOFile.
	
	# Read iterative
	
	# int bytesRead = read(ifd, ibuffer + bytesReadAcum, bytesToRead);
	lw		v1,24($fp)				# Cargo en v1 ibuffer.
	lw		v0,48($fp)				# Cargo en v0 bytesReadAcum.
	addu		v0,v1,v0				# Guardo en v0 el resultado de ibuffer + bytesReadAcum.
	lw		a0,80($fp)				# Cargo en a0 ifd. Parametro de la funcion read.
	move		a1,v0					# Cargo en a1 la direccion del buffer a donde se van a guardar los bytes leidos 
								# (ibuffer + bytesReadAcum). Parametro de la funcion read.
	lw		a2,52($fp)				# Cargo en a2 bytesToRead. Parametro de la funcion read.
	li		v0, SYS_read
	syscall						# Seria read: int bytesRead = read(ifd, ibuffer + bytesReadAcum, bytesToRead);
	
	# Controlo errores y cantidad de bytes leidos. v0 contiene el numero de caracteres leidos (es negativo si hubo error y es 0 si llego a fin del archivo).	
	sw		v0,56($fp)				# Guardo en la direccion de memoria 56($fd) el resultado de la funcion read, que estaria representado por la variable bytesRead.
	
	# bytesRead == -1 ?
	lw		v1,56($fp)				# Cargo en v1 bytesRead.
	li		v0,-1					# Cargo en v0 -1 para la comparacion.
	bne		v1,v0,$ContinueValidationResultRead 	# If (bytesRead != -1) goto ContinueValidationResultRead.
	
	# bytesRead is -1 => Mensaje de error.
	li		a0,FILE_DESCRIPTOR_STDERR		# Cargo en a0 FILE_DESCRIPTOR_STDERR.
	la		a1,MENSAJE_ERROR_LECTURA_ARCHIVO 	# Cargo en a1 la direccion de memoria donde se encuentra el mensaje a cargar.
	li		a2,BYTES_MENSAJE_ERROR_LECTURA_ARCHIVO	# Cargo en a2 la cantidad de bytes a escribir.
	li		v0, SYS_write
	syscall						# No controlo error porque sale de por si de la funcion por error.
	
	# myfree(ibuffer)	
	lw		a0,24($fp)				# Cargo en a0 ibuffer. Parametro de la funcion myfree.
	la		t9,myfree				# Cargo la direccion de la funcion myfree.
	jal		ra,t9					# Ejecuto la funcion myfree.
	sw		zero,24($fp)				# Asigno NULL a ibuffer.
	
	# myfree(obuffer)
	lw		a0,obuffer				# Cargo en a0 obuffer. Parametro de la funcion myfree.
	la		t9,myfree				# Cargo la direccion de la funcion myfree.
	jal		ra,t9					# Ejecuto la funcion myfree.
	sw		zero,obuffer				# Asigno NULL a obuffer.
	
	# myfree(amountSavedInOBuffer)
	lw		a0,28($fp)				# Cargo en a0 amountSavedInOBuffer. Parametro de la funcion myfree.
	la		t9,myfree				# Cargo la direccion de la funcion myfree.
	jal		ra,t9					# Ejecuto la funcion myfree.
	sw		zero,28($fp)				# Asigno NULL a amountSavedInOBuffer.
	
	# lexico != NULL ?
	lw		v0,lexico				# Cargo en v0 lexico.
	beq		v0,DIR_NULL,$ReturnErrorRead		# If (lexico == NULL) goto ReturnErrorRead.
	
	# lexico is not NULL
	lw		a0,lexico				# Cargo en a0 lexico. Parametro de la funcion myfree.
	la		t9,myfree				# Cargo la direccion de la funcion myfree.
	jal		ra,t9					# Ejecuto la funcion myfree.
	sw		zero,lexico				# Asigno NULL a lexico.
$ReturnErrorRead:
	li		v0,ERROR_READ				# Cargo en v0 el codigo de ERROR_READ.
	sw		v0,60($fp)				# Guardo en la direccion 60($fp) el resultado de la funcion palindrome, que en este caso es un error.
	b		$ReturnPalindrome			# Salto incondicional al return de la funcion palindrome.
$ContinueValidationResultRead:
	lw		v0,56($fp)				# Cargo en v1 bytesRead.
	bne		v0,zero,$ContinueAccumulatingBytesRead 	# If (bytesRead != 0) goto ContinueAccumulatingBytesRead
	li		v0,TRUE			
	sw		v0,36($fp)				# Asigno a la variable end, guardada en 36($fp), TRUE.
$ContinueAccumulatingBytesRead:
	# bytesReadAcum += bytesRead;
	lw		v1,48($fp)				# Cargo en v1 bytesReadAcum.
	lw		v0,56($fp)				# Cargo en v0 bytesRead.
	addu		v0,v1,v0				# Sumo bytesReadAcum con bytesRead y guardo resultado en v0.
	sw		v0,48($fp)				# Guardo el resultado de la suma en bytesReadAcum.
	
	# bytesToRead = ibytes - bytesReadAcum;
	lw		v1,84($fp)				# Cargo en v1 ibytes.
	lw		v0,48($fp)				# Cargo en v0 bytesReadAcum.
	subu		v0,v1,v0				# Resto ibytes con bytesReadAcum y guardo resultado en v0, para saber cuandos bytes restan por leer del archivo.
	sw		v0,52($fp)				# Asigno a bytesToRead el resultado de la resta.
	
	# bytesToRead == 0 ?
	lw		v0,52($fp)				# Cargo en v0 bytesToRead.
	bne		v0,zero,$WhileLoadIBuffer		# If (bytesToRead != 0) goto WhileLoadIBuffer
	
	# bytesToRead is 0.
	li		v0,TRUE
	sw		v0,44($fp)				# Asigno a completeDelivery TRUE.
	b		$WhileLoadIBuffer			# Salto incondicional al comienzo del while para cargar el buffer con los datos del archivo (goto WhileLoadIBuffer).
$VerifyIfWriteOFile:
	# Verifico si tengo datos en el buffer de entrada para verificar palindromos, 
	# guardar en el buffer de salida y en el archivo de salida si corresponde.
	
	# ibuffer != NULL && ibuffer[0] != '\0' ?
	
	# ibuffer != NULL ?
	lw		v0,24($fp)				# Cargo en v0 ibuffer.
	beq		v0,DIR_NULL,$WhilePalindrome		# If (ibuffer == NULL) goto WhilePalindrome.
	
	# ibuffer is not NULL
	
	# ibuffer[0] != '\0' ?
	lw		v0,24($fp)				# Cargo en v0 ibuffer.
	lb		v0,0(v0)				# Cargo en contenido de la primer posicion de ibuffer en v0.
	beq		v0,zero,$WhilePalindrome		# If (ibuffer[0] == '\0') goto WhilePalindrome
	
	# ibuffer[0] is not equal '\0'
	
	# int resultProcessWrite = executePalindromeWrite(ibuffer, amountSavedInOBuffer);
	lw		a0,24($fp)				# Cargo en a0 ibuffer. Parametro de la funcion executePalindromeWrite.
	lw		a1,28($fp)				# Cargo en a1 amountSavedInOBuffer. Parametro de la funcion executePalindromeWrite.
	la		t9,executePalindromeWrite		# Cargo en t9 la direccion de memoria en donde se encuentra la funcion executePalindromeWrite.
	jal		ra,t9					# Ejecuto la funcion executePalindromeWrite.
	sw		v0,56($fp)				# El resultado de la ejecucion de la funcion executePalindromeWrite esta en v0. Guardo 
								# este resultado en la direccion de memoria 56($fp), que representaria a la variable resultProcessWrite.
	
	# resultProcessWrite == LOAD_I_BUFFER ?
	lw		v1,56($fp)				# Cargo en v1 resultProcessWrite.
	li		v0,LOAD_I_BUFFER
	bne		v1,v0,$ContinueValidationResultExecutePalinWrite # If (resultProcessWrite != LOAD_I_BUFFER) goto ContinueValidationResultExecutePalinWrite.
	
	# resultProcessWrite is equal LOAD_I_BUFFER
	
	# initializeBuffer(ibytes, ibuffer);
	lw		a0,84($fp)				# Cargo en a0 ibytes. Parametro de la funcion initializeBuffer.
	lw		a1,24($fp)				# Cargo en a1 ibuffer. Parametro de la funcion initializeBuffer.
	la		t9,initializeBuffer			# Cargo en t9 la direccion de la funcion initializeBuffer.
	jal		ra,t9					# Ejecuto la funcion initializeBuffer.
$ContinueValidationResultExecutePalinWrite:
	# (resultProcessWrite == ERROR_MEMORY || resultProcessWrite == ERROR_WRITE) ?
	
	# resultProcessWrite == ERROR_MEMORY ?
	lw		v1,56($fp)				# Cargo en v1 resultProcessWrite.
	li		v0,ERROR_MEMORY
	beq		v1,v0,$LoadErrorOfExecutePalinWrite 	# If (resultProcessWrite == ERROR_MEMORY) goto LoadErrorOfExecutePalinWrite.
	
	# resultProcessWrite is not equal ERROR_MEMORY
	
	# resultProcessWrite == ERROR_WRITE ?
	lw		v1,56($fp)				# Cargo en v1 resultProcessWrite.
	li		v0,ERROR_WRITE
	beq		v1,v0,$LoadErrorOfExecutePalinWrite 	# If (resultProcessWrite == ERROR_WRITE) goto LoadErrorOfExecutePalinWrite.
	
	# No hay errores
	b		$WhilePalindrome			# Vuelvo a intentar entrar al loop.
$LoadErrorOfExecutePalinWrite:
#	# error = TRUE;
	li		v0,TRUE
	sw		v0,40($fp)				# Asigno a la variable error TRUE.
	
	# rdoProcess = resultProcessWrite;
	lw		v0,56($fp)				# Cargo en v0 resultProcessWrite.
	sw		v0,32($fp)				# Asigno a la variable rdoProcess resultProcessWrite.
	
	b		$WhilePalindrome			# Vuelvo a intentar entrar al loop.
$myfreeBuffers:
	# (ibuffer != NULL) ?
	lw		v0,24($fp)				# Cargo en v0 ibuffer.
	beq		v0,DIR_NULL,$myfreeOBufferInPalindrome 	# If (ibuffer == NULL) goto myfreeOBufferInPalindrome
	
	# ibuffer es not NULL
	lw		a0,24($fp)				# Cargo en a0 ibuffer. Parametro de la funcion myfree.
	la		t9,myfree				# Cargo en t9 la direccion de la funcion myfree.
	jal		ra,t9					# Ejecuto la funcion myfree.
	sw		zero,24($fp)				# Asigno a ibuffer NULL.
$myfreeOBufferInPalindrome:
	# (obuffer != NULL) ?
	lw		v0,obuffer				# Cargo en v0 obuffer.
	beq		v0,DIR_NULL,$myfreeLexicoInPalindrome 	# If (obuffer == NULL) goto myfreeLexicoInPalindrome.
	
	# obuffer is not NULL
	
	# (amountSavedInOBuffer != NULL && (*amountSavedInOBuffer) > 0) ?
	
	# (amountSavedInOBuffer != NULL) ?
	lw		v0,28($fp)				# Cargo en v0 amountSavedInOBuffer.
	beq		v0,DIR_NULL,$myfreeLexicoPalin		# If (amountSavedInOBuffer == NULL) goto myfreeLexicoPalin.
	
	# amountSavedInOBuffer is not NULL
	
	# ((*amountSavedInOBuffer) > 0) ?
	lw		v0,28($fp)				# Cargo en v0 amountSavedInOBuffer.
	lw		v0,0(v0)				# Cargo el contenido de lo apuntado por amountSavedInOBuffer en v0.
	blez		v0,$myfreeLexicoPalin			# If ((* amountSavedInOBuffer) <= 0) goto myfreeLexicoPalin.
	
	# (*amountSavedInOBuffer) is greater then 0
	
	# int rdoWrite = writeOBufferInOFile(amountSavedInOBuffer);
	lw		a0,28($fp)				# Cargo en a0 amountSavedInOBuffer. Parametro de la funcion writeOBufferInOFile.
	la		t9,writeOBufferInOFile			# Cargo en t9 la direccion de la funcion writeOBufferInOFile.
	jal		ra,t9					# Ejecuto la funcion writeOBufferInOFile.
	sw		v0,56($fp)				# En v0 esta el resultado de writeOBufferInOFile (que seria la variable rdoWrite). Guado esto en la direccion 56($fp).
	
	# (rdoWrite != OKEY) ?
	lw		v0,56($fp)				# Cargo en v0 rdoWrite.
	beq		v0,OKEY,$myfreeLexicoPalin		# If (rdoWrite == OKEY) goto myfreeLexicoPalin.
	
	# rdoWrite is OKEY.
	
	# rdoProcess = rdoWrite;
	lw		v0,56($fp)				# Cargo en v0 rdoWrite.
	sw		v0,32($fp)				# Asigno a la variable rdoProcess rdoWrite.
$myfreeLexicoPalin:
	# myfree(obuffer);
	lw		a0,obuffer				# Cargo en a0 obuffer. Parametro de la funcion myfree.
	la		t9,myfree				# Cargo en t9 la direccion de la funcion myfree.
	jal		ra,t9					# Ejecuto la funcion myfree.
	sw		zero,obuffer				# Asigno NULL a obuffer.
$myfreeLexicoInPalindrome:
	# (lexico != NULL) ?
	lw		v0,lexico				# Cargo en v0 lexico.
	beq		v0,DIR_NULL,$myfreeAmountSavedInOBuffer # If (lexico == NULL) goto myfreeAmountSavedInOBuffer.
	
	# lexico is not NULL
	lw		a0,lexico				# Cargo en a0 lexico. Parametro de la funcion myfree.
	la		t9,myfree				# Cargo en t9 la direccion de la funcion myfree.
	jal		ra,t9					# Ejecuto la funcion myfree.
	sw		zero,lexico				# Asigno NULL a lexico.
$myfreeAmountSavedInOBuffer:
	# (amountSavedInOBuffer != NULL) ?
	lw		v0,28($fp)				# Cargo en v0 amountSavedInOBuffer.
	beq		v0,DIR_NULL,$LoadReturnPalindrome 	# If (amountSavedInOBuffer == NULL) goto LoadReturnPalindrome.
	
	# amountSavedInOBuffer is not NULL
	
	# myfree(amountSavedInOBuffer);
	lw		a0,28($fp)				# Cargo en a0 amountSavedInOBuffer. Parametro de la funcion myfree.
	la		t9,myfree				# Cargo en t9 la direccion de la funcion myfree.
	jal		ra,t9					# Ejecuto la funcion myfree.
	sw		zero,28($fp)				# Asigno NULL a amountSavedInOBuffer.
$LoadReturnPalindrome:
	lw		v0,32($fp)				# Cargo en v0 rdoProcess.
	sw		v0,60($fp)				# Cargo en la direccion 60($fp) el resultado de la funcion palindrome, que en este caso seria rdoProcess.
$ReturnPalindrome:
	lw		v0,60($fp)
	move		sp,$fp
	lw		ra,72(sp)
	lw		$fp,68(sp)
	addu		sp,sp,80
	j		ra					# Jump and return
	.end	palindrome


## Variables auxiliares

	.data

	.globl	isize
	.align 2
isize:		
	.space 4

	.globl	osize
	.align 2
osize:		
	.space 4

	.globl	oFileDescriptor
	.align 2
oFileDescriptor:	
	.space 4	
	
	.globl		lexico
	.section	.bss
	.align	2
	.type	lexico, @object
	.size	lexico, 4
lexico:
	.space	4
	
	.globl	quantityCharacterInLexico
	.align	2
	.type	quantityCharacterInLexico, @object
	.size	quantityCharacterInLexico, 4
quantityCharacterInLexico:
	.space	4
	
	.globl	savedInOFile
	.align	2
	.type	savedInOFile, @object
	.size	savedInOFile, 4
savedInOFile:
	.space	4
	
	.globl	obuffer
	.align	2
	.type	obuffer, @object
	.size	obuffer, 4
obuffer:
	.space	4
	
	.globl	bytesLexico
	.align	2
	.type	bytesLexico, @object
	.size	bytesLexico, 4
bytesLexico:
	.space	4	
	
	
## Mensajes de error

	.rdata	
	
	.align	2
MENSAJE_ERROR_MEMORIA_OBUFFER:
	.ascii	"[Error] Hubo un error de asignacion de memoria (obuffer)"
	.ascii	". \n\000"
	
	.align	2
MENSAJE_ERROR_MEMORIA_IBUFFER:
	.ascii	"[Error] Hubo un error de asignacion de memoria (ibuffer)"
	.ascii	". \n\000"
	
	.align	2
MENSAJE_ERROR_MEMORIA_AMOUNT_SAVED:
	.ascii	"[Error] Hubo un error de asignacion de memoria (amountSa"
	.ascii	"ved). \n\000"
	
	.align	2
MENSAJE_ERROR_LECTURA_ARCHIVO:
	.ascii	"[Error] Hubo un error en la lectura de datos del archivo"
	.ascii	". \n\000"


