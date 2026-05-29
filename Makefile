KERNEL    := legion
IDRIS2    := idris2
CC        := i686-elf-gcc
AS        := nasm
LD        := i686-elf-ld

IDRIS_SRC := src/Main.idr
IDRIS_OPTS := --codegen chez

C_SRCS    := $(wildcard src/boot/*.c src/arch/x86/*.c src/memory/*.c \
               src/process/*.c src/drivers/*.c src/fs/*.c \
               src/ipc/*.c src/syscall/*.c)

ASM_SRCS  := src/boot/entry.asm

C_OBJS    := $(patsubst src/%.c, build/%.o, $(C_SRCS))
ASM_OBJS  := $(patsubst src/%.asm, build/%.o, $(ASM_SRCS))

CFLAGS    := -std=c11 -ffreestanding -O2 -Wall -Wextra \
             -Iinclude -m32 -fno-stack-protector \
             -fno-builtin -nostdlib

LDFLAGS   := -T build/legion.ld -m elf_i386 \
             -nostdlib --no-undefined

ISO_DIR   := build/iso
ISO_FILE  := $(KERNEL).iso

.PHONY: all clean iso run

all: $(KERNEL).elf

build/%.o: src/%.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

build/%.o: src/%.asm
	@mkdir -p $(dir $@)
	$(AS) -f elf32 $< -o $@

$(KERNEL).elf: $(C_OBJS) $(ASM_OBJS)
	$(LD) $(LDFLAGS) -o $@ $^

iso: $(KERNEL).elf
	@mkdir -p $(ISO_DIR)/boot/grub
	cp $(KERNEL).elf $(ISO_DIR)/boot/$(KERNEL).elf
	@echo 'set timeout=0'                               > $(ISO_DIR)/boot/grub/grub.cfg
	@echo 'set default=0'                              >> $(ISO_DIR)/boot/grub/grub.cfg
	@echo ''                                           >> $(ISO_DIR)/boot/grub/grub.cfg
	@echo 'menuentry "Legion Idris Kernel" {'          >> $(ISO_DIR)/boot/grub/grub.cfg
	@echo '    multiboot /boot/$(KERNEL).elf'          >> $(ISO_DIR)/boot/grub/grub.cfg
	@echo '    boot'                                   >> $(ISO_DIR)/boot/grub/grub.cfg
	@echo '}'                                          >> $(ISO_DIR)/boot/grub/grub.cfg
	grub-mkrescue -o $(ISO_FILE) $(ISO_DIR)

run: iso
	qemu-system-i386 -cdrom $(ISO_FILE) -serial stdio -m 128M

clean:
	rm -rf build/*.o build/boot build/arch build/memory build/process \
	       build/drivers build/fs build/ipc build/syscall \
	       $(KERNEL).elf $(ISO_FILE) $(ISO_DIR)
