OUTPUT_FORMAT("binary")
INPUT(kernel16.o kernel32.o)
ENTRY(kernel_start)
OUTPUT(kernel.bin)
SECTIONS
{
	.text16 0x0:
	{
		kernel16.o(.text);
	}
	.data16 0x200:
	{
		kernel16.o(.data);
	}
	.text32 0x400:
	{
		kernel32.o(.text)
	}
	.data32 0x600:
	{
		kernel32.o(.data)
	}
}

