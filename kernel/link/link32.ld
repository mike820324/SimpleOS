OUTPUT_FORMAT("binary")
INPUT(kernel32.o video.o IO.o)
ENTRY(main)
OUTPUT(kernel32.bin)
SECTIONS
{
	.text 0x100000:
	{
		kernel32.o(.text)
		video.o(.text)
		IO.o(.text)
	}
	.data :
	{
		kernel32.o(.data)
		video.o(.data)
	}
	.bss :
	{
		kernel32.o(.bss)
		video.o(.bss)
	}
}

