.text

.align 4

.global start
start:
        .code32                         # Assemble for 32-bit mode
        movl $0x2f4b2f4f, (0xb8000)
        hlt
