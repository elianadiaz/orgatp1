/*
 * memoryFunctions.h
 *
 *  Created on: Oct 19, 2017
 *      Author: ediaz
 */

#ifndef MEMORYFUNCTIONS_H_
#define MEMORYFUNCTIONS_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>
#include <unistd.h>

void * myRealloc(void * ptr, size_t tamanyoNew, int tamanyoOld);

#endif /* MEMORYFUNCTIONS_H_ */
