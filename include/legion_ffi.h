#ifndef LEGION_FFI_H
#define LEGION_FFI_H

#include <stdint.h>

void     halt_cpu(void);

void     gdt_load(uint32_t base, uint16_t limit);
void     idt_set_gate(uint8_t num, uint32_t handler, uint16_t sel, uint8_t flags);
void     idt_load(void);
extern   uint32_t isr_stub_table[];

void     outb(uint16_t port, uint8_t val);
uint8_t  inb(uint16_t port);
void     io_wait(void);

void     phys_mem_init(void);
void     virt_mem_init(void);
void     heap_init(uint64_t start, uint64_t size);
uint64_t kmalloc(uint64_t size);
void     kfree(uint64_t ptr);
uint64_t phys_alloc_frame(void);
void     phys_free_frame(uint64_t addr);
void     virt_map_page(uint64_t vaddr, uint64_t paddr, uint32_t flags);
void     virt_unmap_page(uint64_t vaddr);

void     sched_init(void);
void     sched_run(void);
void     sched_yield(void);
uint32_t sched_spawn(uint32_t entry, uint8_t prio);
void     sched_exit(uint32_t code);
void     sched_block(uint32_t pid);
void     sched_unblock(uint32_t pid);
uint32_t sched_current_pid(void);

typedef uint32_t (*syscall_handler_t)(uint32_t nr, uint32_t a1, uint32_t a2,
                                      uint32_t a3, uint32_t a4, uint32_t a5);
void     syscall_register_handler(syscall_handler_t h);

uint64_t pipe_create(void);
uint64_t pipe_read(uint64_t fd, uint64_t count);
uint64_t pipe_write(uint64_t fd, uint64_t buf, uint64_t size);
void     pipe_close(uint64_t fd, uint8_t end);

#endif
