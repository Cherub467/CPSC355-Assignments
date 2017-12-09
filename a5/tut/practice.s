/*
int x = 2, y = 4;
int buff[4];

//cubes a number then adds a constant x
int cube(int c){
	return (c*c*c) + x;
}

void main(){
	for(int i = 0; i < y; i++){
		buff[i] = cube(x+i);
	}
}

*/


	.data
x_m:	.word 2
y_m:	.word 4

	.bss	
buff_m:	.skip 4*4

	i_s = -4

	.text
	.balign 4
	.global main

main:	stp x29, x30, [sp, -16]!
	mov x29, sp
	
	add sp, sp, -4 & -16		//allocate space for i
	str wzr, [x29, i_s]

	b test
top:
	adrp x19, x_m
	add x19, x19, :lo12:x_m		//load x
	ldr w0, [x19]
	
	ldr w19, [x29, i_s]		//load i
	add w0, w0, w19			//arg1 = x + i

	bl cube				//return in w0

	adrp x19, buff_m		//calculate base address of buff
	add x19, x19, :lo12:buff_m

	ldr w20, [x29, i_s]		//load i

	str w0, [x19, w20, SXTW 2] 	//buff[i] = cube(x+i)		

	ldr w19, [x29, i_s]
	add w19, w19, 1
	str w19, [x29, i_s]		//i++

test:	adrp x19, y_m			//get pointer to y
	add x19, x19, :lo12:y_m
	ldr w20, [x19]

	ldr w21, [x29, i_s]		//load i
	cmp w21, w20
	b.lt top

end:	add sp, sp, 16			//deallocate space for i

	ldp x29, x30, [sp], 16
	ret

cube:	stp x29, x30, [sp, -16]!
	mov x29, sp

	mul w9, w0, w0
	mul w9, w0, w9

	adrp x10, x_m
	add x10, x10, :lo12:x_m		//load x
	ldr w1, [x10]

	add w0, w9, w1	

	ldp x29, x30, [sp], 16
	ret
