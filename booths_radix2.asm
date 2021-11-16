#  COA PROJECT Group A4
#  Course: EC3060D Computer Organization and Architecture
#  Description: 	 
# Algorithm - This program multiplies two integers using radix 2 booth algorithm	 
########################################################### 

# Register Contents	:

# $s0 = loop counter
# $s1 = Q (multiplier) 
# $s2 = M (multiplicand)
# $s3 = A --> holds the results from each step in the algorithm
# $s4 = V --> holds the overflow from U, when right-shift
# $s5 = Q-1 --> holds the least significant bit from X before each right-shift
# $s6 = N --> an extra bit to the left of U to perform multiplication
# 	      when multiplicand is the largest negative number




# data segment
	.data

multiplicand:		.asciiz "\nPlease enter the multiplicand: "
multiplier:		.asciiz "\nPlease enter the multiplier: "

#instruction for the four cases in booth algorithm

instruction_for_00:		.asciiz "00, nop shift"
instruction_for_01:		.asciiz "01, add shift"
instruction_for_10:		.asciiz "10, subtract shift"
instruction_for_11:		.asciiz "11, nop shift"
result_in_decimal:		 .asciiz "\n\nResult in decimal : "
result_in_binary:		 .asciiz "\n\nResult in binary : "
counter:		         .asciiz "\nStep="
tab:			         .asciiz "\t"
N:				.asciiz "N="
A:				.asciiz "A="
V:				.asciiz "V="
Q:				.asciiz "Q="
M:				.asciiz "M="
Q_1:			        .asciiz "Q-1="



# 	Syscalls

sys_print_int:			.word 1
sys_print_binary:		.word 35
sys_print_string:		.word 4
sys_read_int:			.word 5
sys_exit:			.word 10


#text segment 
	.text
	.globl main


# main


main:
	# initialize values  counter = 0, A=0, V=0, Q-1=0, N=0
	addi $s0, $zero, 0
	addi $s3, $zero, 0
	addi $s4, $zero, 0
	addi $s5, $zero, 0
	addi $s6, $zero, 0

	# prompt for multiplier
	li   $v0, 4
	la   $a0, multiplier
	syscall                     

	# get integer value into $s1
	li   $v0, 5
	syscall
	add  $s1, $zero, $v0

	# prompt for multiplicand
	li   $v0, 4
	la   $a0, multiplicand
	syscall

	# get integer value into $s2
	li   $v0, 5
	syscall
	add  $s2, $zero, $v0


#looping part of the algorithm

check_and_loop:

	# check for the counter
	beq  $s0, 33, exit              #if s0==33 , goto exit

	# print counter message
	li   $v0, 4
	la   $a0, counter
	syscall

	# print counter value
	li   $v0, 1
	add  $a0, $zero, $s0
	syscall
	
	#print tab
	li   $v0, 4
	la   $a0, tab
	syscall

	# print N meassage
	li   $v0, 4
	la   $a0, N
	syscall

	# print N value
	li   $v0, 1
	add  $a0, $zero, $s6
	syscall
	
	#print tab
	li   $v0, 4
	la   $a0, tab
	syscall

	# print A message
	li   $v0, 4
	la   $a0, A
	syscall

	# print A value
	li   $v0, 35
	add  $a0, $zero, $s3
	syscall
	
	#print tab
	li   $v0, 4
	la   $a0, tab
	syscall

	# print V message
	li   $v0, 4
	la   $a0, V
	syscall

	# print V value
	li   $v0, 35
	add  $a0, $zero, $s4
	syscall
	
	#print tab
	li   $v0, 4
	la   $a0, tab
	syscall

	# print Q message
	li   $v0, 4
	la   $a0, Q
	syscall

	# print Q value
	li   $v0, 35
	add  $a0, $zero, $s1
	syscall
	
	#print tab
	li   $v0, 4
	la   $a0, tab
	syscall

	# print Q_1 message
	li   $v0, 4
	la   $a0, Q_1
	syscall

	# print Q-1 value
	li   $v0, 1
	add  $a0, $zero, $s5
	syscall
	
	#print tab
	li   $v0, 4
	la   $a0, tab
	syscall


#	check the values of Q-1 and lsb of Q  and branch according to them

	
	andi $t0, $s1, 1		# $t0 = LSB of Q
	beq  $t0, $zero, lsb_q_0	# if ($t0 == 0) then goto lsb_q_0
	j    lsb_q_1			# if ($t1 == 1) then goto lsb_q_1

lsb_q_0: 				# when the LSB of Q = 0
	beq  $s5, $zero, case_00	# if (Q-1 == 0) then goto case_00
	j    case_01			# if (Q-1 == 1) then goto case_01

lsb_q_1:				# when the LSB of Q = 1
	beq  $s5, $zero, case_10	# if (Q-1 == 0) then goto case_10
	j    case_11			# if (Q-1 == 1) then goto case_11

case_00:
	# print instruction about case00 message
	li   $v0, 4
	la   $a0, instruction_for_00
	syscall
	
	# shifting
	andi $t0, $s3, 1		# LSB of A for overflow checking
	bne  $t0, $zero, overflow	# if LSB of A not zero, goto overflow, i.e. A overflows
	srl  $s4, $s4, 1		# shift right logical V by 1-bit
	j    shift			# goto shift other variables

case_01:
	# print instruction about case01 message
	li   $v0, 4
	la   $a0, instruction_for_01
	syscall

	# check for special case ie multiplier is the largest negative number
	beq  $s2, -2147483648, do_special_add

	# do addition and shifting
	add  $s3, $s3, $s2		# add M to A
	andi $s5, $s5, 0		# Q=0, so next time Q-1=0
	andi $t0, $s3, 1		# LSB of A for overflow checking
	bne  $t0, $zero, overflow	# if LSB of A not zero, goto overflow, i.e. A overflows
	srl  $s4, $s4, 1		# shift right logical V by 1-bit
	j    shift			# goto shift other variables

case_10:
	# print instruction about case10 message
	li   $v0, 4
	la   $a0, instruction_for_10
	syscall
	
	# check for special case ie multiplier is the largest negative number
	beq  $s2, -2147483648, do_special_sub

	# do subtract and shifting
	sub  $s3, $s3, $s2		# sub M from A
	ori  $s5, $s5, 1		# Q=1, so next time Q-1=1
	andi $t0, $s3, 1		# LSB of A for overflow checking
	bne  $t0, $zero, overflow	# if LSB of A not zero, goto overflow, i.e. A overflows
	srl  $s4, $s4, 1		# shift right logical V by 1-bit
	j    shift			# goto shift other variables

case_11:
	# print info about action
	li   $v0, 4
	la   $a0, instruction_for_11
	syscall
	
	# shifting
	andi $t0, $s3, 1		# LSB of A for overflow checking
	bne  $t0, $zero, overflow	# if LSB of A not zero, goto overflow
	srl  $s4, $s4, 1		# shift right logical V by 1-bit
	j    shift 			# goto shift 

overflow:
	andi $t0, $s4, 0x80000000	# What is the MSB of V?
	bne  $t0, $zero, v_msb_1	# If MSB == 1, goto v_msb_1
	srl  $s4, $s4, 1		# MSB == 0, so first shift right logical V by 1-bit
	ori  $s4, $s4, 0x80000000	# then make MSB of V = 1
	j    shift			# goto shift other variables

v_msb_1:
	srl  $s4, $s4, 1		# shift right logical V by 1-bit
	ori  $s4, $s4, 0x80000000	# MSB 0f V = 1
	j    shift			# goto shift 

shift:
	sra  $s3, $s3, 1		# shift right arithmetic A by 1-bit
	ror  $s1, $s1, 1		# rotate right Q by 1-bit
	addi $s0, $s0, 1		# increment loop counter
	beq  $s0, 32, save		# if it is last step, save the contents of the regs for result
	j    check_and_loop		# loop again

save:
	add  $t1, $zero, $s3		# save A in $t1
	add  $t2, $zero, $s4		# save V in $t2
	j   check_and_loop		# loop again	


#	special case ie multiplicand is the largest negative integer


do_special_sub:				# to ignore overflow on A by adding variable N as MSB of A
	subu $s3, $s3, $s2		# sub M from A
	andi $s6, $s6, 0		# set N=0
	ori  $s5, $s5, 1		# Q=1, so next time Q-1=1
	andi $t0, $s3, 1		# LSB of A for overflow checking
	bne  $t0, $zero, overflow	# if LSB of A not zero, goto overflow, i.e. A overflows
	srl  $s4, $s4, 1		# shift right logical V by 1-bit
	j    shift_special		# goto shift_special, we gotta check N for updating A

do_special_add:				# to ignore overflow on A by adding variable N as MSB of A
	addu $s3, $s3, $s2		# add M to A
	ori  $s6, $s6, 1		# set N=1
	andi $s5, $s5, 0		# Q=0, so next time Q-1=0
	andi $t0, $s3, 1		# LSB of A for overflow checking
	bne  $t0, $zero, overflow	# if LSB of A not zero, goto overflow, i.e. A overflows
	srl  $s4, $s4, 1		# shift right logical V by 1-bit
	j    shift_special		# goto shift_special, we gotta check N for updating A
	
	
shift_special:
	beq  $s6, $zero, n_0	        # if (N==0) then goto n_0
	sra  $s3, $s3, 1		# shift right arithmetic A by 1-bit
	ror  $s1, $s1, 1		# rotate right Q by 1-bit
	addi $s0, $s0, 1		# increment loop counter
	beq  $s0, 32, save		# if it is last step, save the contents of the regs for result
	j    check_and_loop		# loop again

n_0:
	srl  $s3, $s3, 1		# shift right logic A by 1-bit, because N=0
	ror  $s1, $s1, 1		# rotate right Q by 1-bit
	addi $s0, $s0, 1		# increment loop counter
	beq  $s0, 32, save		# if it is last step, save the contents of the regs for result
	j    check_and_loop		# loop again


# print result and exit	

exit:
	# print result message
	li   $v0, 4
	la   $a0, result_in_decimal
	syscall
	
	#print result value in decimal
	li   $v0, 1
	add  $a0, $zero, $t2
	syscall
	
	# print result message
	li   $v0, 4
	la   $a0, result_in_binary
	syscall

	#print result value in 64 bit binary 
	# print A value
	li   $v0, 35
	add  $a0, $zero, $t1
	syscall
	
	# print V value
	li   $v0, 35
	add  $a0, $zero, $t2
	syscall
	
	# Exit
	li   $v0, 10
	syscall
