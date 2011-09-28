#!/bin/bash
#Program:
#	This scripts helps me generate simple gdb scripts and run the gdb
#	
#	by MicroMike 2011/08/05

gdb_script_name=$PROJECT_PATH/script/command.gdb
gdb_command="--command=$gdb_script_name"
architecture=i8086
port=1234
breakaddress=0x7c00

echo "generating command.gdb"
touch $gdb_script_name
echo "python print '###############################'" > $gdb_script_name
echo "set arch $architecture" >>  $gdb_script_name
echo "target remote localhost:$port" >> $gdb_script_name
echo "break *($breakaddress)" >> $gdb_script_name
echo "python print 'use continue to start debug'" >> $gdb_script_name

gdb $gdb_command
rm $gdb_script_name
