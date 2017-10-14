#include <mips/regdef.h>
#include <sys/syscall.h>

#STATICS VAR DEFINITIONS

#define FALSE 			0
#define TRUE 			1


##-----	isKeywords -----##

	.align		2
	.globl		isKeywords
	.ent		isKeywords
isKeywords:
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
	
	move		v0,a0   # Muevo de a0 a v0 el parametro de la funcion (char character).
	sb		v0,8($fp)   # Guardo en la direccion de memoria 8($fp) el contenido de la variable character que se encuentra en el registro v0.
	lb		v0,8($fp)   # Cargo el byte character en v0 que estaba en la direccion de memoria 8($fp).
	
	# character >= 65 && character <= 90    ---   A - Z = [65 - 90]
	slt		v0,v0,65   # Compara el contenido de la variable character con el literal 65, y guarda true en v0 si 
   			# el primero (character) es mas chico que el segundo (65). 
	bne		v0,FALSE,$VerifyCharacterOfaToz		# Si no es igual a FALSE, o sea, character < 65, salta a VerifyCharacterOfaToz.
	lb		v0,8($fp)   # Cargo el byte character en v0 que estaba en la direccion de memoria 8($fp).
	slt		v0,v0,91   # Compara el contenido de la variable character con el literal 91, y guarda true en v0 si el 
   			# primero (character) es mas chico que el segundo (91). 
	bne		v0,FALSE,$ReturnIsKeywordsTrue		# Si no es igual a FALSE, o sea, character > 91, salta a ReturnIsKeywordsTrue.
$VerifyCharacterOfaToz:	
	lb		v0,8($fp)   # Cargo el byte character en v0 que estaba en la direccion de memoria 8($fp).
	
	# character >= 97 && character <= 122    ---   a - z = [97 - 122]
	slt		v0,v0,97   # Compara el contenido de la variable character con el literal 97, y guarda true en v0 si 
   			# el primero (character) es mas chico que el segundo (97). 
	bne		v0,FALSE,$VerifyCharacterOf0To9		# Si no es igual a FALSE, o sea, character < 65, salta a VerifyCharacterOf0To9.
	lb		v0,8($fp)   # Cargo el byte character en v0 que estaba en la direccion de memoria 8($fp).
	slt		v0,v0,123   # Compara el contenido de la variable character con el literal 123, y guarda true en v0 si el 
   			# primero (character) es mas chico que el segundo (123). 
	bne		v0,FALSE,$ReturnIsKeywordsTrue		# Si no es igual a FALSE, o sea, character > 123, salta a ReturnIsKeywordsTrue.
$VerifyCharacterOf0To9:
	lb		v0,8($fp)   # Cargo el byte character en v0 que estaba en la direccion de memoria 8($fp).

	# character >= 48 && character <= 57    ---   0 - 9 = [48 - 57]
	slt		v0,v0,48   # Compara el contenido de la variable character con el literal 48, y guarda true en v0 si el 
   			# primero (character) es mas chico que el segundo (48). 
	bne		v0,zero,$VerifyCharacterGuionMedio	# Si no es igual a FALSE, o sea, character < 48, salta a VerifyCharacterGuionMedio.
	lb		v0,8($fp)   # Cargo el byte character en v0 que estaba en la direccion de memoria 8($fp).
	slt		v0,v0,58   # Compara el contenido de la variable character con el literal 58, y guarda true en v0 si el 
   			# primero (character) es mas chico que el segundo (58). 
	bne		v0,zero,$ReturnIsKeywordsTrue		# Si no es igual a FALSE, o sea, character > 58, salta a ReturnIsKeywordsTrue.
$VerifyCharacterGuionMedio:
	lb		v1,8($fp)   # Cargo el byte character en v1 que estaba en la direccion de memoria 8($fp).
	
	# character == 45    ---   - =  45
	li		v0,45   # Cargo el literal 45 en v0 para hacer luego la comparacion.
	beq		v1,v0,$ReturnIsKeywordsTrue		# If (character == 45) goto ReturnIsKeywordsTrue
	
	lb		v1,8($fp)   # Cargo el byte character en v1 que estaba en la direccion de memoria 8($fp).
	
	# character == 95    ---   _ = 95
	li		v0,95   # Cargo el literal 95 en v0 para hacer luego la comparacion.
	beq		v1,v0,$ReturnIsKeywordsTrue		# If (character == 95) goto ReturnIsKeywordsTrue
	b		$ReturnIsKeywordsFalse			# Salto incondicional para retornar FALSE (character no es un keyword).
$ReturnIsKeywordsTrue:
	li		v0,TRUE   # Cargo en v0 TRUE (que seria igual a 1).
	sw		v0,12($fp)   # Guardo el resultado de la funcion TRUE (v0) en la direccion de memoria 12($fp).
	b		$ReturnIsKeywords			# Salto incondicional para retornar resultado de las comparaciones.
$ReturnIsKeywordsFalse:
	sw		zero,12($fp)   # Guardo FALSE (que seria igual a 0) en la direccion de memoria 12($fp).
$ReturnIsKeywords:
	lw		v0,12($fp)   # Cargo en v0 el resultado de la funcion isKeywords guardado en la direccion de memoria 12($fp).
	move		sp,$fp
	lw		$fp,20(sp)
	addu		sp,sp,24
	j		ra   # Jump and return
	.end		isKeywords


