#!/bin/bash
#program:
#	this scripts is to help me run the binary file.
#	
#	by MicroMike in NCU 2011/08/05
runflag="false"
debugflag="false"
setpathflag="false"
gdbflag="false"
realmodeflag="false"
bin_path="$PROJECT_PATH/bin/os.flp"
qemu_mem="64"
function print_help(){
	echo "run.sh [options] [flags]"
	echo "below are some options:"
	echo "-r --run : run qemu without any debug stub."
	echo "           this option will be override by the --debug option."
	echo "-d --debug : run the binary in qemu and enable the gdb stub."
	echo "-g --gdb : start gdb automaticaly(the --debug need to be set.)"
	echo "-p --root-path : set the root path of the project"
	echo "below is the flags"
	echo "--realmode=enale/disable to enable/disable the realmode debug."
	echo "--memory=number to set the memory of the qemu. Default is 64."
	echo "before using the realmode flag set the gdb option first."
	echo "ex. run.sh -p `pwd` --debug --gdb realmode=enable"
	exit 0 
}

for i in "$@"
do

	if [ "$setpathflag" == "true" ]; then
		bin_path="$i/bin/os.flp"
		PROJECT_PATH=$i
		setpathflag="false"	
	fi
	if [ "$i" == "-p" ] || [ "$i" == "--root-path" ]; then
		setpathflag="true"	
	fi
	if [ "$i" == "-r" ] || [ "$i" == "--run" ]; then
		runflag="true"
	fi

	if [ "$i" == "-h" ] || [ "$i" == "--help" ]; then
		print_help	
	fi	
	if [ "$i" == "-d" ] || [ "$i" == "--debug" ]; then
		debugflag="true"	
	fi
	
	if [ "$i" == "--gdb" ] || [ "$i" == "-g" ]; then
		gdbflag="true"	
	fi
	
	if [ "$i" == "--realmode=enable" ]; then
		realmodeflag="true"	
	fi
	if echo "$i" | grep -q memory=; then
		qemu_mem=`echo "$i" | cut -d'=' -f2`
		echo "$qemu_mem"	
	fi
	
done
[ "$#" == "0" ] && echo "no options" && print_help && exit 1
if [ "$PROJECT_PATH" == "" ]; then 
	echo "no project root path."
	echo "please set it manually or use "
	echo "-p or --root-path to set the PROJECT_PATH"
else
	echo "project path is $PROJECT_PATH"
	
	if [ "$debugflag" == "true" ]; then
		if [ "$gdbflag" == "true" ]; then
			if [ "$realmodeflag" == "true" ]; then
				qemu -s -S -fda $bin_path -m 64 & 
				echo "starting gdb and enable realmode..." &
				$PROJECT_PATH/script/debug.sh 
			else
				qemu -s -S -fda $bin_path -m 64 & 
				echo "starting gdb..." &
				$PROJECT_PATH/script/debug.sh "--realmode=disable"
			fi
		else 
			echo "default port 1234"
			echo "run gdb with target remote localhost:1234"
			qemu -s -S -fda $bin_path -m 64
		fi
	else
		echo "start running qemu with no debug mode enable"
		qemu -fda $bin_path -m 64
	fi	
fi
