#include "include/memory.h"
#include "include/video.h"

mem820_struct physical_memory[128];
char hello[]= "Hello World!!";

void main(){
	printk(hello);
	//calculate_phys();
	__asm__("hlt");	
}
void calculate_phys(){
	int i;
	for (i=0; i<128; i++)
		physical_memory[i].dest = physical_memory[i].base + physical_memory[i].dest;

}
