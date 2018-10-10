.data
	str: .asciiz "MIPT-MIPS supports syscalls!\n"

.text

.global __start
 __start:
 	# Print integer
 	li $v0, 1
	li $a0, 1337
	syscall

	# Print character
	li $v0, 11
	li $a0, 0xA # '\n'
	syscall

	# Print string
	li $v0, 4
	li $a0, str
	syscall

	# File IO syscalls coming later

	# Read character
	li $v0, 12
	syscall

	# Exit
	li $v0, 10
	syscall

