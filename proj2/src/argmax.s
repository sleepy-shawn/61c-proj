.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
    # Prologue
    mv t0, a0 # t0 is the pointer
    mv t1, a1 # t1 is the number of elements
    ble t1, x0, exception # if size is less than one return error
    
   
loop_start:
    lw t2, 0(t0) # t2 stores the value of each
    add t3, x0, t2  # t3 stores the max value, using the first to initialize
    add t4, x0, x0 # t4 stores the max index
    addi t5, x0, 1 # t5 stores the current index
    j loop_continue # beign loop

loop_continue:
    bge t5, t1, loop_end # if count == num, break
    slli t6, t5, 2 # multi the size of word
    add t6, t6, t0 # get the correct index
    lw t2, 0(t6) # t2 gets the current value
    blt t3, t2, remax # if greater than max, then remax
    j increase_count

remax:
    mv t3, t2 # update the value
    mv t4, t5 # uodate the index
    j increase_count
    
increase_count:
    addi t5, t5, 1 # every loop count increases
    j loop_continue # back to loop

loop_end:
    # Epilogue
    mv a0 t4 # a0 returns the pointer index
    jr ra
  
exception:
    li a0 36
    j exit  
