/*
 ============================================================================
 Name        : tp1.c
 Author      : Grupo orga 66.20
 Version     : 1
 Copyright   : Orga6620 - Tp1
 Description : Trabajo practico 1: Programacion MIPS
 ============================================================================
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>
#include <unistd.h>
#include "process.h"

#define VERSION "1.0"

#define FALSE 0
#define TRUE 1

size_t ibytes = 1;
size_t obytes = 1;

enum ParameterState {
	 OKEY = 0, INCORRECT_QUANTITY_PARAMS = 1, INCORRECT_MENU = 2, ERROR_FILE = 3, ERROR_MEMORY = 4, ERROR_READ = 5, ERROR_BYTES = 6
};

int executeHelp() {
	fprintf(stdout, "Usage: \n");
	fprintf(stdout, "	tp1 -h \n");
	fprintf(stdout, "	tp1 -V \n");
	fprintf(stdout, "	tp1 [options] \n");
	fprintf(stdout, "Options: \n");
	fprintf(stdout, "	-V, --version		Print version and quit. \n");
	fprintf(stdout, "	-h, --help	    	Print this information. \n");
	fprintf(stdout, "	-i, --input	    	Location of the input file. \n");
	fprintf(stdout, "	-o, --output		Location of the output file. \n");
	fprintf(stdout, "	-I, --ibuf-bytes	Byte-count of the input buffer. \n");
	fprintf(stdout, "	-O, --obuf-bytes	Byte-count of the output buffer. \n");
	fprintf(stdout, "Examples: \n");
	fprintf(stdout, "	tp1 -i ~/input -o ~/output \n");

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

	int ifd = fileno(fileInput);
	int ofd = fileno(fileOutput);

	int executeResult = palindrome(ifd, ibytes, ofd, obytes);

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

	int ifd = fileno(fileInput);
	int ofd = fileno(fileOutput);

	int executeResult = palindrome(ifd, ibytes, ofd, obytes);

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

int executeByMenu(int argc, char **argv) {
	// Always begins with /
	if (argc == 1) {
		// Run with default parameters
		return executeWithDefaultParameter(NULL, TRUE, TRUE);
	}

	char * inputValue = NULL;
	char * outputValue = NULL;
	char * iBufBytes = NULL;
	char * oBufBytes = NULL;

	/* Una cadena que lista las opciones cortas validas */
	const char* const smallOptions = "Vhi:o:I:O:";

	/* Una estructura de varios arrays describiendo los valores largos */
	const struct option longOptions[] = {
		{"version",		no_argument, 		0,  'V' },
		{"help",		no_argument,       	0,  'h' },
		{"input",		required_argument,  0,	'i' }, // optional_argument
		{"output",		required_argument,  0,	'o' },
		{"ibuf-bytes",	required_argument, 	0,  'I' },
		{"obuf-bytes",	required_argument, 	0,  'O' },
		{0,			0,                 	0,   0  }
	};

	int incorrectOption = FALSE;
	int finish = FALSE;
	int result = OKEY;
	int longIndex = 0;
	char opt = 0;

	while ((opt = getopt_long(argc, argv, smallOptions,
				   longOptions, &longIndex )) != -1 && incorrectOption == FALSE && finish == FALSE) {
		switch (opt) {
			 case 'V' :
				 result = executeVersion();
				 finish = TRUE;
				 break;
			 case 'h' :
				 result = executeHelp();
				 finish = TRUE;
				 break;
			 case 'i' :
				 inputValue = optarg;
				 break;
			 case 'o' :
				 outputValue = optarg;
				 break;
			 case 'I' :
				 iBufBytes = optarg;
				 break;
			 case 'O' :
				 oBufBytes = optarg;
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

	if (iBufBytes != NULL) {
		char *finalPtr;
		ibytes = strtoul(iBufBytes, &finalPtr, 10);
		if (ibytes == 0) {
			fprintf(stderr, "[Error] Incorrecta cantidad de bytes para el buffer de entrada.\n");
			return ERROR_BYTES;
		}
	}

	if (oBufBytes != NULL) {
		char *finalPtr;
		obytes = strtoul(oBufBytes, &finalPtr, 10);
		if (obytes == 0) {
			fprintf(stderr, "[Error] Incorrecta cantidad de bytes para el buffer de salida.\n");
			return ERROR_BYTES;
		}
	}

	if (inputValue == NULL && outputValue == NULL) {
		return executeWithDefaultParameter(NULL, TRUE, TRUE);
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

int main(int argc, char **argv) {
	// / -i lalala.txt -o pepe.txt -I 2 -O 3 => 9 parameters as maximum
	if (argc > 9) {
		fprintf(stderr, "[Error] Cantidad máxima de parámetros incorrecta: %d \n", argc);
		return INCORRECT_QUANTITY_PARAMS;
	}

	return executeByMenu(argc, argv);
}
