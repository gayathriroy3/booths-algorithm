
#  Description: 	 
# This program perform booths algorithm for radix 4. 	 
###########################################################

# Register Contents	:

# $s0 = loop counter
# $s1 = Q (multiplier) 
# $s2 = M (multiplicand)
# $s3 = A --> holds the results from each step in the algorithm
# $s4 = V --> holds the overflow from U, when right-shift
# $s5 = Q-1 --> holds the least significant bit from X before each right-shift

 
#data declarations: declare variable names used in program
                          .data 
#enter multiplicand and multiplier

Multiplicand:   .asciiz "Please enter the multiplicand: "
Multiplier:     .asciiz "Please enter the multiplier: "

#instruction for the eight cases in booth algorithm radix 4

instruction_for_000:		.asciiz "000 , no action"
instruction_for_001:		.asciiz "001 , add multiplicand"
instruction_for_010:		.asciiz "010 , add multiplicand"
instruction_for_011:		.asciiz "011 , add multiplicand left shifted by 1 bit "
instruction_for_100:		.asciiz "100 , add 2s complement of multiplicand left shifted by 1 bit"
instruction_for_101:		.asciiz "101 , add 2s complement of multiplicand"
instruction_for_110:		.asciiz "110 ,add 2s complement of multiplicand"
instruction_for_111:		.asciiz "111 , no action"

Result_in_decimal:		.asciiz "\nResult in decimal"
Result_in_binary:		.asciiz "\nResult in binary"
steps:		                .asciiz "\nStep="
N:				.asciiz "N="
A:				.asciiz "A="
V:				.asciiz "V="
Q:				.asciiz "Q="  #multiplier
M:				.asciiz "M="  #multiplicand
Q_1:			        .asciiz "Q-1="
tab:			        .asciiz "\t"


# 	Syscalls for reference

sys_print_int:			.word 1
sys_print_binary:		.word 35
sys_print_string:		.word 4
sys_read_int:			.word 5
sys_exit:			.word 10

 



# text segment 
	.text
	.globl main

main:                                                # initialize steps= 0, A=0, V=0, Q-1=0
	addi $s0, $zero, 0                           # s0 for steps
	addi $s7,$zero,0                             #shifting purpose at each stage
	addi $s3, $zero, 0                           # s3 for A - each step's result in the algorithm
	addi $s4, $zero, 0                           # s4 for V -overflow from U, when right-shift
	addi $s5, $zero, 0                           # s5 for Q-1 - least significant bit from X before each right-shift
	addi $s6, $zero, 0                           # s6 for N -extra bit to the left of U to perform multiplication when multiplicand is the largest negative number

	# print multiplier prompt
	li   $v0, 4                                  #syscall to print string
	la   $a0,Multiplier                          #load address mulitplier to a0
	syscall                                      #syscall

	# get integer value of multiplier into s1
	li   $v0, 5                                  #read integer
	syscall                                      #syscall
	add  $s1, $zero, $v0                         # s1 stores multiplier

        # print multiplicand prompt
	li   $v0, 4                                  #syscall to print string
	la   $a0,Multiplicand                        #load address multiplicand to a0
	syscall                                      #syscall

        # get integer value of multiplicand into $s2
	li   $v0, 5                                  #read integer
	syscall                                      #syscall
	add  $s2, $zero, $v0                         # s2 stores multiplicand

CHECK_STEP_AND_LOOP:                                 # check for the steps
	
        beq  $s0,17,EXIT                             #if s0==17, goto exit

	#step                                   
	li   $v0, 4                                  #print string                      
	la   $a0, steps                              #load steps in a0
	syscall                                      #syscall
        
        #print steps value
	li   $v0, 1                                  #print integer
	add  $a0, $zero, $s0                         #add s0 in a0
	syscall                                      #syscall
        
        #tab
	li   $v0, 4                                  #print string
	la   $a0, tab                                #load tab in a0
	syscall                                      #syscall

        #print A string
	li   $v0, 4                                  #print string      
	la   $a0, A                                  #load A in a0
	syscall                                      #syscall

	#print A value
	li   $v0, 35                                 #print binary                           
	add  $a0, $zero, $s3                         #load s3 in a0
	syscall                                      #syscall

        #tab
	li   $v0, 4                                  #print string
	la   $a0, tab                                #load tab in a0
	syscall                                      #syscall

        #print Q string
	li   $v0, 4                                  #print string
	la   $a0, Q                                  #load Q in a0
	syscall                                      #syscall

        #print Q value
	li   $v0, 35                                 #print binary                   
	add  $a0, $zero, $s1                         #add s1 to a0
	syscall                                      #syscall

	li   $v0, 4                                  #tab
	la   $a0, tab         
	syscall
        
        #print Q-1 string
        li   $v0, 4                                  #print string                              
	la   $a0, Q_1                                #load q_1 in a0
	syscall  

        #print q-1 value
	li   $v0, 35                                 #print binary
	add  $a0, $zero, $s5                         #add s5 in a0
	syscall

	li   $v0, 4                                  #tab
	la   $a0, tab         
	syscall

        and $t0,$s1,0x03                            #get last two bits
        beq $t0,0x00,lsb_00                         #goto lsb_00
        beq $t0,0x01,lsb_01                         #goto lsb_01
        beq $t0,0x02,lsb_10                         #goto lsb_10
        j lsb_11                                    #goto lsb_11

lsb_00:				        
	beq  $s5,0, CASE_000            # if (Q-1 == 0) then goto CASE_000
	j    CASE_001			# if (Q-1 == 1) then goto  CASE_001
lsb_01:				
	beq  $s5, 1, CASE_011           # if (Q-1 == 1) then goto CASE_010
	j    CASE_010			# if (Q-1 == 0) then goto  CASE_011
lsb_10:
        beq  $s5, 0, CASE_100           # if (Q-1 == 0) then goto CASE_100
	j    CASE_101			# if (Q-1 == 1) then goto  CASE_101
lsb_11:
        beq  $s5, 0, CASE_110           # if (Q-1 == 0) then goto CASE_110
        j    CASE_111			# if (Q-1 == 1) then goto  CASE_111

CASE_000:

        # print instructions for 000 case
	li   $v0, 4                      #print string
	la   $a0, instruction_for_000
	syscall
        
        li $s5,0                         #load s5 as 0
        j SHIFT                          #goto shift

CASE_001:
        # print instructions for 001 case
	li   $v0, 4
	la   $a0, instruction_for_001
	syscall
        
        
	li $t1,0                        #load t1 as 0
        add $t1,$t1,$s2                 #add s2 to t1
        
        sllv $t1,$t1,$s7                #shift left t1 by s7 bits
	add  $s3, $s3, $t1		# add M to A
        li $s5,0                        #load s5 as 0
    
        j SHIFT                         #goto shift

CASE_010:
        # print instructions for 010 case
	li   $v0, 4                      #print string
	la   $a0, instruction_for_010    
	syscall
        
        li $t1,0                         #load t1 as 0
        add $t1,$t1,$s2                  #add s2 to t1
        sllv $t1,$t1,$s7                 #shift left t1 by s7 bits
	add  $s3, $s3, $t1		 # add M to A
        li $s5,0                         #load s5 as 0
         
        j SHIFT                          #goto shift

CASE_011:
        # print instructions for 011 case
	li   $v0, 4                     #print string
	la   $a0, instruction_for_011
	syscall
        
        li $t1,0                         #load t1 as 0
        add $t1,$t1,$s2                  #add s2 to t1
        sll $t1,$t1,1                    #shift left t1 by 1 bits
        sllv $t1,$t1,$s7                 #shift left t1 by s7 bits
        add  $s3, $s3, $t1		 # add M to A
        li $s5,0                         #load s5 as 0

        j SHIFT                          #goto shift

CASE_100:
        # print instructions for 100 case
	li   $v0, 4                      #print string
	la   $a0, instruction_for_100
	syscall
        
        li $t1,0                         #load t1 as 0        
        add $t1,$t1,$s2                  #add s2 to t1
        sll $t1,$t1,1                    #shift left t1 by 1 bits
        li $t0,0                         #load t0 as 0
	sub  $t0, $t0, $t1		 # sub t1 from t0
        sllv  $t0,$t0,$s7                #shift left t0 by s7 bits
        add $s3,$s3,$t0                  # add M to A
        
        li $s5,1                         #load s5 as 1
     
        j SHIFT                          #goto shift
       
CASE_101:
        # print instructions for 101 case
	li   $v0, 4                      #print string
	la   $a0, instruction_for_101
	syscall
        
        li $t1,0                        #load t1 as 0 
        add $t1,$t1,$s2                 #add s2 to t1
        li $t0,0                        #load t0 as 0
	sub  $t0, $t0, $t1		# sub t1 from t0
        sllv  $t0,$t0,$s7               #shift left t0 by s7 bits
	add  $s3, $s3, $t0		# add M to A
        li $s5,1                        #load s5 as 1
       
        j SHIFT                         #goto shift

CASE_110:
        # print instructions for 110 case
	li   $v0, 4                     #print string
	la   $a0, instruction_for_110
	syscall
        
	li $t1,0                         #load t1 as 0 
        add $t1,$t1,$s2                  #add s2 to t1
        li $t0,0                         #load t0 as 0
	sub  $t0, $t0, $t1		 # sub t1 from t0
        sllv  $t0,$t0,$s7                #shift left t0 by s7 bits
	add  $s3, $s3, $t0		 # add M to A
        li $s5,1                         #load s5 as 1
         
        j SHIFT                          #goto shift


CASE_111:
        # print instructions for 111 case
	li   $v0, 4                      #print string
	la   $a0, instruction_for_111
	syscall
        
        li $s5,1                         #load s5 as 1
        j SHIFT                          #goto shift

SHIFT:
        
	srl $s1,$s1,2                   # right shift by 2 bits
	addi $s0, $s0, 1		# increment step
	addi $s7, $s7, 2		# increment value to shift at each stage
	beq  $s0, 16,SAVE		# if it is last step, save the contents of the regs for result
	j    CHECK_STEP_AND_LOOP        # loop again

SAVE:   
        li   $t7,0                      #load t7 as 0
        li   $t6,0                      #load t6 as 0
	add  $t7, $zero, $s3		# save U in $t1
        andi $s4,$t7,0x80000000         #check last bit of t7 and save in s4
        sra  $s4,$s4,31                 #shift right arithmetic 31 times in s4
	add  $t6, $zero, $s4		# save V (s4)  in $t6
	j    CHECK_STEP_AND_LOOP        # loop again	

EXIT:
	#print result in decimal
	li   $v0, 4                     # print string
	la   $a0, Result_in_decimal     #load result string in a0   
	syscall
	
	#print result in decimal
	li   $v0, 1                    # print interger
	add  $a0, $zero, $t7           #load result in a0
	syscall
        
        #print result in binary
	li   $v0, 4                     # print string
	la   $a0, Result_in_binary      #load result string in a0   
	syscall
	
	#print V in binary
        li $v0,35                       #print binary
        add $a0,$zero,$t6               #add t6 in a0
        syscall
        
        #print A in binary
        li $v0,35                       #print binary
        add $a0,$zero,$t7               #add t7 in a0
        syscall
	
	
	li   $v0, 10                    # syscall to exit
	syscall
