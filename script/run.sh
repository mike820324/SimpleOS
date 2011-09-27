#!/bin/bash
#program:
#	this scripts is to help me run the binary file.
#	
#	by MicroMike in NCU 2011/08/05

bin_path="$PROJECT_PATH/bin/os.flp"

if [ "$#" == "0" ]; then
	echo "no option."
	echo "-r --run : use qemu to run the binary file"
	echo "-d --debug : run the binary in qemu and enable the gdb stub"
fi

if [ "$1" == "-r" ] || [ "$1" == "--run" ]; then
	qemu -fda $bin_path
fi

if [ "$1" == "-d" ] || [ "$1" == "--debug" ]; then
	echo "default port 1234"
	echo "run gdb with target remote localhost:1234"
	qemu -s -S -fda $bin_path
fi
