/*
 * bufferFunctions.c
 *
 *  Created on: Oct 19, 2017
 *      Author: ediaz
 */

// TODO ACA VAN LAS FUNCIONES RELACIONADAS AL MANEJO DE BUFFERS:
// getch(), putch(), flush, close (clean, el que libere la memoria) , initializeBuffer (si es necesaria)

#include "bufferFunctions.h"

/*** input  ***/
int ifd = 0;
size_t ibytes = 0;
int lastPositionInIBufferRead = 0;
int quantityCharactersInIBuffer = 0;
char * ibuffer = NULL;

/*** output  ***/
int ofd = 0;
size_t obytes = 0;
int quantityCharactersInOBuffer = 0;
char * obuffer = NULL;

void initializeInput(int ifd, size_t ibytes) {
	ifd = ifd;
	ibytes = ibytes;
}

void initializeOutput(int ofd, size_t obytes) {
	ofd = ofd;
	obytes = obytes;
}

int loadIBufferWithIFile() {
	if (ibuffer == NULL) {
		ibuffer = (char *) malloc(ibytes*sizeof(char));
		if (ibuffer == NULL) {
			fprintf(stderr, "[Error] Hubo un error de asignacion de memoria (ibuffer). \n");
			return ERROR_MEMORY;
		}
	}

	int completeDelivery = FALSE;
	quantityCharactersInIBuffer = 0;
	int bytesToRead = ibytes;
	int end = FALSE;

	// Lleno el buffer de entrada
	while (completeDelivery == FALSE && end == FALSE) {
		int bytesRead = read(ifd, ibuffer + quantityCharactersInIBuffer, bytesToRead);
		if (bytesRead == -1) {
			fprintf(stderr, "[Error] Hubo un error en la lectura de datos del archivo. \n");
			return ERROR_I_READ;
		}

		if (bytesRead == 0) {
			end = TRUE;
		}

		quantityCharactersInIBuffer += bytesRead;
		bytesToRead = ibytes - quantityCharactersInIBuffer;

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
	if (lastPositionInIBufferRead == (quantityCharactersInIBuffer - 1)) {
		int resultLoadIBuffer = loadIBufferWithIFile();
		if (resultLoadIBuffer == ERROR_I_READ) {
			return ERROR_I_READ;
		}

		if (quantityCharactersInIBuffer == 0) {
			return EOF;
		}
	}

	lastPositionInIBufferRead ++;
	return ibuffer[lastPositionInIBufferRead];
}

int writeBufferInOFile() {
	int completeDelivery = FALSE;
	int bytesWriteAcum = 0;
	int bytesToWrite = quantityCharactersInOBuffer;
	while (completeDelivery == FALSE) {
		int bytesWrite = write(ofd, obuffer + bytesWriteAcum, bytesToWrite);
		if (bytesWrite < 0) {
			fprintf(stderr, "[Error] Hubo un error al escribir en el archivo. \n");
			return ERROR_WRITE;
		}

		bytesWriteAcum += bytesWrite;
		bytesToWrite = quantityCharactersInOBuffer - bytesWriteAcum;

		if (bytesToWrite <= 0) {
			completeDelivery = TRUE;
		}
	}

	return OKEY;
}

int putch(int character) {
	if (obuffer == NULL) {
		obuffer = (char *) malloc(obytes*sizeof(char));
		if (obuffer == NULL) {
			fprintf(stderr, "[Error] Hubo un error de asignacion de memoria (obuffer). \n");
			return ERROR_MEMORY;
		}

		quantityCharactersInOBuffer = 0;
	}

	obuffer[quantityCharactersInOBuffer] = character;
	quantityCharactersInOBuffer ++;

	if (quantityCharactersInOBuffer == obytes) {
		writeBufferInOFile();
		quantityCharactersInOBuffer = 0;
	}

	return OKEY;
}
