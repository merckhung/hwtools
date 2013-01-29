;
; libscn.asm -- VGA Screen Routines
;
; Copyright (C) 2008 - 2009, Merck Hung
; Author : Merck Hung <merckhung@gmail.com>
;
.586P


INCLUDE include\scn.inc


;------------------------------------------------------------------------------
; libscn code segment
;
libscn SEGMENT USE16 PUBLIC


;----------------------------------- PUBLIC -----------------------------------



;##############################################################################
; rbuTrickInt10h -- A trick to directly jump to INT 10h service
;
; Input:
;   None
;
; Output:
;   None
;
; Modified:
;   All possible
;
rbuTrickInt10h PROC FAR PUBLIC

    push    es
    push    bx

    ; Set pointer
    xor     ax, ax
    mov     es, ax
    mov     bx, 10h * 4

    ; Get position of Int 10h ISR
    mov     ax, es:[bx]
    mov     si, OFFSET Int10Offset
    mov     cs:[si], ax

    mov     ax, es:[bx+2]
    mov     si, OFFSET Int10Segment
    mov     cs:[si], ax


    ; Prepare for jumping to INT 10h
    pushf
    push    SEG Int10Ret
    push    OFFSET Int10Ret


    ; Do jumpping
    DB      0EAh

Int10Offset:
    DW      0000h

Int10Segment:
    DW      0000h


Int10Ret::


    pop     bx
    pop     es

    ret

rbuTrickInt10h ENDP



;##############################################################################
; rbuPrtScr -- Print string on 80x25 text mode screen
;
; Input:
;   DS:SI = String Buffer
;   BX    = Cursor position
;
; Output:
;   BX    = Lastest cursor position
;
; Modified:
;   BX
;
rbuPrtScr PROC FAR PUBLIC


    ; Save registers
    push    ax
    push    dx
    push    si
    push    es


    ; AL : ASCII code
    xor     al, al


    ; point to Video ram
    push    VIDEORAM
    pop     es


print_loop:


    ; get ASCII char
    mov     al, ds:[si]


    ; Check terminal char NULL
    cmp     al, 0
    jz      print_exit


    ; Check new line
    cmp     al, 10
    jnz     print_not_nl


    ; go to next line
    mov     ax, bx
    mov     dl, COLUMN * 2
    div     dl

    inc     al
    mul     dl

    dec     ax
    dec     ax
    mov     bx, ax

    jmp     print_next_char


print_not_nl:


    ; Print on screen
    mov     es:[bx], al


print_next_char:


    ; Pointer++
    inc     si
    inc     bx
    inc     bx

    jmp     print_loop


print_exit:


    ; Restore registers
    pop     es
    pop     si
    pop     dx
    pop     ax


    ret

rbuPrtScr ENDP



;##############################################################################
; rbuSetColor -- Set Screen Color
;
; Input:
;   AL    = Color Code
;   BX    = Cursor position
;   CX    = Length of Color Bar
;
; Output:
;   BX    = Lastest cursor position
;
; Modified:
;   BX
;
rbuSetColor PROC FAR PUBLIC


    ; Save registers
    push    ax
    push    cx
    push    es


    ; point to Video ram base
    push    VIDEORAM
    pop     es


PutColor:


    ; Put Color Code
    mov     es:[bx+1], al
    inc     bx
    inc     bx
    dec     cx
    jnz     PutColor


    ; Restore registers
    pop     es
    pop     cx
    pop     ax

    ret

rbuSetColor ENDP



;##############################################################################
; rbuClrScr -- Clear 80x25 Text Mode Screen
;
; Input:
;   None
;
; Output:
;   None
;
; Modified:
;   None
;
rbuClrScr PROC FAR PUBLIC

    push    ds
    push    ax
    push    bx
    push    cx


    ; Point to VGA Text mode buffer
    push    VIDEORAM
    pop     ds

    mov     ax, COL_WB
    xor     bx, bx
    mov     cx, (COLUMN * LINE * 2)


ClrScr:


    ; Clear Screen
    mov     ds:[bx], ax
    add     bx, 2
    sub     cx, 2
    jnz     ClrScr


    pop     cx
    pop     bx
    pop     ax
    pop     ds

    ret

rbuClrScr ENDP



;----------------------------------- PRIVATE -----------------------------------


libscn ENDS

    END


