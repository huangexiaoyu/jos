OBJDIR := obj

GDBPORT	:= $(shell expr `id -u` % 5000 + 25000)
CC := gcc
LD := ld

CFLAGS := $(CFLAGS) -I include

arch := x86_64
target := $(arch)-unknown-linux-gnu
jos := target/$(target)/debug/libjos.a
kernel := $(OBJDIR)/kernel
image := $(OBJDIR)/kernel.iso

KERN_ASMFILES :=	src/entry.S \
					src/multiboot.S

KERN_OBJFILES := $(patsubst src/%.S, $(OBJDIR)/%.o, $(KERN_ASMFILES))

.PHONY: all clean qemu

all: $(image)

clean:
	rm -rf $(OBJDIR)

QEMUOPTS = -drive format=raw,file=$(image) -gdb tcp::$(GDBPORT) -no-reboot

qemu: $(image)
	@qemu-system-x86_64 $(QEMUOPTS)

qemu-gdb: $(image)
	@qemu-system-x86_64 $(QEMUOPTS) -S

.gdbinit:
	sed "s/localhost:1234/localhost:$(GDBPORT)/" < $^ > $@

gdb: .gdbinit
	gdb -x .gdbinit

$(image): $(kernel) src/grub.cfg
	@echo + mk $@
	@mkdir -p $(OBJDIR)/image/boot/grub
	@cp $(kernel) $(OBJDIR)/image/boot/kernel
	@cp src/grub.cfg $(OBJDIR)/image/boot/grub
	@grub-mkrescue -o $@ $(OBJDIR)/image 2> /dev/null
	@rm -rf $(OBJDIR)/image

$(kernel): cargo $(jos) $(KERN_OBJFILES) src/kernel.ld
	@echo + ld $@
	$(LD) -o $@ -n --gc-sections -T src/kernel.ld $(KERN_OBJFILES) $(jos)

cargo:
	@cargo rustc --target $(target) -- -Z no-landing-pads

$(OBJDIR)/%.o: src/%.S
	@echo + as $@
	@mkdir -p $(@D)
	$(CC) -nostdinc $(CFLAGS) -c -o $@ $<
