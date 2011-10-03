#include "include/System.h"

mem820_struct physical_memory[128]={0,0,0};
char hello[]= "hello world";

void main(){
	printk(hello);
	flush_screen();
	calculate_phys();
	__asm__("hlt");	
	for(;;);
}
void flush_screen(){
	char *ptr = 0xb8000;
	int i;
	for(i=0;i<80*25;i++){
		(*ptr++) = 0;
	}

}
void calculate_phys(){
	int i;
	for (i=0; i<128; i++)
		physical_memory[i].dest = physical_memory[i].base + physical_memory[i].dest;

}
void printk(char *text){
	char *ptr;
	for( ptr= (char *)0xb8000; *text!=0; text++ ){
		*(ptr++) = *text;
		*(ptr++) = 0xe;

	}
}
