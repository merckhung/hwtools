;
; mroutine.inc -- Generic Macro routines
;
; Copyright (C) 2007 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;


;##############################################################################
; get_cursor -- Call BIOS service to get current cursor position in DX
;
; Input :
;   None
;
; Output:
;   DH  = Line on Screen
;   DL  = Column on Screen
;
; Modified:
;   AX
;   BH
;   CX
;
get_cursor MACRO

    push    ax
    push    bx
    push    cx

    mov     ah, 03h
    xor     bh, bh
    int     10h

    pop     cx 
    pop     bx
    pop     ax
ENDM


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
; wait_input -- Call BIOS service to get keyboard input
;
; Input :
;   None
;
; Output:
;   AH  = Scan code
;   AL  = ASCII code
;
; Modified:
;   None
;
wait_input MACRO

    xor     ax, ax
    int     16h
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
; replace_ascii_str -- macro version, convert ascii number into string buffer
;
; Input :
;   None
;
; Output:
;   None
;
; Modified:
;   EAX
;   CX
;   DI
;
replace_ascii_str MACRO STRP, BA, OFFS

    push    eax
    push    cx
    push    di

    mov     cl, (BA - 1) * NBPAB
    mov     di, offset STRP
    add     di, OFFS
    call    conv_push_ascii

    pop     di
    pop     cx
    pop     eax

ENDM


;##############################################################################
; print_ascii_str -- print ascii number and string
;
; Input :
;   None
;
; Output:
;   None
;
; Modified:
;   EAX
;   CX
;   DI
;
print_ascii_str MACRO STRP, BA, OFFS

    push    eax
    push    cx
    push    di

    mov     cl, (BA - 1) * NBPAB
    mov     di, offset STRP
    add     di, OFFS
    call    conv_push_ascii
    print_str STRP

    pop     di
    pop     cx
    pop     eax

ENDM


;##############################################################################
; line_highlight -- highlight specific line
;
; Input :
;   LINE
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
line_highlight MACRO LINE

    push    ax
    push    bx
    push    cx
    push    dx

    mov     ah, 06h
    xor     al, al

    mov     bh, 02fh

    mov     ch, LINE
    mov     cl, 0

    mov     dh, LINE
    mov     dl, 79

    int     10h

    pop     dx
    pop     cx
    pop     bx
    pop     ax

ENDM


;##############################################################################
; line_normal -- disable highlight
;
; Input :
;   LINE
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
line_normal MACRO line

    push    ax
    push    bx
    push    cx
    push    dx

    mov     ah, 06h
    xor     al, al

    mov     bh, 07h

    mov     ch, LINE
    mov     cl, 0

    mov     dh, LINE
    mov     dl, 79

    int     10h

    pop     dx
    pop     cx
    pop     bx
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


;##############################################################################
; set_screen -- Set Screen Color
;
; Input :
;   ATTR
;   L0
;   L1
;   C0
;   C1
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
set_screen MACRO ATTR, L0, L1, C0, C1

    push    ax
    push    bx
    push    cx
    push    dx

    mov     ah, 06h
    xor     al, al

    mov     bh, ATTR

    mov     ch, L0
    mov     cl, L1

    mov     dh, C0
    mov     dl, C1

    int     10h

    pop     dx
    pop     cx
    pop     bx
    pop     ax

ENDM


;##############################################################################
; set_feiled -- Set field Color
;
; Input :
;   ATTR
;   CH
;   CL
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
set_field MACRO ATTR

    push    ax
    push    bx
    push    cx
    push    dx

    mov     ah, 06h
    xor     al, al

    mov     bh, ATTR

    mov     dh, ch
    mov     dl, cl
    inc     dl

    int     10h

    pop     dx
    pop     cx
    pop     bx
    pop     ax

ENDM


;##############################################################################
; bin_to_bcd -- Convert Binary to BCD
;
; Input :
;   AX      = Binary number
;   or
;   DIGITS  = How many digits we handle? (1 - 8)
;   BINNUM  = Binary to convert
;
; Output:
;   EAX = ASCII code of Dec. number
;
; Modified:
;   BX
;   CX
;   DX
;
bin_to_bcd MACRO DIGITS, BINNUM

    LOCAL   b2d_next_loop, b2d_ax_next


    push    bx
    push    cx
    push    dx



IFNB <BINNUM>
    mov     ax, BINNUM
ENDIF


    ; Prevent Most Significant Double Word had value
    and     eax, 0000ffffh


    ; How many digits we handle?
    mov     cx, DIGITS


    ; Initialize loop
    mov     bx, 10


b2d_next_loop:

    ; DS:AX / BX
    xor     dx, dx
    div     bx


    ; Save quotient
    push    dx


    dec     cx
    jnz     b2d_next_loop


    ;
    ; Assemble result
    ;
    xor     eax, eax
    xor     bx, bx
    mov     cx, DIGITS


b2d_ax_next:
    shl     eax, 4
    pop     bx
    or      al, bl

    dec     cx
    jnz     b2d_ax_next



    pop     dx
    pop     cx
    pop     bx

ENDM


;##############################################################################
; line_highlight2 -- highlight specific line
;
; Input :
;   LINE
;
; Output:
;   None
;
; Modified:
;   ES
;   AX
;   CX
;   DX
;
line_highlight2 MACRO LINE

    LOCAL   line_highlight2_loop

    push    ax
    push    cx
    push    di
    push    es


    ; Calculate position
    mov     al, LINE
    mov     cl, 80 * 2
    mul     cl
    mov     di, ax
    inc			di

    mov     ax, 0b800h
    mov     es, ax
    mov     al, 2fh
    mov		cl, 80

line_highlight2_loop: 

    mov     es:[di], al
    inc		di
    inc		di
    dec     cl
    jnz     line_highlight2_loop

    pop     es
    pop     di
    pop     cx
    pop     ax

ENDM


;##############################################################################
; line_normal2 -- disable highlight
;
; Input :
;   LINE
;
; Output:
;   None
;
; Modified:
;   ES
;   AX
;   CX
;   DI
;
line_normal2 MACRO LINE

    LOCAL   line_normal2_loop

    push    ax
    push    cx
    push    di
    push    es


    ; Calculate position
    mov     al, LINE
    mov     cl, 80 * 2
    mul     cl
    inc     ax
    mov     di, ax

    mov     ax, 0b800h
    mov     es, ax
    mov     al, 07h
    mov			cl, 80

line_normal2_loop: 

    mov     es:[di], al
    inc     di
    inc     di
    dec     cl
    jnz     line_normal2_loop

    pop     es
    pop     di
    pop     cx
    pop     ax


ENDM


;##############################################################################
; set_feiled2 -- Set field Color
;
; Input :
;   ATTR
;   CH
;   CL
;
; Output:
;   None
;
; Modified:
;   ES
;   AX
;   CX
;   DI
;
set_field2 MACRO ATTR

    push    ax
    push    cx
    push    di
    push    es


    ; Calculate position
    mov     al, 80 * 2
    mul     ch
    mov		di, ax
    
    mov		al, 2
    mul		cl
    
    add		di, ax

    mov     ax, 0b800h
    mov     es, ax

    mov     al, ATTR

    mov     es:[di+1], al
    mov     es:[di+3], al

    pop     es
    pop     di
    pop     cx
    pop     ax

ENDM


;##############################################################################
; scrollup_one_line -- Directly accesss Video RAM to scroll line up
;
; Input :
;   LINE_START
;   LINE_END
;
; Output:
;   None
;
; Modified:
;   ES
;   AX
;   CX
;   DI
;		SI
;
scrollup_one_line MACRO LINE_START, LINE_END

    LOCAL   scrollup_one_line_loop

    push    ax
    push    cx
    push    di
    push		si
    push    es


    ; Calculate start position
    mov     al, LINE_START
    mov     cl, 80 * 2
    mul     cl
    mov     si, ax
    sub			ax, 80 * 2
    mov			di, ax
    
    ; Calculate end position
		mov			cx, (LINE_END - LINE_START + 1) * 80

		; Setup base address
    mov     ax, 0b800h
    mov			es, ax
    mov			ah, 20h

scrollup_one_line_loop: 

		mov			al, es:[si]
		mov			es:[si], ah
    mov     es:[di], al

    inc     di
    inc     di
		inc			si
		inc			si

    dec     cx
    jnz     scrollup_one_line_loop

    pop     es
    pop			si
    pop     di
    pop     cx
    pop     ax

ENDM



;##############################################################################
; scrolldown_one_line -- Directly accesss Video RAM to scroll line down
;
; Input :
;   LINE_START
;   LINE_END
;
; Output:
;   None
;
; Modified:
;   ES
;   AX
;   CX
;   DI
;		SI
;
scrolldown_one_line MACRO LINE_START, LINE_END

    LOCAL   scrolldown_one_line_loop

    push    ax
    push    cx
    push    di
    push		si
    push    es


    ; Calculate start position
    mov     al, LINE_END
    mov     cl, 80 * 2
    mul     cl
    mov     si, ax
    add			ax, 80 * 2
    mov			di, ax
    
    ; Calculate end position
		mov			cx, (LINE_END - LINE_START) * 80

		; Setup base address
    mov     ax, 0b800h
    mov			es, ax
    mov			ah, 20h

scrolldown_one_line_loop: 

    mov			al, es:[si]
    mov			es:[si], ah
    mov     es:[di], al

    dec     di
    dec     di
		dec			si
		dec			si

    dec     cx
    jnz     scrolldown_one_line_loop

    pop     es
    pop			si
    pop     di
    pop     cx
    pop     ax

ENDM


;##############################################################################
; myseekfile -- Seek file handler
;
; Input:
;   None
;
; Output:
;   None
;
; Modified:
;   AX
;   DS
;   BX
;   ECX
;   EDX
;
myseekfile MACRO HANDLER, MODE, OFFSET

    push    ax
    push    ds
    push    bx
    push    ecx
    push    edx

    
    mov     ax, seg HANDLER
    mov     ds, ax
    mov     bx, HANDLER
    
    mov     ecx, OFFSET
    and     ecx, 0ffff0000h
    shr     ecx, 16

    mov     edx, OFFSET
    and     edx, 00000ffffh

    mov     al, MODE
    mov     ah, 42h
    int     21h
    

    pop     edx
    pop     ecx
    pop     bx
    pop     ds
    pop     ax

ENDM


;##############################################################################
; beep -- Use PC speaker
;
; Input:
;   None
;
; Output:
;   None
;
; Modified:
;   AX
;   DX
;   ECX
;
beep MACRO

    push    ax
    push    dx
    push    ecx


    ; Save original value
    mov     al, 0b6h
    out     43h, al


    ; Write my value
    mov     ax, 0800h
    out     42h, al
    mov     al, ah
    out     42h, al


    ; Enable beep
    in      al, 61h
    or      al, 03h
    out     61h, al


    ; Delay loop
    mov     dx, 00fh

mydelay2:
    mov     ecx, 0ffffffffh
mydelay:
    dec     ecx
    jnz     mydelay

    dec     dx
    jnz     mydelay2
    

    ; Disable beep
    in      al, 61h
    and     al, 0fch
    out     61h, al


    pop     ecx
    pop     dx
    pop     ax

ENDM



;##############################################################################
; CompareBuffers -- Compare between two buffers
;
; Input:
;   BUF1    -- Buffer1
;   BUF2    -- Buffer2
;   LEN     -- Length of Buffer1 and Buffer2
;
; Output:
;   Carry   -- 1: Not Identical
;           -- 0: Identical
;
; Modified:
;   None
;
CompareBuffers MACRO BUF1, BUF2, LEN


    LOCAL Identical, NotIdentical, CheckNextByte


    push    ax
    push    cx
    push    si
    push    di
    push    ds
    push    es


    ; Setup Pointer
    push    SEG BUF1
    pop     ds
    mov     si, OFFSET BUF1

    ; Setup Pointer
    push    SEG BUF2
    pop     es
    mov     di, OFFSET BUF2

    ; Setup Counter
    mov     cx, LEN


CheckNextByte:


    ; Fetch One Byte
    mov     al, ds:[si]
    mov     ah, es:[di]

    ; Do Compare
    cmp     ah, al
    jne     NotIdentical

    ; Check Next Byte
    inc     si
    inc     di
    dec     cx

    jnz     CheckNextByte


    clc
    jmp     Identical


NotIdentical:

    stc


Identical:


    pop     es
    pop     ds
    pop     di
    pop     si
    pop     cx
    pop     ax

ENDM



