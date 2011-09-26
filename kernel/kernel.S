#include "video.h"
.code16
.section .text
.global main


	jmp kernel_main
#video global variable
video_row:
	.byte 0
video_col:
	.byte 0

#segement descriptors for GDT
gdt_null:
	

kernel_main:
	cli
	movw	$0x800, %ax
	movw	%ax, %ds
	movw	%ax, %es
	movw 	%ax, %ss
	movw 	$4096, %sp
	movw 	$0xb800, %ax
	movw 	%ax, %gs
	sti
set_video_mode:
	movb $0x03, %al
	movb $0x00, %ah
	int  $0x10
	
print_welcome_message:
	movw $os_welcome,%di	
	call print_msg
	

code_32:

end:	jmp end


#the following is the kernel function

print_msg:
	position_4_print video_row,video_col,%si
.print_start:
	movb	(%di), %al
	cmpb	$0, %al
	je	print_msg_end
	print_char %al
	addw	$2, %si
	inc 	%di
	jmp	.print_start

print_msg_end:
	position_4_cursor video_row,video_col,%si
	set_cursor %si
	ret
/*
func_position_4_print:
	position_4_print %si
	ret
func_calculate_4_cursor:
	position_4_cursor %si	
	ret
*/
update_text_coordinate:
	incb video_col
        movb video_col, %bl
        xor $80, %bl
        jnz update_cursor_end
        movb $0, video_col
        add  $1,video_row
update_cursor_end:
	ret




#this is the data section
os_welcome:
	.ascii "Welcome to the simple OS project..."
	.byte  0

keyboard_buffer:
		
