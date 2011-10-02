CC := gcc
LD := ld
CFLAGS := -c -g -Wall -ffreestanding 
ASFLAGS := -c -g
LDFLAGS := -T link.ld -M > kernel.map
SECTIONS := -j .text -j .data

all: kernel.bin

kernel.bin: kernel16.o kernel32.o
	${LD} ${LDFLAGS} 
kernel16.o: kernel16.S
	${CC} ${ASFLAGS} -o kernel16.o kernel16.S
	cp kernel16.o k16_debug.o
	objcopy ${SECTIONS} kernel16.o
kernel32.o: kernel32.c
	${CC} ${CFLAGS} -o kernel32.o kernel32.c
	cp kernel32.o k32_debug.o
	objcopy ${SECTIONS} kernel32.o


