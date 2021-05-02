KERNEL_SOURCE_FILES = $(wildcard Kernel/*.c)
KERNEL_OBJ_FILES = ${KERNEL_SOURCE_FILES:.c=.o}

BOOT_SECTOR_ASM = $(wildcard Boot_Sector/*.asm)

NASMPATH = "C:/Program Files (x86)/Microsoft Visual Studio/2019/Community/VC/nasm.exe"

# ----------------------------------------------------------------------------------
# Operating System Image Rules
# ----------------------------------------------------------------------------------
os-image : Boot_Sector/boot_sect.bin Kernel/kernel.bin
	cat $^ > $@

# ----------------------------------------------------------------------------------
# Boot Sector Rules
# ----------------------------------------------------------------------------------
Boot_Sector/boot_sect.bin : $(BOOT_SECTOR_ASM)
	cd Boot_Sector; \
	$(NASMPATH) boot_sect.asm -f bin -o $(@F)

# ----------------------------------------------------------------------------------
# Kernel Rules
# ----------------------------------------------------------------------------------
Kernel/kernel.bin : Kernel/kernel.tmp
	objcopy -O binary -j .text $^ $@

Kernel/kernel.tmp : Kernel/kernel_entry.o $(KERNEL_OBJ_FILES)
	ld -o $@ -Ttext 0x1000 $^

Kernel/kernel_entry.o : Kernel/kernel_entry.asm
	$(NASMPATH) $^ -f win -o $@

# ----------------------------------------------------------------------------------
# Generic Rules
# ----------------------------------------------------------------------------------
# Generic rule for compiling c source files
*.o : $(KERNEL_SOURCE_FILES)
	gcc -ffreestanding -c $< -o $@

.PHONY: clean
clean:
	rm -fr os-image
	rm -fr Kernel/*.o Kernel/*.tmp Kernel/*.bin
	rm -fr Kernel/*.o Kernel/*.tmp Kernel/*.bin
	rm -fr Boot_Sector/*.bin
