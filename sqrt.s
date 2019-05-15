## Square root
## Copyright (C) 2017 by Stanislav Zhelnio under MIT License
## https://github.com/zhelnio/schoolMIPS/blob/master/program/02_sqrt/main.s

## unsigned isqrt (unsigned x) {
##     unsigned m, y, b;
##     m = 0x40000000;
##     y = 0;
##     while (m != 0) { // Do 16 times
##         b = y |  m;
##         y >>= 1;
##         if (x >= b) {
##             x -= b;
##             y |= m;
##         }
##         m >>= 2;
##     }
##     return y;
## }

        .text
	.globl main
main:
init:   li      $a0, 145        ## x = 145

sqrt:   li      $t0, 0x40000000 ## m = 0x40000000
        move    $t1, $0         ## y = 0

L0:     or      $t2, $t1, $t0   ## b = y | m;
        srl     $t1, $t1, 1     ## y >>= 1
        sltu    $t3, $a0, $t2   ## if (x < b)
        bnez    $t3, L1         ##   goto L1
                                ## else
        subu    $a0, $a0, $t2   ##   x -= b
        or      $t1, $t1, $t0   ##   y |= m

L1:     srl     $t0, $t0, 2     ## m >>= 2
        bnez    $t0, L0         ## if(m != 0) goto L0
        move    $v0, $t1        ## return y

end:    b       end             ## while(1);

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
