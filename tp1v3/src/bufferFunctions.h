/*
 * bufferFunctions.h
 *
 *  Created on: Oct 19, 2017
 *      Author: ediaz
 */

#ifndef BUFFERFUNCTIONS_H_
#define BUFFERFUNCTIONS_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>
#include <unistd.h>

#include "constants.h"
#include "memoryFunctions.h"


#define FALSE 0
#define TRUE 1

void initializeInput(int ifd, size_t ibytes);

void initializeOutput(int ofd, size_t obytes);

int getch();

int putch(int character);

#endif /* BUFFERFUNCTIONS_H_ */
