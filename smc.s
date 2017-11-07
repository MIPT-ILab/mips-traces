# Copyright (C) 2017 Yarovoy Danil
# this program is free software
.globl __start

.data
fm:	.asciiz "Failed test\n"

.text


__start: 

    j main

#instructions that we want to get after modification
new1:
    add $t1, $t2, 0xa5
new2:
    add $t3, $t1, 0x5
new3:
    sub $t1, $t2, $t2
#print fail message
fail:	
    li $v0, 4	# syscall 4 (print_str)
	la $a0, fm
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
fill1_10:

    
    la $t1, new1    # t1 = &(new_instruction)
    lw $t0, 0($t1)  # t0 = new_instruction
    la $t1, smc1_10 # t1 = &(old_instruction)
    
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
smc1_10:
    add $t1, $t2, 0x5

    #check modification. if wasn't  modificated then print fail message  
    la $s2, smc1_10 # s2 = &(modificated_instruction)
    lw $s2, 0($s2)  # s2 = modificated_instruction
    beq $t0, $s2, fill1_4 # if new_insrtuction == modificated_instruction 
                          # then continue test with another gaps
                          # else print fail message
    jal fail
    #continue testing another gap
#-----------------------------------------------

#gap with 4 instructions
fill1_4:

    #modificate
    la $t1, smc1_4 
    sw $t0, 0($t1)

    #gap
    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2

    #old instruction
smc1_4:
    add $t1, $t2, 0x5

    #check modification
    la $s2, smc1_4
    lw $s2, 0($s2)
    beq $t0, $s2, fill1_3
    jal fail
#------------------------------------------------
#gap with 3 instructions
fill1_3:
    la $t1, smc1_3

    sw $t0, 0($t1)


    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2


smc1_3:
    add $t1, $t2, 0x5

    #check modification
    la $s2, smc1_3
    lw $s2, 0($s2)
    beq $t0, $s2, fill1_2
    jal fail
#-------------------------------------------------
#gap with 2 instructions
fill1_2:
    la $t1, smc1_2

    sw $t0, 0($t1)


    add $s0, $s1, $s2
    add $s0, $s1, $s2


smc1_2:
    add $t1, $t2, 0x5

    la $s2, smc1_2
    lw $s2, 0($s2)
    beq $t0, $s2, fill1_1
    jal fail
#--------------------------------------------------
#gap with 1 instruction
fill1_1:
    la $t1, smc1_1

    sw $t0, 0($t1)


    add $s0, $s1, $s2


smc1_1:
    add $t1, $t2, 0x5

    la $s2, smc1_1
    lw $s2, 0($s2)
    beq $t0, $s2, fill1_0
    jal fail
#----------------------------------------------------
#gap with 0 instruction
fill1_0:
    
    la $t1, smc1_0

    sw $t0, 0($t1)

smc1_0:
    add $t1, $t2, 0x5

    la $s2, smc1_0
    lw $s2, 0($s2)
    beq $t0, $s2, fill2_10
    jal fail
#---------------------------------------------------
#
#---------------------------------------------------

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

#---------------------------------------------------
#   test modification of register
#   the concept the same as for previous modification
#---------------------------------------------------

fill2_10:

    la $t1, new2
    lw $t0, 0($t1)
    la $t1, smc2_10

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

    
smc2_10:
    add $t1, $t2, 0x5

    #check modification
    la $s2, smc2_10
    lw $s2, 0($s2)
    beq $t0, $s2, fill2_4
    jal fail
#-----------------------------------------------
fill2_4:
    la $t1, smc2_4

    sw $t0, 0($t1)


    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2


smc2_4:
    add $t1, $t2, 0x5

    la $s2, smc2_4
    lw $s2, 0($s2)
    beq $t0, $s2, fill2_3
    jal fail
#------------------------------------------------
fill2_3:
    la $t1, smc2_3

    sw $t0, 0($t1)


    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2


smc2_3:
    add $t1, $t2, 0x5

    la $s2, smc2_3
    lw $s2, 0($s2)
    beq $t0, $s2, fill2_2
    jal fail
#-------------------------------------------------
fill2_2:
    la $t1, smc2_2

    sw $t0, 0($t1)


    add $s0, $s1, $s2
    add $s0, $s1, $s2


smc2_2:
    add $t1, $t2, 0x5

    la $s2, smc2_2
    lw $s2, 0($s2)
    beq $t0, $s2, fill2_1
    jal fail
#--------------------------------------------------
fill2_1:
    la $t1, smc2_1

    sw $t0, 0($t1)


    add $s0, $s1, $s2


smc2_1:
    add $t1, $t2, 0x5

    la $s2, smc2_1
    lw $s2, 0($s2)
    beq $t0, $s2, fill2_0
    jal fail
#----------------------------------------------------
fill2_0:
    
    la $t1, smc2_0

    sw $t0, 0($t1)

smc2_0:
    add $t1, $t2, 0x5

    la $s2, smc2_0
    lw $s2, 0($s2)
    beq $t0, $s2, fill3_10
    jal fail

#---------------------------------------------------
#
#---------------------------------------------------

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

#---------------------------------------------------
#   test modification of opcode
#---------------------------------------------------

fill3_10:

    la $t1, new3
    lw $t0, 0($t1)
    la $t1, smc3_10

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

    
smc3_10:
    add $t1, $t2, $t2

    #check modification
    la $s2, smc3_10
    lw $s2, 0($s2)
    beq $t0, $s2, fill3_4
    jal fail
#-----------------------------------------------
fill3_4:
    la $t1, smc3_4

    sw $t0, 0($t1)


    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2


smc3_4:
    add $t1, $t2, $t2

    la $s2, smc3_4
    lw $s2, 0($s2)
    beq $t0, $s2, fill3_3
    jal fail
#------------------------------------------------
fill3_3:
    la $t1, smc3_3

    sw $t0, 0($t1)


    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2


smc3_3:
    add $t1, $t2, $t2

    la $s2, smc3_3
    lw $s2, 0($s2)
    beq $t0, $s2, fill3_2
    jal fail
#-------------------------------------------------
fill3_2:
    la $t1, smc3_2

    sw $t0, 0($t1)


    add $s0, $s1, $s2
    add $s0, $s1, $s2


smc3_2:
    add $t1, $t2, $t2

    la $s2, smc3_2
    lw $s2, 0($s2)
    beq $t0, $s2, fill3_1
    jal fail
#--------------------------------------------------
fill3_1:
    la $t1, smc3_1

    sw $t0, 0($t1)


    add $s0, $s1, $s2


smc3_1:
    add $t1, $t2, $t2

    la $s2, smc3_1
    lw $s2, 0($s2)
    beq $t0, $s2, fill3_0
    jal fail
#----------------------------------------------------
fill3_0:
    
    la $t1, smc3_0

    sw $t0, 0($t1)

smc3_0:
    add $t1, $t2, $t2

    la $s2, smc3_0
    lw $s2, 0($s2)
    beq $t0, $s2, fill4_10
    jal fail
    
    j fill4_10
#----------------------------------------------------
#
#----------------------------------------------------

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

#new branches
#they pointed to the next test with another gap
#so if modification will be successful, then testing go futher without printing fail message
new4_10:
    j fill4_4
new4_4:
    j fill4_3
new4_3:
    j fill4_2
new4_2:
    j fill4_1
new4_1:
    j fill4_0
new4_0:
    j end

#---------------------------------------------------
#   test modification of branch
#---------------------------------------------------

fill4_10:

    # load jump with new target at modifiable section
    la $t1, new4_10 
    lw $t0, 0($t1)
    la $t1, smc4_10

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
smc4_10:
    j next1
#--------------

# if it modification haven't been successful, then print fail message
# else go to the next section with another gap

next1:
    la $s2, smc4_10
    lw $s2, 0($s2)
    beq $t0, $s2, fill4_4
    jal fail
#-----------------------------------------------

fill4_4:
    la $t1, new4_4
    lw $t0, 0($t1)
    la $t1, smc4_4

    sw $t0, 0($t1)


    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2


smc4_4:
    j next2

next2:
    la $s2, smc4_4
    lw $s2, 0($s2)
    beq $t0, $s2, fill4_3
    jal fail
#------------------------------------------------
fill4_3:
    la $t1, new4_3
    lw $t0, 0($t1)
    la $t1, smc4_3

    sw $t0, 0($t1)


    add $s0, $s1, $s2
    add $s0, $s1, $s2
    add $s0, $s1, $s2


smc4_3:
    j next3

next3:
    la $s2, smc4_3
    lw $s2, 0($s2)
    beq $t0, $s2, fill4_2
    jal fail
#-------------------------------------------------
fill4_2:
    la $t1, new4_2
    lw $t0, 0($t1)
    la $t1, smc4_2

    sw $t0, 0($t1)


    add $s0, $s1, $s2
    add $s0, $s1, $s2


smc4_2:
    j next4

next4:
    la $s2, smc4_2
    lw $s2, 0($s2)
    beq $t0, $s2, fill4_1
    jal fail
#--------------------------------------------------
fill4_1:
    la $t1, new4_1
    lw $t0, 0($t1)
    la $t1, smc4_1

    sw $t0, 0($t1)


    add $s0, $s1, $s2


smc4_1:
    j next5

next5:
    la $s2, smc4_1
    lw $s2, 0($s2)
    beq $t0, $s2, fill4_0
    jal fail
#----------------------------------------------------
fill4_0:
    la $t1, new4_0
    lw $t0, 0($t1)
    la $t1, smc4_0

    sw $t0, 0($t1)

smc4_0:
    j next6

next6:
    la $s2, smc4_0
    lw $s2, 0($s2)
    beq $t0, $s2, exit
    jal fail


#----------------------------------------------------

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


exit:
    nop

