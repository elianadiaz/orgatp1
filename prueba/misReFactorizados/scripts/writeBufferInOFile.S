#include <mips/regdef.h>
#include <sys/syscall.h>

#STATICS VAR DEFINITIONS

#define FALSE 			0
#define TRUE 			1

# Resultados de funciones posibles
#define OKEY			0
#define	ERROR_WRITE		4


##-----	writeBufferInOFile -----##

	.align		2
	.globl		writeBufferInOFile
	.ent		writeBufferInOFile
writeBufferInOFile:
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
	
	# Parameter
	sw		a0,64($fp)				# Guardo en la direccion de memoria 64($fp) la variable * amountSavedInOBuffer (int * amountSavedInOBuffer).
	sw		a1,68($fp)				# Guardo en la direccion de memoria 68($fp) la variable * buffer (char * buffer).	
	
	sw		zero,24($fp)				# Guardo en la direccion de memoria 24($fp) la variable completeDelivery inicializada en FALSE (int completeDelivery = FALSE;).
	sw		zero,28($fp)				# Guardo en la direccion de memoria 28($fp) la variable bytesWriteAcum inicializada en 0 (int bytesWriteAcum = 0;).
	
	lw		v0,64($fp)				# Cargo en v0 el contenido de la direccion de memoria 64($fp), que seria la variable * amountSavedInOBuffer. 
	lw		v0,0(v0)				# Cargo la direccion de memoria del contenido en v0.
	sw		v0,32($fp)				# Guardo en la direccion de memoria 32($fp) la direccion de memoria de la variable 
								# amountSavedInOBuffer (int bytesToWrite = (*amountSavedInOBuffer);).
$WhileWriteBufferInOFile:
	lw		v0,24($fp)				# Cargo en v0 el contenido de la direccion de memoria 24($fp), que seria la variable completeDelivery.
	beq		v0,FALSE,$GoInWhileWriteBufferInOFile  # Si completeDelivery es FALSE (todavia no se guardaron todos los datos cargados en el buffer en el archivo) 
								# entro al while para continuar la bajada de los datos al buffer.
	b		$WriteBufferInOFileReturnOkey  	# Salto incondicional para retornar OKEY como resultado del proceso de escritura en el archivo de salida.
$GoInWhileWriteBufferInOFile:
	# obuffer + bytesWriteAcum
	lw		v1,68($fp)				# Cargo en v1 buffer.
	lw		v0,28($fp)				# Cargo en v0 el contenido de la direccion de memoria 28($fp), que es la variable bytesWriteAcum.
	addu		v0,v1,v0				# Sumo la direccion de obuffer con el contenido de bytesWriteAcum, y lo guardo en v0.
	
	lw		a0,oFileDescriptor			# Cargo en a0 la variable oFileDescriptor.
	
	move		a1,v0					# Muevo el contenido de v0 (corrimiento de direccion de memoria sobre obuffer) en a1.
	
	lw		a2,32($fp)				# Cargo en a2 el contenido de la direccion de memoria 32($fp), que seria la variable bytesToWrite.
	
	li		v0, SYS_write
	syscall				# Seria write: int bytesWrite = write(oFileDescriptor, obuffer + bytesWriteAcum, bytesToWrite);
	
	# Chequeo errores. v0 contiene el numero de caracteres escrito (es negativo si hubo error).
	sw		v0,36($fp)				# Guardo en la direccion de memoria 36($fp) la cantidad de bytes escritos efectivamente en el archivo de salida, que esta en v0.
	lw		v0,36($fp)				# Cargo en v0 la cantidad de bytes escritos (bytesWrite).
	bgez		v0,$ContinueWriteBufferInOFile 	# Si la cantidad de bytes escritos (bytesWrite) es mas grande que 0, salto a continuar escribiendo 
								# en el archivo si es necesario (ContinueWriteBufferInOFile).
	
	# Hubo un error (la cantidad de caracteres escritos es menor a 0, valor negativo).
	li		v0,ERROR_WRITE				# Cargo en v0 el resultado de la funcion, que seria un codigo de error (ERROR_WRITE).
	sw		v0,40($fp)				# Guardo en la direccion de memoria 40($fp) el resultado de la funcion que estaba en v0 (ERROR_WRITE).
	b		$WriteBufferInOFileReturn		# Salto incondicional al final de la funcion, al return.
$ContinueWriteBufferInOFile:
	# bytesWriteAcum += bytesWrite;
	lw		v1,28($fp)				# Cargo en v1 el contenido de la direccion de memoria 28($fp), que seria la variable bytesWriteAcum.
	lw		v0,36($fp)				# Cargo en v0 el contenido de la direccion de memoria 36($fp), que seria la variable bytesWrite.
	addu		v0,v1,v0				# Sumo el contenido de v1 (bytesWriteAcum) y el contenido de v0 (bytesWrite), y guardo el resultado en v0.
	sw		v0,28($fp)				# Guardo en la direccion de memoria 28($fp) el contenido de v0, que seria el resultado de la suma (bytesWriteAcum += bytesWrite;).
	
	# bytesToWrite = (*amountSavedInOBuffer) - bytesWriteAcum;
	lw		v0,64($fp)				# Cargo en v0 el contenido de la direccion de memoria 64($fp), que seria la variable *amountSavedInOBuffer (una direccion de memoria).
	lw		v1,0(v0)				# Cargo lo contenido en la direccion de memoria guardada en v0 en v1 (ammountSavedInOBuffer es un puntero).
	lw		v0,28($fp)				# Cargo en v0 el contenido de la direccion de memoria 28($fp), que seria la variable bytesWriteAcum.
	subu		v0,v1,v0				# Resto el contenido de v1 (*amountSavedInOBuffer) con el contenido de v0 (bytesWriteAcum), y guardo el resultado en v0.
	sw		v0,32($fp)				# Guardo el resultado de la resta en la direccion de memoria 32($fp), que seria la variable bytesToWrite.
	
	lw		v0,32($fp)				# Cargo en v0 el contenido de la direccion de memoria 32($fp), que seria la variable bytesToWrite.
	bgtz		v0,$WhileWriteBufferInOFile   		# Si bytesToWrite es mayor a cero, salto a WhileWriteBufferInOFile (vuelvo a entrar al loop while).
	# (bytesToWrite <= 0) ? then:
	li		v0,TRUE					# Cargo en v0 el literal TRUE (que es 1).
	sw		v0,24($fp)				# Guardo en la direccion de memoria 24($fp) el contenido de v0. O sea, completeDelivery = TRUE;
	b		$WhileWriteBufferInOFile		# Salto incondicional al inicio del loop.
$WriteBufferInOFileReturnOkey:
	sw		zero,40($fp)				# Guardo en la direccion de memoria 40($fp) el resultado OKEY (resultado de la funcion writeBufferInOFile).
$WriteBufferInOFileReturn:
	lw		v0,40($fp)				# Cargo el resultado de la funcion writeBufferInOFile, que estaba en la direccion de memoria 40($fp), en el registro v0.
	move		sp,$fp
	lw		ra,56(sp)
	lw		$fp,52(sp)
	addu		sp,sp,64
	j		ra					# Jump and return
	.end		writeBufferInOFile



