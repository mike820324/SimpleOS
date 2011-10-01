OUTPUT_FORMAT("binary")
INPUT(kernel/kernel.o)
ENTRY(kernel_start)
OUTPUT(bin/kernel.bin)
SECTIONS
{
	.text16 0x8000:
	{
		kernel/kernel.o(.text);
	}
	.data16 0x8200:
	{
		kernel/kernel.o(.data);
	}
}

