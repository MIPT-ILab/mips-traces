.text
	.globl main
main:
move  $t1, $zero
addi  $t2, $zero, 1 

fib:
addu $t3, $t1, $t2 # c := a + b
move $t1, $t2      # a := b
move $t2, $t3      # b := c
nop
j fib

# Standard startup code.  Invoke the routine "main" with arguments:
#	main(argc, argv, envp)
#
	.text
	.globl __start
__start:
	lw $a0, 0($sp)		# argc
	addiu $a1, $sp, 4		# argv
	addiu $a2, $a1, 4		# envp
	sll $v0, $a0, 2
	addu $a2, $a2, $v0
	jal main
	nop

	li $v0, 10
	syscall			# syscall 10 (exit)

	.globl __eoth
__eoth:
