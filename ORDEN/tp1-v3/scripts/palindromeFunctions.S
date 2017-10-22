#include <mips/regdef.h>
#include <sys/syscall.h>

#include "constants.h"

# Size mensajes
#define BYTES_MENSAJE_ERROR_PUTCH   65


##-----	toLowerCase -----##

	.text
	.align	2
	.globl	toLowerCase
	.ent	toLowerCase
toLowerCase:
	.frame	$fp,24,ra
	.set	noreorder
	.cpload	t9
	.set	reorder

        # Stack frame creation
	subu	sp,sp,24

	.cprestore 0
	sw	$fp,20(sp)
	sw	gp,16(sp)

        # de aqui al fin de la funcion uso $fp en lugar de sp.
	move	$fp,sp

        # Parametro
	sb	a0,8($fp)       # Guardo en la direccion 8($fp) el contenido de 
                                # a0 que es word (char word).

        # (word >= 65 && word <= 90) ?

        # (word >= 65) ?
	lb	v0,8($fp)
	slt	v0,v0,65      # Guardo en v0 TRUE si word es mas chico que 65, sino guardo FALSE.
	bne	v0,FALSE,returnToLowerCase  # If (word < 65) goto returnToLowerCase

        # word is >= 65

        # (word <= 90) ?
	lb	v0,8($fp)
	slt	v0,v0,91      # Guardo en v0 TRUE si word es mas chico que 91, sino guardo FALSE.
	beq	v0,FALSE,returnToLowerCase # If (word >= 91) goto returnToLowerCase

        # word is <= 90

        # word += 32;
	lbu	v0,8($fp)
	addu	v0,v0,32
	sb	v0,8($fp)  # Guardo en la direccion 8($fp) el resultado de la funcion,
                           # que coincide con la variable word.
returnToLowerCase:
	lb	v0,8($fp)
	move	sp,$fp
	lw	$fp,20(sp)
        # destruyo stack frame
	addu	sp,sp,24
        # vuelvo a funcion llamante
	j	ra

	.end	toLowerCase



##-----	verifyPalindromic -----##

	.align	2
	.globl	verifyPalindromic
	.ent	verifyPalindromic
verifyPalindromic:
	.frame	$fp,72,ra
	.set	noreorder
	.cpload	t9
	.set	reorder

	subu	sp,sp,72

	.cprestore 16
	sw	ra,64(sp)
	sw	$fp,60(sp)
	sw	gp,56(sp)

	move	$fp,sp

        # (lexico.buffer == NULL || lexico.quantityCharactersInBuffer <= 0) ?

        # (lexico.buffer == NULL) ?
	lw	v0,lexico
	beq	v0,zero,returnFalse # If (lexico.buffer == NULL) goto returnFalse

        # lexico.buffer is not NULL

        # (lexico.quantityCharactersInBuffer <= 0) ?
	lw	v0,lexico+4
	blez	v0,returnFalse   # If (lexico.quantityCharactersInBuffer <= 0) returnFalse

        # lexico.quantityCharactersInBuffer is > 0
	b	verifyOneCharacter
returnFalse:
        # return FALSE;
	sw	zero,48($fp)     # FALSE = 0, guardo en la direccion 48($fp) el resultado de la funcion
	b	returnVerifyPalindromic
verifyOneCharacter:
        # (lexico.quantityCharactersInBuffer == 1) ?
	lw	v1,lexico+4
	li	v0,1
	bne	v1,v0,compareCharacters # IF (lexico.quantityCharactersInBuffer != 1) 
                                        # goto compareCharacters

        # lexico.quantityCharactersInBuffer is equals to 1

        # return TRUE;
	li	v0,TRUE
	sw	v0,48($fp)    # guardo en la direccion 48($fp) el resultado de la funcion
	b	returnVerifyPalindromic
compareCharacters:
        # double middle = (double)lexico.quantityCharactersInBuffer / 2;
	l.s	$f0,lexico+4  # Cargo lexico.quantityCharactersInBuffer en f0
	cvt.d.w	$f2,$f0       # Convierto el integer quantityCharactersInBuffer a double
	l.d	$f0,doubleWord   # Cargo en f0 el valor 2.
	div.d	$f0,$f2,$f0     # Division con Double (double)quantityCharacterInWord / 2; 
                                # Sintaxis: div.d FRdest, FRsrc1, FRsrc2
	s.d	$f0,24($fp)     # Guarda el resultado de la division en 24($fp). O sea, 
                                # middle (double middle = (double)quantityCharacterInWord / 2;)

        # int idx = 0;
	sw	zero,32($fp)    # En 32($fp) se encuentra idx (int idx = 0;).

        # int validPalindromic = TRUE;
	li	v0,TRUE
	sw	v0,36($fp)    # En 36($fp) esta la variable validPalindromic.

        # int last = lexico.quantityCharactersInBuffer - 1;
	lw	v0,lexico+4
	addu	v0,v0,-1
	sw	v0,40($fp)    # En 40($fp) esta la variable last.
whileMirror:
        # (idx < middle && last >= middle && validPalindromic == TRUE)
	l.s	$f0,32($fp)   # Cargo idx en f0.
	cvt.d.w	$f2,$f0       # Convierto el integer idx a double y lo guardo en 
                              # f2 para poder hacer la comparacion.
	l.d	$f0,24($fp)   # Cargo en a0 la variable middle.
	c.lt.d	$f2,$f0       # Compara la variable idx con la variable middle, y 
                              # setea el condition flag en true si el primero (idx) es 
                              # mas chico que el segundo (middle).
	bc1t	verifyConditionLastWithMiddle # Si el condition flag es true, continua 
                                              # haciendo las comparaciones.
	b	whileMirrorFinalized   # Si el condition flag es false, salta al final de la 
                                       # funcion, devolviendo el valor de la variable validPalindromic.
verifyConditionLastWithMiddle:
	l.s	$f0,40($fp)  # Cargo la variable last en f0.
	cvt.d.w	$f2,$f0      # Convierto el integer last a double y lo guardo 
                             # en f2 para poder hacer la comparacion.
	l.d	$f0,24($fp)  # Cargo en f0 el contenido de la variable middle.
	c.le.d	$f0,$f2      # Compara el contenido de la variable last con la variable 
                             # middle, y setea el condition flag en true si 
                             # middle es menor o igual a last, sino false
	bc1t	verifyConditionPalindromicTrue # Si el condition flag es true, 
                                               # continua haciendo las comparaciones.
	b	whileMirrorFinalized  # false
verifyConditionPalindromicTrue:
	lw	v1,36($fp)  # Carga en v1 validPalindromic
	li	v0,TRUE
	beq	v1,v0,whileMirrorContent  # If (validPalindromic == TRUE) goto whileMirrorContent
	b	whileMirrorFinalized
whileMirrorContent:
        # char firstCharacter = toLowerCase(lexico.buffer[idx]);
	lw	v1,lexico
	lw	v0,32($fp)
	addu	v0,v1,v0
	lb	v0,0(v0)
	move	a0,v0
	la	t9,toLowerCase
	jal	ra,t9
	sb	v0,44($fp)   # Guardo en la direccion 44($fp) la variable firstCharacter

        # char lastCharacter = toLowerCase(lexico.buffer[last]);
	lw	v1,lexico
	lw	v0,40($fp)
	addu	v0,v1,v0
	lb	v0,0(v0)
	move	a0,v0
	la	t9,toLowerCase
	jal	ra,t9
	sb	v0,45($fp)   # Guardo en la direccion 45($fp) la variable lastCharacter

        # (firstCharacter != lastCharacter) ?
	lb	v1,44($fp)   # Cargo firstCharacter en v1
	lb	v0,45($fp)   # Cargo lastCharacter en v0
	beq	v1,v0,continueWhile # If (firstCharacter == lastCharacter) goto continueWhile

        # firstCharacter != lastCharacter

        # validPalindromic = FALSE;
	sw	zero,36($fp)
continueWhile:
        # idx ++;
	lw	v0,32($fp)
	addu	v0,v0,1
	sw	v0,32($fp)

        # last --;
	lw	v0,40($fp)
	addu	v0,v0,-1
	sw	v0,40($fp)

	b	whileMirror
whileMirrorFinalized:
        # return validPalindromic;
	lw	v0,36($fp)   # Cargo el contenido de validPalindromic en v0
	sw	v0,48($fp)   # Guardo en la direccion 48($fp) el resultado de la funcion 
                             # que esta en v0.
returnVerifyPalindromic:
	lw	v0,48($fp)
	move	sp,$fp
	lw	ra,64(sp)
	lw	$fp,60(sp)
        # destruyo stack frame
	addu	sp,sp,72
        # vuelvo a funcion llamante
	j	ra

	.end	verifyPalindromic



##-----	isKeywords -----##

	.align	2
	.globl	isKeywords
	.ent	isKeywords
isKeywords:
	.frame	$fp,24,ra
	.set	noreorder
	.cpload	t9
	.set	reorder

        # Stack frame creation
	subu	sp,sp,24

	.cprestore 0
	sw	$fp,20(sp)
	sw	gp,16(sp)

        # de aqui al fin de la funcion uso $fp en lugar de sp.
	move	$fp,sp

        # Parametro
	sb	a0,8($fp)       # Guardo en la direccion 8($fp) el parametro character 
                                # que viene en a0 (char character).

        # ((character >= 65 && character <= 90) || (character >= 97 && character <= 122)
	#		|| (character >= 48 && character <= 57)
	#		|| character == 45 || character == 95) ?


        # (character >= 65 && character <= 90) ?

        # (character >= 65) ? ---   A - Z = [65 - 90]
	lb	v0,8($fp)
	slt	v0,v0,65      # Guarda en v0 TRUE si character es mas chico que 65, sino FALSE.
	bne	v0,FALSE,verifyCharacterOfaToz # Si no es igual a FALSE, o sea, character < 65, 
                                               # salta a VerifyCharacterOfaToz.

        # (character >= 65 && character <= 90) ?
	lb	v0,8($fp)
	slt	v0,v0,91     # Compara el contenido de la variable character con el 
                             # literal 91, y guarda true en v0 si el primero (character) 
                             # es mas chico que el segundo (91).
	bne	v0,FALSE,returnIsKeywordsTrue # Si no es igual a FALSE, o sea, 
                                              # character < 91, salta a ReturnIsKeywordsTrue.
verifyCharacterOfaToz:
        # (character >= 97 && character <= 122) ?    ---   a - z = [97 - 122]

        # (character >= 97) ?
	lb	v0,8($fp)
	slt	v0,v0,97    # Guarda true en v0 si el primero (character) es mas 
                            # chico que el segundo (97).
	bne	v0,FALSE,verifyCharacterOf0To9 # Si no es igual a FALSE, o sea, 
                                               # character < 97, salta a verifyCharacterOf0To9.

        # (character <= 122) ?
	lb	v0,8($fp)
	slt	v0,v0,123   # Guarda true en v0 si el primero (character) 
                            # es mas chico que el segundo (123).
	bne	v0,FALSE,returnIsKeywordsTrue # Si no es igual a FALSE, o sea, 
                                              # character < 123, salta a returnIsKeywordsTrue.
verifyCharacterOf0To9:
        # (character >= 48 && character <= 57) ?    ---   0 - 9 = [48 - 57]

        # (character >= 48) ?
	lb	v0,8($fp)
	slt	v0,v0,48
	bne	v0,FALSE,verifyCharacterGuionMedio

        # (character <= 57) ?
	lb	v0,8($fp)
	slt	v0,v0,58
	bne	v0,FALSE,returnIsKeywordsTrue
verifyCharacterGuionMedio:
        # character == 45 ?
	lb	v1,8($fp)
	li	v0,45
	beq	v1,v0,returnIsKeywordsTrue

        # character == 95 ?
	lb	v1,8($fp)
	li	v0,95
	beq	v1,v0,returnIsKeywordsTrue

	b	returnIsKeywordsFalse
returnIsKeywordsTrue:
	li	v0,TRUE
	sw	v0,12($fp)      # Guardo en la direccion 12($fp) el resultado 
                                # de la funcion, en este caso TRUE.
	b	returnIsKeywords
returnIsKeywordsFalse:
	sw	zero,12($fp)    # Guardo en la direccion 12($fp) el resultado 
                                # de la funcion, en este caso FALSE.
returnIsKeywords:
	lw	v0,12($fp)
	move	sp,$fp
	lw	$fp,20(sp)
        # destruyo stack frame
	addu	sp,sp,24
        # vuelvo a funcion llamante
	j	ra

	.end	isKeywords



##-----	saveIfPalindrome -----##

	.align	2
	.globl	saveIfPalindrome
	.ent	saveIfPalindrome
saveIfPalindrome:
	.frame	$fp,64,ra
	.set	noreorder
	.cpload	t9
	.set	reorder

        # Stack frame creation
	subu	sp,sp,64

	.cprestore 16
	sw	ra,56(sp)
	sw	$fp,52(sp)
	sw	gp,48(sp)

        # de aqui al fin de la funcion uso $fp en lugar de sp.
	move	$fp,sp

        # int itsPalindromic = verifyPalindromic();
	la	t9,verifyPalindromic
	jal	ra,t9
	sw	v0,24($fp)    # Guardo en la direccion 24($fp) itsPalindromic.

        # (itsPalindromic == TRUE) ?
	lw	v1,24($fp)
	li	v0,TRUE
	bne	v1,v0,returnOkeySaveIfPalindrome # If (itsPalindromic != TRUE) goto 
                                                 # returnOkeySaveIfPalindrome

	# int idx = 0;
	sw	zero,28($fp)

        # int error = FALSE;
	sw	zero,32($fp)
whilePutch:
        # (idx < lexico.quantityCharactersInBuffer && error == FALSE) ?

        # (idx < lexico.quantityCharactersInBuffer) ?
	lw	v0,28($fp)     # Cargo en v0 idx
	lw	v1,lexico+4    # Cargo en v1 quantityCharactersInBuffer
	slt	v0,v0,v1       # Cargo en v0 TRUE si idx < quantityCharactersInBuffer, sino FALSE
	beq	v0,FALSE,loadLineJump # If (idx >= quantityCharactersInBuffer) goto loadLineJump

        # (error == FALSE) ?
	lw	v0,32($fp)
	bne	v0,FALSE,loadLineJump # If (error != FALSE) goto loadLineJump

        # int result = putch(lexico.buffer[idx]);
	lw	v1,lexico
	lw	v0,28($fp)
	addu	v0,v1,v0
	lb	v0,0(v0)
	move	a0,v0
	la	t9,putch
	jal	ra,t9        # Ejecuto la funcion putch
	sw	v0,36($fp)   # Guardo en la direccion 36($fp) el resultado de la funcion putch (result).

        # (result == EOF_F) ?
	lw	v1,36($fp)
	li	v0,EOF_F
	bne	v1,v0,incrementIdx  # If (result != EOF) goto incrementIdx

#       # error = TRUE;
	li	v0,TRUE
	sw	v0,32($fp)    # Guardo TRUE en la variable error.
incrementIdx:
        # idx ++;
	lw	v0,28($fp)
	addu	v0,v0,1
	sw	v0,28($fp)

	b	whilePutch
loadLineJump:
        # (error == FALSE) ?
	lw	v0,32($fp)
	bne	v0,FALSE,returnWithError  # If (error != FALSE) goto returnWithError

        # int result = putch('\n');
	li	a0,10         # '\n' = 10
	la	t9,putch
	jal	ra,t9
	sw	v0,36($fp)

        # (result == EOF_F)
	lw	v1,36($fp)
	li	v0,EOF_F
	bne	v1,v0,returnWithError

#       # error = TRUE;
	li	v0,TRUE
	sw	v0,32($fp)
returnWithError:
        # (error == TRUE) ?
	lw	v1,32($fp)
	li	v0,TRUE
	bne	v1,v0,returnOkeySaveIfPalindrome # If (error != TRUE) goto returnOkeySaveIfPalindrome
	
        # Mensaje de error
	li      a0,FILE_DESCRIPTOR_STDERR # Cargo en a0 FILE_DESCRIPTOR_STDERR.
	la      a1,MENSAJE_ERROR_PUTCH 	# Cargo en a1 la direccion de memoria donde se encuentra el mensaje a cargar.
	li      a2,BYTES_MENSAJE_ERROR_PUTCH	# Cargo en a2 la cantidad de bytes a escribir.
	li      v0, SYS_write
	syscall    # No controlo error porque sale de por si de la funcion por error.
	
        # return ERROR_PUTCH;
	li	v0,ERROR_PUTCH
	sw	v0,40($fp)
	b	returnSaveIfPalindrome
returnOkeySaveIfPalindrome:
	sw	zero,40($fp)    # OKEY = 0
returnSaveIfPalindrome:
	lw	v0,40($fp)
	move	sp,$fp
	lw	ra,56(sp)
	lw	$fp,52(sp)
        # destruyo stack frame
	addu	sp,sp,64
        # vuelvo a funcion llamante
	j	ra

	.end	saveIfPalindrome



##-----	palindrome -----##

	.align	2
	.globl	palindrome
	.ent	palindrome
palindrome:
	.frame	$fp,56,ra
	.set	noreorder
	.cpload	t9
	.set	reorder

        # Stack frame creation
	subu	sp,sp,56

	.cprestore 16
	sw	ra,48(sp)
	sw	$fp,44(sp)
	sw	gp,40(sp)

        # de aqui al fin de la funcion uso $fp en lugar de sp.
	move	$fp,sp

        # Parametros
	sw	a0,56($fp)      # Guardo en la direccion 56($fp) ifd que estaba en a0.
	sw	a1,60($fp)      # Guardo en la direccion 60($fp) ibytes que estaba en a1.
	sw	a2,64($fp)      # Guardo en la direccion 64($fp) ofd que estaba en a2.
	sw	a3,68($fp)      # Guardo en la direccion 68($fp) obytes que estaba en a3.

        # initializeInput(ifd, ibytes);
	lw	a0,56($fp)
	lw	a1,60($fp)
	la	t9,initializeInput
	jal	ra,t9

        # initializeOutput(ofd, obytes);
	lw	a0,64($fp)
	lw	a1,68($fp)
	la	t9,initializeOutput
	jal	ra,t9

        # lexico.quantityCharactersInBuffer = 0;
	sw	zero,lexico+4

        # int icharacter = getch();
	la	t9,getch
	jal	ra,t9
	sw	v0,24($fp)      # Guardo en la direccion 4($fp) icharacter, 
                                # resultado de la funcion getch().

        # int result = OKEY;
	sw	zero,28($fp)    # Guardo en la direccion 28($fp) OKEY (= 0).
whilePalindrome:
        # (icharacter != EOF && icharacter != ERROR_I_READ && result == OKEY) ?

        # (icharacter != EOF_F) ?
	lw	v1,24($fp)
	li	v0,EOF_F
	beq	v1,v0,flushLexico # If (icharacter == EOF) goto flushLexico

        # (icharacter != ERROR_I_READ) ?
	lw	v1,24($fp)
	li	v0,ERROR_I_READ
	beq	v1,v0,flushLexico # If (icharacter == ERROR_I_READ) goto flushLexico

        # (result == OKEY) ?
	lw	v0,28($fp)
	bne	v0,OKEY,flushLexico # If (result != OKEY) goto flushLexico

        # In while

        # char character = icharacter;
	lbu	v0,24($fp)
	sb	v0,32($fp)    # Guardo en la direccion 32($fp) character

        # (isKeywords(character) == TRUE) ?
	lb	v0,32($fp)
	move	a0,v0
	la	t9,isKeywords
	jal	ra,t9
	move	v1,v0
	li	v0,TRUE
	bne	v1,v0,isNotKeyword # If (resultado de isKeywords != TRUE) goto isNotKeyword

        # is keyword

        # result = loadInBuffer(character, &lexico, LEXICO_BUFFER_SIZE);
	lb	v0,32($fp)
	move	a0,v0
	la	a1,lexico
	li	a2,LEXICO_BUFFER_SIZE
	la	t9,loadInBuffer
	jal	ra,t9        # Ejecuto la funcion loadInBuffer.
	sw	v0,28($fp)   # Cargo en la direccion 28($fp) el resultado de la funcion loadInBuffer.

	b	loadNextCharacter
isNotKeyword:
        # result = saveIfPalindrome();
	la	t9,saveIfPalindrome
	jal	ra,t9
	sw	v0,28($fp)

        # cleanContentBuffer(&lexico);
	la	a0,lexico
	la	t9,cleanContentBuffer
	jal	ra,t9
loadNextCharacter:
        # icharacter = getch();
	la	t9,getch
	jal	ra,t9
	sw	v0,24($fp)    # icharacter

	b	whilePalindrome
flushLexico:
        # int resultFlush = saveIfPalindrome();
	la	t9,saveIfPalindrome
	jal	ra,t9
	sw	v0,36($fp)    # Guardo en la direccion 36($fp) la variable resultFlush, 
                              # que representa el resultado de ejecutar la funcion saveIfPalindrome.

        # (result == OKEY) ?
	lw	v0,28($fp)
	bne	v0,OKEY,cleanLexico # If (result != OKEY) goto cleanLexico

        # result = resultFlush;
	lw	v0,36($fp)
	sw	v0,28($fp)
cleanLexico:
        # cleanContentBuffer(&lexico);
	la	a0,lexico
	la	t9,cleanContentBuffer
	jal	ra,t9

        # resultFlush = flush();
	la	t9,flush
	jal	ra,t9
	sw	v0,36($fp)   # Guardo el resultado de flush en resultFlush, 36($fp)

        # (result == OKEY) ?
	lw	v0,28($fp)
	bne	v0,OKEY,continueWithFreeResources # If (result != OKEY) goto continueWithFreeResources

        # result = resultFlush;
	lw	v0,36($fp)
	sw	v0,28($fp)
continueWithFreeResources:
        # freeResources();
	la	t9,freeResources
	jal	ra,t9

	lw	v0,28($fp)   # Cargo en v0 result que esta en la direccion 28($fp).

	move	sp,$fp
	lw	ra,48(sp)
	lw	$fp,44(sp)
        # destruyo stack frame
	addu	sp,sp,56
        # vuelvo a funcion llamante
	j	ra

	.end	palindrome


# ---------------------------------------------------------------------------- #

## Variables auxiliares

	.data

	.globl	lexico
	.align 2
lexico:		
	.space 12


	.rdata
	.align	3
doubleWord:
	.word	0
	.word	1073741824
	

## Mensajes de error

	.rdata	
	
	.align	2
MENSAJE_ERROR_PUTCH:
	.ascii	"[Error] Error al escribir en el archivo output el palind"
	.ascii	"romo. \n\000"	

	
