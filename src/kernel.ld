ENTRY(start)

SECTIONS
{
    . = 1M;

    .boot : {
        KEEP(*multiboot.o(.multiboot_header))
    }

    .text : {
        *(.text)
    }

    .pgtable : {
        *(.pgtable)
    }   
}
