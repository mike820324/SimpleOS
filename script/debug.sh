#!/bin/bash
#Program:
#	This scripts helps me generate simple gdb scripts and run the gdb
#	
#	by MicroMike 2011/08/05

gdb_script_name=command.gdb
gdb_command="--command=$gdb_script_name"
architecture=i8086
port=1234
bootldaddress=0x7c00
k16add=0x90000
k32add=0x100000
realmodeflag="true"
notrun="false"
for i in $@
do
	if [ "$i" == "--realmode=disable" ]; then
		realmodeflag="false"
		architecture=i386
	fi
	if [ "$i" == "-g" ] || [ "$i" == "--generate" ]; then
		notrun="true"	
	fi
done
if [ "$realmodeflag" == "true" ]; then
	echo "generating gdb command(command.gdb) for realmode...."
	touch $gdb_script_name
	echo "set arch $architecture" >>  $gdb_script_name
	echo "target remote localhost:$port" >> $gdb_script_name
	echo "python print 'bootloader break point is at 0x7c00'" >> $gdb_script_name
	echo "break *($bootldaddress)" >> $gdb_script_name
	echo "python print 'kernel16 is at 0x90000'" >> $gdb_script_name
	echo "break *($k16add)" >> $gdb_script_name
	echo "python print 'use continue to start debug'" >> $gdb_script_name
else
	echo "generating gdb command(command.gdb) for protected mode...."
	touch $gdb_script_name
	echo "set arch $architecture" >>  $gdb_script_name
	echo "target remote localhost:$port" >> $gdb_script_name
	echo "python print 'kernel is at 0x100000'" >> $gdb_script_name
	echo "break *($k32add)" >> $gdb_script_name
	echo "python print 'use continue to start debug'" >> $gdb_script_name
fi
if [ "$notrun" == "false" ]; then
	gdb $gdb_command
	rm $gdb_script_name
fi
