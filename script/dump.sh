#!/bin/bash
#program:
#	this program is to dump the debug information

boot_bin="$PROJECT_PATH/bin/boot.bin"
ker_bin="$PROJECT_PATH/bin/kernel.bin"
flp_bin="$PROJECT_PATH/bin/os.flp"
deb_path="$PROJECT_PATH/dump"
ker_dump="$deb_path/kernel.dump"
boot_dump="$deb_path/boot.dump"
flp_dump="$deb_path/floppy.dump"



function dump_check(){
	[ ! -e "$ker_bin" ] && [ ! -e "$boot_bin" ] && echo "use make first" && exit 0 [ ! -e "$flp_bin" ] && echo "use make install first" && exit 0
	[ ! -d dump ] && echo "creating directory" && mkdir dump
}
function dump_bin(){
	echo "generating binary dump files...."
        test -e $boot_dump && rm $boot_dump 
	test -e $ker_dump && rm $ker_dump
        touch temp.c
        gcc -c -o temp.o temp.c
        objcopy --add-section raw=$boot_bin temp.o
        objcopy -R .comment temp.o
        objdump -D --disassembler-options=i8086 temp.o >> $boot_dump
        objcopy -R raw temp.o
        objcopy --add-section raw=$ker_bin temp.o
        objdump -D --disassembler-options=i8086 temp.o >> $ker_dump
        rm temp.*
}
function dump_floppy(){
	test -e $flp_dump && rm $flp_dump
        echo "generating virtual flp dump files...."
        xxd $flp_bin >> $flp_dump
}
function dump_all(){
	dump_check
	dump_bin
	dump_floppy
}

function remove(){	
	echo "removing dump files"
	[ -d $deb_path ] && rm -rf $deb_path || echo "no dump files"
}


if [ "$#" == "0" ]; then
	echo "no options"	
	echo "-r --remove : clean the dump files"	
	echo "-d --dump : dump the debug files"
	exit 0
fi

if [ "$PROJECT_PATH" == "" ]; then
	echo "there is no root path(PROJECT_PATH)"
	echo "more information, read README"
	exit 0
fi
if [ "$1" == "--dump" ] || [ "$1" == "-d" ]; then
	dump_all
fi

if [ "$1" == "--remove" ] || [ "$1" == "-r" ]; then
	remove	
	echo "all done"
	exit 0
fi
