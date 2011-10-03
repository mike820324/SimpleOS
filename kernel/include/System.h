extern void printk(char *text);
extern void calculate_phys();
extern void clear_screen();
struct memory820 {
	long long base;
	long long dest;
	long status;
};

typedef struct memory820 mem820_struct;

