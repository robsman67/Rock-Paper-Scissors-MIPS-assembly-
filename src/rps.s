# vim:sw=2 syntax=asm
.data
  
  #ascii character for the output
msg:
  .ascii "T"
  .ascii "W"
  .ascii "L"

.text
  .globl play_game_once

# Play the game once, that is
# (1) compute two moves (RPS) for the two computer players
# (2) Print (W)in (L)oss or (T)ie, whether the first player wins, looses or ties.
#
# Arguments:
#     $a0 : address of configuration in memory
#   0($a0): eca       (1 word)
#   4($a0): tape      (1 word)
#   8($a0): tape_len  (1 byte)
#   9($a0): rule      (1 byte)
#  10($a0): skip      (1 byte)
#  11($a0): column    (1 byte)
#
# Returns: Nothing, only print either character 'W', 'L', or 'T' to stdout
play_game_once:

  addiu $sp $sp -8
  sw $ra 0($sp)
  sw $a0 4($sp)
  
  
  jal gen_byte #create the first byte of the first player
  move $t4 $v0 #store the result of first player

  jal gen_byte
  
  move $t0, $t4
  move $t1, $v0 #Player two
  
  li $t2 1 #refer to 01 paper
  li $t3 2 #refer to 02 Scissors in order to compare
  la $a1 msg
  
  #check  the value of $t0 (the first player) and link in consequently to the correct game result
  beq $t0, $t1, draw 
  beq $t0, $zero, rock
  beq $t0, $t2, paper
  b scissors #else
  
draw:

  lb $a0 0($a1) #refer to T
  li $v0 11
  syscall
  lw $ra 0($sp)
  lw $a0 4($sp)
  addiu $sp $sp 8
  jr $ra
  
rock:

  beq $t1, $t2, win_2 #two possibilites, if paper so player 2 win
  j win_1		#else player 1
  

paper:

  beq $t1, $zero, win_1
  j win_2

scissors:

  beq $t1, $zero, win_2
  j win_1

win_1:

  lb $a0 1($a1) #refer to Win
  li $v0 11
  syscall
  lw $ra 0($sp)
  lw $a0 4($sp)
  addiu $sp $sp 8
  jr $ra
  
win_2:

  lb $a0 2($a1) #refer to Loose
  li $v0 11
  syscall
  lw $ra 0($sp)
  lw $a0 4($sp)
  addiu $sp $sp 4
  jr $ra
  

  
  

  
