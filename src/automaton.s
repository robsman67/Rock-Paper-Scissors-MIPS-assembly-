# vim:sw=2 syntax=asm
.data
store_tape:
  .space 30

.text
  .globl simulate_automaton, print_tape

# Simulate one step of the cellular automaton
# Arguments:
#     $a0 : address of configuration in memory
#   0($a0): eca       (1 word)
#   4($a0): tape      (1 word)
#   8($a0): tape_len  (1 byte)
#   9($a0): rule      (1 byte)
#  10($a0): skip      (1 byte)
#  11($a0): column    (1 byte)
#
# Returns: Nothing, but updates the tape in memory location 4($a0)
simulate_automaton:
  
  #load the ra to go back from where it come
  addiu $sp $sp -8
  sw $ra 0($sp)
  sw $a0 4($sp)
  
  lw $t0, 4($a0)     # Load the tape address
  # Load the length of the tape into $t1
  lb $t1, 8($a0)
  
  # Initialize loop counter
  li $t3, 0
  
  la $a0 store_tape
  
  


  jr $ra

# Print the tape of the cellular automaton
# Arguments:
#     $a0 : address of configuration in memory
#   0($a0): eca       (1 word)
#   4($a0): tape      (1 word)
#   8($a0): tape_len  (1 byte)
#   9($a0): rule      (1 byte)
#  10($a0): skip      (1 byte)
#  11($a0): column    (1 byte)
#
# Return nothing, print the tape as follows:
#   Example:
#       tape: 42 (0b00101010)
#       tape_len: 8
#   Print:  
#       __X_X_X_

print_tape:

  #load the ra to go back from where it come
  addiu $sp $sp -8
  sw $ra 0($sp)
  sw $a0 4($sp)
  
  lw $t0, 4($a0)     # Load the tape address
  # Load the length of the tape into $t1
  lb $t1, 8($a0)
  
  # Initialize loop counter
  li $t3, 0
  la $a0 store_tape
  

loop:
  # Check if loop counter is equal to tape length
  beq $t3, $t1, print
  
  # Extract the LSB of the tape
  andi $t4, $t0, 1
  
  sb $t4, 0($a0)
  
  # Increment loop counter
  addi $t3, $t3, 1
  beq $t3, $t1, print #in order to not increment when we have reach the length
  # Store the bit in the stack
  addiu $a0 $a0 1
  
  # Shift the mask to the left to access the next bit
  srl $t0, $t0, 1
  # Repeat the loop
  j loop

print:
  # Print the bit
  li $t3, 0           # Reset loop counter
  
print_loop:
  # Check if loop counter is equal to tape length
  beq $t3, $t1, end

  # Load the bit from the stack
  lb $t4, 0($a0)
  
  move $t5, $a0	  #to keep the correct value of the adresse
  # Print 'X' if the current bit is 1, else go to print_dead and print '_'
  beqz $t4, print_dead
     
  li $v0, 11          # syscall code for printing character
  li $a0, 'X'         # Load 'X' character to print
  syscall
  move $a0 $t5
  j next_iteration

print_dead:
  li $v0, 11          
  li $a0, '_'         # Load '_' character to print
  syscall
  move $a0 $t5

next_iteration:
  # Increment loop counter
  addi $t3, $t3, 1
  
  # Increment the address of the next bit in the data
  addiu $a0 $a0 -1
  
  # Repeat the loop
  j print_loop

end:
  lw $ra 0($sp)
  lw $a0 4($sp)
  addiu $sp $sp 8
  jr $ra
