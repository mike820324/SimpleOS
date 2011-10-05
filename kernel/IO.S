.code32
.section .text

.global outb
.type outb, @function
outb:
	push	%ebp
	movl	%esp,%ebp
#get the first parameter, which is the port number
	movl	0x8(%ebp), %edx
#get the second parameter, which is the value to output
	movl	0xc(%ebp), %eax
	outb	%al, %dx
	
	leave
	ret
