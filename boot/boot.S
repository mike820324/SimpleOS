#Program:
#	This program is a simple bootloader.
#	The purpose is to load the kernel, or the sencond stage bootloader
#	into memory.
#	more information plz read the Readme
#Time:
#	2011/06/27	first version 	by MicroMike NCU
.code16

.macro read_disk disk, lba, sector, location
        movw \lba, lba
        call lba2chs
        movw \location, %bx
        movb $0x2, %ah
        movb \sector, %al
        movb \disk, %dl
        int  $0x13
.endm

.macro reboot
	xor 	%ax,%ax
        int     $0x16
	xor 	%ax,%ax
	int 	$0x19        
.endm
.section .text

.global main
main:
#FAT12 file system format
#there is nothing to change in this part.
#the property of all the field will be written in Readme.XD
		jmp start_prog
		nop
		.ascii 	"MicrMike"	#8 bytes for this field
		.word	512		#bytes per sector
		.byte 	1		#sector per cluster
		.word	1		#Reserved sectors for boot record
		.byte	2		#number of FATS
RootEntry:	.word	224		#Number of entries in root dir
		.word	2880		#number of logical sectors
		.byte	0xf0
SPF:		.word	9		#sectors per FAT
SPT:		.word	18		#sectors per track
HPT:		.word	2		#heads per track
		.long	0
		.long	0
		.word	0
		.byte	0x29		#Drive signature: 0x29 for floppy
		.long	0x19900303
		.ascii	"MicroMike  "	#11 bytes for this field
		.ascii	"FAT12   "	#8 bytes for this field
		.fill	18, 1, 0

start_prog:
#set the whole segement
#need to have a 8 kb disk buffer = 512 paragraph + 32 paragraph
#since the linker won't helps me set the base,(the default is 0x0)
#I need to set segement registers(that needed the most) by myself
#the starting paragraph is 0x7c0=>paragraph is the address/16
	movw $0x7c0, %ax
	addw $544, %ax
	cli
#stack grows downwards
	movw %ax, %ss
	movw %sp, 4096
	sti

	movw $0x0, %ax
	movw %ax, %ds
	movw %ax, %es
	
	#movb %dl, bootdev
#load the root directory to the disk buffer
#I need to load all of them. 
#Since I have 8kb disk buffer, there is enough space to load them
#the lba of the root dir is 19	
load_root_dir:
	read_disk $0, $19, $0x0e, $disk_buffer
 	jnc  search_root_dir
	call reset_floppy
	jnc  load_root_dir
	jmp  error_exit                         #if there is double error halt the system
#the root dir is now in the memory
#I need to search the kernel.bin 
#and find which FAT it is using
search_root_dir:
	movw $disk_buffer, %di
	movw RootEntry, %cx
	movw $0, %ax
next_root_entry:
	xchg %cx, %dx
	movw $11, %cx
	movw $kern_name, %si
	rep cmpsb
	je  found_image
	movw $disk_buffer, %di
	addw $0x20, %di
   	xchg %cx, %dx
	loop next_root_entry
	jmp error_exit				##debug OK no problem
found_image:
	movw RootEntry, %ax
	subw %dx, %ax				##debug OK no problem
	movw $disk_buffer, %di
	movw $0x20, %bx
	mulw %bx
	addw %ax, %di
	addw $0x1a, %di
	movw (%di), %ax				##debug OK no problem
	movw %ax, FATNUM
#now I have the FAT number of the binary
#I have to check how many FAT(sector) is the kernel using
read_FAT:
	read_disk $0, $1, $0x09, $disk_buffer
	jnc cal_FAT
	call reset_floppy
	jnc read_FAT
	jmp error_exit				##debug OK no problem

	
cal_FAT:
	movw FATNUM, %ax	
	incw sector
	shr $1, %ax
	addw FATNUM, %ax
	movw $disk_buffer, %di
	addw %ax, %di
	movw (%di), %ax
	testb $1, FATNUM
	jz reminder_0
reminder_1:	
	shr $4,%ax
	jmp cmp_FAT 
reminder_0:
	andw $0xfff, %ax
cmp_FAT:
	cmpw $0xfff, %ax
	je load_kernel
	movw %ax, FATNUM
	jmp cal_FAT
#now it's time to load the kernel
load_kernel:
	movw FATNUM, %bx
	subw sector, %bx
	incw %bx
	addw $31, %bx
	movw $0x800, %ax
	movw %ax, %es
	read_disk $0, %bx, sector, $0
	
goto_kernel: 
	ljmp $0x0, $0x8000

error_exit:
	movw $err, %si
	call print_msg
	reboot

#the following is the function call that we will need in the bootloader

#print_msg
#using bios interrupt 10h to print the message
#parameter of bios interrupt 10h
#%ah: function inumber
#%al: the offset of the message

print_msg:
	movb	$0xe, %ah
	movb 	(%si), %al
	cmpb	$0, %al
	je	print_msg_fin
	int 	$0x10
	addw	$1, %si
	jmp 	print_msg

print_msg_fin:
	ret

#lba2chs:
#the function is like the following
#C = lba %(SPT*HPT)
#H = (lba%SPT)mod HPT
#S = (lba mod SPT)+1

lba2chs:
	movw	SPT, %ax
	mulw	HPT
	movw 	%ax, %bx
	movw	lba, %ax
	xorw	%dx, %dx
	divw	%bx
	movb	%al, %ch

	movw 	lba, %ax
	xor	%dx, %dx
	divw	SPT
	addw	$1, %dx
	movb	%dl, %cl  

	xor 	%dx, %dx  
	divw	HPT
	xchgb	%dh, %dl
	ret
#when error happened reset the floppy and read it again	
#since I'm using fda as the default boot device
#the value of the dl register is 0
reset_floppy:
	pushw %ax
	pushw %dx
	xor %ax, %ax
	movb $0, %dl
	stc
	int $0x13
	popw %dx
	popw %ax
	ret
#here is the data segement, however in real mode the code segement
#and data segement is the same value.
err:	
	.ascii  "loading error, press any key to reboot......"
	.byte 	0x0a, 0x0d, 0
lba:		
	.word	0x0
kern_name:	
	.ascii 	"KERNEL  BIN"
FATNUM:	
	.word	0x0
sector: 
	.byte	0x0
#fill the rest of the bytes to zero, except for the last bytes
	.org	0x1fe, 0x00
#the magic number, 55AAh. However, intel is using little endian
	.word	0xaa55
#here is the disk buffer
disk_buffer:

