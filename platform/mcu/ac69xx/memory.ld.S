MEMORY
{
	reserved_ram(rw)  : ORIGIN = 0x0000100,  LENGTH = 0x00100
    ram (rwx)   	  : ORIGIN = 0x200, LENGTH = 97K-0x200
	/*overlay_task 	  :	ORIGIN = 67K,   LENGTH = 8K*/
	/*overlay_ram0 	  :	ORIGIN = 75K,   LENGTH = 30K*/
    stack_ram(rwx)    : ORIGIN =0x1C000-0x100-0x1B00, LENGTH = 0x1B00
    flash (rx)        : ORIGIN = 0x1000000, LENGTH = 512K - 128k
    flash_kv(rw)      : ORIGIN = 0x1000000 + 512K - 128K + 0x8e0, LENGTH = 128K
}

ENTRY(_start)

SECTIONS
{
	. = ORIGIN(reserved_ram);
	.resrved_data ALIGN(4):
	{
	} > reserved_ram


	. = ORIGIN(ram);
    .bss (NOLOAD) :SUBALIGN(4)
    {
        *(.sbss*)
        *(.bss*)
        *(*COMM*)
    } > ram

    .data :SUBALIGN(4)
    {
        *(.data*)
        *(.common)
        *(.vm)
        *(.poweroff_text)
        *(.powerdown_text)
        *(.poweroff_flash)
    } > ram


	.=ORIGIN(stack_ram);
	.stack_data(NOLOAD) :SUBALIGN(4)
	{
		STACK_START = .;
		*(.stack)
		STACK_END = .;
	} > stack_ram

	. = ORIGIN(flash);
    .text :
    {
        *(.startup.text)
        *(.text*)
        *(.rodata*)

        /* FIXME: 可能需要放到别的地方 */
        *(.audio_text)


        *(.gcc_except_table .gcc_except_table.*)
    } > flash

    text_end = . ;

    text_size = SIZEOF(.text);

    __data_runtime_start__ = ADDR(.data);
    __data_store_start__ = text_end;
    __data_size__ = SIZEOF(.data); 

/*    __bss_start__ = ADDR(.bss);*/
/*    __bss_size__ = SIZEOF(.bss); */

    __bss_start__ = 0x200;
    __bss_size__ = SIZEOF(.bss) + 0x200;

    __bss_end__ = ADDR(.bss) + SIZEOF(.bss);
    __data_runtime_end__ = ADDR(.data) + SIZEOF(.data);

    __heap_start__ = __data_runtime_end__;   
    __heap_len__ = ORIGIN(ram) + LENGTH(ram) - __heap_start__;

    __flash_kv_start__ = ORIGIN(flash_kv);
    __flash_kv_size__ = LENGTH(flash_kv);
}
