.include "./cs47_proj_macro.asm"
.text
.globl au_logical
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_logical
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_logical:
# TBD: Complete it
	# RTE store
	addi $sp, $sp, -24
	sw $fp, 24($sp)
	sw $ra, 20($sp)
	sw $s1, 16($sp)
	sw $s2, 12($sp)
	sw $s3, 8($sp)
	addi $fp, $sp 24
	# Check operation
	beq $a2, 0x2B, addition 
	beq $a2, 0x2D, subtraction
	beq $a2, 0x2A, multiplication
	beq $a2, 0x2F, division
addition:
	jal add_logical
	j end
subtraction:
	jal sub_logical
	j end
multiplication:
	jal mul_signed
	j end
division:
	jal div_signed
	j end
end:
	# Restore RTE
	lw $fp, 24($sp)
	lw $ra, 20($sp)
	lw $s1, 16($sp)
	lw $s2, 12($sp)
	lw $s3, 8($sp)
	addi $sp, $sp 24
	jr $ra
###################################################
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: Mode
# Return: 
# 	$v0: ($a0+$a1) if addition mode (0x00000000)
#	     ($a0-$a1) if subtraction mode (0xFFFFFFFF)
# 	$v1: final carryout
###################################################
add_sub_logical:
	# RTE store
	addi $sp, $sp, -36
	sw $fp, 36($sp)
	sw $ra, 32($sp)
	sw $a0, 28($sp)
	sw $a1, 24($sp)
	sw $s0, 20($sp)
	sw $s1, 16($sp)
	sw $s2, 12($sp)
	sw $s3, 8($sp)
	addi $fp, $sp, 36
	# Begin
	li $t0, 0 # holds bit from first number
	li $t1, 0 # holds bit from second number
	li $t2, 0 # holds $t0 XOR $t1
	li $t3, 0 # holds sum bit
	li $t4, 0 # holds maskReg
	li $t5, 0 # holds first number
	li $t6, 0 # holds second number
	add $s0, $zero, $zero # sum
	add $s1, $zero, $zero # index
	add $s2, $zero, $zero # will contain 0 or 1 depending on mode
	extract_nth_bit($s2, $a2, $s1) # Extract MSB from second number
	beqz $s2, add_routine # after inversion, if necessary, goes into add_routine regardless
	invert_bit_pattern($a1, $t7) # Subtraction, so invert second number
	addi $a1, $a1, 1 # Add 1 to obtain final inverted bit pattern
	li $s2, 0 # Reset $s2, have already used it to determine addition/subtraction
add_routine:
	move $t5, $a0 # Reset value of first number after each iteration
	move $t6, $a1 # Reset value of second number after each iteration
	extract_nth_bit($t0, $t5, $s1) # extract bit from first number at index
	extract_nth_bit($t1, $t6, $s1) # extract bit from second number at index
	xor $t2, $t0, $t1 # $t2 contains t0 XOR t1
	xor $s3, $t2, $s2 # s3 contains this iteration's sum bit
	and $s2, $s2, $t2
	and $t3, $t0, $t1
	or $s2, $s2, $t3 
	insert_to_nth_bit($s0, $s1, $s3, $t4) # Insert sum bit to result
	addi $s1, $s1, 1 # Increase index
	bne $s1, 32, add_routine # Loop condition
	move $v0, $s0 # Result
	move $v1, $s2 # Final carryout
	# Restore RTE
	lw $fp, 36($sp)
	lw $ra, 32($sp)
	lw $a0, 28($sp)
	lw $a1, 24($sp)
	lw $s0, 20($sp)
	lw $s1, 16($sp)
	lw $s2, 12($sp)
	lw $s3, 8($sp)
	addi $sp, $sp 36
	# Return to caller
	jr $ra
################################
add_logical:
	# RTE store
	addi $sp, $sp, -16
	sw $fp, 16($sp)
	sw $ra, 12($sp)
	sw $a2, 8($sp)
	addi $fp, $sp 16
	# Body
	add $a2, $zero, $zero
	jal add_sub_logical
	# RTE restore
	lw $fp, 16($sp)
	lw $ra, 12($sp)
	lw $a2, 8($sp)
	addi $sp, $sp 16
	jr $ra
##############################3
sub_logical:
	# RTE store
	addi $sp, $sp, -16
	sw $fp, 16($sp)
	sw $ra, 12($sp)
	sw $a2, 8($sp)
	addi $fp, $sp 16
	# Body
	li $a2, 0xFFFFFFFF # subtraction mode
	jal add_sub_logical
	# RTE restore
	lw $fp, 16($sp)
	lw $ra, 12($sp)
	lw $a2, 8($sp)
	addi $sp, $sp 16
	jr $ra
#############################
twos_complement:
	# RTE store
	addi $sp, $sp, -16
	sw $fp, 16($sp)
	sw $ra, 12($sp)
	sw $a0, 8($sp)
	addi $fp, $sp, 16
	# Body
	not $a0, $a0
	li $a1, 1
	jal add_logical # called with ~$a0 and value 1 as $a1
	# RTE restore
	lw $fp, 16($sp)
	lw $ra, 12($sp)
	lw $a0, 8($sp)
	addi $sp, $sp, 16
	# Return to caller
	jr $ra
##############################
# Obtain 2's complement only if negative; if positive, return
twos_complement_if_neg: 
	# RTE store
	addi $sp, $sp, -16
	sw $fp, 16($sp)
	sw $ra, 12($sp)
	sw $a0, 8($sp)
	addi $fp, $sp, 16
	# Body
	li $t0, 31
	li $t2, 0 # Will contain MSB of tested number
	move $t1, $a0
	extract_nth_bit($t2, $t1, $t0) # Extract MSB
	beqz $t2, twos_complement_positive
	jal twos_complement
	j twos_complement_end
twos_complement_positive:
	move $v0, $a0
twos_complement_end:
	# Restore RTE
	lw $fp, 16($sp)
	lw $ra, 12($sp)
	lw $a0, 8($sp)
	addi $sp, $sp, 16
	jr $ra
################################
# Argument $a0 = Lo; $a1 = Hi
# Returns $v0 = Lo part of 2's complemented 64 bit; $v1 = Hi part of 2's complemented 64 bit
twos_complement_64bit:
	# RTE store
	addi $sp, $sp, -32
	sw $fp, 32($sp)
	sw $ra, 28($sp)
	sw $a0, 24($sp)
	sw $a1, 20($sp)
	sw $s0, 16($sp)
	sw $s1, 12($sp)
	sw $s2, 8($sp)
	addi $fp, $sp, 32
	# Body
	not $a0, $a0
	not $a1, $a1
	move $s0, $a1
	li $a1, 1
	jal add_logical
	move $s1, $v0 # Final result for Lo part of 2's complemented 64 bit
	move $a0, $s0 # Use higher 32 bits as first number to add 
	move $a1, $v1 # Final carry out, use as second number to add
	jal add_logical
	move $s2, $v0 # Final result for Hi part of 2's complemented 64 bit
	move $v1, $s2 # Save Hi in $v1
	move $v0, $s1 # Save Lo in $v0
	# Restore RTE
	lw $fp, 32($sp)
	lw $ra, 28($sp)
	lw $a0, 24($sp)
	lw $a1, 20($sp)
	lw $s0, 16($sp)
	lw $s1, 12($sp)
	lw $s2, 8($sp)
	addi $sp, $sp, 32
	jr $ra
##################################
# Takes $a0, the bit to replicate 32 times
# Returns $v0 (either 0x00000000 or 0xFFFFFFFF)
bit_replicator:
	# RTE store
	addi $sp, $sp, -16
	sw $fp, 16($sp)
	sw $ra, 12($sp)
	sw $a0, 8($sp)
	addi $fp, $sp, 16
	# Body
	beqz $a0, bit_replicator_zero
	# Replicate '1' 32 times
	li $a0, 1
	jal twos_complement # 2's complement of 1 is 0xFFFFFFFF
	j bit_replicator_end
bit_replicator_zero:
	move $v0, $a0
bit_replicator_end:
	# RTE restore
	lw $fp, 16($sp)
	lw $ra, 12($sp)
	lw $a0, 8($sp)
	addi $sp, $sp, 16
	jr $ra
#################################
# Arguments $a0 (multiplicand) and $a1 (multiplier)
# Returns $v0 (Lo part of result) and $v1 (Hi part of result)
mul_unsigned:
	# RTE store
	addi $sp, $sp, -36
	sw $fp, 36($sp)
	sw $ra, 32($sp)
	sw $a0, 28($sp)
	sw $a1, 24($sp)
	sw $s0, 20($sp)
	sw $s1, 16($sp)
	sw $s2, 12($sp)
	sw $s3, 8($sp)
	addi $fp, $sp, 36
	# Body
	li $s0, 0 # Index
	li $s1, 0 # Final sum or Hi of product
	move $s2, $a1 # Multiplier or Lo of product
	move $s3, $a0 # Multiplicand
mul_unsigned_loop:
	beq $s0, 32, mul_unsigned_loop_end
	li $t0, 0 
	li $a0, 0 # Will contain current LSB of multiplier
	extract_nth_bit($a0, $s2, $t0) # Using $t0 first as a register indicating 0th position
	jal bit_replicator
	move $t0, $v0 # Now contains replicated bit pattern
	li $t1, 0 # Will contain bit pattern of this step
	and $t1, $s3, $t0
	move $a0, $s1 
	move $a1, $t1
	jal add_logical # Increase sum by this step's sum
	move $s1, $v0
	srl $s2, $s2, 1
	li $t2, 0 # Will contain LSB of current sum (Hi)
	extract_nth_bit($t2, $s1, $t2)
	li $t3, 31 # Contains value of 31 to be used to indicate bit position to insert to
	insert_to_nth_bit($s2, $t3, $t2, $t4)
	srl $s1, $s1, 1
	addi $s0, $s0, 1
	j mul_unsigned_loop
mul_unsigned_loop_end:
	move $v0, $s2
	move $v1, $s1
	# RTE restore
	lw $fp, 36($sp)
	lw $ra, 32($sp)
	lw $a0, 28($sp)
	lw $a1, 24($sp)
	lw $s0, 20($sp)
	lw $s1, 16($sp)
	lw $s2, 12($sp)
	lw $s3, 8($sp)
	addi $sp, $sp, 36
	jr $ra
###############################
# Takes arguments $a0 (multiplicand) and $a1 (multiplier)
# Returns $v0 (Lo part of result) and $v1 (Hi part of result)
mul_signed:
	# RTE store
	addi $sp, $sp, -36
	sw $fp, 36($sp)
	sw $ra, 32($sp)
	sw $a0, 28($sp)
	sw $a1, 24($sp)
	sw $s0, 20($sp)
	sw $s1, 16($sp)
	sw $s6, 12($sp)
	sw $s7, 8($sp)
	addi $fp, $sp, 36
	# Body
	move $s6, $a0 # Contains old multiplicand
	move $s7, $a1 # Contains old multiplier
	jal twos_complement_if_neg
	move $s0, $v0 # Will contain new multiplicand (or stay the same if non-negative)
	move $a0, $s7 # Move multiplier to $a0 before testing if negative
	jal twos_complement_if_neg
	move $s1, $v0 # Will contain new multiplier (or stay the same if non-negative)
	move $a0, $s0 # New multiplicand
	move $a1, $s1 # New multiplier
	jal mul_unsigned
	li $t0, 31 # Contains value indicating MSB
	li $t1, 0 # Will contain MSB of old multiplicand
	li $t2, 0 # Will contain MSB of old multiplier
	li $t3, 0 # Will contain sign S of result
	extract_nth_bit($t1, $s6, $t0)
	extract_nth_bit($t2, $s7, $t0)
	xor $t3, $t1, $t2 # Contains sign S of result
	beqz $t3, mul_signed_end
	move $a0, $v0
	move $a1, $v1
	jal twos_complement_64bit
mul_signed_end:
	# RTE restore
	lw $fp, 36($sp)
	lw $ra, 32($sp)
	lw $a0, 28($sp)
	lw $a1, 24($sp)
	lw $s0, 20($sp)
	lw $s1, 16($sp)
	lw $s6, 12($sp)
	lw $s7, 8($sp)
	addi $sp, $sp, 36
	jr $ra
######################################
# Arguments $a0 (dividend) and $a1 (divisor)
# Return $v0 (Quotient) and $v1 (Remainder)
div_unsigned:
	# RTE store
	addi $sp, $sp, -36
	sw $fp, 36($sp)
	sw $ra, 32($sp)
	sw $a0, 28($sp)
	sw $a1, 24($sp)
	sw $s0, 20($sp)
	sw $s1, 16($sp)
	sw $s2, 12($sp)
	sw $s3, 8($sp)
	addi $fp, $sp, 36
	# Body
	li $s0, 0 # Index
	move $s1, $a0 # Dividend
	move $s2, $a1 # Divisor
	li $s3, 0 # Remainder
div_unsigned_loop:
	beq $s0, 32, div_unsigned_loop_end
	sll $s3, $s3, 1
	li $t0, 31 # Will contain current MSB of dividend
	li $t1, 0 # Indicates 0th bit position
	move $t2, $s1 # Copy of dividend
	li $t3, 0
	extract_nth_bit($t3, $t2, $t0)
	insert_to_nth_bit($s3, $t1, $t3, $t6)
	sll $s1, $s1, 1 # Continue shifting quotient
	li $t2, 0 # Will contain subtraction result of this step
	move $a0, $s3
	move $a1, $s2
	jal sub_logical
	move $t3, $v0 # $t3 = remainder - divisor
	bltz $t3, div_unsigned_loop_next
	move $s3, $t3
	li $t3, 1
	li $t1, 0
	insert_to_nth_bit($s1, $t1, $t3, $t5)
div_unsigned_loop_next:
	addi $s0, $s0, 1
	j div_unsigned_loop
div_unsigned_loop_end:
	move $v0, $s1
	move $v1, $s3
	# RTE restore
	lw $fp, 36($sp)
	lw $ra, 32($sp)
	lw $a0, 28($sp)
	lw $a1, 24($sp)
	lw $s0, 20($sp)
	lw $s1, 16($sp)
	lw $s2, 12($sp)
	lw $s3, 8($sp)
	addi $sp, $sp, 36
	jr $ra
#####################################
# Arguments $a0 (Dividend) and $a1 (Divisor)
# Returns $v0 (Quotient) and $v1 (Remainder)
div_signed:
	# RTE store
	addi $sp, $sp, -44
	sw $fp, 44($sp)
	sw $ra, 40($sp)
	sw $a0, 36($sp)
	sw $a1, 32($sp)
	sw $s0, 28($sp)
	sw $s1, 24($sp)
	sw $s2, 20($sp)
	sw $s3, 16($sp)
	sw $s6, 12($sp)
	sw $s7, 8($sp)
	addi $fp, $sp, 44
	# Body
	move $s6, $a0 # Contains old dividend
	move $s7, $a1 # Contains old divisor
	jal twos_complement_if_neg
	move $s0, $v0 # Will contain new dividend (or stay the same if non-negative)
	move $a0, $s7 # Move divisor to $a0 before testing if negative
	jal twos_complement_if_neg
	move $s1, $v0 # Will contain new divisor (or stay the same if non-negative)
	move $a0, $s0 # New dividend
	move $a1, $s1 # New divisor
	jal div_unsigned
	move $s2, $v0 # Contains quotient
	move $s3, $v1 # Contains remainder
	li $t0, 31 # Contains value indicating MSB
	li $t1, 0 # Will contain MSB of old dividend
	li $t2, 0 # Will contain MSB of old divisor
	li $t3, 0 # Will contain sign S of result
	move $t4, $s6
	extract_nth_bit($t1, $t4, $t0)
	extract_nth_bit($t2, $s7, $t0)
	xor $t3, $t1, $t2 # Contains sign S of result
	beqz $t3, div_signed_remainder
	move $a0, $s2 
	jal twos_complement # Obtain 2's complement form of quotient
	move $s2, $v0 # Final quotient
div_signed_remainder:
	li $t0, 31
	li $t3, 0
	extract_nth_bit($t3, $s6, $t0) # Extract MSB from old dividend
	beqz $t3, div_signed_end
	move $a0, $s3 
	jal twos_complement # Obtain 2's complement form of remainder
	move $s3, $v0 # Final remainder
div_signed_end:
	move $v0, $s2
	move $v1, $s3
	# RTE restore
	lw $fp, 44($sp)
	lw $ra, 40($sp)
	lw $a0, 36($sp)
	lw $a1, 32($sp)
	lw $s0, 28($sp)
	lw $s1, 24($sp)
	lw $s2, 20($sp)
	lw $s3, 16($sp)
	lw $s6, 12($sp)
	lw $s7, 8($sp)
	addi $sp, $sp, 44
	jr $ra
###########################################
# End of list of procedures
	
	
	
	
	
	
	
	

	
	
	
	

	
	
