[org 0x7c00]	; Tell the assembler where this code will be loaded

	mov [g_bootDrive], dl ; BIOS stores our boot drive in DL, so it's best to remember this for later.

	mov bp, 0x9000	; Set the stack.
	mov sp, bp

	mov bx, g_helloWorldString
	call PrintString

	mov bx, g_msgRealMode
	call PrintString

	call LoadKernel

	call SwitchToPM	; Note that we never return from here.

	jmp $

; Includes
%include "print_string.asm"
%include "global_descriptor_table.asm"
%include "disk_load.asm"

[bits  16]
LoadKernel:
	mov bx, g_msgLoadKernel
	call PrintString

	mov bx, g_kernelOffset	; Setup parameters for our DiskLoad routine, so that we load the first 15 sectors (excluding the boot sector) from the boot disk (i.e. our kernel code) to address KERNEL_OFFSET
	mov dh, 15
	mov dl, [g_bootDrive]
	call  DiskLoad
	
	ret

SwitchToPM:
	cli						; (clear interrupts) We must switch off interrupts until we have setup the protected mode interrupt vector otherwise interrupts will run riot.

	lgdt [gdt_descriptor]	; Load our global descriptor table, which defines the protecte  mode segments (e.g. for code and data)
	
	mov eax, cr0			; To make the switch to protected mode, we set
	or eax, 0x1				; the first bit of CR0, a control register
	mov cr0, eax
	
	jmp CODE_SEG:InitializePM	; Make a far jump (i.e. to a new segment) to our 32-bit code. 
								; This also forces the CPU to flush it's cache of pre-fetched and real mode decoded instructions, which can cause problems.

[bits  32]	; Initialize registers and the stack once in PM.
InitializePM:
	mov ax, DATA_SEG		; Now in PM, our old segments are meaningless, so we point our segment registers to the data selector we defined in our GDT
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

	mov ebp , 0x90000		; Update our stack position so it is right at the top of the free space.
	mov esp , ebp
	call BeginPM

; This is  where we  arrive  after  switching  to and  initialising  protected  mode.
BeginPM:
	mov ebx , g_msgProtectedMode
	call PrintString32		; Use our 32-bit print routine.

	call g_kernelOffset		; Now jump to the address of our loaded kernel code.

	jmp $					; Hang.

; Global variables
g_kernelOffset equ 0x1000 ; This is the memory offset to which we will load our kernel
g_bootDrive db 0

g_helloWorldString: db "Hello, welcome to Kris' super cool OS!", 0
g_msgRealMode: db "Started in 16-bit Real Mode", 0
g_msgProtectedMode: db "Successfully landed in 32-bit Protected Mode", 0
g_msgLoadKernel: db "Loading kernel into memory", 0

;
; Padding  and  magic  BIOS  number.
;

times  510-($-$$) db 0	; When compiled, our program must fit into 512 bytes, with the last two byte being the magic number, so here, tell our assembly compiler to pad out our
						; program with enough zero bytes (db 0) to bring us to the; 510th byte.

dw 0xaa55				; Last two bytes (one word) from the magic number, so BIOS knows we are a boot sector.

