;------------------------------------------------------------------------
;------------------------------------------------------------------------
; 16 BIT REAL MODE PRINT FUNCTIONS
;------------------------------------------------------------------------
;------------------------------------------------------------------------

;------------------------------------------------------------------------
; Print Hex
;------------------------------------------------------------------------

; Expect hex value to be in the dx register
PrintHex:
	mov ah, 0x0e	; int  10/ah = 0eh -> scrolling teletype BIOS routine

	; Print leading "0x" hex characters
	mov al, "0"
	int 0x10
	mov al, "x"
	int 0x10

	; The dx register is 16 bits (2 bytes). 1 hex byte (8 bits) is represented by 2 characters.
	; So each individual hex character is 4 bits. dx is divided into dh and dl (8 bits each).
	; So we can get the needed four bits by bitshifting dh and dl
	mov al, dh
	shr al, 4
	call HandleHexValue

	shl dh, 4
	mov al, dh
	shr al, 4
	call HandleHexValue

	mov al, dl
	shr al, 4
	call HandleHexValue

	shl dl, 4
	mov al, dl
	shr al, 4
	call HandleHexValue

	call PrintNewLine
	ret

HandleHexValue:
	cmp al, 9
		jbe HandleHexNumber
		ja HandleHexLetter

	; Convert our hex value into ascii. Conversion is just an addition (refer to ascii table)
	HandleHexNumber:
		add al, 0x30
		jmp PrintHexValue
	HandleHexLetter:
		add al, 0x37
		jmp PrintHexValue

	PrintHexValue:
		int 0x10		; print from al register
	ret

;------------------------------------------------------------------------
; Print String
;------------------------------------------------------------------------

; Expect string to be in the bx register
PrintString:
	mov ah, 0x0e	; int  10/ah = 0eh -> scrolling teletype BIOS routine
	loopString:
		mov al, [bx]	; get the first character of the string and store in al register
		cmp al, 0		; check if we reached the end of the string
			je exitPrintString

		int 0x10		; print from al register

		inc bx			; increment bx register
		jmp loopString

	exitPrintString:
		call PrintNewLine
		ret

;------------------------------------------------------------------------
; Print Newline
;------------------------------------------------------------------------
PrintNewLine:
	mov ah, 0x0e	; int  10/ah = 0eh -> scrolling teletype BIOS routine
	mov al, 10		; 10 is decimal for the newline character
	int 0x10		; print from al register
	mov al, 13		; 13 is decimal for the carriage return character
	int 0x10		; print from al register
	ret

;------------------------------------------------------------------------
;------------------------------------------------------------------------
; 32 BIT PROTECTED MODE PRINT FUNCTIONS
;------------------------------------------------------------------------
;------------------------------------------------------------------------

[bits  32]
; Define some constants
VIDEO_MEMORY equ 0xb8000

; Font templates, see https://en.wikipedia.org/wiki/VGA_text_mode#Text_buffer for details
WHITE_ON_BLACK equ 0x0f
RED_ON_BLACK equ 0xC
GREEN_ON_BLACK equ 0xA
WHITE_ON_BLACK_BLINK equ 0x8F

; Expect string to be in the ebx register
PrintString32:
	pusha
	mov edx , VIDEO_MEMORY			; Set edx to the start of vid mem.

	loopString32:
		mov al, [ebx]				; Store the char at EBX in AL
		mov ah, GREEN_ON_BLACK		; Store the attributes in AH
	
		cmp al, 0					; if (al == 0), at end of string , so
			je exitPrintString32	; jump to done
	
		mov [edx], ax				; Store char and attributes at current; character cell.
	
		add ebx , 1					; Increment EBX to the next char in string.
		add edx , 2					; Move to next character cell in vid mem. Each character cell is represented by two bytes. 
									; The first byte is the ASCII code of the character.
									; The second byte encodes the character's attributes such as the foreground/background colour, if the character should be blinking, etc.
	
		jmp  loopString32			; loop around to print the next char.
	
	exitPrintString32:
		popa
		ret							; Return from the function

