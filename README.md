# Legion Idris Kernel

**Author:** Demo X Hexa  
**Organization:** Death Legion Team LK  
**GitHub:** https://github.com/deathlegionteamlk  
**Version:** 0.1.0

---

A Linux-like kernel written in Idris 2. x86 bare metal. Boots via GRUB Multiboot.

## What it has

- GDT / IDT setup
- PIC remapping (IRQs 0–15 at 0x20–0x2F)
- Physical and virtual memory management
- Heap allocator (kmalloc / kfree)
- Round-robin process scheduler
- COM1 serial driver
- POSIX-style syscall dispatcher (exit, fork, read, write, getpid, sbrk, yield)
- VFS interface (filesystem agnostic)
- Pipe-based IPC

## Requirements

- Idris 2 >= 0.7.0
- i686-elf-gcc cross-compiler
- nasm
- GRUB (grub-mkrescue)
- QEMU (for testing)

## Build

```sh
make
make iso
make run
```

## Structure

```
legion-idris-kernel/
├── src/
│   ├── Main.idr
│   ├── boot/
│   │   ├── Init.idr
│   │   └── entry.asm
│   ├── arch/x86/
│   │   ├── GDT.idr
│   │   ├── IDT.idr
│   │   └── PIC.idr
│   ├── memory/
│   │   └── Allocator.idr
│   ├── process/
│   │   └── Scheduler.idr
│   ├── drivers/
│   │   └── Serial.idr
│   ├── syscall/
│   │   └── Dispatcher.idr
│   ├── fs/
│   │   └── VFS.idr
│   └── ipc/
│       └── Pipe.idr
├── include/
│   └── legion_ffi.h
├── build/
│   └── legion.ld
├── legion.ipkg
└── Makefile
```

## FFI

Low-level x86 stuff (port I/O, register loads, page table ops) lives in C and is called from Idris via the FFI layer declared in `include/legion_ffi.h`. The Idris side never touches raw hardware directly.

## License

MIT
