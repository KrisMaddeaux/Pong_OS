; GDT
gdt_start:

gdt_null:		; the mandatory null descriptor
	dd 0x0		; ’dd’ means define double word (i.e. 4 bytes)
	dd 0x0

gdt_code:	; the code segment descriptor
	; base=0x0, limit=0xfffff,
	; 1st flags:
		; Present: 1, since segment is present in memory - used for virtual memory
		; Privilege: 00, for the highest privilege
		; Descriptor type: 1 for code or data segment, 0 is used for traps
		; Total: 1001b
	; type flags:
		; Code: 1 for code, since this is a code segment
		; Conforming: 0, by not conforming it means code in a segment with a lower privilege may not call code in this segment - this a key to memory protection
		; Readable: 1, 1 if readable, 0 if execute-only. Readable allows us to read constants defined in the code.
		; Accessed: 0, This is often used for debugging and virtual memory techniques, since the CPU sets the bit when it accesses the segment.
		; Total: 1010b
	; 2nd flags:
		; Granularity: 1, if set this multiples our limit by 4K (i.e 16*16*16), so our 0xfffff would become 0xfffff000 (i.e shift 3 hex digits to the left), allowing our segment to span 4 GB of memory.
		; 32-bit default: 1, since our segment will hold 32-bit code, otherwise we'd use 0 for 16-bit code. This actually sets the default data unit size for operations (e.g push 0x4 would expand to a 32-bit number, etc.)
		; 64-bit code segment: 0, unused of 32-bit processor
		; AVL: 0, We can set this for our own uses (e.g debugging) but we will not use it.
		; Total: 1100b
	dw 0xffff		; Limit (bits 0-15)
	dw 0x0			; Base (bits 0-15)
	db 0x0			; Base (bits 16 -23)
	db 10011010b	; 1st flags, type flags
	db 11001111b	; 2nd flags, Limit (bits 16-19)
	db 0x0			; Base (bits 24 -31)

gdt_data:	; the data segment descriptor
	; Same as code segment except for the type flags:
	; type flags:
		; Code: 0 for data 
		; Expand Down: 0 
		; Writable: 1, This allows the data segment to be written to, otherwise it would be read only.
		; Accessed 0, This is often used for debugging and virtual memory techniques, since the CPU sets the bit when it accesses the segment.
		; Total: 0010b
	dw 0xffff		; Limit (bits 0-15)
	dw 0x0			; Base (bits 0-15)
	db 0x0			; Base (bits 16 -23)
	db 10010010b	; 1st flags, type flags
	db 11001111b	; 2nd flags, Limit (bits 16-19)
	db 0x0			; Base (bits 24 -31)

gdt_end:			; The reason for putting a label at the end of the GDT is so we can have the assembler calculate the size of the GDT for the GDT decriptor (below)

; GDT  descriptior
gdt_descriptor:
	dw gdt_end - gdt_start - 1	; Size of our GDT, always one less of the true size
	dd gdt_start				; Start address of our GDT

; Define some handy constants for the GDT segment descriptor offsets, which are what segment registers must contain when in protected mode.
; For example, when we set DS = 0x10 in PM, the CPU knows that we mean it to use the segment described at offset 0x10 (i.e. 16 bytes) in our GDT,
; which in our case is the DATA segment (0x0 -> NULL; 0x08 -> CODE; 0x10 -> DATA)
CODE_SEG  equ  gdt_code  - gdt_start
DATA_SEG  equ  gdt_data  - gdt_start
