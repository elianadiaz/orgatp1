
#include "process.h"


#define FALSE 0
#define TRUE 1
#define LEXICO_BUFFER_SIZE 3

enum ParameterState {
	 OKEY = 0, INCORRECT_QUANTITY_PARAMS = 1, ERROR_MEMORY = 2, ERROR_READ = 3, ERROR_WRITE = 4, LOAD_I_BUFFER = 5
};

size_t isize;
size_t osize;
int oFileDescriptor;
char * lexico = NULL;
int quantityCharacterInLexico = 0;
int savedInOFile = FALSE;
char * obuffer = NULL;
char * ibuffer = NULL;
int bytesLexico = 0;

char toLowerCase(char word) {
	/* ASCII:
	 * 		A - Z = [65 - 90]
	 * 		a - z = [97 - 122]
	 * 		0 - 9 = [48 - 57]
	 * 		- =  45
	 * 		_ = 95
	 */
	if (word >= 65 && word <= 90) {
		word += 32;
	}

	return word;
}

int verifyPalindromic(char * word, int quantityCharacterInWord) {
	if (word == NULL || quantityCharacterInWord <= 0) {
		return FALSE;
	}

	if (quantityCharacterInWord == 1) {
		// The word has one character
		return TRUE;
	}

	if (quantityCharacterInWord == 2) {
		char firstCharacter = toLowerCase(word[0]);
		char lastCharacter = toLowerCase(word[1]);
		if (firstCharacter != lastCharacter) {
			return FALSE;
		}

		return TRUE;
	}

	double middle = (double)quantityCharacterInWord / 2;
	int idx = 0;
	int validPalindromic = TRUE;
	int last = quantityCharacterInWord - 1;
	while(idx < middle && last > middle && validPalindromic == TRUE) {
		char firstCharacter = toLowerCase(word[idx]);
		char lastCharacter = toLowerCase(word[last]);
		if (firstCharacter != lastCharacter) {
			validPalindromic = FALSE;
		}

		idx ++;
		last --;
	}

	return validPalindromic;
}

int isKeywords(char character) {
	/* ASCII:
	 * 		A - Z = [65 - 90]
	 * 		a - z = [97 - 122]
	 * 		0 - 9 = [48 - 57]
	 * 		- =  45
	 * 		_ = 95
	 */
	if ((character >= 65 && character <= 90) || (character >= 97 && character <= 122)
			|| (character >= 48 && character <= 57)
			|| character == 45 || character == 95) {
		return TRUE;
	}

	return FALSE;
}

void * myRealloc(void * ptr, size_t tamanyoNew, int tamanyoOld) {
	if (tamanyoNew <= 0) {
		free(ptr);
		ptr = NULL;

		return NULL;
	}

	void * ptrNew = (void *) malloc(tamanyoNew);
	if (ptrNew == NULL) {
		return NULL;
	}

	if (ptr == NULL) {
		return ptrNew;
	}

	int end = tamanyoNew;
	if (tamanyoOld < tamanyoNew) {
		end = tamanyoOld;
	}

	char *tmp = ptrNew;
	const char *src   = ptr;

	while (end--) {
		*tmp = *src;
		tmp++;
		src++;
	}

	free(ptr);
	ptr = NULL;

	return ptrNew;
}

void initializeBuffer(size_t bytes, char * buffer) {
    // initialize the buffer
    int i;
    for(i = 0; i < bytes; ++i){
        buffer[i] = '\0';
    }
}

int writeBufferInOFile(int * amountSavedInBuffer, char * buffer) {
	int completeDelivery = FALSE;
	int bytesWriteAcum = 0;
	int bytesToWrite = (*amountSavedInBuffer);
	while (completeDelivery == FALSE) {
		int bytesWrite = write(oFileDescriptor, buffer + bytesWriteAcum, bytesToWrite);
		if (bytesWrite < 0) {
			return ERROR_WRITE;
		}

		bytesWriteAcum += bytesWrite;
		bytesToWrite = (*amountSavedInBuffer) - bytesWriteAcum;

		if (bytesToWrite <= 0) {
			completeDelivery = TRUE;
		}
	}

	return OKEY;
}

int loadInLexico(char character) {
	if (lexico == NULL) {
		lexico = malloc(LEXICO_BUFFER_SIZE * sizeof(char));
		bytesLexico = LEXICO_BUFFER_SIZE;
	} else if (quantityCharacterInLexico >= bytesLexico) {
		int bytesLexicoPreview = bytesLexico;
		bytesLexico += LEXICO_BUFFER_SIZE;
		lexico = myRealloc(lexico, bytesLexico*sizeof(char), bytesLexicoPreview);
	}

	if (lexico == NULL) {
		fprintf(stderr, "[Error] Hubo un error en memoria (lexico). \n");
		return ERROR_MEMORY;
	}

	lexico[quantityCharacterInLexico] = character;
	quantityCharacterInLexico ++;

	return OKEY;
}

void copyFromLexicoToOBuffer(int * amountSavedInOBuffer) {
	int i;
	for (i = 0; i < quantityCharacterInLexico; ++i) {
		obuffer[*amountSavedInOBuffer] = lexico[i];
		*amountSavedInOBuffer = (*amountSavedInOBuffer) + 1;
	}
}

char * loadBufferInitial(size_t size, char * buffer) {
	buffer = (char *) malloc(size*sizeof(char));
	if (buffer == NULL) {
		fprintf(stderr, "[Error] Hubo un error de asignacion de memoria (buffer). \n");
		return NULL;
	}

	// initialize the buffer
	initializeBuffer(size, buffer);

	return buffer;
}

int processDataInIBuffer(char * ibuffer, int * amountSavedInOBuffer) {
	int findEnd = FALSE;
	int loadIBuffer = FALSE;
	int idx = 0;
	int rdo = OKEY;
	while (findEnd == FALSE && loadIBuffer == FALSE) {
		char character = ibuffer[idx];
		if (character == '\0') {
			findEnd = TRUE;
		}

		if (findEnd != TRUE && isKeywords(character) == TRUE) {
			int rdo = loadInLexico(character);
			if (rdo != OKEY) {
				return rdo;
			}
		} else if (quantityCharacterInLexico > 0) {
			int itsPalindromic = verifyPalindromic(lexico, quantityCharacterInLexico);
			if (itsPalindromic == TRUE) {
				loadInLexico('\n');
				int amountToSaved = (*amountSavedInOBuffer) + quantityCharacterInLexico;
				if ((*amountSavedInOBuffer) > 0 || savedInOFile == TRUE) {
					amountToSaved ++; // Es para el separador
				}
				if (amountToSaved > osize) {
					/*
					 * Tomo la decision de pedir mas memoria para bajar el lexico completo
					 * y luego rearmo el buffer de salida y reinicio la cantidad guardada en 0.
					 */
					obuffer = myRealloc(obuffer, amountToSaved*sizeof(char), (*amountSavedInOBuffer));
					if (obuffer == NULL) {
						fprintf(stderr, "[Error] Hubo un error en memoria (obuffer). \n");
						return ERROR_MEMORY;
					}
					copyFromLexicoToOBuffer(amountSavedInOBuffer);

					int rdoWrite = writeBufferInOFile(amountSavedInOBuffer, obuffer);
					if (rdoWrite != OKEY) {
						return rdoWrite;
					}

					*amountSavedInOBuffer = 0;
					savedInOFile = TRUE;

					if (obuffer != NULL) {
						free(obuffer);
						obuffer = NULL;
					}

					obuffer = loadBufferInitial(osize, obuffer);
					if (obuffer == NULL) {
						return ERROR_MEMORY;
					}
				} else {
					copyFromLexicoToOBuffer(amountSavedInOBuffer);
				}
			}

			free(lexico);
			lexico = NULL;
			quantityCharacterInLexico = 0;
		}

		if ((idx + 1) == isize) {
			loadIBuffer = TRUE;
			rdo = LOAD_I_BUFFER;
		} else {
			idx ++;
		}
	}

	return rdo;
}

enum IBufferState {
	 COMPLETE_DELIVERY = -1, END_I_FILE = -2, ERROR_I_READ = -3, OKEY_I_FILE = -4
};

int loadIBufferWithIFile(size_t ibytes, int ifd) {
	int completeDelivery = FALSE;
	int bytesReadAcum = 0;
	int bytesToRead = ibytes;
	int end = FALSE;
	// Lleno el buffer de entrada
	while (completeDelivery == FALSE && end == FALSE) {
		int bytesRead = read(ifd, ibuffer + bytesReadAcum, bytesToRead);
		if (bytesRead == -1) {
			fprintf(stderr, "[Error] Hubo un error en la lectura de datos del archivo. \n");
			return ERROR_I_READ;
		}

		if (bytesRead == 0) {
			end = TRUE;
		}

		bytesReadAcum += bytesRead;
		bytesToRead = ibytes - bytesReadAcum;

		if (bytesToRead <= 0) {
			completeDelivery = TRUE;
		}
	}

	if (end == TRUE) {
		return END_I_FILE;
	}

	return OKEY_I_FILE;
}

int cleanBuffers(int * amountSavedInOBuffer) {
	int rdo = OKEY;
	if (ibuffer != NULL) {
		free(ibuffer);
		ibuffer = NULL;
	}

	if (obuffer != NULL) {
		if (amountSavedInOBuffer != NULL && (*amountSavedInOBuffer) > 0) {
			int rdoWrite = writeBufferInOFile(amountSavedInOBuffer, obuffer);
			if (rdoWrite != OKEY) {
				rdo = rdoWrite;
			}
		}

		free(obuffer);
		obuffer = NULL;
	}

	if (lexico != NULL) {
		if (quantityCharacterInLexico > 0 && verifyPalindromic(lexico, quantityCharacterInLexico) == TRUE) {
			loadInLexico('\n');
			int rdoWrite = writeBufferInOFile(&quantityCharacterInLexico, lexico);
			if (rdoWrite != OKEY) {
				rdo = rdoWrite;
			}
		}

		free(lexico);
		lexico = NULL;
	}

	return rdo;
}

int palindrome(int ifd, size_t ibytes, int ofd, size_t obytes) {
	isize = ibytes;
	osize = obytes;
	oFileDescriptor = ofd;

	ibuffer = loadBufferInitial(isize, ibuffer);
	if (ibuffer == NULL) {
		return ERROR_MEMORY;
	}

	obuffer = loadBufferInitial(osize, obuffer);
	if (obuffer == NULL) {
		free(ibuffer);
		ibuffer = NULL;
		return ERROR_MEMORY;
	}

	int * amountSavedInOBuffer = (int *) malloc(sizeof(int));
	if (amountSavedInOBuffer == NULL) {
		fprintf(stderr, "[Error] Hubo un error de asignacion de memoria (amountSavedInOBuffer). \n");
		free(ibuffer);
		ibuffer = NULL;
		free(obuffer);
		obuffer = NULL;
		return ERROR_MEMORY;
	}
	amountSavedInOBuffer[0] = 0;

	int rdoProcess = OKEY;
	int error = FALSE;
	int rdoLoadIBuffer = OKEY_I_FILE;
	while (rdoLoadIBuffer == OKEY_I_FILE && error == FALSE) {
		rdoLoadIBuffer = loadIBufferWithIFile(ibytes, ifd);

		if (ibuffer != NULL && ibuffer[0] != '\0') {
			int resultProcessWrite = processDataInIBuffer(ibuffer, amountSavedInOBuffer);
			if (resultProcessWrite == LOAD_I_BUFFER) {
				// initialize the ibuffer
				initializeBuffer(ibytes, ibuffer);
			}
			if (resultProcessWrite == ERROR_MEMORY || resultProcessWrite == ERROR_WRITE) {
				error = TRUE;
				rdoProcess = resultProcessWrite;
			}
		}
	}

	int rdoClean = cleanBuffers(amountSavedInOBuffer);

	if (amountSavedInOBuffer != NULL) {
		free(amountSavedInOBuffer);
		amountSavedInOBuffer = NULL;
	}

	if (rdoClean != OKEY) {
		return rdoClean;
	}

	return rdoProcess;
}
