.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the number of elements to use is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:
    # Prologue
    li t0,1 # for later comparsion
    blt a2, t0, exception1 # If the number of elements less than 1
    blt a3, t0, exception2 # If the stride 1 less than 1
    blt a4, t0, exception2 # If the stride 2 less than 1
    
    li t0, 0 # the total sum
    li t1, 0 # the times for loop
    li t2, 0 # the index of A
    li t3, 0 # the index of B
    
    j loop_start # start loop
    
loop_start:
    bge t1, a2, loop_end # if reach the aim times
    
    slli t4, t2, 2 # get the correct index of words
    slli t5, t3, 2 # get the correct index of words
    
    add t4, t4, a0 # add from the base index
    add t5, t5, a1 # add from the base index
    
    lw t4, 0(t4) # t4 gets the value
    lw t5, 0(t5) # t5 gets the value
    
    mul t4, t4, t5 # mul the two value
    add t0, t0, t4 # add to the total sum
    
    add t2, t2, a3 # update the A index
    add t3, t3, a4 # update the B index
    
    addi t1, t1, 1 # add the loop times
    
    j loop_start 

loop_end:
    # Epilogue
    mv a0, t0 # get the return value
    jr ra

exception1:
    li a0 36 
    j exit
    
exception2:
    li a0 37
    j exit