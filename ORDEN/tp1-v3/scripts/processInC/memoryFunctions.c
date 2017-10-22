/*
 * memoryFunctions.c
 *
 */

#include "memoryFunctions.h"

void * myRealloc(void * ptr, size_t tamanyoNew, int tamanyoOld) {
	if (tamanyoNew <= 0) {
		free(ptr);
		ptr = NULL;

		return NULL;
	}

	void * ptrNew = (void *) malloc(tamanyoNew);
	if (ptrNew == NULL) {
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

