/*
 * bufferFunctions.h
 *
 */

#ifndef BUFFERFUNCTIONS_H_
#define BUFFERFUNCTIONS_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>

#include "constants.h"
#include "memoryFunctions.h"

typedef struct  {
    char * buffer;
    int quantityCharactersInBuffer;
    size_t sizeBytes;
} Buffer;

void initializeInput(int ifd, size_t ibytes);

void initializeOutput(int ofd, size_t obytes);

int getch();

int putch(int character);

int flush();

void freeResources();

int loadInBuffer(char character, Buffer * buffer, size_t sizeInitial);

void cleanContentBuffer(Buffer * buffer);

#endif /* BUFFERFUNCTIONS_H_ */
