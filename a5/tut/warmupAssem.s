
	.global peck
	.global hootini

	.data
peck:	.word 5
tini:	.byte 0xde
hoot:	.byte 0xad

	.text
	.balign 4

hootini: stp x29, x30, [sp, -16]!
	mov x29, sp

	adrp x9, peck
	add x9, x9, :lo12:peck		//load peck
	ldr w1, [x9]

	mul w0, w0, w1			//i = i * peck
	lsl w0, w0, 8			//i = i << 8

	adrp x9, tini
	add x9, x9, :lo12:tini		//load tini
	ldrb w1, [x9]

	add w0, w0, w1			//i = i + tini

	lsl w0, w0, 8			//i = i << 8
	
	adrp x9, hoot
	add x9, x9, :lo12:hoot		//load hoot
	ldrb w1, [x9]

	add w0, w0, w1			//i = i + hoot

	ldp x29, x30, [sp], 16
	ret
