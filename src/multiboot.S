#define ASM_FILE

#include <multiboot2.h>

# The Multiboot2 header

.section .multiboot_header, "a"
header_start:   
    .long   MULTIBOOT2_HEADER_MAGIC     # Magic number (multiboot 2)
    .long   0                           # Architectrure (protected mode i386)
    .long   header_end - header_start   # Header length

    # Checksum (magic number + architecture + header length)
    .long   0x100000000 - (0xe85250d6 + 0 + (header_end - header_start))

    # End tag
    .word   0                           # Type
    .word   0                           # Flags
    .long   8                           # Size
header_end:
