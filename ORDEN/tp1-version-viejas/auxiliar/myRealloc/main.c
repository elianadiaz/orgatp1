#include <stdio.h>

#include <stdlib.h>

#include <sys/types.h>
#include "mymalloc.h"
#include "myRealloc.h"

/*
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
*/

int main(int argc, char * const argv[])
{
	size_t i;
	size_t j;
	char *p;
	char *p2;

	for (i = 1; i; ++i) {
		fprintf(stdout, "malloc(%ld) ...", (long) i);
		fflush(stdout);
		p = (char *) mymalloc(i);

		fprintf(stdout, " %p.", p);

		printf(" Writing ...");
		fflush(stdout);
		for (j = 0; j < i; ++j)
			p[j] = 0xff;
		printf(" Ok.");
		//begin myRealloc
		printf("Writing myRealloc...");
		p2 = (char *) myRealloc(p,4*sizeof(p),sizeof(p));
		fprintf(stdout, " %p.", p2);

		printf("end writing myRealloc...");
		//end myRealloc

		printf(" Freeing memory ...");
		fflush(stdout);

		myfree(p2);

		printf(" Ok.\n");
		fflush(stdout);
	}
	return 0;
}
