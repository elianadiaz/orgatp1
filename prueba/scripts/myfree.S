#include <mips/regdef.h>
#include <sys/syscall.h>

#define MYMALLOC_SIGNATURE 0xdeadbeef


##-----	myfree -----##

	.globl	myfree
	.ent	myfree
myfree:
	subu	sp, sp, 40
	sw	ra, 32(sp)
	sw	$fp, 28(sp)
	sw	a0, 24(sp)  # Temporary: argument pointer.
	sw	a0, 20(sp)  # Temporary: actual mmap(2) pointer.
	move	$fp, sp

	# Calculate the actual mmap(2) pointer.
	#
	lw	t0, 24(sp)
	subu	t0, t0, 8
	sw	t0, 20(sp)

	# XXX Sanity check: the argument pointer must be checked
	# in before we try to release the memory block.
	#
	# First, check the allocation signature.
	#
	lw	t0, 20(sp) # t0: actual mmap(2) pointer.
	lw	t1, 0(t0)
	bne	t1, MYMALLOC_SIGNATURE, myfree_die

	# Second, check the memory block trailer.
	#
	lw	t0, 20(sp) # t0: actual mmap(2) pointer.
	lw	t1, 4(t0)  # t1: actual mmap(2) block size.
	addu	t2, t0, t1 # t2: trailer pointer.
	lw	t3, -4(t2)
	xor	t3, t3, t1
	bne	t3, MYMALLOC_SIGNATURE, myfree_die

	# All checks passed. Try to free this memory area.
	#
	li	v0, SYS_munmap
	lw	a0, 20(sp) # a0: actual mmap(2) pointer.
	lw	a1, 4(a0)  # a1: actual allocation size.
	syscall

	# Bail out if we cannot unmap this memory block.
	#
	bnez	v0, myfree_die

	# Success.
	#
	j myfree_return

myfree_die:
	# Generate a segmentation fault by writing to the first
	# byte of the address space (a.k.a. the NULL pointer).
	#
	sw t0, 0(zero)

myfree_return:
	# Destroy the stack frame.
	#
	move	sp, $fp
	lw	ra, 32(sp)
	lw	$fp, 28(sp)
	addu	sp, sp, 40

	j	ra
	.end	myfree


