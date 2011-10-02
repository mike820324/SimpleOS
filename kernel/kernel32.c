void printk(char *text);
char hello[]="hello world!!";
void main(){
	printk(hello);
	__asm__("hlt");	
	for(;;);
}
void printk(char *text){
	char *ptr;
	for( ptr= (char *)0xb8000; *text!=0; text++ ){
		*(ptr++) = *text;
		*(ptr++) = 0xe;

	}
}
