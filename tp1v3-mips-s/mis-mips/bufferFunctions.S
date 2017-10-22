#include <mips/regdef.h>
#include <sys/syscall.h>

#include "constants.h"
#include "memoryFunctions.h"

# Size mensajes
#define BYTES_MENSAJE_ERROR_MEMORIA_IBUFFER     60
#define BYTES_MENSAJE_ERROR_LECTURA_ARCHIVO     60
#define BYTES_MENSAJE_ERROR_ESCRITURA_ARCHIVO   51
#define BYTES_MENSAJE_ERROR_MEMORIA_OBUFFER	60
#define BYTES_MENSAJE_ERROR_MEMORIA_BUFFER	59

##-----	initializeInput -----##

        .text
        .align	2
        .globl  initializeInput
        .ent    initializeInput
initializeInput:
        .frame  $fp,16,ra
        .set    noreorder
        .cpload t9
        .set    reorder

        # Stack frame creation
        subu    sp,sp,16

        .cprestore 0
        sw      $fp,12(sp)
        sw      gp,8(sp)
	
        # de aqui al fin de la funcion uso $fp en lugar de sp.
        move    $fp,sp

        # Parametros
        sw      a0,16($fp)      # Guardo en la direccion de memoria 16($fp) la 
                                # variable iFileDescriptor (int).
        sw      a1,20($fp)      # Guardo en la direccion de memoria 20($fp) la 
                                # variable ibytes (size_t).

        # ifd = iFileDescriptor;
        lw      v0,16($fp)      # Cargo en v0 iFileDescriptor.
        sw      v0,ifd          # Guardo el contenido de v0, iFileDescriptor, en 
                                # la variable ifd.

        # ibuffer.sizeBytes = ibytes;
        lw      v0,20($fp)      # Cargo en v0 ibytes.
        sw      v0,ibuffer+8    # Guardo en sizeBytes (ibuffer+8) el contenido 
                                # de v0 (ibytes).

        move    sp,$fp
        lw      $fp,12(sp)
        # destruyo stack frame
        addu    sp,sp,16
        # vuelvo a funcion llamante
        j       ra

        .end    initializeInput



##-----	initializeOutput -----##

        .align  2
        .globl  initializeOutput
        .ent    initializeOutput
initializeOutput:
        .frame  $fp,16,ra
        .set    noreorder
        .cpload t9
        .set    reorder

        # Stack frame creation
        subu    sp,sp,16

        .cprestore 0
        sw      $fp,12(sp)
        sw      gp,8(sp)

        # de aqui al fin de la funcion uso $fp en lugar de sp.
        move    $fp,sp

        # Parametros
        sw      a0,16($fp)      # Guardo en la direccion de memoria 16($fp) la 
                                # variable oFileDescriptor (int).
        sw      a1,20($fp)      # Guardo en la direccion de memoria 20($fp) la 
                                # variable obytes (size_t).

        # ofd = oFileDescriptor;
        lw      v0,16($fp)      # Cargo en v0 oFileDescriptor.
        sw      v0,ofd          # Guardo el contenido de v0, oFileDescriptor, en 
                                # la variable ofd.

        # obuffer.sizeBytes = obytes;
        lw      v0,20($fp)      # Cargo en v0 obytes.
        sw      v0,obuffer+8    # Guardo en sizeBytes (obuffer+8) el contenido 
                                # de v0 (obytes).

        move    sp,$fp
        lw      $fp,12(sp)
        # destruyo stack frame
        addu    sp,sp,16
        # vuelvo a funcion llamante
        j       ra

        .end    initializeOutput



##-----	loadIBufferWithIFile -----##

        .align  2
        .globl  loadIBufferWithIFile
        .ent    loadIBufferWithIFile
loadIBufferWithIFile:
        .frame  $fp,56,ra
        .set    noreorder
        .cpload t9
        .set    reorder

        # Stack frame creation
        subu    sp,sp,56

        .cprestore 16
        sw      ra,48(sp)
        sw      $fp,44(sp)
        sw      gp,40(sp)

        # de aqui al fin de la funcion uso $fp en lugar de sp.
        move    $fp,sp

        # (ibuffer.buffer == NULL) ?
        lw      v0,ibuffer      # Cargo en v0 ibuffer. El primer campo del struct 
                                # es buffer.
        bne     v0,zero,ibufferNotNull # If (ibuffer.buffer != NULL) goto ibufferNotNull

        # ibuffer.buffer is NULL
        lw      a0,ibuffer+8    # Cargo en a0 la variable sizeBytes (ibuffer.sizeBytes).
                                # Es el tercer elemento del struct Buffer.
                                # Es parametro de la funcion mymalloc.
        la      t9,mymalloc     # Cargo en t9 la direccion de memoria de mymalloc.
        jal     ra,t9           # Ejecuto la funcion mymalloc.

        # Verifico asignacion de memoria.
        sw      v0,ibuffer      # Asigno la memoria reservada con mymalloc a ibuffer.buffer
        lw      v0,ibuffer      # Cargo en v0 ibuffer.buffer
        bne     v0,zero,ibufferNotNull # If (ibuffer.buffer != NULL) goto ibufferNotNull

        # ibuffer.buffer is NULL  => Mensaje de error.
        li      a0,FILE_DESCRIPTOR_STDERR # Cargo en a0 FILE_DESCRIPTOR_STDERR.
        la      a1,MENSAJE_ERROR_MEMORIA_IBUFFER # Cargo en a1 la direccion de memoria donde se encuentra el mensaje a cargar.
        li      a2,BYTES_MENSAJE_ERROR_MEMORIA_IBUFFER # Cargo en a2 la cantidad de bytes a escribir.
        li      v0, SYS_write
        syscall   # No controlo error porque sale de por si de la funcion por error.
        li      v0,ERROR_MEMORY
        sw      v0,36($fp)      # Guardo en la direccion de memoria 36($fp) el codigo de error.
                                # Es el resultado de la funcion loadIBufferWithFile.
        b       returnLoadIBufferWithFile # Salto incodicional al return de la funcion.
ibufferNotNull:
        # ibuffer.buffer is not NULL

        # int completeDelivery = FALSE;
        sw      zero,24($fp)    # Guardo en la direccion de memoria 24($fp) la variable 
                                # completeDelivery, inicializada en FALSE (= 0).

        # ibuffer.quantityCharactersInBuffer = 0;
        sw      zero,ibuffer+4  # Asigno 0 a la variable ibuffer.quantityCharactersInBuffer.
                                # quantityCharactersInBuffer es el segundo elemento del struct Buffer.

        # int bytesToRead = ibuffer.sizeBytes;
        lw      v0,ibuffer+8    # Cargo en v0 el valor de sizeBytes.
                                # sizeBytes es el tercer elemento del struct Buffer (Buffer ibuffer).
        sw      v0,28($fp)      # Guardo en la direccion 28($fp) el valor de sizeBytes, que representaria
                                # a la variable bytesToRead.

        # Lleno el buffer de entrada
whileLoadIBuffer:
        # (completeDelivery == FALSE && endIFile == FALSE) ?

        # (completeDelivery == FALSE) ?	
        lw      v0,24($fp)      # Cargo en v0 la variable completeDelivery, guardada 
                                # en la direccion 24($fp).
	bne     v0,FALSE,initializeLastPositionInIBufferRead # If (completeDelivery != FALSE) 
                                                    # goto initializeLastPositionInIBufferRead

        # completeDelivery is FALSE

        # (endIFile == FALSE) ?
        lw      v0,endIFile     # Cargo en v0 endIFile.
        bne     v0,FALSE,initializeLastPositionInIBufferRead # If (endIFile != FALSE) 
                                                 # goto initializeLastPositionInIBufferRead

        # completeDelivery is FALSE && endIFile is FALSE

        # int bytesRead = read(ifd, ibuffer.buffer + ibuffer.quantityCharactersInBuffer, bytesToRead);
        lw      v1,ibuffer      # Cargo en v1 ibuffer.buffer (primer elemento del struct Buffer).
        lw      v0,ibuffer+4    # Cargo en v0 ibuffer.quantityCharactersInBuffer (segundo 
                                # elemento del struct Buffer).
        addu    v0,v1,v0        # Me muevo sobre ibuffer.buffer. Guarda esta direccion de memoria
                                # en v0.

        lw      a0,ifd          # Cargo en a0 ifd, parametro de la funcion read.
        move    a1,v0           # Cargo la direccion de memoria que estaba en v0 en a1. Parametro
                                # de la funcion read.
        lw      a2,28($fp)      # Cargo en a2 bytesToRead que estaba en la direccion 28($fp).
        li      v0, SYS_read
        syscall     # Seria read: int bytesRead = read(ifd, ibuffer.buffer + 
                    #               ibuffer.quantityCharactersInBuffer, bytesToRead);

        # Controlo errores y cantidad de bytes leidos. v0 contiene el numero de caracteres 
        # leidos (es negativo si hubo error y es 0 si llego a fin del archivo).

        beq     a3,zero,savedBytesRead #Si a3 es cero, no hubo error 

        # Hubo error en la lectura de los datos => Mensaje de error.

        li     a0,FILE_DESCRIPTOR_STDERR # Cargo en a0 FILE_DESCRIPTOR_STDERR.
        la     a1,MENSAJE_ERROR_LECTURA_ARCHIVO # Cargo en a1 la direccion de memoria donde 
                                                # se encuentra el mensaje a cargar.
        li     a2,BYTES_MENSAJE_ERROR_LECTURA_ARCHIVO # Cargo en a2 la cantidad de bytes a escribir.
        li     v0, SYS_write
        syscall  # No controlo error porque sale de por si de la funcion por error.

        li     v0,ERROR_I_READ
        sw     v0,36($fp)       # Guardo en la direccion de memoria 36($fp) el codigo de error.
                                # Es el resultado de la funcion loadIBufferWithFile.
        b       returnLoadIBufferWithFile # Salto incodicional al return de la funcion.

savedBytesRead:
        sw      v0,32($fp)      # Guardo en la direccion de memoria 40($fd) el resultado de la 
                                # funcion read, que estaria representado por la variable bytesRead.

        # (bytesRead == 0) ?      
        lw      v0,32($fp)      # Cargo en v0 lo que esta en la direccion 32($fp), que seria bytesRead.
        bne     v0,zero,loadBytesRead # If (bytesRead != 0) goto loadBytesRead.

        # bytesRead is 0

        # endIFile = TRUE;
        li      v0,TRUE
        sw      v0,endIFile
loadBytesRead:
        # ibuffer.quantityCharactersInBuffer += bytesRead;
        lw      v1,ibuffer+4    # Cargo en v1 ibuffer.quantityCharactersInBuffer (segundo
                                # elemento del struct Buffer).
        lw      v0,32($fp)      # Cargo en v0 los bytes leidos (bytesRead).
        addu    v0,v1,v0        # Guardo el resultado de la suma en v0: 
                                # quantityCharactersInBuffer + bytesRead.
        sw      v0,ibuffer+4    # Guardo el resultado de la suma en ibuffer.quantityCharactersInBuffer.

        # bytesToRead = ibuffer.sizeBytes - ibuffer.quantityCharactersInBuffer;
        lw      v1,ibuffer+8    # Cargo en v1 ibuffer.sizeBytes.
        lw      v0,ibuffer+4    # Cargo en v0 ibuffer.quantityCharactersInBuffer.
        subu    v0,v1,v0        # Guardo el resultado de la suma en v0: 
                                # ibuffer.sizeBytes - ibuffer.quantityCharactersInBuffer
        sw      v0,28($fp)      # Guardo el resultado de la suma en la direccion 28($fp), que
                                # representa la variable bytesToRead.

        # (bytesToRead <= 0) ?
        lw      v0,28($fp)      # Cargo en v0 bytesToRead.
        bgtz    v0,whileLoadIBuffer # If (bytesToRead > 0) goto whileLoadIBuffer
	
        # bytesToRead is <= 0

        # completeDelivery = TRUE;
        li      v0,TRUE
        sw      v0,24($fp)      # Guardo TRUE en la direccion 24($fp), que 
                                # representa la variable completeDelivery.
        b       whileLoadIBuffer # Vuelvo a intentar entrar al loop.
initializeLastPositionInIBufferRead:
        # lastPositionInIBufferRead = -1;
        li      v0,-1
        sw      v0,lastPositionInIBufferRead
        
        # return OKEY_I_FILE;
        li      v0,OKEY_I_FILE
        sw      v0,36($fp)
returnLoadIBufferWithFile:
        lw      v0,36($fp)
        move    sp,$fp
        lw      ra,48(sp)
        lw      $fp,44(sp)
        # destruyo stack frame
        addu    sp,sp,56
        # vuelvo a funcion llamante
        j       ra

        .end    loadIBufferWithIFile



##-----	getch -----##

        .align  2
        .globl  getch
        .ent    getch
getch:
        .frame  $fp,48,ra
        .set    noreorder
        .cpload t9
        .set    reorder

        # Stack frame creation
        subu    sp,sp,48

        .cprestore 16
        sw      ra,40(sp)
        sw      $fp,36(sp)
        sw      gp,32(sp)

        # de aqui al fin de la funcion uso $fp en lugar de sp.
        move    $fp,sp

        # (ibuffer.buffer == NULL || lastPositionInIBufferRead == (ibuffer.quantityCharactersInBuffer - 1)) ?
        lw     v0,ibuffer       # Cargo en v0 ibuffer.buffer (primer elemento del struct Buffer).
        beq    v0,zero,verifyEndIFile	# If (ibuffer.buffer == NULL) goto verifyEndIFile

        # ibuffer.buffer is not NULL

        # (lastPositionInIBufferRead == (ibuffer.quantityCharactersInBuffer - 1)) ?
        lw      v0,ibuffer+4    # Cargo en v0 ibuffer.quantityCharactersInBuffer (segundo
                                # elemento del struct Buffer).
        addu    v1,v0,-1        # Cargo en v1 el resultadod de la suma: 
                                # ibuffer.quantityCharactersInBuffer + (-1)
        lw      v0,lastPositionInIBufferRead # Cargo en v0 lastPositionInIBufferRead
        beq     v0,v1,verifyEndIFile # If (lastPositionInIBufferRead == (ibuffer.quantityCharactersInBuffer - 1))
                                     # goto verifyEndIFile

        b       increaseLastPositionInIBufferRead # Salto incondicional.
verifyEndIFile:
        # (endIFile == TRUE) ?
        lw      v1,endIFile     # Cargo en v1 endIFile.
        li      v0,TRUE
        bne     v1,v0,loadIBuffer # If (endIFile != TRUE) goto loadIBuffer

        # endIFile is TRUE
        li      v0,EOF          # EOF = -1
        sw      v0,28($fp)      # Guardo en la direccion 28($fp) el resultado de la funcion.
        b       returnGetch     # Salto incondicional al return de la funcion.
loadIBuffer:
        # int resultLoadIBuffer = loadIBufferWithIFile();
        la      t9,loadIBufferWithIFile
        jal     ra,t9           # Ejecuto la funcion loadIBufferWithIFile
        sw      v0,24($fp)      # Guardo el resultado de la funcion en la direccion 24($fp),
                                # que representaria la variable resultLoadIBuffer.

        # (resultLoadIBuffer == ERROR_I_READ) ?
        lw      v1,24($fp)      # Cargo en v1 la variable de resultLoadIBuffer.
        li      v0,ERROR_I_READ
        bne     v1,v0,verifyQuantityCharactersInBuffer # If (resultLoadIBuffer != ERROR_I_READ) 
                                                       # goto verifyQuantityCharactersInBuffer

        # return ERROR_I_READ;
        li      v0,ERROR_I_READ
        sw      v0,28($fp)
        b       returnGetch
verifyQuantityCharactersInBuffer:
        # (ibuffer.quantityCharactersInBuffer == 0) ?
        lw      v0,ibuffer+4    # Cargo en v0 ibuffer.quantityCharactersInBuffer (segundo
                                # elemento del struct Buffer).
        # If (ibuffer.quantityCharactersInBuffer != 0) goto increaseLastPositionInIBufferRead
        bne     v0,zero,increaseLastPositionInIBufferRead

        # return EOF;
        li      v0,EOF          # EOF = -1
        sw      v0,28($fp)
        b       returnGetch
increaseLastPositionInIBufferRead:
        # lastPositionInIBufferRead ++;
        lw      v0,lastPositionInIBufferRead
        addu    v0,v0,1
        sw      v0,lastPositionInIBufferRead

        # return ibuffer.buffer[lastPositionInIBufferRead];
        lw      v1,ibuffer
        lw      v0,lastPositionInIBufferRead
        addu    v0,v1,v0
        lb      v0,0(v0)
        sw      v0,28($fp)
returnGetch:
        lw      v0,28($fp)
        move    sp,$fp
        lw      ra,40(sp)
        lw      $fp,36(sp)
        # destruyo stack frame
        addu    sp,sp,48
        # vuelvo a funcion llamante
        j       ra

       .end     getch



##-----	writeBufferInOFile -----##

        .align  2
        .globl  writeBufferInOFile
        .ent    writeBufferInOFile
writeBufferInOFile:
        .frame  $fp,64,ra
        .set    noreorder
        .cpload t9
        .set    reorder

        # Stack frame creation
        subu    sp,sp,64

        .cprestore 16
        sw      ra,56(sp)
        sw      $fp,52(sp)
        sw      gp,48(sp)

        # de aqui al fin de la funcion uso $fp en lugar de sp.
        move    $fp,sp

        # (obuffer.buffer == NULL || obuffer.quantityCharactersInBuffer <= 0) ?

        # (obuffer.buffer == NULL) ?
        lw      v0,obuffer      # Cargo en v0 obuffer.buffer (primer elemento del
                                # struct Buffer.
        beq     v0,zero,returnOkey # If (obuffer.buffer == NULL) goto returnOkey

        # obuffer.buffer is not NULL

        # (obuffer.quantityCharactersInBuffer <= 0) ?
        lw      v0,obuffer+4    # Cargo en v0 obuffer.quantityCharactersInBuffer
                                # (segundo elemento del struct Buffer).
        blez    v0,returnOkey   # If (obuffer.quantityCharactersInBuffer <= 0) 
                                # goto returnOkey.
        b       loadOBuffer     # Salto incondicional a loadOBuffer.
returnOkey:
        # return OKEY;
        sw      OKEY,40($fp)    # Guardo en la direccion 40($fp) el resultado de la
                                # funcion, en este caso OKEY (= 0).
        b       returnWriteBufferInOFile # Salto incondicional al return de la funcion.
loadOBuffer:
        # int completeDelivery = FALSE;
        sw      FALSE,24($fp)   # 24($fp) <-> completeDelivery

        # int bytesWriteAcum = 0;
        sw      zero,28($fp)    # 28($fp) <-> bytesWriteAcum

        # int bytesToWrite = obuffer.quantityCharactersInBuffer;
        lw      v0,obuffer+4   # quantityCharactersInBuffer es el segundo elemento del
                               # struct Buffer.
	sw	v0,32($fp)     # 32($fp) <-> bytesToWrite
whileWriteOFile:
        # (completeDelivery == FALSE) ?
        lw      v0,24($fp)     # Cargo en v0 completeDelivery
        beq     v0,FALSE,inWhileWriteOFile  # If (completeDelivery == FALSE) goto inWhileWriteOFile

        # completeDelivery is not FALSE (is TRUE)
        b       loadReturnOkey # Salto incondicional a loadReturnOkey.
inWhileWriteOFile:
        # int bytesWrite = write(ofd, obuffer.buffer + bytesWriteAcum, bytesToWrite);

        # obuffer.buffer + bytesWriteAcum
        lw      v1,obuffer     # obuffer.buffer es el primer elemento del struct Buffer.
        lw      v0,28($fp)     # Cargo en v0 bytesWriteAcum.
        addu    v0,v1,v0       # Me muevo por buffer, guardo la direccion en v0.

        lw      a0,ofd         # Cargo en a0 ofd. Parametro de la funcion write.
        move    a1,v0          # Cargo en a1 la direccion sobre obuffer.buffer.
                               # Parametro de la funcion write.
        lw      a2,32($fp)     # Cargo en a2 bytesToWrite. Parametro de la funcion write.

        li      v0, SYS_write
        syscall  # Seria int bytesWrite = write(ofd, obuffer.buffer + bytesWriteAcum, bytesToWrite);

        beq     a3,zero,saveBytesWrite # Si no hubo error, salto a saveBytesWrite.

        # Hubo error al querer escribir en el archivo => Mensaje de error. 
        li      a0,FILE_DESCRIPTOR_STDERR # Cargo en a0 FILE_DESCRIPTOR_STDERR.
        la      a1,MENSAJE_ERROR_ESCRITURA_ARCHIVO # Cargo en a1 la direccion de memoria donde se encuentra el mensaje a cargar.
        li      a2,BYTES_MENSAJE_ERROR_ESCRITURA_ARCHIVO # Cargo en a2 la cantidad de bytes a escribir.
        li      v0, SYS_write
        syscall # No controlo error porque sale de por si de la funcion por error.

        # return ERROR_WRITE;
        li      v0,ERROR_WRITE  # Cargo codigo de error, que sera el resultado de la funcion.
        sw      v0,40($fp)      # Guardo en la direccion 40($fp) el resultado de la funcion.
        b       returnWriteBufferInOFile
saveBytesWrite:
        sw      v0,36($fp)     # Guardo en la direccion 36($fp) los bytes escritor,
                                # que representarian la variable bytesWrite.
        # bytesWriteAcum += bytesWrite;
        lw      v1,28($fp)      # 28($fp) <-> bytesWriteAcum. Cargo en v1 bytesWriteAcum
        lw      v0,36($fp)      # Cargo en v0 bytesWrite.
        addu    v0,v1,v0        # Sumo estos dos valores y guardo resultado en v0.
        sw      v0,28($fp)      # Guardo en bytesWriteAcum su nuevo valor (resultado de la suma).

        # bytesToWrite = obuffer.quantityCharactersInBuffer - bytesWriteAcum;
        lw      v1,obuffer+4    # obuffer.quantityCharactersInBuffer es el segundo elemento
                                # del struct Buffer. Cargo este valor en v1.
        lw      v0,28($fp)      # Cargo en v0 bytesWriteAcum.
        subu    v0,v1,v0        # Resto estos dos valores. Guardo resultado en v0.
        sw      v0,32($fp)      # Asigno a bytesToWrite el resultado de la resta.

        # (bytesToWrite <= 0) ?
        lw      v0,32($fp)     # Cargo en v0 bytesToWrite
        bgtz    v0,whileWriteOFile # If (bytesToWrite > 0) goto whileWriteOFile

        # bytesToWrite is <= 0
        li      v0,TRUE
        sw      v0,24($fp)     # Asigno a completeDelivery TRUE
        b       whileWriteOFile
loadReturnOkey:
        sw      zero,40($fp)   # OKEY = 0
returnWriteBufferInOFile:
        lw      v0,40($fp)
        move    sp,$fp
        lw      ra,56(sp)
        lw      $fp,52(sp)
        # destruyo stack frame
        addu    sp,sp,64
        # vuelvo a funcion llamante
        j       ra

        .end    writeBufferInOFile



##-----	putch -----##

        .align  2
        .globl  putch
        .ent    putch
putch:
        .frame  $fp,48,ra
        .set    noreorder
        .cpload t9
        .set    reorder

        # Stack frame creation
        subu    sp,sp,48

       .cprestore 16
        sw      ra,40(sp)
        sw      $fp,36(sp)
        sw      gp,32(sp)

        # de aqui al fin de la funcion uso $fp en lugar de sp.
        move    $fp,sp

        # Parametro
        sw      a0,48($fp)      # Guardo en la direccion de memoria 48($fp) lo que tiene a0, que
                                # es el parametro que recibe la funcion, int character.

        # (obuffer.buffer == NULL) ?
        lw      v0,obuffer      # Cargo en v0 obuffer.buffer, que es el primer elemento del 
                                # struct Buffer.
        bne     v0,zero,loadInOBuffer # If (obuffer.buffer != NULL) goto loadInOBuffer

        # obuffer.buffer is NULL

        # Asigno memoria a obuffer.buffer
        # obuffer.buffer = (char *) malloc(obuffer.sizeBytes*sizeof(char));
        lw      a0,obuffer+8    # quantityCharactersInBuffer es el tercer elemento del struct Buffer.
        la      t9,mymalloc
        jal     ra,t9
        sw      v0,obuffer
        lw      v0,obuffer

        # Verifico error en la asignacion de memoria.
        # (obuffer.buffer == NULL) ?
        bne     v0,zero,initializeQuantityCharactersInOBuffer # If (obuffer.buffer != NULL) goto 
                                                              # initializeQuantityCharactersInOBuffer.

        # obuffer.buffer is NULL => Mensaje de error.
        li      a0,FILE_DESCRIPTOR_STDERR # Cargo en a0 FILE_DESCRIPTOR_STDERR.
        la      a1,MENSAJE_ERROR_MEMORIA_OBUFFER # Cargo en a1 la direccion de memoria donde se encuentra el mensaje a cargar.
        li      a2,BYTES_MENSAJE_ERROR_MEMORIA_OBUFFER	# Cargo en a2 la cantidad de bytes a escribir.
        li      v0, SYS_write
        syscall    # No controlo error porque sale de por si de la funcion por error.

        # return ERROR_MEMORY;
        li      v0,ERROR_MEMORY
        sw      v0,24($fp)      # Cargo en la direccion 24($fp) el resultado de la funcion,
                                # en este caso es el codigo de error ERROR_MEMORY.
        b       returnPutch     # Salto incondicional a returnPutch.
initializeQuantityCharactersInOBuffer:
        # obuffer.quantityCharactersInBuffer = 0;
        sw      zero,obuffer+4
loadInOBuffer:
        # obuffer.buffer[obuffer.quantityCharactersInBuffer] = character;
        lw      v1,obuffer      # Cargo obuffer.buffer en v1.
        lw      v0,obuffer+4    # Cargo obuffer.quantityCharactersInBuffer en v0.
        addu    v1,v1,v0        # Me muevo sobre obuffer.buffer, o sea: 
                                # obuffer.buffer[obuffer.quantityCharactersInBuffer]
                                # Guardo esta direccion en v1.
        lbu     v0,48($fp)      # Cargo en v0 character.
        sb      v0,0(v1)        # Asigno character a obuffer.buffer[obuffer.quantityCharactersInBuffer].

        # obuffer.quantityCharactersInBuffer ++;
        lw      v0,obuffer+4
        addu    v0,v0,1
        sw      v0,obuffer+4

        # (obuffer.quantityCharactersInBuffer == obuffer.sizeBytes) ?
        lw      v1,obuffer+4    # obuffer.quantityCharactersInBuffer es el segundo elemento del
                                # struct Buffer.
        lw      v0,obuffer+8    # obuffer.sizeBytes es el tercer elemento del struct Buffer.
        bne     v1,v0,loadReturnPutch # If (obuffer.quantityCharactersInBuffer != obuffer.sizeBytes) goto loadReturnPutch

        # obuffer.quantityCharactersInBuffer is equal obuffer.sizeBytes

        # writeBufferInOFile();
        la      t9,writeBufferInOFile
        jal     ra,t9

        # obuffer.quantityCharactersInBuffer = 0;
        sw      zero,obuffer+4
loadReturnPutch:
        # return OKEY;
        sw      zero,24($fp)
returnPutch:
        lw      v0,24($fp)
        move    sp,$fp
        lw      ra,40(sp)
        lw      $fp,36(sp)
        # destruyo stack frame
        addu    sp,sp,48
        # vuelvo a funcion llamante
        j       ra

        .end    putch



##-----	flush -----##

        .align  2
        .globl  flush
        .ent    flush
flush:
        .frame  $fp,48,ra
        .set    noreorder
        .cpload t9
        .set    reorder

        # Stack frame creation
        subu    sp,sp,48

        .cprestore 16
        sw      ra,40(sp)
        sw      $fp,36(sp)
        sw      gp,32(sp)

        # de aqui al fin de la funcion uso $fp en lugar de sp.
        move    $fp,sp

        # (obuffer.buffer != NULL && obuffer.quantityCharactersInBuffer > 0) ?

        # (obuffer.buffer != NULL) ?
        lw      v0,obuffer
        beq     v0,zero,loadReturnOkeyFlush # If (obuffer.buffer == NULL) goto loadReturnOkeyFlush.

        # obuffer.buffer is equal NULL

        # (obuffer.quantityCharactersInBuffer > 0) ?
        lw      v0,obuffer+4    # obuffer.quantityCharactersInBuffer es el segundo 
                                # elemento del struct Buffer.
        blez    v0,loadReturnOkeyFlush # If (obuffer.quantityCharactersInBuffer <= 0)
                                   # goto loadReturnOkeyFlush

        # obuffer.quantityCharactersInBuffer is > 0

        # return writeBufferInOFile();
        la      t9,writeBufferInOFile
        jal     ra,t9
        sw      v0,24($fp)    # Cargo en la direccion 24($fp) el resultado de ejecutar 
                              # la funcion writeBufferInOFile.
        b       returnFlush
loadReturnOkeyFlush:
        # return OKEY;
        sw      OKEY,24($fp)  # OKEY = 0
returnFlush:
        lw      v0,24($fp)
        move    sp,$fp
        lw      ra,40(sp)
        lw      $fp,36(sp)
        # destruyo stack frame
        addu    sp,sp,48
        # vuelvo a funcion llamante
        j       ra

        .end    flush



##-----	freeResources -----##

        .align  2
        .globl  freeResources
        .ent    freeResources
freeResources:
        .frame  $fp,40,ra
        .set    noreorder
        .cpload t9
        .set    reorder

        # Stack frame creation
        subu    sp,sp,40

        .cprestore 16
        sw      ra,32(sp)
        sw      $fp,28(sp)
        sw      gp,24(sp)

        # de aqui al fin de la funcion uso $fp en lugar de sp.
        move    $fp,sp

        # (ibuffer.buffer != NULL) ?
        lw      v0,ibuffer
        beq     v0,zero,freeOBufferBuffer # If (ibuffer.buffer == NULL) goto freeOBufferBuffer

        # ibuffer.buffer is not NULL

        # free(ibuffer.buffer);
        lw      a0,ibuffer    # ibuffer.buffer es el primer elemento del struct Buffer
                              # (Buffer ibuffer).
        la      t9,myfree
        jal     ra,t9

        # ibuffer.buffer = NULL;
        sw      zero,ibuffer
freeOBufferBuffer:
        # (obuffer.buffer != NULL) ?
        lw      v0,obuffer
        beq     v0,zero,returnFreeResources # If (obuffer.buffer == NULL) goto returnFreeResources

        # obuffer.buffer is not NULL

        # free(obuffer.buffer);
        lw      a0,obuffer    # obuffer.buffer es el primer elemento del struct Buffer
                              # (Buffer ibuffer).
        la      t9,myfree
        jal     ra,t9

        # obuffer.buffer = NULL;
        sw      zero,obuffer
returnFreeResources:
        move    sp,$fp
        lw      ra,32(sp)
        lw      $fp,28(sp)
        # destruyo stack frame
        addu    sp,sp,40
        # vuelvo a funcion llamante
        j       ra

        .end    freeResources



##-----	loadInBuffer -----##

        .align  2
        .globl  loadInBuffer
        .ent    loadInBuffer
loadInBuffer:
        .frame  $fp,56,ra
        .set    noreorder
        .cpload t9
        .set    reorder

        # Stack frame creation
        subu    sp,sp,56

        .cprestore 16
        sw      ra,52(sp)
        sw      $fp,48(sp)
        sw      gp,44(sp)
        sw      s0,40(sp)

        # de aqui al fin de la funcion uso $fp en lugar de sp.
        move    $fp,sp

        move    v0,a0           # Cargo en v0 lo que viene en a0, que es character (char).
	sw	a1,60($fp)      # Cargo en la direccion 60($fp) lo que viene en a1, que 
                                # es * buffer (Buffer * buffer).
	sw	a2,64($fp)      # Cargo en 64($fp) lo que viene en a2, que es sizeInitial (size_t).
	sb	v0,24($fp)      # Guardo en la direccion 24($fp) lo que estaba en v0, que era
                                # el parametro character.

        # (buffer->buffer == NULL) ?
	lw	v0,60($fp)      # Cargo en v0 la direccion de buffer.
	lw	v0,0(v0)        # Cargo en v0 el contenido en esa direccion de memoria, que
                                # que seria buffer->buffer.
	bne	v0,zero,compareQuantities # If (buffer->buffer != NULL) goto compareQuantities.

        # buffer->buffer is NULL

        # buffer->buffer = malloc(sizeInitial * sizeof(char));
	lw	s0,60($fp)      # Cargo en s0 la direccion de buffer.
	lw	a0,64($fp)      # Cargo en a0 sizeInitial, parametro para mymalloc.
	la	t9,mymalloc
	jal	ra,t9           # Ejecuto mymalloc.
	sw	v0,0(s0)        # Asigno la memoria a lo que apunta buffer (buffer -> buffer).
                                # La validacion de NULL en la asignacion de memoria se hace luego.

        # buffer->sizeBytes = sizeInitial;
	lw	v1,60($fp)      # Cargo en v1 la direccion de buffer.
	lw	v0,64($fp)      # Cargo en v0 sizeInitial.
	sw	v0,8(v1)        # Cargo en v0 buffer -> sizeBytes. sizeBytes es el tercer elemento 
                                # del struct Buffer.
	b	verifyMemory    # Salto incondicional para verificar la asignacion de memoria.
compareQuantities:
        # (buffer->quantityCharactersInBuffer >= buffer->sizeBytes) ?
        lw      v0,60($fp)     # Cargo en v0 la direccion de buffer.
        lw      v1,60($fp)     # Cargo en v1 la direccion de buffer.
        lw      a0,4(v0)       # Cargo en a0 buffer->quantityCharactersInBuffer. En el struct
                               # Buffer quantityCharactersInBuffer es el segundo elemento.
        lw      v0,8(v1)       # Cargo en v0 buffer->sizeBytes. En el struct
                               # Buffer sizeBytes es el tercer elemento.
        sltu    v0,a0,v0       # Guardo en v0 TRUE si buffer->quantityCharactersInBuffer es mas
                               # chico que buffer->sizeBytes, sino guardo FALSE (=0).
        bne     v0,FALSE,verifyMemory # If (buffer->quantityCharactersInBuffer < buffer->sizeBytes)
                                      # goto verifyMemory

        # buffer->quantityCharactersInBuffer is >= than buffer->sizeBytes

        # size_t bytesLexicoPreview = buffer->sizeBytes;
	lw	v0,60($fp)     # Cargo en v0 la direccion de buffer.
	lw	v0,8(v0)       # Cargo en v0 buffer->sizeBytes. En el struct
                               # Buffer sizeBytes es el tercer elemento.
	sw	v0,28($fp)     # Cargo en la direccion de memoria 28($fp) el valor de 
                               # buffer->sizeBytes, que representaria la variabla bytesLexicoPreview.

        # buffer->sizeBytes = bytesLexicoPreview * 2;
	lw	v1,60($fp)     # Cargo en v1 la direccion de buffer.
	lw	v0,28($fp)     # Cargo en v0 bytesLexicoPreview.
	sll	v0,v0,1        # bytesLexicoPreview * 2 y guardo resultado en v0.
                               # 1 porque 2 elevado a 1 es igual a 2.
	sw	v0,8(v1)       # Guardo el resultado de la multiplicacion en buffer->sizeBytes.

        # char * auxiliary = myRealloc(buffer->buffer, buffer->sizeBytes*sizeof(char), bytesLexicoPreview);
	lw	v0,60($fp)     # Cargo en v0 la direccion de buffer
	lw	v1,60($fp)     # Cargo en v1 la direccion de buffer
	lw	a0,0(v0)       # Cargo en a0 buffer->buffer. Parametro para myRealloc.
	lw	a1,8(v1)       # Cargo en a1 buffer->sizeBytes. Parametro para myRealloc. 
	lw	a2,28($fp)     # Cargo en a2 bytesLexicoPreview. Parametro para myRealloc.
	la	t9,myRealloc
	jal	ra,t9          # Ejecuto la funcion myRealloc.
	sw	v0,32($fp)     # Guardo en la direccion 32($fp) la memoria reservada.

        # (auxiliary == NULL) ?
	lw	v0,32($fp)     # Cargo en v0 la memoria reservada.
	bne	v0,zero,memoryAllocation # If (auxiliary != NULL) goto memoryAllocation.

        # Hubo problemas con la reasignacion de memoria.
	lw	a0,60($fp)     # Cargo en a0 buffer. Parametro de la funcion cleanContentBuffer.
	la	t9,cleanContentBuffer
	jal	ra,t9          # Ejecuto la funcion cleanContentBuffer para liberar memoria.

	b	verifyMemory
memoryAllocation:
        # buffer->buffer = auxiliary;
	lw	v1,60($fp)
	lw	v0,32($fp)
	sw	v0,0(v1)
verifyMemory:
        # (buffer->buffer == NULL) ?
	lw	v0,60($fp)
	lw	v0,0(v0)
	bne	v0,zero,loadCharacterInBuffer # If (buffer->buffer != NULL) goto loadCharacterInBuffer

        # buffer->buffer is NULL => Mensaje de error
	li      a0,FILE_DESCRIPTOR_STDERR # Cargo en a0 FILE_DESCRIPTOR_STDERR.
	la      a1,MENSAJE_ERROR_MEMORIA_BUFFER # Cargo en a1 la direccion de memoria donde se encuentra el mensaje a cargar.
	li      a2,BYTES_MENSAJE_ERROR_MEMORIA_BUFFER # Cargo en a2 la cantidad de bytes a escribir.
	li      v0, SYS_write
	syscall   # No controlo error porque sale de por si de la funcion por error.
	
        # return ERROR_MEMORY;
	li	v0,ERROR_MEMORY
	sw	v0,36($fp)      # Guardo en la direccion 36($fp) el codigo de error, 
                                # resultado de la funcion.
	b	returnLoadInBuffer
loadCharacterInBuffer:
        # buffer->buffer[buffer->quantityCharactersInBuffer] = character;
	lw	v0,60($fp)
	lw	v1,60($fp)
	lw	a0,0(v0)       # Cargo en a0 buffer->buffer
	lw	v0,4(v1)       # Cargo en v0 buffer->quantityCharactersInBuffer
	addu	v1,a0,v0       # Corrimiento sobre buffer->buffer. Guardo en v1
	lbu	v0,24($fp)     # Carga character en v0
	sb	v0,0(v1)       # Asigno character a esa direccion de memoria.

        # buffer->quantityCharactersInBuffer ++;
	lw	v1,60($fp)
	lw	v0,60($fp)
	lw	v0,4(v0)
	addu	v0,v0,1
	sw	v0,4(v1)

        # return OKEY;
	sw	zero,36($fp)    # OKEY = 0
returnLoadInBuffer:
	lw	v0,36($fp)
	move	sp,$fp
	lw	ra,52(sp)
	lw	$fp,48(sp)
	lw	s0,40(sp)
        # destruyo stack frame
	addu	sp,sp,56
        # vuelvo a funcion llamante
	j	ra

	.end	loadInBuffer


##-----	cleanContentBuffer -----##

        .align	2
	.globl	cleanContentBuffer
	.ent	cleanContentBuffer
cleanContentBuffer:
	.frame	$fp,40,ra
	.set	noreorder
	.cpload	t9
	.set	reorder

	subu	sp,sp,40

	.cprestore 16
	sw	ra,32(sp)
	sw	$fp,28(sp)
	sw	gp,24(sp)

	move	$fp,sp

        # Parametro
	sw	a0,40($fp)      # Guardo en la direccion 40($fp) el parametro * buffer (Buffer * buffer).

        # (buffer->buffer != NULL) ?
	lw	v0,40($fp)	
	lw	v0,0(v0)        # Cargo en v0 buffer -> buffer
	beq	v0,zero,cleanQuantities # If (buffer->buffer == NULL) goto cleanQuantities

        # buffer->buffer is not NULL

        # free(buffer->buffer);		
	lw	v0,40($fp)
	lw	a0,0(v0)
	la	t9,myfree
	jal	ra,t9

        # buffer->buffer = NULL;
	lw	v0,40($fp)
	sw	zero,0(v0)
cleanQuantities:
        # buffer->quantityCharactersInBuffer = 0;
	lw	v0,40($fp)
	sw	zero,4(v0)

        # buffer->sizeBytes = 0;
	lw	v0,40($fp)
	sw	zero,8(v0)

	move	sp,$fp
	lw	ra,32(sp)
	lw	$fp,28(sp)
        # destruyo stack frame
	addu	sp,sp,40
        # vuelvo a funcion llamante
	j	ra
	.end	cleanContentBuffer


# ---------------------------------------------------------------------------- #

## Variables auxiliares

	.data


	# -------------------------------------- #
	#					 #
	# typedef struct  {			 #
	#    char * buffer;			 #
	#    int quantityCharactersInBuffer;	 #
	#    size_t sizeBytes;			 #
	# } Buffer;				 #
	#					 #
	# Buffer ibuffer			 #
	# Buffer obuffer			 #
	#					 #
	# -------------------------------------- #


	## Variables para la parte de input

	.globl	ifd
#	.section	.bss   #TODO DESPUES VER SI ESTO SE PUEDE ELIMINAR
	.align	2
	.type	ifd, @object
	.size	ifd, 4
ifd:
	.space	4

	.globl	lastPositionInIBufferRead
	.align	2
	.type	lastPositionInIBufferRead, @object
	.size	lastPositionInIBufferRead, 4
lastPositionInIBufferRead:
	.word	-1

	.globl	ibuffer	
#	.section	.bss  TODO VER SI ANDA BIEN Y SACARLO
	.align	2
	.type	ibuffer, @object
	.size	ibuffer, 12
ibuffer:
	.space	12

	.globl	endIFile
	.globl	endIFile
	.align	2
	.type	endIFile, @object
	.size	endIFile, 4
endIFile:
	.space	4


	## Variables para la parte de input

	.globl	ofd
	.align	2
	.type	ofd, @object
	.size	ofd, 4
ofd:
	.space	4

	.globl	obuffer
	.align	2
	.type	obuffer, @object
	.size	obuffer, 12
obuffer:
	.space	12
	
## Mensajes de error

	.rdata	
	
	.align	2
MENSAJE_ERROR_MEMORIA_IBUFFER:
	.ascii	"[Error] Hubo un error de asignacion de memoria (ibuffer)"
	.ascii	". \n\000"
	
	.align	2
MENSAJE_ERROR_LECTURA_ARCHIVO:
	.ascii	"[Error] Hubo un error en la lectura de datos del archivo"
	.ascii	". \n\000"

	.align	2
MENSAJE_ERROR_ESCRITURA_ARCHIVO:
	.ascii	"[Error] Hubo un error al escribir en el archivo. \n\000"

         .align	2
MENSAJE_ERROR_MEMORIA_OBUFFER:
	.ascii	"[Error] Hubo un error de asignacion de memoria (obuffer)"
	.ascii	". \n\000"

MENSAJE_ERROR_MEMORIA_BUFFER:
	.ascii	"[Error] Hubo un error de asignacion de memoria (buffer)"
	.ascii	". \n\000"




	
