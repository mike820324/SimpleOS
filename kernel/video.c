/*
 * A very simple video driver under 80x25 text mode.
 * More detailed about 80x25 text mode can be found in osdev wiki. :)
 *
 * Author MicroMike
 * First created time: 2011/10/5
 */

#include "include/video.h"

unsigned int column = 0;
unsigned int row = 0;

void printk(char *string){
	extern unsigned int column;
	extern unsigned int row;
	char *video_ptr=VIDEO_BASE;
	unsigned int loop;
	for(loop = 0; string[loop]!=0; loop++){
		video_ptr[POS2MEM] = string[loop];
		video_ptr[POS2MEM+1] = 0xe;
		column++;
		if(column >= COLUMN_MAX){
			row++;
			column = 0;
		} 
	}
	update_cursor();
}
/* Change a new line */
void change_line(){
	extern unsigned int column;
	extern unsigned int row;
	row++;
	column = 0;
	
}
/* clear the screen */
void clear_screen(){
	extern unsigned int column;
	extern unsigned int row;
	unsigned int loop;
	char *video_ptr=VIDEO_BASE;
	/* clear the screen memory */
	for(loop=0; loop<ROW_MAX*COLUMN_MAX*2; loop++){
		*(video_ptr+loop) = 0;	
	}
	/* reset the coordinate global variables */
	column = 0;
	row = 0;
	update_cursor();
}
/* update the cursor */
void update_cursor(){
	unsigned short position;
	position = COOR2POS; /* get the postion by calling macro */
	/* set the low port */
	io_outb(CURSOR_COMMAND_PORT, 0xf);
	io_outb(CURSOR_INPUT_PORT, (unsigned char)(position&0xff));
	/* set the high port */
	io_outb(CURSOR_COMMAND_PORT, 0xe);
	io_outb(CURSOR_INPUT_PORT, (unsigned char)((position>>8)&0xff));
	
}

