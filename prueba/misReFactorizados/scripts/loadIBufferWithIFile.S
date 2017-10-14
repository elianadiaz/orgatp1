#include <mips/regdef.h>
#include <sys/syscall.h>

#STATICS VAR DEFINITIONS

#define FALSE 			0
#define TRUE 			1
#define FILE_DESCRIPTOR_STDERR	2

# Resultados de funciones posibles
#define COMPLETE_DELIVERY	-1
#define END_I_FILE		-2
#define ERROR_I_READ		-3
#define OKEY_I_FILE		-4

# Size mensajes
#define BYTES_MENSAJE_ERROR_LECTURA_ARCHIVO	60


##-----	loadIBufferWithIFile -----##

	.align	2
	.globl		loadIBufferWithIFile
	.ent		loadIBufferWithIFile
loadIBufferWithIFile:
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
	sw		a0,64($fp)				# Guardo en la direccion de memoria 64($fp) la variable ibytes (size_t ibytes).
	sw		a1,68($fp)				# Guardo en la direccion de memoria 68($fp) la variable ifd (int ifd).

	sw		zero,24($fp)				# Guardo en la direccion 24($fp) cero, que representa a la variable completeDelivery.
	sw		zero,28($fp)				# Guardo en la direccion 28($fp) cero, que representa a la variable bytesReadAcum.
	lw		v0,64($fp)
	sw		v0,32($fp)				# Guardo en la direccion 32($fp) ibytes, que representa a la variable bytesToRead.
	sw		zero,36($fp)				# Guardo en la direccion 36($fp) cero, que representa a la variable end.

	# Lleno el buffer de entrada
$WhileLoadIBuffer:
	# (completeDelivery == FALSE) ?
	lw		v0,24($fp)				# Cargo en v0 completeDelivery.
	bne		v0,FALSE,$VerifyResultWhileLoadIBuffer  # If (completeDelivery != FALSE) goto VerifyResultWhileLoadIBuffer.

	# completeDelivery is FALSE
	
	# (end == FALSE) ?
	lw		v0,36($fp)				# Cargo en v0 end.
	bne		v0,FALSE,$VerifyResultWhileLoadIBuffer   # If (completeDelivery != FALSE) goto VerifyResultWhileLoadIBuffer.

	# Entre al while

	# int bytesRead = read(ifd, ibuffer + bytesReadAcum, bytesToRead);
	lw		v1,ibuffer
	lw		v0,28($fp)				# Cargo en v0 bytesReadAcum.
	addu		v0,v1,v0				# Guardo en v0 la direccion resultante de ibuffer+bytesReadAcum.
	lw		a0,68($fp)				# Cargo en v0 ifd.
	move		a1,v0					# Cargo en a1 ifd. Parametro de la funcion read.
	lw		a2,32($fp)				# Cargo en a2 bytesToRead. Parametro de la funcion read.
	
	li		v0, SYS_read
	syscall						# Seria read: int bytesRead = read(ifd, ibuffer + bytesReadAcum, bytesToRead);
	
	# Controlo errores y cantidad de bytes leidos. v0 contiene el numero de caracteres leidos (es negativo si hubo error y es 0 si llego a fin del archivo).

	sw		v0,40($fp)			# Guardo en la direccion de memoria 40($fd) el resultado de la funcion read, que 
							# estaria representado por la variable bytesRead.
	
	# bytesRead == -1 ?
	lw		v1,40($fp)			# Cargo en v1 bytesRead.
	li		v0,-1					# Cargo en v0 -1 para la comparacion.
	bne		v1,v0,$ContinueValidationResultRead 	# If (bytesRead != -1) goto ContinueValidationResultRead.
	
	# bytesRead is -1 => Mensaje de error.
	li		a0,FILE_DESCRIPTOR_STDERR		# Cargo en a0 FILE_DESCRIPTOR_STDERR.
	la		a1,MENSAJE_ERROR_LECTURA_ARCHIVO 	# Cargo en a1 la direccion de memoria donde se encuentra el mensaje a cargar.
	li		a2,BYTES_MENSAJE_ERROR_LECTURA_ARCHIVO	# Cargo en a2 la cantidad de bytes a escribir.
	li		v0, SYS_write
	syscall						# No controlo error porque sale de por si de la funcion por error.
	
	li		v0,ERROR_I_READ
	sw		v0,44($fp)			# Guardo el codigo de error en la direccion 44($fp).
	b		$ReturnLoadIBufferWithIFile 	# Salto incondicional al return de la funcion.
$ContinueValidationResultRead:
	lw		v0,40($fp)			# Cargo en v1 bytesRead.
	bne		v0,zero,$ContinueAccumulatingBytesRead 	# If (bytesRead != 0) goto ContinueAccumulatingBytesRead
	li		v0,TRUE
	sw		v0,36($fp)				# Asigno a la variable end, guardada en 36($fp), TRUE.
$ContinueAccumulatingBytesRead:
	# bytesReadAcum += bytesRead;
	lw		v1,28($fp)				# Cargo en v1 bytesReadAcum.
	lw		v0,40($fp)				# Cargo en v0 bytesRead.
	addu		v0,v1,v0				# Sumo bytesReadAcum con bytesRead y guardo resultado en v0.
	sw		v0,28($fp)				# Guardo el resultado de la suma en bytesReadAcum.

	# bytesToRead = ibytes - bytesReadAcum;
	lw		v1,64($fp)				# Cargo en v1 ibytes.
	lw		v0,28($fp)				# Cargo en v0 bytesReadAcum.
	subu		v0,v1,v0				# Resto ibytes con bytesReadAcum y guardo resultado en v0, para saber cuandos bytes restan por leer del archivo.
	sw		v0,32($fp)				# Asigno a bytesToRead el resultado de la resta.

	# bytesToRead == 0 ?
	lw		v0,52($fp)				# Cargo en v0 bytesToRead.
	bne		v0,zero,$WhileLoadIBuffer		# If (bytesToRead != 0) goto WhileLoadIBuffer

	# bytesToRead is 0.
	li		v0,TRUE
	sw		v0,24($fp)				# Asigno a completeDelivery TRUE.
	b		$WhileLoadIBuffer			# Salto incondicional al comienzo del while para cargar el buffer con los datos 
								# del archivo (goto WhileLoadIBuffer).
$VerifyResultWhileLoadIBuffer:
	lw		v1,36($fp)				# Cargo en v1 end.
	li		v0,TRUE
	bne		v1,v0,$ReturnFunctionOkey		# If (end != TRUE) goto ReturnFunctionOkey

	li		v0,END_I_FILE
	sw		v0,44($fp)				# Guardo codigo de error en la direccion de memoria 44($fp).
	b		$ReturnLoadIBufferWithIFile
$ReturnFunctionOkey:
	li		v0,OKEY_I_FILE
	sw		v0,44($fp)				# Guardo codigo de error en la direccion de memoria 44($fp).
$ReturnLoadIBufferWithIFile:
	lw		v0,44($fp)
	move		sp,$fp
	lw		ra,56(sp)
	lw		$fp,52(sp)
	addu		sp,sp,64
	j		ra
	.end		loadIBufferWithIFile


## Mensajes de error

	.rdata
	
	.align	2
MENSAJE_ERROR_LECTURA_ARCHIVO:
	.ascii	"[Error] Hubo un error en la lectura de datos del archivo"
	.ascii	". \n\000"


