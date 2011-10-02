LD := ld
CC := gcc
ASFLAGS := -g -Wall -c
CFLAGS := -g -Wall -c -ffreestanding
LDBOOT := -L ./boot -T link.ld -o ./tmp/boot.bin -M >./tmp/boot.map  
LDKERNEL := -L ./kernel -T link.ld -o ./tmp/kernel.bin -M >./tmp/system.map
 
all: boot/boot.bin kernel/kernel.bin
	[ -d tmp ] || mkdir tmp &&\
	mv boot/boot.bin tmp &&\
	mv kernel/kernel.bin tmp;
boot/boot.bin: 
	(cd boot; make)
kernel/kernel.bin: 
	(cd kernel; make)
clean:
	rm -f ./boot/*.o ./boot/*.map ./kernel/*.o ./kernel/*.map
	rm -rf ./tmp

uninstall:
	[ -d ./bin ] &&\
	rm -rf ./bin
install:
	[ -d ./bin ] &&\
	echo "remove old binary files" &&\
	rm -rf ./bin ||\
	mkdir ./bin;
	[ -d tmp ] &&\
	mv tmp/*.bin ./bin;
	echo "generating fat12 dos file system";\
	mkdosfs -C ./bin/os.flp 1440 &&\
	echo "installing the bootloader" &&\
	dd status=noxfer conv=notrunc if=./bin/boot.bin of=./bin/os.flp &&\
	echo "bootloader install complete" &&\
	[ -d floppy ] ||\
	mkdir floppy &&\
	mount -o loop -t vfat ./bin/os.flp floppy &&\
	cp ./bin/kernel.bin floppy/ &&\
	chmod 666 ./bin/os.flp &&\
	echo "kernel install complete" &&\
	umount floppy &&\
	rm  -r floppy;
