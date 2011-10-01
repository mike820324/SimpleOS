LD := ld
CC := gcc
CFLAGS := -g -Wall -c
LDBOOT := -T ${PROJECT_PATH}/boot/link.ld   
LDKERNEL := -T ${PROJECT_PATH}/kernel/link.ld 
 
all: boot.bin kernel.bin

boot.bin: ./boot/boot.o
	@[ -d ./bin ] || mkdir bin  
	${LD} ${LDBOOT} 

kernel.bin: ./kernel/kernel.o
	@[ -d ./bin ] || mkdir bin 
	${LD} ${LDKERNEL} 

./boot/boot.o:
	${CC} ${CFLAGS} ./boot/boot.S -o ./boot/boot.o

./kernel/kernel.o:
	${CC} ${CFLAGS} ./kernel/kernel.S -o ./kernel/kernel.o

clean:
	rm -f ./boot/boot.o ./kernel/kernel.o

uninstall:
	@unset PROJECT_PATH &&\
	[ -d ./bin ] &&\
	rm -rf ./bin
install:
	@[ -e ./bin/os.flp ] &&\
	echo "remove old virtual flp" &&\
	rm ./bin/os.flp;\
	echo "generating fat12 dos file system";\
	mkdosfs -C ./bin/os.flp 1440 &&\
	echo "installing the bootloader" &&\
	dd status=noxfer conv=notrunc if=./bin/boot.bin of=./bin/os.flp &&\
	echo "bootloader install complete" &&\
	[ -d tmp ] ||\
	mkdir tmp &&\
	mount -o loop -t vfat ./bin/os.flp tmp &&\
	cp ./bin/kernel.bin tmp/ &&\
	chmod 666 ./bin/os.flp &&\
	echo "kernel install complete" &&\
	umount tmp &&\
	rm  -r tmp; 
