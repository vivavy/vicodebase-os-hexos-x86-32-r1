/* entry point of our kernel */
ENTRY(_start)

SECTIONS
{
	. = 4K;

  	/* text section */
	.text BLOCK(1K) : ALIGN(1K)
	{
		*(.text)
	}

	/* read only data section */
	.rodata BLOCK(1K) : ALIGN(1K)
	{
		*(.rodata)
	}

	/* data section */
	.data BLOCK(1K) : ALIGN(1K)
	{
		*(.data)
	}

	/* bss section */
	.bss BLOCK(1K) : ALIGN(1K)
	{
		*(COMMON)
		*(.bss)
	}

}