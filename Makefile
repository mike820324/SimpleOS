CC := gcc 
all: boot/boot.bin kernel/kernel.bin tools/install.out
	[ -d tmp ] || mkdir tmp &&\
	mv boot/boot.bin tmp &&\
	mv kernel/kernel.bin tmp &&\
	mv tools/install.out tmp

tools/install.out: tools/install.c
	${CC} -o tools/install.out tools/install.c

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
	
	cd tmp; ./install.out
	mkdir bin
	mv ./tmp/*.bin ./bin
	mv ./tmp/os.flp ./bin
	@echo "generating iso file....."
	(cd bin; mkisofs -V 'SIMPLEOS' -input-charset iso8859-1 -o SimpleOS.iso -b os.flp ./)
	 
	
