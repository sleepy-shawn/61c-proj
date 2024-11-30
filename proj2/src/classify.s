.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>

classify:
# Prologue

# check the arg error
    li t0, 5
    bne a0, t0, exception_arg 
    
# save ra and s register
    addi sp, sp, -48
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
    sw s7, 32(sp)
    sw s8, 36(sp)
    sw s9, 40(sp)
    sw s10, 44(sp)
  
    mv s0, a1
    mv s1, a2 # store the print argument
    
    
    # Read pretrained m0
    li a0, 8
    jal malloc
    beq a0, x0, exception_malloc
    mv s2, a0 # s2 stores m0's row and column
    lw a0, 4(s0)
    mv a1, s2
    addi a2, s2, 4 
    
    jal read_matrix
    
    mv s3, a0 # s3 saves the pointer to m0
    

    # Read pretrained m1
    li a0, 8
    jal malloc
    beq a0, x0, exception_malloc
    mv s4, a0 # s4 stores m1's row and column
    lw a0, 8(s0)
    mv a1, s4
    addi a2, s4, 4 
    
    jal read_matrix 
    
    mv s5, a0 # s5 saves the pointer to m1


    # Read input matrix
    li a0, 8
    jal malloc
    beq a0, x0, exception_malloc
    mv s6, a0 # s6 stores m0's row and column
    lw a0, 12(s0)
    mv a1, s6
    addi a2, s6, 4 
    
    jal read_matrix
    
    mv s7, a0 # s7 saves the pointer to input matrix

# ______________________________________________________________I don't think above is wrong!!!!!
    # Compute h = matmul(m0, input)
    
    # first let's malloc
    lw t0, 0(s2)
    lw t1, 4(s6)
    mul a0, t0, t1
    slli a0, a0, 2 # convert to bytes!!!
    
    jal malloc
    
    beq a0, x0, exception_malloc
   
    mv s8, a0 # s8 is now pointer of matrix h
    
    # then set the arg for matmul
    
    mv a0, s3
    lw a1, 0(s2)
    lw a2, 4(s2)
    mv a3, s7
    lw a4, 0(s6)
    lw a5, 4(s6)
    mv a6, s8
    
    jal matmul
    
    # Compute h = relu(h)
    mv a0, s8 
    lw t0, 0(s2)
    lw t1, 4(s6)
    mul a1, t0, t1 # a1 is the size of t
    
    jal relu
# _______________________________________I don't think above is wrong    
    
    # Compute o = matmul(m1, h)    
    # first let's malloc again for matrix o
    lw t0, 0(s4)
    lw t1, 4(s6)
    mul a0, t0, t1
    slli a0, a0, 2 # Don't forget convert to bytes!
    
    jal malloc
    
    beq a0, x0, exception_malloc
   
    mv s9, a0 # s9 is now pointer of matrix o
    
    mv a0, s5
    lw a1, 0(s4)
    lw a2, 4(s4)
    mv a3, s8
    lw a4, 0(s2)
    lw a5, 4(s6)
    mv a6, s9

    jal matmul
    
    
    
# _____________________________________________________I don't think above is wrong
    
    # Write output matrix o
    lw a0, 16(s0)
    mv a1, s9
    lw a2, 0(s4)
    lw a3, 4(s6)
    
    jal write_matrix

    # Compute and return argmax(o)
    
    mv a0, s9
    lw t0, 0(s2)
    lw t1, 4(s6)
    mul a1, t0, t1
    jal argmax
    mv s10, a0 
    bne s1, x0, no_print # if s1 == x0, print result, if not end directly
   
    # If enabled, print argmax(o) and newline
    # a0 don't need change
    mv a0, s10
    jal print_int
    
    li a0, '\n'
    jal print_char
    
 
    
# Epilogue
    
no_print:    
    # free the three pointer
    mv a0, s2
    jal free
    
    mv a0, s3
    jal free
    
    mv a0, s4
    jal free
    
    mv a0, s5
    jal free 
    
    mv a0, s6
    jal free
    
    mv a0, s7
    jal free
    
    mv a0, s8
    jal free
    
    mv a0, s9
    jal free
    
    # reset the ra and s registers
    mv a0, s10
    
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    lw s7, 32(sp)
    lw s8, 36(sp)
    lw s9, 40(sp)
    lw s10, 44(sp)
    addi sp, sp, 48
    
    jr ra
    
exception_arg:
    li a0, 31
    j exit
    
exception_malloc:
    li a0, 26
    j exit
    
    