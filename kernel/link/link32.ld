OUTPUT_FORMAT("binary")
INPUT(kernel32.o)
ENTRY(main)
OUTPUT(kernel32.bin)
SECTIONS
{
	.text 0x100000:
	{
		kernel32.o(.text)
	}
	.data 0x100200:
	{
		kernel32.o(.data)
	}
}

