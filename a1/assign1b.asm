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

		
		define(x_r, x19)								//Define x_r as the x value, and set it to register x19
		define(y_r, x20)								//Define y_r as the y value, and set it to register x20
		define(ymax_r, x21)								//Define ymax_r as the y maximum value, and set it to register x21
		define(temp_r, x22)								//Define a temporary variable used to hold temporary values.

		define(coef1_r, x23)								//Define a coefficient for the 1st term in the polynomial
		mov coef1_r, -3
		
		define(coef2_r, x24)								//Define a coefficient for the 2nd term in the polynomial
		mov coef2_r, -24
		
		define(coef3_r, x25)								//Define a coefficient for the 3rd term in the polynomial
		mov coef3_r, 13

		define(coef4_r, x26)								//Define a coefficient for the 4th term in the polynomial
		mov coef4_r, 31
		
		define(counter, x28)								//Loop counter. Used to initialize the first Y_max.	

	
		mov x_r, -8									//Set X to a value of -8.

		mov counter, 0									//Set loop counter to 0.


		b test										//Branch to test at bottom of loop.

												// <--- Start of code inside the loop.
top:		mov y_r, 0									//Re-initialize Y to 0 for the beginning of each iteration.
		mov temp_r, 0									//Re-set temp_r to 0

		add y_r, y_r, coef4_r								//Add 31 to Y

		madd y_r, coef3_r, x_r, y_r							//y_r = y_r + (x_r * coef3_r) (Y = 31 + 13X)
				

		mul temp_r, coef2_r, x_r							//temp_r = coef2_r * x_r (Temp = -24X)
		madd y_r, temp_r, x_r, y_r							//y_r = temp_r * x_r + temp_r   (Y = 31 + 13X - 24X^2)

		mov temp_r, 0									//Re-set temp_r to 0
		mul temp_r, coef1_r, x_r							// temp_r = coef1_r * X ( = -3X)
		mul temp_r, temp_r, x_r								// temp_r = temp_r * X ( = -3X^2)
		madd y_r, temp_r, x_r, y_r							// y_r = temp_r * X + y_r   (Y = 31 + 13X - 24X^3 - 3X^3)

		cmp counter, 0									//If the loop counter is 0, then the Y_max should be set to the current Y value.
		b.eq updateYmax
		
		cmp y_r, ymax_r									//Compares Y and Y_max. If Y is greater than current Y_max, then branch to update Y max.
		b.gt updateYmax									// If Y > Y-Max, set Y-Max = Y 




loopend:
		adrp x0, values									// Set the 1st argument of printf
		add x0, x0, :lo12:values							// Add the low 12 bits to x0
		mov x1, x_r									// Place the value of X into the x1 register for the printf argument.
		mov x2, y_r									// Place the value of Y into the x2 register for the printf argument.
		mov x3, ymax_r									// Place the value of Y-maximum into the x3 register for the printf argument.

		bl printf									//Calls the printf function.
		add x_r, x_r, 1									//Increments X by 1.
		add counter, counter, 1								//Increments loop counter by 1.
		b test										// <--- End of code inside the loop. Return to test if loop should go again.


updateYmax:	mov ymax_r, y_r									//Places the value of Y into Y_max
		b loopend									//Returns to the end of the loop.
	
test:		cmp x_r, 5									//Compare X variable with the immediate 5
		b.le top									//If X < 5, branch to "top"

done:		mov x0, 0									// <--- Code upon completion. (When X > 5) 
												// Return the x0 register to 0.
		ldp x29, x30, [sp], 16								// Restore FP and LR from stack, post-increment SP

		ret										// Return to caller
