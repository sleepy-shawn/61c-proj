.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:

    # Prologue
    # save the callee's s
    addi sp, sp, -24
    sw s0, 0(sp) # for a0
    sw s1, 4(sp) # for a1
    sw s2, 8(sp) # for a2
    sw s3, 12(sp) # for file descriptor
    sw s4, 16(sp) # for result matirx pointer
    sw s5, 20(sp) # for store the size(bytes)
    
    # save the arguments
    mv s0, a0
    mv s1, a1
    mv s2, a2
    
    
    # First fopen
    addi sp, sp, -4
    sw ra, 0(sp) # save the ra before calling fopen
    # a0 stays the same
    li a1, 0 # a1 == 0 -> only read
    jal fopen # call fopen
    lw ra, 0(sp)
    addi sp, sp, 4
    li t0, -1 
    beq a0, t0, efopen
    mv s3, a0
    
    # Now s3 contains the file descriptor 
    # Firse read the row
    addi sp, sp, -4 
    sw ra, 0(sp)
    mv a0, s3
    mv a1, s1
    li a2, 4 # read 4 byte
    jal fread # call fread
    lw ra, 0(sp)
    addi sp, sp, 4
    li t0, 4
    bne a0, t0, efread
 
    

    
    # Second read the column
    addi sp, sp, -4
    sw ra, 0(sp)
    mv a0, s3
    mv a1, s2
    li a2, 4
    jal fread
    lw ra, 0(sp)
    addi sp, sp, 4
    li t0, 4
    bne a0, t0, efread
    
# I don't think above is wrong.

   
    # Then call malloc to allocate memory
    lw t0, 0(s1) # the row num
    lw t1, 0(s2) # the column num
    mul s5, t0, t1
    slli s5, s5, 2 # s0 stores the size (byte)
    mv a0, s5
    addi sp, sp, -4
    sw ra, 0(sp)
    jal malloc
    lw ra, 0(sp)
    addi sp, sp, 4
    beq a0, x0, emalloc
    mv s4, a0
 
    # Then call fread again to read the whole matrix
    mv a0, s3 # a0 is the file descriptor
    mv a1, s4 # a1 is the pointer of result memory
    mv a2, s5 # a2 is the size(byte)
    addi sp, sp, -4
    sw ra, 0(sp)
    jal fread
    lw ra, 0(sp)
    addi sp, sp, 4
    bne s5, a0, efread
    
    # close the file
    addi sp, sp, -4
    sw ra, 0(sp)
    mv a0, s3 
    jal fclose
    lw ra, 0(sp)
    addi sp, sp, 4
    bne a0, x0, efclose
    
    
    # Epilogue
    mv a0, s4 # the result matrix pointer
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    addi sp, sp, 24
    jr ra
    
efopen:
    li a0, 27
    j exit
    
emalloc:
    li a0, 26
    j exit
    
efread:
    li a0, 29
    j exit
    
efclose:
    li a0, 28
    j exit