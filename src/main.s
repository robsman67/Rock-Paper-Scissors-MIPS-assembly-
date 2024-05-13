.data
    .globl main

# Memory layout of the Configuration
# |   eca  |   tape   |  tape_len  |  rule  |  skip  | column |
# | 1 word |  1 word  |   1 byte   | 1 byte | 1 byte | 1 byte |
automaton:
  .word 1       # eca
  .word 252     # tape
  .byte 8       # tape_len
  .byte 106     # rule
  .byte 1       # skip
  .byte 5       # column

.text

main:
  li $s0 10 # loop counter
loop:
  beqz $s0 terminate
  subi $s0 $s0 1
  la $a0 automaton
  jal gen_byte
  # print returned value
  move $a0 $v0
  li $v0 1
  syscall
  j loop
terminate:
  li      $v0 10
  syscall
