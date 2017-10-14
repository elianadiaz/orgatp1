#include <mips/regdef.h>
#include <sys/syscall.h>

#STATICS VAR DEFINITIONS FUNCTION PALINDROME

#define FALSE 			0
#define TRUE 			1
#define LEXICO_BUFFER_SIZE 	10
#define DIR_NULL 		0
#define FILE_DESCRIPTOR_STDERR	2
#define LINE_BREAK		10

# Resultados de funciones posibles
#define OKEY			0
#define ERROR_MEMORY	2
#define ERROR_READ		3
#define	ERROR_WRITE		4
#define LOAD_I_BUFFER	5

# Size mensajes
#define BYTES_MENSAJE_ERROR_MEMORIA_LEXICO	45
#define BYTES_MENSAJE_ERROR_MEMORIA_OBUFFER	60
#define BYTES_MENSAJE_ERROR_MEMORIA_IBUFFER 60
#define BYTES_MENSAJE_ERROR_MEMORIA_AMOUNT_SAVED 64
#define BYTES_MENSAJE_ERROR_LECTURA_ARCHIVO	60

# Para mymalloc y myfree

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
	lw	ra, 48(sp)
	lw	$fp, 44(sp)
	addu	sp, sp, 56

	j	ra
	.end	mymalloc


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


##-----	toLowerCase -----##

	.text
#	.abicalls
	.align 		2
	.globl 		toLowerCase 
	.ent 		toLowerCase
toLowerCase:
	.frame		$fp,24,ra		# vars= 8, regs= 2/0, args= 0, extra= 8
	.set		noreorder
	.cpload		t9
	.set		reorder
	
	#Stack frame creation
	subu		sp,sp,24
	
	.cprestore 0
	sw		$fp,20(sp)
	sw		gp,16(sp)
	move		$fp,sp
	
	move		v0,a0					# word (this is the character)
	sb		v0,8($fp)
	lb		v0,8($fp)
	slt		v0,v0,65
	bne		v0,zero,$IfNotLower			# if !(word >= 65) goto IfNotLower 
	lb		v0,8($fp)
	slt		v0,v0,91
	beq		v0,zero,$IfNotLower			# if !(word <= 90) goto IfNotLower 
	lbu		v0,8($fp)
	addu		v0,v0,32				# word += 32
	sb		v0,8($fp)
$IfNotLower:
	lb		v0,8($fp)
	move		sp,$fp
	
	#Stack frame destruction.
	lw		$fp,20(sp)
	addu		sp,sp,24
	j		ra					# Jump and return
	.end		toLowerCase
	.size		toLowerCase, .-toLowerCase

	
##-----	verifyPalindromic -----##

	.text
	.align		2
	.globl		verifyPalindromic
	.ent		verifyPalindromic
verifyPalindromic:
	.frame		$fp,72,ra			# vars= 32, regs= 3/0, args= 16, extra= 8 => 72 = 32 + 16 + 3*8
	.set		noreorder
	.cpload		t9
	.set		reorder
	
	#Stack frame creation
	subu		sp,sp,72
	
	.cprestore 	16
	sw		ra,64(sp)
	sw		$fp,60(sp)
	sw		gp,56(sp)
	move		$fp,sp
	
	sw		a0,72($fp)				# char * word
	sw		a1,76($fp)				# int quantityCharacterInWord
	
	lw		v0,72($fp)
	beq		v0,zero,$IfPalindromicFalse		# if (word == NULL) goto IfPalindromicFalse
	lw		v0,76($fp)
	blez		v0,$IfPalindromicFalse			# if (quantityCharacterInWord <= 0) goto IfPalindromicFalse
	b		$VerifyWhenOneCharacter			# Salta siempre - goto VerifyWhenOneCharacter
$IfPalindromicFalse:
	sw		zero,52($fp)					# Guardo FALSE (= 0)
	b		$ReturnVerifyPalindromic		# Salta siempre - goto ReturnVerifyPalindromic (con return FALSE)
$VerifyWhenOneCharacter:
	lw		v1,76($fp)				# Cargo quantityCharacterInWord
	li		v0,1					# Cargo en v0, el valor 1, para luego hacer la comparacion
	bne		v1,v0,$VerifyWhenTwoCharacteres	# if (quantityCharacterInWord != 1) goto VerifyWhenTwoCharacteres
	li		v0,TRUE					# Cargo resultado (TRUE es igual a 1)
	sw		v0,52($fp)
	b		$ReturnVerifyPalindromic		# Salta siempre - goto ReturnVerifyPalindromic (con return TRUE)
$VerifyWhenTwoCharacteres:
	lw		v1,76($fp)				# Cargo quantityCharacterInWord
	li		v0,2					# Cargo en v0, el valor 2, para luego hacer la comparacion
	bne		v1,v0,$VerifyWhenMoreThanOneCharacter	# if (quantityCharacterInWord != 2) goto VerifyWhenMoreThanOneCharacter
	
	# Paso a minuscula el primer caracter del lexico
	lw		v0,72($fp)				# Cargo * word
	lb		v0,0(v0)				# Cargo el primer caracter apuntado por word	
	move		a0,v0					# Cargo el primer caracter que estaba en v0, en a0. Voy a enviarlo por parametro a la funcion toLoweCase
	la		t9,toLowerCase				# Cargo la direccion de la funcion toLowerCase
	jal		ra,t9					# Salto a la funcion toLowerCase	
	sb		v0,24($fp)				# Cargo el resultado en v0 en 24($fp).
	
	# Paso a minuscula el segundo caracter del lexico
	lw		v0,72($fp)				# Cargo la direccion de memoria en donde esta word	
	addu		v0,v0,1					# Sumo uno a la direccion de memoria, me corro un lugar.
	lb		v0,0(v0)				# Cargo el segundo caracter apuntado por word (solo habian dos caracteres)
	move		a0,v0					# Cargo el segundo caracter que estaba en v0, en a0. Voy a enviarlo por parametro a la funcion toLoweCase
	la		t9,toLowerCase				# Cargo la direccion de la funcion toLowerCase
	jal		ra,t9					# Salto a la funcion toLowerCase
	sb		v0,25($fp)				# Cargo el resultado en v0 en 25($fp).
	
	lb		v1,24($fp)				# Cargo el primer caracter en minuscula en v1
	lb		v0,25($fp)				# Cargo el segundo caracter en minuscula en v0
	beq		v1,v0,$IfPalindromicTrue		# if (firstCharacter == lastCharacter) goto IfPalindromicTrue
	sw		zero,52($fp)			# Guardo FALSE (= 0)
	b		$ReturnVerifyPalindromic		# Salta siempre - goto ReturnVerifyPalindromic (con return FALSE)
$IfPalindromicTrue:
	li		v0,TRUE					# TRUE es igual a 1
	sw		v0,52($fp)
	b		$ReturnVerifyPalindromic		# Salta siempre - goto ReturnVerifyPalindromic (con return TRUE)
$VerifyWhenMoreThanOneCharacter:
	l.s		$f0,76($fp)				# Cargo quantityCharacterInWord
	cvt.d.w	$f2,$f0					# Convierto el integer quantityCharacterInWord a double
	l.d		$f0,doubleWord			# Cargo en f0 el valor 2.
	div.d	$f0,$f2,$f0				# Division con Double (double)quantityCharacterInWord / 2; - Sintaxis: div.d FRdest, FRsrc1, FRsrc2
	s.d		$f0,32($fp)				# Guarda el resultado de la division en 32($fp). O sea, middle (double middle = (double)quantityCharacterInWord / 2;)
	sw		zero,40($fp)			# En 40($fp) se encuentra idx (int idx = 0;).
	li		v0,TRUE					# En v0 esta la variable validPalindromic en TRUE, que es igual a 1 (int validPalindromic = TRUE;).
	sw		v0,44($fp)				# Guarda en la direccion 44($fp) el valor de validPalindromic.
	lw		v0,76($fp)				# Cargo quantityCharacterInWord en v0.
	addu		v0,v0,-1				# Le resto 1 a quantityCharacterInWord y lo guardo en v0 (int last = quantityCharacterInWord - 1;).
	sw		v0,48($fp)				# Guardo en la direccion 48($fp) la variable last.
$WhileMirror:
	l.s		$f0,40($fp)				# Cargo idx en f0.
	cvt.d.w	$f2,$f0					# Convierto el integer idx a double y lo guardo en f2 para poder hacer la comparacion.
	l.d		$f0,32($fp)				# Cargo en a0 la variable middle.
	c.lt.d	$f2,$f0					# Compara la variable idx con la variable middle, y setea el condition flag en true si el primero (idx) es mas chico que el segundo (middle).
	bc1t	$WhileMirrorConditionLastWithMiddle	# Si el condition flag es true, continua haciendo las comparaciones.
	b		$WhileMirrorFinalized			# Si el condition flag es false, salta al final de la funcion, devolviendo el valor de la variable validPalindromic que seria TRUE.
$WhileMirrorConditionLastWithMiddle:
	l.s		$f0,48($fp)				# Cargo la variable last en f0.
	cvt.d.w	$f2,$f0					# Convierto el integer last a double y lo guardo en f2 para poder hacer la comparacion.
	l.d		$f0,32($fp)				# Cargo en f0 el contenido de la variable middle.
	c.lt.d	$f0,$f2					# Compara el contenido de la variable last con la variable middle, y setea el condition flag en true si 
								# el primero (last) es mas chico que el segundo (middle).
	bc1t	$WhileMirrorConditionValidPalindromicTrue	# Si el condition flag es true, continua haciendo las comparaciones.
	b		$WhileMirrorFinalized			# Si el condition flag es false, salta al final de la funcion, devolviendo el valor de la variable validPalindromic que seria TRUE.
$WhileMirrorConditionValidPalindromicTrue:
	lw		v1,44($fp)				# Cargo el contenido de la variable validPalindromic, que esta en la direccion 44($fp), en v1.
	li		v0,TRUE					# Cargo TRUE (que seria 1) en v0.
	beq		v1,v0,$WhileMirrorContent		# If validPalindromic == TRUE goto WhileMirrorContent (entro al while).
	b		$WhileMirrorFinalized			# Salto para salir del while (bucle).
$WhileMirrorContent:
	# Voy a pasar a minuscula el caracter apuntado desde la izquierda.
	lw		v1,72($fp)				# Cargo en v1 el contenido de la variable * word.
	lw		v0,40($fp)				# Cargo en v0 el contenido de la variable idx.
	addu		v0,v1,v0				# En v0 coloco el puntero a word corrido la cantidad indicada por la variable idx.
	lb		v0,0(v0)				# Cargo en v0 el contenido de la direccion de memoria (cero corrimiento).
	move		a0,v0					# Paso a a0 el contenido de v0, que seria un unico caracter.
	la		t9,toLowerCase				# Cargo la direccion de la funcion toLowerCase
	jal		ra,t9					# Salto a la funcion toLowerCase para pasar el caracter a minuscula.
	sb		v0,25($fp)				# Cargo el caracter contenido en v0 a la direccion de memoria 25($fp) - char firstCharacter = toLowerCase(word[idx]);
	
	# Voy a pasar a minuscula el caracter apuntado desde la derecha.
	lw		v1,72($fp)				# Cargo en v1 el contenido de la variable * word.
	lw		v0,48($fp)				# Cargo en v0 el contenido de la variable last.
	addu		v0,v1,v0				# En v0 coloco el puntero a word corrido la cantidad indicada por la variable last.
	lb		v0,0(v0)				# Cargo en v0 el contenido de la direccion de memoria (cero corrimiento).
	move		a0,v0					# Paso a a0 el contenido de v0, que seria un unico caracter.
	la		t9,toLowerCase				# Cargo la direccion de la funcion toLowerCase
	jal		ra,t9					# Salto a la funcion toLowerCase para pasar el caracter a minuscula.
	sb		v0,24($fp)				# Cargo el caracter contenido en v0 a la direccion de memoria 24($fp) - char lastCharacter = toLowerCase(word[last]);	
	
	lb		v1,25($fp)				# Cargo en v1 el contenido de la variable firstCharacter.
	lb		v0,24($fp)				# Cargo en v1 el contenido de la variable lastCharacter.
	beq		v1,v0,$ContinuedInWhileMirror 		# If (firstCharacter == lastCharacter) goto ContinuedInWhileMirror
	sw		zero,44($fp)
$ContinuedInWhileMirror:
	lw		v0,40($fp)				# Cargo en v0 el contenido de la variable idx.
	addu		v0,v0,1					# Incremento en uno el valor de la variable idx (idx ++).
	sw		v0,40($fp)				# Guardo el contenido de la variable idx en la direccion de memoria 40($fp).
	lw		v0,48($fp)				# Cargo en v0 el contenido de la variable last.	
	addu		v0,v0,-1				# Decremento en uno el valor de la variable last (last --).
	sw		v0,48($fp)				# Guardo el contenido de la variable last en la direccion de memoria 48($fp).
	b		$WhileMirror				# Vuelvo a entrar en el bucle.
$WhileMirrorFinalized:
	lw		v0,44($fp)				# Cargo en v0 el contenido de la variable validPalindromic, que se encuentra en la direccion de memoria 44($fp).
	sw		v0,52($fp)				# Guardo en la direccion de memoria 52($fp) el resultado de la funcion verifyPalindromic. 
$ReturnVerifyPalindromic:
	lw		v0,52($fp)
	move		sp,$fp
	lw		ra,64(sp)
	lw		$fp,60(sp)
	addu		sp,sp,72
	j		ra					# Jump and return
	.end		verifyPalindromic
	.size		verifyPalindromic, .-verifyPalindromic


##-----	isKeywords -----##

	.align		2
	.globl		isKeywords
	.ent		isKeywords
isKeywords:
	.frame		$fp,24,ra				# vars= 8, regs= 2/0, args= 0, extra= 8
	.set		noreorder
	.cpload		t9
	.set		reorder
	
	#Stack frame creation
	subu		sp,sp,24
	.cprestore 0
	sw		$fp,20(sp)
	sw		gp,16(sp)
	move		$fp,sp
	
	move		v0,a0					# Muevo de a0 a v0 el parametro de la funcion (char character).
	sb		v0,8($fp)				# Guardo en la direccion de memoria 8($fp) el contenido de la variable character que se encuentra en el registro v0.
	lb		v0,8($fp)				# Cargo el byte character en v0 que estaba en la direccion de memoria 8($fp).
	
	# character >= 65 && character <= 90    ---   A - Z = [65 - 90]
	slt		v0,v0,65				# Compara el contenido de la variable character con el literal 65, y guarda true en v0 si 
								# el primero (character) es mas chico que el segundo (65). 
	bne		v0,FALSE,$VerifyCharacterOfaToz		# Si no es igual a FALSE, o sea, character < 65, salta a VerifyCharacterOfaToz.
	lb		v0,8($fp)				# Cargo el byte character en v0 que estaba en la direccion de memoria 8($fp).
	slt		v0,v0,91				# Compara el contenido de la variable character con el literal 91, y guarda true en v0 si el 
								# primero (character) es mas chico que el segundo (91). 
	bne		v0,FALSE,$ReturnIsKeywordsTrue		# Si no es igual a FALSE, o sea, character > 91, salta a ReturnIsKeywordsTrue.
$VerifyCharacterOfaToz:	
	lb		v0,8($fp)				# Cargo el byte character en v0 que estaba en la direccion de memoria 8($fp).
	
	# character >= 97 && character <= 122    ---   a - z = [97 - 122]
	slt		v0,v0,97				# Compara el contenido de la variable character con el literal 97, y guarda true en v0 si 
								# el primero (character) es mas chico que el segundo (97). 
	bne		v0,FALSE,$VerifyCharacterOf0To9		# Si no es igual a FALSE, o sea, character < 65, salta a VerifyCharacterOf0To9.
	lb		v0,8($fp)				# Cargo el byte character en v0 que estaba en la direccion de memoria 8($fp).
	slt		v0,v0,123				# Compara el contenido de la variable character con el literal 123, y guarda true en v0 si el 
								# primero (character) es mas chico que el segundo (123). 
	bne		v0,FALSE,$ReturnIsKeywordsTrue		# Si no es igual a FALSE, o sea, character > 123, salta a ReturnIsKeywordsTrue.
$VerifyCharacterOf0To9:
	lb		v0,8($fp)				# Cargo el byte character en v0 que estaba en la direccion de memoria 8($fp).

	# character >= 48 && character <= 57    ---   0 - 9 = [48 - 57]
	slt		v0,v0,48				# Compara el contenido de la variable character con el literal 48, y guarda true en v0 si el 
								# primero (character) es mas chico que el segundo (48). 
	bne		v0,zero,$VerifyCharacterGuionMedio		# Si no es igual a FALSE, o sea, character < 48, salta a VerifyCharacterGuionMedio.
	lb		v0,8($fp)				# Cargo el byte character en v0 que estaba en la direccion de memoria 8($fp).
	slt		v0,v0,58				# Compara el contenido de la variable character con el literal 58, y guarda true en v0 si el 
								# primero (character) es mas chico que el segundo (58). 
	bne		v0,zero,$ReturnIsKeywordsTrue		# Si no es igual a FALSE, o sea, character > 58, salta a ReturnIsKeywordsTrue.
$VerifyCharacterGuionMedio:
	lb		v1,8($fp)				# Cargo el byte character en v1 que estaba en la direccion de memoria 8($fp).
	
	# character == 45    ---   - =  45
	li		v0,45					# Cargo el literal 45 en v0 para hacer luego la comparacion.
	beq		v1,v0,$ReturnIsKeywordsTrue		# If (character == 45) goto ReturnIsKeywordsTrue
	
	lb		v1,8($fp)				# Cargo el byte character en v1 que estaba en la direccion de memoria 8($fp).
	
	# character == 95    ---   _ = 95
	li		v0,95					# Cargo el literal 95 en v0 para hacer luego la comparacion.
	beq		v1,v0,$ReturnIsKeywordsTrue		# If (character == 95) goto ReturnIsKeywordsTrue
	b		$ReturnIsKeywordsFalse			# Salto incondicional para retornar FALSE (character no es un keyword).
$ReturnIsKeywordsTrue:
	li		v0,TRUE					# Cargo en v0 TRUE (que seria igual a 1).
	sw		v0,12($fp)				# Guardo el resultado de la funcion TRUE (v0) en la direccion de memoria 12($fp).
	b		$ReturnIsKeywords			# Salto incondicional para retornar resultado de las comparaciones.
$ReturnIsKeywordsFalse:
	sw		zero,12($fp)				# Guardo FALSE (que seria igual a 0) en la direccion de memoria 12($fp).
$ReturnIsKeywords:
	lw		v0,12($fp)				# Cargo en v0 el resultado de la funcion isKeywords guardado en la direccion de memoria 12($fp).
	move		sp,$fp
	lw		$fp,20(sp)
	addu		sp,sp,24
	j		ra					# Jump and return
	.end		isKeywords
	.size		isKeywords, .-isKeywords


##-----	myRealloc -----##

	.align		2
	.globl		myRealloc
	.ent		myRealloc
myRealloc:
	.frame		$fp,64,ra				# vars= 24, regs= 3/0, args= 16, extra= 8	
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
	sw		a0,64($fp)				# Guardo en la direccion de memoria 64($fp) la variable ptr (void * ptr).
	sw		a1,68($fp)				# Guardo en la direccion de memoria 68($fp) la variable tamanyoNew (size_t tamanyoNew).
	sw		a2,72($fp)				# Guardo en la direccion de memoria 72($fp) la variable tamanyoOld (int tamanyoOld).
	
	lw		v0,68($fp)				# Cargo en v0 el contenido de la variable tamanyoNew, que esta en la direccion de memoria 68($fp)
	bne		v0,zero,$MyReallocContinueValidations   # If (tamanyoNew != 0) goto MyReallocContinueValidations
	
	# If (tamanyoNew == 0)
	lw		a0,64($fp)				# Cargo en a0 la direccion de memoria guardada en la direccion 64($fp), o sea, la variable * ptr.
	la		t9,free					# Cargo la direccion de la funcion free.
	jal		ra,t9					# Ejecuto la funcion free.
	sw		zero,64($fp)			# Coloco el puntero apuntando a NULL (ptr = NULL;).
	sw		zero,40($fp)			# Coloco en la direccion de memoria 40($fp) NULL, que seria el resultado de la funcion myRealloc.
	b		$MyReallocReturn			# Salto incondicional para retornar resultado de myRealloc.
$MyReallocContinueValidations:
	lw		a0,68($fp)				# Cargo en a0 el contenido guardado en la direccion 68($fp), o sea, la variable tamanyoNew.
	la		t9,malloc				# Cargo la direccion de la funcion malloc.
	jal		ra,t9					# Ejecuto la funcion malloc.
	sw		v0,24($fp)				# Guardo en la direccion 24($fp) el contenido de v0, que seria la direccion de la memoria asignada con malloc.
	lw		v0,24($fp)				# Cargo en v0 la direccion de la memoria asignada con malloc (void * ptrNew = (void *) malloc(tamanyoNew);).
	
	# (ptrNew == NULL) ?
	bne		v0,DIR_NULL,$MyReallocContinueValidationsWithMemory # If (ptrNew != NULL) goto MyReallocContinueValidationsWithMemory
	lw		a0,64($fp)				# Cargo en a0 la direccion de memoria guardada en la direccion 64($fp), o sea, la variable * ptr.
	la		t9,free					# Cargo la direccion de la funcion free.
	jal		ra,t9					# Ejecuto la funcion free.
	sw		zero,64($fp)			# Coloco el puntero apuntando a NULL (ptr = NULL;).
	sw		zero,40($fp)			# Coloco en la direccion de memoria 40($fp) NULL, que seria el resultado de la funcion myRealloc.
	b		$MyReallocReturn			# Salto incondicional para retornar resultado de myRealloc.
$MyReallocContinueValidationsWithMemory:
	lw		v0,64($fp)				# Cargo en v0 la direccion de memoria guardada en la direccion 64($fp), o sea, la variable * ptr.
	bne		v0,DIR_NULL,$MyReallocContinueWithLoadCharacters # If (ptr != NULL) goto MyReallocContinueWithLoadCharacters
	
	# (ptr == NULL) ?
	lw		v0,24($fp)				# Cargo en v0 la direccion de memoria guardada en la direccion 24($fp), o sea, la variable * ptrNew, 
								# que seria la direccion de la memoria asignada con malloc.
	sw		v0,40($fp)				# Coloco en la direccion de memoria 40($fp) el contenido de v0 (* ptrNew), que seria el resultado de la funcion myRealloc.
	b		$MyReallocReturn			# Salto incondicional para retornar resultado de myRealloc.
$MyReallocContinueWithLoadCharacters:
	lw		v0,68($fp)				# Cargo en v0 el contenido guardado en la direccion 68($fp), o sea, la variable tamanyoNew.
	sw		v0,28($fp)				# Guardo en la direccion de memoria 28($fp) la variable tamanyoNew guardada en v0 (int end = tamanyoNew;). 
	
	lw		v1,72($fp)				# Cargo en v1 el contenido guardado en la direccion 72($fp), o sea, la variable tamanyoOld.
	lw		v0,68($fp)				# Cargo en v0 el contenido guardado en la direccion 68($fp), o sea, la variable tamanyoNew, para poder luego hacer comparacion.
	
	# (tamanyoOld < tamanyoNew) ?
	sltu		v0,v1,v0				# Compara el contenido de la variable tamanyoOld (v1) con tamanyoNew (v0), y guarda true en v0 si 
								# el primero (tamanyoOld) es mas chico que el segundo (tamanyoNew). 
	beq		v0,FALSE,$MyReallocLoadCharacters 	# If (tamanyoOld >= tamanyoNew) goto MyReallocLoadCharacters
	lw		v0,72($fp)				# Cargo en v0 el contenido guardado en la direccion 72($fp), o sea, la variable tamanyoOld.
	sw		v0,28($fp)				# Guardo en la direccion 28($fp), que seria la variable end, el contenido de la variable tamanyoOld (end = tamanyoOld;).
$MyReallocLoadCharacters:
	lw		v0,24($fp)				# Cargo en v0 el contenido guardado en la direccion 24($fp), o sea, la variable ptrNew.
	sw		v0,32($fp)				# Guardo en la direccion de memoria 24($fp) el contenido de v0 (char *tmp = ptrNew;).
	lw		v0,64($fp)				# Cargo en v0 el contenido guardado en la direccion 64($fp), o sea, la variable ptr.
	sw		v0,36($fp)				# Guardo en la direccion de memoria 36($fp) el contenido de v0 (const char *src   = ptr;).
$MyReallocWhileLoadCharacter:
	lw		v0,28($fp)				# Cargo en v0 el contenido guardado en la direccion 28($fp), o sea, la variable end.
	addu		v0,v0,-1				# Decremento en 1 el contenido de v0 (end --).
	move		v1,v0					# Muevo el contenido de v0 a v1.
	sw		v1,28($fp)				# Guardo en la direccion de memoria 28($fp), que seria en donde estaba end, el nuevo valor de end (habia sido decrementado en 1).
	li		v0,-1					# Cargo en v0 el literal -1.
	bne		v1,v0,$MyReallocContinueWhileLoad	# If ( end != -1) goto MyReallocContinueWhileLoad.
	b		$MyReallocFinalizedWhileLoad		# Salto incondicional fuera del while, porque la variable end es -1.
$MyReallocContinueWhileLoad:
	# *tmp = *src;
	lw		v1,32($fp)				# Cargo en v1 el contenido guardado en la direccion 32($fp), que seria *tmp.
	lw		v0,36($fp)				# Cargo en v0 el contenido guardado en la direccion 36($fp), que seria *src.
	lbu		v0,0(v0)				# Cargo la direccion de memoria en v0 de src.
	sb		v0,0(v1)				# Guardo en la direccion apuntada por el contenido de v1, la direccion de memoria guardada en v0 (*tmp = *src;).
	
	# tmp ++
	lw		v0,32($fp)				# Cargo en v0 el contenido guardado en la direccion 32($fp), que seria *tmp.
	addu		v0,v0,1					# Incremento en 1 el contenido guardado en v0 (tmp ++).
	sw		v0,32($fp)				# Guardo en la direccion de memoria 32($fp) lo que tenia v0 (el resultado de hacer tmp ++).
	
	# src ++
	lw		v0,36($fp)				# Cargo en v0 el contenido guardado en la direccion 36($fp), que seria *src.
	addu		v0,v0,1					# Incremento en 1 el contenido guardado en v0 (src ++).
	sw		v0,36($fp)				# Guardo en la direccion de memoria 36($fp) lo que tenia v0 (el resultado de hacer src ++).
	
	b		$MyReallocWhileLoadCharacter    	# Vuelvo a entrar al while
$MyReallocFinalizedWhileLoad:
	lw		a0,64($fp)				# Cargo en v0 el contenido guardado en la direccion 64($fp), que seria *PTR.
	la		t9,free					# Cargo la direccion de la funcion free.
	jal		ra,t9					# Ejecuto la funcion free.
	sw		zero,64($fp)			# Coloco el puntero apuntando a NULL (ptr = NULL;).
	
	lw		v0,24($fp)				# Cargo en v0 la direccion de memoria guardada en la direccion 24($fp), o sea, la variable * ptrNew, que seria la direccion de la memoria asignada con malloc..
	sw		v0,40($fp)				# Guardo en la direccion de memoria 40($fp) el contenido de v0 (* ptrNew), que seria el resultado de la funcion myRealloc.		
$MyReallocReturn:
	lw		v0,40($fp)				# Cargo en v0 el resultado de la funcion myRealloc guardado en la direccion de memoria 40($fp).
	move		sp,$fp
	lw		ra,56(sp)
	lw		$fp,52(sp)
	addu		sp,sp,64
	j		ra					# Jump and return
	.end		myRealloc
	.size		myRealloc, .-myRealloc


##-----	initializeBuffer -----##

	.align		2
	.globl		initializeBuffer
	.ent		initializeBuffer
initializeBuffer:
	.frame		$fp,24,ra				# vars= 8, regs= 2/0, args= 0, extra= 8	
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
	sw		a0,24($fp)				# Guardo en la direccion de memoria 24($fp) la variable bytes (size_t bytes).
	sw		a1,28($fp)				# Guardo en la direccion de memoria 28($fp) la variable buffer (char * buffer).
	
	sw		zero,8($fp)				# Guardo en la direccion de memoria 8($fp) el contenido 0, que seria la variable i (int i;).
$ForInitializeBuffer:
	lw		v0,8($fp)				# Cargo en v0 el contenido en la direccion de memoria 8($fp), que seria la variable i.
	lw		v1,24($fp)				# Cargo en v1 el contenido en la direccion de memoria 24($fp), que seria la variable bytes.
	sltu		v0,v0,v1				# Comparo i (v0) con bytes (v1). Si i < bytes, guardo TRUE en v0, sino guardo FALSE.
	bne		v0,FALSE,$ForInitializeCharacter 	# If (i < bytes) goto ForInitializeCharacter.
	b		$InitializeBufferReturn			# Salto incondicional al return de la funcion initializeBuffer.
$ForInitializeCharacter:
	# buffer[i] = '\0';
	lw		v1,28($fp)				# Cargo en v1 el contenido en la direccion de memoria 28($fp), que seria la variable * buffer.
	lw		v0,8($fp)				# Cargo en v0 el contenido en la direccion de memoria 8($fp), que seria la variable i.
	addu		v0,v1,v0				# Me corro en el buffer la cantidad estipulada por la variable i (buffer[i] = buffer + i), y lo guardo en v0.
	sb		zero,0(v0)				# Guardo '\0' = 0 en la posicion del buffer estipulada previamente (buffer[i] = '\0';).
	
	# ++ i
	lw		v0,8($fp)				# Cargo en v0 el contenido en la direccion de memoria 8($fp), que seria la variable i.
	addu		v0,v0,1					# Incremento en 1 la variable i (i ++).
	sw		v0,8($fp)				# Guardo en la direccion de memoria 8($fp) el nuevo valor de la variable i.
	
	b		$ForInitializeBuffer			# Vuelvo a entrar en el for (bucle).
$InitializeBufferReturn:
	move		sp,$fp
	lw		$fp,20(sp)
	addu		sp,sp,24
	j		ra					# Jump and return
	.end		initializeBuffer
	.size		initializeBuffer, .-initializeBuffer


##-----	writeOBufferInOFile -----##

	.align		2
	.globl		writeOBufferInOFile
	.ent		writeOBufferInOFile
writeOBufferInOFile:
	.frame		$fp,64,ra				# vars= 24, regs= 3/0, args= 16, extra= 8
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
	
	sw		zero,24($fp)				# Guardo en la direccion de memoria 24($fp) la variable completeDelivery inicializada en FALSE (int completeDelivery = FALSE;).
	sw		zero,28($fp)				# Guardo en la direccion de memoria 28($fp) la variable bytesWriteAcum inicializada en 0 (int bytesWriteAcum = 0;).
	
	lw		v0,64($fp)				# Cargo en v0 el contenido de la direccion de memoria 64($fp), que seria la variable * amountSavedInOBuffer. 
	lw		v0,0(v0)				# Cargo la direccion de memoria del contenido en v0.
	sw		v0,32($fp)				# Guardo en la direccion de memoria 32($fp) la direccion de memoria de la variable 
								# amountSavedInOBuffer (int bytesToWrite = (*amountSavedInOBuffer);).
$WhileWriteOBufferInOFile:
	lw		v0,24($fp)				# Cargo en v0 el contenido de la direccion de memoria 24($fp), que seria la variable completeDelivery.
	beq		v0,FALSE,$GoInWhileWriteOBufferInOFile  # Si completeDelivery es FALSE (todavia no se guardaron todos los datos cargados en el buffer en el archivo) 
								# entro al while para continuar la bajada de los datos al buffer.
	b		$WriteOBufferInOFileReturnOkey  	# Salto incondicional para retornar OKEY como resultado del proceso de escritura en el archivo de salida.
$GoInWhileWriteOBufferInOFile:
	# obuffer + bytesWriteAcum
	lw		v1,obuffer				# Cargo en v1 obuffer (variable global).
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
	bgez		v0,$ContinueWriteOBufferInOFile 	# Si la cantidad de bytes escritos (bytesWrite) es mas grande que 0, salto a continuar escribiendo 
								# en el archivo si es necesario (ContinueWriteOBufferInOFile).
	
	# Hubo un error (la cantidad de caracteres escritos es menor a 0, valor negativo).
	li		v0,ERROR_WRITE				# Cargo en v0 el resultado de la funcion, que seria un codigo de error (ERROR_WRITE).
	sw		v0,40($fp)				# Guardo en la direccion de memoria 40($fp) el resultado de la funcion que estaba en v0 (ERROR_WRITE).
	b		$WriteOBufferInOFileReturn		# Salto incondicional al final de la funcion, al return.
$ContinueWriteOBufferInOFile:
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
	bgtz		v0,$WhileWriteOBufferInOFile   		# Si bytesToWrite es mayor a cero, salto a WhileWriteOBufferInOFile (vuelvo a entrar al loop while).
	# (bytesToWrite <= 0) ? then:
	li		v0,TRUE					# Cargo en v0 el literal TRUE (que es 1).
	sw		v0,24($fp)				# Guardo en la direccion de memoria 24($fp) el contenido de v0. O sea, completeDelivery = TRUE;
	b		$WhileWriteOBufferInOFile		# Salto incondicional al inicio del loop.
$WriteOBufferInOFileReturnOkey:
	sw		zero,40($fp)				# Guardo en la direccion de memoria 40($fp) el resultado OKEY (resultado de la funcion writeOBufferInOFile).
$WriteOBufferInOFileReturn:
	lw		v0,40($fp)				# Cargo el resultado de la funcion writeOBufferInOFile, que estaba en la direccion de memoria 40($fp), en el registro v0.
	move		sp,$fp
	lw		ra,56(sp)
	lw		$fp,52(sp)
	addu		sp,sp,64
	j		ra					# Jump and return
	.end		writeOBufferInOFile
	.size		writeOBufferInOFile, .-writeOBufferInOFile


##-----	executePalindromeWrite -----##
		
	.align		2
	.globl		executePalindromeWrite
	.ent		executePalindromeWrite
executePalindromeWrite:
	.frame		$fp,80,ra				# vars= 40, regs= 3/0, args= 16, extra= 8	
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
	sw		a0,80($fp)				# Guardo en la direccion de memoria 80($fp) la variable * ibuffer (char * ibuffer).
	sw		a1,84($fp)				# Guardo en la direccion de memoria 84($fp) la variable * amountSavedInOBuffer (int * amountSavedInOBuffer).
	
	sw		zero,24($fp)				# Guardo en la direccion de memoria 24($fp) el valor FALSE (que seria 0), representa la variable findEnd (int findEnd = FALSE).
	sw		zero,28($fp)				# Guardo en la direccion de memoria 28($fp) el valor FALSE (que seria 0), representa la variable loadIBuffer (int loadIBuffer = FALSE).
	sw		zero,32($fp)				# Guardo en la direccion de memoria 32($fp) el valor 0, representa la variable idx (int idx = 0).
	sw		zero,36($fp)				# Guardo en la direccion de memoria 36($fp) el valor OKEY (que seria 0), representa la variable rdo (int rdo = FALSE).
$WhileExecPalindromeWrite:
	# findEnd == FALSE ?
	lw		v0,24($fp)				# Cargo en v0 el contenido de la direccion de memoria 24($fp), que seria la variable findEnd.
	bne		v0,FALSE,$LeaveWhileExecPalindromeWrite # If (findEnd != FALSE) goto LeaveWhileExecPalindromeWrite.
	
	# loadIBuffer == FALSE ?
	lw		v0,28($fp)				# Cargo en v0 el contenido de la direccion de memoria 28($fp), que seria la variable loadIBuffer.
	bne		v0,FALSE,$LeaveWhileExecPalindromeWrite # If (loadIBuffer != FALSE) goto LeaveWhileExecPalindromeWrite.
	
	# Comienzo a ejecutar las intrucciones dentro del while
	
	# char character = ibuffer[idx];	
	lw		v1,80($fp)				# Cargo en v1 lo guardado en la direccion de memoria 80($fp), que seria la variable ibuffer.
	lw		v0,32($fp)				# Cargo en v0 lo guardado en la direccion de memoria 32($fp), que seria la variable idx.
	addu		v0,v1,v0				# Me corro en la direccion de memoria: a la apuntada por v1 (ibuffer) me corro la cantidad de posiciones establecidas por idx.
	lbu		v0,0(v0)				# Cargo en v0 la direccion de memoria guardada en v0 (calculada en el paso anterior).
	sb		v0,40($fp)				# Guardo en la direccion 40($fp) lo guardado en v0. Representaria la variable character.
	
	# character == '\0' ?
	lb		v0,40($fp)				# Cargo en v0 el contenido de la direccion de memoria 40($fp), que seria la variable character.
	bne		v0,zero,$VerifyCharacterToLoadInLexico  # If (character != '\0') goto VerifyCharacterToLoadInLexico.
	
	# character is equal '\0'
	li		v0,TRUE					# Cargo en v0 TRUE (que seria el literal 1).
	sw		v0,24($fp)				# Guardo en la direccion de memoria 24($fp) el contenido de v0 (findEnd = TRUE).
$VerifyCharacterToLoadInLexico:
	# findEnd != TRUE
	lw		v1,24($fp)				# Cargo en v1 el contenido de la direccion de memoria 24($fp), que seria findEnd.
	li		v0,TRUE					# Cargo en v0 el literal 1 (TRUE) para hacer luego una comparacion.
	beq		v1,v0,$VerifyQuantityCharacterInLexico  # Si findEnd (v1) es igual a TRUE (v0), salto a VerifyQuantityCharacterInLexico.
	
	# findEnd es igual a TRUE. Continuo validaciones para cargar caracter en lexico.
	# Voy a verificar si el caracter es una keyword.
	lb		v0,40($fp)				# Cargo en v0 el contenido en la direccion de memoria 40($fp), que seria character.
	move		a0,v0					# Muevo el contenido de v0 a a0. Voy a pasar como parametro la variable character a la funcion isKeywords.
	la		t9,isKeywords				# Cargo la direccion de memoria de isKeywords.
	jal		ra,t9					# Ejecuto la funcion isKeywords.
	move		v1,v0					# Muevo el resultado de la funcion isKeywords, que esta en v0, a v1.
	li		v0,TRUE					# Cargo en v0 TRUE, que es el literal 1.
	bne		v1,v0,$VerifyQuantityCharacterInLexico  # Si el resultado de la funcion isKeywords (v1) no es igual a TRUE (v0), salto a VerifyQuantityCharacterInLexico.
	
	# El caracter es una keyword.
	lw		v0,lexico				# Cargo en v0 lo guardado en lexico.
	bne		v0,DIR_NULL,$VerifyMemoryFreeInLexico   # Si el contenido de lexico no apunta a NULL, voy a verificar la memoria disponible para cargarle character (goto VerifyMemoryFreeInLexico).
	
	# Voy a asignar memoria a la variable lexico. lexico es igual a NULL.
	li		a0,LEXICO_BUFFER_SIZE			# Cargo en a0 la cantidad de bytes a asignar por buffer a lexico (es un literal).
	la		t9,malloc				# Cargo en t9 la direccion de la funcion malloc.
	jal		ra,t9					# Ejecuto la funcion malloc.
	sw		v0,lexico				# Guardo en lexico la memoria asignada con malloc (que esta en v0).
	li		v0,LEXICO_BUFFER_SIZE			# Cargo en v0 el literal LEXICO_BUFFER_SIZE (cantidad de bytes a asignar por buffer a lexico).
	sw		v0,bytesLexico				# Guardo el contenido de vo (LEXICO_BUFFER_SIZE) en la variable global bytesLexico.
	b		$LoadCharacterInLexico			# Salto incondicional, voy a cargar caracter en lexico.
$VerifyMemoryFreeInLexico:
	lw		v0,quantityCharacterInLexico		# Cargo en v0 el contenido de quantityCharacterInLexico.
	lw		v1,bytesLexico				# Cargo en v1 el contenido de bytesLexico.
	slt		v0,v0,v1				# Verifico si quantityCharacterInLexico es mas chico que bytesLexico. Guardo resultado en v0 (TRUE o FALSE).
	bne		v0,FALSE,$LoadCharacterInLexico 	# Si quantityCharacterInLexico >= bytesLexico (el contenido de v0 es FALSE, resultado comparacion anterior), voy a LoadCharacterInLexico.
	
	# Realloc para lexico
	lw		v0,bytesLexico				# Cargo en v0 el contenido de bytesLexico.
	sw		v0,44($fp)				# Guardo en la direccion de memoria 44($fp) el contenido de v0, que seria bytesLexico. Representaria la variable bytesLexicoPreview.
	lw		v0,bytesLexico				# Cargo en v0 el contenido de bytesLexico.
	addu		v0,v0,LEXICO_BUFFER_SIZE		# Le sumo a bytesLexico LEXICO_BUFFER_SIZE y guardo resultado en v0.
	sw		v0,bytesLexico				# Guardo el contenido de la suma en bytesLexico.
	lw		a0,lexico				# Cargo en a0 lexico para enviarlo por parametro a myRealloc.
	lw		a1,bytesLexico				# Cargo en a1 bytesLexico para enviarlo por parametro a myRealloc.
	lw		a2,44($fp)				# Cargo en a2 lo guardado en la direccion de memoria 44($fp), que representaba a bytesLexicoPreview, para enviarlo por parametro a myRealloc.
	la		t9,myRealloc				# Cargo en t9 la direccion de la funcion myRealloc.
	jal		ra,t9					# Ejecuto la funcion myRealloc.
	sw		v0,lexico				# Guardo en lexico la nueva direccion de memoria. En v0 esta el resultado de la funcion myRealloc.
$LoadCharacterInLexico:
	lw		v0,lexico				# Cargo en v0 lexico.
	bne		v0,DIR_NULL,$LoadCharacter		# If (lexico != NULL) goto LoadCharacter
	
	# lexico is NULL => Mensaje de error
	li		a0,FILE_DESCRIPTOR_STDERR		# Cargo en a0 FILE_DESCRIPTOR_STDERR.	
	la		a1,MENSAJE_ERROR_MEMORIA_LEXICO # Cargo en a1 la direccion de memoria donde se encuentra el mensaje a cargar.
	li		a2,BYTES_MENSAJE_ERROR_MEMORIA_LEXICO	# Cargo en a2 la cantidad de bytes a escribir.	
	li		v0, SYS_write
	syscall						# No controlo error porque sale de por si de la funcion por error.
	
	li		v0,ERROR_MEMORY				# Cargo en v0 el codigo de error.
	sw		v0,60($fp)				# Guardo el codigo de error (en v0) en la direccion de memoria 60($fp).
	b		$ReturnExecutePalindromeWrite		# Salto incondicional al return de la funcion (goto ReturnExecutePalindromeWrite).
$LoadCharacter:
	# lexico is not NULL
	lw		v1,lexico				# Cargo en v1 lexico.
	lw		v0,quantityCharacterInLexico   		# Cargo en v0 quantityCharacterInLexico.
	addu		v1,v1,v0				# Me desplazo en la direccion de memoria de lexico (v1) la cantidad especificada por quantityCharacterInLexico (v0) y 
								# guardo la nueva posicion en v1.
	lbu		v0,40($fp)				# Cargo en v0 lo almacenado en la direccion de memoria 40($fp), que seria la variable character.
	sb		v0,0(v1)				# Guardo en la posicion de memoria guardada almacenada en v1 (0 de desplazamiento), el contenido de v0 
								# (character). O sea: lexico[quantityCharacterInLexico] = character;
	lw		v0,quantityCharacterInLexico		# Cargo en v0 quantityCharacterInLexico
	addu		v0,v0,1					# Incremento en 1 la cantidad de caracteres guardados en lexico (quantityCharacterInLexico ++;). Este resultado se guarda en v0.
	sw		v0,quantityCharacterInLexico		# Guardo el resultado del incremento (v0) en quantityCharacterInLexico.
	b		$VerifyLoadIBuffer			# Salto incondicional a VerifyLoadIBuffer.
$VerifyQuantityCharacterInLexico:
	# quantityCharacterInLexico > 0 ?
	lw		v0,quantityCharacterInLexico		# Cargo en v0 quantityCharacterInLexico.
	blez		v0,$VerifyLoadIBuffer			# Si quantityCharacterInLexico (v0) es menor que 0, salto a VerifyLoadIBuffer.
	
	# quantityCharacterInLexico > 0 => Verifico si lexico es palindromo.
	lw		a0,lexico				# Cargo en a0 lexico (parametro para la funcion verifyPalindromic).
	lw		a1,quantityCharacterInLexico		# Cargo en a1 quantityCharacterInLexico (parametro para la funcion verifyPalindromic).
	la		t9,verifyPalindromic			# Cargo en t9 la direccion de la verifyPalindromic.
	jal		ra,t9					# Ejecuto la funcion verifyPalindromic.
	sw		v0,44($fp)				# Guardo en la direccion de memoria 44($fp) el resultado de la funcion verifyPalindromic, que esta 
								# almacenado en v0 y que representaria a la variable itsPalindromic.
	lw		v1,44($fp)				# Cargo en v1 lo que se encuentra en la direccion de memoria 44($fp) que seria el resultado de la funcion verifyPalindromic.
	li		v0,TRUE					# Cargo en v0 TRUE (es el literal 1) para hacer luego la comparacion.
	bne		v1,v0,$FreeLexico			# If (itsPalindromic != TRUE) goto FreeLexico.
	
	# itsPalindromic is TRUE
	
	# int amountToSaved = (*amountSavedInOBuffer) + quantityCharacterInLexico;
	lw		v0,84($fp)				# Cargo en v0 lo almacenado en la direccion de memoria 84($fp), que seria la variable *amountSavedInOBuffer.
	lw		v1,0(v0)				# Cargo lo almacenado en la direccion de memoria apuntada por *amountSavedInOBuffer en v1.
	lw		v0,quantityCharacterInLexico		# Cargo en v0 quantityCharacterInLexico.
	addu		v0,v1,v0				# Hago (*amountSavedInOBuffer) + quantityCharacterInLexico, y guardo el resultado en v0.
	sw		v0,48($fp)				# Guardo el resultado de la suma (almacenado el v0) en la direccion de memoria 48($fp), que representaria a la variable amountToSaved.
	
	# (*amountSavedInOBuffer) > 0 ?
	lw		v0,84($fp)				# Cargo en v0 lo almacenado en la direccion de memoria 84($fp), que seria la variable *amountSavedInOBuffer.
	lw		v0,0(v0)				# Cargo lo almacenado en la direccion de memoria apuntada por *amountSavedInOBuffer en v0.
	bgtz		v0,$IncrementAmountToSaved		# Si el contenido de lo almacenado en la direccion apuntada por amountSavedInOBuffer (que esta en v0) 
								# es mas grande que 0, salto a IncrementAmountToSaved.
	
	# (*amountSavedInOBuffer) <= 0
	# savedInOFile == TRUE ?
	lw		v1,savedInOFile				# Cargo en v1 savedInOFile.
	li		v0,TRUE					# Cargo en v0 TRUE (literal igual a 1).
	beq		v1,v0,$IncrementAmountToSaved 		# If (savedInOFile == TRUE) goto IncrementAmountToSaved.
	b		$ContinueVerificationAboutAmountToSaved # Salto incondicional a ContinueVerificationAboutAmountToSaved.
$IncrementAmountToSaved:
	# amountToSaved ++;  Es para el separador entre lexicos
	lw		v0,48($fp)				# Cargo en v0 lo guardado en la direccion de memoria 48($fp), que representaria a la variable amountToSaved.
	addu		v0,v0,1					# Incremento en uno a amountToSaved.
	sw		v0,48($fp)				# Guardo el nuevo valor de amountToSaved (almacenado en v0) en la direccion de memoria 48($fp).
$ContinueVerificationAboutAmountToSaved:
	# amountToSaved > osize ?
	lw		v0,48($fp)				# Cargo en v0 lo guardado en la direccion de memoria 48($fp), que representaria a la variable amountToSaved.
	lw		v1,osize				# Cargo en v1 osize.
	sltu		v0,v1,v0				# Si v1 (osize) es mas chico que v0 (amountToSaved), guardo TRUE en v0, sino guardo FALSE.
	beq		v0,FALSE,$LoadLexicoInOBuffer		# Si el resultado de la comparacion es FALSE (amountToSaved <= osize), salto a LoadLexicoInOBuffer.
	
	# amountToSaved > osize
	# Tomo la decision de pedir mas memoria para bajar el lexico completo
	# y luego rearmo el buffer de salida y reinicio la cantidad guardada en 0.
	
	# obuffer = myRealloc(obuffer, amountToSaved*sizeof(char), (*amountSavedInOBuffer));
	lw		v0,84($fp)				# Cargo en v0 lo guardado en la direccion de memoria 84($fp), que representaria a la variable *amountSavedInOBuffer.
	lw		a0,obuffer				# Cargo en a0 obuffer (parametro para la funcion myRealloc).
	lw		a1,48($fp)				# Cargo en a1 lo guardado en la direccion de memoria 48($fp), que representaria a la variable *amountToSaved. Parametro 
								# para la funcion myRealloc.
	lw		a2,0(v0)				# Cargo en a2 lo almacenado en la direccion de memoria guardada en v0 (parametro para la funcion myRealloc).
	la		t9,myRealloc				# Cargo en t9 la direccion de la myRealloc.
	jal		ra,t9					# Ejecuto myRealloc con los parametros: myRealloc(obuffer, amountToSaved*sizeof(char), (*amountSavedInOBuffer));
	sw		v0,obuffer				# Asigno a obuffer el resultado de myRealloc almacenado en v0.
	
	# (*amountSavedInOBuffer) > 0 ?
	lw		v0,84($fp)				# Cargo en v0 lo guardado en la direccion de memoria 84($fp), que representaria a la variable *amountSavedInOBuffer.
	lw		v0,0(v0)				# Cargo en v0 lo almacenado en la direccion de memoria guardada en v0 (*amountSavedInOBuffer).
	bgtz		v0,$LoadEnterInOBuffer			# Si el contenido de v0 (*amountSavedInOBuffer) es mayor a 0, salta LoadEnterInOBuffer.
	
	# (*amountSavedInOBuffer) <= 0 => continuo verificando si debo de guardar un enter ('\n').
	# savedInOFile == TRUE ?
	lw		v1,savedInOFile				# Cargo en v1 savedInOFile.
	li		v0,TRUE					# Cargo en v0 TRUE (literal igual a 1) para luego hacer comparacion.
	beq		v1,v0,$LoadEnterInOBuffer		# If (savedInOFile == TRUE), goto LoadEnterInOBuffer.
	b		$LoadLexicoInOBufferToWriteFile 	# Salto incondicional a LoadLexicoInOBufferToWriteFile.
$LoadEnterInOBuffer:
	# (*amountSavedInOBuffer) > 0 || savedInOFile == TRUE
	
	# obuffer[*amountSavedInOBuffer] = '\n';
	lw		v0,84($fp)				# Cargo en v0 lo guardado en la direccion de memoria 84($fp), que representaria a la variable *amountSavedInOBuffer.
	lw		v1,obuffer				# Cargo en v1 obuffer.
	lw		v0,0(v0)				# Cargo en v0 lo almacenado en la direccion de memoria guardada en v0 (*amountSavedInOBuffer).
	addu		v1,v1,v0				# Me muevo en la memoria: obuffer + (* amountSavedInOBuffer). La nueva direccion la guardo en v1.
	li		v0,LINE_BREAK				# Cargo en v0 el salto de linea (literal 10).
	sb		v0,0(v1)				# Cargo el salto de linea en la direccion apuntada por v1: obuffer[*amountSavedInOBuffer] = '\n';
	
	# *amountSavedInOBuffer = (*amountSavedInOBuffer) + 1;
	lw		v1,84($fp)				# Cargo en v1 lo guardado en la direccion de memoria 84($fp), que representaria a la variable *amountSavedInOBuffer.
	lw		v0,84($fp)				# Cargo en v0 lo guardado en la direccion de memoria 84($fp), que representaria a la variable *amountSavedInOBuffer.
	lw		v0,0(v0)				# Cargo en v0 lo almacenado en la direccion de memoria guardada en v0 (*amountSavedInOBuffer).
	addu		v0,v0,1					# Incremento en 1 el contenido apuntado por amountSavedInOBuffer. Guardo resultado en v0.
	sw		v0,0(v1)				# Guardo el incremento en la direccion apuntada por amountSavedInOBuffer.
$LoadLexicoInOBufferToWriteFile:
	sw		zero,52($fp)				# Creo un indice (i) en la direccion de memoria 52($fp), inicializado en 0.
$ForLexicoInOBuffer:
	lw		v0,52($fp)				# Cargo el indice i en v0.
	lw		v1,quantityCharacterInLexico		# Cargo en v1 quantityCharacterInLexico.
	slt		v0,v0,v1				# Guardo TRUE en v0 si (i < quantityCharacterInLexico), sino guardo FALSE.
	bne		v0,FALSE,$InForLexicoInOBuffer		# Si el resultado de la comparacion no es FALSE, o sea, (i < quantityCharacterInLexico), entro al for (goto InForLexicoInOBuffer).
	b		$WriteLexicoInOFile			# Salto incondicional a WriteLexicoInOFile.
$InForLexicoInOBuffer:
	# obuffer[*amountSavedInOBuffer] = lexico[i];
	lw		v0,84($fp)						# Cargo en v0 lo guardado en la direccion de memoria 84($fp), que representaria a la variable *amountSavedInOBuffer.
	lw		v1,obuffer						# Cargo en v1 obuffer.
	lw		v0,0(v0)						# Cargo en v0 lo almacenado en la direccion de memoria guardada en v0 (*amountSavedInOBuffer).
	addu		a0,v1,v0						# Guardo en a0 la nueva direccion de memoria sobre obuffer: obuffer + *amountSavedInOBuffer = obuffer[*amountSavedInOBuffer]
	lw			v1,lexico						# Cargo en v1 lexico.
	lw			v0,52($fp)						# Cargo en v0 el indice i guardado en la direccion de memoria 52($fp).
	addu		v0,v1,v0						# Guardo en v0 la nueva direccion de memoria sobre lexico: lexico + i = lexico[i]
	lbu			v0,0(v0)						# Cargo en v0 lo guardado en la direccion de memoria almacenada en v0 (es sobre lexico).
	sb			v0,0(a0)						# Guardo en la direccion de memoria almacenada en a0 (es sobre obuffer) lo almacenado en v0. O sea: obuffer[*amountSavedInOBuffer] = lexico[i];
	
	# *amountSavedInOBuffer = (*amountSavedInOBuffer) + 1;
	lw			v1,84($fp)						# Cargo en v1 lo guardado en la direccion de memoria 84($fp), que representaria a la variable *amountSavedInOBuffer.
	lw			v0,84($fp)						# Cargo en v0 lo guardado en la direccion de memoria 84($fp), que representaria a la variable *amountSavedInOBuffer.
	lw			v0,0(v0)						# Cargo en v0 lo almacenado en la direccion de memoria guardada en v0 (*amountSavedInOBuffer).
	addu		v0,v0,1						# Incremento en 1 el contenido apuntado por amountSavedInOBuffer.
	sw			v0,0(v1)						# Guardo el incremento.
	
	# ++ i
	lw			v0,52($fp)						# Cargo en v0 el indice i guardado en la direccion de memoria 52($fp).
	addu		v0,v0,1						# Incremento en 1 el indice i.
	sw			v0,52($fp)						# Guardo el incremento.
	b			$ForLexicoInOBuffer				# Salto incondicional. Vuelvo al comienzo del loop for.
$WriteLexicoInOFile:
	# int rdoWrite = writeOBufferInOFile(amountSavedInOBuffer);
	lw			a0,84($fp)						# Cargo en a0 lo guardado en la direccion de memoria 84($fp), que representaria a la variable *amountSavedInOBuffer. Parametro de la funcion writeOBufferInOFile.
	la			t9,writeOBufferInOFile			# Cargo en t9 la direccion de la writeOBufferInOFile.
	jal			ra,t9							# Ejecuto la funcion writeOBufferInOFile.
	sw			v0,56($fp)						# Guardo en la direccion de memoria 56($fp) el resultado de ejecutar la funcion writeOBufferInOFile almacenado en v0.
	
	# rdoWrite != OKEY ?
	lw			v0,56($fp)						# Cargo en v0 el resultado de la ejecucion de la funcion writeOBufferInOFile, que seria la variable rdoWrite.
	beq			v0,OKEY,$WriteInNewOBuffer		# If (rdoWrite == OKEY) goto WriteInNewOBuffer.
	lw			v0,56($fp)						# Cargo en v0 el resultado de la ejecucion de la funcion writeOBufferInOFile, que seria la variable rdoWrite.
	sw			v0,60($fp)						# Guardo el codigo de error (en v0) en la direccion de memoria 60($fp).
	b			$ReturnExecutePalindromeWrite	# Salto incondicional al return de la funcion (goto ReturnExecutePalindromeWrite).
$WriteInNewOBuffer:
	# *amountSavedInOBuffer = 0;
	lw			v0,84($fp)						# Cargo en v0 lo guardado en la direccion de memoria 84($fp), que representaria a la variable *amountSavedInOBuffer.
	sw			zero,0(v0)					# Guardo 0 en la direccion apuntada por amountSavedInOBuffer.
	
	# savedInOFile = TRUE;
	li			v0,TRUE
	sw			v0,savedInOFile				# Guardo en savedInOFile el contenido de v0 (TRUE).
	
	# obuffer != NULL ?
	lw			v0,obuffer						# Cargo en v0 obuffer.
	beq			v0,DIR_NULL,$MallocNewOBuffer	# If (obuffer == NULL) goto MallocNewOBuffer.
	
	# obuffer != NULL => free(obuffer) and obuffer = NULL.
	lw			a0,obuffer						# Cargo en a0 obuffer.
	la			t9,free						# Cargo en t9 la direccion de memoria de free.
	jal			ra,t9							# Ejecuto free sobre obuffer.
	sw			zero,obuffer				# Asigno NULL a obuffer.
$MallocNewOBuffer:
	# obuffer = (char *) malloc(osize*sizeof(char));
	lw			a0,osize						# Cargo en a0 osize.
	la			t9,malloc						# Cargo en t9 la direccion de memoria de malloc.
	jal			ra,t9							# Ejecuto malloc.
	sw			v0,obuffer						# Asigno la nueva direccion de memoria, que se encuentra almacenada en v0, a obuffer.
	
	# obuffer == NULL ?
	lw			v0,obuffer						# Cargo en v0 obuffer.
	bne			v0,DIR_NULL,$InitializeNewOBuffer # If (obuffer != NULL) goto InitializeNewOBuffer.
	
	# obuffer is NULL => Mensaje de error
	li			a0,FILE_DESCRIPTOR_STDERR		# Cargo en a0 FILE_DESCRIPTOR_STDERR.	
	la			a1,MENSAJE_ERROR_MEMORIA_OBUFFER # Cargo en a1 la direccion de memoria donde se encuentra el mensaje a cargar.
	li			a2,BYTES_MENSAJE_ERROR_MEMORIA_OBUFFER	# Cargo en a2 la cantidad de bytes a escribir.	
	li			v0, SYS_write
	syscall						# No controlo error porque sale de por si de la funcion por error.
	
	li			v0,ERROR_MEMORY
	sw			v0,60($fp)						# Guardo el codigo de error (en v0) en la direccion de memoria 60($fp).
	b			$ReturnExecutePalindromeWrite	# Salto incondicional al return de la funcion (goto ReturnExecutePalindromeWrite).
$InitializeNewOBuffer:
	lw			a0,osize						# Cargo en a0 osize. Parametro de la funcion initializeBuffer.
	lw			a1,obuffer						# Cargo en a1 obuffer. Parametro de la funcion initializeBuffer.
	la			t9,initializeBuffer			# Cargo en t9 la direccion de memoria de la funcion initializeBuffer.
	jal			ra,t9							# Ejecuto la funcion initializeBuffer.
	
	b			$FreeLexico						# Salto incondicional a FreeLexico.
$LoadLexicoInOBuffer:
	# (*amountSavedInOBuffer) > 0 ?
	lw			v0,84($fp)						# Cargo en v0 lo guardado en la direccion de memoria 84($fp), que representaria a la variable *amountSavedInOBuffer.
	lw			v0,0(v0)						# Cargo en v0 lo almacenado en la direccion de memoria guardada en v0 (*amountSavedInOBuffer).
	bgtz		v0,$LoadLineBeakInOBuffer		# Si (*amountSavedInOBuffer > 0), voy a guardar el salto de linea para separar lexicos que son palindromos (LoadLineBeakInOBuffer).
	
	# (*amountSavedInOBuffer) <= 0
	# savedInOFile == TRUE ?
	lw			v1,savedInOFile				# Cargo en v1 savedInOFile.
	li			v0,TRUE
	beq			v1,v0,$LoadLineBeakInOBuffer	# Si (savedInOFile == TRUE), voy a guardar el salto de linea para separar lexicos que son palindromos (LoadLineBeakInOBuffer).
	
	b			$LoadLexicoInOBufferNotWriteFile # Salto incondicional a LoadLexicoInOBufferNotWriteFile.
$LoadLineBeakInOBuffer:
	# obuffer[*amountSavedInOBuffer] = '\n';
	lw			v0,84($fp)						# Cargo en v0 lo guardado en la direccion de memoria 84($fp), que representaria a la variable *amountSavedInOBuffer.
	lw			v1,obuffer						# Cargo en v1 obuffer.
	lw			v0,0(v0)						# Cargo en v0 lo almacenado en la direccion de memoria guardada en v0 (*amountSavedInOBuffer).
	addu		v1,v1,v0						# Guardo en v1 la nueva posicion dentro de obuffer: obuffer[*amountSavedInOBuffer] = obuffer + *amountSavedInOBuffer
	li			v0,LINE_BREAK					# Cargo en v0 el literal LINE_BREAK (es 10 que representa a '\n').
	sb			v0,0(v1)						# Guardo en obuffer, en la posicion indicada en v1, LINE_BREAK. O sea: obuffer[*amountSavedInOBuffer] = '\n';
	
	# *amountSavedInOBuffer = (*amountSavedInOBuffer) + 1;
	lw			v1,84($fp)						# Cargo en v1 lo guardado en la direccion de memoria 84($fp), que representaria a la variable *amountSavedInOBuffer. 
	lw			v0,84($fp)						# Cargo en v0 lo guardado en la direccion de memoria 84($fp), que representaria a la variable *amountSavedInOBuffer.
	lw			v0,0(v0)						# Cargo en v0 lo almacenado en la direccion de memoria guardada en v0 (*amountSavedInOBuffer).
	addu		v0,v0,1						# Incremento en 1
	sw			v0,0(v1)						# Guardo nuevo valor de *amountSavedInOBuffer.
$LoadLexicoInOBufferNotWriteFile:
	sw			zero,56($fp)					# Guardo 0 en la direccion de memoria 56($fp). Inicializo indice en 0 para un nuevo loop.
$ForLexicoInOBufferNotWriteFile:
	lw			v0,56($fp)						# Cargo en v0 el indice (i) en 0.
	lw			v1,quantityCharacterInLexico	# Cargo en v1 quantityCharacterInLexico.
	slt			v0,v0,v1						# Guado en v0 TRUE si el indice i es menor que quantityCharacterInLexico. Caso contrario guardo FALSE
	bne			v0,FALSE,$GoInForLexicoInOBufferNotWriteFile # Si (i < quantityCharacterInLexico) goto GoInForLexicoInOBufferNotWriteFile.
	b			$FreeLexico
$GoInForLexicoInOBufferNotWriteFile:
	# obuffer[*amountSavedInOBuffer] = lexico[i];
	lw			v0,84($fp)						# Cargo en v0 lo guardado en la direccion de memoria 84($fp), que representaria a la variable *amountSavedInOBuffer.
	lw			v1,obuffer						# Cargo en v1 obuffer.
	lw			v0,0(v0)						# Cargo en v0 lo almacenado en la direccion de memoria guardada en v0 (*amountSavedInOBuffer).
	addu		a0,v1,v0						# Guardo en v1 la nueva posicion dentro de obuffer: obuffer[*amountSavedInOBuffer] = obuffer + *amountSavedInOBuffer
	lw			v1,lexico						# Cargo en v1 lexico.
	lw			v0,56($fp)						# Cargo en v0 el indice i.				
	addu		v0,v1,v0						# Guardo en v0 la nueva posicion dentro de lexico: lexico[i] = lexico + i
	lbu			v0,0(v0)						# Cargo en v0 el contenido de la posicion dentro de lexico.
	sb			v0,0(a0)						# Guardo en la direccion apuntada por a0 (posicion dentro de obuffer0 el contenido almacenado en v0: obuffer[*amountSavedInOBuffer] = lexico[i];
	
	# *amountSavedInOBuffer = (*amountSavedInOBuffer) + 1;
	lw			v1,84($fp)
	lw			v0,84($fp)
	lw			v0,0(v0)
	addu		v0,v0,1						# Incremento en 1 a *amountSavedInOBuffer.
	sw			v0,0(v1)						# Guardo el nuevo valor de *amountSavedInOBuffer.
	
	# ++i
	lw			v0,56($fp)						# Cargo en v0 el indice i.				
	addu		v0,v0,1						# Incremento el indice.
	sw			v0,56($fp)						# Guardo nuevo valor del indice.
	b			$ForLexicoInOBufferNotWriteFile # Salto al principio del for para intentar entrar nuevamente al loop.
$FreeLexico:
	lw			a0,lexico						# Cargo en a0 lexico.
	la			t9,free						# Cargo en t9 la direccion de la funcion free.
	jal			ra,t9							# Ejecuto la funcion free
	sw			zero,lexico					# Asigno NULL a lexico.
	sw			zero,quantityCharacterInLexico # Dejo quantityCharacterInLexico en 0.
$VerifyLoadIBuffer:
	# (idx + 1) == isize ?
	lw			v0,32($fp)						# Cargo en v0 lo guardado en la direccion 32($fp), que seria la variable idx.
	addu		v1,v0,1						# Incremento en 1 a idx y lo guardo en v1.
	lw			v0,isize						# Cargo en v0 isize para luego hacer comparacion.
	bne			v1,v0,$IncrementIdx			# If ((idx+1) != isize) goto IncrementIdx
	
	# ((idx + 1) == isize) is TRUE
	li			v0,TRUE
	sw			v0,28($fp)						# Guardo en la direccion 28($fp), que estaba la variable loadIBuffer, TRUE.
	li			v0,LOAD_I_BUFFER
	sw			v0,36($fp)						# Guardo en la direccion 36($fp), que estaba la variable rdo -resultado de la operacion-, LOAD_I_BUFFER.
	
	b			$WhileExecPalindromeWrite		# Salto incondicional al comienzo del while para verificar entrada al mismo.
$IncrementIdx:
	# idx ++
	lw			v0,32($fp)						# Cargo en v0 idx, guardado en la direccion 32($fp).
	addu		v0,v0,1						# Incremento en 1 a idx.
	sw			v0,32($fp)						# Guardo el nuevo valor de idx.
	
	b			$WhileExecPalindromeWrite		# Salto incondicional al comienzo del while para verificar entrada al mismo.
$LeaveWhileExecPalindromeWrite:
	lw			v0,36($fp)						# Cargo en v0 el resultado del while: variable rdo guardada en la direccion 36($fp).
	sw			v0,60($fp)						# Guardo en 60($fp) el resultado de la funcion.
$ReturnExecutePalindromeWrite:
	lw			v0,60($fp)
	move		sp,$fp
	lw			ra,72(sp)
	lw			$fp,68(sp)
	addu		sp,sp,80
	j			ra								# Jump and return
	.end		executePalindromeWrite
	.size		executePalindromeWrite, .-executePalindromeWrite


##-----	palindrome -----##
		
	.align		2
	.globl		palindrome
	.ent		palindrome
palindrome:
	.frame		$fp,80,ra		# vars= 40, regs= 3/0, args= 16, extra= 8	
	.set		noreorder
	.cpload		t9
	.set		reorder
	
	#Stack frame creation
	subu		sp,sp,80
	
	.cprestore 16
	sw			ra,72(sp)
	sw			$fp,68(sp)
	sw			gp,64(sp)
	move		$fp,sp
	
	# Parameters
	sw			a0,80($fp)						# Guardo en la direccion de memoria 80($fp) la variable ifd (int ifd).
	sw			a1,84($fp)						# Guardo en la direccion de memoria 84($fp) la variable ibytes (size_t ibytes).
	sw			a2,88($fp)						# Guardo en la direccion de memoria 88($fp) la variable ofd (int ofd).
	sw			a3,92($fp)						# Guardo en la direccion de memoria 92($fp) la variable obytes (size_t obytes).
	
	# isize = ibytes;
	lw			v0,84($fp)						# Cargo en v0 ibytes, guardado en 84($fp).
	sw			v0,isize						# Guardo en isize ibytes.
	
	# osize = obytes;
	lw			v0,92($fp)						# Cargo en v0 obytes, guardado en 92($fp).
	sw			v0,osize						# Guardo en osize obytes.
	
	# oFileDescriptor = ofd;
	lw			v0,88($fp)						# Cargo en v0 ofd, guardado en 88($fp).
	sw			v0,oFileDescriptor				# Guardo en oFileDescriptor ofd.
	
	# char * ibuffer = (char *) malloc(ibytes*sizeof(char));
	lw			a0,84($fp)						# Cargo en a0 ibytes, guardado en 84($fp). Parametro de la funcion malloc.
	la			t9,malloc						# Cargo en t9 la direccion de la funcion malloc.
	jal			ra,t9							# Ejecuto la funcion malloc.
	sw			v0,24($fp)						# En v0 esta el resultado de malloc. Guardo esto en la direccion 24($fp) que representaria la variable * ibuffer.
	
	# ibuffer == NULL ?
	lw			v0,24($fp)						# Cargo en v0 *ibuffer, guardado en la direccion 24($fp).
	bne			v0,DIR_NULL,$OBufferMalloc		# If (ibuffer != NULL) goto OBufferMalloc
	
	# ibuffer is NULL => Mensaje de error
	li			a0,FILE_DESCRIPTOR_STDERR		# Cargo en a0 FILE_DESCRIPTOR_STDERR.
	la			a1,MENSAJE_ERROR_MEMORIA_IBUFFER # Cargo en a1 la direccion de memoria donde se encuentra el mensaje a cargar.
	li			a2,BYTES_MENSAJE_ERROR_MEMORIA_IBUFFER	# Cargo en a2 la cantidad de bytes a escribir.
	li			v0, SYS_write
	syscall						# No controlo error porque sale de por si de la funcion por error.
	
	li			v0,ERROR_MEMORY				# Cargo en v0 el codigo de error.	
	sw			v0,60($fp)						# Guardo el codigo de error (en v0) en la direccion de memoria 60($fp).
	b			$ReturnPalindrome				# Salto incondicional al return de la funcion (goto ReturnPalindrome).
$OBufferMalloc:
	# obuffer = (char *) malloc(obytes*sizeof(char));
	lw			a0,92($fp)						# Cargo en a0 obytes. Parametro de la funcion malloc.
	la			t9,malloc						# Cargo en t9 la direccion de la funcion malloc.
	jal			ra,t9							# Ejecuto la funcion malloc.
	sw			v0,obuffer						# En v0 esta el resultado de malloc. Guardo esto en obuffer.
	
	# obuffer == NULL ?
	lw			v0,obuffer						# Cargo en v0 obuffer.
	bne			v0,DIR_NULL,$InitializeBuffers # If (obuffer != NULL) goto InitializeBuffers
	
	# obuffer is NULL => Mensaje de error
	li			a0,FILE_DESCRIPTOR_STDERR		# Cargo en a0 FILE_DESCRIPTOR_STDERR.
	la			a1,MENSAJE_ERROR_MEMORIA_OBUFFER # Cargo en a1 la direccion de memoria donde se encuentra el mensaje a cargar.
	li			a2,BYTES_MENSAJE_ERROR_MEMORIA_OBUFFER	# Cargo en a2 la cantidad de bytes a escribir.
	li			v0, SYS_write
	syscall						# No controlo error porque sale de por si de la funcion por error.
	
	# free(ibuffer)
	lw			a0,24($fp)						# Cargo en a0 ibuffer. Parametro de la funcion free.
	la			t9,free						# Cargo en t9 direccion de la funcion free.
	jal			ra,t9							# Ejecuto la funcion free.
	sw			zero,24($fp)				# Asigno NULL a ibuffer.
	
	li			v0,ERROR_MEMORY				# Cargo en v0 el codigo de error.	
	sw			v0,60($fp)						# Guardo el codigo de error (en v0) en la direccion de memoria 60($fp).
	b			$ReturnPalindrome				# Salto incondicional al return de la funcion (goto ReturnPalindrome).	
$InitializeBuffers:
	# initialize the ibuffer: initializeBuffer(ibytes, ibuffer);
	lw			a0,84($fp)						# Cargo en a0 ibytes. Parametro de la funcion initializeBuffer.
	lw			a1,24($fp)						# Cargo en a1 ibuffer. Parametro de la funcion initializeBuffer.
	la			t9,initializeBuffer			# Cargo en t9 la direccion de la funcion initializeBuffer.
	jal			ra,t9							# Ejecuto la funcion initializeBuffer.
	
	# initialize the obuffer: initializeBuffer(obytes, obuffer);
	lw			a0,92($fp)						# Cargo en a0 0bytes. Parametro de la funcion initializeBuffer.
	lw			a1,obuffer						# Cargo en a1 0buffer. Parametro de la funcion initializeBuffer.
	la			t9,initializeBuffer			# Cargo en t9 la direccion de la funcion initializeBuffer.
	jal			ra,t9							# Ejecuto la funcion initializeBuffer.
	
	# int * amountSavedInOBuffer = (int *) malloc(sizeof(int));
	li			a0,4							# Cargo en a0 la cantidad de bytes a asignar (por ser un int, son 4 bytes).
	la			t9,malloc						# Cargo en t9 la direccion de la funcion malloc.
	jal			ra,t9							# Ejecuto la funcion malloc.
	sw			v0,28($fp)						# En v0 esta el resultado de malloc. Asigno este resultado a la direccion 28($fp), que representaria a la variable * amountSavedInOBuffer.
	
	# amountSavedInOBuffer == NULL ?
	lw			v0,28($fp)						# Cargo en v0 amountSavedInOBuffer
	bne			v0,DIR_NULL,$ContinueProcessToLoadIBuffer # If (amountSavedInOBuffer != NULL) goto ContinueProcessToLoadIBuffer
	
	# amountSavedInOBuffer is NULL => Mensaje de error
	li			a0,FILE_DESCRIPTOR_STDERR		# Cargo en a0 FILE_DESCRIPTOR_STDERR.
	la			a1,MENSAJE_ERROR_MEMORIA_AMOUNT_SAVED # Cargo en a1 la direccion de memoria donde se encuentra el mensaje a cargar.
	li			a2,BYTES_MENSAJE_ERROR_MEMORIA_AMOUNT_SAVED # Cargo en a2 la cantidad de bytes a escribir.
	li			v0, SYS_write
	syscall						# No controlo error porque sale de por si de la funcion por error.
	
	# free(ibuffer)
	lw			a0,24($fp)						# Cargo en a0 ibuffer. Parametro de la funcion free.
	la			t9,free						# Cargo en t9 la direccion de la funcion free.
	jal			ra,t9							# Ejecuto la funcion free.
	sw			zero,24($fp)				# Asigno NULL a ibuffer.
	
	# free(obuffer)
	lw			a0,obuffer						# Cargo en a0 obuffer. Parametro de la funcion free.
	la			t9,free						# Cargo en t9 la direccion de la funcion free.
	jal			ra,t9							# Ejecuto la funcion free.
	sw			zero,obuffer				# Asigno NULL a obuffer.
	
	li			v0,ERROR_MEMORY				# Cargo en v0 el codigo de error.	
	sw			v0,60($fp)						# Guardo el codigo de error (en v0) en la direccion de memoria 60($fp).
	b			$ReturnPalindrome				# Salto incondicional al return de la funcion (goto ReturnPalindrome).	
$ContinueProcessToLoadIBuffer:
	# amountSavedInOBuffer[0] = 0;
	lw			v0,28($fp)						# Cargo en v0 amountSavedInOBuffer.
	sw			zero,0(v0)					# Asigno a amountSavedInOBuffer el valor 0.
	
	# int rdoProcess = OKEY;
	sw			zero,32($fp)					# Asigno a rdoProcess, que esta en la direccion 32($fp), el valor OKEY.
	
	# int end = FALSE;
	sw			zero,36($fp)					# Asigno a end, que esta en la direccion 36($fp), el valor FALSE.
	
	# int error = FALSE;
	sw			zero,40($fp)					# Asigno a error, que esta en la direccion 40($fp), el valor FALSE.
$WhilePalindrome:
	# end == FALSE ?
	lw			v0,36($fp)						# Cargo en v0 end.
	bne			v0,FALSE,$FreeBuffers			# If (end != FALSE) goto FreeBuffers.
	
#	# end is FALSE
	
#	# error == FALSE ?
	lw			v0,40($fp)						# Cargo en v0 end.
	bne			v0,FALSE,$FreeBuffers			# If (error != FALSE) goto FreeBuffers.
	
#	#  error is FALSE
	
	# Within the while
	
	# int completeDelivery = FALSE;
	sw			zero,44($fp)					# Guardo FALSE en la direccion 44($fp), que representaria la variable completeDelivery.
	
	# int bytesReadAcum = 0;
	sw			zero,48($fp)					# Guardo 0 en la direccion 48($fp), que representaria la variable bytesReadAcum.
	
#	#  size_t bytesToRead = ibytes;
	lw			v0,84($fp)						# Cargo en v0 ibytes, que esta en la direccion 84($fp).
	sw			v0,52($fp)						# Guardo ibytes (que esta en v0) en la direccion 52($fp), que representaria la variable bytesToRead.
$WhileLoadIBuffer:
	# completeDelivery == FALSE ?
	lw			v0,44($fp)						# Cargo en v0 completeDelivery.
	bne			v0,FALSE,$VerifyIfWriteOFile	# If (completeDelivery != FALSE) goto VerifyIfWriteOFile.
	
	# end == FALSE
	lw			v0,36($fp)						# Cargo en v0 end.
	bne			v0,FALSE,$VerifyIfWriteOFile	# If (end != FALSE) goto VerifyIfWriteOFile.
	
	# Read iterative
	
	# int bytesRead = read(ifd, ibuffer + bytesReadAcum, bytesToRead);
	lw			v1,24($fp)						# Cargo en v1 ibuffer.
	lw			v0,48($fp)						# Cargo en v0 bytesReadAcum.
	addu		v0,v1,v0						# Guardo en v0 el resultado de ibuffer + bytesReadAcum.
	lw			a0,80($fp)						# Cargo en a0 ifd. Parametro de la funcion read.
	move		a1,v0							# Cargo en a1 la direccion del buffer a donde se van a guardar los bytes leidos (ibuffer + bytesReadAcum). Parametro de la funcion read.
	lw			a2,52($fp)						# Cargo en a2 bytesToRead. Parametro de la funcion read.
	li			v0, SYS_read
	syscall						# Seria read: int bytesRead = read(ifd, ibuffer + bytesReadAcum, bytesToRead);
	
	# Controlo errores y cantidad de bytes leidos. v0 contiene el numero de caracteres leidos (es negativo si hubo error y es 0 si llego a fin del archivo).	
	sw			v0,56($fp)						# Guardo en la direccion de memoria 56($fd) el resultado de la funcion read, que estaria representado por la variable bytesRead.
	
	# bytesRead == -1 ?
	lw			v1,56($fp)						# Cargo en v1 bytesRead.
	li			v0,-1							# Cargo en v0 -1 para la comparacion.
	bne			v1,v0,$ContinueValidationResultRead # If (bytesRead != -1) goto ContinueValidationResultRead.
	
	# bytesRead is -1 => Mensaje de error.
	li			a0,FILE_DESCRIPTOR_STDERR		# Cargo en a0 FILE_DESCRIPTOR_STDERR.
	la			a1,MENSAJE_ERROR_LECTURA_ARCHIVO # Cargo en a1 la direccion de memoria donde se encuentra el mensaje a cargar.
	li			a2,BYTES_MENSAJE_ERROR_LECTURA_ARCHIVO	# Cargo en a2 la cantidad de bytes a escribir.
	li			v0, SYS_write
	syscall						# No controlo error porque sale de por si de la funcion por error.
	
	# free(ibuffer)	
	lw			a0,24($fp)						# Cargo en a0 ibuffer. Parametro de la funcion free.
	la			t9,free						# Cargo la direccion de la funcion free.
	jal			ra,t9							# Ejecuto la funcion free.
	sw			zero,24($fp)				# Asigno NULL a ibuffer.
	
	# free(obuffer)
	lw			a0,obuffer						# Cargo en a0 obuffer. Parametro de la funcion free.
	la			t9,free						# Cargo la direccion de la funcion free.
	jal			ra,t9							# Ejecuto la funcion free.
	sw			zero,obuffer				# Asigno NULL a obuffer.
	
	# free(amountSavedInOBuffer)
	lw			a0,28($fp)						# Cargo en a0 amountSavedInOBuffer. Parametro de la funcion free.
	la			t9,free						# Cargo la direccion de la funcion free.
	jal			ra,t9							# Ejecuto la funcion free.
	sw			zero,28($fp)				# Asigno NULL a amountSavedInOBuffer.
	
	# lexico != NULL ?
	lw			v0,lexico						# Cargo en v0 lexico.
	beq			v0,DIR_NULL,$ReturnErrorRead	# If (lexico == NULL) goto ReturnErrorRead.
	
	# lexico is not NULL
	lw			a0,lexico						# Cargo en a0 lexico. Parametro de la funcion free.
	la			t9,free						# Cargo la direccion de la funcion free.
	jal			ra,t9							# Ejecuto la funcion free.
	sw			zero,lexico					# Asigno NULL a lexico.
$ReturnErrorRead:
	li			v0,ERROR_READ					# Cargo en v0 el codigo de ERROR_READ.
	sw			v0,60($fp)						# Guardo en la direccion 60($fp) el resultado de la funcion palindrome, que en este caso es un error.
	b			$ReturnPalindrome				# Salto incondicional al return de la funcion palindrome.
$ContinueValidationResultRead:
	lw			v0,56($fp)						# Cargo en v1 bytesRead.
	bne			v0,zero,$ContinueAccumulatingBytesRead # If (bytesRead != 0) goto ContinueAccumulatingBytesRead
	li			v0,TRUE			
	sw			v0,36($fp)						# Asigno a la variable end, guardada en 36($fp), TRUE.
$ContinueAccumulatingBytesRead:
	# bytesReadAcum += bytesRead;
	lw			v1,48($fp)						# Cargo en v1 bytesReadAcum.
	lw			v0,56($fp)						# Cargo en v0 bytesRead.
	addu		v0,v1,v0						# Sumo bytesReadAcum con bytesRead y guardo resultado en v0.
	sw			v0,48($fp)						# Guardo el resultado de la suma en bytesReadAcum.
	
	# bytesToRead = ibytes - bytesReadAcum;
	lw			v1,84($fp)						# Cargo en v1 ibytes.
	lw			v0,48($fp)						# Cargo en v0 bytesReadAcum.
	subu		v0,v1,v0						# Resto ibytes con bytesReadAcum y guardo resultado en v0, para saber cuandos bytes restan por leer del archivo.
	sw			v0,52($fp)						# Asigno a bytesToRead el resultado de la resta.
	
	# bytesToRead == 0 ?
	lw			v0,52($fp)						# Cargo en v0 bytesToRead.
	bne			v0,zero,$WhileLoadIBuffer		# If (bytesToRead != 0) goto WhileLoadIBuffer
	
	# bytesToRead is 0.
	li			v0,TRUE
	sw			v0,44($fp)						# Asigno a completeDelivery TRUE.
	b			$WhileLoadIBuffer				# Salto incondicional al comienzo del while para cargar el buffer con los datos del archivo (goto WhileLoadIBuffer).
$VerifyIfWriteOFile:
	# Verifico si tengo datos en el buffer de entrada para verificar palindromos, 
	# guardar en el buffer de salida y en el archivo de salida si corresponde.
	
	# ibuffer != NULL && ibuffer[0] != '\0' ?
	
	# ibuffer != NULL ?
	lw			v0,24($fp)						# Cargo en v0 ibuffer.
	beq			v0,DIR_NULL,$WhilePalindrome	# If (ibuffer == NULL) goto WhilePalindrome.
	
	# ibuffer is not NULL
	
	# ibuffer[0] != '\0' ?
	lw			v0,24($fp)						# Cargo en v0 ibuffer.
	lb			v0,0(v0)						# Cargo en contenido de la primer posicion de ibuffer en v0.
	beq			v0,zero,$WhilePalindrome		# If (ibuffer[0] == '\0') goto WhilePalindrome
	
	# ibuffer[0] is not equal '\0'
	
	# int resultProcessWrite = executePalindromeWrite(ibuffer, amountSavedInOBuffer);
	lw			a0,24($fp)						# Cargo en a0 ibuffer. Parametro de la funcion executePalindromeWrite.
	lw			a1,28($fp)						# Cargo en a1 amountSavedInOBuffer. Parametro de la funcion executePalindromeWrite.
	la			t9,executePalindromeWrite		# Cargo en t9 la direccion de memoria en donde se encuentra la funcion executePalindromeWrite.
	jal			ra,t9							# Ejecuto la funcion executePalindromeWrite.
	sw			v0,56($fp)						# El resultado de la ejecucion de la funcion executePalindromeWrite esta en v0. Guardo este resultado en la direccion de memoria 56($fp), que representaria a la variable resultProcessWrite.
	
	# resultProcessWrite == LOAD_I_BUFFER ?
	lw			v1,56($fp)						# Cargo en v1 resultProcessWrite.
	li			v0,LOAD_I_BUFFER
	bne			v1,v0,$ContinueValidationResultExecutePalinWrite # If (resultProcessWrite != LOAD_I_BUFFER) goto ContinueValidationResultExecutePalinWrite.
	
	# resultProcessWrite is equal LOAD_I_BUFFER
	
	# initializeBuffer(ibytes, ibuffer);
	lw			a0,84($fp)						# Cargo en a0 ibytes. Parametro de la funcion initializeBuffer.
	lw			a1,24($fp)						# Cargo en a1 ibuffer. Parametro de la funcion initializeBuffer.
	la			t9,initializeBuffer			# Cargo en t9 la direccion de la funcion initializeBuffer.
	jal			ra,t9							# Ejecuto la funcion initializeBuffer.
$ContinueValidationResultExecutePalinWrite:
	# (resultProcessWrite == ERROR_MEMORY || resultProcessWrite == ERROR_WRITE) ?
	
	# resultProcessWrite == ERROR_MEMORY ?
	lw			v1,56($fp)						# Cargo en v1 resultProcessWrite.
	li			v0,ERROR_MEMORY
	beq			v1,v0,$LoadErrorOfExecutePalinWrite # If (resultProcessWrite == ERROR_MEMORY) goto LoadErrorOfExecutePalinWrite.
	
	# resultProcessWrite is not equal ERROR_MEMORY
	
	# resultProcessWrite == ERROR_WRITE ?
	lw			v1,56($fp)						# Cargo en v1 resultProcessWrite.
	li			v0,ERROR_WRITE
	beq			v1,v0,$LoadErrorOfExecutePalinWrite # If (resultProcessWrite == ERROR_WRITE) goto LoadErrorOfExecutePalinWrite.
	
	# No hay errores
	b			$WhilePalindrome				# Vuelvo a intentar entrar al loop.
$LoadErrorOfExecutePalinWrite:
#	# error = TRUE;
	li			v0,TRUE
	sw			v0,40($fp)						# Asigno a la variable error TRUE.
	
	# rdoProcess = resultProcessWrite;
	lw			v0,56($fp)						# Cargo en v0 resultProcessWrite.
	sw			v0,32($fp)						# Asigno a la variable rdoProcess resultProcessWrite.
	
	b			$WhilePalindrome				# Vuelvo a intentar entrar al loop.
$FreeBuffers:
	# (ibuffer != NULL) ?
	lw			v0,24($fp)						# Cargo en v0 ibuffer.
	beq			v0,DIR_NULL,$FreeOBufferInPalindrome # If (ibuffer == NULL) goto FreeOBufferInPalindrome
	
	# ibuffer es not NULL
	lw			a0,24($fp)						# Cargo en a0 ibuffer. Parametro de la funcion free.
	la			t9,free						# Cargo en t9 la direccion de la funcion free.
	jal			ra,t9							# Ejecuto la funcion free.
	sw			zero,24($fp)				# Asigno a ibuffer NULL.
$FreeOBufferInPalindrome:
	# (obuffer != NULL) ?
	lw			v0,obuffer						# Cargo en v0 obuffer.
	beq			v0,DIR_NULL,$FreeLexicoInPalindrome # If (obuffer == NULL) goto FreeLexicoInPalindrome.
	
	# obuffer is not NULL
	
	# (amountSavedInOBuffer != NULL && (*amountSavedInOBuffer) > 0) ?
	
	# (amountSavedInOBuffer != NULL) ?
	lw			v0,28($fp)						# Cargo en v0 amountSavedInOBuffer.
	beq			v0,DIR_NULL,$FreeLexicoPalin	# If (amountSavedInOBuffer == NULL) goto FreeLexicoPalin.
	
	# amountSavedInOBuffer is not NULL
	
	# ((*amountSavedInOBuffer) > 0) ?
	lw			v0,28($fp)						# Cargo en v0 amountSavedInOBuffer.
	lw			v0,0(v0)						# Cargo el contenido de lo apuntado por amountSavedInOBuffer en v0.
	blez		v0,$FreeLexicoPalin			# If ((* amountSavedInOBuffer) <= 0) goto FreeLexicoPalin.
	
	# (*amountSavedInOBuffer) is greater then 0
	
	# int rdoWrite = writeOBufferInOFile(amountSavedInOBuffer);
	lw			a0,28($fp)						# Cargo en a0 amountSavedInOBuffer. Parametro de la funcion writeOBufferInOFile.
	la			t9,writeOBufferInOFile			# Cargo en t9 la direccion de la funcion writeOBufferInOFile.
	jal			ra,t9							# Ejecuto la funcion writeOBufferInOFile.
	sw			v0,56($fp)						# En v0 esta el resultado de writeOBufferInOFile (que seria la variable rdoWrite). Guado esto en la direccion 56($fp).
	
	# (rdoWrite != OKEY) ?
	lw			v0,56($fp)						# Cargo en v0 rdoWrite.
	beq			v0,OKEY,$FreeLexicoPalin		# If (rdoWrite == OKEY) goto FreeLexicoPalin.
	
	# rdoWrite is OKEY.
	
	# rdoProcess = rdoWrite;
	lw			v0,56($fp)						# Cargo en v0 rdoWrite.
	sw			v0,32($fp)						# Asigno a la variable rdoProcess rdoWrite.
$FreeLexicoPalin:
	# free(obuffer);
	lw			a0,obuffer						# Cargo en a0 obuffer. Parametro de la funcion free.
	la			t9,free						# Cargo en t9 la direccion de la funcion free.
	jal			ra,t9							# Ejecuto la funcion free.
	sw			zero,obuffer				# Asigno NULL a obuffer.
$FreeLexicoInPalindrome:
	# (lexico != NULL) ?
	lw			v0,lexico						# Cargo en v0 lexico.
	beq			v0,DIR_NULL,$FreeAmountSavedInOBuffer # If (lexico == NULL) goto FreeAmountSavedInOBuffer.
	
	# lexico is not NULL
	lw			a0,lexico						# Cargo en a0 lexico. Parametro de la funcion free.
	la			t9,free						# Cargo en t9 la direccion de la funcion free.
	jal			ra,t9							# Ejecuto la funcion free.
	sw			zero,lexico					# Asigno NULL a lexico.
$FreeAmountSavedInOBuffer:
	# (amountSavedInOBuffer != NULL) ?
	lw			v0,28($fp)						# Cargo en v0 amountSavedInOBuffer.
	beq			v0,DIR_NULL,$LoadReturnPalindrome # If (amountSavedInOBuffer == NULL) goto LoadReturnPalindrome.
	
	# amountSavedInOBuffer is not NULL
	
	# free(amountSavedInOBuffer);
	lw			a0,28($fp)						# Cargo en a0 amountSavedInOBuffer. Parametro de la funcion free.
	la			t9,free						# Cargo en t9 la direccion de la funcion free.
	jal			ra,t9							# Ejecuto la funcion free.
	sw			zero,28($fp)					# Asigno NULL a amountSavedInOBuffer.
$LoadReturnPalindrome:
	lw			v0,32($fp)						# Cargo en v0 rdoProcess.
	sw			v0,60($fp)						# Cargo en la direccion 60($fp) el resultado de la funcion palindrome, que en este caso seria rdoProcess.
$ReturnPalindrome:
	lw			v0,60($fp)
	move		sp,$fp
	lw			ra,72(sp)
	lw			$fp,68(sp)
	addu		sp,sp,80
	j			ra								# Jump and return
	.end	palindrome
	.size	palindrome, .-palindrome
		
		

## Variables auxiliares

	.data
	.align 2
	isize:		.space 4

	.align 2
	osize:		.space 4

	.align 2
	oFileDescriptor:	.space 4


	.rdata
	.align	3
doubleWord:
	.word	0
	.word	1073741824
	
	.globl		lexico
	.section	.bss		# TODO VER SI ESTO VA
	.align	2
	.type	lexico, @object
	.size	lexico, 4
lexico:
	.space	4
	
	.globl	quantityCharacterInLexico
	.globl	quantityCharacterInLexico
	.align	2
	.type	quantityCharacterInLexico, @object
	.size	quantityCharacterInLexico, 4
quantityCharacterInLexico:
	.space	4
	
	.globl	savedInOFile
	.globl	savedInOFile
	.align	2
	.type	savedInOFile, @object
	.size	savedInOFile, 4
savedInOFile:
	.space	4
	
	.globl	obuffer
	.globl	obuffer
	.align	2
	.type	obuffer, @object
	.size	obuffer, 4
obuffer:
	.space	4
	
	.globl	bytesLexico
	.globl	bytesLexico
	.align	2
	.type	bytesLexico, @object
	.size	bytesLexico, 4
bytesLexico:
	.space	4	
	
	
## Mensajes de error

	.rdata
	.align	2
MENSAJE_ERROR_MEMORIA_LEXICO:
	.ascii	"[Error] Hubo un error en memoria (lexico). \n\000"
	
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

