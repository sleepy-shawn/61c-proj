.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:

    # Prologue
    addi sp, sp, -16
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    
    mv s0, a0 # s0 is the pointer to string filename
    mv s1, a1 # s1 is the pointer to the start of the matrix
    mv s2, a2 # s2 is the row num
    mv s3, a3 # s3 is the column num
 


    # First open the file in write mode
    # a0 don't need to change
    li a1, 1 # write mode
    
    addi sp, sp, -4
    sw ra, 0(sp)
    
    jal fopen
    
    lw ra, 0(sp)
    addi sp, sp, 4
    
    li t0, -1
    beq a0, t0, exception_fopen
    
    mv s0, a0 # s0 is the file description
    
    
    # store data of row num and column num in memory
    addi sp, sp, -12
    sw s2, 0(sp)
    sw s3, 4(sp) 
    sw ra, 8(sp)
    
    mv a0, s0 # a0 is the pointer to the string filename
    add a1, sp, x0 # the pointer to data
    li a2, 2 # the num of elements is 2
    li a3, 4 # size of element
    
    jal fwrite
    
    lw s2, 0(sp)
    lw s3, 4(sp)
    lw ra, 8(sp)
    addi sp, sp, 12
    
    li t0, 2
    bne a0, t0, exception_fwrite
    
    # store data in file
    addi sp, sp, -4
    sw ra, 0(sp)
    
    mv a0, s0 # the pointer to filename descriptor
    mv a1, s1 # the data in memory
    mul a2, s2, s3 # the num of elements
    li a3, 4
    
    jal fwrite
    
    lw ra, 0(sp)
    addi sp, sp, 4
    mul t0, s2, s3
    bne a0, t0, exception_fwrite
    
    
    
    addi sp, sp, -4
    sw ra, 0(sp)
    mv a0, s0
    
    jal fclose
    
    lw ra, 0(sp)
    addi sp, sp, 4
    bne a0, x0, exception_fclose


    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    addi sp, sp, 16
    jr ra

exception_fopen:
    li a0, 27
    j exit
    
exception_fwrite:
    li a0, 30
    j exit
    
exception_fclose:
    li a0, 28
    j exit