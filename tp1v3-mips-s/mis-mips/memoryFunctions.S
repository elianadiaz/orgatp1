#include <mips/regdef.h>
#include <sys/syscall.h>

#define MYMALLOC_SIGNATURE 0xdeadbeef
#define MYMALLOC_SIGNATURE 0xdeadbeef

#ifndef PROT_READ
#define PROT_READ 0x01
#endif

#ifndef PROT_WRITE
#define PROT_WRITE 0x02
#endif

#ifndef MAP_PRIVATE
#define MAP_PRIVATE 0x02
#endif

#ifndef MAP_ANON
#define MAP_ANON 0x1000
#endif


##-----	myfree -----##

	.globl	myfree
	.ent	myfree
myfree:
	subu	sp, sp, 40
	sw	ra, 32(sp)
	sw	$fp, 28(sp)
	sw	a0, 24(sp)  # Temporary: argument pointer.
	sw	a0, 20(sp)  # Temporary: actual mmap(2) pointer.
	move	$fp, sp

	# Calculate the actual mmap(2) pointer.
	#
	lw	t0, 24(sp)
	subu	t0, t0, 8
	sw	t0, 20(sp)

	# XXX Sanity check: the argument pointer must be checked
	# in before we try to release the memory block.
	#
	# First, check the allocation signature.
	#
	lw	t0, 20(sp) # t0: actual mmap(2) pointer.
	lw	t1, 0(t0)
	bne	t1, MYMALLOC_SIGNATURE, myfree_die

	# Second, check the memory block trailer.
	#
	lw	t0, 20(sp) # t0: actual mmap(2) pointer.
	lw	t1, 4(t0)  # t1: actual mmap(2) block size.
	addu	t2, t0, t1 # t2: trailer pointer.
	lw	t3, -4(t2)
	xor	t3, t3, t1
	bne	t3, MYMALLOC_SIGNATURE, myfree_die

	# All checks passed. Try to free this memory area.
	#
	li	v0, SYS_munmap
	lw	a0, 20(sp) # a0: actual mmap(2) pointer.
	lw	a1, 4(a0)  # a1: actual allocation size.
	syscall

	# Bail out if we cannot unmap this memory block.
	#
	bnez	v0, myfree_die

	# Success.
	#
	j myfree_return

myfree_die:
	# Generate a segmentation fault by writing to the first
	# byte of the address space (a.k.a. the NULL pointer).
	#
	sw t0, 0(zero)

myfree_return:
	# Destroy the stack frame.
	#
	move	sp, $fp
	lw	ra, 32(sp)
	lw	$fp, 28(sp)
	addu	sp, sp, 40

	j	ra
	.end	myfree



##-----	mymalloc -----##

	.text
	.align	2
	.globl	mymalloc
	.ent	mymalloc
mymalloc:
	subu	sp, sp, 56
	sw	ra, 48(sp)
	sw	$fp, 44(sp)
	sw	a0, 40(sp)  # Temporary: original allocation size.
	sw	a0, 36(sp)  # Temporary: actual allocation size.
	li	t0, -1
	sw	t0, 32(sp)  # Temporary: return value (defaults to -1).
#if 0
	sw	a0, 28(sp)  # Argument building area (#8?).
	sw	a0, 24(sp)  # Argument building area (#7?).
	sw	a0, 20(sp)  # Argument building area (#6).
	sw	a0, 16(sp)  # Argument building area (#5).
	sw	a0, 12(sp)  # Argument building area (#4, a3).
	sw	a0,  8(sp)  # Argument building area (#3, a2).
	sw	a0,  4(sp)  # Argument building area (#2, a1).
	sw	a0,  0(sp)  # Argument building area (#1, a0).
#endif
	move	$fp, sp

	# Adjust the original allocation size to a 4-byte boundary.
	#
	lw	t0, 40(sp)
	addiu	t0, t0, 3
	and	t0, t0, 0xfffffffc
	sw	t0, 40(sp)

	# Increment the allocation size by 12 units, in order to 
	# make room for the allocation signature, block size and
	# trailer information.
	#
	lw	t0, 40(sp)
	addiu	t0, t0, 12
	sw	t0, 36(sp)

	# mmap(0, sz, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANON, -1, 0)
	#
	li	v0, SYS_mmap
	li	a0, 0
	lw	a1, 36(sp)
	li	a2, PROT_READ|PROT_WRITE
	li	a3, MAP_PRIVATE|MAP_ANON

	# According to mmap(2), the file descriptor 
	# must be specified as -1 when using MAP_ANON.
	#
	li	t0, -1
	sw	t0, 16(sp)

	# Use a trivial offset.
	#
	li	t0, 0
	sw	t0, 20(sp)

	# XXX TODO.
	#
	sw	zero, 24(sp)
	sw	zero, 28(sp)

	# Excecute the syscall, save the return value.
	#
	syscall
	sw	v0, 32(sp)
	beqz	v0, mymalloc_return

	# Success. Check out the allocated pointer.
	#
	lw	t0, 32(sp)
	li	t1, MYMALLOC_SIGNATURE
	sw	t1, 0(t0)

	# The actual allocation size goes right after the signature.
	#
	lw	t0, 32(sp)
	lw	t1, 36(sp)
	sw	t1,  4(t0)

	# Trailer information.
	#
	lw	t0, 36(sp) # t0: actual allocation size.
	lw	t1, 32(sp) # t1: Pointer.
	addu	t1, t1, t0 # t1 now points to the trailing 4-byte area.
	xor	t2, t0, MYMALLOC_SIGNATURE
	sw	t2, -4(t1)

	# Increment the result pointer.
	#
	lw	t0, 32(sp)
	addiu	t0, t0, 8
	sw	t0, 32(sp)

mymalloc_return:
	# Restore the return value.
	#
	lw	v0, 32(sp)

	# Destroy the stack frame.
	#
	move	sp, $fp
	lw		ra, 48(sp)
	lw		$fp, 44(sp)
	addu	sp, sp, 56

	j		ra
	.end	mymalloc



##-----	myRealloc -----##

	.align	2
	.globl	myRealloc
	.ent	myRealloc
myRealloc:
	.frame	$fp,64,ra
	.set	noreorder
	.cpload	t9
	.set	reorder
	
	#Stack frame creation
	subu	sp,sp,64
	
	.cprestore 16
	sw	ra,56(sp)
	sw	$fp,52(sp)
	sw	gp,48(sp)
	move	$fp,sp
	
	# Parameters
	sw	a0,64($fp)  # Guardo en la direccion de memoria 
                            # 64($fp) la variable ptr (void * ptr).
	sw	a1,68($fp)  # Guardo en la direccion de memoria 68($fp) 
                            # la variable tamanyoNew (size_t tamanyoNew).
	sw	a2,72($fp)  # Guardo en la direccion de memoria 72($fp) 
                            # la variable tamanyoOld (int tamanyoOld).
	
	lw	v0,68($fp)  # Cargo en v0 el contenido de la variable tamanyoNew, 
                            # que esta en la direccion de memoria 68($fp)
	bne	v0,zero,$MyReallocContinueValidations # If (tamanyoNew != 0) goto MyReallocContinueValidations
	
	# If (tamanyoNew == 0)
	lw	a0,64($fp)  # Cargo en a0 la direccion de memoria guardada 
                            # en la direccion 64($fp), o sea, la variable * ptr.
	la	t9,myfree   # Cargo la direccion de la funcion myfree.
	jal	ra,t9  	    # Ejecuto la funcion myfree.
	sw	zero,64($fp)  # Coloco el puntero apuntando a NULL (ptr = NULL;).
	sw	zero,40($fp)  # Coloco en la direccion de memoria 40($fp) NULL, 
                              # que seria el resultado de la funcion myRealloc.
	b	$MyReallocReturn # Salto incondicional para retornar resultado de myRealloc.
$MyReallocContinueValidations:
	lw	a0,68($fp)  # Cargo en a0 el contenido guardado en la direccion
                            # 68($fp), o sea, la variable tamanyoNew.
	la	t9,mymalloc  # Cargo la direccion de la funcion mymalloc.
	jal	ra,t9  	     # Ejecuto la funcion mymalloc.
	sw	v0,24($fp)  # Guardo en la direccion 24($fp) el contenido de v0, que 
                            # seria la direccion de la memoria asignada con mymalloc.
	lw	v0,24($fp)  # Cargo en v0 la direccion de la memoria asignada con 
                            # mymalloc (void * ptrNew = (void *) mymalloc(tamanyoNew);).
	
	# (ptrNew == NULL) ?
        # If (ptrNew != NULL) goto MyReallocContinueValidationsWithMemory
	bne	v0,DIR_NULL,$MyReallocContinueValidationsWithMemory	
	sw	zero,40($fp)  # Coloco en la direccion de memoria 40($fp) NULL, 
                              # que seria el resultado de la funcion myRealloc.
	b	$MyReallocReturn # Salto incondicional para retornar resultado de myRealloc.
$MyReallocContinueValidationsWithMemory:
	lw	v0,64($fp)  # Cargo en v0 la direccion de memoria guardada en la 
                            # direccion 64($fp), o sea, la variable * ptr.

        # If (ptr != NULL) goto MyReallocContinueWithLoadCharacters
	bne	v0,DIR_NULL,$MyReallocContinueWithLoadCharacters 
	
	# (ptr == NULL) ?
	lw	v0,24($fp)  # Cargo en v0 la direccion de memoria guardada en la 
                            # direccion 24($fp), o sea, la variable * ptrNew, que 
                            # seria la direccion de la memoria asignada con mymalloc.
	sw	v0,40($fp)  # Coloco en la direccion de memoria 40($fp) el contenido 
                            # de v0 (* ptrNew), que seria el resultado de la funcion myRealloc.
	b	$MyReallocReturn # Salto incondicional para retornar resultado de myRealloc.
$MyReallocContinueWithLoadCharacters:
	lw	v0,68($fp)  # Cargo en v0 el contenido guardado en la direccion 68($fp), 
                            # o sea, la variable tamanyoNew.
	sw	v0,28($fp)  # Guardo en la direccion de memoria 28($fp) la variable 
                            # tamanyoNew guardada en v0 (int end = tamanyoNew;). 
	
	lw	v1,72($fp)  # Cargo en v1 el contenido guardado en la direccion 
                            # 72($fp), o sea, la variable tamanyoOld.
	lw	v0,68($fp)  # Cargo en v0 el contenido guardado en la direccion 
                            # 68($fp), o sea, la variable tamanyoNew, para poder 
                            # luego hacer comparacion.
	
	# (tamanyoOld < tamanyoNew) ?
	sltu	v0,v1,v0  # Compara el contenido de la variable tamanyoOld (v1) 
                          # con tamanyoNew (v0), y guarda true en v0 si el 
                          # primero (tamanyoOld) es mas chico que el segundo (tamanyoNew).
        # If (tamanyoOld >= tamanyoNew) goto MyReallocLoadCharacters
	beq	v0,FALSE,$MyReallocLoadCharacters
	lw	v0,72($fp)  # Cargo en v0 el contenido guardado en la 
                            # direccion 72($fp), o sea, la variable tamanyoOld.
	sw	v0,28($fp)  # Guardo en la direccion 28($fp), que seria la variable 
                            # end, el contenido de la variable tamanyoOld (end = tamanyoOld;).
$MyReallocLoadCharacters:
	lw	v0,24($fp)  # Cargo en v0 el contenido guardado en la direccion 24($fp), 
                            # o sea, la variable ptrNew.
	sw	v0,32($fp)  # Guardo en la direccion de memoria 24($fp) el contenido de 
                            # v0 (char *tmp = ptrNew;).
	lw	v0,64($fp)  # Cargo en v0 el contenido guardado en la direccion 64($fp), 
                            # o sea, la variable ptr.
	sw	v0,36($fp)  # Guardo en la direccion de memoria 36($fp) el contenido 
                            # de v0 (const char *src   = ptr;).
$MyReallocWhileLoadCharacter:
	lw	v0,28($fp)  # Cargo en v0 el contenido guardado en la direccion 28($fp), 
                            # o sea, la variable end.
	addu	v0,v0,-1    # Decremento en 1 el contenido de v0 (end --).
	move	v1,v0  	    # Muevo el contenido de v0 a v1.
	sw	v1,28($fp)  # Guardo en la direccion de memoria 28($fp), que seria en donde 
                            # estaba end, el nuevo valor de end (habia sido decrementado en 1).
	li	v0,-1  	    # Cargo en v0 el literal -1.
	bne	v1,v0,$MyReallocContinueWhileLoad # If ( end != -1) goto MyReallocContinueWhileLoad.
	b	$MyReallocFinalizedWhileLoad # Salto incondicional fuera del while, porque la variable end es -1.
$MyReallocContinueWhileLoad:
	# *tmp = *src;
	lw	v1,32($fp)  # Cargo en v1 el contenido guardado en la direccion 32($fp), que seria *tmp.
	lw	v0,36($fp)  # Cargo en v0 el contenido guardado en la direccion 36($fp), que seria *src.
	lbu	v0,0(v0)    # Cargo la direccion de memoria en v0 de src.
	sb	v0,0(v1)    # Guardo en la direccion apuntada por el contenido de v1, la direccion de 
                            # memoria guardada en v0 (*tmp = *src;).
	
	# tmp ++
	lw	v0,32($fp)  # Cargo en v0 el contenido guardado en la direccion 32($fp), que seria *tmp.
	addu	v0,v0,1     # Incremento en 1 el contenido guardado en v0 (tmp ++).
	sw	v0,32($fp)  # Guardo en la direccion de memoria 32($fp) lo que tenia v0 
                            # (el resultado de hacer tmp ++).
	
	# src ++
	lw	v0,36($fp)  # Cargo en v0 el contenido guardado en la direccion 36($fp), que seria *src.
	addu	v0,v0,1     # Incremento en 1 el contenido guardado en v0 (src ++).
	sw	v0,36($fp)  # Guardo en la direccion de memoria 36($fp) lo que tenia v0 
                            # (el resultado de hacer src ++).
	
	b	$MyReallocWhileLoadCharacter # Vuelvo a entrar al while
$MyReallocFinalizedWhileLoad:
	lw	a0,64($fp)  # Cargo en v0 el contenido guardado en la direccion 64($fp), que seria *ptr.
	la	t9,myfree   # Cargo la direccion de la funcion myfree.
	jal	ra,t9  	    # Ejecuto la funcion myfree.
	sw	zero,64($fp)  # Coloco el puntero apuntando a NULL (ptr = NULL;).
	
	lw	v0,24($fp)  # Cargo en v0 la direccion de memoria guardada en la 
                            # direccion 24($fp), o sea, la variable * ptrNew, que seria 
                            # la direccion de la memoria asignada con mymalloc..
	sw	v0,40($fp)  # Guardo en la direccion de memoria 40($fp) el contenido de v0 
                            # (* ptrNew), que seria el resultado de la funcion myRealloc.		
$MyReallocReturn:
	lw	v0,40($fp)  # Cargo en v0 el resultado de la funcion myRealloc guardado 
                            # en la direccion de memoria 40($fp).
	move	sp,$fp
	lw	ra,56(sp)
	lw	$fp,52(sp)
	addu	sp,sp,64
	j	ra  	# Jump and return

	.end	myRealloc
  
	
