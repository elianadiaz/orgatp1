/*
 ============================================================================
 Name        : tp0.c
 Author      : grupo orga 66.20
 Version     : 1.3
 Copyright   : Orga6620
 Description : Trabajo practico 1: Programacion MIPS
 ============================================================================
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>
#include <unistd.h>

#define VERSION "1.3"

#define FALSE 0
#define TRUE 1

enum ParameterState {
	 OKEY = 0, INCORRECT_QUANTITY_PARAMS = 1, INCORRECT_MENU = 2, ERROR_FILE = 3, ERROR_MEMORY = 4, ERROR_READ = 5
};

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
	int quantityCharacterInWordWithoutEnd = quantityCharacterInWord - 1;
	if (word == NULL || quantityCharacterInWordWithoutEnd <= 0) {
		return FALSE;
	}

	if (word != NULL && quantityCharacterInWord && quantityCharacterInWordWithoutEnd == 1) {
		// The word has one character
		return TRUE;
	}

	int last = quantityCharacterInWordWithoutEnd - 1; // I take the end of word and keep in mind that it starts at zero.
	double middle = (double)last / 2;
	int idx = 0;
	int validPalindromic = TRUE;
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

int executePalindromic(char * buffer, int quantityCharacterInWord, FILE * fileOutput) {
	buffer[quantityCharacterInWord] = '\0';
	quantityCharacterInWord ++;
	int itsPalindromic = verifyPalindromic(buffer, quantityCharacterInWord);

	if (itsPalindromic == TRUE) {
		int result = fputs(buffer, fileOutput);
		if (result == EOF) {
			fprintf(stderr, "[Error] Error al escribir en el archivo output la palabra %s", buffer);
			return ERROR_FILE;
		}

		result = fputc('\n', fileOutput);
		if (result == EOF) {
			fprintf(stderr, "[Error] Error al escribir en el archivo output el salto de línea.");
			return ERROR_FILE;
		}
	}

	return OKEY;
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

int executeProcess(FILE * fileInput, FILE * fileOutput) {
	// Precondition: Files must be open.
	int icharacter = fgetc(fileInput);
	char * buffer = NULL;
	int quantityCharacterInWord = 0;
	while (icharacter != EOF) {
		char character = icharacter;

		buffer = (char *) myRealloc(buffer, (quantityCharacterInWord + 1)*sizeof(char), quantityCharacterInWord);
		if (buffer == NULL){
			fprintf(stderr, "[Error] Hubo un error en memoria \n");
			return ERROR_MEMORY;
		}

		if (isKeywords(character) == TRUE) {
			buffer[quantityCharacterInWord] = character;
			quantityCharacterInWord ++;
		} else {
			int result = executePalindromic(buffer, quantityCharacterInWord, fileOutput);

			free(buffer);
			buffer = NULL;
			quantityCharacterInWord = 0;

			if (result != OKEY) {
				return result;
			}
		}

		icharacter = fgetc(fileInput);
	}

	if (buffer != NULL) {
		int result = executePalindromic(buffer, quantityCharacterInWord, fileOutput);

		free(buffer);
		buffer = NULL;

		if (result != OKEY) {
			return result;
		}
	}

	return OKEY;
}

int executeHelp() {
	/*
	Usage:
		tp0 -h
		tp0 -V
		tp0 [options]
	Options:
		-V, --version Print version and quit.
		-h, --help Print this information.
		-i, --input Location of the input file.
		-o, --output Location of the output file.
	*/

	fprintf(stdout, "Usage: \n");
	fprintf(stdout, "	tp0 -h \n");
	fprintf(stdout, "	tp0 -V \n");
	fprintf(stdout, "	tp0 [options] \n");
	fprintf(stdout, "Options: \n");
	fprintf(stdout, "	-V, --version	Print version and quit. \n");
	fprintf(stdout, "	-h, --help	Print this information. \n");
	fprintf(stdout, "	-i, --input	Location of the input file. \n");
	fprintf(stdout, "	-o, --output	Location of the output file. \n");

	return OKEY;
}

int executeVersion() {
	fprintf(stdout, "Version: \"%s\" \n", VERSION);

	return OKEY;
}

int executeWithDefaultParameter(char * path, int isInputDefault, int isOutputDefault) {
	FILE * fileInput = NULL;
	FILE * fileOutput = NULL;

	if (isInputDefault == TRUE && isOutputDefault == TRUE) {
		fileInput = stdin;
		fileOutput = stdout;
	} else {
		if (isInputDefault == TRUE) {
			fileInput = stdin;

			fileOutput = fopen(path, "w"); // Opens a text file for writing. Pace the content.
			if (fileOutput == NULL) {
				fprintf(stderr, "[Error] El archivo de output no pudo ser abierto para escritura: %s \n", path);
				return ERROR_FILE;
			}
		} else {
			fileInput = fopen(path, "r"); // Opens an existing text file for reading purpose.
			if (fileInput == NULL) {
				fprintf(stderr, "[Error] El archivo de input no pudo ser abierto para lectura: %s \n", path);
				return ERROR_FILE;
			}

			fileOutput = stdout;
		}
	}

	int executeResult = executeProcess(fileInput, fileOutput);

	if (isInputDefault == FALSE || isOutputDefault == FALSE) {
		if (isInputDefault == TRUE) {
			if (fileOutput != NULL) {
				int result = fclose(fileOutput);
				if (result == EOF) {
					fprintf(stderr, "[Warning] El archivo de output no pudo ser cerrado correctamente: %s \n", path);
					return ERROR_FILE;
				}
			}
		} else {
			if (fileInput != NULL) {
				int result = fclose(fileInput);
				if (result == EOF) {
					fprintf(stderr, "[Warning] El archivo de input no pudo ser cerrado correctamente: %s \n", path);
					return ERROR_FILE;
				}
			}
		}
	}

	return executeResult;
}

int executeWithParameters(char * pathInput, char * pathOutput) {
	FILE * fileInput = fopen(pathInput, "r"); // Opens an existing text file for reading purpose.
	if (fileInput == NULL) {
		fprintf(stderr, "[Error] El archivo de input no pudo ser abierto para lectura: %s \n", pathInput);
		return ERROR_FILE;
	}

	FILE * fileOutput = fopen(pathOutput, "w"); // Opens a text file for writing. Pace the content.
	if (fileOutput == NULL) {
		fprintf(stderr, "[Error] El archivo de output no pudo ser abierto para escritura: %s \n", pathOutput);

		int result = fclose(fileInput);
		if (result == EOF) {
			fprintf(stderr, "[Warning] El archivo de input no pudo ser cerrado correctamente: %s \n", pathInput);
		}

		return ERROR_FILE;
	}

	int executeResult = executeProcess(fileInput, fileOutput);

	int resultFileInputClose = 0; // EOF = -1
	if (fileInput != NULL) {
		resultFileInputClose = fclose(fileInput);
		if (resultFileInputClose == EOF) {
			fprintf(stderr, "[Warning] El archivo de input no pudo ser cerrado correctamente: %s \n", pathInput);
		}
	}

	if (fileOutput != NULL) {
		int result = fclose(fileOutput);
		if (result == EOF) {
			fprintf(stderr, "[Warning] El archivo de output no pudo ser cerrado correctamente: %s \n", pathOutput);
			return ERROR_FILE;
		}
	}

	if (resultFileInputClose) {
		return ERROR_FILE;
	}

	return executeResult;
}

int executeByMenu2(int argc, char *argv[]){
	// Always begins with /
	if (argc == 1) {
		// Run with default parameters
		return executeWithDefaultParameter(NULL, TRUE, TRUE);
	}

	char* inputValue; //= malloc(sizeof(char));
	char* outputValue; // = malloc(sizeof(char));

	int opt;
	int opt_idx;

	int incorrectOption = FALSE;
	int finish = FALSE;
	int result = OKEY;

	const char* const op_sort = "hv:i:o:";

	struct option op_long[] = {
			//{"V",		no_argument,		0,  'V' },
			{"version",	no_argument, 		0,  'v' },
			//{"h",		no_argument,       	0,  'h' },
			{"help",	no_argument,       	0,  'H' },
			//{"i",		required_argument, 	0,  'i' },
			{"input",	required_argument,  0,	'i' },
			//{"o",		required_argument,	0,  'o' },
			{"output",	required_argument, 	0,  'o' },
			{0,			0,                 	0,   0  }
		};

	while(1){
		opt = getopt_long(argc, argv, op_sort, op_long, &opt_idx);

		if (opt == -1)
		        	break;

		switch(opt){
		case 'V' :
			result = executeVersion();
			finish = TRUE;
			break;
		 case 'v' :
			 result = executeVersion();
			 finish = TRUE;
			 break;
		 case 'h' :
			 result = executeHelp();
			 finish = TRUE;
			 break;
		 case 'H' :
			 result = executeHelp();
			 finish = TRUE;
			 break;
		 case 'i' :
			 inputValue = opt;
			 break;
		 case 'I' :
			 inputValue = opt;
			 break;
		 case 'o' :
			 outputValue = opt;
			 break;
		 case 'O' :
			 outputValue = opt;
			 break;
		 default:
			 incorrectOption = TRUE;
		}
	}
	puts("Input value: ");
	//puts(inputValue);puts("\n");
	fprintf("%s\n",inputValue);
	puts("Output value: ");
	//puts(outputValue);puts("\n");
	fprintf("%s\n",outputValue);



}

int executeByMenu(int argc, char *argv[]) {
	// Always begins with /
	if (argc == 1) {
		// Run with default parameters
		return executeWithDefaultParameter(NULL, TRUE, TRUE);
	}

	char* inputValue;
	char* outputValue;

	struct option longOptions[] = {
		//{"V",		no_argument,		0,  'V' },
		{"version",	no_argument, 		0,  'v' },
		//{"h",		no_argument,       	0,  'h' },
		{"help",	no_argument,       	0,  'H' },
		//{"i",		required_argument, 	0,  'i' },
		{"input",	required_argument,  0,	'I' },
		//{"o",		required_argument,	0,  'o' },
		{"output",	required_argument, 	0,  'O' },
		{0,			0,                 	0,   0  }
	};

	int incorrectOption = FALSE;
	int finish = FALSE;
	int result = OKEY;
	int longIndex = 0;
	char opt = 0;

	while ((opt = getopt_long(argc, argv, "VvhH:i:I:o:O::" ,
				   longOptions, &longIndex )) != -1 && incorrectOption == FALSE && finish == FALSE) {
		switch (opt) {
			 case 'V' :
				 result = executeVersion();
				 finish = TRUE;
				 break;
			 case 'v' :
				 result = executeVersion();
				 finish = TRUE;
				 break;
			 case 'h' :
				 result = executeHelp();
				 finish = TRUE;
				 break;
			 case 'H' :
				 result = executeHelp();
				 finish = TRUE;
				 break;
			 case 'i' :
				 if(optarg)
					 inputValue = optarg;
				 break;
			 case 'I' :
				 if(optarg)
					 inputValue = optarg;
				 break;
			 case 'o' :
				 if(optarg)
					 outputValue = optarg;
				 break;
			 case 'O' :
				 if(optarg)
					 outputValue = optarg;
				 break;
			 default:
				 incorrectOption = TRUE;
		}
	}

	if (incorrectOption == TRUE) {
		fprintf(stderr, "[Error] Incorrecta option de menu.\n");
		return INCORRECT_MENU;
	}

	if (finish == TRUE) {
		return result;
	}

	// / -i fileInput
	if (inputValue != NULL && outputValue == NULL) {
		if (strcmp("-",inputValue) == 0) {
			return executeWithDefaultParameter(NULL, TRUE, TRUE);
		} else {
			return executeWithDefaultParameter(inputValue, FALSE, TRUE);
		}
	}

	// / -o fileOutput
	if (inputValue == NULL && outputValue != NULL) {
		if (strcmp("-",outputValue) == 0) {
			return executeWithDefaultParameter(NULL, TRUE, TRUE);
		} else {
			return executeWithDefaultParameter(outputValue, TRUE, FALSE);
		}
	}

	if (inputValue != NULL && outputValue != NULL) {
		if (strcmp("-",inputValue) == 0 && strcmp("-",outputValue) == 0) {
			return executeWithDefaultParameter(NULL, TRUE, TRUE);
		}

		if (strcmp("-",inputValue) == 0 && strcmp("-",outputValue) != 0) {
			return executeWithDefaultParameter(outputValue, TRUE, FALSE);
		}

		if (strcmp("-",inputValue) != 0 && strcmp("-",outputValue) == 0) {
			return executeWithDefaultParameter(inputValue, FALSE, TRUE);
		}

		return executeWithParameters(inputValue, outputValue);
	}

	fprintf(stderr, "[Error] Incorrecta option de menu.\n");
	return INCORRECT_MENU;
}

int main(int argc, char *argv[]) {
	// / -i lalala.txt -o pepe.txt  => 5 parameters as maximum
	if (argc > 5) {
		fprintf(stderr, "[Error] Cantidad máxima de parámetros incorrecta: %d \n", argc);
		return INCORRECT_QUANTITY_PARAMS;
	}

	return executeByMenu(argc, argv);
}
