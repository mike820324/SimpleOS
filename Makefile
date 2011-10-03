 
all: boot/boot.bin kernel/kernel.bin
	[ -d tmp ] || mkdir tmp &&\
	mv boot/boot.bin tmp &&\
	mv kernel/kernel.bin tmp;
boot/boot.bin: 
	(cd boot; make)
kernel/kernel.bin: 
	(cd kernel; make)
clean:
	(cd kernel; make clean)
	(cd boot; make clean)
	rm -rf ./tmp

uninstall:
	[ -d ./bin ] &&\
	rm -rf ./bin
install:
	if test -d ./bin; then\
		echo "remove old binary files";\
		rm -rf ./bin;\
	fi
	if test -d floppy; then\
		echo "remove floppy folder";\
		rm -rf ./floppy;\
	fi
	
	mkdir ./bin;
	mv tmp/*.bin ./bin;
	chmod 666 ./bin/*.bin;
	@echo "generating fat12 dos file system";
	@mkdosfs -C ./bin/os.flp 1440;
	@echo "installing the bootloader";
	@dd status=noxfer conv=notrunc if=./bin/boot.bin of=./bin/os.flp;
	@echo "bootloader install complete";
	@echo "installing kernel.bin";
	mkdir floppy &&\
	mount -o loop -t vfat ./bin/os.flp floppy &&\
	cp ./bin/kernel.bin floppy/;
	@chmod 666 ./bin/os.flp;
	@echo "kernel install complete";
	umount floppy && rm  -r floppy;
