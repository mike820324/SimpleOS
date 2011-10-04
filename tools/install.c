#include <stdio.h>
#include <stdlib.h>
#define FAT1_start 0x200
#define FAT2_start 0x1400
#define RootDir_start 0x2600
#define Data_start 0x4200

struct RootDir{
	char name[11];
	char attribute;
	char reserve[10];
	char create_time[2];
	char modify_time[2];
	char FAT_pointer[2];
	char size[4];
};
typedef struct RootDir RootDir_struct;

int main(){
	int loop;
	char boot_buffer[0x200];
	char buffer=0;
	FILE *input;
	FILE *output;
	FILE *input_kernel;
	unsigned int kernel_length=0;
//setting up the kernel root directory

	char *kernel_ptr;
	RootDir_struct kernel;
	kernel.name[0]='K';
	kernel.name[1]='E';
	kernel.name[2]='R';
	kernel.name[3]='N';
	kernel.name[4]='E';
	kernel.name[5]='L';
	kernel.name[6]=' ';
	kernel.name[7]=' ';
	kernel.name[8]='B';
	kernel.name[9]='I';
	kernel.name[10]='N';
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
	kernel.size[0]=0x0c;
	kernel.size[1]=0x05;
	kernel.size[2]=0;
	kernel.size[3]=0;
	kernel_ptr = (char*)&kernel;
//start to write the file
	input = fopen("./boot.bin","rb");
	output = fopen("./os.flp", "wb");
//install the bootloader
	for(loop=0;loop<0x200;loop++){
		buffer = fgetc(input);
		putc(buffer,output);
	}
//this is the first FAT
	putc(0xf0,output);
	putc(0xff,output);
	putc(0xff,output);
	putc(0x03,output);
	putc(0x40,output);
	putc(0x00,output);
	putc(0xff,output);
	putc(0x0f,output);
	
	for(loop=FAT1_start+8;loop<FAT2_start;loop++){
			putc(0,output);
	}
//this is the second FAT
	putc(0xf0,output);
	putc(0xff,output);
	putc(0xff,output);
	putc(0x03,output);
	putc(0x40,output);
	putc(0x00,output);
	putc(0xff,output);
	putc(0x0f,output);
	for(loop=FAT2_start+8;loop<RootDir_start;loop++){
		putc(0,output);
	}
//load the kernel root directory
	for(loop=0;loop<0x20;loop++){
		buffer = (char)*(kernel_ptr+loop);
		putc(buffer,output);
	}
//this is the root directory
	for(loop=RootDir_start+0x20;loop<0x4200;loop++){
		putc(0,output);	
	}

//this is the data section of the floppy
//the start section should be kernel.bin
//and fill with other
	
	input_kernel = fopen("./kernel.bin","rb");
	while(1){
		buffer = fgetc(input_kernel);
		if(feof(input_kernel)) break;	
		putc(buffer,output);
		kernel_length++;
	}
	printf("kernel size is %d\n",kernel_length);
	for(loop=Data_start+kernel_length;loop<0x168000;loop++){
		putc(0,output);
	}
}
