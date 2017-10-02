#include <stdio.h>

#include "mymalloc.h"

void * myRealloc(void * ptr, size_t tamanyoNew, int tamanyoOld) {
	if (tamanyoNew <= 0) {
		//free(ptr);
		myfree(ptr);

		ptr = NULL;

		return NULL;
	}

	//void * ptrNew = (void *) malloc(tamanyoNew);
	void * ptrNew = (void *) mymalloc(tamanyoNew);

	if (ptrNew == NULL) {
		//free(ptr);
		myfree(ptr);

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

	//free(ptr);
	myfree(ptr);

	ptr = NULL;

	return ptrNew;
}
