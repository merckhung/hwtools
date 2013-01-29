;
; libkbd.asm -- x86 8042 keyboard routines
;
; Copyright (C) 2007 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
; This is a collection of keyboard 8042 routines for x86 assembly programming.
;
.586P


INCLUDE include\mroutine.inc
INCLUDE include\mdebug.inc
INCLUDE include\routine.inc


routine SEGMENT USE16 PUBLIC

	EXTERN byte_ascii_to_bin:FAR
	EXTERN conv_push_ascii:FAR
@CurSeg ENDS


;------------------------------------------------------------------------------
; libkbd code segment
;
libkbd SEGMENT USE16 PUBLIC



;----------------------------------- PUBLIC -----------------------------------


;##############################################################################
; KbdSendCmd -- Send command to keyboard controller
;
; Input:
;   AL  = Keyboard Command Code
;
; Output:
;   None
;
; Modified:
;   AL
;
KbdSendCmd PROC FAR PUBLIC


	;
	; Save input for later issue
	;
	push	ax
	

	;
	; Disable keyboard
	;
	mov	al, 0ADh
	call	KbdSendCmd_8042
	jc	KbdSendCmd_EXIT


	;
	; Disable interrupt
	;
	;cli


	;
	; Send command to keyboard
	;
	pop	ax
	out	060h, al


	;
	; Re-enable interrupt
	;
	;sti


	;
	; Re-enable keyboard
	;
	mov	al, 0AEh
	call	KbdSendCmd_8042


KbdSendCmd_EXIT:
    
	ret


KbdSendCmd ENDP



;##############################################################################
; KbdSendCmd_8042 -- Send command to on-board 8042 controller
;
; Input:
;   AL  = Keyboard Command Code
;
; Output:
;   CARRY = 0 : Success
;	  = 1 : Failed
;
; Modified:
;   All preserved
;
KbdSendCmd_8042 PROC NEAR PUBLIC


	;
	; Save input command code
	;
	push	ax


	;
	; Disable interrupt
	;
	;cli


	;
	; Wait for input buffer empty
	;
	call	KbdWaitInputEmpty
	jc	KbSendCmd_8042_ABORT


	;
	; Send Command to 8042
	;
	pop	ax
	out	064h, al


	;
	; Wait again
	;
	call	KbdWaitInputEmpty
	jc	KbSendCmd_8042_ABORT


	;
	; Success, Clear CARRY = 0
	;
	clc
	jmp	KbSendCmd_8042_EXIT


KbSendCmd_8042_ABORT:


	;
	; Failed, Set CARRY = 1
	;
	stc


KbSendCmd_8042_EXIT:


	;
	; Re-enable interrupt
	;
    	;sti
    	

	ret

KbdSendCmd_8042 ENDP


;##############################################################################
; KbdWaitInputEmpty -- Wait for input buffer empty
;
; Input:
;   AL  = Keyboard Command Code
;
; Output:
;   CARRY = 0 : Success
;	  = 1 : ABORT
;
; Modified:
;   All preserved
;
KbdWaitInputEmpty PROC NEAR PUBLIC


	push	ax
	push	cx


	;
	; Wait for input buffer empty
	;
	mov	cx, 0FFFFh

KbdWaitInputEmpty_WRDY:

	dec	cx
	jz	KbdWaitInputEmpty_ABORT


	;
	; Read Data port and wait it empty
	;
	in	al, 064h
	test	al, 002h
	jnz	KbdWaitInputEmpty_WRDY


	;
	; Clear CARRY = 0
	;
	clc
	jmp	KbdWaitInputEmpty_EXIT
	

KbdWaitInputEmpty_ABORT:

	;
	; Set CARRY = 1
	;
	stc


KbdWaitInputEmpty_EXIT:


	pop	cx
	pop	ax


	ret

KbdWaitInputEmpty ENDP


;##############################################################################
; KbdUMPCReadHotkey -- Issue UMPC specificed C7-25 Sequence for
;		       reading Hotkey data
;
; Input:
;   BL  : Button ID to check
;
; Output:
;   AX	: UMPC hotkey data
;
; Modified:
;   All preserved
;
KbdUMPCReadHotkey PROC FAR PUBLIC


	;
	; Disable keyboard
	;
	mov	al, 0ADh
	call	KbdSendCmd_8042
	jc	KbdUMPCReadHotkey_EXIT


	;
	; Issue 0C7h command to 8042
	;
	mov	al, 0C7h
	call	KbdSendCmd_8042
	jc	KbdUMPCReadHotkey_EXIT


	;
	; Disable interrupt
	;
	;cli


	;
	; Send sub command to keyboard
	;
	mov	al, bl
	out	060h, al


	;
	; Read Hotkey High byte
	;
	in	al, 060h
	mov	ah, al


	;
	; Read Hotkey Low byte
	;
	in	al, 060h


	;
	; Save result for later return
	;
	push	ax


	;
	; Re-enable interrupt
	;
	;sti


	;
	; Re-enable keyboard
	;
	mov	al, 0AEh
	call	KbdSendCmd_8042


	;
	; Restore data for returning
	;
	pop	ax


KbdUMPCReadHotkey_EXIT:

    
	ret

KbdUMPCReadHotkey ENDP


;##############################################################################
; KbdReadKeyCode -- Read keyboard scan code
;
; Input:
;   None
;
; Output:
;   AL	: Keyboard scan code
;
; Modified:
;   AL
;
KbdReadKeyCode PROC FAR PUBLIC

	in	al, 060h
	ret

KbdReadKeyCode ENDP


;##############################################################################
; KbdPollDelay -- Poll read keyboard scan code for diagnostic
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
KbdPollDelay PROC FAR PUBLIC


	push	ecx
	push	dx


	; Delay for user input
	mov     dx, 0fh


mydelay2:

	mov     ecx, 0ffffh
	
mydelay:
	dec     ecx
	jnz     mydelay

	dec     dx
	jnz     mydelay2


	pop	dx
	pop	ecx


	ret

KbdPollDelay ENDP



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


	in	al, 060h
	test	al, 80h
	jnz	skip_break_code


	push	ax
	

	mov	al, 'M'
	mov	es:[di], al

	mov	al, 'a'
	mov	es:[di+2], al

	mov	al, 'k'
	mov	es:[di+4], al

	mov	al, 'e'
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


	pop	ax


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
	mov	es:[di+22], al


	cmp	ah, 0Ah
	jb	Below10_2

	sub	ah, 00Ah
	add	ah, 041h
	jmp	go2
Below10_2:
	add	ah, 030h
go2:	
	mov	es:[di+20], ah


	mov	al, 'h'
	mov	es:[di+24], al


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


libkbd ENDS

    END


