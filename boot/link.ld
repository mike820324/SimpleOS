OUTPUT_FORMAT("binary")
SEARCH_DIR("boot")
INPUT(boot.o)
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
}
