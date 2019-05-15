# Torture test for MIPS32 LE specific instructions
# Based on SPIM torture test
#
# Copyright (c) 1990-2018, James R. Larus, Pavel Kryukov
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
# Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation and/or
# other materials provided with the distribution.
#
# Neither the name of the James R. Larus nor the names of its contributors may be
# used to endorse or promote products derived from this software without specific
# prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
# GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

	.set noreorder
    .set gp=32 # Do not generate 64 bit instructions

	.data
saved_ret_pc:	.word 0		#, Holds PC to return from main
m3:	.asciiz "The next few lines should contain exception error messages\n"
m4:	.asciiz "Done with exceptions\n\n"
m5:	.asciiz "Expect an address error exception:\n	"
m6:	.asciiz "Expect two address error exceptions:\n"
	.text
	.globl main
main:
	sw $31, saved_ret_pc

#
# The first thing to do is to test the exceptions:
#
	li $v0, 4	# syscall 4 (print_str)
	la $a0, m3
	syscall

# Exception 1 (INT) -- Not implemented yet
# Exception 4 (ADEL)
	li $t0, 0x400000
	lw $3, 1($t0)
# Exception 5 (ADES)
	sw $3, 1($t0)
# Exception 6 (IBUS) -- Can't test and continue
# Exception 7 (DBUS)
	lw $3, 10000000($t0)
# Exception 8 (SYSCALL) -- Not implemented
# Exception 9 (BKPT)
	break 0
# Exception 10 (RI) -- Not implemented (can't enter bad instructions)
# Exception 12 (overflow)
	li $t0, 0x7fffffff
	add $t0, $t0, $t0
	li $v0, 4	# syscall 4 (print_str)
	la $a0, m4
	syscall

#
# Try modifying R0
#
	add $0, $0, 1
	bnez $0, fail


#
# Test the timer:
#
#	.data
#timer_:	.asciiz "Testing timer\n"
#	.text
#	li $v0, 4	# syscall 4 (print_str)
#	la $a0, timer_
#	syscall
#
#	mtc0 $0, $9	# Clear count register
#timer1_:
#	mfc0 $9, $9
#	bne $9, 10, timer1_# Count up to 10
#


# Test .ASCIIZ

	.data
asciiz_:.asciiz "Testing .asciiz\n"
str0:	.asciiz ""
str1:	.asciiz "a"
str2:	.asciiz "bb"
str3:	.asciiz "ccc"
str4:	.asciiz "dddd"
str5:	.asciiz "eeeee"
str06:	.asciiz "", "a", "bb", "ccc", "dddd", "eeeee"
	.text
	li $v0, 4	# syscall 4 (print_str)
	la $a0, asciiz_
	syscall

	la $a0, str0
	li $a1, 6
	jal ck_strings

	la $a0, str06
	li $a1, 6
	jal ck_strings

	j over_strlen


ck_strings:
	move $s0, $a0
	move $s1, $ra
	li $s2, 0

l_asciiz1:
	move $a0, $s0
	jal strlen

	bne $v0, $s2, fail

	add $s0, $s0, $v0	# skip string
	add $s0, $s0, 1	# skip null byte

	add $s2, 1
	blt $s2, $a1, l_asciiz1

	move $ra, $s1
	jal $ra


strlen:
	li $v0, 0	# num chars
	move $t0, $a0	# str pointer

l_strlen1:
	lb $t1, 0($t0)
	add $t0, 1
	add $v0, 1
	bnez $t1, l_strlen1

	sub $v0, $v0, 1	# don't count null byte
	jr $31

over_strlen:

#
# Now, test each instruction
#

#########################
## ENDIAN SPECIFIC (LE)
#########################

	.data
lb_:	.asciiz "Testing LB\n"
lbd_:	.byte 1, -1, 0, 128
lbd1_:	.word 0x76543210, 0xfedcba98
	.text
	li $v0, 4	# syscall 4 (print_str)
	la $a0, lb_
	syscall

	la $2, lbd_
	lb $3, 0($2)
	bne $3, 1, fail
	lb $3, 1($2)
	bne $3, -1, fail
	lb $3, 2($2)
	bne $3, 0, fail
	lb $3, 3($2)
	bne $3, 0xffffff80, fail

	la $t0, lbd1_
	lb $t1, 0($t0)
	bne $t1, 0x10, fail
	lb $t1, 1($t0)
	bne $t1, 0x32, fail
	lb $t1, 2($t0)
	bne $t1, 0x54, fail
	lb $t1, 3($t0)
	bne $t1, 0x76, fail
	lb $t1, 4($t0)
	bne $t1, 0xffffff98, fail
	lb $t1, 5($t0)
	bne $t1, 0xffffffba, fail
	lb $t1, 6($t0)
	bne $t1, 0xffffffdc, fail
	lb $t1, 7($t0)
	bne $t1, 0xfffffffe, fail

	li $v0, 4	# syscall 4 (print_str)
	la $a0, m5
	syscall

	li $t5, 0x7fffffff
	lb $3, 1000($t5)


	.data
lbu_:	.asciiz "Testing LBU\n"
	.text
	li $v0, 4	# syscall 4 (print_str)
	la $a0, lbu_
	syscall

	la $2, lbd_
	lbu $3, 0($2)
	bne $3, 1, fail
	lbu $3, 1($2)
	bne $3, 0xff, fail
	lbu $3, 2($2)
	bne $3, 0, fail
	lbu $3, 3($2)
	bne $3, 128, fail

	la $t0, lbd1_
	lbu $t1, 0($t0)
	bne $t1, 0x10, fail
	lbu $t1, 1($t0)
	bne $t1, 0x32, fail
	lbu $t1, 2($t0)
	bne $t1, 0x54, fail
	lbu $t1, 3($t0)
	bne $t1, 0x76, fail
	lbu $t1, 4($t0)
	bne $t1, 0x98, fail
	lbu $t1, 5($t0)
	bne $t1, 0xba, fail
	lbu $t1, 6($t0)
	bne $t1, 0xdc, fail
	lbu $t1, 7($t0)
	bne $t1, 0xfe, fail

	li $v0, 4	# syscall 4 (print_str)
	la $a0, m5
	syscall

	li $t5, 0x7fffffff
	lbu $3, 1000($t5)


	.data
lwl_:	.asciiz "Testing LWL\n"
	.align 2
lwld_:	.byte 0, 1, 2, 3, 4, 5, 6, 7
	.text
	li $v0, 4	# syscall 4 (print_str)
	la $a0, lwl_
	syscall

	la $2, lwld_
	move $3, $0
	lwl $3, 0($2)
	bne $3, 0, fail
	move $3, $0
	lwl $3, 1($2)
	bne $3, 0x01000000, fail
	li $3, 5
	lwl $3, 1($2)
	bne $3, 0x01000005, fail
	move $3, $0
	lwl $3, 2($2)
	bne $3, 0x02010000, fail
	li $3, 5
	lwl $3, 2($2)
	bne $3, 0x02010005, fail
	move $3, $0
	lwl $3, 3($2)
	bne $3, 0x03020100, fail
	li $3, 5
	lwl $3, 3($2)
	bne $3, 0x03020100, fail

	li $v0, 4	# syscall 4 (print_str)
	la $a0, m6
	syscall

	li $t5, 0x7fffffff
	lwl $3, 1000($t5)
	lwl $3, 1001($t5)


	.data
lwr_:	.asciiz "Testing LWR\n"
	.align 2
lwrd_:	.byte 0, 1, 2, 3, 4, 5, 6, 7
	.text
	li $v0, 4	# syscall 4 (print_str)
	la $a0, lwr_
	syscall

	la $2, lwrd_
	li $3, 0x00000500
	lwr $3, 0($2)
	bne $3, 0x3020100, fail
	move $3, $0
	lwr $3, 1($2)
	bne $3, 0x30201, fail
	li $3, 0x50000000
	lwr $3, 1($2)
	bne $3, 0x50030201, fail
	move $3, $0
	lwr $3, 2($2)
	bne $3, 0x0302, fail
	li $3, 0x50000000
	lwr $3, 2($2)
	bne $3, 0x50000302, fail

	li $v0, 4	# syscall 4 (print_str)
	la $a0, m6
	syscall

	li $t5, 0x7fffffff
	lwr $3, 1000($t5)
	lwr $3, 1001($t5)


	.data
sb_:	.asciiz "Testing SB\n"
	.align 2
sbd_:	.byte 0, 0, 0, 0
	.text
	li $v0, 4	# syscall 4 (print_str)
	la $a0, sb_
	syscall

	li $3, 1
	la $2, sbd_
	sb $3, 0($2)
	lw $4, 0($2)
	bne $4, 0x1, fail
	li $3, 2
	sb $3, 1($2)
	lw $4, 0($2)
	bne $4, 0x201, fail
	li $3, 3
	sb $3, 2($2)
	lw $4, 0($2)
	bne $4, 0x30201, fail
	li $3, 4
	sb $3, 3($2)
	lw $4, 0($2)
	bne $4, 0x4030201, fail


	li $v0, 4	# syscall 4 (print_str)
	la $a0, m5
	syscall

	li $t5, 0x7fffffff
	sb $3, 1000($t5)


	.data
sh_:	.asciiz "Testing SH\n"
sh2_:	.asciiz "Expect two address error exceptions:\n"
	.align 2
shd_:	.byte 0, 0, 0, 0
	.text
	li $v0, 4	# syscall 4 (print_str)
	la $a0, sh_
	syscall

	li $3, 1
	la $2, shd_
	sh $3, 0($2)
	lw $4, 0($2)
	bne $4, 0x1, fail
	li $3, 2
	sh $3, 2($2)
	lw $4, 0($2)
	bne $4, 0x20001, fail

	li $v0, 4	# syscall 4 (print_str)
	la $a0, sh2_
	syscall

	li $t5, 0x7fffffff
	sh $3, 1000($t5)
	sh $3, 1001($t5)


 	.data
 swl_:	.asciiz "Testing SWL\n"
 	.align 2
    .word 0
 swld_:	.word 0, 0
 	.text
 	li $v0, 4	# syscall 4 (print_str)
 	la $a0, swl_
 	syscall

 	la $2, swld_
 	li $3, 0x01FFFFFF
 	swl $3, 0($2)
 	lw $4, 0($2)
 	bne $4, 0x1, fail
 	lw $4, -4($2)
 	bnez $4, fail

 	li $3, 0x0102FFFF
 	swl $3, 1($2)
 	lw $4, 0($2)
 	bne $4, 0x0102, fail
 	lw $4, -4($2)
 	bnez $4, fail

 	li $3, 0x010203FF
 	swl $3, 2($2)
 	lw $4, 0($2)
 	bne $4, 0x010203, fail
 	lw $4, -4($2)
 	bnez $4, fail

 	li $3, 0x01020304
 	swl $3, 3($2)
 	lw $4, 0($2)
 	bne $4, 0x01020304, fail
 	lw $4, -4($2)
 	bnez $4, fail


 	.data
 swr_:	.asciiz "Testing SWR\n"
 	.align 2
 swrd_:	.word 0, 0
 	.text
 	li $v0, 4	# syscall 4 (print_str)
 	la $a0, swr_
 	syscall

 	la $2, swrd_
 	li $3, 1
 	swr $3, 0($2)
 	lw $4, 0($2)
 	bne $4, 1, fail

 	li $3, 0x0102
 	swr $3, 1($2)
 	lw $4, 0($2)
 	bne $4, 0x10201, fail

 	li $3, 0x010203
 	swr $3, 2($2)
 	lw $4, 0($2)
 	bne $4, 0x2030201, fail

 	li $3, 0x01020304
 	swr $3, 3($2)
 	lw $4, 0($2)
 	bne $4, 0x4030201, fail


	.data
ulh_:	.asciiz "Testing ULH\n"
ulh1_:	.byte 1, 2, 3, 4, 5, 6, 7, 8
ulh2_:	.byte 0xff, 0xff
	.text

	li $v0, 4	# syscall 4 (print_str)
	la $a0, ulh_
	syscall
	la $2, ulh1_
	ulh $3, 0($2)
	bne $3, 0x0201, fail
	ulh $3, 1($2)
	bne $3, 0x0302, fail
	ulh $3, 2($2)
	bne $3, 0x0403, fail
	ulh $3, 3($2)
	bne $3, 0x0504, fail
	ulh $3, 4($2)
	bne $3, 0x0605, fail
	la $2, ulh2_
	ulh $3, 0($2)
	bne $3, -1, fail


	.data
ulhu_:	.asciiz "Testing ULHU\n"
	.text
	li $v0, 4	# syscall 4 (print_str)
	la $a0, ulhu_
	syscall

	li $v0, 4	# syscall 4 (print_str)
	la $a0, ulhu_
	syscall
	la $2, ulh1_
	ulhu $3, 0($2)
	bne $3, 0x0201, fail
	ulhu $3, 1($2)
	bne $3, 0x0302, fail
	ulhu $3, 2($2)
	bne $3, 0x0403, fail
	ulhu $3, 3($2)
	bne $3, 0x0504, fail
	ulhu $3, 4($2)
	bne $3, 0x0605, fail
	la $2, ulh2_
	ulhu $3, 0($2)
	bne $3, 0xffff, fail


	.data
ulw_:	.asciiz "Testing ULW\n"
	.text
	li $v0, 4	# syscall 4 (print_str)
	la $a0, ulw_
	syscall

	la $2, ulh1_
	ulw $3, 0($2)
	bne $3, 0x04030201, fail
	ulw $3, 1($2)
	bne $3, 0x05040302, fail
	ulw $3, 2($2)
	bne $3, 0x06050403, fail
	ulw $3, 3($2)
	bne $3, 0x07060504, fail


	.data
ush_:	.asciiz "Testing USH\n"
ushd:	.word 0, 0
	.text
	li $v0, 4	# syscall 4 (print_str)
	la $a0, ush_
	syscall

	la $2, ushd
	sw $0, 0($2)
	sw $0, 4($2)
	li $3, 0x01020304
	ush $3, 0($2)
	lw $4, 0($2)
	bne $4, 0x0304, fail
	lw $4, 4($2)
	bne $4, 0, fail

	sw $0, 0($2)
	sw $0, 4($2)
	li $3, 0x01020304
	ush $3, 1($2)
	lw $4, 0($2)
	bne $4, 0x030400, fail
	lw $4, 4($2)
	bne $4, 0, fail

	sw $0, 0($2)
	sw $0, 4($2)
	li $3, 0x01020304
	ush $3, 2($2)
	lw $4, 0($2)
	bne $4, 0x03040000, fail
	lw $4, 4($2)
	bne $4, 0, fail

	sw $0, 0($2)
	sw $0, 4($2)
	li $3, 0x01020304
	ush $3, 3($2)
	lw $4, 0($2)
	bne $4, 0x04000000, fail
	lw $4, 4($2)
	bne $4, 0x03, fail


 	.data
 usw_:	.asciiz "Testing USW\n"
 	.text
 	li $v0, 4	# syscall 4 (print_str)
 	la $a0, usw_
 	syscall

 	la $2, ushd
 	sw $0, 0($2)
 	sw $0, 4($2)
 	li $3, -1
 	usw $3, 0($2)
 	lw $4, 0($2)
 	bne $4, -1, fail
 	lw $4, 4($2)
 	bne $4, 0, fail

 	sw $0, 0($2)
 	sw $0, 4($2)
 	li $3, -1
 	usw $3, 1($2)
 	lw $4, 0($2)
 	bne $4, 0xffffff00, fail
 	lw $4, 4($2)
 	bne $4, 0xff, fail

 	sw $0, 0($2)
 	sw $0, 4($2)
 	li $3, -1
 	usw $3, 2($2)
 	lw $4, 0($2)
 	bne $4, 0xffff0000, fail
 	lw $4, 4($2)
 	bne $4, 0xffff, fail

 	sw $0, 0($2)
 	sw $0, 4($2)
 	li $3, -1
 	usw $3, 3($2)
 	lw $4, 0($2)
 	bne $4, 0xff000000, fail
 	lw $4, 4($2)
 	bne $4, 0xffffff, fail


	.data
word_:	.asciiz "Testing .WORD\n"
	.text
	li $v0, 4	# syscall 4 (print_str)
	la $a0, word_
	syscall

	.data
	.align 0
wordd:	.byte 0x1
	.word 0x2345678
	.word 0x9abcdef
	.text
	la $2, wordd
	lwr $3, 1($2)
	lwl $3, 4($2)
	bne $3, 0x2345678, fail
	lwr $3, 5($2)
	lwl $3, 8($2)
	bne $3, 0x9abcdef, fail

	.data
	.byte 0
x:	.word OK	# Forward reference in unaligned data!
	.text
	lw $8, x
	beq $8, $0, fail

OK:


# Done !!!
	.data
sm:	.asciiz "\nPassed all tests\n"
	.text
	li $v0, 4	# syscall 4 (print_str)
	la $a0, sm
	syscall
	lw $31, saved_ret_pc
	jr $31		#, Return, from main


	.data
fm:	.asciiz "Failed test\n"
	.text
fail:	li $v0, 4	# syscall 4 (print_str)
	la $a0, fm
	syscall
	li $v0, 10	# syscall 10 (exit)
	syscall
	swr $0, 0($0)


	.text 0x408000

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
