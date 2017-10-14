#include <mips/regdef.h>

##-----	toLowerCase -----##

	.align 		2
	.globl 		toLowerCase 
	.ent 		toLowerCase
toLowerCase:
	.frame		$fp,24,ra
	.set		noreorder
	.cpload		t9
	.set		reorder
	
	#Stack frame creation
	subu		sp,sp,24
	
	.cprestore 0
	sw		$fp,20(sp)
	sw		gp,16(sp)
	move		$fp,sp
	
	move		v0,a0					# word (this is the character)
	sb		v0,8($fp)
	lb		v0,8($fp)
	slt		v0,v0,65
	bne		v0,zero,$IfNotLower			# if !(word >= 65) goto IfNotLower 
	lb		v0,8($fp)
	slt		v0,v0,91
	beq		v0,zero,$IfNotLower			# if !(word <= 90) goto IfNotLower 
	lbu		v0,8($fp)
	addu		v0,v0,32				# word += 32
	sb		v0,8($fp)
$IfNotLower:
	lb		v0,8($fp)
	move		sp,$fp
	
	#Stack frame destruction.
	lw		$fp,20(sp)
	addu		sp,sp,24
	j		ra					# Jump and return
	.end		toLowerCase


