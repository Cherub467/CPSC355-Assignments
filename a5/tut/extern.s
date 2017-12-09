/*
int i = 2, j = 12, k = 0;

int main(){
	k = i + j
	...
}
*/

	.data
i_m:	.word	2
j_m:	.word	12
k_m:	.word	0

	.text
	.balign 4
	.global main

main:	stp x29, x30, [sp, -16]!
	mov x29, sp

	adrp x19, i_m
	add x19, x19, :lo12:i_m
	ldr w20, [x19]			//w20 = i

	adrp x19, j_m
	add x19, x19, :lo12:j_m
	ldr w21, [x19]			//w21 = j

	add w22, w20, w21		//w22 = i + j

	adrp x19, k_m
	add x19, x19, :lo12:k_m
	str w22, [x19]			//k = w22

	ldp x29, x30, [sp], 16
	ret
