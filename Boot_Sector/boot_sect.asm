[org 0x7c00]	; Tell the assembler where this code will be loaded

	mov [g_bootDrive], dl ; BIOS stores our boot drive in DL, so it's best to remember this for later.

	mov bp, 0x9000	; Set the stack.
	mov sp, bp

	mov bx, g_helloWorldString
	call PrintString

	mov bx, g_msgRealMode
	call PrintString

	; Added check to see if the A20 Line is enabled. It seems to be already enabled. So ignoring implementing functionality to turn it on
;    call CheckA20
;    call PrintA20Status

	call LoadKernel

	; Switch to graphics 320 x 200, 256 colour mode
	mov ah, 0x00
	mov al, 0x13
	int 0x10

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

; Function: CheckA20
;
; Purpose: to check the status of the a20 line in a completely self-contained state-preserving way.
;
; Returns: 0 in ax if the a20 line is disabled (memory wraps around)
;          1 in ax if the a20 line is enabled (memory does not wrap around)
 
;	CheckA20:
;	    pushf
;	    push ds
;	    push es
;	    push di
;	    push si
;	 
;	    cli
;	 
;	    xor ax, ax ; ax = 0
;	    mov es, ax
;	 
;	    not ax ; ax = 0xFFFF
;	    mov ds, ax
;	 
;	    mov di, 0x0500
;	    mov si, 0x0510
;	 
;	    mov al, byte [es:di]
;	    push ax
;	 
;	    mov al, byte [ds:si]
;	    push ax
;	 
;	    mov byte [es:di], 0x00
;	    mov byte [ds:si], 0xFF
;	 
;	    cmp byte [es:di], 0xFF
;	 
;	    pop ax
;	    mov byte [ds:si], al
;	 
;	    pop ax
;	    mov byte [es:di], al
;	 
;	    mov ax, 0
;	    je check_a20__exit
;	 
;	    mov ax, 1
;	 
;	    check_a20__exit:
;	        pop si
;	        pop di
;	        pop es
;	        pop ds
;	        popf
;	     
;	    ret
;	
;	PrintA20Status:
;	    cmp ax, 0
;	        je printA20StatusDisabled
;	        jne printA20StatusEnabled
;	
;	    printA20StatusDisabled:
;	        mov bx, g_msgA20Disabled
;	        call PrintString
;	        ret
;	
;	    printA20StatusEnabled:
;	        mov bx, g_msgA20Enabled
;	        call PrintString
;	        ret

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
	;mov ebx , g_msgProtectedMode
	;call PrintString32		; Use our 32-bit print routine.

	call g_kernelOffset		; Now jump to the address of our loaded kernel code.

	jmp $					; Hang.

; Global variables
g_kernelOffset equ 0x1000 ; This is the memory offset to which we will load our kernel
g_bootDrive db 0

g_helloWorldString: db "Hello, welcome to Kris' super cool OS!", 0
g_msgRealMode: db "Started in 16-bit Real Mode", 0
g_msgProtectedMode: db "Successfully landed in 32-bit Protected Mode", 0
g_msgLoadKernel: db "Loading kernel into memory", 0
;g_msgA20Enabled: db "The A20 Line is Enabled!", 0
;g_msgA20Disabled: db "The A20 Line is Disabled!", 0

;
; Padding  and  magic  BIOS  number.
;

times  510-($-$$) db 0	; When compiled, our program must fit into 512 bytes, with the last two byte being the magic number, so here, tell our assembly compiler to pad out our
						; program with enough zero bytes (db 0) to bring us to the; 510th byte.

dw 0xaa55				; Last two bytes (one word) from the magic number, so BIOS knows we are a boot sector.

