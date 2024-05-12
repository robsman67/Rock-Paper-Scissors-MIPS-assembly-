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
  move $t1, $v0
  
  jal gen_bit
  add $t2, $t1, $v0
  beq $t2 $t0 gen_byte_without_ra#in order to see if 2 consicutive one are choose by the gen_bit, if 1 we do gen_byte again
  
  sll $t1, $t1, 1  # shift left the first bit by 1 in order to get 10.
  add $v0, $t1, $v0 #add the result into $v0
  
  
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
  addi $sp $sp -4
  sw $a0 0($sp)
  lw $a1 4($a0)
  lw $a0 0($a0)
  #Store the correct value into a0 and a1 to have the correct seed

  #load the random number
  li $v0 41
  syscall
  #For the last significant bit and store in reg $v0
  andi $v0, $a0, 1
  
  #restore the value
  lw $a0 0($sp)
  addi $sp $sp 4
  jr $ra
