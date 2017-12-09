/*
*	Assignment 5
*	
*	Lecture Section: L01
*	Prof. Leonard Manzara
*
*	Evan Loughlin
*	UCID: 00503393
*	Date: 2017-03-29
*
*	a5a.asm:
*	A program which contains the following subroutines: push(), pop(), clear(), getop(), getch(), and ungetch(). 
*       The file provides a data struction of a stack, allowing a main function to push and pop from it, and also
*       get chars from it.
*       This file is utilized by the main() function (C program), which uses these subroutines to accept keyboard 
*       input for calculator commands, in the "reverse polish" notation.
*	
*	
*	Reference material used for this assignment: edwinckc.com/CPSC355/
*
*/

// ================================================= EQUATES =================================================== //

			MAXVAL = 100						// Equate for Maxval
			MAXOP = 20						// Equate for MaxOp
			NUMBER = 0						// Equate for Number
			TOOBIG = 9						// Equate for "TooBig"
			BUFSIZE = 100						// Equate for "BufSize"

// ================================================= GLOBAL VARIABLES ========================================== //

// Allocate memory for the .bss variables and arrays.
			.bss							// Begin the ".bss" section, to initialize arrays with each value being zero.

val_m:			.skip 	4*MAXVAL					// Create an array for val.
buf_m:			.skip 	1*BUFSIZE					// Create an array for buf (array of chars).
sp_m:			.skip 	4						// Create a global variable (sp = pseudo stack pointer)
bufp_m:			.skip 	4						// Create a buffer pointer variable (int).

			.text							// Return to the .text section.

// Globalize all variables:

			.global sp_m						// Variable for the "SP" (local stack pointer)	
			.global val_m						// Variable for "var" (array of values)
			.global bufp_m						// Variable for "bufp" (buffer pointer) 
			.global buf_m						// Variable for "buf" (array)

// Globalize all subroutines:

			.global push						// Make Function "push" visible globally
			.global pop						// Make function "pop" visible globally
			.global clear						// Make function "clear" visible globally
			.global getop						// Make function "getop" visible globally
		//	.global getch						// Make function "getch" visible globally
		//	.global ungetch						// Make function "ungetch" visible globally


// ================================================= PRINT FUNCTIONS =========================================== //

print_1:		.string "error: stack full\n"				// Print statement for when stack is full.
print_2:		.string "error: stack empty\n"				// Print statement for when stack is empty.

			.balign 4						// quad-word align instructions

// ================================================== SUBROUTINES =============================================== //


// ------------------------------------------------ PUSH --------------------------------------------------------//
		
push:			stp x29, x30, [sp, -16]!
			mov x29, sp

			mov 	w9, w0						// Set w9 register to hold input int "f".
			mov 	w10, MAXVAL					// Store MAXVAL (100) into w10
			
			adrp	 x11, sp_m					// Set w11 register to hold global variable int "sp".
			add 	x11, x11, :lo12:sp_m
			ldr 	w11, [x11]

			adrp 	x12, val_m					// Set x12 to hold the array val_m
			add 	x12, x12, :lo12:val_m			
			ldr 	w12, [x12]
		
			cmp 	w11, w10					// If sp_m < MAXVAL
			b.ge	 push_next					// Skip past this if sp_m >= MAXVAL

			str 	w9, [x12, w11, SXTW 2]				// Store the value of "f" into val_m offset by sp_m
			add 	w11, w11, 1					// sp++
			str	 w11, [x11]					// Store new SP back in memory.
			b 	push_end					// Branch to end of push function (skip past print)

push_next:		adrp 	x9, print_1					// Print "error: stack full"
			add 	x9, x9, :lo12:print_1
			bl 	printf						

			bl 	clear						// Branch link to clear subroutine.
			mov 	w0, 0						// Set w0 (return) to 0	

push_end:		ldp 	x29, x30, [sp], 16				// De-allocate memory from stack.
			ret							// Return to caller.


// ----------------------------------------------- POP -------------------------------------------------------//

pop:			stp 	x29, x30, [sp, -16]!				// Allocate memory for pop subroutine.
			mov 	x29, sp

			adrp 	x9, sp_m					// Load pointer to sp_m from memory
			add 	x9, x9, :lo12:sp_m				// Load low 12 bits
			ldr 	w9, [x9]					// Load value of sp_m from pointer address

			cmp 	w9, 0						// If sp > 0
			b.gt 	pop_next					// Branch to pop_next (complete pop)

			adrp 	x9, print_2					// Print error "stack is empty"
			add 	x9, x9, :lo12:print_2				
			bl 	printf

			bl 	clear						// Branch link to clear subroutine
			mov 	w0, 0						// Set return w0 = 0

			b 	pop_end

pop_next:
			sub 	w9, w9, 1					// SP--
			
			adrp 	x10, val_m					// Load pointer to val_m array from memory
			add 	x10, x10, :lo12:val_m				// Load low 12 bits
			ldr 	w10, [x10, w9, SXTW 2]				// Load value of val_m

			mov 	w0, w10						// Set w0 = val[--sp] to be returned

pop_end:		ldp 	x29, x30, [sp], 16				// De-allocate memory from stack
			ret							// Return to caller.

// ----------------------------------------------- CLEAR ------------------------------------------------------ //

clear:			stp 	x29, x30, [sp, -16]!				// Allocate memory for the clear subroutine.
			mov 	x29, sp

			adrp 	x9, sp_m					// Set x9 to hold the address to the global variable sp_m
			add 	x9, x9, :lo12:sp_m				// Add low 12 bits
			ldr	w9, [x9]					// Get value from pointer

			mov 	w9, 0						// Set register w9 to zero (sp_m = 0)
			str	w9, [x9]					// Store sp_m = 0 into memory.

			ldp 	x29, x30, [sp], 16				// De-allocate memory from stack
			ret							// Return to caller.


// ---------------------------------------------- GETOP ---------------------------------------------------------//


getop:			stp 	x29, x30, [sp, -16]!				// Allocate memory for the "getop" subroutine
			mov 	x29, sp						

			



			ldp 	x29, x30, [sp], 16					
			ret				

// ---------------------------------------------- GETCH -------------------------------------------------------- //










// --------------------------------------------- UNGETCH ------------------------------------------------------- //


// ================================================== ====================================================== //
