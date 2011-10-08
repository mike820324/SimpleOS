//this code contains some function that is associated with the
//video.
//I use the 80x25 text mode, therefore the base address is at 0xb8000
//and the size is 80x25.
//
//Author MicroMike
//Time 2011/10/5

#include "include/video.h"

unsigned int column = 0;
unsigned int row = 0;

void printk(char *string){
	extern unsigned int column;
	extern unsigned int row;
	char *video_ptr=VIDEO_BASE;
	unsigned int loop;
	for(loop = 0; string[loop]!=0; loop++){
		video_ptr[coor2mem] = string[loop];
		video_ptr[coor2mem+1] = 0xe;
		column++;
		if(column >= COLUMN_MAX){
			row++;
			column = 0;
		} 
	}
	update_cursor();
}

void clear_screen(){
	extern unsigned int column;
	extern unsigned int row;
	unsigned int loop;
	char *video_ptr=VIDEO_BASE;
//clear the sreen memory
	for(loop=0; loop<ROW_MAX*COLUMN_MAX*2; loop++){
		*(video_ptr+loop) = 0;	
	}
//reset the coordinate variable
	column = 0;
	row = 0;
	update_cursor();
}
//update the cursor...
void update_cursor(){
	unsigned short position;
	position = row*80+column;
//set the low port
	outb(CURSOR_COMMAND_PORT, 0xf);
	outb(CURSOR_INPUT_PORT, (unsigned char)(position&0xff));
//set the hign port
	outb(CURSOR_COMMAND_PORT, 0xe);
	outb(CURSOR_INPUT_PORT, (unsigned char)((position>>8)&0xff));
	
}

