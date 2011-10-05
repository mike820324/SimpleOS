OUTPUT_FORMAT("binary")
INPUT(kernel32.o video.o)
ENTRY(main)
OUTPUT(kernel32.bin)
SECTIONS
{
	.text 0x100000:
	{
		kernel32.o(.text)
		video.o(.text)		
	}
	.data 0x100200:
	{
		kernel32.o(.data)
		video.o(.data)
	}
	.bss 0x100300:
	{
		kernel32.o(.bss)
		video.o(.bss)
	}
}

