.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:

    # Error checks
    li t0 1
    # dimensions do not make sense
    blt a1 t0 exception
    blt a2 t0 exception
    blt a4 t0 exception
    blt a5 t0 exception
    # dimensions do not match
    bne a2 a4 exception


    # Prologue
    addi sp, sp, -32
    sw s0, 0(sp) 
    sw s1, 4(sp) 
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp) 
    sw s6, 24(sp)
    sw s7, 28(sp)
    
    li s0, 0 # set the begin index of outer loop
    li s1, 0 # set the begin index of inner loop
    mv s2, a1 # save the row num of m0
    mv s3, a5 # save the column num of m1
    mv s4, a0 # save the pointer of m0
    mv s5, a3 # save the pointer of m1
    mv s6, a2 # save the column num of m0
    mv s7, a6 # save the pointer of the result matrix
    

    # for better simplified code
    addi s7, s7, -4
    
outer_loop_start:
    bge s0, s2, outer_loop_end    
   # auto go into inner_loop_start
    li s1, 0
    
inner_loop_start:
   
    bge s1, s3, inner_loop_end
    
    # Set a0 every inner loop
    slli t0, s0, 2
    mul t0, t0, s6
    add a0, t0, s4
    
    # Set a2, a3, a4 every inner loop
    mv a2, s6 # set the num 
    li a3, 1 # set the stride of m1
    mv a4, s3 # set the stride of m2
    
    # Set a1
    slli t0, s1, 2
    add a1, t0, s5
    
    # Set correct a6
    addi s7, s7, 4 # move the result pointer
    
    # jump to dot function
    addi sp, sp, -4
    sw ra, 0(sp)
    jal dot
    sw a0, 0(s7) # fill the result matrix
    lw ra, 0(sp)
    addi sp, sp, 4
    
    addi s1, s1, 1 # add count of inner loop
    j inner_loop_start
    
   
inner_loop_end:
    addi s0, s0, 1 # add count of outer loop
    j outer_loop_start

outer_loop_end:

    # Epilogue
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
    
exception:
    li a0 38
    j exit