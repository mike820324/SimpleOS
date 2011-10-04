/*
The program will generate a floppy disk(1.4 mb) with bootloader and kernel installed

Author: MicroMike
Time: 2011/10/05
*/
#include <stdio.h>
#include <stdlib.h>

#define FAT1_start 0x200
#define FAT2_start 0x1400
#define RootDir_start 0x2600
#define Data_start 0x4200
#define Floppy_end 0x168000

struct RootDir{
	//this field should be 11 bytes.
	char *name;
	char attribute;
	char reserve[10];
	char create_time[2];
	char modify_time[2];
	char FAT_pointer[2];
	//this field is exactly 4 bytes long.
	unsigned int *size;
};
typedef struct RootDir RootDir_struct;

void write_kernel_dir(fpos_t kernel_dir);
void init_kernel_dir(unsigned int *kernel_length);
void write_FAT(unsigned int start, unsigned int end);

RootDir_struct kernel;
FILE *input_boot;
FILE *output;
FILE *input_kernel;

int main(){
	int loop;
	char boot_buffer[0x200];
	char buffer=0;
	fpos_t kernel_dir;
	unsigned int kernel_length=0;

//start to write the file
	input_kernel = fopen("./kernel.bin","rb");	
	input_boot = fopen("./boot.bin","rb");
	output = fopen("./os.flp", "wb");
//install the bootloader
	for(loop=0;loop<0x200;loop++){
		buffer = fgetc(input_boot);
		putc(buffer,output);
	}
//write the FAT1
	write_FAT(FAT1_start, FAT2_start);
//write the FAT2
	write_FAT(FAT2_start, RootDir_start);

//get the current position for future usage
	fgetpos(output, &kernel_dir);
//this is the root directory
	for(loop=RootDir_start;loop<0x4200;loop++){
		putc(0,output);	
	}

//this is the data section of the floppy
	while(1){
		buffer = fgetc(input_kernel);
		if(feof(input_kernel)) break;	
		putc(buffer,output);
		kernel_length++;
	}
	printf("kernel size is %d\n",kernel_length);
	for(loop=Data_start+kernel_length;loop<Floppy_end;loop++){
		putc(0,output);
	}

//time to setup the kernel root directory table	
	init_kernel_dir(&kernel_length);
//write the kernel directory 
	write_kernel_dir(kernel_dir);
//close all the FILE pointer
	fclose(output);
	fclose(input_boot);
	fclose(input_kernel);
}
/*
the function is to set the FAT table for the floppy
*/
void write_FAT(unsigned int start, unsigned int end){
	unsigned int loop;
	putc(0xf0,output);
	putc(0xff,output);
	putc(0xff,output);
	putc(0x03,output);
	putc(0x40,output);
	putc(0x00,output);
	putc(0xff,output);
	putc(0x0f,output);
	
	for(loop=start+8;loop<end;loop++){
			putc(0,output);
	}
}

//initialize the root directory structure for the kernel
void init_kernel_dir(unsigned int *kernel_length){
	unsigned int loop;
	kernel.name="KERNEL  BIN";	
	kernel.attribute=0x20;
	for (loop=0;loop<10;loop++){
		kernel.reserve[loop] = 0;
	}
	kernel.create_time[0] = 0xe4;
	kernel.create_time[1] = 0x0a;
	kernel.modify_time[0] = 0x45;
	kernel.modify_time[1] = 0x3f;
	kernel.FAT_pointer[0] = 0x02;
	kernel.FAT_pointer[1] = 0x00;
	kernel.size=kernel_length;
}

//write the kernel structure to the root directory
void write_kernel_dir(fpos_t kernel_dir){
	fsetpos(output,&kernel_dir);
	fwrite(kernel.name,1,11,output);
	fputc(kernel.attribute,output);	
	fwrite(kernel.reserve,1,10,output);
	fwrite(kernel.create_time,1,2,output);
	fwrite(kernel.modify_time,1,2,output);
	fwrite(kernel.FAT_pointer,1,2,output);
	fwrite(kernel.size,1,4,output);
}
