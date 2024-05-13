# vim:sw=2 syntax=asm
.data
store_tape:
  .space 30 #max space of the tape

store_new_tape:
  .space 30 #in order to store the new tape bit per bit

rule:
  .space 8 #in order to store each bit of the rule

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

  lw $t0, 4($a0)     # Load the tape words
  # Load the length of the tape into $t1
  lb $t1, 8($a0)
  
  lb $s2, 9($a0) #store the number from rule
  
  la $a1 rule #contain the adress of the last significant bit
  
  addiu $s1 $s1 8 #counteur
  
  move $t3, $zero
  move $t4, $zero  
  move $t5, $zero  
  move $t6, $zero  


  # Copy the tape to the store_tape variable in the .data section
  la $t5 store_tape
  la $a1, store_new_tape
  li $t2, 0 # Counter for copying

loop_simulate:
  
  # Check if loop counter is equal to tape length
  beq $t3, $t1, end_copy_simulate
  
  # Extract the LSB of the tape
  andi $t4, $t0, 1
  
  sb $t4, 0($t5)
  
  # Increment loop counter
  addi $t3, $t3, 1
  beq $t3, $t1, end_copy_simulate #in order to not increment when we have reach the length
  # Store the bit in the stack
  addiu $t5 $t5 1
  
  # shift to the left to access the next bit
  srl $t0, $t0, 1
  # Repeat the loop
  j loop_simulate


end_copy_simulate:

  move $t3, $zero
  move $t4, $zero  
  move $t5, $zero  
  move $t6, $zero
  
  la $a0 store_tape
  addiu $t1 $t1 -1 #because start from 0 
  #la $t0, 4($a0)     # Load the tape adress
  # Load the length of the tape into $t1
  
  move $t2 $s2
  move $s2 $zero
  
  la $a1 rule #contain the adress of the last significant bit
  

  
loop_rule:

  beqz $s1 next
  
  andi $t3 $t2, 1 #get the last significant bit
  
  sb $t3 0($a1)
  
  addiu $a1 $a1 1 #come to the left one    
  addiu $s1 $s1 -1 #increase the counter
  
  srl $t2, $t2, 1 #shift in order to do it with the next bit

  b loop_rule
      
      
next:  
  # Initialize loop counter
  li $s1, 0
  

  la $a1 rule #store the adress from rule to $a1 in order to use it later
  la $a0 store_tape #refer to the leas significant bit
  la $a2 store_new_tape
  
  move $t9, $a0 #to keep the last significant bit
  
  addu $a0 $a0 $t1 #refer to the most significant bit (bit of start + length)
  
  move $t0 $a0 #to store the most significantbit
  lb $t3 0($a0) #store in register the most significant for doing the extension on the last cell 
  

loop_automaton:

  beqz $s1 first_cell
  
  #that is if we are in a normal case
  lb $t4 1($a0) #the bit on the left
  lb $t5 0($a0) #the current bit
  lb $t6 -1($a0) #the bit on the right
  
  addiu $s1 $s1 1 #increment the counter
  addiu $a0 $a0 -1 #go to the next bit
  
  j number
  

first_cell: #in order to join the first and the last cell

  lb $t4 0($t9) #the least signififcant bit
  lb $t5 0($a0) #the current bit
  lb $t6 -1($a0) #the bit on the right
  
  addiu $s1 $s1 1 #increment the counter
  addiu $a0 $a0 -1 #go to the next bit
  
  j number
  
  
last_cell:
  lb $t4 1($a0) #the bit on the left
  lb $t5 0($a0) #the current bit
  move $t6 $t3 #the most signififcant bit that we have store in the beginning
  
  sll $t7 $t4 1 #$t7 is now the number to use for the rule  
  addu $t7 $t7 $t5
  sll $t7 $t7 1
  addu $t7 $t7 $t6 #we have now a number between 0 and 7

  addu $t7, $t7 $a1 # we add the number into t7 with the adress of a1. For instance if 
  # t7 is equal to 010 (2) we add 2 to the adresse of a1 in order to check this bit
  
  lb $t4 0($t7)
  sb $t4 0($a2) # add the number into a2 (the new tape)
  
  j n_tape_config
  
number: #take the 3 cell and combine each other

  sll $t7 $t4 1 #$t7 is now the number to use for the rule  
  addu $t7 $t7 $t5
  sll $t7 $t7 1
  addu $t7 $t7 $t6 #we have now a number between 0 and 7

  addu $t7, $t7 $a1 # we add the number into t7 with the adress of a1. For instance if 
  # t7 is equal to 010 (2) we add 2 to the adresse of a1 in order to check this bit
  
  lb $t4 0($t7)
  sb $t4 0($a2) # add the number into a2 (the new tape)
  
  addiu $a2 $a2 1
  
  beq $s1 $t1 last_cell #in order to quit the loop when it's finish and do the last one
  
  j loop_automaton

n_tape_config:

  move $t4 $zero #our new value
  move $t2 $zero #new counter for the n_tape
  la $a2 store_new_tape
  lb $t4 0($a2) #we sart from the LSB
  
  j first_store

n_tape: #here we create the new tape using the data new_tape.

  lb $t3 0($a2) #we sart from the LSB
  sll $t4 $t4 1
  addu $t4 $t4 $t3

first_store: #in order to recompile the number from his bit

  beq $t1 $t2 end_simulate
  
  addiu $a2 $a2 1 #increment or decrement the adresse and the counter
  addiu $t2 $t2 1
  
  j n_tape
  

end_simulate:
  
  #move $t3 $a0 #to keep the adresse of the tape
  move $t2 $zero
  lw $a0 4($sp)     #take back the original a0, from configuration
  sw $t4 4($a0)     # Update the tape
  
  lw $a0 4($sp)
  lw $ra 0($sp)

  addiu $sp $sp 8
  li $s1 0 #restore s1
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
  
  lw $t0, 4($a0)     # Load the tape 
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
  
  # shift to the left to access the next bit
  srl $t0, $t0, 1
  # Repeat the loop
  j loop
 

print:
  # Print the bit
  subu $a1 $a0 $t1
  #move $a1, $a0 #in order to store the adresse of the least significant bit
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

  li $v0, 11      # Charger le code de la syscall pour l'impression d'un caractère
  li $a0, '\n'   # Charger le caractère de saut de ligne
  syscall         # Appeler la syscall pour imprimer le saut de ligne
  lw $ra 0($sp)
  lw $a0 4($sp)
  addiu $sp $sp 8
  jr $ra
