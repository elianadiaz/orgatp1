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

#include "constants.h"
#include "palindromeFunctions.h"

#define VERSION "1.3"

size_t isize = 1;
size_t osize = 1;

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

int executeByMenu(int argc, char **argv) {
	int inputFileDefault = FALSE;
	int outputFileDefault = FALSE;
	FILE * fileInput = stdin;
	FILE * fileOutput = stdout;

	// Always begins with /
	if (argc == 1) {
		// Run with default parameters
		inputFileDefault = TRUE;
		outputFileDefault = TRUE;
	}

	char * pathInput = NULL;
	char * pathOutput = NULL;
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
				 pathInput = optarg;
				 break;
			 case 'o' :
				 pathOutput = optarg;
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
		isize = strtoul(iBufBytes, &finalPtr, 10);
		if (isize == 0) {
			fprintf(stderr, "[Error] Incorrecta cantidad de bytes para el buffer de entrada.\n");
			return ERROR_BYTES;
		}
	}

	if (oBufBytes != NULL) {
		char *finalPtr;
		osize = strtoul(oBufBytes, &finalPtr, 10);
		if (osize == 0) {
			fprintf(stderr, "[Error] Incorrecta cantidad de bytes para el buffer de salida.\n");
			return ERROR_BYTES;
		}
	}

	if (pathInput == NULL || strcmp("-",pathInput) == 0) {
		inputFileDefault = TRUE;
	}

	if (pathOutput == NULL || strcmp("-",pathOutput) == 0) {
		outputFileDefault = TRUE;
	}

	if (inputFileDefault == FALSE) {
		fileInput = fopen(pathInput, "r"); // Opens an existing text file for reading purpose.
		if (fileInput == NULL) {
			fprintf(stderr, "[Error] El archivo de input no pudo ser abierto para lectura: %s \n", pathInput);
			return ERROR_FILE;
		}
	}

	if (outputFileDefault == FALSE) {
		fileOutput = fopen(pathOutput, "w"); // Opens a text file for writing. Pace the content.
		if (fileOutput == NULL) {
			fprintf(stderr, "[Error] El archivo de output no pudo ser abierto para escritura: %s \n", pathOutput);

			if (inputFileDefault == FALSE) {
				int result = fclose(fileInput);
				if (result == EOF) {
					fprintf(stderr, "[Warning] El archivo de input no pudo ser cerrado correctamente: %s \n", pathInput);
				}
			}

			return ERROR_FILE;
		}
	}

	int ifd = fileno(fileInput);
	int ofd = fileno(fileOutput);

	int executeResult = palindrome(ifd, isize, ofd, osize);

	int resultFileInputClose = 0; // EOF = -1

	if (inputFileDefault == FALSE && fileInput != NULL) {
		resultFileInputClose = fclose(fileInput);
		if (resultFileInputClose == EOF) {
			fprintf(stderr, "[Warning] El archivo de input no pudo ser cerrado correctamente: %s \n", pathInput);
		}
	}

	if (outputFileDefault == FALSE && fileOutput != NULL) {
		int result = fclose(fileOutput);
		if (result == EOF) {
			fprintf(stderr, "[Warning] El archivo de output no pudo ser cerrado correctamente: %s \n", pathOutput);
			resultFileInputClose = EOF;
		}
	}

	if (resultFileInputClose != 0) {
		return ERROR_FILE;
	}

	return executeResult;
}

int main(int argc, char **argv) {
	// / -i lalala.txt -o pepe.txt -I 2 -O 3 => 9 parameters as maximum
	if (argc > 9) {
		fprintf(stderr, "[Error] Cantidad máxima de parámetros incorrecta: %d \n", argc);
		return INCORRECT_QUANTITY_PARAMS;
	}

	return executeByMenu(argc, argv);
}
