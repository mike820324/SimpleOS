.code16
.section .text
.global kernel_start

kernel_start:
	cli
	movw	$0x0, %ax
	movw	%ax, %ds
	movw	%ax, %es
	/*
	movw 	%ax, %ss
	movw 	$4096, %sp
	movw 	$0xb800, %ax
	movw 	%ax, %gs
	*/
	sti
set_video_mode:
	movb $0x03, %al
	movb $0x00, %ah
	int  $0x10
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
	jmp flush 
/*
according to the intel manual, after change to pmode,
we need to short jmp to clear prefetch queue.
*/
flush:
	xorw %bx, %bx
	xorl %esi, %esi
	movw %cs, %si
	
#the jmpi 0x100000, 8
goto_code_32:
	.byte 0x66, 0xea
	.long 0x8400
	.word 0x8
.section .data
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

gdtr:
#limit field
.word boot_gdt_end-boot_gdt-1
#base field
.long boot_gdt 

