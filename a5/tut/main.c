#include <stdio.h>

extern int peck;
int hootini(int i);

void main(){

	int hello = peck + 2;

	printf("%x\n", hootini(hello));
}
