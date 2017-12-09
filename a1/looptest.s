/*  CPSC 355 - Computing Machinery 1
	Assignment 1: Part A
	
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



fmt:	.string "I pooped my pants %d times. \n"

	.balign 4
	.global main


main:	stp x29, x30, [sp, -16]!
	mov x29, sp

	mov x19, 0 					//this is the loop counter


test:	cmp x19, 10					//compare loop counter and 10

	b.ge done					//If loop counter > 10, exit loop and branch to "done"


//Start of code inside the loop

	adrp x0, fmt					//set the 1st argument of printf
	add x0, x0, :lo12:fmt
	add x1, x19, 1					//Set the 2nd argument of printf

	bl printf					//Call the printf() function

	add x19, x19, 1					//Increment the loop counter by 1

	b test						//Loop iteration has ended. Goto test to see if we should execute loop again.

done:	mov w0, 0

	ldp x29, x30, [sp], 16
	ret

		





