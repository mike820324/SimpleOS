OUTPUT_FORMAT("binary")
INPUT(boot.o)
ENTRY(main)
OUTPUT(boot.bin)
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
