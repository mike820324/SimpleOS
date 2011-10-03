OUTPUT_FORMAT("binary")
INPUT(kernel16.o)
ENTRY(kernel16_start)
OUTPUT(kernel16.bin)
SECTIONS
{
	.text 0x0:
	{
		kernel16.o(.text)
	}
	.data 0x200:
	{
		kernel16.o(.data)
	}
}

