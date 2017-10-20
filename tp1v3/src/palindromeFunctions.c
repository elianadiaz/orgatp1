/*
 * palindromeFunctions.c
 *
 *  Created on: Oct 18, 2017
 *      Author: ediaz
 */

// TODO ACA VAN LAS FUNCIONES RELACIONADAS A PALINDROMES:
// toLowerCase  , verifyPalindromic , isKeywords , palindrome

#include "palindromeFunctions.h"

char * lexico = NULL;
int quantityCharacterInLexico = 0;
size_t sizeLexico = 0;

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

int verifyPalindromic() {
	if (lexico == NULL || quantityCharacterInLexico <= 0) {
		return FALSE;
	}

	if (quantityCharacterInLexico == 1) {
		// The word has one character
		return TRUE;
	}

	double middle = (double)quantityCharacterInLexico / 2;
	int idx = 0;
	int validPalindromic = TRUE;
	int last = quantityCharacterInLexico - 1;
	while(idx < middle && last >= middle && validPalindromic == TRUE) {
		char firstCharacter = toLowerCase(lexico[idx]);
		char lastCharacter = toLowerCase(lexico[last]);
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

int loadInLexico(char character) {
	if (lexico == NULL) {
		lexico = malloc(LEXICO_BUFFER_SIZE * sizeof(char));
		sizeLexico = LEXICO_BUFFER_SIZE;
	} else if (quantityCharacterInLexico >= sizeLexico) {
		int bytesLexicoPreview = sizeLexico;
		sizeLexico = bytesLexicoPreview * 2;
		lexico = myRealloc(lexico, sizeLexico*sizeof(char), bytesLexicoPreview);
	}

	if (lexico == NULL) {
		fprintf(stderr, "[Error] Hubo un error en memoria (lexico). \n");
		return ERROR_MEMORY;
	}

	lexico[quantityCharacterInLexico] = character;
	quantityCharacterInLexico ++;

	return OKEY;
}

int saveIfPalindrome() {
	int itsPalindromic = verifyPalindromic();

	if (itsPalindromic == TRUE) {
		int idx = 0;
		int error = FALSE;
		while(idx < quantityCharacterInLexico && error == FALSE) {
			int result = putch(lexico[idx]);
			if (result == EOF) {
				error = TRUE;
			}
		}

		if (error == FALSE) {
			int result = putch('\n');
			if (result == EOF) {
				error = TRUE;
			}
		}

		if (error == TRUE) {
			fprintf(stderr, "[Error] Error al escribir en el archivo output la palabra %s", lexico);
			return ERROR_PUTCH;
		}
	}

	return OKEY;
}

void freeLexico() {
	free(lexico);
	lexico = NULL;
	sizeLexico = 0;
	quantityCharacterInLexico = 0;
}

int palindrome(int ifd, size_t ibytes, int ofd, size_t obytes) {
	initializeInput(ifd, ibytes);
	initializeOutput(ofd, obytes);

	quantityCharacterInLexico = 0;
	int icharacter = getch();
	int result = OKEY;
	while (icharacter != EOF && icharacter != ERROR_I_READ && result == OKEY) {
		char character = icharacter;

		if (isKeywords(character) == TRUE) {
			result = loadInLexico(character);
		} else {
			// Dentro de esta funcion se invoca a putch si el lexico es palindromo.
			result = saveIfPalindrome();

			freeLexico();
		}

		icharacter = getch();
	}

	// Guardo lo que haya quedado en lexico si es palindromo.
	int resultFlush = saveIfPalindrome();
	if (result == OKEY) {
		result = resultFlush;
	}

	freeLexico();

	return result;
}
