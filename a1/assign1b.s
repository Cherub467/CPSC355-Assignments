/*  CPSC 355 - Computing Machinery 1
	Assignment 1: Part B
	
	Lecture Section: L01
	Prof. Leonard Manzara

	Evan Loughlin
	UCID: 00503393
	Date: 2016-01-29


	Overview: This program is a sample ARMv8 A64 assembly language program that finds the maximum
	of y = -3x^3 - 24x^2 + 13x + 31 in the range -8 <= x <= 5, by stepping through the range
	one by one in a loop and testing.

	Part A) The program is written without macros, and only the mul, add, and mov instructions are
	used to do calculations.

	Part B) Same as part A, except that the loop test is put at the bottom of the loop (although it is 
	still a pre-test loop), and the madd instruction is used. Additionally, macros are added to make
	the program more readable. (Heavily used macros are provided for heavily used registers.)
*/



values:		.string "For X =  %d, Y = %d.\n     The current maximum of Y = %d.\n"		//The print label for values of x, y, and z to be completed each interval. 
		.balign 4									//This aligns instructions by 4 bits.


		.global main 									//Makes "main" visible to the OS


main:		stp x29, x30, [sp, -16]! 							//Save FP and LR to stack, allocating 16 bytes, pre-increment SP
		mov x29, sp 									//Update frame pointer (FP) to current stack pointer (SP)

		
										//Define x19 as the x value, and set it to register x19
										//Define x20 as the y value, and set it to register x20
										//Define x21 as the y maximum value, and set it to register x21
										//Define a temporary variable used to hold temporary values.

										//Define a coefficient for the 1st term in the polynomial
		mov x23, -3
		
										//Define a coefficient for the 2nd term in the polynomial
		mov x24, -24
		
										//Define a coefficient for the 3rd term in the polynomial
		mov x25, 13

										//Define a coefficient for the 4th term in the polynomial
		mov x26, 31
		
										//Loop x28. Used to initialize the first Y_max.	

	
		mov x19, -8									//Set X to a value of -8.

		mov x28, 0									//Set loop x28 to 0.


		b test										//Branch to test at bottom of loop.

												// <--- Start of code inside the loop.
top:		mov x20, 0									//Re-initialize Y to 0 for the beginning of each iteration.
		mov x22, 0									//Re-set x22 to 0

		add x20, x20, x26								//Add 31 to Y

		madd x20, x25, x19, x20							//x20 = x20 + (x19 * x25) (Y = 31 + 13X)
				

		mul x22, x24, x19							//x22 = x24 * x19 (Temp = -24X)
		madd x20, x22, x19, x20							//x20 = x22 * x19 + x22   (Y = 31 + 13X - 24X^2)

		mov x22, 0									//Re-set x22 to 0
		mul x22, x23, x19							// x22 = x23 * X ( = -3X)
		mul x22, x22, x19								// x22 = x22 * X ( = -3X^2)
		madd x20, x22, x19, x20							// x20 = x22 * X + x20   (Y = 31 + 13X - 24X^3 - 3X^3)

		cmp x28, 0									//If the loop x28 is 0, then the Y_max should be set to the current Y value.
		b.eq updateYmax
		
		cmp x20, x21									//Compares Y and Y_max. If Y is greater than current Y_max, then branch to update Y max.
		b.gt updateYmax									// If Y > Y-Max, set Y-Max = Y 




loopend:
		adrp x0, values									// Set the 1st argument of printf
		add x0, x0, :lo12:values							// Add the low 12 bits to x0
		mov x1, x19									// Place the value of X into the x1 register for the printf argument.
		mov x2, x20									// Place the value of Y into the x2 register for the printf argument.
		mov x3, x21									// Place the value of Y-maximum into the x3 register for the printf argument.

		bl printf									//Calls the printf function.
		add x19, x19, 1									//Increments X by 1.
		add x28, x28, 1								//Increments loop x28 by 1.
		b test										// <--- End of code inside the loop. Return to test if loop should go again.


updateYmax:	mov x21, x20									//Places the value of Y into Y_max
		b loopend									//Returns to the end of the loop.
	
test:		cmp x19, 5									//Compare X variable with the immediate 5
		b.le top									//If X < 5, branch to "top"

done:		mov x0, 0									// <--- Code upon completion. (When X > 5) 
												// Return the x0 register to 0.
		ldp x29, x30, [sp], 16								// Restore FP and LR from stack, post-increment SP

		ret										// Return to caller
