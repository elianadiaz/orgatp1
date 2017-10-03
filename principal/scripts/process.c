
#include "process.h"


#define FALSE 0
#define TRUE 1

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

	if (word != NULL && quantityCharacterInWord == 1) {
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
		free(ptr);
		ptr = NULL;

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

int writeOBufferInOFile(int * amountSavedInOBuffer) {
	int completeDelivery = FALSE;
	int bytesWriteAcum = 0;
	int bytesToWrite = (*amountSavedInOBuffer);
	while (completeDelivery == FALSE) {
		int bytesWrite = write(oFileDescriptor, obuffer + bytesWriteAcum, bytesToWrite);
		if (bytesWrite < 0) {
			return ERROR_READ;
		}

		bytesWriteAcum += bytesWrite;
		bytesToWrite = (*amountSavedInOBuffer) - bytesWriteAcum;

		if (bytesToWrite <= 0) {
			completeDelivery = TRUE;
		}
	}

	return OKEY;
}

int executePalindromeWrite(char * ibuffer, int * amountSavedInOBuffer) {
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
			lexico = myRealloc(lexico, (quantityCharacterInLexico + 1)*sizeof(char), quantityCharacterInLexico);
			if (lexico == NULL) {
				fprintf(stderr, "[Error] Hubo un error en memoria (lexico). \n");
				return ERROR_MEMORY;
			}

			lexico[quantityCharacterInLexico] = character;
			quantityCharacterInLexico ++;
		} else if (quantityCharacterInLexico > 0) {
			int itsPalindromic = verifyPalindromic(lexico, quantityCharacterInLexico);
			if (itsPalindromic == TRUE) {
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
					if ((*amountSavedInOBuffer) > 0 || savedInOFile == TRUE) {
						obuffer[*amountSavedInOBuffer] = '\n';
						*amountSavedInOBuffer = (*amountSavedInOBuffer) + 1;
					}

					int i;
					for (i = 0; i < quantityCharacterInLexico; ++i) {
						obuffer[*amountSavedInOBuffer] = lexico[i];
						*amountSavedInOBuffer = (*amountSavedInOBuffer) + 1;
					}

					int rdoWrite = writeOBufferInOFile(amountSavedInOBuffer);
					if (rdoWrite != OKEY) {
						return rdoWrite;
					}

					*amountSavedInOBuffer = 0;
					savedInOFile = TRUE;
					if (obuffer != NULL) {
						free(obuffer);
						obuffer = NULL;
					}

					obuffer = (char *) malloc(osize*sizeof(char));
					if (obuffer == NULL) {
						fprintf(stderr, "[Error] Hubo un error de asignacion de memoria (obuffer). \n");
						return ERROR_MEMORY;
					}

					// initialize the obuffer
					initializeBuffer(osize, obuffer);
				} else {
					if ((*amountSavedInOBuffer) > 0 || savedInOFile == TRUE) {
						obuffer[*amountSavedInOBuffer] = '\n';
						*amountSavedInOBuffer = (*amountSavedInOBuffer) + 1;
					}

					int i;
					for (i = 0; i < quantityCharacterInLexico; ++i) {
						obuffer[*amountSavedInOBuffer] = lexico[i];
						*amountSavedInOBuffer = (*amountSavedInOBuffer) + 1;
					}
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

int palindrome(int ifd, size_t ibytes, int ofd, size_t obytes) {
	isize = ibytes;
	osize = obytes;
	oFileDescriptor = ofd;
	char * ibuffer = (char *) malloc(ibytes*sizeof(char));
	if (ibuffer == NULL) {
		fprintf(stderr, "[Error] Hubo un error de asignacion de memoria (ibuffer). \n");
		return ERROR_MEMORY;
	}

	obuffer = (char *) malloc(obytes*sizeof(char));
	if (obuffer == NULL) {
		fprintf(stderr, "[Error] Hubo un error de asignacion de memoria (obuffer). \n");
		free(ibuffer);
		ibuffer = NULL;
		return ERROR_MEMORY;
	}

	// initialize the ibuffer
	initializeBuffer(ibytes, ibuffer);
    // initialize the obuffer
	initializeBuffer(obytes, obuffer);

	int * amountSavedInOBuffer = (int *) malloc(sizeof(int));
	if (amountSavedInOBuffer == NULL) {
		fprintf(stderr, "[Error] Hubo un error de asignacion de memoria (amountSaved). \n");
		free(ibuffer);
		ibuffer = NULL;
		free(obuffer);
		obuffer = NULL;
		return ERROR_MEMORY;
	}
	amountSavedInOBuffer[0] = 0;

	int rdoProcess = OKEY;
	int end = FALSE;
	int error = FALSE;
	while (end == FALSE && error == FALSE) {
		int completeDelivery = FALSE;
		int bytesReadAcum = 0;
		size_t bytesToRead = ibytes;
		// Lleno el buffer de entrada
		while (completeDelivery == FALSE && end == FALSE) {
			int bytesRead = read(ifd, ibuffer + bytesReadAcum, bytesToRead);
			if (bytesRead == -1) {
				fprintf(stderr, "[Error] Hubo un error en la lectura de datos del archivo. \n");
				free(ibuffer);
				ibuffer = NULL;
				free(obuffer);
				obuffer = NULL;
				free(amountSavedInOBuffer);
				amountSavedInOBuffer = NULL;
				if (lexico != NULL) {
					free(lexico);
					lexico = NULL;
				}
				return ERROR_READ;
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

		if (ibuffer != NULL && ibuffer[0] != '\0') {
			int resultProcessWrite = executePalindromeWrite(ibuffer, amountSavedInOBuffer);
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

	if (ibuffer != NULL) {
		free(ibuffer);
		ibuffer = NULL;
	}

	if (obuffer != NULL) {
		if (amountSavedInOBuffer != NULL && (*amountSavedInOBuffer) > 0) {
			int rdoWrite = writeOBufferInOFile(amountSavedInOBuffer);
			if (rdoWrite != OKEY) {
				rdoProcess = rdoWrite;
			}
		}

		free(obuffer);
		obuffer = NULL;
	}

	if (lexico != NULL) {
		free(lexico);
		lexico = NULL;
	}

	if (amountSavedInOBuffer != NULL) {
		free(amountSavedInOBuffer);
		amountSavedInOBuffer = NULL;
	}

	return rdoProcess;
}
