#include <mips/regdef.h>
#include <sys/syscall.h>

#STATICS VAR DEFINITIONS

#define FALSE 			0
#define TRUE 			1
#define DIR_NULL 		0

##-----	myRealloc -----##

	.align		2
	.globl		myRealloc
	.ent		myRealloc
myRealloc:
	.frame		$fp,56,ra
	.set		noreorder
	.cpload		t9
	.set		reorder
	
	#Stack frame creation
	subu		sp,sp,56
	
	.cprestore 16 #VER PARA QUE SIRVE
	sw		ra,48(sp)
	sw		$fp,44(sp)
	sw		gp,40(sp)
	move		$fp,sp
	
	# Parameters
	sw		a0,56($fp)  # Guardo en la direccion de memoria 56($fp) la variable ptr (void * ptr).
	sw		a1,60($fp)  # Guardo en la direccion de memoria 60($fp) la variable tamanyoNew (size_t tamanyoNew).
	sw		a2,64($fp)  # Guardo en la direccion de memoria 64($fp) la variable tamanyoOld (int tamanyoOld).
	
	lw		v0,60($fp)  # Cargo en v0 el contenido de la variable tamanyoNew, que esta en la direccion de memoria 60($fp)
	bne		v0,zero,$MyReallocContinueValidations   # If (tamanyoNew != 0) goto MyReallocContinueValidations
	
	# If (tamanyoNew == 0)
	lw		a0,56($fp)  # Cargo en a0 la direccion de memoria guardada en la direccion 56($fp), o sea, la variable * ptr.
	la		t9,myfree  # Cargo la direccion de la funcion myfree.
	jal		ra,t9  	# Ejecuto la funcion myfree.
	sw		zero,56($fp)  # Coloco el puntero apuntando a NULL (ptr = NULL;).
	sw		zero,32($fp)  # Coloco en la direccion de memoria 32($fp) NULL, que seria el resultado de la funcion myRealloc.
	b		$MyReallocReturn			# Salto incondicional para retornar resultado de myRealloc.
$MyReallocContinueValidations:
	lw		a0,60($fp)  # Cargo en a0 el contenido guardado en la direccion 60($fp), o sea, la variable tamanyoNew.
	la		t9,mymalloc  # Cargo la direccion de la funcion mymalloc.
	jal		ra,t9  	# Ejecuto la funcion mymalloc.
	sw		v0,16($fp)  # Guardo en la direccion 16($fp) el contenido de v0, que seria la direccion de la memoria asignada con mymalloc.
	lw		v0,16($fp)  # Cargo en v0 la direccion de la memoria asignada con mymalloc (void * ptrNew = (void *) mymalloc(tamanyoNew);).
	
	# (ptrNew == NULL) ?
	bne		v0,DIR_NULL,$MyReallocContinueValidationsWithMemory # If (ptrNew != NULL) goto MyReallocContinueValidationsWithMemory	
	sw		zero,32($fp)  # Coloco en la direccion de memoria 32($fp) NULL, que seria el resultado de la funcion myRealloc.
	b		$MyReallocReturn			# Salto incondicional para retornar resultado de myRealloc.
$MyReallocContinueValidationsWithMemory:
	lw		v0,56($fp)  # Cargo en v0 la direccion de memoria guardada en la direccion 56($fp), o sea, la variable * ptr.
	bne		v0,DIR_NULL,$MyReallocContinueWithLoadCharacters # If (ptr != NULL) goto MyReallocContinueWithLoadCharacters
	
	# (ptr == NULL) ?
	lw		v0,16($fp)  # Cargo en v0 la direccion de memoria guardada en la direccion 16($fp), o sea, la variable * ptrNew, 
    # que seria la direccion de la memoria asignada con mymalloc.
	sw		v0,32($fp)  # Coloco en la direccion de memoria 32($fp) el contenido de v0 (* ptrNew), que seria el resultado de la funcion myRealloc.
	b		$MyReallocReturn			# Salto incondicional para retornar resultado de myRealloc.
$MyReallocContinueWithLoadCharacters:
	lw		v0,60($fp)  # Cargo en v0 el contenido guardado en la direccion 60($fp), o sea, la variable tamanyoNew.
	sw		v0,20($fp)  # Guardo en la direccion de memoria 20($fp) la variable tamanyoNew guardada en v0 (int end = tamanyoNew;). 
	
	lw		v1,64($fp)  # Cargo en v1 el contenido guardado en la direccion 64($fp), o sea, la variable tamanyoOld.
	lw		v0,60($fp)  # Cargo en v0 el contenido guardado en la direccion 60($fp), o sea, la variable tamanyoNew, para poder luego hacer comparacion.
	
	# (tamanyoOld < tamanyoNew) ?
	sltu		v0,v1,v0  # Compara el contenido de la variable tamanyoOld (v1) con tamanyoNew (v0), y guarda true en v0 si 
    # el primero (tamanyoOld) es mas chico que el segundo (tamanyoNew). 
	beq		v0,FALSE,$MyReallocLoadCharacters 	# If (tamanyoOld >= tamanyoNew) goto MyReallocLoadCharacters
	lw		v0,64($fp)  # Cargo en v0 el contenido guardado en la direccion 64($fp), o sea, la variable tamanyoOld.
	sw		v0,20($fp)  # Guardo en la direccion 20($fp), que seria la variable end, el contenido de la variable tamanyoOld (end = tamanyoOld;).
$MyReallocLoadCharacters:
	lw		v0,16($fp)  # Cargo en v0 el contenido guardado en la direccion 16($fp), o sea, la variable ptrNew.
	sw		v0,24($fp)  # Guardo en la direccion de memoria 16($fp) el contenido de v0 (char *tmp = ptrNew;).
	lw		v0,56($fp)  # Cargo en v0 el contenido guardado en la direccion 56($fp), o sea, la variable ptr.
	sw		v0,28($fp)  # Guardo en la direccion de memoria 28($fp) el contenido de v0 (const char *src   = ptr;).
$MyReallocWhileLoadCharacter:
	lw		v0,20($fp)  # Cargo en v0 el contenido guardado en la direccion 20($fp), o sea, la variable end.
	addu		v0,v0,-1  # Decremento en 1 el contenido de v0 (end --).
	move		v1,v0  	# Muevo el contenido de v0 a v1.
	sw		v1,20($fp)  # Guardo en la direccion de memoria 20($fp), que seria en donde estaba end, el nuevo valor de end (habia sido decrementado en 1).
	li		v0,-1  	# Cargo en v0 el literal -1.
	bne		v1,v0,$MyReallocContinueWhileLoad	# If ( end != -1) goto MyReallocContinueWhileLoad.
	b		$MyReallocFinalizedWhileLoad		# Salto incondicional fuera del while, porque la variable end es -1.
$MyReallocContinueWhileLoad:
	# *tmp = *src;
	lw		v1,24($fp)  # Cargo en v1 el contenido guardado en la direccion 24($fp), que seria *tmp.
	lw		v0,28($fp)  # Cargo en v0 el contenido guardado en la direccion 28($fp), que seria *src.
	lbu		v0,0(v0)  # Cargo la direccion de memoria en v0 de src.
	sb		v0,0(v1)  # Guardo en la direccion apuntada por el contenido de v1, la direccion de memoria guardada en v0 (*tmp = *src;).
	
	# tmp ++
	lw		v0,24($fp)  # Cargo en v0 el contenido guardado en la direccion 24($fp), que seria *tmp.
	addu		v0,v0,1  	# Incremento en 1 el contenido guardado en v0 (tmp ++).
	sw		v0,24($fp)  # Guardo en la direccion de memoria 24($fp) lo que tenia v0 (el resultado de hacer tmp ++).
	
	# src ++
	lw		v0,28($fp)  # Cargo en v0 el contenido guardado en la direccion 28($fp), que seria *src.
	addu		v0,v0,1  	# Incremento en 1 el contenido guardado en v0 (src ++).
	sw		v0,28($fp)  # Guardo en la direccion de memoria 28($fp) lo que tenia v0 (el resultado de hacer src ++).
	
	b		$MyReallocWhileLoadCharacter    	# Vuelvo a entrar al while
$MyReallocFinalizedWhileLoad:
	lw		a0,56($fp)  # Cargo en v0 el contenido guardado en la direccion 56($fp), que seria *ptr.
	la		t9,myfree  # Cargo la direccion de la funcion myfree.
	jal		ra,t9  	# Ejecuto la funcion myfree.
	sw		zero,56($fp)  # Coloco el puntero apuntando a NULL (ptr = NULL;).
	
	lw		v0,16($fp)  # Cargo en v0 la direccion de memoria guardada en la direccion 16($fp), o sea, la variable * ptrNew, que seria 
    # la direccion de la memoria asignada con mymalloc..
	sw		v0,32($fp)  # Guardo en la direccion de memoria 32($fp) el contenido de v0 (* ptrNew), que seria el resultado de la funcion myRealloc.		
$MyReallocReturn:
	lw		v0,32($fp)  # Cargo en v0 el resultado de la funcion myRealloc guardado en la direccion de memoria 32($fp).
	move		sp,$fp
	lw		ra,48(sp)
	lw		$fp,44(sp)
	addu		sp,sp,56
	j		ra  	# Jump and return
	.end		myRealloc
