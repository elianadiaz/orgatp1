#include <mips/regdef.h>
#include <sys/syscall.h>

#STATICS VAR DEFINITIONS

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


##-----	executePalindromeWrite -----##
		
	.align		2
	.globl		executePalindromeWrite
	.ent		executePalindromeWrite
executePalindromeWrite:
	.frame		$fp,80,ra
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
	bne		v0,DIR_NULL,$VerifyMemorymyfreeInLexico # Si el contenido de lexico no apunta a NULL, voy a verificar la memoria disponible para 
								# cargarle character (goto VerifyMemorymyfreeInLexico).
	
	# Voy a asignar memoria a la variable lexico. lexico es igual a NULL.
	li		a0,LEXICO_BUFFER_SIZE			# Cargo en a0 la cantidad de bytes a asignar por buffer a lexico (es un literal).
	la		t9,mymalloc				# Cargo en t9 la direccion de la funcion mymalloc.
	jal		ra,t9					# Ejecuto la funcion mymalloc.
	sw		v0,lexico				# Guardo en lexico la memoria asignada con mymalloc (que esta en v0).
	li		v0,LEXICO_BUFFER_SIZE			# Cargo en v0 el literal LEXICO_BUFFER_SIZE (cantidad de bytes a asignar por buffer a lexico).
	sw		v0,bytesLexico				# Guardo el contenido de vo (LEXICO_BUFFER_SIZE) en la variable global bytesLexico.
	b		$LoadCharacterInLexico			# Salto incondicional, voy a cargar caracter en lexico.
$VerifyMemorymyfreeInLexico:
	lw		v0,quantityCharacterInLexico		# Cargo en v0 el contenido de quantityCharacterInLexico.
	lw		v1,bytesLexico				# Cargo en v1 el contenido de bytesLexico.
	slt		v0,v0,v1				# Verifico si quantityCharacterInLexico es mas chico que bytesLexico. Guardo resultado en v0 (TRUE o FALSE).
	bne		v0,FALSE,$LoadCharacterInLexico 	# Si quantityCharacterInLexico >= bytesLexico (el contenido de v0 es FALSE, resultado comparacion 
								# anterior), voy a LoadCharacterInLexico.
	
	# Realloc para lexico
	lw		v0,bytesLexico				# Cargo en v0 el contenido de bytesLexico.
	sw		v0,44($fp)				# Guardo en la direccion de memoria 44($fp) el contenido de v0, que seria bytesLexico. Representaria 
								# la variable bytesLexicoPreview.
	lw		v0,bytesLexico				# Cargo en v0 el contenido de bytesLexico.
	addu		v0,v0,LEXICO_BUFFER_SIZE		# Le sumo a bytesLexico LEXICO_BUFFER_SIZE y guardo resultado en v0.
	sw		v0,bytesLexico				# Guardo el contenido de la suma en bytesLexico.
	lw		a0,lexico				# Cargo en a0 lexico para enviarlo por parametro a myRealloc.
	lw		a1,bytesLexico				# Cargo en a1 bytesLexico para enviarlo por parametro a myRealloc.
	lw		a2,44($fp)				# Cargo en a2 lo guardado en la direccion de memoria 44($fp), que representaba a 
								# bytesLexicoPreview, para enviarlo por parametro a myRealloc.
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
	addu		v1,v1,v0				# Me desplazo en la direccion de memoria de lexico (v1) la cantidad especificada por 
								# quantityCharacterInLexico (v0) y 
								# guardo la nueva posicion en v1.
	lbu		v0,40($fp)				# Cargo en v0 lo almacenado en la direccion de memoria 40($fp), que seria la variable character.
	sb		v0,0(v1)				# Guardo en la posicion de memoria guardada almacenada en v1 (0 de desplazamiento), el contenido de v0 
								# (character). O sea: lexico[quantityCharacterInLexico] = character;
	lw		v0,quantityCharacterInLexico		# Cargo en v0 quantityCharacterInLexico
	addu		v0,v0,1					# Incremento en 1 la cantidad de caracteres guardados en lexico (quantityCharacterInLexico ++;). Este 
								# resultado se guarda en v0.
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
	bne		v1,v0,$myfreeLexico			# If (itsPalindromic != TRUE) goto myfreeLexico.
	
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
	bne		v0,FALSE,$InForLexicoInOBuffer		# Si el resultado de la comparacion no es FALSE, o sea, (i < quantityCharacterInLexico), entro 
								# al for (goto InForLexicoInOBuffer).
	b		$WriteLexicoInOFile			# Salto incondicional a WriteLexicoInOFile.
$InForLexicoInOBuffer:
	# obuffer[*amountSavedInOBuffer] = lexico[i];
	lw		v0,84($fp)				# Cargo en v0 lo guardado en la direccion de memoria 84($fp), que representaria a la variable *amountSavedInOBuffer.
	lw		v1,obuffer				# Cargo en v1 obuffer.
	lw		v0,0(v0)				# Cargo en v0 lo almacenado en la direccion de memoria guardada en v0 (*amountSavedInOBuffer).
	addu		a0,v1,v0				# Guardo en a0 la nueva direccion de memoria sobre obuffer: obuffer + *amountSavedInOBuffer = obuffer[*amountSavedInOBuffer]
	lw		v1,lexico				# Cargo en v1 lexico.
	lw		v0,52($fp)				# Cargo en v0 el indice i guardado en la direccion de memoria 52($fp).
	addu		v0,v1,v0				# Guardo en v0 la nueva direccion de memoria sobre lexico: lexico + i = lexico[i]
	lbu		v0,0(v0)				# Cargo en v0 lo guardado en la direccion de memoria almacenada en v0 (es sobre lexico).
	sb		v0,0(a0)				# Guardo en la direccion de memoria almacenada en a0 (es sobre obuffer) lo almacenado en v0. O sea: 
								# obuffer[*amountSavedInOBuffer] = lexico[i];
	
	# *amountSavedInOBuffer = (*amountSavedInOBuffer) + 1;
	lw		v1,84($fp)				# Cargo en v1 lo guardado en la direccion de memoria 84($fp), que representaria a la variable *amountSavedInOBuffer.
	lw		v0,84($fp)				# Cargo en v0 lo guardado en la direccion de memoria 84($fp), que representaria a la variable *amountSavedInOBuffer.
	lw		v0,0(v0)				# Cargo en v0 lo almacenado en la direccion de memoria guardada en v0 (*amountSavedInOBuffer).
	addu		v0,v0,1					# Incremento en 1 el contenido apuntado por amountSavedInOBuffer.
	sw		v0,0(v1)				# Guardo el incremento.
	
	# ++ i
	lw		v0,52($fp)				# Cargo en v0 el indice i guardado en la direccion de memoria 52($fp).
	addu		v0,v0,1					# Incremento en 1 el indice i.
	sw		v0,52($fp)				# Guardo el incremento.
	b		$ForLexicoInOBuffer			# Salto incondicional. Vuelvo al comienzo del loop for.
$WriteLexicoInOFile:
	# int rdoWrite = writeOBufferInOFile(amountSavedInOBuffer);
	lw		a0,84($fp)				# Cargo en a0 lo guardado en la direccion de memoria 84($fp), que representaria a la variable *amountSavedInOBuffer. 
								# Parametro de la funcion writeOBufferInOFile.
	la		t9,writeOBufferInOFile			# Cargo en t9 la direccion de la writeOBufferInOFile.
	jal		ra,t9					# Ejecuto la funcion writeOBufferInOFile.
	sw		v0,56($fp)				# Guardo en la direccion de memoria 56($fp) el resultado de ejecutar la funcion writeOBufferInOFile almacenado en v0.
	
	# rdoWrite != OKEY ?
	lw		v0,56($fp)				# Cargo en v0 el resultado de la ejecucion de la funcion writeOBufferInOFile, que seria la variable rdoWrite.
	beq		v0,OKEY,$WriteInNewOBuffer		# If (rdoWrite == OKEY) goto WriteInNewOBuffer.
	lw		v0,56($fp)				# Cargo en v0 el resultado de la ejecucion de la funcion writeOBufferInOFile, que seria la variable rdoWrite.
	sw		v0,60($fp)				# Guardo el codigo de error (en v0) en la direccion de memoria 60($fp).
	b		$ReturnExecutePalindromeWrite		# Salto incondicional al return de la funcion (goto ReturnExecutePalindromeWrite).
$WriteInNewOBuffer:
	# *amountSavedInOBuffer = 0;
	lw		v0,84($fp)				# Cargo en v0 lo guardado en la direccion de memoria 84($fp), que representaria a la variable *amountSavedInOBuffer.
	sw		zero,0(v0)				# Guardo 0 en la direccion apuntada por amountSavedInOBuffer.
	
	# savedInOFile = TRUE;
	li		v0,TRUE
	sw		v0,savedInOFile				# Guardo en savedInOFile el contenido de v0 (TRUE).
	
	# obuffer != NULL ?
	lw		v0,obuffer				# Cargo en v0 obuffer.
	beq		v0,DIR_NULL,$mymallocNewOBuffer		# If (obuffer == NULL) goto mymallocNewOBuffer.
	
	# obuffer != NULL => myfree(obuffer) and obuffer = NULL.
	lw		a0,obuffer				# Cargo en a0 obuffer.
	la		t9,myfree				# Cargo en t9 la direccion de memoria de myfree.
	jal		ra,t9					# Ejecuto myfree sobre obuffer.
	sw		zero,obuffer				# Asigno NULL a obuffer.
$mymallocNewOBuffer:
	# obuffer = (char *) mymalloc(osize*sizeof(char));
	lw		a0,osize				# Cargo en a0 osize.
	la		t9,mymalloc				# Cargo en t9 la direccion de memoria de mymalloc.
	jal		ra,t9					# Ejecuto mymalloc.
	sw		v0,obuffer				# Asigno la nueva direccion de memoria, que se encuentra almacenada en v0, a obuffer.
	
	# obuffer == NULL ?
	lw		v0,obuffer				# Cargo en v0 obuffer.
	bne		v0,DIR_NULL,$InitializeNewOBuffer 	# If (obuffer != NULL) goto InitializeNewOBuffer.
	
	# obuffer is NULL => Mensaje de error
	li		a0,FILE_DESCRIPTOR_STDERR		# Cargo en a0 FILE_DESCRIPTOR_STDERR.	
	la		a1,MENSAJE_ERROR_MEMORIA_OBUFFER 	# Cargo en a1 la direccion de memoria donde se encuentra el mensaje a cargar.
	li		a2,BYTES_MENSAJE_ERROR_MEMORIA_OBUFFER	# Cargo en a2 la cantidad de bytes a escribir.	
	li		v0, SYS_write
	syscall						# No controlo error porque sale de por si de la funcion por error.
	
	li		v0,ERROR_MEMORY
	sw		v0,60($fp)				# Guardo el codigo de error (en v0) en la direccion de memoria 60($fp).
	b		$ReturnExecutePalindromeWrite		# Salto incondicional al return de la funcion (goto ReturnExecutePalindromeWrite).
$InitializeNewOBuffer:
	lw		a0,osize				# Cargo en a0 osize. Parametro de la funcion initializeBuffer.
	lw		a1,obuffer				# Cargo en a1 obuffer. Parametro de la funcion initializeBuffer.
	la		t9,initializeBuffer			# Cargo en t9 la direccion de memoria de la funcion initializeBuffer.
	jal		ra,t9					# Ejecuto la funcion initializeBuffer.
	
	b		$myfreeLexico				# Salto incondicional a myfreeLexico.
$LoadLexicoInOBuffer:
	# (*amountSavedInOBuffer) > 0 ?
	lw		v0,84($fp)				# Cargo en v0 lo guardado en la direccion de memoria 84($fp), que representaria a la variable *amountSavedInOBuffer.
	lw		v0,0(v0)				# Cargo en v0 lo almacenado en la direccion de memoria guardada en v0 (*amountSavedInOBuffer).
	bgtz		v0,$LoadLineBeakInOBuffer		# Si (*amountSavedInOBuffer > 0), voy a guardar el salto de linea para separar lexicos que son palindromos (LoadLineBeakInOBuffer).
	
	# (*amountSavedInOBuffer) <= 0
	# savedInOFile == TRUE ?
	lw		v1,savedInOFile				# Cargo en v1 savedInOFile.
	li		v0,TRUE
	beq		v1,v0,$LoadLineBeakInOBuffer		# Si (savedInOFile == TRUE), voy a guardar el salto de linea para separar lexicos que son palindromos (LoadLineBeakInOBuffer).
	
	b		$LoadLexicoInOBufferNotWriteFile 	# Salto incondicional a LoadLexicoInOBufferNotWriteFile.
$LoadLineBeakInOBuffer:
	# obuffer[*amountSavedInOBuffer] = '\n';
	lw		v0,84($fp)				# Cargo en v0 lo guardado en la direccion de memoria 84($fp), que representaria a la variable *amountSavedInOBuffer.
	lw		v1,obuffer				# Cargo en v1 obuffer.
	lw		v0,0(v0)				# Cargo en v0 lo almacenado en la direccion de memoria guardada en v0 (*amountSavedInOBuffer).
	addu		v1,v1,v0				# Guardo en v1 la nueva posicion dentro de obuffer: obuffer[*amountSavedInOBuffer] = obuffer + *amountSavedInOBuffer
	li		v0,LINE_BREAK				# Cargo en v0 el literal LINE_BREAK (es 10 que representa a '\n').
	sb		v0,0(v1)				# Guardo en obuffer, en la posicion indicada en v1, LINE_BREAK. O sea: obuffer[*amountSavedInOBuffer] = '\n';
	
	# *amountSavedInOBuffer = (*amountSavedInOBuffer) + 1;
	lw		v1,84($fp)				# Cargo en v1 lo guardado en la direccion de memoria 84($fp), que representaria a la variable *amountSavedInOBuffer. 
	lw		v0,84($fp)				# Cargo en v0 lo guardado en la direccion de memoria 84($fp), que representaria a la variable *amountSavedInOBuffer.
	lw		v0,0(v0)				# Cargo en v0 lo almacenado en la direccion de memoria guardada en v0 (*amountSavedInOBuffer).
	addu		v0,v0,1					# Incremento en 1
	sw		v0,0(v1)				# Guardo nuevo valor de *amountSavedInOBuffer.
$LoadLexicoInOBufferNotWriteFile:
	sw		zero,56($fp)				# Guardo 0 en la direccion de memoria 56($fp). Inicializo indice en 0 para un nuevo loop.
$ForLexicoInOBufferNotWriteFile:
	lw		v0,56($fp)				# Cargo en v0 el indice (i) en 0.
	lw		v1,quantityCharacterInLexico		# Cargo en v1 quantityCharacterInLexico.
	slt		v0,v0,v1				# Guado en v0 TRUE si el indice i es menor que quantityCharacterInLexico. Caso contrario guardo FALSE
	bne		v0,FALSE,$GoInForLexicoInOBufferNotWriteFile # Si (i < quantityCharacterInLexico) goto GoInForLexicoInOBufferNotWriteFile.
	b		$myfreeLexico
$GoInForLexicoInOBufferNotWriteFile:
	# obuffer[*amountSavedInOBuffer] = lexico[i];
	lw		v0,84($fp)				# Cargo en v0 lo guardado en la direccion de memoria 84($fp), que representaria a la variable *amountSavedInOBuffer.
	lw		v1,obuffer				# Cargo en v1 obuffer.
	lw		v0,0(v0)				# Cargo en v0 lo almacenado en la direccion de memoria guardada en v0 (*amountSavedInOBuffer).
	addu		a0,v1,v0				# Guardo en v1 la nueva posicion dentro de obuffer: obuffer[*amountSavedInOBuffer] = obuffer + *amountSavedInOBuffer
	lw		v1,lexico				# Cargo en v1 lexico.
	lw		v0,56($fp)				# Cargo en v0 el indice i.				
	addu		v0,v1,v0				# Guardo en v0 la nueva posicion dentro de lexico: lexico[i] = lexico + i
	lbu		v0,0(v0)				# Cargo en v0 el contenido de la posicion dentro de lexico.
	sb		v0,0(a0)				# Guardo en la direccion apuntada por a0 (posicion dentro de obuffer0 el contenido almacenado en v0: 
								# obuffer[*amountSavedInOBuffer] = lexico[i];
	
	# *amountSavedInOBuffer = (*amountSavedInOBuffer) + 1;
	lw		v1,84($fp)
	lw		v0,84($fp)
	lw		v0,0(v0)
	addu		v0,v0,1					# Incremento en 1 a *amountSavedInOBuffer.
	sw		v0,0(v1)				# Guardo el nuevo valor de *amountSavedInOBuffer.
	
	# ++i
	lw		v0,56($fp)				# Cargo en v0 el indice i.				
	addu		v0,v0,1					# Incremento el indice.
	sw		v0,56($fp)				# Guardo nuevo valor del indice.
	b		$ForLexicoInOBufferNotWriteFile 	# Salto al principio del for para intentar entrar nuevamente al loop.
$myfreeLexico:
	lw		a0,lexico				# Cargo en a0 lexico.
	la		t9,myfree				# Cargo en t9 la direccion de la funcion myfree.
	jal		ra,t9					# Ejecuto la funcion myfree
	sw		zero,lexico				# Asigno NULL a lexico.
	sw		zero,quantityCharacterInLexico  	# Dejo quantityCharacterInLexico en 0.
$VerifyLoadIBuffer:
	# (idx + 1) == isize ?
	lw		v0,32($fp)				# Cargo en v0 lo guardado en la direccion 32($fp), que seria la variable idx.
	addu		v1,v0,1					# Incremento en 1 a idx y lo guardo en v1.
	lw		v0,isize				# Cargo en v0 isize para luego hacer comparacion.
	bne		v1,v0,$IncrementIdx			# If ((idx+1) != isize) goto IncrementIdx
	
	# ((idx + 1) == isize) is TRUE
	li		v0,TRUE
	sw		v0,28($fp)				# Guardo en la direccion 28($fp), que estaba la variable loadIBuffer, TRUE.
	li		v0,LOAD_I_BUFFER
	sw		v0,36($fp)				# Guardo en la direccion 36($fp), que estaba la variable rdo -resultado de la operacion-, LOAD_I_BUFFER.
	
	b		$WhileExecPalindromeWrite		# Salto incondicional al comienzo del while para verificar entrada al mismo.
$IncrementIdx:
	# idx ++
	lw		v0,32($fp)				# Cargo en v0 idx, guardado en la direccion 32($fp).
	addu		v0,v0,1					# Incremento en 1 a idx.
	sw		v0,32($fp)				# Guardo el nuevo valor de idx.
	
	b		$WhileExecPalindromeWrite		# Salto incondicional al comienzo del while para verificar entrada al mismo.
$LeaveWhileExecPalindromeWrite:
	lw		v0,36($fp)				# Cargo en v0 el resultado del while: variable rdo guardada en la direccion 36($fp).
	sw		v0,60($fp)				# Guardo en 60($fp) el resultado de la funcion.
$ReturnExecutePalindromeWrite:
	lw		v0,60($fp)
	move		sp,$fp
	lw		ra,72(sp)
	lw		$fp,68(sp)
	addu		sp,sp,80
	j		ra					# Jump and return
	.end		executePalindromeWrite


## Mensajes de error

	.rdata

	.align	2
MENSAJE_ERROR_MEMORIA_LEXICO:
	.ascii	"[Error] Hubo un error en memoria (lexico). \n\000"

	.align	2
MENSAJE_ERROR_MEMORIA_OBUFFER:
	.ascii	"[Error] Hubo un error de asignacion de memoria (obuffer)"
	.ascii	". \n\000"


