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
    addi sp, sp, -32
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw s7, 28(sp)
    
    mv s0, ra
    lw s1, 4(a1) # pointer to filepath string of m0
    lw s2, 8(a1) # pointer to filepath string of m1
    lw s3, 12(a1) # pointer to filepath string of input matrix
    lw s4, 16(a1) # pointer to filepath string of output file
    mv s5, a2 # store the print argument
    # Read pretrained m0
    mv a0, s1 
    addi sp, sp, -8 # allocate memory for row num and column num
    mv a1, sp
    addi a2, sp, 4
    
    j read_matrix
    
    mv s1, a0 # s1 saves the pointer to m0
    

    # Read pretrained m1
    mv a0, s2 
    addi sp, sp, -8 # allocate memory for row num and column num
    mv a1, sp
    addi a2, sp, 4
    
    j read_matrix 
    
    mv s2, a0 # s2 saves the pointer to m1


    # Read input matrix
    mv a0, s3 
    addi sp, sp, -8 # allocate memory for row num and column num
    mv a1, sp
    addi a2, sp, 4
    
    jal read_matrix
    
    mv s3, a0 # s3 saves the pointer to input matrix

# ______________________________________________________________I don't think above is wrong!!!!!
    # Compute h = matmul(m0, input)
    
    # first let's malloc
    lw t0, 16(sp)
    lw t1, 4(sp)
    mul a0, t0, t1
    slli a0, a0, 2 # convert to bytes!!!
    
    jal malloc
    
    beq a0, x0, exception_malloc
   
    mv s6, a0 # s6 is now pointer of matrix h
    
    # then set the arg for matmul
    
    mv a0, s1
    lw a1, 16(sp)
    lw a2, 20(sp)
    mv a3, s3
    lw a4, 0(sp)
    lw a5, 4(sp)
    mv a6, s6 
    
    jal matmul
    
    # Compute h = relu(h)
    mv a0, s6 
    lw t0, 16(sp)
    lw t1, 4(sp)
    mul a1, t0, t1 # a1 is the size of t
    
    jal relu
# _______________________________________I don't think above is wrong    
    
    # Compute o = matmul(m1, h)    
    # first let's malloc again for matrix o
    lw t0, 8(sp)
    lw t1, 4(sp)
    mul a0, t0, t1
    slli a0, a0, 2 # Don't forget convert to bytes!
    
    jal malloc
    
    beq a0, x0, exception_malloc
   
    mv s7, a0 # s7 is now pointer of matrix o
    
    mv a0, s2
    lw a1, 8(sp)
    lw a2, 12(sp)
    mv a3, s6
    lw a4, 16(sp)
    lw a5, 4(sp)
    mv a6, s7

    jal matmul
    
    mv a0, s6
    jal free # h is no use any more
    
# _____________________________________________________I don't think above is wrong
    
    # Write output matrix o
    mv a0, s4
    mv a1, s7
    lw a2, 8(sp)
    lw a3, 4(sp)
    
    jal write_matrix

    # Compute and return argmax(o)
    mv a0, s7
    lw t0, 8(sp)
    lw t1, 4(sp)
    mul a1, t0, t1
    jal argmax
    mv s6, a0 # s1 is the final result since it is no useful now
    bne s5, x0, end # if s5 == x0, print result, if not end directly
    
print_argmax:
   
    # If enabled, print argmax(o) and newline
    # a0 don't need change
    mv a0, s6
    jal print_int
    
    li a0, '\n'
    jal print_char
    
    j end
    
# Epilogue
    
end:    
    # free the three pointer
    mv a0, s1
    jal free
    
    mv a0, s2
    jal free
    
    mv a0, s3
    jal free
    
    mv a0, s7
    jal free
    
    # reset stack pointer
    addi sp, sp, 24
    
    # reset the ra and s registers
    mv ra, s0
    mv a0, s6
    
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw s7, 28(sp)
    
    addi sp, sp, 32
    
    jr ra
    
exception_arg:
    li a0, 31
    j exit
    
exception_malloc:
    li a0, 26
    j exit
    
    