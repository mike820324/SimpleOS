#ifndef VIDEO_H
#define VIDEO_H

#define ROW_MAX 25
#define COLUMN_MAX 40
#define VIDEO_BASE 0xb8000
#define CURSOR_COMMAND_PORT 0x3d4
#define CURSOR_INPUT_PORT 0x3d5

#define COOR2POS (row*80+column)
#define POS2MEM	 (2*COOR2POS)


extern void printk(char *text);
extern void change_line();
extern void clear_screen();
extern void update_cursor();

#endif
