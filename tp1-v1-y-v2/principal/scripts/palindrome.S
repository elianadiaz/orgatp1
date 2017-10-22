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
#define OKEY_I_FILE			-4

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
	.frame		$fp,64,ra
	.set		noreorder
	.cpload		t9
	.set		reorder

	#Stack frame creation
	subu		sp,sp,64

	.cprestore 16
	sw		ra,56(sp)
	sw		$fp,52(sp)
	sw		gp,48(sp)
	move		$fp,sp

	# Parameters
	sw		a0,64($fp)  # Guardo en la direccion de memoria 64($fp) la variable ifd (int ifd).
	sw		a1,68($fp)  # Guardo en la direccion de memoria 68($fp) la variable ibytes (size_t ibytes).
	sw		a2,72($fp)  # Guardo en la direccion de memoria 72($fp) la variable ofd (int ofd).
	sw		a3,76($fp)  # Guardo en la direccion de memoria 76($fp) la variable obytes (size_t obytes).

	# isize = ibytes;
	lw		v0,68($fp)  # Cargo en v0 ibytes, guardado en 68($fp).
	sw		v0,isize  # Guardo en isize ibytes.

	# osize = obytes;
	lw		v0,76($fp)  # Cargo en v0 obytes, guardado en 76($fp).
	sw		v0,osize  # Guardo en osize obytes.

	# oFileDescriptor = ofd;
	lw		v0,72($fp)  # Cargo en v0 ofd, guardado en 72($fp).
	sw		v0,oFileDescriptor			# Guardo en oFileDescriptor ofd.

	# ibuffer = loadBufferInitial(isize, ibuffer);
	lw		a0,isize  # Cargo en a0 isize. Parametro de la funcion loadBufferInitial.
	lw		a1,ibuffer  # Cargo en a1 ibuffer. Parametro de la funcion loadBufferInitial.
	la		t9,loadBufferInitial
	jal		ra,t9  	# Ejecuto la funcion loadBufferInitial.
	sw		v0,ibuffer  # Asigno a ibuffer el resultado de la funcion loadBufferInitial.

	# (ibuffer == NULL) ?
	lw		v0,ibuffer
	bne		v0,DIR_NULL,$LoadOBuffer		# If (ibuffer != NULL) goto LoadOBuffer

	# ibuffer is NULL
	li		v0,ERROR_MEMORY
	sw		v0,44($fp)  # Guardo el codigo de error en la direccion 44($fp).
	b		$ReturnPalindrome			# Salto incondicional al return de la funcion.
$LoadOBuffer:
	# obuffer = loadBufferInitial(osize, obuffer);
	lw		a0,osize
	lw		a1,obuffer
	la		t9,loadBufferInitial
	jal		ra,t9
	sw		v0,obuffer

	# (obuffer == NULL) ?
	lw		v0,obuffer	
	bne		v0,DIR_NULL,$LoadAmountSavedInOBuffer	# If (obuffer != NULL) goto LoadAmountSavedInOBuffer
	
	# free(ibuffer); ibuffer = NULL;
	lw		a0,ibuffer
	la		t9,myfree
	jal		ra,t9
	sw		zero,ibuffer

	li		v0,ERROR_MEMORY
	sw		v0,44($fp)  # Guardo el codigo de error en la direccion 44($fp).
	b		$ReturnPalindrome			# Salto incondicional al return de la funcion.
$LoadAmountSavedInOBuffer:
	li		a0,4  	# Cargo en a0 la cantidad de bytes a asignar (por ser un int, son 4 bytes).
	la		t9,mymalloc
	jal		ra,t9
	sw		v0,24($fp)  # En v0 esta el resultado de mymalloc. Asigno este resultado a la direccion 
    # 24($fp), que representaria a la variable * amountSavedInOBuffer.

	# amountSavedInOBuffer == NULL ?
	lw		v0,24($fp)
	bne		v0,DIR_NULL,$ContinueProcessToLoadIBuffer # If (amountSavedInOBuffer != NULL) goto ContinueProcessToLoadIBuffer

	# amountSavedInOBuffer is NULL => Mensaje de error
	li		a0,FILE_DESCRIPTOR_STDERR		# Cargo en a0 FILE_DESCRIPTOR_STDERR.
	la		a1,MENSAJE_ERROR_MEMORIA_AMOUNT_SAVED 	# Cargo en a1 la direccion de memoria donde se encuentra el mensaje a cargar.
	li		a2,BYTES_MENSAJE_ERROR_MEMORIA_AMOUNT_SAVED # Cargo en a2 la cantidad de bytes a escribir.
	li		v0, SYS_write
	syscall  		# No controlo error porque sale de por si de la funcion por error.
	
	# myfree(ibuffer)
	lw		a0,ibuffer  # Cargo en a0 ibuffer. Parametro de la funcion myfree.
	la		t9,myfree  # Cargo en t9 la direccion de la funcion myfree.
	jal		ra,t9  	# Ejecuto la funcion myfree.
	sw		zero,ibuffer  # Asigno NULL a ibuffer.
	
	# myfree(obuffer)
	lw		a0,obuffer  # Cargo en a0 obuffer. Parametro de la funcion myfree.
	la		t9,myfree  # Cargo en t9 la direccion de la funcion myfree.
	jal		ra,t9  	# Ejecuto la funcion myfree.
	sw		zero,obuffer  # Asigno NULL a obuffer.
	
	li		v0,ERROR_MEMORY  # Cargo en v0 el codigo de error.
	sw		v0,44($fp)
	b		$ReturnPalindrome
$ContinueProcessToLoadIBuffer:
	# amountSavedInOBuffer[0] = 0;
	lw		v0,24($fp)
	sw		zero,0(v0)

	# int rdoProcess = OKEY;
	sw		zero,28($fp)

	# int error = FALSE;
	sw		zero,32($fp)

	# int rdoLoadIBuffer = OKEY_I_FILE;
	li		v0,OKEY_I_FILE
	sw		v0,36($fp)
$WhilePalindrome:
	# (rdoLoadIBuffer == OKEY_I_FILE) ?
	lw		v1,36($fp)
	li		v0,OKEY_I_FILE
	bne		v1,v0,$CleanBuffersSincePalindrome	# If (rdoLoadIBuffer != OKEY_I_FILE) goto CleanBuffersSincePalindrome

	# (error == FALSE) ?
	lw		v0,32($fp)
	bne		v0,FALSE,$CleanBuffersSincePalindrome	# If (error != FALSE) goto CleanBuffersSincePalindrome

	# rdoLoadIBuffer = loadIBufferWithIFile(ibytes, ifd);
	lw		a0,68($fp)
	lw		a1,64($fp)
	la		t9,loadIBufferWithIFile
	jal		ra,t9
	sw		v0,36($fp)  # Cargo en la direccion 36($fp) el resultado de la funcion loadIBufferWithIFile, 
  		# que representaria a la variable rdoLoadIBuffer.
	
	# (ibuffer != NULL && ibuffer[0] != '\0') ?

	# (ibuffer != NULL) ?
	lw		v0,ibuffer
	beq		v0,DIR_NULL,$WhilePalindrome		# If (ibuffer == NULL) goto WhilePalindrome

	# (ibuffer[0] != '\0') ?
	lw		v0,ibuffer
	lb		v0,0(v0)
	beq		v0,zero,$WhilePalindrome		# If (ibuffer[0] == '\0') goto WhilePalindrome

	# int resultProcessWrite = processDataInIBuffer(ibuffer, amountSavedInOBuffer);
	lw		a0,ibuffer
	lw		a1,24($fp)
	la		t9,processDataInIBuffer
	jal		ra,t9
	sw		v0,40($fp)  # En la direccion 40($fp) guarda el resultado de la funcion processDataInIBuffer, 
    # que representa la variable resultProcessWrite.

	# (resultProcessWrite == LOAD_I_BUFFER) ?
	lw		v1,40($fp)
	li		v0,LOAD_I_BUFFER
	bne		v1,v0,$ContinueValidationResultProcessDataInIBuffer  # If (resultProcessWrite != LOAD_I_BUFFER) goto ContinueValidationResultProcessDataInIBuffer.

	# resultProcessWrite is equal LOAD_I_BUFFER
	
	# initializeBuffer(ibytes, ibuffer);
	lw		a0,68($fp)
	lw		a1,ibuffer
	la		t9,initializeBuffer
	jal		ra,t9  	# Ejecuto la funcion initializeBuffer.
$ContinueValidationResultProcessDataInIBuffer:
	# (resultProcessWrite == ERROR_MEMORY || resultProcessWrite == ERROR_WRITE) ?
	
	# resultProcessWrite == ERROR_MEMORY ?
	lw		v1,40($fp)  # Cargo en v1 resultProcessWrite.
	li		v0,ERROR_MEMORY
	beq		v1,v0,$LoadErrorOfExecutePalinWrite  	# If (resultProcessWrite == ERROR_MEMORY) goto LoadErrorOfExecutePalinWrite.

	# resultProcessWrite is not equal ERROR_MEMORY
	
	# resultProcessWrite == ERROR_WRITE ?
	lw		v1,40($fp)  # Cargo en v1 resultProcessWrite.
	li		v0,ERROR_WRITE
	beq		v1,v0,$LoadErrorOfExecutePalinWrite 	# If (resultProcessWrite == ERROR_WRITE) goto LoadErrorOfExecutePalinWrite.

	# No hay errores
	b		$WhilePalindrome
$LoadErrorOfExecutePalinWrite:
	li		v0,TRUE
	sw		v0,32($fp)  # Asigno a la variable error TRUE.

	# rdoProcess = resultProcessWrite;
	lw		v0,40($fp)  # Cargo en v0 resultProcessWrite.
	sw		v0,28($fp)  # Asigno a la variable rdoProcess resultProcessWrite.

	b		$WhilePalindrome			# Vuelvo a intentar entrar al loop.
$CleanBuffersSincePalindrome:
	# int rdoClean = cleanBuffers(amountSavedInOBuffer);
	lw		a0,24($fp)  # Cargo en a0 amountSavedInOBuffer. Parametro de la funcion cleanBuffers.
	la		t9,cleanBuffers
	jal		ra,t9  	# Ejecuto la funcion cleanBuffers.
	sw		v0,40($fp)  # Guardo en la direccion 40($fp) el resultado de ejecutar la funcion cleanBuffers. Seria rdoClean.

	lw		v0,24($fp)  # Cargo en v0 amountSavedInOBuffer.
	beq		v0,DIR_NULL,$VerifyResultClean		# if (amountSavedInOBuffer == NULL) goto VerifyResultClean.

	# free(amountSavedInOBuffer); amountSavedInOBuffer = NULL;
	lw		a0,24($fp)
	la		t9,myfree
	jal		ra,t9
	sw		zero,24($fp)
$VerifyResultClean:
	# (rdoClean != OKEY) ?
	lw		v0,40($fp)  # Cargo en v0 rdoClean.
	beq		v0,OKEY,$ReturnResultProcess		# if (rdoClean == OKEY) goto ReturnResultProcess
	lw		v0,40($fp)
	sw		v0,44($fp)  # Cargo en la direccion 44($fp) rdoClean
	b		$ReturnPalindrome
$ReturnResultProcess:
	lw		v0,28($fp)			
	sw		v0,44($fp)  # Cargo en la direccion 44($fp) rdoProcess
$ReturnPalindrome:
	lw		v0,44($fp)
	move		sp,$fp
	lw		ra,56(sp)
	lw		$fp,52(sp)
	addu		sp,sp,64
	j		ra
	.end		palindrome


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
	
	.globl	ibuffer
	.align	2
	.type	ibuffer, @object
	.size	ibuffer, 4
ibuffer:
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
