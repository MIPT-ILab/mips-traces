# MIPT-MIPS Simulator
# Corner cases which were found during MIPT-MIPS debug
#
# Copyright (C) 2017 Pavel Kryukov
# This program is a part of MIPT-MIPS source code
# distributed under terms of MIT License
#
# MIPT-MIPS web site: http://mipt-ilab.github.io/mipt-mips/
#

.globl __start

.data

# fail_msg_ are messages for different failures
fail_msg_write_deadbeef: .asciiz "0xDEADBEEF value is not written to registers\n"

.text

__start: 

    j main #start with main part

#print fail message
fail:	
    li $v0, 4	# syscall 4 (print_str)
    #la $a0, fm
    syscall
    jr $ra
    li $v0, 10	# syscall 10 (exit)
    syscall

main:

# In MIPT-MIPS 0xDEADBEEF is a value used for initialization of 32 bits.
# Let's check it is treated as any other value.
write_deadbeef:
    or $t2, $zero, $zero
    li $t1, 0xdeadbeef
    or $t2, $t1, $t1; $t2 must contain 0xdeadbeef
    beq $t2, $t1, end
    la $a0, fail_msg_write_deadbeef
    jal fail

end:
    li $v0, 10	# syscall 10 (exit)
    syscall
