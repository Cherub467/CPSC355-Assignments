/*

int peck = 5;
char tini = 0xde;
char hoot = 0xad;

int hootini(int i){
	i = i * peck;
	i = i << 8;
	i = i + tini;
	i = i << 8;
	i = i + hoot;

	return i;
}

void main(){

	int hello = peck + 2;

	printf("%x\n", hootini(hello));
}
*/