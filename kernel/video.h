/* video.h
   contains some macros of the video drivers
   by MicroMike 2011/8/03
*/

.macro print_char text
        movb \text, %al
        movb %al, %gs:(%si)
	call update_text_coordinate
.endm

.macro position_4_print row,column,position
	push %ax
        xor %ax,%ax
        movb \row, %al
        movb $160, %cl
        mul %cl
        xor %cx,%cx
        movb \column, %cl
        shl $1, %cl
        add %cx, %ax
        movw %ax, \position
        pop %ax
.endm

.macro position_4_cursor row,column,position
	push %ax
        xor %ax,%ax
        movb \row, %al
        movb $80, %cl
        mul %cl
        xor %cx,%cx
        movb \column, %cl
        add %cx, %ax
        movw %ax, \position
        pop %ax
.endm

.macro set_cursor position
        movb $0x0f, %al
        movw $0x3d4, %dx
        out  %al, %dx

        movw \position, %ax
        movw $0x3d5, %dx
        out  %al, %dx

        movb $0x0e, %al
        movw $0x3d4, %dx
        out  %al, %dx

        movw \position, %ax
        shr  $8, %ax
        movw $0x3d5, %dx
        out  %al, %dx
.endm
