CC := gcc
LD := ld
CFLAGS := -c -g -Wall -ffreestanding 
ASFLAGS := -c -g
RLDFLAGS := -T link/link16.ld -M > map/k16.map
KLDFLAGS := -T link/link32.ld -M > map/k32.map
SECTIONS := -j .text -j .data

all: kernel.bin

kernel.bin: kernel16.bin kernel32.bin
	dd if=kernel16.bin of=kernel.bin
	dd oflag=append conv=notrunc if=kernel32.bin of=kernel.bin
	rm kernel16.bin kernel32.bin
kernel16.bin: kernel16.o
	[ -d ./map ] || mkdir map
	${LD} ${RLDFLAGS}

kernel32.bin: kernel32.o
	[ -d ./map ] || mkdir map
	${LD} ${KLDFLAGS}

kernel16.o: kernel16.S
	${CC} ${ASFLAGS} -o kernel16.o kernel16.S
	cp kernel16.o k16_debug.o
	objcopy ${SECTIONS} kernel16.o
kernel32.o: kernel32.c
	${CC} ${CFLAGS} -o kernel32.o kernel32.c
	cp kernel32.o k32_debug.o
	objcopy ${SECTIONS} kernel32.o

clean:
	rm *.o
	rm -rf map


