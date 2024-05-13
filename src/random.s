# vim:sw=2 syntax=asm
.data

.text
  .globl gen_byte, gen_bit

# Arguments:
#     $a0 : address of configuration in memory
#   0($a0): eca       (1 word)
#   4($a0): tape      (1 word)
#   8($a0): tape_len  (1 byte)
#   9($a0): rule      (1 byte)
#  10($a0): skip      (1 byte)
#  11($a0): column    (1 byte)
#
# Return value:
#  Compute the next valid byte (00, 01, 10) and put into $v0
#  If 11 would be returned, produce two new bits until valid
#
gen_byte:
  # Save $ra, because we can lose it when we do the jal gen_bit
  addiu $sp $sp -8
  sw $ra 0($sp)
  sw $a0 4($sp)
  
  
gen_byte_without_ra: #we can keep the initial value of   
  #move $a1, $ra
  #$t0 in order to compare if 11
  li $t0 2
  jal gen_bit
  #t1 contain the value of the first random number
  move $s3, $v0
  #lw $a0 4($sp) #restore the correct value of $a0 before going to the second bit
  jal gen_bit
  li $t0 2
  add $t2, $s3, $v0
  beq $t2 $t0 gen_byte_without_ra#in order to see if 2 consicutive one are choose by the gen_bit, if 1 we do gen_byte again
  
  sll $s3, $s3, 1  # shift left the first bit by 1 in order to get 10.
  add $v0, $s3, $v0 #add the result into $v0
  
  # take the good $ra back
  lw $ra 0($sp)
  lw $a0 4($sp)
  addiu $sp $sp 8
  jr $ra

# Arguments:
#     $a0 : address of configuration in memory
#   0($a0): eca       (1 word)
#   4($a0): tape      (1 word)
#   8($a0): tape_len  (1 byte)
#   9($a0): rule      (1 byte)
#  10($a0): skip      (1 byte)
#  11($a0): column    (1 byte)
#
# Return value:
#  Look at the field {eca} and use the associated random number generator to generate one bit.
#  Put the computed bit into $v0
#
gen_bit:

  
  #we store the $a0 value that refer to configuration
  addi $sp $sp -8
  sw $a0 0($sp)
  sw $ra 4($sp)
  
  la $a0 0($a0)
  
  lw $a1 4($a0) #has the tape
  lw $t5 0($a0) #the eca
  
  beqz $t5 ecaz
  
  lb $t4 10($a0) #the skip
  lb $t2 11($a0) #the columm
  lb $t6 8($a0) #the lenght in order to get the correct place
  #addiu $t6 $t6 -1
  
  move $t3 $zero #the counter

eca:

  beq $t3 $t4 columm #when we have done it skip time
  
  addi $sp $sp -24

  sw $t2 0($sp)
  sw $t3 4($sp)
  sw $t4 8($sp)
  sw $t5 12($sp)
  sw $t6 16($sp)
  sw $a1 20($sp)
  sw $a0 24($sp)
  jal simulate_automaton
  
  lw $t2 0($sp)
  lw $t3 4($sp)
  lw $t4 8($sp)
  lw $t5 12($sp)
  lw $t6 16($sp)
  lw $a1 20($sp)
  sw $a0 24($sp)
  addi $sp $sp 24
  
  addiu $t3 $t3 1
  
  j eca

columm: #now we must take the bit from the columm
  
  lw $t5 4($a0) #the tape (new/last)
  
  subu $t7 $t6 $t2 #the new counter
  
  addiu $t7 $t7 -1
  
columm_loop:

  beqz $t7 end
  
  srl $t5 $t5 1 #shift by left
  
  addiu $t7 $t7 -1
  
  andi $v0, $t5, 1 #get the least signifcant bit
  
  j columm_loop
  

  #Store the correct value into a0 and a1 to have the correct seed
  
ecaz:
  lw $a0 0($a0)
  #load the random number
  li $v0 41
  syscall
  #For the last significant bit and store in reg $v0
  andi $v0, $a0, 1

end:
  #do a move for store the value in v0
  #restore the value
  
  lw $a0 0($sp)
  lw $ra 4($sp)
  addi $sp $sp 8
  jr $ra
