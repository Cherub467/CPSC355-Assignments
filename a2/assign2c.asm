/*  CPSC 355 - Computing Machinery 1
	Assignment 2: Part C
	
	Lecture Section: L01
	Prof. Leonard Manzara

	Evan Loughlin
	UCID: 00503393
	Date: 2017-02-09


	Overview: This program is a sample ARMv8 A64 assembly language program that has been developed to practice bitwise logical and shift operations,
	use of branching and condition code tests, and understanding of hexidecimal and binary numbers.

	The original code was written in the C language, and was translated into the ARMv8 A64 assembly language. Refer to CPSC 355 Assignment 2 sheet for original C code.

	Part A) "assign2a.asm": Direct translation of C code.
	Part B) "assign2b.asm": Same as part A, except 522133279 is used for the multiplicand, and 200 for the multiplier. 
	Part C) "assign2c.asm": Same as part A, except -252645136 is used for the multiplicand, and -256 for the multiplier.

*/


values_1:	.string "multiplier = 0x%08x (%d)  multiplicand = 0x%08x (%d)\n\n"		// The print label for values "multiplier", and "multiplicand", displaying 8 digits of hex, and in decimal.
		.balign 4									// Aligns instructions by 4 bits.

values_2:	.string "product = 0x%08x multiplier = 0x%08x\n"				// The 2nd print label for the values "product" and "multiplier", following some bitwise operations.  
		.balign 4									// Aligns instructions by 4 bits.

values_3:	.string "64-bit result = 0x%016lx (%ld)\n"					// The 3rd print label, for the 64-bit of the 32-bit "product" and "multiplier" side-by-side. 
		.balign 4									// Aligns instructions by 4 bits.

		.global main									// Makes "main" visible to the OS

main:		stp x29, x30, [sp, -16]								// Save FP and LR to stack, allocating 16 bytes, pre-increment SP
		mov x29, sp									// Update frame pointer (FP) to current stack pointer (SP)

		
												// ** Definition of all variables ** 
		define(multiplier_r, w19)							// Define "multiplier", and set it to register w19. (32-bit register)
		define(multiplicand_r, w20)							// Define "multiplicand", and set it to register w20. (32-bit register)
		define(product_r, w21)								// Define "product", and set it to register w21. (32-bit register)
		define(i_r, w22)								// Define "i", and set it to register w22. (32-bit register)
		define(negative_r, w23)								// Define "negative", and set it to register w23. (32-bit register)
		define(temp1_r, x24)								// Define "temp1", and set it to register x24. (64-bit register)
		define(temp2_r, x25)								// Define "temp2", and set it to register x25. (64-bit register)
		define(result_r, x26)								// Define "result" and set it to register x26 (64-bit register)

												// ** Initialization of variables **
		movk multiplicand_r, 0xf0f0, lsl 0 						// Initialize "multiplicand" variable with the value -252645136. Place the first half of f0f0f0ed in.
		movk multiplicand_r, 0xf0ed, lsl 16 						// Place remainder of "0xf0f0f0ed" in.
		mov multiplier_r, -256								// Initialize "multiplier" variable with the value 200.
		mov product_r, 0								// Initialize "product" variable with the value 0.


												// ** First print statement **
		adrp x0, values_1								// Set the 1st argument of printf
		add x0, x0, :lo12:values_1							// Add the low 12 bits to x0
		mov w1, multiplier_r								// Place the value of "multiplier" into the x1 register for the printf argument.
		mov w2, multiplier_r								// Place the value of "multiplier" into the x2 register for the printf argument.
		mov w3, multiplicand_r 								// Place the value of "multiplicand" into the x3 register for the printf argument.
		mov w4, multiplicand_r								// Place the value of "multiplicand" into the x4 register for the printf argument.

		bl printf									// Calls the printf function.

		
		 										// ** Determine if multiplier is negative. **
		cmp multiplier_r, wzr								// Compare multiplier to zero register, to determine if multiplier is positive or negative.
		b.ge else									// Branch to "else" if multiplier is greater than or equal to xzr
		
		mov negative_r, 1								// Store a "true" (1) into "negative" register, if multiplier is less than zero.
		b next_1									// Branch to next, skipping over the "else" statement

else:		mov negative_r, 0								// Store a "false" (0) into "negative" register, if multiplier is greater than or equal to zero.
		
next_1:												// Continue the code after the "if" statement.




												// ** Do repeated add and shift in the following loop. **	
		mov i_r, 0									// Set i = 0
		b test_1									// Branch to the test statement of the "for" loop. 

loop_1:		AND w27, multiplier_r, 0x1							// Completes an AND operation, placing the result into the W27 register
		cmp w27, 0									// Compare the result of the AND operation to zero
		b.eq next_2									// If the result of AND is equal to zero, this indicates that the IF was false.

		add product_r, product_r, multiplicand_r					// product = product + multiplicand

next_2:												// Jump here if the AND result (w27) was equal to zero	

		asr multiplier_r, multiplier_r, 1						// Arithmetic shift right the combined product and multiplier
				
		AND w27, product_r, 0x1								// Use AND operation on product_r and 0x1, and place result in w27
		cmp w27, 0									// Test to see if w27 is equal to zero or not
		b.eq next_3									// If equal to zero, then AND is false, and branch to next_3

		orr multiplier_r, multiplier_r, 0x80000000					// Complete an ORR operation and store result in multiplier.
		b next_4

next_3:		AND multiplier_r, multiplier_r, 0x7FFFFFFF					// ELSE (if w27 is 0), perform this operation.		

next_4:		ASR product_r, product_r, 1							// Arithmetic shift right by 1.

		add i_r, i_r, 1									// i++

test_1:		cmp i_r, 32									// Compare i to 32
		b.lt loop_1									// Branch to loop_1 if i_r < 32

		cmp negative_r, 0								// Is multiplier negative?
		b.eq next_5									// If negative = 0, then skip statement (false)

		sub product_r, product_r, multiplicand_r					// If multiplier is negative, then do product = product - mulitplicand 		

next_5:												// If multipland is positive, skip to here.


												// ** Second print statement **
		adrp x0, values_2								// Set the 1st argument of printf
		add x0, x0, :lo12:values_2							// Add the low 12 bits to x0
		mov w1, product_r								// Place the value of "product" into the w1 register for the printf argument.
		mov w2, multiplier_r								// Place the value of "multiplier" into the w2 register for the printf argument.
		bl printf									// Calls the printf function.



												// ** Combine product and multiplier together **
		sxtw temp1_r, product_r								// Move value of product_r into temp_r
		AND temp1_r, temp1_r, 0xFFFFFFFF						// Move result of AND of product_r and 0xFFFFFFFF into temp1 register
		lsl temp1_r, temp1_r, 32							// Shift values of temp1_r over left by 32 bits
		
		sxtw temp2_r, multiplier_r							// Place multiplier into temp2 register
		AND temp2_r, temp2_r, 0xFFFFFFFF						// Pad temp2

		add result_r, temp1_r, temp2_r							// result = temp1 + temp2


												// ** Final print statement **
		adrp x0, values_3								// Set the 1st argument of printf
		add x0, x0, :lo12:values_3							// Add the low 12 bits to x0
		mov x1, result_r								// Place the value of "result" into the x1 register for the printf argument.
		mov x2, result_r								// Place the value of "result" into the x2 register for the printf argument.
		bl printf									// Calls the printf function.


												
done:												// <--- Code upon completion. 
		mov x0, 0									// Return the x0 register to 0.
		ldp x29, x30, [sp], 16								// Restore FP and LR from stack, post-increment SP
		ret										// Return to caller


