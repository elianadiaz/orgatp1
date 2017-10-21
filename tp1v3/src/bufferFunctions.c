/*
 * bufferFunctions.c
 *
 *  Created on: Oct 19, 2017
 *      Author: ediaz
 */

#include "bufferFunctions.h"

/*** input  ***/
int ifd = 0;
int lastPositionInIBufferRead = -1;
Buffer ibuffer = { NULL, 0, 0 }; // TODO HAY Q PASARLO A PUNTERO

/*** output  ***/
int ofd = 0;
Buffer obuffer = { NULL, 0, 0 }; // TODO HAY Q PASARLO A PUNTERO


void initializeInput(int iFileDescriptor, size_t ibytes) {
	ifd = iFileDescriptor;
	ibuffer.sizeBytes = ibytes;
}

void initializeOutput(int oFileDescriptor, size_t obytes) {
	ofd = oFileDescriptor;
	obuffer.sizeBytes = obytes;
}

int loadIBufferWithIFile() {
	if (ibuffer.buffer == NULL) {
		ibuffer.buffer = (char *) malloc(ibuffer.sizeBytes*sizeof(char));
		if (ibuffer.buffer == NULL) {
			fprintf(stderr, "[Error] Hubo un error de asignacion de memoria (ibuffer). \n");
			return ERROR_MEMORY;
		}
	}

	int completeDelivery = FALSE;
	ibuffer.quantityCharactersInBuffer = 0;
	int bytesToRead = ibuffer.sizeBytes;
	int end = FALSE;

	// Lleno el buffer de entrada
	while (completeDelivery == FALSE && end == FALSE) {
		int bytesRead = read(ifd, ibuffer.buffer + ibuffer.quantityCharactersInBuffer, bytesToRead);
		if (bytesRead == -1) {
			fprintf(stderr, "[Error] Hubo un error en la lectura de datos del archivo. \n");
			return ERROR_I_READ;
		}

		if (bytesRead == 0) {
			end = TRUE;
		}

		ibuffer.quantityCharactersInBuffer += bytesRead;
		bytesToRead = ibuffer.sizeBytes - ibuffer.quantityCharactersInBuffer;

		if (bytesToRead <= 0) {
			completeDelivery = TRUE;
		}
	}

	if (end == TRUE) {
		return END_I_FILE;
	}

	lastPositionInIBufferRead = -1;
	return OKEY_I_FILE;
}

int getch() {
	if (ibuffer.buffer == NULL || lastPositionInIBufferRead == (ibuffer.quantityCharactersInBuffer - 1)) {
		int resultLoadIBuffer = loadIBufferWithIFile();
		if (resultLoadIBuffer == ERROR_I_READ) {
			return ERROR_I_READ;
		}

		if (ibuffer.quantityCharactersInBuffer == 0) {
			return EOF;
		}
	}

	lastPositionInIBufferRead ++;
	return ibuffer.buffer[lastPositionInIBufferRead];
}

int writeBufferInOFile() {
	if (obuffer.buffer == NULL || obuffer.quantityCharactersInBuffer <= 0) {
		return OKEY;
	}

	int completeDelivery = FALSE;
	int bytesWriteAcum = 0;
	int bytesToWrite = obuffer.quantityCharactersInBuffer;
	while (completeDelivery == FALSE) {
		int bytesWrite = write(ofd, obuffer.buffer + bytesWriteAcum, bytesToWrite);
		if (bytesWrite < 0) {
			fprintf(stderr, "[Error] Hubo un error al escribir en el archivo. \n");
			return ERROR_WRITE;
		}

		bytesWriteAcum += bytesWrite;
		bytesToWrite = obuffer.quantityCharactersInBuffer - bytesWriteAcum;

		if (bytesToWrite <= 0) {
			completeDelivery = TRUE;
		}
	}

	return OKEY;
}

int putch(int character) {
	if (obuffer.buffer == NULL) {
		obuffer.buffer = (char *) malloc(obuffer.sizeBytes*sizeof(char));
		if (obuffer.buffer == NULL) {
			fprintf(stderr, "[Error] Hubo un error de asignacion de memoria (obuffer). \n");
			return ERROR_MEMORY;
		}

		obuffer.quantityCharactersInBuffer = 0;
	}

	obuffer.buffer[obuffer.quantityCharactersInBuffer] = character;
	obuffer.quantityCharactersInBuffer ++;

	if (obuffer.quantityCharactersInBuffer == obuffer.sizeBytes) {
		writeBufferInOFile();
		obuffer.quantityCharactersInBuffer = 0;
	}

	return OKEY;
}

int flush() {
	if (obuffer.buffer != NULL && obuffer.quantityCharactersInBuffer > 0) {
		return writeBufferInOFile();
	}

	return OKEY;
}

void freeResources() {
	if (ibuffer.buffer != NULL) {
		free(ibuffer.buffer);
		ibuffer.buffer = NULL;
	}

	if (obuffer.buffer != NULL) {
		free(obuffer.buffer);
		obuffer.buffer = NULL;
	}
}

int loadInBuffer(char character, Buffer * buffer, size_t sizeInitial) {
	if (buffer->buffer == NULL) {
		buffer->buffer = malloc(sizeInitial * sizeof(char));
		buffer->sizeBytes = sizeInitial;
	} else if (buffer->quantityCharactersInBuffer >= buffer->sizeBytes) {
		size_t bytesLexicoPreview = buffer->sizeBytes;
		buffer->sizeBytes = bytesLexicoPreview * 2;
		// Esto es para no perder memoria.
		char * auxiliary = myRealloc(buffer->buffer, buffer->sizeBytes*sizeof(char), bytesLexicoPreview);
		if (auxiliary == NULL) {
			cleanContentBuffer(buffer);
		} else {
			buffer->buffer = auxiliary;
		}
	}

	if (buffer->buffer == NULL) {
		fprintf(stderr, "[Error] Hubo un error en memoria (lexico). \n");
		return ERROR_MEMORY;
	}

	buffer->buffer[buffer->quantityCharactersInBuffer] = character;
	buffer->quantityCharactersInBuffer ++;

	return OKEY;
}

void cleanContentBuffer(Buffer * buffer) {
	if (buffer->buffer != NULL) {
		free(buffer->buffer);
		buffer->buffer = NULL;
	}

	buffer->quantityCharactersInBuffer = 0;
	buffer->sizeBytes = 0;
}
