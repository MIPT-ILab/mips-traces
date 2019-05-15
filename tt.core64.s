# Torture test for MIPS64 specific instructions
# Based on SPIM torture test
#
# This file tests instructions specifically in MIPS64 mode
# The key issue is sign extension, as in MIPS64 sign is extended
# to the high 32 bits as well
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
    .set gp=64 # Do not generate 64 bit instructions

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

	.data
addiu_:	.asciiz "Testing ADDIU\n"
	.text
	li $v0, 4	# syscall 4 (print_str)
	la $a0, addiu_
	syscall

	addiu $4, $0, 0
	bnez $4, fail
	addiu $4, $0, 1
	bne $4, 1, fail
	addiu $4, $4, -1
	bnez $4, fail

	li $2, 0x7fffffff
	addiu $2, $2, 2	# should not trap
	bne $2, 0x80000001, fail

	.data
bgez_:	.asciiz "Testing BGEZ\n"
	.text
	li $v0, 4	# syscall 4 (print_str)
	la $a0, bgez_
	syscall

	daddiu $2, $zero, -1
	li $3, 1

	bgez $0, l3
	j fail
l3:	bgez $3, l4
	j fail
l4:	bgez $2, fail


	.data
bgezal_:.asciiz "Testing BGEZAL\n"
	.text
	li $v0, 4	# syscall 4 (print_str)
	la $a0, bgezal_
	syscall

	li $2, -1
	li $3, 1

	bgezal $0, l5
	j fail
	bgezal $2, fail
l5:	bgezal $3, l6
l55:	j fail
l6:	la $4, l55
	bne $31, $4, fail


	.data
bgtz_:	.asciiz "Testing BGTZ\n"
	.text
	li $v0, 4	# syscall 4 (print_str)
	la $a0, bgtz_
	syscall

	daddiu $2, $zero, -1
	li $3, 1

	bgtz $0, fail
l7:	bgtz $3, l8
	j fail
l8:	bgtz $2, fail


	.data
blez_:	.asciiz "Testing BLEZ\n"
	.text
	li $v0, 4	# syscall 4 (print_str)
	la $a0, blez_
	syscall

	daddiu $2, $zero, -1
	li $3, 1

	blez $0, l9
	j fail
l9:	blez $2, l10
	j fail
l10:	blez $3, fail


	.data
bltz_:	.asciiz "Testing BLTZ\n"
	.text
	li $v0, 4	# syscall 4 (print_str)
	la $a0, bltz_
	syscall

	daddiu $2, $zero, -1
	li $3, 1

	bltz $0, fail
l11:	bltz $2, l12
	j fail
l12:	bltz $3, fail


	.data
bltzal_: .asciiz "Testing BLTZAL\n"
	.text
	li $v0, 4	# syscall 4 (print_str)
	la $a0, bltzal_
	syscall

	daddiu $2, $zero, -1
	li $3, 1

	bltzal $0, fail
	bltzal $3, fail
l13:	bltzal $2, l15
l14:	j fail
l15:	la $4, l14
	bne $31, $4, fail

	.data
lh_:	.asciiz "Testing LH\n"
lh2_:	.asciiz "Expect two address error exceptions:\n"
lhd_:	.half 1, -1, 0, 0x8000
	.text
	li $v0, 4	# syscall 4 (print_str)
	la $a0, lh_
	syscall

	la $2, lhd_
	lh $3, 0($2)
	bne $3, 1, fail
	lh $3, 2($2)
	daddiu $4, $zero, -1
	bne $3, $4, fail
	lh $3, 4($2)
	bne $3, 0, fail
	lh $3, 6($2)
    daddiu $4, $zero, 0x8000
	bne $3, $4, fail

	li $v0, 4	# syscall 4 (print_str)
	la $a0, lh2_
	syscall

	li $t5, 0x7fffffff
	lh $3, 1000($t5)
	lh $3, 1001($t5)

	.data
lw_:	.asciiz "Testing LW\n"
lwd_:	.word 1, -1, 0, 0x8000000
	.text
	li $v0, 4	# syscall 4 (print_str)
	la $a0, lw_
	syscall

	la $2, lwd_
	lw $3, 0($2)
	bne $3, 1, fail
	lw $3, 4($2)
    daddiu $4, $zero, -1
	bne $3, $4, fail
	lw $3, 8($2)
	bne $3, 0, fail
	lw $3, 12($2)
	bne $3, 0x8000000, fail

	li $2, 0
	lw $3, lwd_($2)
	bne $3, 1, fail
	addi $2, $2, 4
	lw $3, lwd_($2)
    daddiu $4, $zero, -1
	bne $3, $4, fail
	addi $2, $2, 4
	lw $3, lwd_($2)
	bne $3, 0, fail
	addi $2, $2, 4
	lw $3, lwd_($2)
	bne $3, 0x8000000, fail

	la $2, lwd_
	add $2, $2, 12
	lw $3, -12($2)
	bne $3, 1, fail
	lw $3, -8($2)
    daddiu $4, $zero, -1
	bne $3, $4, fail
	lw $3, -4($2)
	bne $3, 0, fail
	lw $3, 0($2)
	bne $3, 0x8000000, fail

	li $v0, 4	# syscall 4 (print_str)
	la $a0, lh2_
	syscall

	li $t5, 0x7fffffff
	lw $3, 1000($t5)
	lw $3, 1001($t5)

	.data
multu_:	.asciiz "Testing MULTU\n"
	.text
	li $v0, 4	# syscall 4 (print_str)
	la $a0, multu_
	syscall

	multu $0, $0
	mfhi $3
	bnez $3, fail
	mflo $3
	bnez $3, fail

	li $4, 1
	multu $4, $4
	mfhi $3
	bnez $3, fail
	mflo $3
	bne $3, 1, fail

	li $4, -1
	multu $4, $4
	mfhi $3
	bne $3, 0xfffffffe, fail
	mflo $3
	bne $3, 1, fail

	li $4, -1
	li $5, 0
	multu $4, $5
	mfhi $3
	bne $3, 0, fail
	mflo $3
	bne $3, 0, fail

	li $4, -1
	li $5, 1
	multu $4, $5
	mfhi $3
	bne $3, 0, fail
	mflo $3
	bne $3, -1, fail

	li $4, 0x10000
	multu $4, $4
	mfhi $3
	bne $3, 1, fail
	mflo $3
	bne $3, 0, fail

	li $4, 0x80000000
	multu $4, $4
	mfhi $3
	bne $3, 0x40000000, fail
	mflo $3
	bne $3, 0, fail

	li $3, 0xcecb8f27
	li $4, 0xfd87b5f2
	multu $3, $4
	mfhi $3
	bne $3, 0xcccccccb, fail
	mflo $3
	bne $3, 0x7134e5de, fail

	.data
nor_:	.asciiz "Testing NOR\n"
	.text
	li $v0, 4	# syscall 4 (print_str)
	la $a0, nor_
	syscall

	li $2, 1
	daddiu $3, $zero, -1

	nor $4, $0, $0
	bne $4, $3, fail
	nor $4, $2, $2
    daddiu $5, $zero, 0xfffe
	bne $4, $5, fail
	nor $4, $2, $3
	bne $4, 0, fail

	.data
sll_:	.asciiz "Testing SLL\n"
	.text
	li $v0, 4	# syscall 4 (print_str)
	la $a0, sll_
	syscall

	li $2, 1

	sll $3, $2, 0
	bne $3, 1, fail
	sll $3, $2, 1
	bne $3, 2, fail
	sll $3, $2, 16
	bne $3, 0x10000, fail
	sll $3, $2, 31
    li  $4, 0xffffffff
    dsll32 $5, $4, 0
    li  $4, 0x80000000
    or $4, $5, $4
	bne $3, $4, fail

	.data
slt_:	.asciiz "Testing SLT\n"
	.text
	li $v0, 4	# syscall 4 (print_str)
	la $a0, slt_
	syscall

	slt $3, $0, $0
	bne $3, 0, fail
	li $2, 1
	slt $3, $2, $0
	bne $3, 0, fail
	slt $3, $0, $2
	bne $3, 1, fail
	daddiu $2, $zero, -1
	slt $3, $2, $0
	bne $3, 1, fail
	slt $3, $0, $2
	bne $3, 0, fail
	daddiu $2, $zero, -1
	li $4, 1
	slt $3, $2, $4
	bne $3, 1, fail

	.data
slti_:	.asciiz "Testing SLTI\n"
	.text
	li $v0, 4	# syscall 4 (print_str)
	la $a0, slti_
	syscall

	slti $3, $0, 0
	bne $3, 0, fail
	li $2, 1
	slti $3, $2, 0
	bne $3, 0, fail
	slti $3, $0, 1
	bne $3, 1, fail
	daddiu $2, $zero, -1
	slti $3, $2, 0
	bne $3, 1, fail
	slti $3, $0, -1
	bne $3, 0, fail
	daddiu $2, $zero, -1
	li $4, 1
	slti $3, $2, 1
	bne $3, 1, fail
	slti $3, $4, -1
	bne $3, 0, fail

	.data
sra_:	.asciiz "Testing SRA\n"
	.text
	li $v0, 4	# syscall 4 (print_str)
	la $a0, sra_
	syscall

	li $2, 1
	sra $3, $2, 0
	bne $3, 1, fail
	sra $3, $2, 1
	bne $3, 0, fail
	li $2, 0x1000
	sra $3, $2, 4
	bne $3, 0x100, fail
	li $2, 0x80000000
	sra $3, $2, 4
    li  $6, 0xffffffff
    dsll32 $5, $6, 0
    li  $6, 0xf8000000
    or $6, $5, $6
	bne $3, $6, fail


	.data
srav_:	.asciiz "Testing SRAV\n"
	.text
	li $v0, 4	# syscall 4 (print_str)
	la $a0, srav_
	syscall

	li $2, 1
	li $4, 0
	srav $3, $2, $4
	bne $3, 1, fail
	li $4, 1
	srav $3, $2, $4
	bne $3, 0, fail
	li $2, 0x1000
	li $4, 4
	srav $3, $2, $4
	bne $3, 0x100, fail
	li $2, 0x80000000
	li $4, 4
	srav $3, $2, $4
    li  $6, 0xffffffff
    dsll32 $5, $6, 0
    li  $6, 0xf8000000
    or $6, $5, $6
	bne $3, $6, fail

	.data
xori_:	.asciiz "Testing XORI\n"
	.text
	li $v0, 4	# syscall 4 (print_str)
	la $a0, xori_
	syscall

	li $2, 1
	li $3, -1

	xori $4, $0, 0
	bne $4, 0, fail
	xori $4, $3, 0xffff
	bne $4, 0xffff0000, fail
	xori $4, $2, 0xffff
	bne $4, 0x0000fffe, fail

	.data
bge_:	.asciiz "Testing BGE\n"
	.text
	li $v0, 4	# syscall 4 (print_str)
	la $a0, bge_
	syscall

	bge $0, $0, l106
	j fail
l106:	li $2, 1
	bge $0, $2, fail
	bge $2, $0, l107
	j fail
l107:	daddiu $3, $zero, -1
	bge $3, $2, fail
	bge $2, $3, l108
	j fail
l108:

	bge $0, 0, l109
	j fail
l109:	li $2, 1
	bge $0, 1, fail
	bge $2, 0, l110
	j fail
l110:	daddiu $3, $zero, -1
	bge $3, 1, fail
	bge $2, -1, l111
	j fail
l111:

	.data
bgt_:	.asciiz "Testing BGT\n"
	.text
	li $v0, 4	# syscall 4 (print_str)
	la $a0, bgt_
	syscall

	bgt $0, $0, fail
l120:	li $2, 1
	bgt $0, $2, fail
	bgt $2, $0, l121
	j fail
l121:	daddiu $3, $zero, -1
	bgt $3, $2, fail
	bgt $2, $3, l122
	j fail
l122:

	bgt $0, 0, fail
l123:	li $2, 1
	bgt $0, 1, fail
	bgt $2, 0, l124
	j fail
l124:	daddiu $3, $zero, -1
	bgt $3, 1, fail
	bgt $2, -1, l125
	j fail
l125:

	.data
ble_:	.asciiz "Testing BLE\n"
	.text
	li $v0, 4	# syscall 4 (print_str)
	la $a0, ble_
	syscall

	ble $0, $0, l140
	j fail
l140:	li $2, 1
	ble $2, $0, fail
	ble $0, $2, l141
	j fail
l141:	daddiu $3, $zero, -1
	ble $2, $3, fail
	ble $3, $2, l142
	j fail
l142:

	ble $0, 0, l143
	j fail
l143:	li $2, 1
	ble $2, 0, fail
	ble $0, 1, l144
	j fail
l144:	daddiu $3, $zero, -1
	ble $2, $3, fail
	ble $3, 1, l145
	j fail
l145:

	.data
blt_:	.asciiz "Testing BLT\n"
	.text
	li $v0, 4	# syscall 4 (print_str)
	la $a0, blt_
	syscall

	blt $0, $0, fail
l160:	li $2, 1
	blt $2, $0, fail
	blt $0, $2, l161
	j fail
l161:	daddiu $3, $zero, -1
	blt $2, $3, fail
	blt $3, $2, l162
	j fail
l162:

	blt $0, 0, fail
l163:	li $2, 1
	blt $2, 0, fail
	blt $0, 1, l164
	j fail
l164:	daddiu $3, $zero, -1
	blt $2, $3, fail
	blt $3, 1, l165
	j fail
l165:

	.data
not_:	.asciiz "Testing NOT\n"
	.text
	li $v0, 4	# syscall 4 (print_str)
	la $a0, not_
	syscall

	not $2, $0
    daddiu $4, $zero, -1
	bne $2, $4, fail
	li $2, 0
	not $3, $2
	bne $3, $4, fail
	not $3, $4
	bne $3, 0, fail

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
