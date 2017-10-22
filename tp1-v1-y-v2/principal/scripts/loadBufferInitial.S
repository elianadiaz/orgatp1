#include <mips/regdef.h>
#include <sys/syscall.h>

#STATICS VAR DEFINITIONS

#define FILE_DESCRIPTOR_STDERR	2


# Size mensaje
#define BYTES_MENSAJE_ERROR_MEMORIA_BUFFER	59


##-----	loadBufferInitial -----##

	.align		2
	.globl		loadBufferInitial
	.ent		loadBufferInitial
loadBufferInitial:
	.frame		$fp,48,ra	
	.set		noreorder
	.cpload		t9
	.set		reorder

	#Stack frame creation
	subu		sp,sp,48
	.cprestore 16
	sw		ra,40(sp)
	sw		$fp,36(sp)
	sw		gp,32(sp)
	move		$fp,sp

	# Parameters
	sw		a0,48($fp)  # Guardo en la direccion de memoria 48($fp) la variable size (size_t size).
	sw		a1,52($fp)  # Guardo en la direccion de memoria 52($fp) la variable * buffer (char * buffer).

	lw		a0,48($fp)  # Cargo en a0 la variable size, parametro de mymalloc.
	la		t9,mymalloc
	jal		ra,t9  	# Ejecuto mymalloc.
	sw		v0,52($fp)  # Asigno la memoria reservada con mymalloc a buffer.

	lw		v0,52($fp)
	bne		v0,zero,$InitializeMemory		# If (buffer != NULL) goto InitializeMemory.

	# buffer is NULL => Mensaje de error
	li		a0,FILE_DESCRIPTOR_STDERR		# Cargo en a0 FILE_DESCRIPTOR_STDERR.
	la		a1,MENSAJE_ERROR_MEMORIA_BUFFER 	# Cargo en a1 la direccion de memoria donde se encuentra el mensaje a cargar.
	li		a2,BYTES_MENSAJE_ERROR_MEMORIA_BUFFER	# Cargo en a2 la cantidad de bytes a escribir.
	li		v0, SYS_write
	syscall  		# No controlo error porque sale de por si de la funcion con null y se controla error luego.
	
	sw		zero,24($fp)  # Guardo NULL en la direccion de memoria 24($fp).
	b		$ReturnLoadBufferInitial		# Salto al return de la funcion.
$InitializeMemory:
	lw		a0,48($fp)  # Cargo en a0 la variable size. Parametro de la funcion initializeBuffer.
	lw		a1,52($fp)  # Cargo en a0 la variable buffer. Parametro de la funcion initializeBuffer.
	la		t9,initializeBuffer
	jal		ra,t9  	# Ejecuto la funcion initializeBuffer.
	lw		v0,52($fp)  # Cargo en v0 la variable buffer.
	sw		v0,24($fp)  # Guardo buffer en la direccion de memoria 24($fp).
$ReturnLoadBufferInitial:
	lw		v0,24($fp)
	move		sp,$fp
	lw		ra,40(sp)
	lw		$fp,36(sp)
	addu		sp,sp,48
	j		ra
	.end		loadBufferInitial


## Mensajes de error

	.rdata	
	
	.align	2
MENSAJE_ERROR_MEMORIA_BUFFER:
	.ascii	"[Error] Hubo un error de asignacion de memoria (buffer)"
	.ascii	". \n\000"



