/*
*	Assignment 6
*	
*	Lecture Section: L01
*	Prof. Leonard Manzara
*
*	Evan Loughlin
*	UCID: 00503393
*	Date: 2017-04-07
*
*	a6.asm:
*	A ARMv8 assembly language program which computes the sine and cosine of an angle given in degrees.
*	To calculate the sine and cosine, a series expansion is used in the following form:
*
*	sin(x) = x - (x^3/3!) + (x^5/5!) - (x^7/7!) + ...
*
*	cos(x) = 1 - (x^2/2!) + (x^4/4!) - (x^6/6!) + ...
*
*	The program only allows angles between 0 and 90 degrees, and uses double-precision floating point numbers.
*
*	The program accepts its input via a file whose name is specified at the command line. 
*
*	Reference material found here: www.edwinckc.com/cpsc355 
*
*/
// ================================================= GLOBAL VARIABLES ========================================= //

			.data							// Begin "data" section.
pi_over_2:		.double	0r1.57079632679489661923			// Pi/2 global variable.i
float_90:		.double 0r90.0						// Float constant 90.0 for evaluating rads from degs.
float_0:		.double 0r0.0						// Float constant 0.0.
deg_upper:		.double	0r90.0						// Upper bound for degree allowance.
deg_lower:		.double 0r0.0						// Lower bound for degree allowance.
convergence_limit:	.double	0r1.0e-10					// Limit for when to stop Taylor series.

// ================================================= EQUATES =================================================== //
			.text
			.balign 4	

			buf_size = 8						// Create buffer for reading 8-byte inputs.
			alloc = -(16 + buf_size)&-16				// Memory allocation
			dealloc = -alloc					// De-allocation amount
			buf_s = 16						// Location of buffer in memory.

i_r			.req w19						// Generic counter i.
argc_r			.req w20						// The total number of arguments input at command line.
argv_r			.req x21						// Arg-values, the base address of array of pointers.
fd_r			.req w22						// File Descriptor register.
buf_base_r		.req x23						// Base register of buffer
nread_r			.req x24						// Base address of bytes read from input file.
			
// ================================================= PRINT FUNCTIONS =========================================== //

print_1:		.string "Opening file: %s\n"				// String output.
print_2:		.string "Input: %.2f degrees.\n"			// Output of number.
print_3:		.string "End of file reached.\n"			// Print "end of file reached".
print_cos:		.string "      Cosine of %f is %.10f.\n"		// Print statement for cosine.
print_sin:		.string "      Sine of %f is %.10f.\n"			// Print statement for sine.

print_err1:		.string "Error: incorrect number of arguments. Usage: ./a6 <filename.bin>\n"
										// Error message for incorrect input.
print_err2:		.string "Error: Filename %s not found.\n"		// Error message for file not found.
print_err3:		.string "Input %f out of range.\n"			// Error message for if degrees are not between 0 and 90.


// ================================================== SUBROUTINES =============================================== //


// ------------------------------------------------ COSINE --------------------------------------------------------//
		
cos:			stp 	x29, x30, [sp, -16]!				// Memory allocation for cosine subroutine.
			mov 	x29, sp

			
			// Set up the temporary registers with all required values.

			fmov	d9, d0						// Move input d0 into temporary register d9

			adrp	x10, convergence_limit				// Get address pointer for convergence limit
			add	x10, x10, :lo12:convergence_limit
			ldr	d10, [x10]					// Load value of convergence limit into d10			

			adrp	x11, pi_over_2					// Get address pointer for pi/2 constant
			add	x11, x11, :lo12:pi_over_2
			ldr	d11, [x11]					// Load value of pi/2 into d11

			adrp	x12, float_90					// Get address pointer for the float constant 90
			add	x12, x12, :lo12:float_90			
			ldr	d12, [x12]					// Load float value of 90 into d12			

			fdiv	d11, d11, d12					// d11 = pi / 2 / 90 = pi / 180

			fmul	d9, d9, d11					// Convert degrees to radians ( deg * pi/180 )	

			mov	w11, 1						// Term number. (Increases by 1 each iteration)
			mov	w12, 0						// Power term n (x^n / n!). (Increases by 2 each iteration)

			fmov	d14, 1.0					// d14 = factorial counter. Initialize it to 1.0

			adrp	x15, float_0					// Initialize d15 to 0.0
			add	x15, x15, :lo12:float_0
			ldr	d15, [x15]			

			// Begin the loop to calculate cosine.	
cos_loop:
			adrp	x13, float_0					// Reset d13 to zero (current term's value)
			add	x13, x13, :lo12:float_0
			ldr	d13, [x13]
		
			// Check if current term is the first term.
			
			cmp	w11, 1						// Check if this is the first term (w11 = 1)
			b.gt	cos_next1					// If it is, set first term value = 1. Otherwise branch.
			
			fmov	d13, 1.0					// Set first term to 1.0
			b	cos_continue					// Continue - increment values and move to next term.
		
cos_next1:		
				



			// Check whether to add or subtract current term.


			// Add current term to ongoing sum.

cos_continue:		fadd	d15, d15, d13					// Add current term to ongoing sum
			add	w11, w11, 1					// Increment term number by 1
			add	w12, w12, 2					// Increment n by 2
			b	cos_loop					// Loop back to top.	


cos_end:		fmov	d0, d15						// Move return value cos(input) into d0.
			ldp 	x29, x30, [sp], 16				// De-allocate memory from stack.
			ret							// Return to caller.


// ----------------------------------------------- SINE -------------------------------------------------------//

sine:			stp 	x29, x30, [sp, -16]!				// Allocate memory for sine subroutine.
			mov 	x29, sp


sin_end:		ldp 	x29, x30, [sp], 16				// De-allocate memory from stack
			ret							// Return to caller.

// ================================================= MAIN =========================================================//

			.global main

main:			stp	x29, x30, [sp, alloc]!				// Allocate memory for main.
			mov	x29, sp

			mov	argc_r,	w0
			mov	argv_r,	x1

			// Check number of arguments input. Should equal 2 to work.
			cmp	argc_r, 2					// Compare number of arguments.
			b.eq	next_1						// If equal to 2, continue.

			adrp	x0, print_err1					// Otherwise, print error message.
			add	x0, x0, :lo12:print_err1
			bl	printf
			b	end						// And branch to end.

			
			// Print out "reading input from file". 
next_1:			adrp	x0, print_1					// Set up print_1 argument.		
			add	x0, x0, :lo12:print_1				
			ldr	x1, [argv_r, 8]					// Load input string into x1.
			bl	printf						// Branch link to printf.
	
			mov	w0, -100					// Reading input from file.
			ldr	x1, [argv_r, 8]					// Place input string into x1
			mov	w2, 0						// 3rd Argument (read-only)
			mov	w3, 0						// 4th Argument (not used)
			mov	x8, 56						// Openat I/O request
			svc	0						// Call system function
			mov	fd_r, w0					// Move result into file descriptor.

			// Do error checking for openat()
			cmp	fd_r, 0						// Error check: branch over.
			b.ge	next_2						// If fd_r > 0, open successful.

			adrp	x0, print_err2					// Otherwise, set up error message "file not found".
			add	x0, x0, :lo12:print_err2
			ldr	x1, [argv_r, 8]					// Move input string into x1.
			bl	printf						// Branch link to printf.
			b	end						// Branch to end.

			// If input string has been successfully opened:
next_2:		
			add	buf_base_r, x29, buf_s				// Set memory base address of buffer. (FP + 16)

open_ok:		mov	w0, fd_r					// 1st Argument (file descriptor)
			mov	x1, buf_base_r					// 2nd Argument (buffer)
			mov	w2, buf_size					// 3rd Argument (Size of buffer = 8 bytes)
			mov	x8, 63						// Read I/O request
			svc	0						// Call system function
			mov	nread_r, x0					// Record the address of bytes actually read.

			cmp	nread_r, buf_size				// Do error checking for read()
			b.ne	exit						// If read was not 8 bytes, then branch to end.

			// Print out the value of the input.
			
			adrp	x0, print_2					// Set up print "Value of input = ___ degrees."
			add	x0, x0, :lo12:print_2				 
			ldr	d0, [buf_base_r]				// Load the read input value into d0.
			bl	printf						// Branch link to print() function.

			b	open_ok						// Read the next input.
			
exit:			adrp	x0, print_3					// Set up print_3 statement: Reached end of file.
			add	x0, x0, :lo12:print_3				// Add low 12 bits
			bl	printf						// Branch to print()

			// Close the binary file.
			mov	w0, fd_r					// 1st argument (file descriptor)
			mov	x8, 57						// Close I/O request
			svc	0						// Call system function.

end:			ldp	x29, x30, [sp], dealloc				// De-allocate memory from stack
			ret							// Return to caller
			

