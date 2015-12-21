#include <x86-msr-index.h>
#include <x86-processor-flags.h>

    .text
    .global start
start:
    .code32
    movl    $boot_stack_end, %esp

    movl    %cr0, %eax
    andl    $(-X86_CR0_EM), %eax
    orl     $X86_CR0_MP, %eax
    movl    %eax, %cr0

    movl    %cr4, %eax
    orl     $X86_CR4_OSFXSR, %eax
    orl     $X86_CR4_OSXMMEXCPT, %eax
    movl    %eax, %cr4

/*
 * Prepare for entering 64 bit mode
 */
    xorl    %ebx, %ebx

/*
 * Build early 4G boot pagetable
 */
    movl    $pgtable, %edi
    xorl    %eax, %eax
    movl    $((4096*3)/4), %ecx
    rep     stosl

    /* Build the top level page table - PML4 */
    movl    $pgtable, %edi
    leal    0x1003(%edi), %eax
    movl    %eax, 0x0(%edi)

    /* Build 4 Page Directory entries in the Page Directory */
    leal    pgtable + 0x1000(%ebx), %edi
    leal    0x1003(%edi), %eax
    movl    %eax, 0x0(%edi)

    /* Build 204 page table entries by 2 megabytes */
    leal    pgtable + 0x2000(%ebx), %edi
    movl    $0x183, %eax
    movl    $2048, %ecx
1:  movl    %eax, 0(%edi)
    addl    $0x00200000, %eax
    addl    $8, %edi
    decl    %ecx
    jnz     1b

    movl    $pgtable, %eax
    movl    %eax, %cr3

    /* Enable PAE mode */
    movl    %cr4, %eax
    orl     $X86_CR4_PAE, %eax
    movl    %eax, %cr4

    /* Enable Long mode in EFER (Extended Feature Enable Register) */
    movl    $MSR_EFER, %ecx
    rdmsr
    btsl    $_EFER_LME, %eax
    wrmsr

    /* Enter paged protected Mode, activating Long Mode */
    movl    $(X86_CR0_PG | X86_CR0_PE), %eax /* Enable Paging and Protected Mode */
    movl    %eax, %cr0

    lgdt    gdtdesc

    ljmp    $0x8, $start64

    .code64
start64:
    xorl    %eax, %eax
    movl    %eax, %ds
    movl    %eax, %es
    movl    %eax, %ss
    movl    %eax, %fs
    movl    %eax, %gs

    movl    %ebx, %edi
    call    kmain

    movq    $0x2f592f412f4b2f4f, %rax
    movq    %rax, (0xb8000)
    hlt

    .data
gdt:
    .quad	0x0000000000000000	/* NULL descriptor */
    .quad	0x00209a0000000000	/* __KERNEL_CS */
    .quad	0x0000910000000000	/* __KERNEL_DS */

gdtdesc:
    .word   0x17
    .quad   gdt

    .bss
    .balign 4
boot_stack:
    .fill   0x4000, 1, 0
boot_stack_end:

    .section ".pgtable", "a", @nobits
    .balign 4096
pgtable:
    .fill   3*4096, 1, 0
