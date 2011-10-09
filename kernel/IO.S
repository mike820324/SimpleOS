#The IO.S contains the low level instruction that c can not achieve.
#Such as in and out instruction, cli, sti and so on.

.code32
.section .text

.global io_outb
.type io_outb, @function
io_outb:
	push	%ebp
	movl	%esp,%ebp
#get the first parameter, which is the port number
	movl	0x8(%ebp), %edx
#get the second parameter, which is the value to output
	movl	0xc(%ebp), %eax
	outb	%al, %dx
	
	leave
	ret
.global io_inb
.type io_inb, @function
io_inb:
	push	%ebp
	movl	%esp,%ebp

	xor	%eax,%eax
	movl	0xc(%ebp), %edx

	inb	%dx, %al

	leave
	ret
