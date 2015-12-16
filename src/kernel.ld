ENTRY(start)

SECTIONS
{
    . = 1M;

    .boot : {
        *multiboot.o(.multiboot_header)    
    }

    .text : {
        *entry.o(.text)
    }
}
