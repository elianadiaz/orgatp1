#include <mips/regdef.h>
#include <sys/syscall.h>

#STATICS VAR DEFINITIONS

#define FALSE 			0
#define TRUE 			1


##-----	initializeBuffer -----##

	.align		2
	.globl		initializeBuffer
	.ent		initializeBuffer
initializeBuffer:
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
	
	# Parameters
	sw		a0,24($fp)  # Guardo en la direccion de memoria 24($fp) la variable bytes (size_t bytes).
	sw		a1,28($fp)  # Guardo en la direccion de memoria 28($fp) la variable buffer (char * buffer).
	
	sw		zero,8($fp)  # Guardo en la direccion de memoria 8($fp) el contenido 0, que seria la variable i (int i;).
$ForInitializeBuffer:
	lw		v0,8($fp)  # Cargo en v0 el contenido en la direccion de memoria 8($fp), que seria la variable i.
	lw		v1,24($fp)  # Cargo en v1 el contenido en la direccion de memoria 24($fp), que seria la variable bytes.
	sltu		v0,v0,v1  # Comparo i (v0) con bytes (v1). Si i < bytes, guardo TRUE en v0, sino guardo FALSE.
	bne		v0,FALSE,$ForInitializeCharacter 	# If (i < bytes) goto ForInitializeCharacter.
	b		$InitializeBufferReturn			# Salto incondicional al return de la funcion initializeBuffer.
$ForInitializeCharacter:
	# buffer[i] = '\0';
	lw		v1,28($fp)  # Cargo en v1 el contenido en la direccion de memoria 28($fp), que seria la variable * buffer.
	lw		v0,8($fp)  # Cargo en v0 el contenido en la direccion de memoria 8($fp), que seria la variable i.
	addu		v0,v1,v0  # Me corro en el buffer la cantidad estipulada por la variable i (buffer[i] = buffer + i), y lo guardo en v0.
	sb		zero,0(v0)  # Guardo '\0' = 0 en la posicion del buffer estipulada previamente (buffer[i] = '\0';).
	
	# ++ i
	lw		v0,8($fp)  # Cargo en v0 el contenido en la direccion de memoria 8($fp), que seria la variable i.
	addu		v0,v0,1  	# Incremento en 1 la variable i (i ++).
	sw		v0,8($fp)  # Guardo en la direccion de memoria 8($fp) el nuevo valor de la variable i.
	
	b		$ForInitializeBuffer			# Vuelvo a entrar en el for (bucle).
$InitializeBufferReturn:
	move		sp,$fp
	lw		$fp,20(sp)
	addu		sp,sp,24
	j		ra  	# Jump and return
	.end		initializeBuffer


