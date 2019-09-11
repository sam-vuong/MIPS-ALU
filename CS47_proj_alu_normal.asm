.include "./cs47_proj_macro.asm"
.text
.globl au_normal
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_normal
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_normal:
# TBD: Complete it
	# RTE store
	addi $sp, $sp, -12
	sw $fp, 12($sp)
	sw $ra, 8($sp)
	addi $fp, $sp, 12
	# Check operation
	beq $a2, 0x2B, normal_add
	beq $a2, 0x2D, normal_sub
	beq $a2, 0x2A, normal_mult
	beq $a2, 0x2F, normal_div
normal_add:
	add $v0, $a0, $a1
	j normal_end
normal_sub:
	sub $v0, $a0, $a1
	j normal_end
normal_mult:
	mult $a0, $a1
	mflo $v0
	mfhi $v1
	j normal_end
normal_div:
	div $a0, $a1
	mflo $v0
	mfhi $v1
	j normal_end
normal_end:
	# Restore RTE
	lw $fp, 12($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	# Return to caller
	jr $ra
	
	
