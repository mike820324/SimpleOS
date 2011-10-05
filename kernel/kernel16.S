KERNEL16_SEG = 0x9000 
KERNEL16_OFFSET = 0X90000
MEM802_ADD = 0X600 
.code16 
.section .text
.global kernel16_start

kernel16_start:
#set the segments registers

	cli
	movw	$KERNEL16_SEG, %ax
	movw	%ax, %ds
	movw	%ax, %es
	movw	$0x9030, %ax
	movw	%ax, %ss
	movw 	$0x1024, %ax
	movw	%ax, %sp
	sti
#read the memory state from the bios and set it to 0x90500, which is the kernel32 data region,
#and will be move to 0x100000.
mem820:
	xorl 	%ebx, %ebx
	movw 	$MEM802_ADD, %di
start_mem820:
	movl 	$0x0000e820, %eax
	movl 	$0x534d4150, %edx
	movl 	$20, %ecx
	int 	$0x15
	jc 	mem820_error
	
	cmpl 	$0x534d4150, %eax
	jne 	mem820_error
mem820_nextentry:
	add 	$20, %di
	cmpl 	$0, %ebx
	jne 	start_mem820
mem820_error:
mem820_end:

#the following is to enable the a20 line of the system
#almost all the a20 code is reference from the linux source code.
	movw 	$255, %cx
a20_start_loop:
#check the a20 line is already enabled
a20_none:
	call 	a20_test
	jnz 	a20_done

#using the bios way
	movw 	$0x2401, %ax
	pushfl
	int 	$0x15
	popfl
	call 	a20_test
	jnz 	a20_done

#using keyboard controller to enable the a20.
#the old trick.:P

a20_kbc:
	call 	empty_8042

	call 	a20_test #Just in case that bios is worked
	jnz 	a20_done 

	movb 	$0xd1, %al
	outb 	%al, $0x64
	call 	empty_8042
	
	movb 	$0xdf, %al
	outb 	%al, $0x60
	call 	empty_8042
#wait a some time
a20_kbc_wait:
	pushw 	%cx
	xorw 	%cx, %cx
a20_kbc_wait_loop:
	call 	a20_test
	jnz 	a20_done
	loop 	a20_kbc_wait_loop

# a20 is not enabled yet
	popw 	%cx
	loop 	a20_start_loop
a20_done:
#load the gdt and prepare to go to protected mode
load_gdt:
	lgdt 	gdtr
#this part is reference from old linux source code
#we remap the pic and mask the irq temporaily.
remap_pic:
#initial the IO remap
	movb 	$0x11, %al
	outb 	%al, $0x20
	call 	delay
	
	movb 	$0x11, %al
	outb 	%al, $0xa0
	call 	delay
#remap the master pic vector offset to 0x20
	movb 	$0x20, %al
	outb 	%al, $0x21
	call 	delay
#rempa the slave pic vector offset to 0x28
	movb 	$0x28, %al
	outb 	%al, $0xa1
	call 	delay

#let the irq2 of master pic connect to the slave pic
	movb 	$0x4, %al
	outb 	%al, $0x21
	call 	delay
	movb 	$0x2, %al
	outb 	%al, $0xa1
	call 	delay

	movb 	$0x01, %al
	outb 	%al, $0x21
	call 	delay
	movb 	$0x01, %al
	outb 	%al, $0xa1
	call 	delay
#now the interrupt of IRQ 0~7 is 0x20~0x27 and IRQ 8~15 is at 0x28~0x2f
pic_remap_end:

#mask the irq line temporarily	
	
#this part is reference from linux source code
#mask the irq in both mater PIC and slave PIC, except the IRQ 2
#The IRQ 2 is the default IRQ that connect master and slave
#After that we have no IO connection
mask_irq:
	mov 	$0xff, %al
	out 	%al, $0xa1
	mov 	$0xfb, %al
	out 	%al, $0x21
#ready to change to the protected mode	
#movw $1, %ax  lmsw %ax is the same as
#mov %cr0, %eax
#or $1, %al
#mov %eax, %cr0
goto_pmode:
	movw 	$1, %ax
	lmsw 	%ax

#	jmp flush
/*
according to the intel manual, after change to pmode,
we need to short jmp to clear prefetch queue.
*/

#the jmpi prepare32, 8
goto_code_32:
	.byte 	0x66, 0xea
	.long 	prepare32+KERNEL16_OFFSET 
	.word 	0x8
#some function for kernel16
#this routine read the keyboard controller port.
empty_8042:
	pushl 	%ecx
	movl 	$100000, %ecx

empty_8042_loop:
	decl 	%ecx
	jz 	empty_8042_end_loop
	
	call 	delay

	inb 	$0x64, %al
	testb 	$1, %al
	jz 	no_output

	call 	delay
	inb 	$0x60, %al
	jmp 	empty_8042_loop

no_output:
	testb 	$2, %al
	jnz 	empty_8042_loop

empty_8042_end_loop:
	popl 	%ecx
	ret
#this routine is reference from linux
#This routine test whether or not A20 is enabled. If so,
#it exits with zf unset.
#
#The memory address used, 0x200 which is the int $0x80 vector, which
#should be fine.
a20_test:
	pushw 	%cx
	pushw 	%ax
	xorw 	%cx, %cx
	movw 	%cx, %fs
	decw 	%cx
	movw 	%cx, %gs
	movw 	$32, %cx
	movw 	%fs:(0x200), %ax
	pushw 	%ax
a20_test_wait:
	incw 	%ax
	movw 	%ax, %fs:(0x200)
	call 	delay
	cmpw 	%gs:(0x210), %ax
	loope	a20_test_wait
	popw 	%fs:(0x200)
	popw 	%ax
	popw 	%cx
	ret
delay:
	outb 	%al,$0x80
	ret
.code32
#the code right now is at 0x90022.
prepare32:
#set the segement register to the third entry of the gdt
	xor 	%eax,%eax
	movl	$2,%eax
	shl 	$3, %eax
	mov 	%ax, %ds
	mov 	%ax, %ss
	mov 	%ax, %es
	xor 	%ax,%ax
	mov 	%ax, %fs
	mov 	%ax, %gs
#move the kernel32 code and data into 0x100000
	mov 	$0x90300, %esi
	mov 	$0x100000, %edi
	mov 	$0x100, %ecx
	rep 	movsl		
	ljmp	$0x8, $0x100000
code_end:
	
#16 bit data section start at 0x90200
.section .data

gdtr:
#limit field
.word boot_gdt_end-boot_gdt-1
#base field
#the code is actually gdtr+6
#since gdtr is 48bits(6 bytes)
.long boot_gdt+KERNEL16_OFFSET

#boot_gdt
boot_gdt:
.fill 1, 8, 0
#code descriptor
.word 0xffff
.word 0x0000
.word 0x9a00
.word 0x00cf
#data descriptor
.word 0xffff
.word 0x0000
.word 0x9200
.word 0x00cf	
boot_gdt_end:
.fill 0xe2, 1, 0
