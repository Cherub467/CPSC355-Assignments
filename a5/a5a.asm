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
print_3:		.string "ungetch: too many characters\n"		// Print statement for when ungetch is called too many times.

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


getop:			
			// Develop a struct for this function

			i_size = 4						// Size of i = 4 bytes
			c_size = 4						// Size of c = 4 bytes
			s_adr_size = 8						// Size of allocation for address of s
			lim_size = 4						// Size of lim = 4 bytes
			
			i_m = 16						// Location of base of i
			c_m = 20						// Location of base of c
			s_adr_m = 24						// Location of base of address for s
			lim_m = 32						// Location of base of lim

			alloc = -(16 + i_size + c_size + s_adr_size + lim_size)&-16 	// Allocation for getop
			dealloc = -alloc					// Deallocation

			stp 	x29, x30, [sp, alloc]!				// Allocate memory for the "getop" subroutine
			mov 	x29, sp					

			add	x12, x29, i_m					// Move base address of i_m into register
			add	x13, x29, c_m					// Move base address of c_m into register
			add	x14, x29, s_adr_m				// Move base address of base address of s into register
			add	x15, x29, lim_m					// Move base address of lim into register

			mov 	x9, x0						// Pass address at base of s (*s) into x9
			str	x9, [x14]					// Store the base address of s into memory for later 

			mov	w10, w1						// Pass int lim into w10
			str	w10, [x15]					// Store the lim into memory for later

getop_loop:		bl	getch						// Branch link to getch
			mov	w11, w0						// Move result of w0 into w11
			str	w11, [x13]					// Move value of c into memory.
						
			cmp	w11, ' '					// Compare if w11 is equal to a ' '
			b.eq	getop_loop					// Branch to top of loop and go again.

			cmp	w11, '\t'					// Compare if w11 is equal to '\t'
			b.eq	getop_loop					// Branch to top of loop and go again.
			
			cmp	w11, '\n'					// Compare if w11 is equal to '\n'
			b.eq	getop_loop					// Branch to top of loop and go again.
			




			cmp	w11, 0						// If c < 0
			b.lt	getop_next1					// Skip forward

			cmp	w11, 9						// If c > 9
			b.gt	getop_next1					// Skip forward

			mov	w0, w11						// Return c	
			b	getop_end 					// branch to the next item


getop_next1:		add	x14, x29, s_adr_m				// Store the address of the base address of s into register
			ldr	x9, [x14]					// Move the address into x9
			str	w11, [x9]					// Move value of c into s[0]

			add	x12, x29, i_m					// Move the base address of i into x12
			mov	w13, 1						// Set w13 = 1
			str	w13, [x12]					// Store i = 1 in memory

getop_loop2_test:	

			bl	getchar						// Branch to getchar
			mov	w9, w0						// Give w0 to w9
			add	x13, x29, c_m					// Get base address of c
			str	w9, [x13]					// Store c back in memory
	
			cmp	w9, 9
			b.gt	getop_loop2_skip				// If c is greater than 0, skip for loop
			
						
			cmp	w9, 0						
			b.lt	getop_loop2_skip				// If c is less than 0, skip for loop


										// Body of for loop
getop_next2:		add	x15, x29, lim_m					// Put address of lim into x15
			ldr	w9, [x29]					// Put value of lim into w9			
			
			add	x12, x29, i_m					// Put address of i into x12
			ldr	w10, [x12]					// Put value of i into w10

			add	x13, x29, c_m					// move base address of c into x13
			ldr	w11, [x13]					// Get current value of c into w11

			cmp	w10, w9						// If i < lim, do code
			b.ge	getop_next3					// If i >= lim, skip over

			add	x14, x29, s_adr_m				// Put base address of address of s into x14
			ldr	x9, [x14]					// Put address of s into x9	
			str	w11, [x9, w10, SXTW 2]				// Store s[i] = c into memory			

getop_next3:	
	
			add	x12, x29, i_m					// Put base address of i into x29
			ldr	w10, [x12]					// Load value of i and put it into w10
			add	w10, w10, 1					// i++
			str	w10, [x12]					// Put value of new i into memory. 

			b	getop_loop2_test				// Return to top of for loop

getop_loop2_skip:	

			add	x15, x29, lim_m					// Put address of lim into x15
			ldr	w9, [x15]					// Move value of lim into w9
			
			add	x12, x29, i_m					// Move address of i into x12
			ldr	w10, [x12]					// Move value of i into w10

			cmp	w10, w9						// Compare i with lim
			b.ge	getop_next4					// If i >= lim, skip ahead

			add	x13, x29, c_m					// Move address of c into x13
			ldr	w11, [x13]					// Load value of c into w11
			mov	w0, w11						// Move w0 = c (prepare for ungetch)

			bl	ungetch						// Branch to ungetch
			
			add	x12, x29, i_m					// Move address of i into x12
			ldr	w10, [x12]					// Load value of i into w10

			mov	w12, '\0'					// Move value of '\0' into w12

			add	x14, x29, s_adr_m				// Store the address of the base address of s into register
			ldr	x9, [x14]					// Move the base address of s into x9
			str	w12, [x9, w10, SXTW 2]				// Move the value of '\0' into s[i]

			mov 	w0, NUMBER					// Return NUMBER
			b	getop_end					

getop_next4:			
getop_loop3:		add	x13, x29, c_m					// Move address of c into x13
			ldr	w11, [x13]					// Load value of c into w11 from memory
			
			cmp	w11, '\0'					// Compare w11 with '\0'
			b.eq	getop_loop3_skip				// If equal to \0, skip this section
		
			
			cmp	w11, -1						// Compare c with '-1' (End Of File)
			b.eq	getop_loop3_skip				// If equal to '-1', skip this section

			bl	getchar						// Branch link to getchar
			mov	w11, w0						// Move result of getchar into w11
			add	x13, x29, c_m					// Move address of c into x13
			str	w11, [x13]					// Store new value of w11 into x13
			
			b	getop_loop3					// Branch to top of while statement



getop_loop3_skip:	add	x14, x29, s_adr_m				// Move address of base address of s into register
			ldr	x9, [x14]					// Move address of s into register x9
			
			add	x15, x29, lim_m					// Move address of lim into x15
			ldr	w10, [x15]					// Load value of lim into w10
			sub	w10, w10, 1					// Subtract one from lim

			mov	w11, '\0'					// Move '\0' value into w11
			
			str	w11, [x9, w10, SXTW 2]				// Store s[lim-1] 

			mov	w0, TOOBIG					// Return TOOBIG (value too big)
			

getop_end:		ldp 	x29, x30, [sp], dealloc					
			ret				




// ---------------------------------------------- GETCH -------------------------------------------------------- //

getch:			stp 	x29, x30, [sp, -16]!				// Allocate memory for the "getch" subroutine
			mov 	x29, sp						

			
			adrp 	x9, bufp_m					// Load buff pointer 
			add	x9, x9, :lo12:bufp_m				// Load low 12 digits
			ldr	w11, [x9]					// Get value of buff pointer into w11

			adrp	x10, buf_m					// Get base address of buffer array
			add	x10, x10, :lo12:buf_m				// Load low 12 digits
			
			cmp	w11, 0						// If bufp <= 0,
			b.le	getch_next					// Go to next (getchar())
										// Otherwise, continue here.

			sub	w11, w11, 1					// buffpointer--
			ldr	w0, [x10, w11, SXTW 2]				// Output w0 = buf[buffpointer * 4]
			
			b	getch_done					// Branch to finish.

getch_next:					
			bl	getchar						// Branch-link to getchar


getch_done:		ldp 	x29, x30, [sp], 16				// De-allocate memory from stack	
			ret							

// --------------------------------------------- UNGETCH ------------------------------------------------------- //

ungetch:		stp 	x29, x30, [sp, -16]!				// Allocate memory for the "ungetch" subroutine
			mov 	x29, sp						

				
			adrp	x9, bufp_m					// Load buff pointer
			add	x9, x9, :lo12:bufp_m				// Load low 12 digits	
			ldr	w10, [x9]					// Load value of buff pointer into w10

			cmp	w10, BUFSIZE					// If w10 <= BUFSIZE
			b.le	ungetch_next					// Then proceed with code
			
			adrp	x11, print_3					// Else, print error messages.
			add	x11, x11, :lo12:print_3
			bl	printf
	
			b	ungetch_done					// Branch to end of function.

ungetch_next:		adrp	x12, buf_m					// Get base address of buff
			add	x12, x12, :lo12:buf_m				// Load low 12 bits
			
			str	w0, [x12, w10, SXTW 2]				// Store buf[bufp] in memory

			add	w10, w10, 1					// Buff_pointer++
			str	w10, [x9]					// Store new buff pointer back in memory
	
ungetch_done:		ldp 	x29, x30, [sp], 16					
			ret			

// ================================================== ====================================================== //
