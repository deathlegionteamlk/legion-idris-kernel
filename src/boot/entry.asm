MBOOT_MAGIC    equ 0x1BADB002
MBOOT_ALIGN    equ 1 << 0
MBOOT_MEMINFO  equ 1 << 1
MBOOT_FLAGS    equ MBOOT_ALIGN | MBOOT_MEMINFO
MBOOT_CHECKSUM equ -(MBOOT_MAGIC + MBOOT_FLAGS)

KERNEL_STACK_SIZE equ 0x4000

section .multiboot
align 4
    dd MBOOT_MAGIC
    dd MBOOT_FLAGS
    dd MBOOT_CHECKSUM

section .bss
align 16
kernel_stack_bottom:
    resb KERNEL_STACK_SIZE
kernel_stack_top:

section .text
global _start
extern legion_kernel_main

_start:
    mov  esp, kernel_stack_top
    push ebx
    push eax
    call legion_kernel_main
    cli

.hang:
    hlt
    jmp .hang
