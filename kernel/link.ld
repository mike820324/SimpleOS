OUTPUT_FORMAT("binary")
INPUT(kernel/kernel.o)
ENTRY(kernel_main)
OUTPUT(bin/kernel.bin)
SECTIONS
{
	.text 0x8000:
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

