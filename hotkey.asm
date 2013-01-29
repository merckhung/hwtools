;
; hotkey.asm -- UMPC hotkey monitor
;
; Copyright (C) 2007 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
; This is a small tool for monitoring UMPC hotkey status
; It's a very cool toy.
;
.586P


;##############################################################################
; set_cursor -- Call BIOS serivce to set cursor position with DX
;
; Input :
;   CURSOR = (Line:Coulmn)
;   or
;   DH  = Line on Screen
;   DL  = Column on Screen
;
; Output:
;   None
;
; Modified:
;   AX
;   BH
;   CX
;   DX
;
set_cursor MACRO CURSOR

    push    ax
    push    bx
    push    cx
    push    dx

    mov     ah, 02h
    xor     bh, bh

IFNB <CURSOR>
    mov     dx, CURSOR
ENDIF

    int     10h

    pop     dx
    pop     cx
    pop     bx
    pop     ax
ENDM


;##############################################################################
; print_str -- Call MSDOS service to print string on screen
;
; Input :
;   STRP = string pointer
;   or
;   DX = string pointer
;
; Output:
;   None
;
; Modified:
;   AX
;   DX
;
print_str MACRO STRP

    push    ax
    push    dx

    ; MS-DOS print string function
    mov     ah, 09h

IFNB <STRP>
    mov     dx, offset STRP
ENDIF

    int     21h

    pop     dx
    pop     ax
ENDM


;##############################################################################
; clear_screen -- Clear Screen
;
; Input :
;   ATTR
;
; Output:
;   None
;
; Modified:
;   AX
;   BX
;   CX
;   DX
;
clear_screen MACRO ATTR

    push    ax
    push    bx
    push    cx
    push    dx

    mov     ah, 06h
    xor     al, al

IFNB <ATTR>
    mov     bh, ATTR
ELSE
    mov     bh, 07h   
ENDIF

    mov     ch, 0
    mov     cl, 0

    mov     dh, 24
    mov     dl, 79

    int     10h

    pop     dx
    pop     cx
    pop     bx
    pop     ax

ENDM


;------------------------------------------------------------------------------
; Code segment
;
_TEXT SEGMENT PARA USE16 'CODE'


;##############################################################################
; MAIN procedure
;
MAIN PROC FAR PRIVATE



	; Save for DOS return
	push    ds
	push    ax



	;--------------------------------------------------------------------------
	; REAL mode code
	;--------------------------------------------------------------------------
	ASSUME  SS:STACK, DS:_DATA, CS:_TEXT, ES:_DATA
	mov     ax, _DATA
	mov     ds, ax
    

	;
	; Disable for keyboard test
	;
	clear_screen
	set_cursor 0000h
	print_str help
	set_cursor 0000h


	;
	; Initialize Keyboard
	;
	call	InstallUMPCKbdHandler


check_exit:
	cmp	do_exit, 0
	jz	check_exit


	call	UninstallUMPCKbdHandler


	clear_screen
	set_cursor 0000h
	print_str version

    
	; Return to DOS
	ret

MAIN ENDP


E0_LASTKEY	DB	00h
E1_LASTKEY	DB	00h
;##############################################################################
; KbdUMPCIntHandler -- Keyboard interrupt handler for UMPC hotkey
;		       monitoring
;
; Input:
;   None
;
; Output:
;   None
;
; Modified:
;   All preserved
;
KbdUMPCIntHandler PROC FAR PUBLIC

	cli
	pushad
	push	es
	
	
	;
	; Read Keyboard scan code
	;
	mov	ax, 0B800h
	mov	es, ax
	xor	di, di


	;
	; Print string
	;
	mov	al, 'S'
	mov	es:[di], al

	mov	al, 'c'
	mov	es:[di+2], al

	mov	al, 'a'
	mov	es:[di+4], al

	mov	al, 'n'
	mov	es:[di+6], al

	mov	al, ' '
	mov	es:[di+8], al

	mov	al, 'C'
	mov	es:[di+10], al

	mov	al, 'o'
	mov	es:[di+12], al

	mov	al, 'd'
	mov	es:[di+14], al

	mov	al, 'e'
	mov	es:[di+16], al

	mov	al, ':'
	mov	es:[di+18], al


	;
	; Read keyboard input code
	;
	in	al, 060h


	;
	; Check E1
	;
	cmp	al, 0E1h
	jnz	not_0E1h


	mov	cs:E1_LASTKEY, 1
	jmp	check_next


not_0E1h:


	cmp	cs:E1_LASTKEY, 0
	jz	not_in_e1


	;
	; Now in E1
	;
	cmp	al, 01Dh
	jz	check_next

	cmp	al, 045h
	jz	check_next

	cmp	al, 09Dh
	jz	check_next

	cmp	al, 0C5h
	jnz	not_0C5h


	;
	; Reset E1 flag
	;
	mov	cs:E1_LASTKEY, 0


	mov	al, 'E'
	mov	es:[di+20], al
	mov	al, '1'
	mov	es:[di+22], al
	mov	al, ' '
	mov	es:[di+24], al
	mov	al, '1'
	mov	es:[di+26], al
	mov	al, 'D'
	mov	es:[di+28], al
	mov	al, ' '
	mov	es:[di+30], al
	mov	al, '4'
	mov	es:[di+32], al
	mov	al, '5'
	mov	es:[di+34], al
	mov	al, ' '
	mov	es:[di+36], al
	mov	al, 'E'
	mov	es:[di+38], al
	mov	al, '1'
	mov	es:[di+40], al
	mov	al, ' '
	mov	es:[di+42], al
	mov	al, '9'
	mov	es:[di+44], al
	mov	al, 'D'
	mov	es:[di+46], al
	mov	al, ' '
	mov	es:[di+48], al
	mov	al, 'C'
	mov	es:[di+50], al
	mov	al, '5'
	mov	es:[di+52], al
	

not_0C5h:


	jmp	check_next


not_in_e1:


	;
	; Check E0
	;
	cmp	al, 0E0h
	jnz	not_0E0h


	mov	cs:E0_LASTKEY, 1
	jmp	check_next


not_0E0h:


	;
	; Check last key is E0?
	;
	cmp	byte ptr cs:E0_LASTKEY, 0
	jz	not_in_e0


	;
	; E0 = 1
	;
	mov	cs:E0_LASTKEY, 0


	push	ax
	mov	al, 'E'
	mov	es:[di+20], al
	mov	al, '0'
	mov	es:[di+22], al
	pop	ax
	jmp	con1


not_in_e0:


	push	ax
	mov	al, ' '
	mov	es:[di+20], al
	mov	es:[di+22], al
	pop	ax


con1:
	cmp	al, 001h
	jnz	not_esc


	;
	; do exit
	;
	mov	do_exit, 001h


not_esc:

	
	;
	; Covert to ASCII hex
	;
	mov	ah, al
	and	al, 00Fh
	and	ah, 0F0h
	shr	ah, 4

	cmp	al, 0Ah
	jb	Below10

	sub	al, 00Ah
	add	al, 041h
	jmp	go1
Below10:
	add	al, 030h
go1:	
	mov	es:[di+28], al


	cmp	ah, 0Ah
	jb	Below10_2

	sub	ah, 00Ah
	add	ah, 041h
	jmp	go2
Below10_2:
	add	ah, 030h
go2:	
	mov	es:[di+26], ah


	mov	al, ' '
	mov	es:[di+30], al
	mov	es:[di+32], al
	mov	es:[di+34], al
	mov	es:[di+36], al
	mov	es:[di+38], al
	mov	es:[di+40], al
	mov	es:[di+42], al
	mov	es:[di+44], al
	mov	es:[di+46], al
	mov	es:[di+48], al
	mov	es:[di+50], al
	mov	es:[di+52], al

check_next:
skip_break_code:


	;
	; Issue End Of Interrupt
	;
	mov	al, 020h
	out	020h, al


	pop	es
	popad
	sti
	iret

KbdUMPCIntHandler ENDP


OldInt09Seg	DW	0000h
OldInt09Off	DW	0000h
;##############################################################################
; InstallUMPCKbdHandler -- Install/Patch original DOS keyboard interrupt
;			   handler for UMPC hotkey monitoring
;
; Input:
;   None
;
; Output:
;   None
;
; Modified:
;   All preserved
;
InstallUMPCKbdHandler PROC FAR PUBLIC


	push	ax
	push	ebx
	push	es


	;
	; Disable interrupt
	;
	cli


	;
	; Prepare variables
	; Patch INT 09h
	;
	xor	ax, ax
	mov	es, ax
	xor	ebx, ebx
	mov	bx, 09h


	;
	; Backup OLD INT 09h handler
	;
	mov	ax, word ptr es:[ebx*4]
	mov	cs:OldInt09Off, ax

	mov	ax, word ptr es:[ebx*4+2]
	mov	cs:OldInt09Seg, ax


	;
	; Install Offset
	;
	mov	word ptr es:[ebx*4], offset KbdUMPCIntHandler


	;
	; Install Segment
	;
	mov	word ptr es:[ebx*4+2], SEG KbdUMPCIntHandler


	;
	; Re-enable interrupt
	;
	sti


	pop	es
	pop	ebx
	pop	ax

	
	ret

InstallUMPCKbdHandler ENDP


;##############################################################################
; UninstallUMPCKbdHandler -- Uninstall/Unpatch original DOS keyboard interrupt
;			     handler for UMPC hotkey monitoring
;
; Input:
;   None
;
; Output:
;   None
;
; Modified:
;   All preserved
;
UninstallUMPCKbdHandler PROC FAR PUBLIC


	push	ax
	push	es
	push	ebx


	;
	; Disable interrupt
	;
	cli
	

	;
	; Prepare variables
	; Patch INT 09h
	;
	xor	ax, ax
	mov	es, ax
	xor	ebx, ebx
	mov	bx, 09h


	;
	; Restore original INT 09h handler
	;
	mov	ax, cs:OldInt09Off
	mov	word ptr es:[ebx*4], ax

	mov	ax, cs:OldInt09Seg
	mov	word ptr es:[ebx*4+2], ax


	;
	; Re-enable interrupt
	;
	sti


	pop	ebx
	pop	es
	pop	ax

	
	ret

UninstallUMPCKbdHandler ENDP


_TEXT ENDS






;------------------------------------------------------------------------------
; Data segment
;
_DATA SEGMENT PARA USE16 STACK 'STACK'
align 4


version     DB      13, 10, 'hotkey version 0.1 (C) 2007, Merck Hung', 13, 10, 13, 10, 24h
usage       DB      'Usage: hotkey', 13, 10, 13, 10, 24h
help	    DB	    13, 10, 'Please press any key, or ESC to exit.', 24h

do_exit	    DB	    00h


_DATA ENDS





;------------------------------------------------------------------------------
; Stack segment
;
STACK SEGMENT PARA USE16 STACK 'STACK'
align 4

	DW     64 DUP(0)

STACK ENDS



    END MAIN


