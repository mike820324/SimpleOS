/*
 * The program will generate a floppy disk(1.4 mb) with bootloader
 * and kernel installed.
 * Some of the function are also the file system drivers.
 * Require two input files:
 * boot.bin and kernel.bin in the same folder.
 * the output file name is os.flp.
 * 
 * Author: MicroMike
 * Time: 2011/10/05
*/
#include <stdio.h>
#include <stdlib.h>

#define FAT1_start 0x200
#define FAT2_start 0x1400
#define RootDir_start 0x2600
#define Data_start 0x4200
#define Floppy_end 0x168000
/* This is the RootDir structure of the FAT 12 */
struct RootDir{
	/* this field should be 11 bytes. */
	char *name;
	char attribute;
	char reserve[10];
	char create_time[2];
	char modify_time[2];
	char FAT_pointer[2];
	/* this field is exactly 4 bytes long. */
	unsigned int *size;
};
typedef struct RootDir RootDir_struct;

void write_kernel_dir(fpos_t kernel_dir);
void init_kernel_dir(unsigned int *kernel_length);
void write_FAT(	unsigned int start, unsigned int end,
		unsigned int kernel_size,fpos_t FAT_addr);
void write_empty_FAT(unsigned int start, unsigned int end);

RootDir_struct kernel;
FILE *input_boot;
FILE *output;
FILE *input_kernel;

int main(){
	int loop;
	char boot_buffer[0x200];
	char buffer=0;
	fpos_t kernel_dir;
	fpos_t FAT1_addr;
	fpos_t FAT2_addr;
	unsigned int kernel_length=0;

	/* start to write the file */
	input_kernel = fopen("./kernel.bin","rb");	
	input_boot = fopen("./boot.bin","rb");
	if(input_kernel==NULL || input_boot==NULL){
		printf("can't find the binary files. Make first!!\n");
		exit(1);
	}
	output = fopen("./os.flp", "wb");
	/* install the bootloader */
	for(loop=0;loop<0x200;loop++){
		buffer = fgetc(input_boot);
		putc(buffer,output);
	}
	/* write FAT1 */
	fgetpos(output,&FAT1_addr);
	write_empty_FAT(FAT1_start, FAT2_start);

	/* write FAT2 */
	fgetpos(output,&FAT2_addr);
	write_empty_FAT(FAT2_start, RootDir_start);

	/* get current positions */
	fgetpos(output, &kernel_dir);
	/* the RootDir starts here */
	for(loop=RootDir_start;loop<0x4200;loop++){
		putc(0,output);	
	}

	/* data section of the FAT 12 */
	while(1){
		buffer = fgetc(input_kernel);
		if(feof(input_kernel)) break;	
		putc(buffer,output);
		kernel_length++;
	}
	printf("kernel size is 0x%x\n",kernel_length);
	for(loop=Data_start+kernel_length;loop<Floppy_end;loop++){
		putc(0,output);
	}
	/* setup the FAT1 for the kernel */
	write_FAT(FAT1_start,FAT2_start,kernel_length,FAT1_addr);
	/* setup the FAT2 for the kernel */
	write_FAT(FAT2_start,RootDir_start,kernel_length,FAT2_addr);
	/* time to setup the kernel root directory table */
	init_kernel_dir(&kernel_length);
	/* write the kernel directory */
	write_kernel_dir(kernel_dir);
	/* close all the FILE pointer */
	fclose(output);
	fclose(input_boot);
	fclose(input_kernel);
}
/* write an empty FAT */
void write_empty_FAT(unsigned int start, unsigned int end){
	unsigned int loop;
	for(loop=start;loop<end;loop++){
		putc(0,output);
	}
}
/*
 * the function is to set the FAT table for the floppy
 */
void write_FAT(unsigned int start, unsigned int end, unsigned int kernel_size,fpos_t FAT_addr){
	unsigned int loop;
	/* the init number is always three */
	short unsigned int init_fat_num = 3;
	short unsigned int temp_fat;
	char *ptr = &init_fat_num;
	unsigned char buffer[3] = { 0, 0, 0};
	unsigned int fat_loop=0;
	/* the first three bytes of the FAT is never change */
	fsetpos(output,&FAT_addr);
	putc(0xf0,output);
	putc(0xff,output);
	putc(0xff,output);


	/* calculate how many FAT the kernel image is using */
	if(kernel_size%0x200==0){
		fat_loop = kernel_size/0x200;	
	}
	else {
		fat_loop = kernel_size/0x200+1;
	}
	/* fat_loop is odd */
	if(fat_loop%2 == 1) {
		for(loop =1; loop<fat_loop-1; loop*=2){
			buffer[0] = (char)*(ptr);
			buffer[1] = (char)*(ptr+1);	
			init_fat_num++;
			temp_fat = init_fat_num;
			init_fat_num = init_fat_num << 4;
			buffer[1] = buffer[1] + (char)(*ptr);
			buffer[2] = (char)*(ptr+1);
			fwrite(buffer,1,3,output);
			init_fat_num = (++temp_fat);
		}
		
		init_fat_num = 0xfff;
		buffer[0] = (unsigned char)*(ptr);
		buffer[1] = (unsigned char)*(ptr+1);
		init_fat_num=0x0;
		buffer[1] += (char)(*ptr);
		buffer[2] = (unsigned char)*(ptr+1);
		fwrite(buffer,1,3,output);
		/* write the rest of the FAT */	
		for(loop=start+((fat_loop+1)/2+1)*3;loop<end;loop++){
				putc(0,output);
		}
	}
	/* FAT loop is even */
	else {
		if(fat_loop == 0){
			printf("the kernel size is zero?!\n");
		}
		else{
			for(loop=1; loop<fat_loop; loop*=2){
				buffer[0] = (char) *(ptr);
				buffer[1] = (char) *(ptr+1);
				
				if(loop*2<fat_loop){ /* check if it will out of bound */
					init_fat_num++;
					init_fat_num = init_fat_num << 4;
					buffer[1] += (char)(*ptr);
					buffer[2] = (char)*(ptr+1);
					fwrite(buffer,1,3,output);
					init_fat_num = init_fat_num >> 4;
				}
				
			}
			init_fat_num = 0xfff;
			buffer[1] += (char)*(ptr);
			buffer[2] = (char)*(ptr+1);
			fwrite(buffer,1,3,output);
			/* write the rest of the FAT */
			for(loop=start+((fat_loop/2)+1)*3;loop<end;loop++){
					putc(0,output);
			}
		}
	}
}

/* initialize the root directory structure for the kernel */
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

/* write the kernel structure to the root directory */
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
