/*
 * The kernel32.c is the first 32 bits code in this OS. 
 * Init environment and everything the OS need.
 */
#include "include/memory.h"
#include "include/video.h"

mem820_struct physical_memory[128];

void main(){
	printk("Welcome to the SimpleOS....");
	change_line();
	printk("by MicroMike.");
	//calculate_phys();
	__asm__("hlt");	
}
void calculate_phys(){
	int i;
	for (i=0; i<128; i++)
		physical_memory[i].dest = physical_memory[i].base + physical_memory[i].dest;

}
