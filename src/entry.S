.text

.global start

start:
        movl $0x2f4b2f4f, ($0xb8000)
spin:   jmp spin
