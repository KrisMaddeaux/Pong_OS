;
; simple boot sector that prints a message to the screen using a BIOS routine.
;

[org 0x7c00]	; Tell the assembler where this code will be loaded

	mov bx, g_helloWorldString
	call PrintString

	mov [g_bootDrive], dl	; BIOS  stores  our  boot  drive  in DL, so it’s; best to  remember  this  for  later.

	mov bp, 0x8000			; Here we set our  stack  safely  out of the
	mov sp, bp				; way , at 0x8000

	mov bx, 0x9000			; Load 5 sectors  to 0x0000(ES):0 x9000(BX)
	mov dh, 5				; from  the  boot  disk.
	mov dl, [g_bootDrive]
	call  DiskLoad

	mov dx, [0x9000]		; Print  out  the  first  loaded  word , which
	call  PrintHex			; we  expect  to be 0xdada , stored; at  address 0x9000

	mov dx, [0x9000 + 512]	; Also , print  the  first  word  from  the
	call  PrintHex			; 2nd  loaded  sector: should  be 0xface

	jmp $

; Global variables
g_helloWorldString: db "Hello, welcome to Kris' super cool OS!", 0
g_bootDrive: db 0

; Includes
%include "print_string.asm"
%include "disk_load.asm"

;
; Padding  and  magic  BIOS  number.
;

times  510-($-$$) db 0	; When compiled, our program must fit into 512 bytes, with the last two byte being the magic number, so here, tell our assembly compiler to pad out our
						; program with enough zero bytes (db 0) to bring us to the; 510th byte.

dw 0xaa55				; Last two bytes (one word) from the magic number, so BIOS knows we are a boot sector.

; We know that BIOS will load only the first 512-byte sector from the disk, so if we purposely add a few more sectors to our code by repeating some
; familiar numbers,we can prove to ourselves that we actually loaded those additional two sectors from the disk we booted from.
times 256 dw 0xdada
times 256 dw 0xface

