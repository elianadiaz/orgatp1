#include <mips/regdef.h>
#include <sys/syscall.h>

#STATICS VAR DEFINITIONS

#define FALSE 			0
#define TRUE 			1
	
##-----	verifyPalindromic -----##

	.align		2
	.globl		verifyPalindromic
	.ent		verifyPalindromic
verifyPalindromic:
	.frame		$fp,72,ra
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
	sw		zero,52($fp)				# Guardo FALSE (= 0)
	b		$ReturnVerifyPalindromic		# Salta siempre - goto ReturnVerifyPalindromic (con return FALSE)
$VerifyWhenOneCharacter:
	lw		v1,76($fp)				# Cargo quantityCharacterInWord
	li		v0,1					# Cargo en v0, el valor 1, para luego hacer la comparacion
	bne		v1,v0,$VerifyWhenTwoCharacteres		# if (quantityCharacterInWord != 1) goto VerifyWhenTwoCharacteres
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
	sw		zero,52($fp)				# Guardo FALSE (= 0)
	b		$ReturnVerifyPalindromic		# Salta siempre - goto ReturnVerifyPalindromic (con return FALSE)
$IfPalindromicTrue:
	li		v0,TRUE					# TRUE es igual a 1
	sw		v0,52($fp)
	b		$ReturnVerifyPalindromic		# Salta siempre - goto ReturnVerifyPalindromic (con return TRUE)
$VerifyWhenMoreThanOneCharacter:
	l.s		$f0,76($fp)				# Cargo quantityCharacterInWord
	cvt.d.w		$f2,$f0					# Convierto el integer quantityCharacterInWord a double
	l.d		$f0,doubleWord				# Cargo en f0 el valor 2.
	div.d		$f0,$f2,$f0				# Division con Double (double)quantityCharacterInWord / 2; - Sintaxis: div.d FRdest, FRsrc1, FRsrc2
	s.d		$f0,32($fp)				# Guarda el resultado de la division en 32($fp). O sea, middle (double middle = (double)quantityCharacterInWord / 2;)
	sw		zero,40($fp)				# En 40($fp) se encuentra idx (int idx = 0;).
	li		v0,TRUE					# En v0 esta la variable validPalindromic en TRUE, que es igual a 1 (int validPalindromic = TRUE;).
	sw		v0,44($fp)				# Guarda en la direccion 44($fp) el valor de validPalindromic.
	lw		v0,76($fp)				# Cargo quantityCharacterInWord en v0.
	addu		v0,v0,-1				# Le resto 1 a quantityCharacterInWord y lo guardo en v0 (int last = quantityCharacterInWord - 1;).
	sw		v0,48($fp)				# Guardo en la direccion 48($fp) la variable last.
$WhileMirror:
	l.s		$f0,40($fp)				# Cargo idx en f0.
	cvt.d.w		$f2,$f0					# Convierto el integer idx a double y lo guardo en f2 para poder hacer la comparacion.
	l.d		$f0,32($fp)				# Cargo en a0 la variable middle.
	c.lt.d		$f2,$f0					# Compara la variable idx con la variable middle, y setea el condition flag en true si el primero (idx) es mas chico que el segundo (middle).
	bc1t		$WhileMirrorConditionLastWithMiddle	# Si el condition flag es true, continua haciendo las comparaciones.
	b		$WhileMirrorFinalized			# Si el condition flag es false, salta al final de la funcion, devolviendo el valor de la variable validPalindromic que seria TRUE.
$WhileMirrorConditionLastWithMiddle:
	l.s		$f0,48($fp)				# Cargo la variable last en f0.
	cvt.d.w		$f2,$f0					# Convierto el integer last a double y lo guardo en f2 para poder hacer la comparacion.
	l.d		$f0,32($fp)				# Cargo en f0 el contenido de la variable middle.
	c.lt.d		$f0,$f2					# Compara el contenido de la variable last con la variable middle, y setea el condition flag en true si 
								# el primero (last) es mas chico que el segundo (middle).
	bc1t		$WhileMirrorConditionValidPalindromicTrue # Si el condition flag es true, continua haciendo las comparaciones.
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


## Variables auxiliares

	.rdata
	.align	3
doubleWord:
	.word	0
	.word	1073741824



