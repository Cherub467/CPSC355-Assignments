/*  CPSC 355 - Computing Machinery 1
	Assignment 3
	
	Lecture Section: L01
	Prof. Leonard Manzara

	Evan Loughlin
	UCID: 00503393
	Date: 2017-02-28

	assign3.asm: A sample ARMv8 program, which builds an array of size 50. It then initializes the array with each of the elements being random positive integers between 
	0 and 255. The array is then sorted using the selection sort, such that the array is ordered from smallest to largest. The program then prints the resulting array.
	This program is designed for the student to practice building arrays, sorting them, and utilizing the stack (allocating and de-allocating) in memory.	

	Reference material used for this assignment: edwinckc.com/CPSC355/69-assignment-3

*/


// ================================================================ PRINT FUNCTIONS ==================================================================================
												
print_1:	.string "Unsorted array:\n"					// The first print function, which produces the title "Unsorted array: "

print_2:	.string "Sorted array:\n"					// The second print function, which produces the title "Sorted array: "  

print_3:	.string "v[%d]: %d\n"						// The 3rd print label, for printing each line in the array. 

// =============================================================== /END PRINT FUNCTIONS ==============================================================================



// ============================================================= LOCAL VARIABLE MEMORY ALLOCATIONS ===================================================================


		index_size = 4							// Size of each element in the array = 4 bytes (word)
		array_size = 50							// Define "array size" as 50.
		ia_size = array_size*index_size					// Allocate 50 * 4 bytes in memory for the array.
		alloc = -(16 + 16 + array_size) & -16				// Set the pre-increment value "alloc", for updating the Stack Pointer. "AND" -16 to quadword align.
		dealloc = -alloc						// Set the post-increment value, for updating SP after frame record is popped.


		i_s = 16							// Set the stack offset (from fp) for variable i to 16	
		j_s = 20							// Set the stack offset (from fp) for variable j to 20
		min_s = 24							// Set the stack offset (from fp) for variable min to 24
		ia_s = 28							// Set the stack offset (from fp) for the base of the array to 28
										

// ============================================================= / END LOCAL VARIABLE MEMORY ALLOCATIONS ============================================================


// ============================================================= DEFINE REGISTERS ===================================================================================

// Note: This section is not necessary, but is used to improve readability of the code. Load and store instructions are still performed on memory from registers.

		define(ia_base_r, x28)						// Define the register holding the stack adress for the base of the array.
		define(index_i_r, w27)						// Define the register holding the index i as register w27.
		define(index_j_r, w26)						// Define the register holding the index j as register w26.

		fp .req x29							// Define fp as x29
		lr .req x30							// Define lr as x30	

// ============================================================ / END: DEFINE REGISTERS ============================================================================



// ============================================================ MAIN ===============================================================================================

		.align 4							// Instructions must be aligned word aligned (4 bytes)
		.global main							// Makes "main" visible to the OS

main:		stp x29, x30, [sp, alloc]!					// Save FP and LR to stack, allocating by the amount "alloc", pre-increment SP. 
		mov fp, sp							// Update frame pointer (FP) to current stack pointer (SP)

		mov ia_base_r, fp						// Calculates the base address of the array. 
		add ia_base_r, ia_base_r, ia_s					// Location of Base of array = (fp + offset from fp to ia_base)


		adrp x0, print_1						// Complete first print function, "Unsorted array: " (higher-order bits)
		add w0, w0, :lo12:print_1                                       // Add lower-order bits to x0 for print_1
		bl printf							// Use bl (branch to label) to call function printf(). 		


// ------------------------------------------------------------------ LOOP 1 : ARRAY INITIALIZATION ----------------------------------------------------------------

		mov index_i_r, 0						// Set index to zero.
		str index_i_r, [fp, i_s]					// Write index i to stack.

		b test_1							// Branch to optimized test_1										

loop_1:									
		ldr index_i_r, [fp, i_s]					// Load the index for i from memory

		bl rand								// Get a random number from the pseudo-random number generator.
		AND w0, w0, 0xFF						// AND value of random with 0xFF, so that the number is between 0 and 255
		str w0, [ia_base_r, index_i_r, SXTW 2]				// Store data from w0 (which holds random number) into v[i]. Sign extend it to fit in our 64-bit memory addresses.
	
		ldr w20, [ia_base_r, index_i_r, SXTW 2]				// Read number from v[i] and store in temporary register w20

		adrp x0, print_3						// Print out the value to standard output, in the form "v[i] = x"
		add w0, w0, :lo12:print_3					// Add lower-order bits to x0 for print 3
		mov w1, index_i_r						// Move i into x1
		mov w2, w20							// Load v[i] from memory, and put it into register x2
		bl printf							// Use bl (branch to label) to call function printf()

		ldr index_i_r, [fp, i_s]					// Get current value of index i
		add index_i_r, index_i_r, 1					// Increment i by 1.
		str index_i_r, [fp, i_s]					// Store new i in memory.


test_1:		cmp index_i_r, array_size					// If i < 50...
		b.lt loop_1							// ... do initialization loop.

// ----------------------------------------------------------------- / END LOOP 1 ---------------------------------------------------------------------------------


		adrp x0, print_2						// Print "Sorted array: "
		add w0, w0, :lo12:print_2					// Add lower 12 digits
		bl printf

// ----------------------------------------------------------------- LOOP 2A --------------------------------------------------------------------------------------

		mov index_i_r, 0						// Set i = 0
		str index_i_r, [fp, i_s]					// Store initial value of i into stack.
	
		b test_2a							// Branch to optimized loop test.
		
loop_2a:	
		mov w20, index_i_r						// Set w20 to i. (min = i)
		str w20, [fp, min_s]						// Store value of min to stack memory.

// ----------------------------------------------------------------- LOOP 2B -------------------------------------------------------------------------------------

		ldr index_i_r, [fp, i_s]					// Load current value of i to register
		mov index_j_r, index_i_r					// Set j = i
		add index_j_r, index_j_r, 1					// j++
		str index_j_r, [fp, j_s]					// Store value of j into stack memory.

		b test_2b							// Branch to loop test.

loop_2b:
		ldr index_j_r, [fp, j_s]	
		ldr w19, [fp, min_s]						// Load value of "min" into register w19.
		ldr w20, [ia_base_r, w19, SXTW 2]				// Load v[min] into w20. SXTW sign extends, and LSL twice, to multiply offset by 4
		ldr w21, [ia_base_r, index_j_r, SXTW 2]				// Load v[j] into w21. SXTW sign extends, and LSL twice to multiply offset by 4

		cmp w20, w21							//Compare v[min] to v[j]
		b.lt next							// If v[min] is less than v[j], skip this step.

		str index_j_r, [fp, min_s]					// Store new "min" value in stack memory.

next:		
		add index_j_r, index_j_r, 1					// j++		
		str index_j_r, [fp, j_s]					// Store new value of j to memory.


test_2b:	cmp index_j_r, array_size					// If j < 50...
		b.lt loop_2b							// Re-iterate back to loop 2b.



// --------------------------------------------------------------- / END LOOP 2B ---------------------------------------------------------------------------------

										// Swap elements v[min] and v[i]
		
		ldr w19, [fp, min_s]						// Load "min" index from stack to w19
		ldr w20, [ia_base_r, w19, SXTW 2]				// Load value of v[min] into w20
		ldr index_i_r, [fp, i_s]					// Load value of i from stack memory.
		ldr w21, [ia_base_r, index_i_r, SXTW 2]				// Load value of v[i] into w21

		mov w22, w21							// Temp = v[i]
		mov w21, w20							// v[i] = v[min]
		mov w20, w22							// v[min] = Temp

		str w20, [ia_base_r, w19, SXTW 2]				// Store v[i] into memory where v[min] was.
		str w21, [ia_base_r, index_i_r, SXTW 2]				// Store v[min] into memory where v[i] was.
		

		adrp x0, print_3						// Print out the value to standard output, in the form "v[i] = x"
		add w0, w0, :lo12:print_3					// Add lower-order bits to x0 for print 3
		mov w1, index_i_r						// Move i into w1
		ldr w20, [ia_base_r, index_i_r, SXTW 2]				// Load value of v[i] to temporary register w20
		mov w2, w20							// Load v[i] from memory, and put it into register x2
		bl printf							// Use bl (branch to label) to call function printf()


		ldr index_i_r, [fp, i_s]					// Load current value of i
		add index_i_r, index_i_r, 1					// i++
		str index_i_r, [fp, i_s]					// Store new value of i back into stack memory.


test_2a:	cmp index_i_r, array_size					// if i < 50 ...
		b.lt loop_2a							// Iterate loop_2a again.

// ---------------------------------------------------------------- /END LOOP 2A ----------------------------------------------------------------------------------

done:		mov w0, 0							// Return 0 to OS
		ldp fp, lr, [sp], dealloc					// De-allocate stack memory.

		ret								// Returns to calling code in OS

