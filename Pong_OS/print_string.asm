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
