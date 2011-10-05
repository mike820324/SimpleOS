CC := gcc
LD := ld
CFLAGS := -c -g -Wall -ffreestanding 
ASFLAGS := -c -g
RLDFLAGS := -T link/link16.ld -M > map/k16.map
KLDFLAGS := -T link/link32.ld -M > map/k32.map
SECTIONS := --strip-debug --strip-unneeded

all: kernel.bin

kernel.bin: kernel16.bin kernel32.bin
	dd if=kernel16.bin of=kernel.bin
	dd oflag=append conv=notrunc if=kernel32.bin of=kernel.bin
	rm kernel16.bin kernel32.bin
kernel16.bin: kernel16.o
	[ -d ./map ] || mkdir map
	${LD} ${RLDFLAGS}

kernel32.bin: kernel32.o video.o IO.o
	[ -d ./map ] || mkdir map
	${LD} ${KLDFLAGS}
	objcopy ${SECTIONS} kernel32.o
kernel16.o: kernel16.S
	${CC} ${ASFLAGS} -o kernel16.o kernel16.S
	cp kernel16.o k16_debug.o
	objcopy ${SECTIONS} kernel16.o
kernel32.o: kernel32.c include/memory.h include/video.h
	${CC} ${CFLAGS} -o kernel32.o kernel32.c
	cp kernel32.o k32_debug.o
	
video.o: video.c include/video.h
	${CC} ${CFLAGS} -o video.o video.c
	cp video.o video_debug.o
	objcopy ${SECTIONS} video.o
IO.o: IO.S
	${CC} ${ASFLAGS} -o IO.o IO.S
clean:
	rm *.o
	rm -rf map


