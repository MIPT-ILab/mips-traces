.text

.global __start
 __start:
	# Read integer
	li $v0, 5
	syscall
	
	# Increment and print
	add $a0, $v0, 1
 	li $v0, 1
	syscall

	# Print character
	li $v0, 11
	li $a0, 0xA # '\n'
	syscall

	# Exit
	li $v0, 10
	syscall

