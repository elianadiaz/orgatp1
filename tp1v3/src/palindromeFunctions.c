/*
 * palindromeFunctions.c
 *
 *  Created on: Oct 18, 2017
 *      Author: ediaz
 */

// TODO ACA VAN LAS FUNCIONES RELACIONADAS A PALINDROMES:
// toLowerCase  , verifyPalindromic , isKeywords , palindrome

#include "palindromeFunctions.h"

/*
char * lexico = NULL;
int quantityCharacterInLexico = 0;
size_t sizeLexico = 0;
*/

Buffer lexico;

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
	if (lexico.buffer == NULL || lexico.quantityCharactersInBuffer <= 0) {
		return FALSE;
	}

	if (lexico.quantityCharactersInBuffer == 1) {
		// The word has one character
		return TRUE;
	}

	double middle = (double)lexico.quantityCharactersInBuffer / 2;
	int idx = 0;
	int validPalindromic = TRUE;
	int last = lexico.quantityCharactersInBuffer - 1;
	while(idx < middle && last >= middle && validPalindromic == TRUE) {
		char firstCharacter = toLowerCase(lexico.buffer[idx]);
		char lastCharacter = toLowerCase(lexico.buffer[last]);
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

int saveIfPalindrome() {
	int itsPalindromic = verifyPalindromic();

	if (itsPalindromic == TRUE) {
		int idx = 0;
		int error = FALSE;
		while(idx < lexico.quantityCharactersInBuffer && error == FALSE) {
			int result = putch(lexico.buffer[idx]);
			if (result == EOF) {
				error = TRUE;
			}

			idx ++;
		}

		if (error == FALSE) {
			int result = putch('\n');
			if (result == EOF) {
				error = TRUE;
			}
		}

		if (error == TRUE) {
			fprintf(stderr, "[Error] Error al escribir en el archivo output la palabra %s", lexico.buffer);
			return ERROR_PUTCH;
		}
	}

	return OKEY;
}

int palindrome(int ifd, size_t ibytes, int ofd, size_t obytes) {
	initializeInput(ifd, ibytes);
	initializeOutput(ofd, obytes);

	lexico.quantityCharactersInBuffer = 0;
	int icharacter = getch();
	int result = OKEY;
	while (icharacter != EOF && icharacter != ERROR_I_READ && result == OKEY) {
		char character = icharacter;

		if (isKeywords(character) == TRUE) {
			result = loadInBuffer(character, &lexico, LEXICO_BUFFER_SIZE);
		} else {
			// Dentro de esta funcion se invoca a putch si el lexico es palindromo.
			result = saveIfPalindrome();

			cleanContentBuffer(&lexico);
		}

		icharacter = getch();
	}

	// Guardo lo que haya quedado en lexico si es palindromo.
	int resultFlush = saveIfPalindrome();
	if (result == OKEY) {
		result = resultFlush;
	}

	cleanContentBuffer(&lexico);

	resultFlush = flush();
	if (result == OKEY) {
		result = resultFlush;
	}
	freeResources();


	return result;
}
