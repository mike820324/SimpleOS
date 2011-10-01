OUTPUT_FORMAT("binary")
INPUT(boot/boot.o)
ENTRY(main)
OUTPUT(bin/boot.bin)
SECTIONS
{
	.text 0x7c00 :
	{
		*(.text)
	}
	.data :
	{
		*(.data)
	}
	
	.bss :
	{
		*(.bss)
	}
}
