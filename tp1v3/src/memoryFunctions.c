/*
 * memoryFunctions.c
 *
 *  Created on: Oct 19, 2017
 *      Author: ediaz
 */

// TODO ACA HABRIA QUE AGREGAR LAS FUNCIONES mymalloc, myfree y mymalloc

#include "memoryFunctions.h"

/*
 * post: la funcion invocante debe liberar la memoria
 * 		 del viejo ptr.
 */
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

	/*
	 * La responsabilidad de liberar ptr
	 * queda para la funcion invocante.
	 */
	//free(ptr);
	//ptr = NULL;

	return ptrNew;
}
