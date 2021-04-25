;
; simple boot sector that prints a message to th  screen using a BIOS routine.
;

[org 0x7c00]	; Tell the assembler where this code will be loaded

mov bx, helloWorldString
call PrintString

mov dx, 0xfd6d
call PrintHex

jmp $			; Jump to the  current  address (i.e.  forever).

helloWorldString:
	db "Hello World!", 0

%include "print_string.asm"

;
; Padding  and  magic  BIOS  number.
;

times  510-($-$$) db 0	; When compiled, our program must fit into 512 bytes, with the last two byte being the magic number, so here, tell our assembly compiler to pad out our
						; program with enough zero bytes (db 0) to bring us to the; 510th byte.

dw 0xaa55				; Last two bytes (one word) from the magic number, so BIOS knows we are a boot sector.

