# Add you macro definition here - do not touch cs47_common_macro.asm"
#<------------------ MACRO DEFINITIONS ---------------------->#

	# $regD contains extracted bit, $regS contains source bit pattern, $regT contains bit position
	.macro extract_nth_bit($regD, $regS, $regT)
	srlv $regS, $regS, $regT 
	and $regD, $regS, 1
	.end_macro
	
	# $regD contains bit pattern to be modified, $regS contains bit position to insert to, $regT contains bit value to insert, $maskReg holds temp mask
	.macro insert_to_nth_bit($regD, $regS, $regT, $maskReg)
	li $maskReg, 1 # Mask
	sllv $maskReg, $maskReg, $regS
	add $t0, $zero, 0xFFFFFFFF
	xor $maskReg, $maskReg, $t0 # Invert Mask
	and $regD, $regD, $maskReg
	sllv $regT, $regT, $regS
	or $regD, $regD, $regT
	.end_macro
	
	# Inverts bit pattern given a bit pattern in $reg and a register $maskReg to hold mask
	.macro invert_bit_pattern($reg, $maskReg)
	li $maskReg, 0xFFFFFFFF
	xor $reg, $reg, $maskReg
	.end_macro
	

