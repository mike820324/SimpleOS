#ifndef MEMORY_H
#define MEMORY_H
extern void calculate_phys();

struct memory820 {
	long long base;
	long long dest;
	long status;
};

typedef struct memory820 mem820_struct;

#endif
