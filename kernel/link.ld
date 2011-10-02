OUTPUT_FORMAT("binary")
INPUT(kernel16.o kernel32.o)
ENTRY(kernel_start)
OUTPUT(kernel.bin)
SECTIONS
{
	.text16 0x8000:
	{
		kernel16.o(.text);
	}
	.data16 0x8200:
	{
		kernel16.o(.data);
	}
	.text32 0x8400:
	{
		kernel32.o(.text)
	}
}

