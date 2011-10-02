.code16
.section .text
.global kernel16_start

kernel16_start:
#since there is no call function at all
#there is no need to set the stack segment and stack pointer again.	
	cli
	movw	$0x800, %ax
	movw	%ax, %ds
	movw	%ax, %es
	sti
#load the gdt and prepare to go to protected mode
load_gdt:
	lgdt gdtr
#ready to change to the protected mode	
#movw $1, %ax  lmsw %ax is the same as
#mov %cr0, %eax
#or $1, %al
#mov %eax, %cr0
goto_pmode:
	movw $1, %ax
	lmsw %ax

#	jmp flush
/*
according to the intel manual, after change to pmode,
we need to short jmp to clear prefetch queue.
*/

#the jmpi prepare32, 8
goto_code_32:
	.byte 0x66, 0xea
	.long prepare32+0x8000
	.word 0x8
.code32
#the code right now is at 0x90022.
prepare32:
#set the segement register to the third entry of the gdt
	xor %eax,%eax
	movl $2,%eax
	shl $3, %eax
	mov %ax, %ds
	mov %ax, %ss
	mov %ax, %es
	xor %ax,%ax
	mov %ax, %fs
	mov %ax, %gs
#move the kernel32 code and data into 0x100000
	mov $0x8400, %esi
	mov $0x100000, %edi
	mov $0x100, %ecx
	rep movsd		
	ljmp $0x8, $0x100000	
.section .data

gdtr:
#limit field
.word boot_gdt_end-boot_gdt-1
#base field
#the code is actually gdtr+6
#since gdtr is 48bits(6 bytes)
.long 0x8206

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

