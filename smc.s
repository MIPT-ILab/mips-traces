# MIPT-MIPS Simulator
# Self-modifying code stress test for MIPS CPU
#
# Copyright (C) 2017 Yarovoy Danil
# This program is a part of MIPT-MIPS source code
# distributed under terms of MIT License
#
# MIPT-MIPS web site: http://mipt-ilab.github.io/mipt-mips/
#

# We check 3 types of modification of ALU instructions:
# * Modification of immediate (addi %r1, %r2, $5 -> addi %r1, %r2, $a5)
# * Modification of register (addi %r1, %r2, $5 -> addi %r3, %r1, $5)
# * Modification of opcode (add %r1, %r2, %r2 -> sub %r1, %r2, %r2)
#
# After that, we check modification of unconditional jump targets
#
# Each check begins with the simplest case:
# modifying instruction is executed ~10 instructions
# before instruction it modifies, than the gap becomes
# closer: 4, 3, 2, 1, 0 filling instructions.
# We use different gaps to check behavior
# on different pipeline depths.
#
# The SMC subroutine template goes as follows
#   fill_TYPE_GAPLEN:
#       la $t1, NEW_LABEL   # get address of new instruction
#       lw $t0, 0($t1)      # read new instruction
#       la $t1, OLD_LABEL   # get address of overwritten instruction
#       sw $t0, 0($t1)      # overwrite instruction
#     # gap of GAPLEN instruction goes here
#   OLD_LABEL:
#       add $t1, $t2, 0x5
#     # Checking subroutine. If it fails, we jump `fail' label
#     # to print the fail message

.globl __start

.data

# fail_msg_ messages for immediate modification
fail_msg_immediate_gap10: .asciiz "Failed modification of immediate with 10 gap\n"
fail_msg_immediate_gap4: .asciiz "Failed modification of immediate with 4 gap\n"
fail_msg_immediate_gap3: .asciiz "Failed modification of immediate with 3 gap\n"
fail_msg_immediate_gap2: .asciiz "Failed modification of immediate with 2 gap\n"
fail_msg_immediate_gap1: .asciiz "Failed modification of immediate with 1 gap\n"
fail_msg_immediate_gap0: .asciiz "Failed modification of immediate with 0 gap\n"

# fail_msg_ messages for register modification 
fail_msg_register_gap10: .asciiz "Failed modification of register with 10 gap\n"
fail_msg_register_gap4: .asciiz "Failed modification of register with 4 gap\n"
fail_msg_register_gap3: .asciiz "Failed modification of register with 3 gap\n"
fail_msg_register_gap2: .asciiz "Failed modification of register with 2 gap\n"
fail_msg_register_gap1: .asciiz "Failed modification of register with 1 gap\n"
fail_msg_register_gap0: .asciiz "Failed modification of register with 0 gap\n"

# fail_msg_ messages for opcode modification 
fail_msg_opcode_gap10: .asciiz "Failed modification of opcode with 10 gap\n"
fail_msg_opcode_gap4: .asciiz "Failed modification of opcode with 4 gap\n"
fail_msg_opcode_gap3: .asciiz "Failed modification of opcode with 3 gap\n"
fail_msg_opcode_gap2: .asciiz "Failed modification of opcode with 2 gap\n"
fail_msg_opcode_gap1: .asciiz "Failed modification of opcode with 1 gap\n"
fail_msg_opcode_gap0: .asciiz "Failed modification of opcode with 0 gap\n"

# fail_msg_ messages for branch modification 
fail_msg_branch_gap10: .asciiz "Failed modification of branch with 10 gap\n"
fail_msg_branch_gap4: .asciiz "Failed modification of branch with 4 gap\n"
fail_msg_branch_gap3: .asciiz "Failed modification of branch with 3 gap\n"
fail_msg_branch_gap2: .asciiz "Failed modification of branch with 2 gap\n"
fail_msg_branch_gap1: .asciiz "Failed modification of branch with 1 gap\n"
fail_msg_branch_gap0: .asciiz "Failed modification of branch with 0 gap\n"

.text

__start: 

    j main #start with main part
#instructions that we want to get after modification
new_immediate:
    addi $t1, $t2, 0xa5
new_register:
    addi $t3, $t1, 0x5
new_opcode:
    sub $t1, $t2, $t2

#print fail message
fail:	
    li $v0, 4	# syscall 4 (print_str)
    #la $a0, fm
    syscall
    jr $ra
	#li $v0, 10	# syscall 10 (exit)
    #syscall

main:

#--------------------------------------------
# check SMC for modification if immediate
#--------------------------------------------

#--------------------------------------------

    
#gap  with 10 instructions
fill_immediate_gap10:

    #initialize t2 and t3 for checking modification
    add $t2, $zero, $zero
    addi $t3, $zero, 0xa5

    la $t1, new_immediate    # t1 = &(new_instruction)
    lw $t0, 0($t1)  # t0 = new_instruction
    la $t1, smc_immediate_gap10 # t1 = &(old_instruction)
    
    sw $t0, 0($t1)  # *(old_instruction) = new_insrtuction

    #gap 
    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2

    #old instruction   
smc_immediate_gap10:
    addi $t1, $t2, 0x5


    beq $t1, $t3, fill_immediate_gap4 # if t1 == 0xa5 (modification is successful) 
                                        # then continue test with another gaps
                                        # else print fail message
    
    la $a0, fail_msg_immediate_gap10 # a0 = &(fail_message) (argument for printing) 
    jal fail
    #continue testing another gap
#-----------------------------------------------

#gap with 4 instructions
fill_immediate_gap4:

    #modificate
    la $t1, smc_immediate_gap4 
    sw $t0, 0($t1)

    #gap
    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2

    #old instruction
smc_immediate_gap4:
    addi $t1, $t2, 0x5

    #check modification
    beq $t1, $t3, fill_immediate_gap3    
   
    la $a0, fail_msg_immediate_gap4 
    jal fail
#------------------------------------------------
#gap with 3 instructions
fill_immediate_gap3:
    la $t1, smc_immediate_gap3

    sw $t0, 0($t1)


    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2


smc_immediate_gap3:
    addi $t1, $t2, 0x5

    #check modification
    beq $t1, $t3, fill_immediate_gap2 

    la $a0, fail_msg_immediate_gap3 
    jal fail
#-------------------------------------------------
#gap with 2 instructions
fill_immediate_gap2:
    la $t1, smc_immediate_gap2

    sw $t0, 0($t1)


    add $s0, $s1, $s2
    add $s0, $s1, $s2


smc_immediate_gap2:
    addi $t1, $t2, 0x5

    beq $t1, $t3, fill_immediate_gap1 
   
    
    la $a0, fail_msg_immediate_gap2 
    jal fail
#--------------------------------------------------
#gap with 1 instruction
fill_immediate_gap1:
    la $t1, smc_immediate_gap1

    sw $t0, 0($t1)


    add $s0, $s1, $s2


smc_immediate_gap1:
    addi $t1, $t2, 0x5

    beq $t1, $t3, fill_immediate_gap0 

    la $a0, fail_msg_immediate_gap1
    jal fail
#----------------------------------------------------
#gap with 0 instruction
fill_immediate_gap0:
    
    la $t1, smc_immediate_gap0

    sw $t0, 0($t1)

smc_immediate_gap0:
    addi $t1, $t2, 0x5

    beq $t1, $t3, fill_register_gap10 

    la $a0, fail_msg_immediate_gap0 
    jal fail
#---------------------------------------------------
#
#---------------------------------------------------

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

#---------------------------------------------------
#   test modification of register
#   the concept the same as for previous modification
#---------------------------------------------------

fill_register_gap10:

    #initialize t4 = 0x5 for checking modification
    add $t4, $zero, 0x5

    la $t1, new_register
    lw $t0, 0($t1)
    la $t1, smc_register_gap10

    sw $t0, 0($t1)

    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2

    #expected instruction: addi $t3, $t1, 0x5
smc_register_gap10:
    addi $t1, $t2, 0x5

    
    #check modification
    sub $t3, $t3, $t1 # t3 = t3 - t1 (expected: t3 = 0x5)
    beq $t3, $t4, fill_register_gap4 # if (t3 == 0x5) test next
    
    la $a0, fail_msg_register_gap10
    jal fail
#-----------------------------------------------
fill_register_gap4:
    la $t1, smc_register_gap4

    sw $t0, 0($t1)


    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2

    #expected instruction: addi $t3, $t1, 0x5
smc_register_gap4:
    addi $t1, $t2, 0x5
    
    sub $t3, $t3, $t1 # t3 = t3 - t1 (expected: t3 = 0x5)
    beq $t3, $t4, fill_register_gap3 # if (t3 == 0x5) test next

    la $a0, fail_msg_register_gap4
    jal fail
#------------------------------------------------
fill_register_gap3:
    la $t1, smc_register_gap3

    sw $t0, 0($t1)


    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2

    #expected instruction: addi $t3, $t1, 0x5
smc_register_gap3:
    addi $t1, $t2, 0x5

    sub $t3, $t3, $t1 # t3 = t3 - t1 (expected: t3 = 0x5)
    beq $t3, $t4, fill_register_gap2 # if (t3 == 0x5) test next

    la $a0, fail_msg_register_gap3
    jal fail
#-------------------------------------------------
fill_register_gap2:
    la $t1, smc_register_gap2

    sw $t0, 0($t1)


    add $s0, $s1, $s2
    add $s0, $s1, $s2

    #expected instruction: addi $t3, $t1, 0x5
smc_register_gap2:
    addi $t1, $t2, 0x5

    sub $t3, $t3, $t1 # t3 = t3 - t1 (expected: t3 = 0x5)
    beq $t3, $t4, fill_register_gap1 # if (t3 == 0x5) test next

    la $a0, fail_msg_register_gap2
    jal fail
#--------------------------------------------------
fill_register_gap1:
    la $t1, smc_register_gap1

    sw $t0, 0($t1)


    add $s0, $s1, $s2

    #expected instruction: addi $t3, $t1, 0x5
smc_register_gap1:
    addi $t1, $t2, 0x5

    sub $t3, $t3, $t1 # t3 = t3 - t1 (expected: t3 = 0x5)
    beq $t3, $t4, fill_register_gap0 # if (t3 == 0x5) test next

    la $a0, fail_msg_register_gap1
    jal fail
#----------------------------------------------------
fill_register_gap0:
    
    la $t1, smc_register_gap0

    sw $t0, 0($t1)
    #expected instruction: addi $t3, $t1, 0x5
smc_register_gap0:
    addi $t1, $t2, 0x5

    sub $t3, $t3, $t1 # t3 = t3 - t1 (expected: t3 = 0x5)
    beq $t3, $t4, fill_opcode_gap10 # if (t3 == 0x5) test next

    la $a0, fail_msg_register_gap0
    jal fail

#---------------------------------------------------
#
#---------------------------------------------------

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

#---------------------------------------------------
#   test modification of opcode
#---------------------------------------------------

fill_opcode_gap10:

    #initialize t2 = 0x5 for checking modification
    addi $t2, $zero, 0x5

    la $t1, new_opcode
    lw $t0, 0($t1)
    la $t1, smc_opcode_gap10

    sw $t0, 0($t1)

    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2

    #expected instruction: sub $t1, $t2, $t2 (t1 = t2 - t2 = 0)
smc_opcode_gap10:
    add $t1, $t2, $t2

    beq $t1, $zero, fill_opcode_gap4

    la $a0, fail_msg_opcode_gap10
    jal fail
#-----------------------------------------------
fill_opcode_gap4:
    la $t1, smc_opcode_gap4

    sw $t0, 0($t1)


    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2

    #expected instruction: sub $t1, $t2, $t2 (t1 = t2 - t2 = 0)
smc_opcode_gap4:
    add $t1, $t2, $t2
    
    beq $t1, $zero, fill_opcode_gap3

    la $a0, fail_msg_opcode_gap4
    jal fail
#------------------------------------------------
fill_opcode_gap3:
    la $t1, smc_opcode_gap3

    sw $t0, 0($t1)


    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2

    #expected instruction: sub $t1, $t2, $t2 (t1 = t2 - t2 = 0)
smc_opcode_gap3:
    add $t1, $t2, $t2

    beq $t1, $zero, fill_opcode_gap2

    la $a0, fail_msg_opcode_gap3
    jal fail
#-------------------------------------------------
fill_opcode_gap2:
    la $t1, smc_opcode_gap2

    sw $t0, 0($t1)


    add $s0, $s1, $s2
    add $s0, $s1, $s2

    #expected instruction: sub $t1, $t2, $t2 (t1 = t2 - t2 = 0)
smc_opcode_gap2:
    add $t1, $t2, $t2

    beq $t1, $zero, fill_opcode_gap1

    la $a0, fail_msg_opcode_gap2
    jal fail
#--------------------------------------------------
fill_opcode_gap1:
    la $t1, smc_opcode_gap1

    sw $t0, 0($t1)


    add $s0, $s1, $s2

    #expected instruction: sub $t1, $t2, $t2 (t1 = t2 - t2 = 0)
smc_opcode_gap1:
    add $t1, $t2, $t2

    beq $t1, $zero, fill_opcode_gap0

    la $a0, fail_msg_opcode_gap1
    jal fail
#----------------------------------------------------
fill_opcode_gap0:
    
    la $t1, smc_opcode_gap0

    sw $t0, 0($t1)

    #expected instruction: sub $t1, $t2, $t2 (t1 = t2 - t2 = 0)
smc_opcode_gap0:
    add $t1, $t2, $t2

    beq $t1, $zero, fill_branch_gap10

    la $a0, fail_msg_opcode_gap0
    jal fail
    
    j fill_branch_gap10
#----------------------------------------------------
#
#----------------------------------------------------

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

#new branches
#they pointed to the next test with another gap
#so if modification will be successful, then testing go futher without printing fail message
new_target_gap10:
    j fill_branch_gap4
new_target_gap4:
    j fill_branch_gap3
new_target_gap3:
    j fill_branch_gap2
new_target_gap2:
    j fill_branch_gap1
new_target_gap1:
    j fill_branch_gap0
new_target_gap0:
    j exit

#---------------------------------------------------
#   test modification of branch
#---------------------------------------------------

fill_branch_gap10:

    # load jump with new target at modifiable section
    la $t1, new_target_gap10 
    lw $t0, 0($t1)
    la $t1, smc_branch_gap10

    sw $t0, 0($t1)

    #gap
    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2

#modifiable code
#--------------
smc_branch_gap10:
    j next_gap10
#--------------

# if it modification haven't been successful, then print fail message
# else go to the next section with another gap

next_gap10:

    la $a0, fail_msg_branch_gap10   
    jal fail
#-----------------------------------------------

fill_branch_gap4:
    la $t1, new_target_gap4
    lw $t0, 0($t1)
    la $t1, smc_branch_gap4

    sw $t0, 0($t1)


    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2


smc_branch_gap4:
    j next_gap4

next_gap4:

    la $a0, fail_msg_branch_gap4  
    jal fail
#------------------------------------------------
fill_branch_gap3:
    la $t1, new_target_gap3
    lw $t0, 0($t1)
    la $t1, smc_branch_gap3

    sw $t0, 0($t1)


    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2


smc_branch_gap3:
    j next_gap3

next_gap3:

    la $a0, fail_msg_branch_gap3 
    jal fail
#-------------------------------------------------
fill_branch_gap2:
    la $t1, new_target_gap2
    lw $t0, 0($t1)
    la $t1, smc_branch_gap2

    sw $t0, 0($t1)


    add $s0, $s1, $s2
    add $s0, $s1, $s2


smc_branch_gap2:
    j next_gap2

next_gap2:

    la $a0, fail_msg_branch_gap2 
    jal fail
#--------------------------------------------------
fill_branch_gap1:
    la $t1, new_target_gap1
    lw $t0, 0($t1)
    la $t1, smc_branch_gap1

    sw $t0, 0($t1)


    add $s0, $s1, $s2


smc_branch_gap1:
    j next_gap1

next_gap1:

    la $a0, fail_msg_branch_gap1 
    jal fail
#----------------------------------------------------
fill_branch_gap0:
    la $t1, new_target_gap0
    lw $t0, 0($t1)
    la $t1, smc_branch_gap0

    sw $t0, 0($t1)

smc_branch_gap0:
    j next_gap0

next_gap0:

    la $a0, fail_msg_branch_gap0 
    jal fail


#----------------------------------------------------

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


exit:
    
    li $v0, 10	# syscall 10 (exit)
    syscall

