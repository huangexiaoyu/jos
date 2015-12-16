OBJDIR := obj

CC := gcc
LD := ld

CFLAGS := $(CFLAGS) -I include

arch := x86_64
kernel := $(OBJDIR)/kernel
image := $(OBJDIR)/kernel.iso

KERN_ASMFILES :=	src/entry.S \
					src/multiboot.S

KERN_OBJFILES := $(patsubst src/%.S, $(OBJDIR)/%.o, $(KERN_ASMFILES))

.PHONY: all clean qemu

all: $(image)

clean:
	rm -rf $(OBJDIR)

qemu: $(image)
	@qemu-system-x86_64 -drive format=raw,file=$(image)

$(image): $(kernel) src/grub.cfg
	@echo + mk $@
	@mkdir -p $(OBJDIR)/image/boot/grub
	@cp $(kernel) $(OBJDIR)/image/boot/kernel
	@cp src/grub.cfg $(OBJDIR)/image/boot/grub
	@grub-mkrescue -o $@ $(OBJDIR)/image 2> /dev/null
	@rm -rf $(OBJDIR)/image

$(kernel): $(KERN_OBJFILES) src/kernel.ld
	@echo + ld $@
	$(LD) -o $@ -n -T src/kernel.ld $(KERN_OBJFILES)

$(OBJDIR)/%.o: src/%.S
	@echo + as $@
	@mkdir -p $(@D)
	$(CC) -nostdinc $(CFLAGS) -c -o $@ $<
