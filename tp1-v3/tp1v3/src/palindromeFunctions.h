/*
 * palindromeFunctions.h
 *
 *  Created on: Oct 18, 2017
 *      Author: ediaz
 */

#ifndef PALINDROMEFUNCTIONS_H_
#define PALINDROMEFUNCTIONS_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>
#include <unistd.h>

#include "constants.h"
#include "bufferFunctions.h"
#include "memoryFunctions.h"

extern int palindrome(int ifd, size_t ibytes, int ofd, size_t obytes);

#endif /* PALINDROMEFUNCTIONS_H_ */