CC := gcc
LD := ld
ASFLAGS := -g -c -Wall
LDFLAGS := -T link.ld -M > boot.map

all: boot.bin

boot.bin: boot.o
	${LD} ${LDFLAGS}

boot.o: boot.S
	${CC} ${ASFLAGS} -o boot.o boot.S
	cp boot.o boot_debug.o
	objcopy -j .text boot.o
clean:
	rm *.o *.map
