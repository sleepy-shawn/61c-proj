.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
    # Prologue
    mv t0, a0 # t0 stores the pointer
    mv t1, a1 # t1 stores the number of array
    ble t1, x0, exception
    add t2, x0, x0 # t2 track the index of the array
    


loop_start:
    bge t2, t1, loop_end # if the current index >= total num
    
    slli t3, t2, 2 # t3 = t2 * 4 for getting the word index
    add t3, t3, t0 # move the pointer
    lw t4, 0(t3) # get the element of the current index
    
    blt t4, x0, loop_continue # if the element < 0
    j count_increase
    
    
loop_continue:
    sw x0, 0(t3) # if element < 0, change it to 0
    j count_increase

count_increase:
    addi t2, t2, 1 # add the count
    j loop_start # still loop

exception:
    li a0, 36
    j exit
    
loop_end:

    # Epilogue
    jr ra
