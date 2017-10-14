#include <mips/regdef.h>
#include <sys/syscall.h>

#STATICS VAR DEFINITIONS

#define FALSE 			0
#define TRUE 			1
#define FILE_DESCRIPTOR_STDERR	2
#define LEXICO_BUFFER_SIZE 	10

# Resultados de funciones posibles
#define ERROR_MEMORY		2

# Size mensajes
#define BYTES_MENSAJE_ERROR_MEMORIA_LEXICO	45



##-----	loadInLexico -----##

	.align		2
	.globl		loadInLexico
	.ent		loadInLexico
loadInLexico:
	.frame		$fp,56,ra
	.set		noreorder
	.cpload		t9
	.set		reorder

	#Stack frame creation
	subu		sp,sp,56

	.cprestore 16
	sw		ra,48(sp)
	sw		$fp,44(sp)
	sw		gp,40(sp)
	move		$fp,sp
	move		v0,a0

	# Parameter
	sb		v0,24($fp)  # Guardo en la direccion de memoria 24($fp) la variable character (char character).
	lw		v0,lexico  # Cargo en v0 la variable lexico.
	bne		v0,zero,$VerifyIfReallocLexico
	li		a0,LEXICO_BUFFER_SIZE			
	la		t9,mymalloc
	jal		ra,t9
	sw		v0,lexico
	li		v0,LEXICO_BUFFER_SIZE
	sw		v0,bytesLexico  # Guardo LEXICO_BUFFER_SIZE en la variable bytesLexico.
	b		$VerifyIfCanLoadInLexico
$VerifyIfReallocLexico:
	# (quantityCharacterInLexico >= bytesLexico) ?
	lw		v0,quantityCharacterInLexico
	lw		v1,bytesLexico
	slt		v0,v0,v1  # Guarda en v0 TRUE si quantityCharacterInLexico < bytesLexico, sino guarda FALSE
	bne		v0,zero,$VerifyIfCanLoadInLexico	# If (quantityCharacterInLexico < bytesLexico) goto VerifyIfCanLoadInLexico.
    # Se va por el negativo para no tener que alocar memoria para guardar TRUE.

	# quantityCharacterInLexico >= bytesLexico

	# bytesLexico += LEXICO_BUFFER_SIZE;
	lw		v0,bytesLexico
	sw		v0,28($fp)
	lw		v0,bytesLexico
	addu		v0,v0,LEXICO_BUFFER_SIZE
	sw		v0,bytesLexico

	# lexico = myRealloc(lexico, bytesLexico*sizeof(char), bytesLexicoPreview);
	lw		a0,lexico
	lw		a1,bytesLexico
	lw		a2,28($fp)
	la		t9,myRealloc
	jal		ra,t9
	sw		v0,lexico	
$VerifyIfCanLoadInLexico:
	lw		v0,lexico
	bne		v0,zero,$LoadCharacterInLexico		# If (lexico != NULL) goto LoadCharacterInLexico.

	# Hubo problemas alocando memoria => Mensaje de error
	li		a0,FILE_DESCRIPTOR_STDERR		# Cargo en a0 FILE_DESCRIPTOR_STDERR.
	la		a1,MENSAJE_ERROR_MEMORIA_LEXICO 	# Cargo en a1 la direccion de memoria donde se encuentra el mensaje a cargar.
	li		a2,BYTES_MENSAJE_ERROR_MEMORIA_LEXICO	# Cargo en a2 la cantidad de bytes a escribir.
	li		v0, SYS_write
	syscall  		# No controlo error porque sale de por si de la funcion por error.

	li		v0,ERROR_MEMORY
	sw		v0,32($fp)  # Guardo el codigo de error (en v0) en la direccion de memoria 32($fp).
	b		$ReturnLoadInLexico			# Salto incondicional al return de la funcion (goto ReturnLoadInLexico).
$LoadCharacterInLexico:
	# lexico[quantityCharacterInLexico] = character;
	lw		v1,lexico
	lw		v0,quantityCharacterInLexico
	addu		v1,v1,v0  # Me corro en la memoria de lexico para guardar nuevo dato, guardo el dato en v1: 
    # lexico + quantityCharacterInLexico = lexico[quantityCharacterInLexico]
	lbu		v0,24($fp)  # Cargo en v0 el caracter a guardar (variable character).
	sb		v0,0(v1)  # Guardo en la direccion apuntada por v1 el caracter guardado en v0.

	# quantityCharacterInLexico ++;
	lw		v0,quantityCharacterInLexico		
	addu		v0,v0,1  	# Incremento en 1 el valor de quantityCharacterInLexico.
	sw		v0,quantityCharacterInLexico		

	# return OKEY;
	sw		zero,32($fp)  # Guardo OKEY (= 0) en la direccion de memoria 32($fp).
$ReturnLoadInLexico:
	lw		v0,32($fp)
	move		sp,$fp
	lw		ra,48(sp)
	lw		$fp,44(sp)
	addu		sp,sp,56
	j		ra
	.end		loadInLexico


## Mensajes de error

	.rdata

	.align	2
MENSAJE_ERROR_MEMORIA_LEXICO:
	.ascii	"[Error] Hubo un error en memoria (lexico). \n\000"
