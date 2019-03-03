.section .text
.globl __start

__start:
   addi $a0, $0, 100
   addi $a1, $0, 200 
   jal test
   jr $zero # Required to halt simulation
test:
   add $v0, $a0, $a1
   jr $ra
