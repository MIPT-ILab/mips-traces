# This is realisation of basic bubble sort algorithm.
# Prototype: void bubble_sort(int* arr , int num)
# num - number of elements in array, num < 536870911
# arr - pointer to the array
# Elements of array could be signed integers
# Both arguments must be sent in $a0 (arr) and $a1 (num)



.globl main
.data
 	numberofelem: .word numberofelem_data
	insertarr: .word insertarr_data
	resbody: .word resbody_data
	res: .word res_data
	badnum: .word badnum_data
 
	numberofelem_data: .asciiz "Number of elements in array: "
	insertarr_data: .asciiz "Elements of array:"
	resbody_data: .asciiz "Sorted array: "
	res_data: .asciiz " "
	badnum_data: .asciiz "Bad number of elements: it must be positive integer. "

	num: .word 0
.text
main:
	# printf numberofelem
	la      $t0, numberofelem 	# load address of msgprompt into $t0
  	lw      $a0, 0($t0)       	# load data from address in $t0 into $a0
  	li      $v0, 4            	# code of print_string
  	syscall                   	# printf syscall
	
	# scanf number of elements
	li 	$v0 , 5 		# code of read_int
	syscall				# call scanf for int
	sw 	$v0 , num		# store to num
	
	# check if num >= 1
	li  	$t0 , 1			# t0 = 1
	bge	$v0 , $t0 , goodnumber	# if num >= t0 goto goodnumber to continue program
	li	$v0 , 4			# code of print_string
	la	$t0 , badnum		# load address of badnum
	lw	$a0 , ($t0)		# load data from t0 to a0
	syscall				# calling printf
	li	$v0 , 10		# code of exit
	syscall
	goodnumber:
	
	# alloc memory for num integers
	li 	$v0 , 9			# code of sbrk
	lw 	$a0 , num		# load number of elements
	sll 	$a0 , $a0 , 2		# a0 = a0 * 4 - size of memory
	syscall 			# call sbrk
	move 	$s0 , $v0		# move address of allocated memory to the t1 and t2 registers - preserved 
	move 	$s1 , $v0		# across procedure calls
	 
	# printf insertarr
        la      $t0, insertarr		# load address of insertarr into $t0
        lw      $a0, 0($t0)             # load data from address in $t0 into $a0
        li      $v0, 4                  # code of print_string
        syscall  

	# scanf num elements of array
	li 	$t0 , 0			# t0 = 1 - counter
	lw 	$t3 , num		# t3 = num
	scanarr:			# beginig of for
		li 	$v0 , 5			# code of read_int
		syscall				# call scanf for int
		sw 	$v0 , ($s0) 		# store int to the t1
		add 	$s0 , $s0 , 4		# t1 += sizeof(int)
		add 	$t0 , $t0 , 1		# t0++
	blt 	$t0 , $t3 , scanarr	# condtiton of for

	# now we have number of elements in num and address of array in s1
	# calling bubble_sort
	addi	$sp , $sp , -4		# move stack pointer on 1 word
	sw	$ra , ($sp) 		# saving ra
	lw	$a1 , num		# a1 = num
	move 	$a0 , $s1		# a0 = address of array
	jal bubble_sort

	# printing array after sort
	# printing main resbody
        la      $t0, resbody            # load address of resbody into $t0
        lw      $a0, 0($t0)             # load data from address in $t0 to $a0
        li      $v0, 4                  # code of print_string
        syscall

	#print res
	li      $t0 , 0                 # t0 = 1 - counter
        lw      $t3 , num               # t3 = num
        printarr:                        # beginig of for
                li      $v0 , 4                 # code of print_string
		la	$t7 , res		# load address of res in $t7
		lw	$a0 , ($t7)		# load data from address in $t7 to $a0
		syscall				# print " "
		li	$v0 , 1
		lw	$a0 , ($s1)		# a1 = *t1 - argument of print
                syscall                         # call print for int
                add     $s1 , $s1 , 4           # t1 += sizeof(int)
                add     $t0 , $t0 , 1           # t0++
        blt     $t0 , $t3 , printarr     # condtiton of for

	# exit
	addi	$sp , $sp , 4		# sp += sizeof(int)
	lw	$ra , ($sp)		# restore ar
	li 	$v0 , 10		# code of exit
	syscall




.data
	errormsg:	.word errormsg_data
	
	errormsg_data:	.asciiz "Error in array sorting."

.text
bubble_sort:
	# for(i = 0 , i < num - 1 , i++)
	#	for(j = 0 , j < num - 1 , j++)
	#		if(a[j] > a[j + 1])
	#			swap(a[j] , a[j + 1])
	
        # There are array address in a0 and number of elements in a1
	# First we need to check is number of elements more than 1. If not, array doesn't need to be sorted
	li	$t0 , 1			# t0 = 1
	bgt	$a1 , $t0 , needtosort	# if num > 1 go to need to sort
	jr	$ra			# return
	needtosort:	
	
	# Sort section
	move	$t2 , $a0		# t2 = a0 - it is a current array pointer
	li      $t0 , 1                 # t0 = 1 - first counter
	forsort1:			# begining of first for
		li      $t1 , 1                 # t1 = 1 - second counter 
		move	$t2 , $a0		# t2 = a0
		forsort2:			# begining of second for		
			lw	$t3 , ($t2)		# t3 = *t2
			add	$t2 , $t2 , 4		# t2 += sizeof(int)
			lw	$t4 , ($t2)		# t4 = *t2
			ble	$t3 , $t4 , dontswap	# if t3 <= t4 don't swap
			# swap section
			sw	$t3 , ($t2)		# *t2 = t3
			sw	$t4 , -4($t2)		# *(t2 - 1) = t4
			# end of swap section
			dontswap:	
			add $t1 , $t1 , 1		# t1++ - counter 
		blt	$t1 , $a1 , forsort2	# condition of second for
		add 	$t0 , $t0 , 1		# t0++ - counter
	blt	$t0 , $a1 , forsort1	# condition of first for
	

	# simple check of sorting array
	li	$t0 , 1			# t0 = 1 - counter
	move 	$t1 , $a0		# t1 = address of array
	forsortcheck:			# begining of for_check
		lw	$t2 , ($t1)		# t2 = *t1
		add	$t1 , $t1 , 4		# t1 += sizeof(int)
		lw	$t3 , ($t1)		# t3 = *t1
		bgt	$t2 , $t3 , sortmistake	# if t2 > t3 go to sortmistake to print error
		add	$t0 , $t0 , 1		# t0++
	blt	$t0 , $a1 , forsortcheck	# condition of for_check

	jr $ra

	sortmistake:
	#print error message
	li	$v0 , 4			# print_string code
	la	$t0 , errormsg		# load address of errormsg
	lw	$a0 , ($t0)		# load data from t0   to a0
	syscall				# call print_string
	sw	$zero , ($zero)		# cause exception







