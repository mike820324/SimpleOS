.code16
.section .text
.global kernel_main

	jmp kernel_main

#segement descriptors for GDT
gdt_null:
	

kernel_main:
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
	

goto_code_32:
	
