;
; hotkey.inc -- Macros related to hotkeyx.asm
;
; Copyright (C) 2007 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;


;##############################################################################
; hotkey_parm_word -- Covert Counter to DEC. and then push into buffer
;
; Input :
;   PARM    = Counter parameter
;   STRP    = String pointer to push result
;   OFFSET  = Offset in pointer
;
; Output:
;   None
;
; Modified:
;   All preserved
;
hotkey_parm_word MACRO PARM, STRP, OFFSET


	push    eax


	; Read value
	mov	ax, PARM


	; Convert AX to ASCII of Dec number.
	bin_to_bcd  8



	; Push result into buffer
	replace_ascii_str STRP, 6, OFFSET

    
	pop     eax

ENDM


;##############################################################################
; hotkey_update_ascii -- Update field on screen
;
; Input :
;   EAX     = Input value
;   
;   PARM    = Temp buffer
;   BA      = Digits
;   POS     = Cursor position
;
; Output:
;   None
;
; Modified:
;   All preserved
;
hotkey_update_ascii MACRO PARM, BA, POS

	push	ax
	replace_ascii_str PARM, BA, 0
	set_cursor POS
	print_str PARM
	pop	ax

ENDM


;##############################################################################
; hotkey_update_dec -- Update dec field on screen
;
; Input :
;   VALUE   = Value parameter
;   PARM    = Temp buffer
;   BA      = Digits
;   POS     = Cursor position
;
; Output:
;   None
;
; Modified:
;   All preserved
;
hotkey_update_dec MACRO VALUE, PARM, POS

	push	ax
	hotkey_parm_word VALUE, PARM, 0
	set_cursor POS
	print_str PARM
	pop	ax

ENDM


